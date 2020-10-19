trigger RevenueAccrualTrigger on Revenue_Accrual__c (before insert, before update) {
     if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        RevenueAccrualTriggerHandler.parseRevenueData(Trigger.new);
    }
}