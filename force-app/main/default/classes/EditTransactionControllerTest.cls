@isTest 
public class EditTransactionControllerTest {
    
    @isTest 
    public static void getClientInformationTest() { 
        
       //Family
        Account accRec =TestDataFactory.createFamilyRecord();
        
         //Client
        Account accRec1 = TestDataFactory.createClientRecord();
        accRec1.ParentId=  accRec.Id;
        insert accRec1;
        
       //Client Account
        Client_Account__c cAccRec = new Client_Account__c();
        cAccRec.Client__c = accRec1.Id;
        cAccRec.name = 'Test';
        insert cAccRec;
        
         Pricebook2 standardPricebook = TestDataFactory.createPriceBook();
        
        EditTransactionController.getClientInformation(accRec.Id);
        EditTransactionController.getClientInformation(accRec1.Id);
       
        Scheme_Mapping__c sceMapRec = new Scheme_Mapping__c();
        sceMapRec.BSEStarSchemeName__c = 'test';
        sceMapRec.MilesSchemeCode__c = 'test1';
        insert sceMapRec;
        
        EditTransactionController.getClientInformation(accRec.Id);
        EditTransactionController.getStringsDate();
        EditTransactionController.getTodaysDate();
        EditTransactionController.getAllFamilies();
        
        
        EditTransactionController.getClientAccountInformation(accRec.Id);
        
        Product2 prodRec = TestDataFactory.createProductRecord();
        
        Client_Asset_Information__c clientAssRec = TestDataFactory.createClientAssetInformationRecord();
        clientAssRec.Client_Account__c = cAccRec.Id;
        clientAssRec.Product__c = prodRec.Id;
        insert clientAssRec;
        
        Scheme_Mapping__c scheme=new Scheme_Mapping__c();
        scheme.BSEStarAMCCode__c ='HDFCMutualFund_MF';
        scheme.BSEStarAMCName__c ='test';
        scheme.BSEStarSchemeName__c='HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT';
        scheme.MilesAMCCode__c='82';
        scheme.MilesSchemeName__c='HDFC Equity Direct-D';
        insert scheme;
        
        Corporate_Action_Notification__c corp= new Corporate_Action_Notification__c();
        corp.Name='test';
        insert corp;
        
        EditTransactionController.getClientAssetInfo(cAccRec.Id,prodRec.Id);
        EditTransactionController.getClientProducts(cAccRec.Id);
        EditTransactionController.getClientProducts(cAccRec.Id);
        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        EditTransactionController.getDependentMap(sObj,'test','test');
        EditTransactionController.getDependentMap(sObj,'AccountSource','Deal_Type__c');
        EditTransactionController.decimalToBinary(2);
        EditTransactionController.base64ToBits('test');
        EditTransactionController.getAmcCode();
        EditTransactionController.getSchemeName('test');
        EditTransactionController.PicklistEntryWrapper Wrapvar = new EditTransactionController.PicklistEntryWrapper();
        Wrapvar.active = 'true';
        Wrapvar.defaultValue = 'true';
        Wrapvar.value = 'true';
        BSE_STAR_UCC__c bseRec = new BSE_STAR_UCC__c();
        bseRec.CLIENT_CODE__c = '12345';
        bseRec.FIRST_APPLICANT_PAN__c = 'DDMGG7447H';
        insert bseRec;
        EditTransactionController.getClientHoldingInfo('12345');
        EditTransactionController.getUCCMasterData(accRec.Id);
        EditTransactionController.getUCCMasterData(accRec1.Id);
        EditTransactionController.getUCCMasterData(null);
        EditTransactionController.getFolioPMS(clientAssRec.Id, 'test1');
        //EditTransactionController.getPMSAccountTYpe(clientAssRec.Id);
        EditTransactionController.gerAttachementParentId();
        
        Schema_Master__c schemaRec = new Schema_Master__c();
        schemaRec.AMC_Code__c = '12345';
        schemaRec.Purchase_Allowed__c = 'Y';
        EditTransactionController.getSchemeController('12345');
        EditTransactionController.getSchemeNameRedemption(cAccRec.Id);
        
        USer userRec = TestDataFactory.getUserProfile();
        userRec.Edelweiss_Employee_Id__c = '12345';
        update userRec;
        
         Order_Entry__c orderEntryRec = TestDataFactory.createOrderEntryRecord();
       
        EUIN_Master__c euinRec = new EUIN_Master__c();
        euinRec.EMP_Code__c = '12345';
        euinRec.Valid_From__c = '02-Feb-20';
        euinRec.Valid_To__c = '02-Feb-20';
        insert euinRec;
        
       EditTransactionController.getEuinDetails(userRec.Id);
       EditTransactionController.getRecordTypeId('Bond','Buy');
       EditTransactionController.getRecordTypeId('PE / AIF','Log Drawdown');
       //EditTransactionController.getRecordTypeId('abcd','Bond');
       //EditTransactionController.getRecordTypeId('','');
       EditTransactionController.checkForProfile();
        
        
       	Order_Entry__c orderCommitment = TestDataFactory.createOrderEntryCommitment();
        orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment;
        
        Order_Entry__c orderEntry = new Order_Entry__c();
          orderEntry.Transaction_Type__c='Purchase';
          orderEntry.scheme_plan_export__c ='Direct';
          orderEntry.Product_Type_Order_Entry__c='MF';
          orderEntry.isReviewed__c = false;
          orderEntry.Folio__c ='55555';
          orderEntry.UCC__c ='5255';
          orderEntry.Transaction_Amount_Export__c='2000';
          orderEntry.OrderEntryMF__c=false;
          orderEntry.Status__c = 'Reviewed'; 
          orderEntry.Transaction_Amount_Financial_Transaction__c= '200';
          orderEntry.End_Date__c =Date.valueOf('2020-06-30');
          orderEntry.Start_Date__c =Date.valueOf('2020-06-22');
          insert orderEntry;
        
        test.startTest();
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        EditTransactionController.getOrderEntryRec(orderEntry.Id);
        //EditTransactionController.getOrderEntryRecTemp(orderEntry.Id);
        
        orderEntryRec.Transaction_Type__c='Redemption';
        orderEntryRec.Product_lookup__c= prodRec.id;
        orderEntryRec.Family_Name__c =accRec.id;
        orderEntryRec.Client_Name__c= accRec1.id;
        orderEntryRec.Client_Account__c= cAccRec.id;
        update orderEntryRec;
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        EditTransactionController.setFamilyName(orderEntryRec);
        EditTransactionController.setClientName(orderEntryRec);
        EditTransactionController.setClientAccountName(orderEntryRec);
        EditTransactionController.setProductName(orderEntryRec);
        EditTransactionController.fetchProductRiskonProductCode('test1');
        
        orderEntryRec.Transaction_Type__c='Switch';
        orderEntryRec.Redemption_Type__c='All Unit';
        update orderEntryRec;
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        EditTransactionController.getAssetDetailsByFolio(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c, 'Physical', 'test');
        EditTransactionController.getFolioNumbers(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c,'Physical');
        EditTransactionController.getFolioNumbers(orderEntryRec.Client_Account__c, orderEntryRec.Product_lookup__c,'Demat');
        EditTransactionController.getFolioNumbersPurchase(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Physical');
        
        EditTransactionController.getFolioNumbersPurchase(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF','Demat');
        //EditTransactionController.getFolioFromAPI(Client_Account__c, '82', 'Physical' );
       
        
        
        orderEntryRec.Redemption_Type__c='Partial Amount';
        update orderEntryRec;
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        
        orderEntryRec.Redemption_Type__c='Partial Unit';
        update orderEntryRec;
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        
        
        orderEntryRec.Product_Type_Order_Entry__c='PE / AIF';
        orderEntryRec.Transaction_Type__c='Log Drawdown';
        orderEntryRec.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        update orderEntryRec;
        EditTransactionController.saveObj(orderEntryRec,orderentryRec.Id);
        
        Id attch=EditTransactionController.saveTheFile(corp.id, 'test', 'test', 'test');
        
        EditTransactionController.appendToFile(attch, 'test');
        
        EditTransactionController.saveChunk(corp.id, 'test', 'test', 'test', attch);
        
        test.stopTest();
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
       // EditTransactionController.getDrawdownData(orderEntryRec);  
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
        
        EditTransactionController.getFolioFromAPI(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Physical','Purchase', 'HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT', '');
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
        EditTransactionController.getHoldingFromAPI(orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Physical','Redemption', 'HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT', '');
        EditTransactionController.folioEligibilityCheck(folioList,orderEntryRec.Client_Account__c, 'HDFCMutualFund_MF', 'Demat','Purchase');
        test.stopTest();
    }
    
}