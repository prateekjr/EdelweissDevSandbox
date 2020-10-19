public with sharing class TaskOnleadTriggerHandler{
    public static void updateCommunicationCount(List<Task> taskList){
        Set<Lead>updatedLeadSet = new Set<Lead>();
        List<Lead>updatedLeadList = new List<Lead>();
        Set<Id>taskIdSet = new Set<Id>();
        Set<Id>leadIdSet = new Set<Id>();
        Map<Id,Set<Id>>leadIdTaskIdMap = new Map<Id,Set<Id>>();
        for(Task taskObj : taskList){
            if(taskObj.Status == EdelweissConstants.TASK_COMPLETED_STATUS && taskObj.WhoId!=null
               && taskObj.WhoId.getSObjectType() == Lead.sObjectType ){
                LeadIdSet.add(taskObj.WhoId);
                if(leadIdTaskIdMap.containsKey(taskObj.WhoId)){
                    taskIdSet = leadIdTaskIdMap.get(taskObj.WhoId);
                    taskIdSet.add(taskObj.Id);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskIdSet );
                }else{
                    taskIdSet = new Set<Id>();
                    taskIdSet.add(taskObj.Id);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskIdSet);
                }
            }
        }
        if(leadIdTaskIdMap!=null && leadIdTaskIdMap.size()>0){
            List<Lead>leadList = [SELECT Id,Status,Cold_Communication_Count__c,Hot_Communication_Count__c,
                         Warm_Communication_Count__c FROM Lead WHERE Id IN:leadIdTaskIdMap.keySet()];
            for(Lead leadObj:leadList ){
                Boolean isCountChange = false;              
                if(leadObj.Status == EdelweissConstants.LEAD_HOT_STATUS ){
                    system.debug('===========leadObj.Hot_Communication_Count__c===='+leadObj.Hot_Communication_Count__c);
                    if(leadObj.Hot_Communication_Count__c == null){
                        leadObj.Hot_Communication_Count__c = 1;
                    
                    }else{
                         leadObj.Hot_Communication_Count__c++;
                    }
                   
                    isCountChange = true;
                }
                if(leadObj.Status == EdelweissConstants.LEAD_WARM_STATUS ){
                    if(leadObj.Warm_Communication_Count__c== null){
                        leadObj.Warm_Communication_Count__c= 1;
                    
                    }else{
                         leadObj.Warm_Communication_Count__c++;
                    }
                   
                    isCountChange = true;
                }
                if(leadObj.Status == EdelweissConstants.LEAD_COLD_STATUS ){
                    if(leadObj.Cold_Communication_Count__c== null){
                        leadObj.Cold_Communication_Count__c= 1;
                    
                    }else{
                         leadObj.Cold_Communication_Count__c++;
                    }
                    
                    isCountChange = true;
                }           
                if(!updatedLeadSet.contains(leadObj) && isCountChange ){
                    updatedLeadSet.add(leadObj);
                }          
            }
            updatedLeadList.addAll(updatedLeadSet);
            if(updatedLeadList!=null && updatedLeadList.size()>0){
                try{
                    update updatedLeadList;
                }catch(Exception e){
                    system.debug('Exception in Lead updation and reason is::'+e);
                }
            }
        
        }
        
        
    }
    public static void updateActivityOnMoM(List<Task>taskList){
        Set<Id>eventIdSet = new Set<Id>();
        Set<Id>AccIdSet = new Set<Id>();
        Set<Id>LeadIdSet = new Set<Id>();
        Set<Id>CaseIdSet = new Set<Id>();
        Set<Id>OpportunityIdSet = new Set<Id>();
        List<Event>updatedEventObjectList = new List<Event>();
        List<Id> Triggerids=new List<Id>();
   
        System.debug('in Trigger 1');
        for(Task t:taskList)
        {
           Triggerids.add(t.id);
        }
        List<Task> taskListUpdated=[select id,whatId,whoId,Status,Type from Task where id in:Triggerids];
        //List<Task>updatedTaskObjectList = new List<Task>();
        for(Task taskObj:taskList){
            system.debug('taskObj.Status==='+taskObj.Status);
            system.debug('taskObj.Type==='+taskObj.Type);
            if(taskObj.Status == EdelweissConstants.TASK_COMPLETED_STATUS && taskObj.Type == EdelweissConstants.MoM_TASK_TYPE){
            //Commented by Sayali to remove Id from Subject line
                /*List<String>subjectArr = taskObj.Subject.split(']');            
                if(subjectArr.size()>0){
                    String eventId = subjectArr[0].substringAfter('[');
                    //taskObj.Subject = subjectArr[0].substringAfter(']');
                    eventIdSet.add(eventId);
                }*/
                System.debug('taskObj.whoId=='+taskObj.whoId);
                 System.debug('taskObj.whatId=='+taskObj.whatId);
                
                if(taskObj.whoId!=null)
                {
                    if(taskObj.whoId.getsObjectType() == Account.sObjectType)
                       AccIdSet.add(taskObj.whoId); 
                     if(taskObj.whoId.getsObjectType() == Lead.sObjectType)
                       LeadIdSet.add(taskObj.whoId);
                    else if(taskObj.whoId.getsObjectType() == Case.sObjectType)
                       CaseIdSet.add(taskObj.whoId);
                    else if(taskObj.whoId.getsObjectType() == Opportunity.sObjectType)
                       OpportunityIdSet.add(taskObj.whoId);
                }
               
                if(taskObj.whatId!=null)
                {
                    if(taskObj.whatId.getsObjectType() == Account.sObjectType)
                       AccIdSet.add(taskObj.whatId); 
                     if(taskObj.whatId.getsObjectType() == Lead.sObjectType)
                       LeadIdSet.add(taskObj.whatId);
                    else if(taskObj.whatId.getsObjectType() == Case.sObjectType)
                       CaseIdSet.add(taskObj.whatId);
                    else if(taskObj.whatId.getsObjectType() == Opportunity.sObjectType)
                       OpportunityIdSet.add(taskObj.whatId);
                }
            }
            
        }
        System.debug('AccIdSet=='+AccIdSet);
        if(AccIdSet!=null)
        {
               List<Account> lstAcc = [SELECT  EventId__c from Account where id IN:AccIdSet];
                for(Account acc : lstAcc)
                {
                    eventIdSet.add(acc.EventId__c);
                }
         }
        if(LeadIdSet!=null)
        {
           List<Lead> lstLead = [SELECT  EventId__c from Lead where id IN:LeadIdSet];
            for(lead acc : lstLead )
            {
                eventIdSet.add(acc.EventId__c);
            }
        }
        if(CaseIdSet!=null)
        {
           List<Case> lstCase = [SELECT  EventId__c from Case where id IN:CaseIdSet];
            for(Case caseObj : lstCase )
            {
                eventIdSet.add(caseObj.EventId__c);
            }
        }
        if(OpportunityIdSet!=null)
        {
           List<Opportunity> lstOpportunity = [SELECT  EventId__c from Opportunity where id IN:OpportunityIdSet];
            for(Opportunity OppObj : lstOpportunity )
            {
                eventIdSet.add(OppObj.EventId__c);
            }
        }
        
        List<Event> eventList = new List<Event>();
        if(eventIdSet!=null && eventIdSet.size()>0){
            eventList = [SELECT id,isMoMSend__c,StartDateTime,EndDateTime FROM Event WHERE id IN:eventIdSet];
        } 
        system.debug('eventList==='+eventList);
        for(Event eventObj:eventList){
            if(eventObj.StartDateTime>System.now())
            {
                eventObj.StartDateTime = System.now().addHours(-3);
                eventObj.EndDateTime = System.now().addHours(-2);
            }
            
                eventObj.isMoMSend__c = true;
                eventObj.Status__c='Completed';
                updatedEventObjectList.add(eventObj);
            
        }
        if(updatedEventObjectList!=null && updatedEventObjectList.size()>0){
            //EventTriggerHandler.stopEventTrigger = true;
            update updatedEventObjectList;
        
        }
        
    
    }
     /*public static void updateFollowUpTaskCreatedRO(List<Task> taskList){
        Set<Lead>updatedLeadSet = new Set<Lead>();
        List<Lead>updatedLeadList = new List<Lead>();
        Set<Id>taskIdSet = new Set<Id>();
        Set<Id>leadIdSet = new Set<Id>();
        Map<Id,Set<Id>>leadIdTaskIdMap = new Map<Id,Set<Id>>();
        for(Task taskObj : taskList){
            if(taskObj.Status == 'Open' && taskObj.Subject == 'Meeting' && taskObj.WhoId!=null
               && taskObj.WhoId.getSObjectType() == Lead.sObjectType ){
                LeadIdSet.add(taskObj.WhoId);
                if(leadIdTaskIdMap.containsKey(taskObj.WhoId)){
                    taskIdSet = leadIdTaskIdMap.get(taskObj.WhoId);
                    taskIdSet.add(taskObj.Id);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskIdSet );
                }else{
                    taskIdSet = new Set<Id>();
                    taskIdSet.add(taskObj.Id);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskIdSet);
                }
            }
        }
        if(leadIdTaskIdMap!=null && leadIdTaskIdMap.size()>0){
            List<Lead>leadList = [SELECT Id,Status,Entered_Initial_Meeting_Notes_with_task__c,Entered_Meeting_Notes_For_R1__c FROM Lead WHERE Id IN:leadIdTaskIdMap.keySet()];
            for(Lead leadObj:leadList ){
                if(leadObj.Status == 'R0' ){
                    
                    leadObj.Entered_Initial_Meeting_Notes_with_task__c = true;
                    updatedLeadSet.add(leadObj);
                     
                 }
                 if(leadObj.Status == 'R1' ){
                    
                    leadObj.Entered_Meeting_Notes_For_R1__c = true;
                    updatedLeadSet.add(leadObj);
                     
                 }
            }
            updatedLeadList.addAll(updatedLeadSet);
            if(updatedLeadList!=null && updatedLeadList.size()>0){
                try{
                    update updatedLeadList;
                }catch(Exception e){
                    system.debug('Exception in Lead updation and reason is::'+e);
                }
            }
        
        } 
     
     }
     public static void validateFollowUpTaskCompletionRO(List<Task> taskList){
        Set<Lead>updatedLeadSet = new Set<Lead>();
        List<Lead>updatedLeadList = new List<Lead>();
        Set<Task>taskSet = new Set<Task>();
        Set<Id>leadIdSet = new Set<Id>();
        Map<Id,Set<Task>>leadIdTaskIdMap = new Map<Id,Set<Task>>();
        system.debug('Task List Size==>'+taskList.size());
        for(Task taskObj : taskList){
            system.debug('Task Obj==>'+taskObj );
            if(taskObj.Status == EdelweissConstants.TASK_COMPLETED_STATUS && taskObj.Subject == 'Meeting' && taskObj.WhoId!=null
               && taskObj.WhoId.getSObjectType() == Lead.sObjectType ){
                LeadIdSet.add(taskObj.WhoId);
                if(leadIdTaskIdMap.containsKey(taskObj.WhoId)){
                    taskSet = leadIdTaskIdMap.get(taskObj.WhoId);
                    taskSet.add(taskObj);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskSet );
                }else{
                    taskSet = new Set<Task>();
                    taskSet.add(taskObj);
                    leadIdTaskIdMap.put(taskObj.WhoId,taskSet );
                }
            }
        }
        if(leadIdTaskIdMap!=null && leadIdTaskIdMap.size()>0){
            List<Lead>leadList = [SELECT Id,Status,Entered_Initial_Meeting_Notes_with_task__c,Initial_Meeting_Notes__c,Follow_Up_Meeting_Notes__c FROM Lead WHERE Id IN:leadIdTaskIdMap.keySet()];
            for(Lead leadObj:leadList ){
                if(leadObj.Status == 'R0' && String.isBlank(leadObj.Initial_Meeting_Notes__c) ){
                    if(leadIdTaskIdMap!=null && leadIdTaskIdMap.containsKey(leadObj.Id)){
                        for(Task taskObj : leadIdTaskIdMap.get(leadObj.Id)){
                            taskObj.addError(Label.Task_Completion_Validation);
                        }
                    
                    }
                 }
                 if(leadObj.Status == 'R1' && String.isBlank(leadObj.Follow_Up_Meeting_Notes__c) ){
                    if(leadIdTaskIdMap!=null && leadIdTaskIdMap.containsKey(leadObj.Id)){
                        for(Task taskObj : leadIdTaskIdMap.get(leadObj.Id)){
                            taskObj.addError(Label.R1_Task_Completion_Validation);
                        }
                    
                    }
                 }
            }
            
        
        } 
     
     }*/
     


}