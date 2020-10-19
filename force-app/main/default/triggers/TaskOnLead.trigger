trigger TaskOnLead on Task (before insert,before update,after update,after insert) {
   if(Trigger.isUpdate && Trigger.isBefore){
        
        TaskOnleadTriggerHandler.updateCommunicationCount(Trigger.new);
        
    }
    if(Trigger.isInsert && Trigger.isBefore){
        
        TaskOnleadTriggerHandler.updateCommunicationCount(Trigger.new);
        
        
    }
   
    if(Trigger.isInsert && Trigger.isAfter){
        TaskOnleadTriggerHandler.updateActivityOnMoM(Trigger.new);
    }

}