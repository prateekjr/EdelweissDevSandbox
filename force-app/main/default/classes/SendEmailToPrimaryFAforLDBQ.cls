global class SendEmailToPrimaryFAforLDBQ implements Database.Batchable<sObject>{
    
    Map<Id, List<Account>> OwnerId_Lead = new Map<Id, List<Account>>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Name, Lead_Database_Due_Date__c, IsValidLDBQ__c, OwnerId, Owner.Name, Owner.Email FROM Account WHERE RecordType.DeveloperName = 'Lead' AND Coverage__c != 'Lead Database' AND IsValidLDBQ__c = TRUE ORDER BY Lead_Database_Due_Date__c]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> leads){
        OwnerId_Lead = convertListToMap(leads);
        system.debug('OwnerId_Lead=='+OwnerId_Lead);
        sendEmail(OwnerId_Lead); 
            
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    public Map<Id, List<Account>> convertListToMap(List<Account> leads){
        
        
        Map<Id, List<Account>> OwnerId_Lead = new Map<Id, List<Account>>();
        
        for(Account lead: leads){
            if(lead.Lead_Database_Due_Date__c != null){
                List<Account> accts = new List<Account>();            
                if(OwnerId_Lead.containsKey(lead.OwnerId)){
                    accts = OwnerId_Lead.get(lead.OwnerId);
            }
            accts.add(lead);
                OwnerId_Lead.put(lead.OwnerId, accts);
        }
        }
        return OwnerId_Lead;
    }
    
    public String getEmailBody(List<Account> accts){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody = '<p style="font-family:Calibri;">Hi ' + accts[0].Owner.Name + ',</br></br>' + 
            				'This is to inform you that you need to take an action for the Leads mentioned below ' + 
                            'before the due date.You can either convert a Lead to Family or get an extension from your Reporting Authority.</p>' +
            				'</br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
            				'<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Lead Name</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Due Date</th></tr>';
        
        String table;
        for(Account a : accts){
            String acctUrl = baseUrl + '/' + a.Id;
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+acctUrl+'" target="_blank" style="text-decoration:none;">' + a.Name + '</a></td>' +
                         '<td style="border:1px solid #dddddd;text-align:left;padding:8px">'+ a.Lead_Database_Due_Date__c.format() + '</td></tr>';
            
            if(table == null)
                table = row;
            else
            	table = table + row;       
		}
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + table + endBody);
    }
    
    public void sendEmail(Map<Id, List<Account>> OwnerId_Lead){
        List<Account> accts = new List<Account>();
        
        Set<Id> primaryFaIds = OwnerId_Lead.keySet();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id priFaId: primaryFaIds){
            accts = OwnerId_Lead.get(priFaId);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = new String[] {accts[0].Owner.Email}; //new String[] {'shubhangi_badwaik@persistent.co.in'};  
            mail.subject = 'Action to be taken for Lead';
            mail.htmlBody = getEmailBody(accts);    
            mails.add(mail);
            
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
}

/* 

String emailBody = '<p style="font-family:Calibri;">Hi ' + accts[0].Owner.Name + ',</br></br>' + 
                            'This is to inform you that you need to take an action for the Leads mentioned below ' + 
                            'before the due date.</p> <p style="font-family:Calibri;"> You can either convert a Lead to Family ' +
            				' or get an extension from your Reporting Authority.</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Lead Name</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Days in Lead Stage</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Due Date</th></tr>';

String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">' + a.Name + '</td>' +
                		 '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + Date.today().daysBetween(a.Lead_Database_Due_Date__c) + '</td>' +
                         '<td style="border:1px solid #dddddd;text-align:left;padding:8px">'+ a.Lead_Database_Due_Date__c.format() + '</td></tr>';

    
*/