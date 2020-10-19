@isTest(SeeAllData = false)
public class UtilityActionLightningTest {

    @testSetup
    static void setup(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        TestClassUtils.InsertSysProperties();
        List<Account> accts = new List<Account>();
        for(Integer i = 1; i <= 4; i++){
            Account a = new Account(
                        Name = 'Test Account ' + i,
                		RecordTypeId = recordTypeID);
            accts.add(a);
        }
        insert accts;
        
        List<Contact> conts = new List<Contact>();
        for(Integer i = 1; i <= 8; i++){
            Contact c = new Contact(
                        LastName = 'Test Contact ' + i,
                        AccountId = accts[Math.mod(i, 4)].Id);
            conts.add(c);
        }
        insert conts;
        
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 1; i <= 3; i++){
            Opportunity o = new Opportunity(
                            Name = 'Test Opportunity ' + i,
                            AccountId = accts[i-1].Id,
                            StageName = 'Ongoing',
                            //Scrip_Name__c = products[i-1].Id,
                            //Actual_AUA_Size_INR_Lakhs__c = 100,
                            CloseDate = System.today().addDays(15));
            opps.add(o);
        }
        insert opps;
        
        recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Exchange Account Opening').getRecordTypeId();
        
        List<Case> cases = new List<Case>();
        for(Integer i = 1; i <= 3; i++){
            Case c = new Case(
                     AccountId = accts[i-1].Id,
                     Priority = 'High',
                     Status = 'In Progress',
                     Contacted_By__c = 'CSO',
                     LOB__c = 'GWM',
                     Product_Type__c = 'Demat Only');
            cases.add(c);
        }
        insert cases;
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 1; i <= 2; i++){
            Lead l = new Lead(
                     LastName = 'Test Lead ' + i,
            		 Company = 'Test Company',
            		 Email = 'test_lead' + i + '@company.com');
            leads.add(l);
        }
        insert leads;
        
        List<Event> events = new List<Event>();
        for(Integer i = 1; i <= 10; i++){
            Event e = new Event(
                      Subject = 'Test Event ' + i,
                      Description = 'This is event\'s description ' + i,
                      Key_Deliverables_Information__c = 'Key Deliverables for Event ' + i,
                      Next_Step__c = 'Next Step for Event ' + i,
                	  ActivityDateTime = Date.newInstance(2018, 05, 02),
            		  DurationInMinutes	= 120 + i*10);
            events.add(e);
        }
        
        for(Integer i = 0; i <= 2; i++){
            events[i].WhatId = opps[i].Id;
            events[i].WhoId = conts[i].Id;
        }        
        
        for(Integer i = 3; i <= 5; i++){
            events[i].WhatId = cases[i-3].Id;
            events[i].WhoId = conts[i].Id;
        }        

        for(Integer i = 6; i <= 7; i++){
            events[i].WhatId = accts[i-5].Id;
            events[i].WhoId = conts[i].Id;
        }        

        /*for(Integer i = 8; i <= 9; i++){
            events[i].WhatId = accts[i-8].Id;
            events[i].WhoId = leads[i-8].Id;
        }*/         
        insert events;
    }
    
    static testmethod void testSendEmail(){
        List<Event> events = [SELECT Subject, Description, Key_Deliverables_Information__c, Next_Step__c, WhatId, WhoId FROM Event];
        String baseUrl = '/_ui/core/email/author/EmailAuthor?p3_lkid=';
        
        Test.startTest();
        TestClassUtils.InsertSysProperties();
        for(Event e : events){
            String expectedUrl;
            String url = UtilityActionLighting.sendEmail(e.Id);
            if(url != null){
            	if(e.WhoId != NULL && e.WhoId.getSObjectType() == Lead.sObjectType){
                    expectedUrl = baseUrl + e.WhoId + '&retURL=' + e.WhoId; 
                }else
                    expectedUrl = baseUrl + e.WhatId + '&retURL=' + e.WhatId;
                expectedUrl = expectedUrl + '&p23=' + e.Description + '&p6=' + e.Subject;
                
                System.assertEquals(expectedUrl, url, 'Invalid URL returned.');
    		}
		}
        Test.stopTest();
    }
}