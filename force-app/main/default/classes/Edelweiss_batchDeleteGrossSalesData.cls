global class Edelweiss_batchDeleteGrossSalesData implements Database.Batchable<sObject> , Database.Stateful{
	global String query;
    global boolean notifyAdminFlag;
    global integer failedRecordCounter;
	global List<Id> successRecordIds;
    
    global Edelweiss_batchDeleteGrossSalesData(){
        query = 'SELECT id FROM Gross_Sales_Details__c';
        notifyAdminFlag=false;
        failedRecordCounter=0;
        successRecordIds = new List<Id>();
        
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Gross_Sales_Details__c> listOfGrossSalesData){
        Database.DeleteResult[] resultList = Database.delete(listOfGrossSalesData, false);
        DataBase.emptyRecycleBin(listOfGrossSalesData);
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