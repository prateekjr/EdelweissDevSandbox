global class Edelweiss_Batch_SendMail_EscalatedCases implements Database.Batchable<sObject> ,Database.Stateful
{
    global boolean isRunDaily;
    global Edelweiss_Batch_SendMail_EscalatedCases(){
        isRunDaily = false;
    }
    global Edelweiss_Batch_SendMail_EscalatedCases(boolean RunDaily){
        system.debug('RunDaily=='+RunDaily);
        isRunDaily = RunDaily;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeNameId.put(info.getName(),info.getRecordTypeId());
        }
        Id recordTypeIdServiceRequest = mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST);
        
        String SOQL = 'SELECT Id, Status, OwnerId, Owner.Email, Owner.Name, Service_Request_Type__c , CaseNumber, Type, Previous_FA__c,Account.Name,Due_Date_Time__c,Case_Type__c,Priority,Description,Client_Satisfaction_Measurement_NPS__r.Name,Client_Satisfaction_Measurement_NPS__c FROM Case WHERE IsEscalated  = True AND (Type =\'NPS\' OR Service_Request_Type__c=\'NPS\')AND RecordTypeId = \''+ recordTypeIdServiceRequest+'\' Order BY Owner.Email' ;
        
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext ctx, List<sObject> scope)
    {
        system.debug('scope=='+scope);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, Name, Email, ManagerId, Manager.Email, UserRoleId, Business_Head__c,Regional_Head__c, UserRole.Name, Business_Head__r.Email,Regional_Head__r.Email FROM User]);
        
        List<User> cxoIndiaUsers = [SELECT Id, Email, Name, UserRole.Name FROM User  Where UserRole.Name = 'CXO - India' and isActive = true ];
        
        Map<Id,List<Case>> MapCaseOwner = new Map<Id,List<Case>>();
        Map<Id,List<Case>> MapCaseOwnerDaily = new Map<Id,List<Case>>();
        List<Case> CXOIndiaCase = new List<Case>();
        for(sObject caseRecord : scope)
        {
            case caseObj =  (case)caseRecord;
            user businessHead = null;
            user regionalHead = null;
            if(userMAP.get(caseObj.OwnerId).Business_Head__c != null && userMAP.get(caseObj.OwnerId).Business_Head__r.Email != null)
                businessHead = userMAP.get(userMAP.get(caseObj.OwnerId).Business_Head__c);
            
            if(userMAP.get(caseObj.OwnerId).UserRoleId != null && !userMAP.get(caseObj.OwnerId).UserRole.Name.containsIgnoreCase('CXO') ){
                if(userMAP.get(caseObj.OwnerId).Regional_Head__c != null && userMAP.get(caseObj.OwnerId).Regional_Head__r.Email != null)
                    regionalHead = userMAP.get(userMAP.get(caseObj.OwnerId).Regional_Head__c);
            }
            
            List<Case> cases = new List<Case>();
            if(businessHead != null){
                cases = new List<Case>();
                if(MapCaseOwner.containsKey(businessHead.Id))
                    cases =  MapCaseOwner.get(businessHead.Id);
                cases.add(caseObj);
                MapCaseOwner.put(businessHead.Id,cases);
                CXOIndiaCase.add(caseObj);
            }
            if(regionalHead != null){
                cases = new List<Case>();
                if(MapCaseOwner.containsKey(regionalHead.Id))
                    cases =  MapCaseOwner.get(regionalHead.Id);
                cases.add(caseObj);
                MapCaseOwner.put(regionalHead.Id,cases);
            }
            //owner map
            cases = new List<Case>();
            if(MapCaseOwnerDaily.containsKey(caseObj.OwnerId))
                cases =  MapCaseOwnerDaily.get(caseObj.OwnerId);
            cases.add(caseObj);
            MapCaseOwnerDaily.put(caseObj.OwnerId,cases);
            
        }
        system.debug('MapCaseOwner=='+MapCaseOwner);
        
        if(isRunDaily){
            // Mail Send to case owner
            for(Id userId: MapCaseOwnerDaily.keySet()){
                List<case> cs = MapCaseOwnerDaily.get(userId);
                user userDetail = userMAP.get(userId);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.subject = 'Case is escalated';
                List<String> toEmails = new List<String>();
                toEmails.add(userDetail.Email);    
                system.debug('Manager'+userDetail.ManagerId );          
                if(userDetail.ManagerId != null){
                     toEmails.add(userDetail.Manager.Email);
                }
                mail.toAddresses = toEmails;
                system.debug('mail.toAddresses'+mail.toAddresses); 
                mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'}; //new String[]{'pwm.salesforceupdate@edelweissfin.com'};
                mail.setSenderDisplayName('PWM SalesForceUpdate');
                
                mail.htmlBody = Edelweiss_Batch_SendMail_EscalatedCases.getEmailBody(cs, userDetail.Name);
                emails.add(mail);
            }
        }else{
            // Mail Send to Business_Head__c and  Regional_Head__c
            for(Id userId: MapCaseOwner.keySet()){
                List<case> cs = MapCaseOwner.get(userId);
                user userDetail = userMAP.get(userId);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.subject = 'Case is escalated';
                mail.toAddresses = new String[]{userDetail.Email};           
                mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'};
                mail.setSenderDisplayName('PWM SalesForceUpdate');
                
                mail.htmlBody = Edelweiss_Batch_SendMail_EscalatedCases.getEmailBody(cs, userDetail.Name);
                emails.add(mail);
            }
            if(CXOIndiaCase != null && CXOIndiaCase.size() > 0 && cxoIndiaUsers != null && cxoIndiaUsers.size() > 0){
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.subject = 'Case is escalated';
                String toMail = '';
                List<String> toAddresses = new List<String>();
                for(user cxoIndia : cxoIndiaUsers){
                    toAddresses.add(cxoIndia.Email);
                    toMail += cxoIndia.Name + '/';
                }
                mail.toAddresses = toAddresses;
                toMail = toMail.removeEnd('/');                         
                mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'};
                mail.setSenderDisplayName('PWM SalesForceUpdate');
                
                mail.htmlBody = Edelweiss_Batch_SendMail_EscalatedCases.getEmailBody(CXOIndiaCase, toMail);
                emails.add(mail);
            }
        }
        
        Messaging.sendEmail(emails);
    }
    
    public static String getEmailBody(List<Case> cases, String mailTo){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody =  '<p style="font-family:Calibri;">Hi ' + mailTo + ',</br></br>' + 'The following NPS cases has been escalated as it has past due date.' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Number</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Lead/Client/Family</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">NPS Number</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Due Date</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Type</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Priority</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Owner</th></tr>';
        
        String table; 
        for(case c : cases){
            String caseUrl = baseUrl + '/' + c.Id;
            String npsUrl = baseUrl + '/' + c.Client_Satisfaction_Measurement_NPS__c;
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+caseUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.CaseNumber + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Account.Name + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+npsUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.Client_Satisfaction_Measurement_NPS__r.Name + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Due_Date_Time__c.format() + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Case_Type__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Priority + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Owner.Name + '</td></tr>';
            
            if(table == null)
                table = row;
            else
                table = table + row;       
        }
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + table + endBody);
    }
    
    global void finish(Database.BatchableContext ctx)
    {
      //database.executeBatch(new Edelweiss_Batch_SendMail_EscalatedCases());  
    }
}