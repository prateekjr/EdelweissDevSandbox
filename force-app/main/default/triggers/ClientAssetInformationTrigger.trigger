trigger ClientAssetInformationTrigger on Client_Asset_Information__c (After insert,Before delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        //ClientAssetInformationTriggerHandler.updateFamilyAUM(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isDelete)
    {
        //AccountTriggerhandler.stopAccountTrigger = true;
       // AccountTriggerhandler.stopUpdatefamily = true;
      //  ClientAssetInformationTriggerHandler.setFamilyAUMRollupToZero(Trigger.old);
       // AccountTriggerhandler.stopAccountTrigger = false;
      //  AccountTriggerhandler.stopUpdatefamily = false;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        ClientAssetInformationTriggerHandler.rollupCreditEligibility(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        ClientAssetInformationTriggerHandler.rollupCreditEligibility(Trigger.old);
    }
}