global class DeleteCorporateActionContainer implements Database.Batchable<sObject> , Database.Stateful{
    global String query;
    global boolean deleteCorporateActionContainer = false;

    global DeleteCorporateActionContainer(){
        query = 'SELECT id FROM Corporate_Action_Staging_Container__c';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    
    // This method is used to delete the Corporate_Action_Staging_Container__c data.
    // So that next day fresh data can be directly inserted.
    global void execute(Database.BatchableContext bcMain, List<Corporate_Action_Staging_Container__c> listOfDataToDelete){
        if(listOfDataToDelete !=null && !listOfDataToDelete.isEmpty()){
            Database.DeleteResult[] resultList = Database.delete(listOfDataToDelete, false);
            DataBase.emptyRecycleBin(listOfDataToDelete);
        }
    }
    // This function is used to trigger the notification to all members of Mobile Notification Queue.
    global void finish(Database.BatchableContext bcMain) 
    { 
        List<Corporate_Action_Notification__c> mobileNotify = new List<Corporate_Action_Notification__c>();            
        Corporate_Action_Notification__c mobileNotifyObj = [SELECT id , Send_Push_notification__c, Push_Notification_Sent_Date__c FROM Corporate_Action_Notification__c limit 1];
        if(mobileNotifyObj !=null){
            mobileNotifyObj.Send_Push_notification__c = true;
            mobileNotifyObj.Push_Notification_Sent_Date__c = system.today();
            mobileNotify.add(mobileNotifyObj);                 
        }	
        Database.update(mobileNotify, false);
    }  
}