trigger FARevenueTrigger on FA_Revenue__c (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        FARevenueTriggerHandler.parseFARevenueData(Trigger.new);
    }
}