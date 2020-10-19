global class DeleteCorporateActions implements Database.Batchable<sObject> , Database.Stateful{
    global String query;
    global boolean executeInsertCorporateActions = false;
    global boolean notificationNotSent = false;
    
    global DeleteCorporateActions(){
        query = 'SELECT id FROM Corporate_Action_Staging_Container__c';
    } 
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        Corporate_Action_Notification__c mobileNotifyObj = [SELECT id , Send_Push_notification__c, Push_Notification_Sent_Date__c FROM Corporate_Action_Notification__c limit 1];
        if(mobileNotifyObj !=null){
            if(mobileNotifyObj.Push_Notification_Sent_Date__c != system.today()){
                notificationNotSent = true;
            }
        }   
        return Database.getQueryLocator(query);
    }
    // This Function is used to delete all data from Corporate_Action__c only if Corporate_Action_Staging_Container__c contains some data 
    // and Mobile Notification not triggered today.
    global void execute(Database.BatchableContext bcMain, List<Corporate_Action_Staging_Container__c> listOfDataToDelete){
        if(notificationNotSent){
            if(listOfDataToDelete !=null && !listOfDataToDelete.isEmpty()){
                List<Corporate_Action__c> listOfCorporateActions = [SELECT id FROM Corporate_Action__c];
                if(listOfCorporateActions !=null && !listOfCorporateActions.isEmpty()){
                    Database.DeleteResult[] resultList = Database.delete(listOfCorporateActions, false);
                    for(Database.DeleteResult result: resultList){
                        if(result.isSuccess()){
                            executeInsertCorporateActions = true;
                        }
                    }
                }else{
                    executeInsertCorporateActions = true;
                }
            }
        }      
    }
    // This Function is used to delete members of mobile notification queue.
    // As queue might be holding older users to whom notification is sent.
    global void finish(Database.BatchableContext bcMain) 
    {
        if(notificationNotSent){
            Id groupObj = [SELECT Id FROM Group WHERE Name =: EdelweissConstants.MOBILE_NOTIFICATION].Id;
            List<GroupMember> groupMemberList = [SELECT Id FROM GroupMember WHERE GroupId =:groupObj];
            if(groupMemberList !=null && !groupMemberList.isEmpty()){
                Database.DeleteResult[] resultListGroup = Database.delete(groupMemberList, false);
            }    
            if(executeInsertCorporateActions){
                database.executeBatch(new InsertCorporateActions(),1000);
            }   
        }  
    }   
}