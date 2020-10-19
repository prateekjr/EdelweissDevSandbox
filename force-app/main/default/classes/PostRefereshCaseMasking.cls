global class PostRefereshCaseMasking implements Database.Batchable<sObject>, Database.Stateful  {
    
    global String strQuery;
    global PostRefereshCaseMasking(){
        strQuery = 'SELECT id , ContactEmail , SuppliedEmail , AccountOwnerManagerEmail__c , Client_Email__c , Client_Representative_Email_Id__c , Email_Id__c , Joint_Holder_Client1_Email_ID__c , Joint_Holder_Client2_Email_ID__c , TicketCreatorManagerEmail__c	 , TicketOwnerManagerEmail__c FROM CASE' ;
        system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Case> allCaseToBeMasked) {
        List<Case> toBeUpdated = new List<Case>();
        Boolean isChanged = false;
        for(Case cObj : allCaseToBeMasked){
            
            if(cObj.Client_Representative_Email_Id__c != null){
                cObj.Client_Representative_Email_Id__c = '111'+cObj.Client_Representative_Email_Id__c  ;
                isChanged = true;
            }
            
            if(cObj.AccountOwnerManagerEmail__c != null){
                cObj.AccountOwnerManagerEmail__c = '111'+cObj.AccountOwnerManagerEmail__c  ;
                isChanged = true;
            }
            
            if(cObj.Client_Email__c != null){
                cObj.Client_Email__c = '111'+cObj.Client_Email__c  ;
                isChanged = true;
            }
            
            if(cObj.Email_Id__c != null){
                cObj.Email_Id__c = '111'+cObj.Email_Id__c  ;
                isChanged = true;
            }
            if(cObj.Joint_Holder_Client1_Email_ID__c != null){
                cObj.Joint_Holder_Client1_Email_ID__c = '111'+cObj.Joint_Holder_Client1_Email_ID__c  ;
                isChanged = true;
            }
            if(cObj.Joint_Holder_Client2_Email_ID__c != null){
                cObj.Joint_Holder_Client2_Email_ID__c = '111'+cObj.Joint_Holder_Client2_Email_ID__c  ;
                isChanged = true;
            }
            if(cObj.TicketCreatorManagerEmail__c != null){
                cObj.TicketCreatorManagerEmail__c = '111'+cObj.TicketCreatorManagerEmail__c  ;
                isChanged = true;
            }
            if(cObj.TicketOwnerManagerEmail__c != null){
                cObj.TicketOwnerManagerEmail__c = '111'+cObj.TicketOwnerManagerEmail__c  ;
                isChanged = true;
            }
            
            if(isChanged){
                toBeUpdated.add(cObj);
            }
            
            
        }
        database.update(toBeUpdated,false);
    }   
    global void finish(Database.BatchableContext bcMain){}
}