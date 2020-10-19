public class SendEmail_FamilyInteraction{ 

    public static void interactForPFReview(List<Account> families){
        
        Map<Id, List<Account>> primaryFA_family = new Map<Id, List<Account>>();
        
        if(!families.isEmpty()){
        for(Account family : families){
                
            if(family.Coverage__c == 'R3' && family.R3_FA_PFReview__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
            else if(family.Coverage__c == 'R4' && family.R4_FA_PFReview__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
            else if(family.Coverage__c == 'R5' && family.R5_FA_PFReview__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
        }
        
            if(!(primaryFA_family.isEmpty())) { sendEmailToFA(primaryFA_family, 'Complete PF Review for Family'); }
        }
        else
            System.debug('No Family records received!');        
    }
    
    public static void familyInteractionForFA(List<Account> families){
        
        Map<Id, List<Account>> primaryFA_family = new Map<Id, List<Account>>();
        
        if(!families.isEmpty()){
        for(Account family : families){
                
            if(family.Coverage__c == 'R3' && family.R3_FA_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
            else if(family.Coverage__c == 'R4' && family.R4_FA_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
            else if(family.Coverage__c == 'R5' && family.R5_FA_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
        }
        
            if(!(primaryFA_family.isEmpty())) { sendEmailToFA(primaryFA_family, 'Complete Family Interaction'); }
        }
        else
            System.debug('No Family records received!');        
    }
    
    public static void familyInteractionForTL(List<Account> families){
        Map<Id, List<Account>> primaryFA_family = new Map<Id, List<Account>>();
        
        if(!families.isEmpty()){
        for(Account family : families){
            if(family.Coverage__c == 'R4' && family.R4_TL_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
            else if(family.Coverage__c == 'R5' && family.R5_TL_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
            }
        }
        
            if(!(primaryFA_family.isEmpty())){        
                //sendEmailToFA(primaryFA_family, 'Complete Family Interaction');
                Map<Id, User> primaryFA_manager = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name, Manager.Email, Manager.Profile.Name FROM User WHERE Id IN: primaryFA_family.keySet() ORDER BY Manager.Name]);   
                sendEmailToTL(primaryFA_family, primaryFA_manager);
        }
        }
        else
            System.debug('No Family records received!');        
    }
    
	public static void familyInteractionForPH(List<Account> families){
        Map<Id, List<Account>> primaryFA_family = new Map<Id, List<Account>>();
        List<Account> familyR5 = new List<Account>();
        
        if(!families.isEmpty()){
        for(Account family : families){
            if(family.Coverage__c == 'R5' && family.R5_RHBHPH_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
                familyR5.add(family);
            }
        }
        if(!(familyR5.isEmpty())){
                //sendEmailToFA(primaryFA_family, 'Complete Family Interaction');
        	List<User> productHead = [SELECT Name, Email FROM User WHERE UserRole.Name = 'FOIG & Product Head' OR UserRole.Name = 'Product Head'];   
        	sendEmailToHead(familyR5, productHead);
        }
	}
        else
            System.debug('No Family records received!');        
    }
    
	public static void familyInteractionForBH_RH_PH(List<Account> families){
        Map<Id, List<Account>> primaryFA_family = new Map<Id, List<Account>>();
        List<Account> familyR5 = new List<Account>();
        List<Account> family_East = new List<Account>();
        List<Account> family_North = new List<Account>();
        List<Account> family_SouthWest = new List<Account>();
        
        if(!families.isEmpty()){
        for(Account family : families){
            if(family.Coverage__c == 'R5' && family.R5_RHBHPH_Interaction__c == false){
                    primaryFA_family = addFamilyToMap(family, primaryFA_family);
                familyR5.add(family);
    
                if(family.Primary_FA__r.Zone__c == 'East')
                    family_East.add(family);
                else if(family.Primary_FA__r.Zone__c == 'North')
                    family_North.add(family);
                else if((family.Primary_FA__r.Zone__c == 'South') || (family.Primary_FA__r.Zone__c == 'West'))
                    family_SouthWest.add(family);
            }
    }
    
        if(!familyR5.isEmpty()){
                //sendEmailToFA(primaryFA_family, 'Complete Family Interaction');
            
            List<User> businessHead = [SELECT Name, Email FROM User WHERE UserRole.Name = 'Business Head'];
            //List<User> productHead = [SELECT Name, Email FROM User WHERE UserRole.Name = 'FOIG & Product Head' OR UserRole.Name = 'Product Head'];
            List<User> regionalHead_East = [SELECT Name, Email FROM User WHERE UserRole.Name = 'Advisory Head - East'];
            List<User> regionalHead_North = [SELECT Name, Email FROM User WHERE UserRole.Name = 'Advisory Head - North'];
            List<User> regionalHead_SouthWest = [SELECT Name, Email FROM User WHERE UserRole.Name = 'Advisory Head - South & West'];
            
            sendEmailToHead(familyR5, businessHead);
            //sendEmailToHead(familyR5, productHead);
            if(!(family_East.isEmpty()) && !(regionalHead_East.isEmpty())) { sendEmailToHead(family_East, regionalHead_East); }
            if(!(family_North.isEmpty()) && !(regionalHead_North.isEmpty())) { sendEmailToHead(family_North, regionalHead_North); }
            if(!(family_SouthWest.isEmpty()) && !(regionalHead_SouthWest.isEmpty())) { sendEmailToHead(family_SouthWest, regionalHead_SouthWest); }    
     	}
    }
        else
            System.debug('No Family records received!');        
	}
    
    public static Map<Id, List<Account>> addFamilyToMap(Account family, Map<Id, List<Account>> primaryFA_family){
        List<Account> accts = new List<Account>();
        
        if(primaryFA_family.containsKey(family.Primary_FA__c)){
        	accts = primaryFA_family.get(family.Primary_FA__c);
        }
        accts.add(family);
        primaryFA_family.put(family.Primary_FA__c, accts);       
 
    	return primaryFA_family;
    }
    
    public static void sendEmailToFA(Map<Id, List<Account>> primaryFA_family, String mailSub){
        List<Account> accts = new List<Account>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Set<Id> primaryFaIds = primaryFA_family.keySet();
        
        Integer count = 0;
        for(Id priFaId: primaryFaIds){
            count++;
            String mailText;
            accts = primaryFA_Family.get(priFaId);
            
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.subject = mailSub;
	        mail.toAddresses = new String[]{accts[0].Primary_FA__r.Email}; //{'shubhangi_badwaik@persistent.co.in'}; 
            
            if(mailSub.equalsIgnoreCase('Complete PF Review for Family'))
                mailText = 'Kindly complete PF Review for the Families mentioned below: ';
            else if(mailSub.equalsIgnoreCase('Complete Family Interaction'))
                mailText = 'Kindly complete interaction for the Families mentioned below: ';
            
            mail.htmlBody = getEmailBody(accts, accts[0].Primary_FA__r.Name, mailText);
			mails.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
    
    public static void sendEmailToTL(Map<Id, List<Account>> primaryFA_family, Map<Id, User> primaryFA_manager){
        List<Account> accts = new List<Account>();
        
        Map<Id,List<Account>> manager_Account = new Map<Id,List<Account>>();
        Map<Id,user> managerMap = new Map<Id,user>();
        
        for(Id FAId: primaryFA_manager.keySet()){
            User user = primaryFA_manager.get(FAId);
            if(user != null && user.managerId != null && primaryFA_family.get(FAId) != null && user.Manager.Profile.Name != NULL && user.Manager.Profile.Name.containsIgnoreCase('Team Leader Advisory')){
                List<Account> lstAcc = new List<Account>();
                if(manager_Account.containsKey(user.managerId)){
                    lstAcc.addAll(manager_Account.get(user.managerId));
                }
                lstAcc.addAll(primaryFA_family.get(FAId));
                manager_Account.put(user.managerId,lstAcc);
            }
            managerMap.put(user.managerId,user);
            
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String mailText = 'Kindly complete interaction for the Families mentioned below: ';
        
        Set<Id> primaryFaIds = primaryFA_family.keySet();
    
        /*for(Id priFaId: primaryFaIds){
            accts = primaryFA_family.get(priFaId);
            User user = primaryFA_manager.get(priFaId);
            
            if(user.ManagerId != null && user.Manager.Email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.subject = 'Complete Family Interaction';
                mail.toAddresses = new String[]{'shubhangi_badwaik@persistent.com'};  //{user.Manager.Email};
                mail.htmlBody = getEmailBody(accts, user.Manager.Name, mailText);
                mails.add(mail);
        	}
		}*/
        
        for(Id managerId: manager_Account.keySet()){
            accts = manager_Account.get(managerId);
            User user = managerMap.get(managerId);
            
            if(user.ManagerId != null && user.Manager.Email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.subject = 'Complete Family Interaction';
                mail.toAddresses = new String[]{user.Manager.Email}; //{'shubhangi_badwaik@persistent.com'};
                mail.htmlBody = getEmailBody(accts, user.Manager.Name, mailText);
            mails.add(mail);
        }
		}
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }

	public static void sendEmailToHead(List<Account> familyR5, List<User> heads){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String mailText = 'Kindly complete interaction for the Families mentioned below: ';
        
        for(User u : heads){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.subject = 'Complete Family Interaction';
            mail.toAddresses = new String[]{u.Email}; //{'shubhangi_badwaik@persistent.com'}; 
            mail.htmlBody = getEmailBody(familyR5, u.Name, mailText);
            mails.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
    
    public static String getEmailBody(List<Account> accts, String mailTo, String mailText){
       	String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody =  '<p style="font-family:Calibri;">Hi ' + mailTo + ',</br></br>' + mailText +
            				'</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
            				'<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Family Name</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Coverage</th></tr>';
        
        String table;
        for(Account a : accts){
            String acctUrl = baseUrl + '/' + a.Id;
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+acctUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + a.Name + '</a></td>' +
                		 '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + a.Coverage__c + '</td></tr>';
            
            if(table == null)
                table = row;
            else
            	table = table + row;       
		}
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + table + endBody);
    }
}