global with sharing class Edelweiss_batchDeleteNonPOAStgContainer implements Database.Batchable<sObject> , Database.Stateful{
    
    global String query;
    Integer stagingRecordCount;
    global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;
    
    List<Non_POA_Bank_Details_Staging_Container__c> errorStagingContainer;    
    
    global Edelweiss_batchDeleteNonPOAStgContainer(){
        query = 'SELECT id FROM Non_POA_Bank_Details_Staging_Container__c WHERE Success__c = true';
        notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Non_POA_Bank_Details_Staging_Container__c> listOfNonPOAAccounts){
        Database.DeleteResult[] resultList = Database.delete(listOfNonPOAAccounts, false);
        DataBase.emptyRecycleBin(listOfNonPOAAccounts);
        
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
    
    global void finish(Database.BatchableContext bcMain) 
    {
        if(notifyAdminFlag){
            Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('Edelweiss_batchDeleteNonPOAStgContainer','Non POA Bank Details Staging Container', 'Non POA Bank Details Staging Container', successRecordIds.size(), failedRecordCounter);
        }
    }
}