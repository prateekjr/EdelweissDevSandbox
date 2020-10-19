global class Edelweiss_batchSendSurvey implements Database.Batchable<sObject>, Database.Stateful {
    
    global String strQuery;
    global Map<Id,Group> wealthOpsQueue = new Map<Id,Group>([select Id from Group where  Type = 'Queue' AND NAME = 'Wealth Ops' limit 1]);
    global Map<Id,User> listOfOpsUsers = new Map<Id,User>([SELECT id FROM User WHERE Profile.Name = 'Operations']);
    global Edelweiss_batchSendSurvey(){
       // strQuery = 'SELECT ClosedDate , Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND Type != \'NPS\' AND ClosedDate = TODAY AND Account.recordtype.name != \'Family\'';
       // strQuery = 'SELECT ClosedDate ,Contacted_By__c, Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND (Type != \'NPS\'  OR  Service_Request_Type__c != \'NPS\')AND ClosedDate = TODAY AND Contacted_By__c != \'RM\' AND Account.recordtype.name != \'Family\'';
		strQuery = 'SELECT ClosedDate ,BotUniqueId__c, Account.DND__c ,Account.Primary_CXO__c , Contacted_By__c, Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND (Type != \'NPS\'  OR  Service_Request_Type__c != \'NPS\')AND ClosedDate = TODAY AND Account.recordtype.name != \'Lead\' AND Account.recordtype.name != \'Family\'  AND BotUniqueId__c = null';
        system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Case> listOfCases) {
        Map<String, Case> emailCaseMap = new  Map<String, Case>();
        Set<String> listOfEmail = new Set<String>();//set
        List<Survey__c> toBeCreated = new List<Survey__c>();
        List<Case> filteredCases = new List<Case>();
        List<Case> listOfFilteredCases = new List<Case>();
        Map<String, Case> emailComplaintCaseMap = new  Map<String, Case>();
        for(Case c : listOfCases){
            User user = listOfOpsUsers.get(c.OwnerId);
            group queue = wealthOpsQueue.get(c.OwnerId);
            if((user != Null ||  queue != Null)){
            }else{
                	listOfFilteredCases.add(c);
            }
            
        }
        
        for(Case c : listOfFilteredCases){
            if(c.Nature__c == 'Complaint'){
                Survey__c survey = new Survey__c();
                survey.Survey_Sent_Email__c = c.Account.Primary_Email__c;
               // survey.Survey_Sent_Date__c = System.today();
                survey.Case__c = c.id;
                survey.account__c = c.Account.id;
                survey.Survey_Sent__c = false;
                toBeCreated.add(survey);
                emailComplaintCaseMap.put(c.Account.Primary_Email__c,c);
            }else{
                if(c.Contacted_By__c != 'RM' &&  c.Account.DND__c != TRUE){
                filteredCases.add(c);
            }
        }
        }
        for(Case c : filteredCases){
            listOfEmail.add(c.Account.Primary_Email__c);
            emailCaseMap.put(c.Account.Primary_Email__c, c);
        }
        
        Sys_Properties__c surveyFrequency = Sys_Properties__c.getValues('Survey Frequency');
        Integer days = Integer.valueOf(surveyFrequency.value__c);
        Date lastWeek = Date.today().addDays(-days);	
        System.debug('lastWeek : '+lastWeek);
        List<Survey__c> listOfSurvey = [SELECT id , Survey_Sent_Email__c , Survey_Sent_Date__c FROM Survey__c where Survey_Sent_Email__c IN:listOfEmail AND Survey_Sent_Date__c >=:lastWeek];
        Map<String,Survey__c>  emailSurveyMap = new Map<String,Survey__c>();
        for(Survey__c s: listOfSurvey){
            System.debug('Survey_Sent_Date__c '+ s.Survey_Sent_Date__c);
            emailSurveyMap.put(s.Survey_Sent_Email__c, s);
        }
        for(String email : listOfEmail){
            if(!emailSurveyMap.containsKey(email) && !emailComplaintCaseMap.containsKey(email)){
                Survey__c survey = new Survey__c();
                survey.Survey_Sent_Email__c = email;
                //survey.Survey_Sent_Date__c = System.today();
                Case c = emailCaseMap.get(email);
                survey.Case__c = c.id;
                survey.account__c = c.Account.id;
                survey.Survey_Sent__c = false;
                toBeCreated.add(survey);
            }
        }
        if(!toBeCreated.isEmpty()){
            Insert(toBeCreated);
        }
        System.debug('toBeCreated : '+toBeCreated);
    }
    global void finish(Database.BatchableContext bcMain){
        Sys_Properties__c surveysiteURL = Sys_Properties__c.getValues('SurveySiteURL');
        String siteURL = String.valueOf(surveysiteURL.value__c);
        Sys_Properties__c surveyPageURL = Sys_Properties__c.getValues('SurveyPageURL');
        String pageURL = String.valueOf(surveyPageURL.value__c);

        Map<String,Contact> accountContactMap = new Map<String,Contact>();
        List<String> emails = new List<String>();
        List<Survey__c> todayCreatedSurvey = [SELECT id,account__c, Survey_Sent__c , Case__c, account__r.name ,account__r.Primary_CXO__r.name,account__r.salutation__c,Case__r.owner.name, Survey_Sent_Date__c, Survey_Sent_Email__c FROM Survey__c WHERE CreatedDate = TODAY AND Survey_Sent__c = false];
        OrgWideEmailAddress owa = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'Edelweiss Global Wealth Management' limit 1];
        EmailTemplate et = [SELECT id , HtmlValue FROM EmailTemplate WHERE developerName = 'SurveyEmail'];
        List<Survey__c> toBeUpdated = new  List<Survey__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('todayCreatedSurvey'+todayCreatedSurvey);
        for(Survey__c mailSend : todayCreatedSurvey){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddress = new List<String>();
            toAddress.add(mailSend.Survey_Sent_Email__c);
            EmailTemplate em = new EmailTemplate(); 
            em = et;
            mail.setTemplateId(em.id);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId('005280000030fCj');
			mail.setOrgWideEmailAddressId(owa.id);
            String htmlValue = em.HtmlValue;
            String htmlValueModified = htmlValue.replace('[ACNAME]', mailSend.Account__r.Name);
            if(mailSend.account__r.salutation__c !=null){
                htmlValueModified = htmlValueModified.replace('[SAL]', mailSend.account__r.salutation__c);
            }else{
                htmlValueModified = htmlValueModified.replace('[SAL]', '');
            }
            htmlValueModified = htmlValueModified.replace('###', mailSend.account__r.Primary_CXO__r.name);
            htmlValueModified = htmlValueModified.replace('google.com', siteURL+pageURL+'?id='+mailSend.account__r.id+'&surveyId='+mailSend.Id);
            //em.HtmlValue = htmlValueModified;
            mail.htmlBody  = htmlValueModified;
            mail.setToAddresses(toAddress);
            //mail.setSenderDisplayName('Edelweiss Global Wealth Management');
            mail.setSubject('Your Feedback Matters');
            mail.setBccSender(false);
            mails.add(mail);
            mailSend.Survey_Sent__c = true;
            mailSend.Survey_Sent_Date__c = System.today();
            toBeUpdated.add(mailSend);
        }
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(mails);
        Database.rollback(sp);
        
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : mails) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setOrgWideEmailAddressId(owa.id);
            msgListToBeSend.add(emailToSend);
        }
       // Messaging.sendEmail(msgListToBeSend);
        if(!toBeUpdated.isEmpty()){
            update(toBeUpdated);
        }
        System.debug('toBeUpdated : '+toBeUpdated);
    }
}