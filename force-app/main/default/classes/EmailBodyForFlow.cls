public class EmailBodyForFlow {

    @InvocableMethod
    public static void callMethodFromFlow(List<List<Account>> accList)
    {
        List<Account> accListFinal = new List<Account>();
        accListFinal.addAll(accList[0]);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> lstToEmails = new List<String>();
        Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, isActive , profile.Name , Name, Email FROM User where isActive = true]);
        Map<string, list<Account>> userEmailMap= new Map<string, list<Account>>();
        Map<string,string> userEmailNameMap = new Map<string,string>();
        user FAUser;
        user CXOUser;
        for(Account acc : accListFinal)
        {
            FAUser = userMAP.get(acc.Primary_FA__c);
            CXOUser = userMAP.get(acc.Primary_CXO__c);
           
            if(acc.Primary_FA__c != null || FAUser != null)
                {
                    if(!userEmailMap.containsKey(FAUser.Email) )
                    {
                        userEmailNameMap.put(FAUser.Email, FAUser.Name);
                        userEmailMap.put(FAUser.Email, new List<Account>{acc});
                    }
                    else
                    {
                        userEmailMap.get(FAUser.Email).add(acc);
                    }
                }   
            if(acc.Primary_CXO__c != null || CXOUser != null)
            {
                    if(!userEmailMap.containsKey(CXOUser.Email) )
                    {
                        userEmailNameMap.put(CXOUser.Email, CXOUser.Name);
                        userEmailMap.put(CXOUser.Email, new List<Account>{acc});
                    }
                    else
                    {
                        userEmailMap.get(CXOUser.Email).add(acc);
                    }
                
            }
        }
        System.debug('Map :'+userEmailMap);
        if(userEmailMap.size() > 0)
        {
            for(String userEmail : userEmailMap.keySet())
            {
                System.debug('userEmail :'+userEmail);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.subject = 'Upcoming Birthday';
                //toAddresses.add(BHUser.Email);   //Doubt
                mail.toaddresses = new String[]{userEmail}; 
                    mail.htmlBody = EmailBodyForFlow.getEmailBody(userEmailMap.get(userEmail), userEmailNameMap.get(userEmail));
                emails.add(mail);  
            }
        }
        System.debug('emails :'+emails);
        if(emails != null && emails.size() > 0)
        {
            Messaging.sendEmail(emails); 
        }
    }
    
        public static String getEmailBody(List<Account> accList, String userName){
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            Id OrgId = UserInfo.getOrganizationId();
            Id BirthdayEmailUpper = [select id from Document where name='BirthdayEmailUpper'].Id;
            Id BirthdayEmailBottom = [select id from Document where name='BirthdayEmailBottom'].Id;
            
            
            //string url = '"'+baseURL+'/servlet/servlet.ImageServer?id='+imageId+'&oid'+OrgId+'"';
            //System.debug('URL :'+url);
            String emailBody =  '<div style="background-color:#f6f6f6;width:700px;"><IMG SRC="'+baseURL+'/servlet/servlet.ImageServer?id='+BirthdayEmailUpper+'&oid='+OrgId+'" ALT="Birthday Image" WIDTH=700 HEIGHT=210">'+
                '<div style="padding: 15px;"><span style="font-family:Calibri;margin-top:-4px">Hi <b>' +userName + '</b>,</br></br>' + 'Here is an opportunity for you to connect with your client.</span>'+
                '<p style="font-family:Calibri;">Please take a note of upcoming birthdays of your client(s).</p>'+
                '<table style="border-collapse:collapse;font-family:Calibri;width:670px;overflow-x:auto;">' +
                '<tr><th style="border: 1px solid black;text-align:left;padding:8px;color:#0858B4">Client Name</th><th style="border: 1px solid black;text-align:left;padding:8px;color:#0858B4">Birthday Date</th>'+
                '<th style="border: 1px solid black;text-align:left;padding:8px;color:#0858B4">Day</th>'+
                '<th style="border: 1px solid black;text-align:left;padding:8px;color:#0858B4">Contact No</th><th style="border: 1px solid black;text-align:left;padding:8px;color:#0858B4">For Details</th></tr>';
                
                String endBody = '</table></div></div><IMG SRC="'+baseURL+'/servlet/servlet.ImageServer?id='+BirthdayEmailBottom+'&oid='+OrgId+'" ALT="Birthday Image" WIDTH=700 HEIGHT=40></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Advisor Edge</p>';
            
            for(Account acc : accList)
            {
                Date after2DaysDate = System.today().addDays(2);
                Datetime dt = DateTime.newInstance(after2DaysDate, Time.newInstance(0, 0, 0, 0));
                String dayOfWeek=dt.format('EEEE');
                System.debug('Day : ' + dayOfWeek);
                String formatedDate;
                if(acc.Date_of_Birth__c != null)
                {
                    Date dateOfBirth = acc.Date_of_Birth__c;
                    System.debug('dateOfBirth :'+dateOfBirth);
                    System.debug('dateOfBirth :'+dateOfBirth.year());
                    formatedDate = DateTime.newInstance(dateOfBirth.year(),dateOfBirth.month(),dateOfBirth.day()).format('dd-MM-YYYY');
                    System.debug('formatedDate'+formatedDate);
                }

                String accUrl = baseUrl + '/' + acc.Id;
                emailBody = emailBody + '<tr><td style="border: 1px solid black;text-align:left;padding:8px">' + acc.name + '</a></td>'+ 
                    '<td style="border: 1px solid black;text-align:left;padding:8px">' + formatedDate + '</a></td>'+
                    '<td style="border: 1px solid black;text-align:left;padding:8px">' + dayOfWeek + '</a></td>'+
                    '<td style="border: 1px solid black;text-align:left;padding:8px">' + acc.Mobile_1__c + '</a></td>'+              
                    '<td style="border: 1px solid black;text-align:left;padding:8px"><a href="'+accURL+'" target="_blank" style="text-decoration:none;color:#FC8618;">Click Here</td></tr>';
            }
            return(emailBody + endBody);
        }
}