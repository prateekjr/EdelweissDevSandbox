//database.executeBatch(new FinancialTransactionMailBatch());
global class FinancialTransactionMailBatch implements Database.Batchable<sObject> ,Database.Stateful
{
        
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeNameId.put(info.getName(),info.getRecordTypeId());
        }
        Id recordTypeIdServiceRequest = mapofCaseRecordTypeNameId.get(EdelweissConstants.FINANCIAL_TRANSACTION);
        
        String SOQL = 'SELECT Id, Status, OwnerId, Owner.Email, Owner.Name, CaseNumber, Type, Previous_FA__c,AccountId,Account.Name,Case_Type__c,Priority,Product_Type__c,Script_Name__c,Script_Name__r.Name,Amount__c,Remarks__c,Product_Risk_Profile__c,Family_Risk_Profile__c,Family_AUA_INR_Cr__c FROM Case WHERE Status =\'Closed – Rejected\' AND RecordTypeId = \''+ recordTypeIdServiceRequest+'\' AND Buy_Sell__c =\'Buy\' AND CreatedDate = this_month Order BY Owner.Email' ;
        
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext ctx, List<sObject> scope)
    {
        system.debug('scope=='+scope);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, Name, Email, ManagerId, Manager.Email, UserRoleId, Business_Head__c,Regional_Head__c, UserRole.Name, Business_Head__r.Email,Regional_Head__r.Email FROM User]);
        List<User> BHPHUsers = [SELECT Id FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Business_Head')];
        
        Map<Id,List<Case>> MapCaseOwner = new Map<Id,List<Case>>();
        List<Case> allCases = new List<Case>();
        for(sObject caseRecord : scope)
        {
            case caseObj =  (case)caseRecord;
            allCases.add(caseObj);
            user regionalHead = null;                                    
            if(userMAP.get(caseObj.OwnerId).Regional_Head__c != null && userMAP.get(caseObj.OwnerId).Regional_Head__r.Email != null)
                regionalHead = userMAP.get(userMAP.get(caseObj.OwnerId).Regional_Head__c);          
            
            List<Case> cases = new List<Case>();
            if(regionalHead != null){
                cases = new List<Case>();
                if(MapCaseOwner.containsKey(regionalHead.Id))
                    cases =  MapCaseOwner.get(regionalHead.Id);
                cases.add(caseObj);
                MapCaseOwner.put(regionalHead.Id,cases);
            }            
        }
        for(user u : BHPHUsers){
            MapCaseOwner.put(u.Id,allCases);
        }
        
        system.debug('MapCaseOwner=='+MapCaseOwner);
        
        // Mail Send to Business_Head__c and  Regional_Head__c
        for(Id userId: MapCaseOwner.keySet()){
            List<case> cs = MapCaseOwner.get(userId);
            user userDetail = userMAP.get(userId);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.subject = 'Rejected Financial Transaction';
            mail.toAddresses = new String[]{userDetail.Email};           
            mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'};
            mail.setSenderDisplayName('PWM SalesForceUpdate');
            
            mail.htmlBody = FinancialTransactionMailBatch.getEmailBody(cs, userDetail.Name);
            emails.add(mail);
        }         
        
        Messaging.sendEmail(emails);
    }
    
    public static String getEmailBody(List<Case> cases, String mailTo){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        String emailBody =  '<p style="font-family:Calibri;">Hi ' + mailTo + ',</br></br>' + 'The following Financial Transaction has been Rejected.' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Number</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Client Name</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">FA Name</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Case Type</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Product Type</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Script Name</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Amount (INR Lakhs)</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Product Risk Profile</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Family Risk Profile</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Family Total AUA(INR Cr)</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Remarks</th></tr>';
        
        String table; 
        for(case c : cases){
            String caseUrl = baseUrl + '/' + c.Id;
            String accUrl = baseUrl + '/' + c.AccountId;
            String prodUrl = baseUrl + '/' + c.Script_Name__c;
            
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+caseUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.CaseNumber + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+accUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.Account.Name + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Owner.Name + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Case_Type__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Product_Type__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+prodUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.Script_Name__r.Name + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Amount__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Product_Risk_Profile__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Family_Risk_Profile__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Family_AUA_INR_Cr__c + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Remarks__c + '</td></tr>';      
            
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
      //database.executeBatch(new FinancialTransactionMailBatch());  
    }
}