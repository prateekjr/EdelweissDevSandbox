////////////////////////////////////
//Author: Abhishek Rajput
//Date: 05 April 2016
//Description: Apex batch class to delete all the existing records from Product Staging Object.
//            
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class BatchDeleteFromProductStaging implements Database.Batchable<sObject>, Database.Stateful 
{
    global String strQuery;
   	global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;
    global BatchDeleteFromProductStaging() 
    {
        strQuery = 'SELECT id, is_Deleted__c FROM Product_Staging_Container__c';
    	notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product_Staging_Container__c> listBatchRecords) 
    {
        // soft deletion of records
        for(Product_Staging_Container__c record: listBatchRecords){
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
    
    global void finish(Database.BatchableContext bcMain){
        //calling next batch to execute, we can also get the status of batch job based on id, if needed.
        id batchJobId= Database.executeBatch(new BatchDeleteFromClientStagingContainer(),200);
    	
        // send email to admin team
    	       if(notifyAdminFlag){
            	Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('BatchDeleteFromProductStaging','Product Staging Container', 'Product Staging Container', successRecordIds.size(), failedRecordCounter);
               }
		}
}