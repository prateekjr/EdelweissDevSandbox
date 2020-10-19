global class Edelweiss_batchSurveyNegativeFeedback implements Database.Batchable<sObject>, Database.Stateful  {
    
    global String strQuery;
    global Edelweiss_batchSurveyNegativeFeedback(){
    strQuery = 'SELECT Satisfaction__c ,account__r.name, Query_Resolution__c , id , Survey_Sent_Email__c , LastModifiedDate , Feedback_received_date_time__c FROM Survey__c WHERE Feedback_received_date_time__c = TODAY';
    system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Survey__c> listOfSurvey) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateA = [SELECT id , HtmlValue FROM EmailTemplate WHERE developerName = 'SurveyNegativeFeedback'];
        OrgWideEmailAddress owa = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'Edelweiss Global Wealth Management' limit 1];
        List<Survey__c> filteredSurvey =  new List<Survey__c>();
        for(Survey__c survey : listOfSurvey){
            if(survey.Query_Resolution__c == 'No' || survey.Satisfaction__c == 'improve'){
					filteredSurvey.add(survey);           
            }
        }
        System.debug('filteredSurvey'+filteredSurvey);
        for(Survey__c s : filteredSurvey){
            List<String> toAddress = new List<String>();		
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               	EmailTemplate em = new EmailTemplate(); 
                em = templateA;
            	toAddress.add(s.Survey_Sent_Email__c);
                mail.setTemplateId(em.id);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId('005280000030fCj');
                String htmlValue = em.HtmlValue;
                String htmlValueModified = htmlValue.replace('[ACNAME]', s.account__r.name);
                mail.htmlBody  = htmlValueModified;
                mail.setToAddresses(toAddress);   
                mail.setSubject('Your feedback is valued !');
                mail.setBccSender(false);
                mails.add(mail);
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
        System.debug('msgListToBeSend'+msgListToBeSend);
        //Messaging.sendEmail(msgListToBeSend);
}
    
    global void finish(Database.BatchableContext bcMain){}
}