@isTest//(SeeAllData=true)


public class TransactionInquireControlleristest {
    
    public  static testMethod void validateHelloWorld() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'lumi', Email='Luminex@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='Luminex@testerorg.com',Miles_Id__c = '');
        insert u;
        
        System.runAs(u) {
            /*
Account accRec = new Account();
accRec.name = 'Test';
accRec.GWM_Online_Id__c = '12345';
accRec.Pan_Number__c = 'DDMGG7447H';
insert accRec;
Account accRec1 = new Account();
accRec1.name = 'Test1'; 
accRec1.ParentId = accRec.Id;
insert accRec1; 

Contact conOne = new Contact(LastName = 'Test Contact LName One', AccountId = accRec.Id);
insert conOne;

Plutus_Family_Details__c familyRec = new Plutus_Family_Details__c();
familyRec.Family_Code__c = '12345';
familyRec.Family_Name__c = 'test';
insert familyRec;

TestDataFactory.createPriceBook();
Product2 prodRec = new Product2();
prodRec.name = 'test';
prodRec.ProductCode = 'test1';
prodRec.Sub_Asset_Class__c = 'Mutual';
prodRec.Risk_Profile_of_Product__c = 'Conservative';
prodRec.Sub_Asset_Class__c = 'Mutual';
insert prodRec;

Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co' );
insert objLead;


Client_Account__c clientacc = new Client_Account__c(Name = 'test client account',	Client__c = accRec.id);
insert clientacc ;


List<Order_Entry__c> oeList = new List<Order_Entry__c>();
Order_Entry__c orderEntry = new Order_Entry__c();
orderEntry.Transaction_Type__c='Purchase';
orderEntry.scheme_plan_export__c ='Direct';
orderEntry.Product_Type_Order_Entry__c='MF';
orderEntry.isReviewed__c = true;
orderEntry.Folio__c ='55555';
orderEntry.UCC__c ='5255';
orderEntry.Transaction_Amount_Export__c='2000';
orderEntry.OrderEntryMF__c=false;
orderEntry.Status__c = 'Completed'; 
orderEntry.Face_Value__c=200;	
orderEntry.Transaction_Amount_Financial_Transaction__c= '200';
oeList.add(orderEntry);

Order_Entry__c orderEntrystp = new Order_Entry__c();
orderEntrystp.Transaction_Type__c='STP';
orderEntrystp.scheme_plan_export__c ='Direct';
orderEntrystp.Product_Type_Order_Entry__c='MF';
orderEntrystp.isReviewed__c = true;
orderEntrystp.Folio__c ='55555';
orderEntrystp.Face_Value__c=200;
orderEntrystp.Transaction_Amount_Export__c='2000';
orderEntrystp.OrderEntryMF__c=true;
orderEntrystp.Status__c = 'Completed'; 
orderEntrystp.Transaction_Amount_Financial_Transaction__c= '200';
oeList.add(orderEntrystp);


Order_Entry__c orderEntryIPO = new Order_Entry__c();
orderEntryIPO.Transaction_Type__c='Bond IPO';
orderEntryIPO.scheme_plan_export__c ='Direct';
orderEntryIPO.Product_Type_Order_Entry__c='IPO';
orderEntryIPO.isReviewed__c = true;         
orderEntryIPO.Status__c = 'Completed'; 
orderEntryIPO.IPO_Application_Number__c= '200';
orderEntryIPO.Cut_Off_Price__c= '20000';
orderEntryIPO.Face_Value__c=200;

oeList.add(orderEntryIPO);

Order_Entry__c orderEntryBond = new Order_Entry__c();
orderEntryBond.Transaction_Type__c='Sell';
orderEntryBond.Family_Name__c =accRec.id;
orderEntryBond.Product_Type_Order_Entry__c='BOND';
orderEntryBond.isReviewed__c = true;         
orderEntryBond.Status__c = 'Completed'; 
orderEntryBond.Payment_Mode__c= '';
orderEntryBond.Face_Value__c=200;
//orderEntryBond.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();

oeList.add(orderEntryBond);
insert oeList;

*/
            
            //Family
            Account accRec =TestDataFactory.createFamilyRecord();
            
            //Client
            Account accRec1 = TestDataFactory.createClientRecord();
            accRec1.ParentId=  accRec.Id;
            insert accRec1;
            
            Pricebook2 standardPricebook = TestDataFactory.createPriceBook();
            
            //Client Account
            Client_Account__c cAccRec = new Client_Account__c();
            cAccRec.Client__c = accRec1.Id;
            cAccRec.name = 'Test';
            insert cAccRec;
            
            Product2 prodRec = TestDataFactory.createProductRecord();       
            
            Client_Asset_Information__c clientAssRec = TestDataFactory.createClientAssetInformationRecord();
            clientAssRec.Client_Account__c = cAccRec.Id;
            clientAssRec.Product__c = prodRec.Id;
            insert clientAssRec;
            
            
            
            TestDataFactory.createCusSettingData();
            TestDataFactory.createUnRelatedRecords();
            Order_Entry__c orderEntryRec = new Order_Entry__c();
            orderEntryRec.Transaction_Type__c='Purchase';
            orderEntryRec.scheme_plan_export__c ='Direct';
            orderEntryRec.Product_Type_Order_Entry__c='MF';
            orderEntryRec.isReviewed__c = true;
            orderEntryRec.Folio__c ='55555';
            orderEntryRec.UCC__c ='5255';
            orderEntryRec.Transaction_Amount_Export__c='2000';
            orderEntryRec.OrderEntryMF__c=false;
            orderEntryRec.Status__c = 'Completed'; 
            orderEntryRec.Transaction_Amount_Financial_Transaction__c= '200';
            orderEntryRec.End_Date__c =Date.valueOf('2020-06-30');
            orderEntryRec.Start_Date__c =Date.valueOf('2020-06-22');
            
            insert orderEntryRec;
            
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            TransactionInquireController.callForApi(orderEntryRec.Id);
            
            
            test.stopTest();
            
        }
    }
    
    public  static testMethod void validateIPOInquireAPI() {
        
        
        Order_Entry__c orderEntryRec1 = new Order_Entry__c();
        orderEntryRec1.Transaction_Type__c='Equity IPO';
        orderEntryRec1.scheme_plan_export__c ='Direct';
        orderEntryRec1.Product_Type_Order_Entry__c='IPO';
        orderEntryRec1.isReviewed__c = true;
        orderEntryRec1.Folio__c ='55555';
        orderEntryRec1.UCC__c ='5255';
        orderEntryRec1.Transaction_Amount_Export__c='2000';
        orderEntryRec1.OrderEntryMF__c=false;
        orderEntryRec1.Status__c = 'Completed'; 
        orderEntryRec1.Transaction_Amount_Financial_Transaction__c= '200';
        orderEntryRec1.End_Date__c =Date.valueOf('2020-06-30');
        orderEntryRec1.Start_Date__c =Date.valueOf('2020-06-22');
        
        insert orderEntryRec1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TransactionInquireController.callForApi(orderEntryRec1.Id);
        test.stopTest();
        
    }
    
    public  static testMethod void validatePEInquireAPI() {
        
                    
            //Family
            Account accRec =TestDataFactory.createFamilyRecord();
            
            //Client
            Account accRec1 = TestDataFactory.createClientRecord();
            accRec1.ParentId=  accRec.Id;
            insert accRec1;
            
            Pricebook2 standardPricebook = TestDataFactory.createPriceBook();
            
            //Client Account
            Client_Account__c cAccRec = new Client_Account__c();
            cAccRec.Client__c = accRec1.Id;
            cAccRec.name = 'Test';
            insert cAccRec;
            
            Product2 prodRec = TestDataFactory.createProductRecord();   
        
        
        Order_Entry__c orderEntryRec2 = TestDataFactory.createOrderEntryRecord();
        orderEntryRec2.Product_lookup__c= prodRec.id;
        orderEntryRec2.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec2.Client_Account__c=cAccRec.id;
        orderEntryRec2.Status__c = 'Completed';
        orderEntryRec2.Transaction_Type__c='Log Drawdown';
        orderEntryRec2.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec2;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TransactionInquireController.callForApi(orderEntryRec2.Id);
        test.stopTest();
        
    }
}