global class Edelweiss_BatchSendMail_UnicaCases implements Database.Batchable<sObject>, Database.Stateful {

    global Map<String,List<Case>> mapRHEmail_Cases = new Map<String,List<Case>>();
    global Map<String,String> mapRHEmail_Name = new Map<String,String>();
    global Map<Id, User> mapUser;
    
    global Edelweiss_BatchSendMail_UnicaCases(){
        mapUser = new Map<Id, User>([
            SELECT Id, Name, Regional_Head__r.Name, Regional_Head__r.Email FROM User WHERE Regional_Head__c <> Null
        ]);
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Id recordTypeIdServiceRequest = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.SERVICE_REQUEST).getRecordTypeId();
        String SOQL = 'SELECT Id, CaseNumber, Status, Priority, Campaign_Product__c, OwnerId, Owner.Name, Account.Name, Due_Date_Time__c, Case_Type__c FROM Case WHERE Type =\'Product Info\' AND CreatedDate = THIS_MONTH AND RecordTypeId = \''+ recordTypeIdServiceRequest+'\'  Order BY Owner.Email' ;
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext ctx, List<Case> lstCases)
    {
        Set<Id> caseOwnerId = new Set<Id>();
        
        System.debug('Executing batch : '+lstCases);
        
        for(Case caseRecord : lstCases)
        {
            User objUser = mapUser.get(caseRecord.OwnerId);
            System.debug('objUser : '+objUser);
            
            if(Null != objUser){
                
                if(mapRHEmail_Cases.containsKey(objUser.Regional_Head__r.Email)){
                    mapRHEmail_Cases.get(objUser.Regional_Head__r.Email).add(caseRecord);
                }else{
                    List<Case> cases = new List<Case>();
                    cases.add(caseRecord);
                    mapRHEmail_Cases.put(objUser.Regional_Head__r.Email, cases);
                }
                    
                
                mapRHEmail_Name.put(objUser.Regional_Head__r.Email, objUser.Regional_Head__r.Name);
            }
        }
        System.debug('mapRHEmail_Cases : '+mapRHEmail_Cases);
        System.debug('mapRHEmail_Name : '+mapRHEmail_Name);
    }
    
    public static String getEmailBody(List<Case> cases, String mailTo){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody =  '<p style="font-family:Calibri;">Hi ' + mailTo + ',</br></br>' + 'Some of the PWM customers has shown interest in newly launched products. All the cases generated in last month related to customer interest are listed below.' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Number</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Customer Name</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Type</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Status</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Due Date</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Campaign Product</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Owner</th></tr>';
        
        String table; 
        String strDateTime;
        for(case c : cases){
            String caseUrl = baseUrl + '/' + c.Id;
            strDateTime = c.Due_Date_Time__c != null ? c.Due_Date_Time__c.format() : '';
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+caseUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.CaseNumber + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Account.Name + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Case_Type__c + '</td>'+
           	'<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Status + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + strDateTime + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Campaign_Product__c + '</td>'+
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
        System.debug('Executing Finish....'+mapRHEmail_Cases);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Id orgWideEmailId = null;
        for(OrgWideEmailAddress owa : [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress]) {
            if(owa.DisplayName.equals('PWM SalesforceUpdate')){
                orgWideEmailId = owa.Id; 
            }
        }
        
        // Mail Send to RH of case owner
        for(String email : mapRHEmail_Cases.keySet()){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.subject = 'Unica - Cases created in last month';
            List<String> toEmails = new List<String>();
            toEmails.add(email);    
            mail.toAddresses = toEmails;
            mail.ccAddresses = new String[]{'shailesh_chimote@persistent.com'}; 
            mail.htmlBody = Edelweiss_BatchSendMail_UnicaCases.getEmailBody(mapRHEmail_Cases.get(email), mapRHEmail_Name.get(email));
            if(Null != orgWideEmailId){
                mail.setOrgWideEmailAddressId(orgWideEmailId);
            }else{
                mail.setSenderDisplayName('PWM SalesforceUpdate');
            }
            emails.add(mail);
        }
        
        System.debug('Eamil List '+emails);
        
        Messaging.sendEmail(emails);
    }
}