global class BatchSendEmployeeAnniversaryMail implements Database.Batchable<sObject>, Database.Stateful {
    
    global String strQuery;
    global Map<Id,Group> wealthOpsQueue = new Map<Id,Group>([select Id from Group where  Type = 'Queue' AND NAME = 'Wealth Ops' limit 1]);
    global Map<Id,User> listOfOpsUsers = new Map<Id,User>([SELECT id FROM User WHERE Profile.Name = 'Operations']);
    global BatchSendEmployeeAnniversaryMail(){
        // strQuery = 'SELECT ClosedDate , Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND Type != \'NPS\' AND ClosedDate = TODAY AND Account.recordtype.name != \'Family\'';
        // strQuery = 'SELECT ClosedDate ,Contacted_By__c, Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND (Type != \'NPS\'  OR  Service_Request_Type__c != \'NPS\')AND ClosedDate = TODAY AND Contacted_By__c != \'RM\' AND Account.recordtype.name != \'Family\'';
        strQuery = 'SELECT id , Anniversary_Date__c,Don_t_send_Anniversary_Mailers__c FROM Edelweiss_Employee_Details__c where Don_t_send_Anniversary_Mailers__c != true ';
        
        system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Employee_Details__c> listOfEmployee) {
        
    }
    global void finish(Database.BatchableContext bcMain){
        Sys_Properties__c AnniversaryCCEmail = Sys_Properties__c.getValues('AnniversaryCCEmail');
        String ccEmail  = AnniversaryCCEmail.value__c;
        Map<id,Edelweiss_Employee_Details__c> listOfEmployee = new Map<id,Edelweiss_Employee_Details__c>([SELECT id ,Location__c,Employee_Name__c, Designation__c , Department__c ,Email_ID__c,Employee_Code__c	, LOB__c,Sub_LOB__c,Anniversary_Date__c,Employee_Status__c,Date_of_Joining__c,RA_ID__c,Don_t_send_Anniversary_Mailers__c FROM Edelweiss_Employee_Details__c WHERE Don_t_send_Anniversary_Mailers__c != true  AND Employee_Status__c != 'Inactive']);
        List<Edelweiss_Employee_Details__c> toBeUpdated = new List<Edelweiss_Employee_Details__c>();
        OrgWideEmailAddress owa = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM HR - PWM' limit 1];
        EmailTemplate et = [SELECT id , HtmlValue,Subject,Body FROM EmailTemplate WHERE developerName = 'Employee_Anniversary_Mail'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String, Edelweiss_Employee_Details__c> mapOfCodeAndEmployee = new Map<String, Edelweiss_Employee_Details__c>();
        For(Edelweiss_Employee_Details__c employee : listOfEmployee.values()){
            mapOfCodeAndEmployee.put(employee.Employee_Code__c , employee);
        }
        
        For(Edelweiss_Employee_Details__c employee : listOfEmployee.values()){
            if(employee.Date_of_Joining__c != null){
                Integer day = employee.Date_of_Joining__c.day();
                Integer month = employee.Date_of_Joining__c.month();
                Integer currentDay = System.today().day();
                Integer currentMonth = System.today().month();
                if(day == 29 && month == 2){
                    day = 28;
                }
                if(day == currentDay && month == currentMonth){
                    if(employee.Email_ID__c != null && employee.Employee_Name__c !=null && employee.Date_of_Joining__c !=null) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        List<String> ccAddress = new List<String>();
                        EmailTemplate em = new EmailTemplate(); 
                        String managerEmail , superManagerEmail;
                        em = et;
                        mail.setTemplateId(em.id);
                        mail.setSaveAsActivity(false);
                        mail.setTargetObjectId('005280000030fCj');
                        mail.setOrgWideEmailAddressId(owa.id);
                        if(ccEmail !=null){
                            ccAddress.add(ccEmail);
                        }
                        mail.setToAddresses(new List<String>{employee.Email_ID__c});
                        integer yearsOfExperience;
                        Integer yearJoining = employee.Date_of_Joining__c.year();
                        yearsOfExperience = System.today().year() - yearJoining;
                        String subject = em.Subject;
                        String totalExpString;
                        if(yearsOfExperience > 1){
                            totalExpString = ''+yearsOfExperience+' Years';
                        }else if(yearsOfExperience <= 1){
                            totalExpString = ''+yearsOfExperience+' Year';
                        }
                        subject =  subject.replace('#####', ''+totalExpString);
                        mail.setHtmlBody(em.Body);
                        String htmlValue = em.HtmlValue;
                        htmlValue = htmlValue.replace('[ACNAME]', employee.Employee_Name__c);
                        htmlValue = htmlValue.replace('@@@@', ''+totalExpString);
                        mail.htmlBody = htmlValue;
                        mail.setSubject(subject);
                        
                        if(employee.Employee_Code__c!=null && employee.RA_ID__c != null){
                            Edelweiss_Employee_Details__c manager = mapOfCodeAndEmployee.get(employee.RA_ID__c);
                            if(manager != null){
                                if(manager.Email_ID__c!=null){
                                      System.debug('manager.Email_ID__c'+manager.Email_ID__c);
                                    ccAddress.add(manager.Email_ID__c);
                                    if(manager.RA_ID__c !=null){
                                        Edelweiss_Employee_Details__c superManager = mapOfCodeAndEmployee.get(manager.RA_ID__c);
                                        if(superManager !=null && superManager.Email_ID__c != null){
                                            System.debug('superManager.Email_ID__c'+superManager.Email_ID__c);
                                             ccAddress.add(superManager.Email_ID__c);
                                        }
                                    }
                                 }
                            } 
                        }
                        if(ccAddress !=null && !ccAddress.isEmpty()){
							mail.setCcAddresses(ccAddress);
                        }
                        mails.add(mail);
                    }
                    
                }
            }
        }
        
        
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(mails);
        Database.rollback(sp);
        
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : mails) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setCcAddresses(email.getCcAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setOrgWideEmailAddressId(owa.id);
            msgListToBeSend.add(emailToSend);
        }
        Messaging.sendEmail(msgListToBeSend);
        
    }
}