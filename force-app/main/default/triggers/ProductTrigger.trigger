trigger ProductTrigger on Product2 (after insert, after update, before insert, before update) {
    if(trigger.isInsert &&  Trigger.isAfter){
        ProductTriggerhandler.setStandardPrice(Trigger.New);        
    }
    if(trigger.isUpdate &&  Trigger.isAfter){
        ProductTriggerhandler.ProductLiveApproval(Trigger.New,Trigger.oldMap);
        ProductTriggerhandler.updateFinancialTransaction(Trigger.New,Trigger.oldMap);
    }
    if(trigger.isUpdate &&  Trigger.isBefore){
        ProductTriggerhandler.updateStatus(Trigger.New,Trigger.oldMap);
    }
    if((trigger.isInsert || trigger.isUpdate) &&  Trigger.isBefore && EdelweissUtils.runOnce()){
        ProductTriggerhandler.validateProductName(Trigger.New, Trigger.oldMap);
    }

}