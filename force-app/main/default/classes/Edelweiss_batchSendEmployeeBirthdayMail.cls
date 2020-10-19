global class Edelweiss_batchSendEmployeeBirthdayMail implements Database.Batchable<sObject>, Database.Stateful {
    
    global String strQuery;
    global Map<Id,Group> wealthOpsQueue = new Map<Id,Group>([select Id from Group where  Type = 'Queue' AND NAME = 'Wealth Ops' limit 1]);
    global Map<Id,User> listOfOpsUsers = new Map<Id,User>([SELECT id FROM User WHERE Profile.Name = 'Operations']);
    global Edelweiss_batchSendEmployeeBirthdayMail(){
        // strQuery = 'SELECT ClosedDate , Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND Type != \'NPS\' AND ClosedDate = TODAY AND Account.recordtype.name != \'Family\'';
        // strQuery = 'SELECT ClosedDate ,Contacted_By__c, Account.id ,Account.Primary_Email__c, Account.Name ,Nature__c, CaseNumber,Account.RecordType.Name , owner.name FROM case where Case_Type__c = \'Service Request\'  AND Status = \'Closed – Success\' AND (Type != \'NPS\'  OR  Service_Request_Type__c != \'NPS\')AND ClosedDate = TODAY AND Contacted_By__c != \'RM\' AND Account.recordtype.name != \'Family\'';
        strQuery = 'SELECT Date_of_Birth__c , id , isBirthdayToday__c,Sub_LOB__c,SBU__c,Don_t_send_Birthday_Mailers__c FROM Edelweiss_Employee_Details__c where Don_t_send_Birthday_Mailers__c != true  ';
        
        system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Employee_Details__c> listOfEmployee) {
        
    }
    global void finish(Database.BatchableContext bcMain){
        List<Edelweiss_Employee_Details__c> listOfEmployee = [SELECT Date_of_Birth__c , id ,Location__c,Employee_Name__c, Designation__c , Department__c , isBirthdayToday__c,Email_ID__c,Employee_Code__c	, LOB__c,Sub_LOB__c, Don_t_send_Birthday_Mailers__c FROM Edelweiss_Employee_Details__c WHERE Don_t_send_Birthday_Mailers__c != true] ;
       system.debug('listOfEmployee-->'+listOfEmployee);
        List<Edelweiss_Employee_Details__c> toBeUpdated = new List<Edelweiss_Employee_Details__c>();
        For(Edelweiss_Employee_Details__c employee : listOfEmployee){
            if(employee.Date_of_Birth__c != null){
                Integer day = employee.Date_of_Birth__c.day();
                Integer month = employee.Date_of_Birth__c.month();
                Integer currentDay = System.today().day();
                Integer currentMonth = System.today().month();
                
                if(day == currentDay && month == currentMonth){
                    //employee.isBirthdayToday__c = true;
                    toBeUpdated.add(employee);
                }
            }
        }
        
        System.debug('*****toBeUpdated'+toBeUpdated);
//database.update(toBeUpdated,false);
        Map<String,Contact> accountContactMap = new Map<String,Contact>();
        Sys_Properties__c BirthdayCCEmail = Sys_Properties__c.getValues('BirthdayCCEmail');
        String ccEmail  = BirthdayCCEmail.value__c;
        System.debug('*******ccEmail'+ccEmail);
        List<String> emails = new List<String>();
        //List<Edelweiss_Employee_Details__c> employeeDetails = [SELECT Date_of_Birth__c , id ,Location__c,Employee_Name__c, Designation__c , Department__c , isBirthdayToday__c,Email_ID__c,Employee_Code__c	, LOB__c,Sub_LOB__c FROM Edelweiss_Employee_Details__c WHERE isBirthdayToday__c = true];
        OrgWideEmailAddress owa = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM HR - PWM' limit 1];
        EmailTemplate et = [SELECT id , HtmlValue FROM EmailTemplate WHERE developerName = 'Employee_Birthday_Mail'];
        List<Edelweiss_Employee_Details__c> toBeUpdateduncheck = new  List<Edelweiss_Employee_Details__c>();
        List<Edelweiss_Employee_Details__c> mailSentUpdate = new  List<Edelweiss_Employee_Details__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        for(Edelweiss_Employee_Details__c details : toBeUpdated){
            if(details.Email_ID__c != null && details.Employee_Name__c !=null && details.Department__c !=null&& details.Location__c !=null) {
                toAddress.add(details.Email_ID__c);
                toBeUpdateduncheck.add(details);
            }
        }
        /*if(!toBeUpdated.isEmpty()){//
           Database.update(toBeUpdated,false);//
        }*/
        System.debug('Before If Inside Finish');
        if(toBeUpdated != null && toAddress != null && !toAddress.isEmpty()){
            String htmlStringAppend = '';
            String htmlValueModified = '';
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                EmailTemplate em = new EmailTemplate(); 
                em = et;
                mail.setTemplateId(em.id);
                mail.setSaveAsActivity(false);
            	//Set PWM User's ID 
                mail.setTargetObjectId('005280000030fCjAAI');
                mail.setOrgWideEmailAddressId(owa.id);
            integer sizeOfList = toBeUpdated.size();//
            for(integer i=1 ; i<=sizeOfList ; i++){
                String htmlValue = em.HtmlValue;
                Edelweiss_Employee_Details__c details = toBeUpdateduncheck[i-1];//
                String s = '</tr><tr bgcolor="#f3ea9d"><td style="font: 14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000; border-bottom:1px solid #ffffff; border-right:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Employee_Name__c+'<td style="font:14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000;  border-bottom:1px solid #ffffff; border-right:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Department__c+'</td>                               <td style="font:14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000;  border-bottom:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Location__c+'</td>';
                String s1 = '<tr bgcolor="#d0cec0"><td style="font: 14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000; border-bottom:1px solid #ffffff; border-right:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Employee_Name__c+'<td style="font:14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000;  border-bottom:1px solid #ffffff; border-right:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Department__c+'</td><td style="font:14px/20px Calibri, Verdana, Geneva, sans-serif; color:#000000;  border-bottom:1px solid #ffffff; padding:5px 10px 5px 10px; text-align:center">'+details.Location__c+'</td></tr>';
                    if((math.mod(i, 2)) == 1){
                        htmlStringAppend = htmlStringAppend+s;
                    }else if((math.mod(i, 2)) == 0){
                        htmlStringAppend = htmlStringAppend+s1;
                    }
                
                htmlValueModified = htmlValue.replace('####', htmlStringAppend);
                System.debug('********* Mail'+mail);
        }
              mail.htmlBody = htmlValueModified;
                mail.setToAddresses(toAddress);
            if(ccEmail != null){
                ccAddress.add(ccEmail);
                mail.setCcAddresses(ccAddress);
            }
               // mail.setSenderDisplayName('PWM HR – PWM');
                mail.setSubject('Wish you a Happy Birthday !');
                mail.setBccSender(false);
                mails.add(mail);
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
             for(Edelweiss_Employee_Details__c details : toBeUpdateduncheck){//
                details.isMailSent__c = true;
                mailSentUpdate.add(details);
        }
             if(!toBeUpdateduncheck.isEmpty()){//
             Database.update(mailSentUpdate,false);
             }
            System.debug('******** msgListToBeSend'+msgListToBeSend[0].getToAddresses());
            System.debug('toBeUpdated : '+toBeUpdated);//
        } 
    }        
}