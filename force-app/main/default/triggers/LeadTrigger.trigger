trigger LeadTrigger on Lead (before Insert , before update,after Insert , after update) {
    if(Trigger.isBefore && Trigger.isUpdate){
       LeadTriggerHandler.checkOwnerAssignment(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.shareLeadWithCXO(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate && !leadTriggerHandler.stopLeadTrigger){
        LeadTriggerHandler.reallocateLead(Trigger.new,Trigger.oldMap);
        LeadTriggerHandler.resetLeadFields(Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isInsert && !leadTriggerHandler.stopLeadTrigger){
        LeadTriggerHandler.changeOwner(Trigger.new);
    }
    

}