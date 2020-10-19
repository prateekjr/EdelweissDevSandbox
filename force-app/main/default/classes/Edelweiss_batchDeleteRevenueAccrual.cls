global class Edelweiss_batchDeleteRevenueAccrual implements Database.Batchable<sObject> , Database.Stateful{
	global String query;
    global boolean notifyAdminFlag;
    global integer failedRecordCounter;
	global List<Id> successRecordIds;
    
    global Edelweiss_batchDeleteRevenueAccrual(){
        query = 'SELECT id FROM Revenue_Accrual__c where Revenue_Manually_By_Ops__c = 0';
        notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
        
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Revenue_Accrual__c> listOfDataToDelete){
        Database.DeleteResult[] resultList = Database.delete(listOfDataToDelete, false);
        DataBase.emptyRecycleBin(listOfDataToDelete);
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
                   Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('Edelweiss_batchDeleteRevenueAccrualData','Revenue AccrualData', 'Revenue Accrual Data', successRecordIds.size(), failedRecordCounter);
               }
      
	}  
    
    
    
}