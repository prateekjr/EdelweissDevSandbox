trigger AdditionalLeadTrigger on Additional_Lead__c (before insert, before update) {

    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
    	AdditionalLeadTriggerHandler.verifyPANDuplication(trigger.new);    
    }
     if(trigger.isBefore && trigger.isInsert){
    	AdditionalLeadTriggerHandler.checkCaseTask(trigger.new);    
    }
}