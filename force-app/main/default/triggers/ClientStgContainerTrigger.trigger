trigger ClientStgContainerTrigger on Edelweiss_Clients_Staging_Container__c (before insert, before update) {
    
    if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
        ClientStgContainerTriggerHandler.updateErrorFlag(trigger.new);
        ClientStgContainerTriggerHandler.updateLeadOrClient(trigger.new);
        ClientStgContainerTriggerHandler.updatePOA(trigger.new);
    }
}