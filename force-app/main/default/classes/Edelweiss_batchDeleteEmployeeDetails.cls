global class Edelweiss_batchDeleteEmployeeDetails implements Database.Batchable<sObject> , Database.Stateful{

    
    global String query;
    Integer stagingRecordCount;
    global boolean notifyAdminFlag;
    global List<Id> successRecordIds;
    global integer failedRecordCounter;
    
    global Edelweiss_batchDeleteEmployeeDetails(){
        query = 'SELECT Date_of_Joining__c FROM Edelweiss_Employee_Details__c WHERE NOT (Don_t_send_Anniversary_Mailers__c = true OR Don_t_send_Birthday_Mailers__c = true) ';
        notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Employee_Details__c> listOfEmployeeDetails){
        Database.DeleteResult[] resultList = Database.delete(listOfEmployeeDetails, false);
        DataBase.emptyRecycleBin(listOfEmployeeDetails);
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
                   Edelweiss_Integration_Utility.sendDeletionNotificationToAdmin('Edelweiss_batchDeleteGrossSalesData','Gross Sales Data', 'Gross Sales Data', successRecordIds.size(), failedRecordCounter);
               }
}  
    
}