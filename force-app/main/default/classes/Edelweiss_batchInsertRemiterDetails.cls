global with sharing class Edelweiss_batchInsertRemiterDetails implements Database.Batchable<sObject> , Database.Stateful{
    
    global String query;
    global Boolean isError;
    global User defaultUser;
    List<Remitter_Account_Details__c> listOfDetailRecords  = new List<Remitter_Account_Details__c>();
    List<Edelweiss_Clients_Staging_Container__c> errorStagingContainer = new List<Edelweiss_Clients_Staging_Container__c>();
    global Edelweiss_batchInsertRemiterDetails(){
        query = 'Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,GWM_Online_Account_Id__c, Remitter_Account_No__c ,ErrorMessage__c,Error__c,Synch__C FROM Edelweiss_Clients_Staging_Container__c';
        listOfDetailRecords = [SELECT id FROM Remitter_Account_Details__c];
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Clients_Staging_Container__c	> listOfStaging){
        List<Remitter_Account_Details__c> toBeInserted = new List<Remitter_Account_Details__c>();
        Map<String,Remitter_Account_Details__c> toBeInsertedMap = new Map<String,Remitter_Account_Details__c>();
        String mapUniqueKey;
        String gwmAccountId;
        String remitterAccNumber;
        Map<id,Edelweiss_Clients_Staging_Container__c	> mapOfRemitterstaging = new Map<id,Edelweiss_Clients_Staging_Container__c	>();
        if(listOfDetailRecords.isEmpty()){ 
        for(Edelweiss_Clients_Staging_Container__c	 stagingObj : listOfStaging){
            mapOfRemitterstaging.put(stagingObj.id , stagingObj);
            Remitter_Account_Details__c Obj = new Remitter_Account_Details__c();
            if(stagingObj.GWM_Online_Account_Id__c != null){
                Obj.GWM_Client_Account_Id__c = stagingObj.GWM_Online_Account_Id__c; 
                gwmAccountId=stagingObj.GWM_Online_Account_Id__c;
            }
            if(stagingObj.Remitter_Account_No__c != null){
                Obj.Remitter_Account_No__c = stagingObj.Remitter_Account_No__c; 
                remitterAccNumber=stagingObj.Remitter_Account_No__c; 
            }
            
            if(Obj != null){
                mapUniqueKey=gwmAccountId+'::'+remitterAccNumber;
                toBeInsertedMap.put(mapUniqueKey,Obj);
            }
        }
        }//IfEnds
        
        if(toBeInsertedMap != null && !toBeInsertedMap.isEmpty()){
            Database.SaveResult[] RemitterAccDetails  = database.insert(toBeInsertedMap.values(),false);
            System.debug('toBeInserted'+toBeInserted);
            for(Database.SaveResult sr : RemitterAccDetails)
            {   
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
            			System.debug('The following error has occurred.');                    
            			System.debug(err.getStatusCode() + ': ' + err.getMessage());
            			System.debug('Account fields that affected this error: ' + err.getFields());
        			}
                    
                    
                }//IfEnds
            }//ForEnd
        } //IfEnds  
        
        
    }
    
    global void finish(Database.BatchableContext bcMain) 
    {
        /*System.debug('****************** errorStagingContainer'+errorStagingContainer);
        if(errorStagingContainer != null && errorStagingContainer.size() > 0){
            update errorStagingContainer;
        }
*/
      //Database.executeBatch(new Edelweiss_batchDeleteRemStgContainer());
    }
}