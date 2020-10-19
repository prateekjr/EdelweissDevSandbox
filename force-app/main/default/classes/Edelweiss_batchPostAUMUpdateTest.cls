@istest
private class Edelweiss_batchPostAUMUpdateTest{
        
        static testmethod void testBatchwithRecord(){
        
                testClassUtils.LoadMeetingFrequency();
        
                Account a=new Account();
                a.Name='TestAccount1';
                AccountTriggerhandler.stopUpdatefamily=false;
                a.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family');
                a.Investible_Assets__c=200000000;
                a.Coverage__c='R5';
                a.InPersonMeeting_Due_Date__c=Date.today()+9;
                a.In_Person_Meeting_End_Date__c=Date.today()+15;
                a.Asset_Classes_Client_is_Interested_in__c='Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt';
                insert a;
        
     
                Account aa=new Account();
                aa.Name='TestAccount2';
                AccountTriggerhandler.stopUpdatefamily=false;
                aa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
                aa.Asset_Classes_Client_is_Interested_in__c='Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt';
                aa.ParentId=a.Id;
                aa.Investible_Assets__c=200000000;
                aa.Coverage__c='R5';   
                insert aa;
 
                Client_Account__c c1=new Client_Account__c();
                c1.Client__c=aa.Id; 
                c1.Name='Client1';
                
                Client_Account__c c2=new Client_Account__c();
                c2.Client__c=a.Id; 
                c2.Name='Client2';
                   
                List<Client_Account__c> clist = new List<Client_Account__c>();
                
                clist.add(c1);
                clist.add(c2);
                insert clist;
                
                List<Client_Asset_Information__c> calist = new List<Client_Asset_Information__c>();
       
                Client_Asset_Information__c obj1=new Client_Asset_Information__c();
                obj1.Family__c=a.Id;
                obj1.Client_Account__c=c1.id;
                obj1.Total_AUM__c=5000000;
                obj1.Asset_Class__c='Alternatives';
                
                Client_Asset_Information__c obj2=new Client_Asset_Information__c();
                obj2.Family__c=aa.Id;
                obj2.Client_Account__c=c2.id;
                obj2.Total_AUM__c=50000;
                obj2.Asset_Class__c='Equity';
                
                calist.add(obj1);
                calist.add(obj2);
                insert calist;
                
                Edelweiss_batchPostAUMFamilyUpdate eBatchAUM = new Edelweiss_batchPostAUMFamilyUpdate();

        
                Test.startTest();
                
                Database.executeBatch(eBatchAUM);
             Test.stopTest();
             
        }
        
        


}