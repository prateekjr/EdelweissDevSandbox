@istest
public with sharing class AccountTriggerhandlerTest {

  
    public testmethod static  void TestAccountinsert()
    {
        Test.startTest();
        
        Account pa=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        pa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family'); 
       pa.In_Person_Meeting_End_Date__c=Date.today();
        insert pa;

        Account ca=TestClassUtils.createAccount();
        ca.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        ca.ParentId=pa.Id;
        AccountTriggerhandler.stopUpdatefamily=false;
        ca.Asset_Classes_Client_is_Interested_in__c='Equity-PMS;Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt;Bonds;Structured Products - Debt';
        insert ca;
             
        ca.Asset_Classes_Client_is_Interested_in__c='Equity-PMS;Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt;Bonds;Structured Products - Debt;Warrants - Direct Debt;Mutual Funds - Balanced';
        AccountTriggerhandler.stopUpdatefamily=false;
        update ca;
      
        TestClassutils.LoadMeetingFrequency();        
        pa.Coverage__c='R3';
        pa.Rollup_AUM_of_Family__c=20;
        pa.setInPersonDueDateRegular__c=true;
        pa.setInPersonEndDateRegular__c=true;
        AccountTriggerhandler.stopAccountTrigger=false;
        update ca;
        update pa;
        
        pa.Coverage__c='R4';
        pa.Rollup_AUM_of_Family__c=70;
        pa.setInPersonDueDateRegular__c=true;
        pa.setInPersonEndDateRegular__c=true;
        pa.InPersonMeeting_Due_Date__c=Date.today();
        pa.In_Person_Meeting_End_Date__c=Date.today();
        pa.Communication_Criteria_Number__c=20;
        pa.In_Person_Meeting_Done__c=true;
        pa.setRH_BHEndDateRegular__c=true;
        pa.setRH_BHDueDateRegular__c=true;
        pa.setPortfolioDueDateRegular__c=true;
        pa.setPortfolioEndDateRegular__c=true;
        pa.Portfolio_Review_Done__c=true;
        AccountTriggerhandler.stopAccountTrigger=false;
        
        update ca;
        update pa;
        
        pa.Coverage__c='R3';
        pa.Rollup_AUM_of_Family__c=10;
        AccountTriggerhandler.stopAccountTrigger=false;
        update ca;
        update pa;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Financial Advisor'];
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Client Experience Office (CXO)'];
        
        User manager= new User(
        Alias = 'standmgr',
        Email='standardusermgr@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='Test990mgr@testorg.hr',
        isActive = true
        );
        insert manager;
        
        User fausr= new User(
        Alias = 'standt',
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='Test990@testorg.hr',
        isActive = true
        );

        User csousr= new User(
        Alias = 'standt',
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p2.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='Test2990@testorg.hr',
        isActive = true,
        ManagerId = manager.Id
        );
        
        insert csousr;   
        insert fausr;
        
        FA_CSO_Mapping__c facso=new FA_CSO_Mapping__c();
        facso.Is_Mapped_CXO__c=true;
        facso.CSO_User__c=csousr.id;
        facso.FA_User__c=fausr.Id;         
        insert facso;
        Test.stopTest();
        
        pa.ownerId  = fausr.id;
        pa.Primary_FA__c  = fausr.id;
        pa.Primary_CXO__c  = csousr.id;
        AccountTriggerhandler.stopAccountTrigger = true;
        AccountTriggerhandler.stopUpdatefamily = true;
        AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
       // Update pa;
        
        System.runAs(fausr){
            Event event1 = new Event(
                WhatId = pa.Id,
                StartDateTime = DateTime.Now().addDays(-2),
                EndDateTime = DateTime.Now().addDays(-1),
                Subject = 'Intraction family',
                Type_of_Communication__c = 'In-Person',
                Agenda__c = 'Portfolio Review',
                Description = 'test'
            );
            system.debug('event=='+event1);
           // insert event1 ;
        }
    }
    public testmethod static void updateClientAssetCountTest(){
        Account pa=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        pa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family'); 
       pa.In_Person_Meeting_End_Date__c=Date.today();
        insert pa;

        Account ca=TestClassUtils.createAccount();
        ca.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        ca.ParentId=pa.Id;
        AccountTriggerhandler.stopUpdatefamily=false;
        ca.Asset_Classes_Client_is_Interested_in__c='Equity-PMS;Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt;Bonds;Structured Products - Debt';
        insert ca;
             
        ca.Asset_Classes_Client_is_Interested_in__c='Equity-PMS;Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt;Bonds;Structured Products - Debt;Warrants - Direct Debt;Mutual Funds - Balanced';
        AccountTriggerhandler.stopUpdatefamily=false;
        update ca;
        
        Map<Id, Account> accountMap= new Map<Id, Account>();
        accountMap.put(pa.id, pa);
      //  AccountTriggerHandler handlerObj= new AccountTriggerHandler();
        List<Account> accountList= new List<Account>();
        accountList.add(pa);
        Test.startTest();
        AccountTriggerHandler.upadateClientAssetCount(accountList, accountMap, true);
    	Test.stopTest();
    }

}