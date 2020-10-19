trigger ClientAssetStagingTrigger on Client_Asset_Staging_Container__c (before insert, before update) {

    if(trigger.isInsert || trigger.isUpdate && trigger.isBefore){
        ClientAssetStagingTriggerHandler.validateAsOnDate(trigger.New);
    }
    
}