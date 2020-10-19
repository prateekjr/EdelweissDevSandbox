trigger ClientRevenueTrigger on Client_Revenue__c (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ClientRevenueTriggerHandler.parseClientRevenueData(Trigger.new);
    }
}