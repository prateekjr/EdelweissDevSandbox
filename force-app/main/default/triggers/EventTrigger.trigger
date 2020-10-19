trigger EventTrigger on Event (after Insert,after update, before delete, before insert, before update) {
    if(Trigger.isUpdate && !EventTriggerHandler.stopEventTrigger && Trigger.isAfter ){
        system.debug('In event Trigger after update====================');
        LeadTriggerHandler.stopLeadTrigger = true;
        //EventTriggerHandler.updateLeadOnMeetingCompletion(Trigger.new);
        //EventTriggerHandler.updateLeadOnMeetingCreation(Trigger.new);
        LeadTriggerHandler.stopLeadTrigger = false;
        EventTriggerHandler.verifyAttendee(Trigger.new);
        EventTriggerHandler.validateSalesOpp(Trigger.new);
        EventTriggerHandler.updateClient(Trigger.new);
        EventTriggerHandler.updateOpportunityOnMeetingCompletion(Trigger.new);
        
        
    }
    if(Trigger.isInsert && !EventTriggerHandler.stopEventTrigger && Trigger.isAfter ){
        system.debug('In event Trigger after insert====================');
        LeadTriggerHandler.stopLeadTrigger = true;
        //EventTriggerHandler.updateLeadOnMeetingCompletion(Trigger.new);
        //EventTriggerHandler.updateLeadOnMeetingCreation(Trigger.new);
        LeadTriggerHandler.stopLeadTrigger = false;
        EventTriggerHandler.verifyAttendee(Trigger.new);
        EventTriggerHandler.validateSalesOpp(Trigger.new);
        EventTriggerHandler.updateClient(Trigger.new);
        EventTriggerHandler.sendEmailToTL(Trigger.new);
        EventTriggerHandler.updateOpportunityOnMeetingCompletion(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isBefore){
        for(Event evnt: Trigger.old){
            Sys_Properties__c adminProfileId = Sys_Properties__c.getValues('ProfileSystemAdminId');
            if(adminProfileId.Value__c != null && userinfo.getProfileId() != (Id)adminProfileId.Value__c)
                evnt.addError('Insufficient Privileges.');
        }
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        EventTriggerHandler.markEventStatusCompleted(Trigger.new);
    }
	if(Trigger.isInsert && Trigger.isAfter ){
		EventTriggerHandler.createEventonFamilyFromClient(Trigger.new);
	}
	
	/*** Adding to update Interaction details on Family **********/
	if(Trigger.isUpdate && EventTriggerHandler.updateClientOnEventTrigger && Trigger.isAfter ){
        LeadTriggerHandler.stopLeadTrigger = false;
        EventTriggerHandler.updateClient(Trigger.new);
    }
}