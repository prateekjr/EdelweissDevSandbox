global class Edelweiss_BatchDeleteErrorLogs implements Database.Batchable<sObject> , Database.Stateful{

     global String query;
    Integer stagingRecordCount;
    global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;
    
    global Edelweiss_BatchDeleteErrorLogs(){
        Sys_Properties__c errorDate = Sys_Properties__c.getValues('ErrorLogDate');
        query = 'SELECT id FROM Edelweiss_Error_Log__c WHERE CreatedDate <'+errorDate.Value__c;
        notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
        System.debug('query'+query);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Error_Log__c> listOfErrorLogs){
        Database.DeleteResult[] resultList = Database.delete(listOfErrorLogs, false);
        DataBase.emptyRecycleBin(listOfErrorLogs);
        for(Database.DeleteResult result: resultList){
            if(result.isSuccess()){
                successRecordIds.add(result.getId());
            }
            else{
                 notifyAdminFlag = true;
                failedRecordCounter++;
            }
        } 
    }
    global void finish(Database.BatchableContext bcMain) 
    {
       // send email to admin team
    	       if(notifyAdminFlag){
                   Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('Edelweiss_BatchDeleteErrorLogs','Error Logs Data', 'Error Logs Data', successRecordIds.size(), failedRecordCounter);
               }
}  
}