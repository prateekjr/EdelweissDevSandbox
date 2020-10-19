@istest
private class Edelweiss_batchUpdateFamilyAUMTest{
        
        static testmethod void testBatchwithRecord(){
        
        
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
                
                Edelweiss_batchUpdateFamilyAUM eBatchAUM = new Edelweiss_batchUpdateFamilyAUM();

        
                Test.startTest();
                
                Database.executeBatch(eBatchAUM);
             Test.stopTest();
             
        }
        
        static testmethod void testBatchWithNoRecords(){
        
        Id recordTypeId = [select Id from RecordType where Name='Family'][0].ID;
        TestClassUtils.LoadMeetingFrequency();
        
                Account a1 = new Account();
                a1.Name='TestAccount';
                a1.RecordTypeID= recordTypeId ;
                a1.GWM_Online_Id__c='500';
                
                Account a2 = new Account();
                a2.Name='TestAccount';
                a2.RecordTypeID = recordTypeId ;
                a2.GWM_Online_Id__c='5000';
                
                List<Account> alist = new List<Account>();
                alist.add(a1);
                alist.add(a2);
                insert alist;
                
                
                Edelweiss_batchUpdateFamilyAUM eBatchAUM = new Edelweiss_batchUpdateFamilyAUM();
                //eBatchAUM.mapFamilyRecord = new Map<Id,Account>();                
                Test.startTest();
                Database.executeBatch(eBatchAUM);
                Test.stopTest();
        
        }


}