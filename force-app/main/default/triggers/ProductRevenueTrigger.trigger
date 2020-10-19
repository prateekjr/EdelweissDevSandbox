trigger ProductRevenueTrigger on ProductRevenue__c (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ProductRevenueTriggerHandler.parseRevenueData(Trigger.new);
    }
}