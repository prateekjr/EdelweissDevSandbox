/*
Integer intervalMinutes = 2;
DateTime now  = DateTime.now();
DateTime nextRunTime = now.addMinutes(intervalMinutes);
String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
	nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
	nextRunTime.month() + ' ? ' + nextRunTime.year(); 
System.schedule(schedulerForCreateEventFromTask.class.getName() + '-' + now.format(), cronString, new schedulerForCreateEventFromTask(intervalMinutes));
*/
global class schedulerForCreateEventFromTask implements Schedulable {
    Integer intervalMinutes;
    public schedulerForCreateEventFromTask(Integer intervalMinutes) {
        this.intervalMinutes = intervalMinutes;
    }
   
    global void execute(SchedulableContext SC) {
        schedulerForCreateEventFromTask.createEvent();      
        
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(schedulerForCreateEventFromTask.class.getName() + '-' + now.format(), cronString, new schedulerForCreateEventFromTask(intervalMinutes));
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);       
        
   }
   
   global static void createEvent(){
        DateTime now = Datetime.now();
        DateTime old = Datetime.now().addHours(-1);
        
        Id taskRecordTypeId =  EdelweissConstants.TaskRecordTypeMap.get('Generic_Task_Record_Type');
        List<Task> tasks = [SELECT ActivityDate,Agenda__c,Description,Description__c,Due_Date_Time__c,OwnerId,Reason_For_Not_Sending_MoM__c,Related_Email__c,Status,Status__c,Subject,Type,Type_of_Communication__c,WhatId,WhoId,RecordTypeId FROM Task WHERE CreatedDate <=: now And CreatedDate >=: old And recordTypeId =: taskRecordTypeId And Type = 'Email'];
        
        System.debug('tasks===='+tasks);
        if(tasks != null && tasks.size() > 0){
            Set<Id> contactIdSet  = new Set<Id>();
            Set<Id> accountIdSet  = new Set<Id>();
            for(Task t : tasks){
              if(t.WhoId!=null && t.WhoId.getSObjectType() == Contact.sObjectType && t.WhatId == null){
                contactIdSet.add(t.WhoId);
              }
              if(t.WhatId!=null && t.WhatId.getSObjectType() == Account.sObjectType ){
                accountIdSet.add(t.WhatId);
              }
            }
            System.debug('contactIdSet===='+contactIdSet);
            
            //Contact Event creation
            Map<Id,Contact> contactMap = new Map<Id,Contact>();
            Id contactRecordTypeId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(EdelweissConstants.EDELWEISS_CONTACT_RECORD_TYPE).getRecordTypeId();
            if(contactIdSet != null && contactIdSet.size() > 0){
                contactMap = new Map<Id,Contact>([SELECT recordTypeId,Id,AccountId 
                                           FROM Contact
                                           WHERE Id IN:contactIdSet AND AccountId != NULL AND RecordTypeId =: contactRecordTypeId 
                                          ]);
            }
            System.debug('contactMap===='+contactMap);       
            
            List<Event> eventInsert = new List<Event>();
            List<Task> taskDelete = new List<Task>();
            System.debug('tasks===='+tasks);
            for(Task t : tasks){
                if(t.WhoId!=null &&  contactMap.get(t.WhoId) != null){
                    Contact cntRecord = contactMap.get(t.WhoId);
                    Event e = new Event();
                    e.Agenda__c = 'General';
                    e.Subject = t.Subject;
                    e.Description = t.Description;
                    e.Type_of_Communication__c = 'Email';
                    System.debug('t.ActivityDate===='+t.ActivityDate);
                    Date activityDate = (t.ActivityDate != null) ? t.ActivityDate: Date.Today() ;
                    System.debug('activityDate===='+activityDate);              
                    e.StartDateTime = DateTime.newInstance(activityDate, System.now().addHours(-2).time());
                    e.EndDateTime = DateTime.newInstance(activityDate, System.now().addHours(-1).time());
                    System.debug('e.StartDateTime===='+e.StartDateTime);    
                    System.debug('e.EndDateTime===='+e.EndDateTime);    
                    e.Status__c = 'Open';
                    e.WhoId = t.WhoId;
					e.OwnerId = t.OwnerId;
                    eventInsert.add(e);
                    taskDelete.add(t);
                }
                
            }
            System.debug('eventInsert===='+eventInsert);
            
            //Account Event creation
            System.debug('accountIdSet===='+accountIdSet);
            Map<Id,Account> accountMap = new Map<Id,Account>();
            
			Set<ID> recordTypeIdSet = new Set<Id>();
			recordTypeIdSet.add(EdelweissConstants.AccountRecordTypeMap.get('Client'));
			recordTypeIdSet.add(EdelweissConstants.AccountRecordTypeMap.get('Family'));
            
            if(accountIdSet != null && accountIdSet.size() > 0){
                accountMap = new Map<Id,Account>([
                    SELECT Id,ParentId 
                    FROM Account
                    WHERE Id IN:accountIdSet AND RecordTypeId =: recordTypeIdSet 
                ]);
            }
            System.debug('accountMap===='+accountMap);
            
            for(Task t : tasks){
                if(t.WhatId!=null &&  accountMap.get(t.WhatId) != null){
                    Account accountRecord = accountMap.get(t.WhatId);
                    Event e = new Event();
                    e.Agenda__c = 'General';
                    e.Subject = t.Subject;
                    e.Description = t.Description;
                    e.Type_of_Communication__c = 'Email';
                    System.debug('t.ActivityDate===='+t.ActivityDate);
                    Date activityDate = (t.ActivityDate != null) ? t.ActivityDate: Date.Today() ;
                    System.debug('activityDate===='+activityDate);              
                    e.StartDateTime = DateTime.newInstance(activityDate, System.now().addHours(-2).time());
                    e.EndDateTime = DateTime.newInstance(activityDate, System.now().addHours(-1).time());
                    System.debug('e.StartDateTime===='+e.StartDateTime);    
                    System.debug('e.EndDateTime===='+e.EndDateTime);    
                    e.Status__c = 'Open';
                    e.WhatId = t.WhatId;
                    e.OwnerId = t.OwnerId;
                    eventInsert.add(e);
                    taskDelete.add(t);
                    
                    if(accountRecord.ParentId != null){
                        Event eParent = new Event();
                        eParent.Agenda__c = 'General';
                        eParent.Subject = t.Subject;
                        eParent.Description = t.Description;
                        eParent.Type_of_Communication__c = 'Email';
                        System.debug('t.ActivityDate===='+t.ActivityDate);
                        activityDate = (t.ActivityDate != null) ? t.ActivityDate: Date.Today() ;
                        System.debug('activityDate===='+activityDate);              
                        eParent.StartDateTime = DateTime.newInstance(activityDate, System.now().addHours(-2).time());
                        eParent.EndDateTime = DateTime.newInstance(activityDate, System.now().addHours(-1).time());
                        System.debug('e.StartDateTime===='+e.StartDateTime);    
                        System.debug('e.EndDateTime===='+e.EndDateTime);    
                        eParent.Status__c = 'Open';
                        eParent.WhatId = accountRecord.ParentId;
                        eParent.OwnerId = t.OwnerId;
                        eventInsert.add(eParent);                       
                    }                   
                }                
            }
            System.debug('eventInsert===='+eventInsert);
            
            if(eventInsert != null && eventInsert.size() > 0)
                Database.insert(eventInsert,true);      
            
            if(taskDelete != null && taskDelete.size() > 0){
                List<Task> tobeDelete = new List<Task>();
                for(Task t : taskDelete){
                    Task tn = new Task();
                    tn.Id = t.Id;
                    tobeDelete.add(tn);
                } 
                Database.delete(tobeDelete,true);
            }           
        }           
        
   }
}