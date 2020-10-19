global with sharing class Edelweiss_batchInsertNonPOABankDetails implements Database.Batchable<sObject> , Database.Stateful{
    
    global String query;
    global Boolean isError;
    global User defaultUser;
    List<Non_POA_Account__c> listOfNonPOARecords  = new List<Non_POA_Account__c>();
    List<Non_POA_Bank_Details_Staging_Container__c> errorStagingContainer = new List<Non_POA_Bank_Details_Staging_Container__c>();
    global Edelweiss_batchInsertNonPOABankDetails(){
        query = 'Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Bank_Details__c, Beneficiary_Account_Number__c, Bank_Name__c, Beneficiary_Name__c, GWM_Client_Account_Id__c, Beneficiary_Bank_IFSC_Code__c,Error_Message__c,Error__c,Success__c FROM Non_POA_Bank_Details_Staging_Container__c where Error__c = false';
   		listOfNonPOARecords = [SELECT id FROM Non_POA_Account__c];
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Non_POA_Bank_Details_Staging_Container__c> listOfStaging){
        List<Non_POA_Account__c> toBeInserted = new List<Non_POA_Account__c>();
        Map<id,Non_POA_Bank_Details_Staging_Container__c> mapOfNonPOAStaging = new Map<id,Non_POA_Bank_Details_Staging_Container__c>();
        if(listOfNonPOARecords.isEmpty()){ 
        for(Non_POA_Bank_Details_Staging_Container__c stagingObj : listOfStaging){
            mapOfNonPOAStaging.put(stagingObj.id , stagingObj);
            Non_POA_Account__c Obj = new Non_POA_Account__c();
            if(stagingObj.Bank_Details__c != null){
                Obj.Bank_Details__c = stagingObj.Bank_Details__c;
            }
            if(stagingObj.Beneficiary_Account_Number__c != null){
                Obj.Beneficiary_Account_Number__c = stagingObj.Beneficiary_Account_Number__c;        
            }
            if(stagingObj.Bank_Name__c != null){
                Obj.Bank_Name__c = stagingObj.Bank_Name__c;        
            }
            if(stagingObj.Beneficiary_Name__c != null){
                Obj.Beneficiary_Name__c = stagingObj.Beneficiary_Name__c;     
            }
            if(stagingObj.GWM_Client_Account_Id__c != null){
                Obj.GWM_Client_Account_Id__c = stagingObj.GWM_Client_Account_Id__c;  
            }
            if(stagingObj.Beneficiary_Bank_IFSC_Code__c != null){
                Obj.Beneficiary_Bank_IFSC_Code__c = stagingObj.Beneficiary_Bank_IFSC_Code__c; 
            }
            if(stagingObj.Bank_Details__c != null){
                Obj.Bank_Details__c = stagingObj.Bank_Details__c;
            }
            if(stagingObj.id != null){
                Obj.Non_POA_Staging_Lookup__c = stagingObj.id;
                
            }
            if(Obj != null){
                toBeInserted.add(Obj);
            }
        }
        }//IfEnds
        
        if(toBeInserted != null && !toBeInserted.isEmpty()){
            Integer index = 0;
            Database.SaveResult[] NonPOAAccounts  = database.insert(toBeInserted,false);
            System.debug('toBeInserted'+toBeInserted);
            for(Database.SaveResult sr : NonPOAAccounts)
            {	
                if(!sr.isSuccess()){
                    String errorMessage = '';
                    
                    if(mapOfNonPOAStaging.get(toBeInserted[index].Non_POA_Staging_Lookup__c) != null){
                        Non_POA_Account__c forSerach =  toBeInserted[index];
                        Id stagingId = forSerach.Non_POA_Staging_Lookup__c;
                        Non_POA_Bank_Details_Staging_Container__c stagingObj = new Non_POA_Bank_Details_Staging_Container__c();
                        stagingObj = mapOfNonPOAStaging.get(stagingId);
                        
                        if(String.isEmpty(stagingObj.Error_Message__c)){
                            stagingObj.Error_Message__c = '';
                        }
                        errorMessage = stagingObj.Error_Message__c;
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage+= err.getMessage() + '\n'; 
                        }                                                                          
                        stagingObj.Error_Message__c = errorMessage;    
                        stagingObj.Error__c = true;
                        stagingObj.Success__c = false;
                        errorStagingContainer = new List<Non_POA_Bank_Details_Staging_Container__c>();
                        errorStagingContainer.add(stagingObj);
                    }
                }//IfEnds
                else{
                    if(mapOfNonPOAStaging.get(toBeInserted[index].Non_POA_Staging_Lookup__c) != null){
                         System.debug('***** index'+index);
                        Non_POA_Account__c forSerach =  toBeInserted[index];
                        Id stagingId = forSerach.Non_POA_Staging_Lookup__c;
                        System.debug('********* stagingId'+stagingId);
                        Non_POA_Bank_Details_Staging_Container__c stagingObj = new Non_POA_Bank_Details_Staging_Container__c();
                        stagingObj = mapOfNonPOAStaging.get(stagingId);
                        stagingObj.Error_Message__c = '';    
                        stagingObj.Error__c = false;
                       	stagingObj.Success__c = true;
                        errorStagingContainer.add(stagingObj);
                    }
                }
                
                index++; 
                
            }//ForEnd
        } //IfEnds	
        
        
    }
    
    global void finish(Database.BatchableContext bcMain) 
    {
        System.debug('****************** errorStagingContainer'+errorStagingContainer);
        if(errorStagingContainer != null && errorStagingContainer.size() > 0){
            update errorStagingContainer;
        }
      Database.executeBatch(new Edelweiss_batchDeleteNonPOAStgContainer());
    }
}