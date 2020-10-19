////////////////////////////////////
//Author: Abhishek Rajput
//Date: 05 April 2016
//Description: Apex batch class to delete all the existing records from Product Staging Object.
//            
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class BatchDeleteFromClientAssetStaging implements Database.Batchable<sObject>, Database.Stateful 
{
    global String strQuery;
   	global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;
    
    global BatchDeleteFromClientAssetStaging() 
    {
        strQuery = 'SELECT id,is_Deleted__c FROM Client_Asset_Staging_Container__c';
    	notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Staging_Container__c> listBatchRecords) 
    {
        // soft deletion of records
        for(Client_Asset_Staging_Container__c record: listBatchRecords){
            record.is_Deleted__c= true;
        }
        
         try{
            update listBatchRecords;
        }
        catch(DmlException de){
            system.debug('Soft deltion was unsuccessful due to==>'+de.getMessage());
        }
        
       
        Database.DeleteResult[] resultList = Database.delete(listBatchRecords, false);
        DataBase.emptyRecycleBin(listBatchRecords);
       
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
        Id batchJobId= Database.executeBatch(new Edelweiss_BatchDeletePortfolioStaging(), 200);
        // send email to admin team
        if(notifyAdminFlag){
           	Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('BatchDeleteFromClientAssetStaging','Client Asset Staging Container', 'Client Asset Staging Container', successRecordIds.size(), failedRecordCounter);
        }
	}
}