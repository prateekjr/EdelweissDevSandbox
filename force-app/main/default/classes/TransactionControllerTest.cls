@isTest
public class TransactionControllerTest {
   
    
    
    @isTest 
    public static void getClientInformationTest() { 
        
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
        USer userRec = TestDataFactory.getUserProfile();
        userRec.Edelweiss_Employee_Id__c = '12345';
        update userRec;
        
        Corporate_Action_Notification__c corp= new Corporate_Action_Notification__c();
        corp.Name='test';
        insert corp;
        
        List<Account> accList =TransactionController.getClientInformation(accRec.Id);
        System.assertEquals(1, accList.size());
        List<Account> accListBlank =TransactionController.getClientInformation(accRec1.Id);
		System.assertEquals(0, accListBlank.size());
        
        Boolean isfound = TransactionController.getClientInformationorderentery(accRec.Id);
        System.assertEquals(true, isfound);
        
        string formatedDate = TransactionController.getStringsDate();
        System.assertEquals(true, formatedDate!=null);
        
        Date todayDate= TransactionController.getTodaysDate();
		System.assertEquals(system.today(), todayDate);
        
        List<Client_Account__c> clientAccount =TransactionController.getClientAccountInformation(accRec1.Id);
		System.assertEquals(1, clientAccount.size());
        
        List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
        Product2 prod =TransactionController.getProductDetailsFromMappings('test');
		System.assertEquals(true, prod!=null);
        
        TransactionController.getClientAssetInfo(cAccRec.Id,prodRec.Id);
        System.assertEquals(true, prod!=null);
        TransactionController.getClientProducts(cAccRec.Id);
        System.assertEquals(true, prod!=null);
        TransactionController.getProductDetailsFromMappingsOE(prodRec.Id);
        TransactionController.getClientProducts(null);
        TransactionController.getProductDetailsFromMappingsOE(null);
        System.assertEquals(true, prod!=null);
        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject();
        System.assertEquals(true, prod!=null);
        TransactionController.getDependentMap(sObj,'test','test');
        System.assertEquals(true, prod!=null);
        TransactionController.getDependentMap(sObj,'AccountSource','Deal_Type__c');
        System.assertEquals(true, prod!=null);
        TransactionController.decimalToBinary(2);
        TransactionController.base64ToBits('test');
        TransactionController.getAmcCode();
        TransactionController.getSchemeName('test');
        TransactionController.PicklistEntryWrapper Wrapvar = new TransactionController.PicklistEntryWrapper();
        Wrapvar.active = 'true';
        Wrapvar.defaultValue = 'true';
        Wrapvar.value = 'true';

        TransactionController.getClientHoldingInfo('12345');
        TransactionController.getUCCMasterData(accRec.Id);
        TransactionController.getUCCMasterData(accRec1.Id);
        TransactionController.getUCCMasterData(null);

        TransactionController.getSchemeController('12345');
        TransactionController.getSchemeNameRedemption(cAccRec.Id);

        //Order_Entry__c orderEntryRec = TestDataFactory.createOrderEntryRecord();
        Order_Entry__c orderEntryRec = new Order_Entry__c();
        orderEntryRec.Transaction_Type__c='Purchase';
        orderEntryRec.scheme_plan_export__c ='Direct';
        orderEntryRec.Product_Type_Order_Entry__c='MF';
        orderEntryRec.isReviewed__c = true;
        orderEntryRec.Folio__c ='55555';
        orderEntryRec.UCC__c ='5255';
        orderEntryRec.Transaction_Amount_Export__c='2000';
        orderEntryRec.OrderEntryMF__c=false;
        orderEntryRec.Status__c = 'Reviewed'; 
        orderEntryRec.Transaction_Amount_Financial_Transaction__c= '200';
        orderEntryRec.End_Date__c =Date.valueOf('2020-06-30');
        orderEntryRec.Start_Date__c =Date.valueOf('2020-06-22');
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = corp.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert attachment;
        orderEntryRec.AttachmentId__c=attachment.id;

       
        
        /* Creating Log Commitment Record for PE*/
        
                      
        Order_Entry__c orderCommitment = TestDataFactory.createOrderEntryCommitment();
        orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment; 
        
        TransactionController.saveObj(orderEntryRec,true);
        
        orderEntryRec.Transaction_Type__c='Redemption';
        orderEntryRec.Product_lookup__c= prodRec.id;
        orderEntryRec.Family_Name__c =accRec.id;
        orderEntryRec.Client_Name__c= accRec1.id;
        orderEntryRec.Client_Account__c= cAccRec.id;
        update orderEntryRec;
        TransactionController.saveObj(orderEntryRec,true);
        TransactionController.saveObj(orderEntryRec,false);
        
        orderEntryRec.Transaction_Type__c='Switch';
        orderEntryRec.Redemption_Type__c='All Unit';
        update orderEntryRec;
        TransactionController.saveObj(orderEntryRec,true);
        
        orderEntryRec.Redemption_Type__c='Partial Amount';
        update orderEntryRec;
        TransactionController.saveObj(orderEntryRec,false);
        
        orderEntryRec.Redemption_Type__c='Partial Unit';
        update orderEntryRec;
        TransactionController.saveObj(orderEntryRec,false);
        
        
        orderEntryRec.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec.Transaction_Type__c='Log Drawdown';
        orderEntryRec.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec;
        TransactionController.saveObj(orderEntryRec,false);
        
         TransactionController.getEuinDetails(userRec.Id,orderEntryRec);
		IPO_Master__c ipo=TestDataFactory.createIPOMasterRecord();

        TransactionController.setIPOCode('SBICards');
        TransactionController.setClientAccountName(orderEntryRec);
        TransactionController.setFamilyName(orderEntryRec);
        TransactionController.setClientName(orderEntryRec);
        TransactionController.setProductName(orderEntryRec);
        
        TransactionController.getAssetDetailsByFolio(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c, 'Physical', 'test');
        
         Test.startTest();
        
        TransactionController.getFolioNumbers(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c,'Physical');
        TransactionController.getFolioNumbers(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c,'Demat');
        
        TransactionController.getFolioNumbersPurchase(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Physical');
        
        TransactionController.getFolioNumbersPurchase(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Demat');
        
        TransactionController.getFoliosPurchaseForMFOE(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Physical');

        TransactionController.getFoliosPurchaseForMFOE(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Demat');
        
        TransactionController.fetchInstrumentName(orderEntryRec.Id);
        
        
        //TransactionController.fetchProductRiskonISIN('123');
       
        TransactionController.gerAttachementParentId();
        
        TransactionController.getPMSAccountTYpe(orderEntryRec.Client_Account__c);
        
        TransactionController.fetchProductRiskonProductCode('test1');
        
        TransactionController.checkForProfile();
        
        TransactionController.checkCuttOffTime('HDFCMutualFund_MF', true, 2000);
        
         TransactionController.checkCuttOffTime('HDFCMutualFund_MF', false, 2000);
        
        TransactionController.getProductListToSchemeSwitch('HDFCMutualFund_MF', orderEntryRec.id );
        
       
        
        //TransactionControllergetFolioFromAPI(Client_Account__c, '82', 'Physical', );
        
        TransactionController.fetchSellAUAQty(orderEntryRec.Client_Account__c,'test');
        
        TransactionController.getInstrumentName('Buy', orderEntryRec.Client_Account__c );
        
        TransactionController.getInstrumentName('Sell', orderEntryRec.Client_Account__c );
        
        TransactionController.getCurrentTime();
        
        Id attch=TransactionController.saveTheFile(corp.id, 'test', 'test', 'test');
        
        TransactionController.appendToFile(attch, 'test');
        
        TransactionController.saveChunk(corp.id, 'test', 'test', 'test', attch);
        
        TransactionController.fetchProductRiskonProductName('test');
        
        TransactionController.getProductListMFOrderEntry('HDFCMutualFund_MF');
        
        TransactionController.getProductListMFOrderEntryRedemptionSwitch('HDFCMutualFund_MF',orderEntryRec.Client_Account__c );
        
        TransactionController.getFolioPMS(orderEntryRec.Client_Account__c, 'test1');

        Test.stopTest();

    }
    
       @isTest 
    public static void apiTest() { 
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
        
     	 TestDataFactory.createUnRelatedRecords();

        
        Order_Entry__c orderCommitment = TestDataFactory.createOrderEntryCommitment();
        orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment; 
        
        Order_Entry__c orderEntryRec1 = TestDataFactory.createOrderEntryRecord();
        orderEntryRec1.Client_Account__c=cAccRec.id;
        update orderEntryRec1;
        
        Order_Entry__c orderEntryRec = TestDataFactory.createOrderEntryRecord();
        orderEntryRec.Product_lookup__c= prodRec.id;
        orderEntryRec.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec.Client_Account__c=cAccRec.id;
        orderEntryRec.Transaction_Type__c='Log Drawdown';
        orderEntryRec.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TransactionController.getDrawdownData(orderEntryRec);  
        test.stopTest();
    }
    
       @isTest 
    public static void apiTestFolio() { 
        
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
        
        TestDataFactory.createUnRelatedRecords();

        
        Order_Entry__c orderCommitment = TestDataFactory.createOrderEntryCommitment();
        orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment; 
        
        Order_Entry__c orderEntryRec1 = TestDataFactory.createOrderEntryRecord();
        orderEntryRec1.Client_Account__c=cAccRec.id;
        update orderEntryRec1;
        
        Order_Entry__c orderEntryRec = TestDataFactory.createOrderEntryRecord();
        orderEntryRec.Product_lookup__c= prodRec.id;
        orderEntryRec.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec.Client_Account__c=cAccRec.id;
        orderEntryRec.Transaction_Type__c='Log Drawdown';
        orderEntryRec.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        TransactionController.getFolioFromAPI(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Physical','Purchase', 'HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT', '');
        test.stopTest();
    }
    
        @isTest 
    public static void apiTestFolioHolding() { 
        
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
        
     	 TestDataFactory.createUnRelatedRecords();

        
        Order_Entry__c orderCommitment = TestDataFactory.createOrderEntryCommitment();
        orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment; 
        
        Order_Entry__c orderEntryRec1 = TestDataFactory.createOrderEntryRecord();
        orderEntryRec1.Client_Account__c=cAccRec.id;

        update orderEntryRec1;
        
        Order_Entry__c orderEntryRec = TestDataFactory.createOrderEntryRecord();
        orderEntryRec.Product_lookup__c= prodRec.id;
        orderEntryRec.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec.Client_Account__c=cAccRec.id;
        orderEntryRec.Transaction_Type__c='Log Drawdown';
        orderEntryRec.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        list<string> folioList=new List<string>{'11348', '9102384536'};
        TransactionController.getHoldingFromAPI(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Physical','Redemption', 'HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT', '');
        TransactionController.folioEligibilityCheck(folioList,orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Demat','Purchase');
        test.stopTest();
    }
}