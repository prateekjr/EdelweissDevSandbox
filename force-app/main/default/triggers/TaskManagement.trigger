trigger TaskManagement on Task (after insert, before update, after update, before delete) {
    if(Trigger.isUpdate && Trigger.isAfter && !TaskManagementTriggerHandler.stopTaskTrigger){
        TaskManagementTriggerHandler.maintainServiceActivityHistory(Trigger.new, Trigger.oldMap);
        TaskManagementTriggerHandler.createSequenceTask(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        TaskManagementTriggerHandler.maintainServiceActivityHistory(Trigger.new, null);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        TaskManagementTriggerHandler.recalculateServiceActivityDueDate(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isDelete && Trigger.isBefore){
        for(Task tsk: Trigger.old){
            Sys_Properties__c adminProfileId = Sys_Properties__c.getValues('ProfileSystemAdminId');
            if(adminProfileId.Value__c != null && userinfo.getProfileId() != (Id)adminProfileId.Value__c)
                tsk.addError('Insufficient Privileges.');
        }
    }
    if(Trigger.isInsert && Trigger.isAfter){
        TaskManagementTriggerHandler.createEventFromTaskofOutlook(Trigger.new);
    }   
}