public class AdditionalLeadTriggerHandler {

    public static void verifyPANDuplication(List<Additional_Lead__c> lstLeads){
        
        List<String> lstPan = new List<String>();
        for(Additional_Lead__c lead : lstLeads){
            if(!String.isEmpty(lead.PAN_Number__c)){
                lead.PAN_Number__c = (lead.PAN_Number__c).toUppercase();
            	lstPan.add(lead.PAN_Number__c);
                System.debug('Case : '+lead.Case__c);
            }
        }
        
        List<Additional_Lead__c> lstAdditionalLead = [
            SELECT Id, Name, Pan_Number__c FROM Additional_Lead__c WHERE Pan_Number__c IN :lstPan
        ];
        
        if(lstAdditionalLead != null && !lstAdditionalLead.isEmpty()){
            
            for(Additional_Lead__c objAdditionalLead : lstAdditionalLead){
                for(Additional_Lead__c lead : lstLeads){
                    if(Trigger.isInsert){
                        if(!String.isEmpty(lead.PAN_Number__c) && lead.PAN_Number__c == objAdditionalLead.PAN_Number__c){
                            lead.Pan_Number__c.addError('Additional Lead already exist with this PAN number');
                        }
                    }
                    else if(Trigger.isUpdate){
                        if(!String.isEmpty(lead.PAN_Number__c) && lead.PAN_Number__c == objAdditionalLead.PAN_Number__c && objAdditionalLead.Id != lead.Id){
                            lead.Pan_Number__c.addError('Additional Lead already exist with this PAN number');
                        }
                    }
                }
            }
        }
        
        
        
        List<Account> lstAccount = [
            SELECT Id, Name, PAN_Number__c FROM Account
            WHERE PAN_Number__c IN :lstPan
        ];
        
        if(lstAccount != null && !lstAccount.isEmpty()){
            for(Account objAcc : lstAccount){
                for(Additional_Lead__c lead : lstLeads){
                    if(!lead.Converted_To_Client__c && !String.isEmpty(lead.PAN_Number__c) && lead.PAN_Number__c == objAcc.PAN_Number__c){
                        lead.Pan_Number__c.addError('Lead/Client already exist with this PAN number');
                    }
                }
            }
        }
    }
    
    public static void checkCaseTask(List<Additional_Lead__c> lstLeads){
        Map<Id, ID> mapOfLeadAndCase =  new Map<Id, ID>();
        List<Id> listOfCases = new List<Id>();
        List<Id> listOfAdditionalLeads = new List<Id>();
        Map<Id,Additional_Lead__c> mapOfAdditionalLeads = new  Map<Id,Additional_Lead__c>();
        System.debug('lstLeads'+lstLeads);
        for(Additional_Lead__c al : lstLeads){
				listOfCases.add(al.Case__c);
            	mapOfLeadAndCase.put(al.Case__c , al.id);
            	mapOfAdditionalLeads.put(al.id, al);
        }      
        
        Map<Id,Case> mapOfCases = new  Map<Id,Case>([SELECT id, Status , RecordType.name FROM case WHERE (RecordType.name = 'Exchange Account Opening' OR RecordType.name = 'Non-Exchange Account Opening' OR  RecordType.name = 'Funding Account Opening') AND id IN:listOfCases]);
	    Map<Id,Task> mapofTasks = new Map<Id,Task>([SELECT id , subject , Status, WhatId FROM task  WHERE WhatId IN :mapOfCases.keyset()]);
        Map<Id,Case> mapOfTaskAndCase = new Map<Id,Case>();
         System.debug('**** mapOfCases '+mapOfCases);
        
        for(case c : mapOfCases.values()){
            if((c.Status == 'Closed – Rejected' || c.Status == 'Closed – Success')){
            Id additionalLeadId = mapOfLeadAndCase.get(c.id);
            Additional_Lead__c errorAL = mapOfAdditionalLeads.get(additionalLeadId);
            System.debug('errorAL'+errorAL);
            errorAL.addError('The record is locked; hence cannot edit / add');
            }
        }
        	
        for(Task tObj : mapofTasks.values()){
            case c = mapOfCases.get(tObj.whatId);	
            if((c.Status == 'Closed – Rejected' || c.Status == 'Closed – Success') || (tObj.Status == 'Completed' && tObj.subject == 'Update PAN Number' || tObj.Status == 'Completed' && tObj.subject == 'Miles Account Opening')){
            Id additionalLeadId = mapOfLeadAndCase.get(c.id);
            Additional_Lead__c errorAL = mapOfAdditionalLeads.get(additionalLeadId);
            System.debug('errorAL'+errorAL);
            errorAL.addError('The record is locked; hence cannot edit / add');
            }
        }
    }
    
}