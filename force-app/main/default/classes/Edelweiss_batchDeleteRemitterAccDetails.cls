global with sharing class Edelweiss_batchDeleteRemitterAccDetails implements Database.Batchable<sObject> , Database.Stateful{
    
    global String query;
    Integer stagingRecordCount;
    global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;

    global Edelweiss_batchDeleteRemitterAccDetails(){
        query = 'SELECT id FROM Remitter_Account_Details__c';
         notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Remitter_Account_Details__c> listOfRemitterAcc){
		List<Edelweiss_Clients_Staging_Container__c> stagingList    =  [SELECT id FROM Edelweiss_Clients_Staging_Container__c	 WHERE Error__c = false];
        
        List<Remitter_Account_Details__c> toBeDeleted = new List<Remitter_Account_Details__c>();
 		if(!stagingList.isEmpty() && stagingList != null){
            Database.DeleteResult[] resultList = Database.delete(listOfRemitterAcc, false);
            DataBase.emptyRecycleBin(listOfRemitterAcc);
              
            for(Database.DeleteResult result: resultList){
                if(result.isSuccess()){
                    successRecordIds.add(result.getId());
                }
                else{ 
                    notifyAdminFlag = true;
                    failedRecordCounter++;
                }
            } 
            system.debug('Number of records deleted successfully: '+successRecordIds.size()+' Number of failed records: '+failedRecordCounter);
        }
    }
    
    global void finish(Database.BatchableContext bcMain) 
    {
       Database.executeBatch(new Edelweiss_batchInsertRemiterDetails());
        if(notifyAdminFlag){
            Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('Edelweiss_batchDeleteRemitterAccDetails','Remitter Acc Details Staging Container', 'Remitter Acc Details Staging Container', successRecordIds.size(), failedRecordCounter);
        }
    }
}