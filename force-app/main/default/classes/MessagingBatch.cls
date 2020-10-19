global class MessagingBatch implements Database.Batchable<sObject>,Database.Stateful {

    global  String Query;
    
    global Integer iterationCount; 
    global List<String> queryList; 
    global Integer duration1,duration2,duration3,duration4,duration5,duration6;
    
    global MessagingBatch()   
    {
        queryList = new List<String>();
        iterationCount = -1; 
        /*LMS related reminders*/
        
         duration1 = 5; 
        //For Anivarsary Reminder
        query = 'SELECT id,owner.Email,Anniversary__c FROM Lead where Anniversary__c <= N_DAYS_AGO:'+duration1+' AND isConverted = False ';
        queryList.add(query); 
        
         // For Birth date reminder
        duration2 = 5;
        query = 'SELECT id,owner.Email,Date_of_Birth__c FROM Lead where Date_of_Birth__c<= N_DAYS_AGO:'+duration2+' AND isConverted = False ';
        queryList.add(query);
         
        //For Lead No Action performed at stage R1 reminder
        duration3 = 14;
        query = 'Select owner.Email,Status, Reply_received_from_client__c, Next_Follow_Up_Established__c,'+
                 'Entered_Meeting_Notes_For_R1__c From Lead where Status =\''+ EdelweissConstants.LEAD_R1_STATUS +'\''
                 +' AND (Reply_received_from_client__c = false AND Entered_Meeting_Notes_For_R1__c = false'
                 + ' AND Next_Follow_Up_Established__c = false) AND R1_State_Change_Date__c<= N_DAYS_AGO:'+duration3 ;
        queryList.add(query);
        //For Lead No Action performed at stage R2 reminder
        duration4 = 7;
        query = 'Select owner.Email,Status, FA_had_open_a_ticket_case__c, Allocation_Fields_duly_completed__c,'+
                 'All_Product_details_filled__c From Lead where Status =\''+ EdelweissConstants.LEAD_R2_STATUS +'\''
                 +' AND (FA_had_open_a_ticket_case__c = false AND Allocation_Fields_duly_completed__c = false'
                 + ' AND All_Product_details_filled__c = false) AND R2_State_Change_Date__c<= N_DAYS_AGO:'+duration4 ;
        queryList.add(query);
        //For Lead whose initial meeting is not completed within 2 days
        duration5 = 2;
        query = 'Select WhoId, Type, Status__c,'+
                'CreatedDate From Event Where Status__c!=\'Completed\' AND'+
                ' Type = \'Meeting\' AND WhoId!=null AND EndDateTime<= N_DAYS_AGO:'+duration5;
        queryList.add(query);
        //For Lead whose initial meeting is escalated
        duration6 = 3;
        query = 'Select WhoId, Type, Status__c,'+
                'CreatedDate From Event Where Status__c!=\'Completed\' AND'+
                ' Type = \'Meeting\' AND WhoId!=null AND EndDateTime<= N_DAYS_AGO:'+duration6;
        queryList.add(query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        iterationcount++;
        system.debug('queryList[iterationCount]: '+queryList[iterationCount]);
        return Database.getQueryLocator(queryList[iterationCount]);
        
   }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(iterationCount == 0 )
        {
            List<Lead> leadList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'Lead_Anniversary_Reminder'];
            if(!templateList.isEmpty())
            {
                for(Lead leadObj:leadList)
                {
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(templateList[0].Id);
                  mail.setTargetObjectId(leadObj.Id);
                  mail.setToAddresses(new List<String>{leadObj.Owner.Email});
                  List<String> ccAddresses = new List<String>();
                  mail.setSenderDisplayName('Edelweiss Admin');
                  msgList.add(mail);
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }else if(iterationCount == 1 ){
        
            List<Lead> leadList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'Lead_Birthday_Reminder'];
            if(!templateList.isEmpty())
            {
                for(Lead leadObj:leadList)
                {
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(templateList[0].Id);
                  mail.setTargetObjectId(leadObj.Id);
                  mail.setToAddresses(new List<String>{leadObj.Owner.Email});
                  List<String> ccAddresses = new List<String>();
                  mail.setSenderDisplayName('Edelweiss Admin');
                  msgList.add(mail);
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }else if(iterationCount == 2 )
        {
            List<Lead> leadList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'No_Task_Completed_at_Status_R1_alert'];
            if(!templateList.isEmpty())
            {
                for(Lead leadObj:leadList)
                {
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(templateList[0].Id);
                  mail.setTargetObjectId(leadObj.Id);
                  mail.setToAddresses(new List<String>{leadObj.Owner.Email});
                  List<String> ccAddresses = new List<String>();
                  mail.setSenderDisplayName('Edelweiss Admin');
                  msgList.add(mail);
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }else if(iterationCount == 3 )
        {
            List<Lead> leadList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'No_Task_Completed_at_Status_R2_alert'];
            if(!templateList.isEmpty())
            {
                for(Lead leadObj:leadList)
                {
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(templateList[0].Id);
                  mail.setTargetObjectId(leadObj.Id);
                  mail.setToAddresses(new List<String>{leadObj.Owner.Email});
                  List<String> ccAddresses = new List<String>();
                  mail.setSenderDisplayName('Edelweiss Admin');
                  msgList.add(mail);
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }else if(iterationCount == 4 )
        {
            List<Event> eventList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'Reminder_for_Meeting_Closure'];
            List<User> userList = [Select u.Name,u.Email,u.IsActive ,u.UserRole.Name, u.UserRoleId From User u where 
                                   u.UserRole.Name ='Acquisition Team'AND
                                   u.IsActive=true];
            List<String> toAddressList = new List<String>();
            for(User u:userList){
                toAddressList.add(u.Email);
            
            }
            if(!templateList.isEmpty())
            {
                for(Event eventObj:eventList)
                {
                  if(eventObj.WhoId!=null && eventObj.WhoId.getSObjectType() == Lead.sObjectType ){
                      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                      mail.setTemplateId(templateList[0].Id);
                      mail.setTargetObjectId(eventObj.Id);                    
                      mail.setToAddresses(toAddressList);
                      List<String> ccAddresses = new List<String>();
                      mail.setSenderDisplayName('Edelweiss Admin');
                      msgList.add(mail);
                    }
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }else if(iterationCount == 5 )
        {
            List<Event> eventList = scope;
            List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
            List<EmailTemplate> templateList = [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'Reminder_for_Meeting_Closure'];
            List<User> userList = [Select u.Name,u.Email,u.IsActive ,u.UserRole.Name, u.UserRoleId From User u where 
                                   u.UserRole.Name ='Business Head'AND
                                   u.IsActive=true];
            List<String> toAddressList = new List<String>();
            for(User u:userList){
                toAddressList.add(u.Email);
            
            }
            if(!templateList.isEmpty())
            {
                for(Event eventObj:eventList)
                {
                  if(eventObj.WhoId!=null && eventObj.WhoId.getSObjectType() == Lead.sObjectType ){
                      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                      mail.setTemplateId(templateList[0].Id);
                      mail.setTargetObjectId(eventObj.Id);                    
                      mail.setToAddresses(toAddressList);
                      List<String> ccAddresses = new List<String>();
                      mail.setSenderDisplayName('Edelweiss Admin');
                      msgList.add(mail);
                    }
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
       }
       
   }

   global void finish(Database.BatchableContext BC){
        if(iterationCount < 5)
            Database.executeBatch(this);
   }
   
  
}