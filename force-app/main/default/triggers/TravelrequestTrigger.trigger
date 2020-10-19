trigger TravelrequestTrigger on Travel_Request__c (after insert,before insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isafter){
            TravelRequestTriggerHandler.initiateApprovalProcess(Trigger.newMap);
    }
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
    {
        TravelRequestTriggerHandler.updateManagerEmail(Trigger.new);
        TravelRequestTriggerHandler.validateData(Trigger.new);
    } 
    if(Trigger.isUpdate && Trigger.isBefore)	
    {
        TravelRequestTriggerHandler.restrictFamilyLeadUpdate(Trigger.oldMap,Trigger.newMap);
    } 
      
}