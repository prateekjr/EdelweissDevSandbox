trigger WealthManagerTrigger on Wealth_Manager__c (after insert,after update,before delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        WealthManagerTriggerHandler.updateLead(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        WealthManagerTriggerHandler.updateLead(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
    }
    if(Trigger.isBefore && Trigger.isdelete){
        WealthManagerTriggerHandler.updateLeadonDelete(Trigger.old);
    }
}