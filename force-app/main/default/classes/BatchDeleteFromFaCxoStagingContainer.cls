////////////////////////////////////
//Author: Abhishek Rajput
//Date: 05 April 2016
//Description: Apex batch class to delete all the existing records from Product Staging Object.
//            
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class BatchDeleteFromFaCxoStagingContainer implements Database.Batchable<sObject>, Database.Stateful 
{
    global String strQuery;
   	global boolean notifyAdminFlag;
    global integer failedRecordCounter;
	global List<Id> successRecordIds;
    global BatchDeleteFromFaCxoStagingContainer() 
    {
        strQuery = 'SELECT id,is_Deleted__c FROM FA_CXO_Staging_Container__c';
    	notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<FA_CXO_Staging_Container__c> listBatchRecords) 
    {
        // soft deletion of records
        for(FA_CXO_Staging_Container__c record: listBatchRecords){
            record.is_Deleted__c= true;
        }
        
         try{
             update listBatchRecords;
        }
        catch(Exception de){
            system.debug('Soft deltion was unsuccessful due to==>'+de.getMessage()+'notify admin: '+notifyAdminFlag);
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
        //calling next batch to execute, we can also get the status of batch job based on id, if needed.
        id batchJobId= Database.executeBatch(new BatchDeleteFromProductStaging(),200);
    	// send email to admin team
    	system.debug('in finish method, notify admin: '+notifyAdminFlag);
        if(notifyAdminFlag){
           	Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('BatchDeleteFromFaCxoStagingContainer','FA-CXO Staging Container', 'FA-CXO Staging Container', successRecordIds.size(), failedRecordCounter);
        }
	}
}