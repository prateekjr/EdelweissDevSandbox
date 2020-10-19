@isTest
public class TestDataFactory {
    
    public static List<Order_Entry__c> createOrderEntry(){
        List<Order_Entry__c> oeList = new List<Order_Entry__c>();
        Order_Entry__c orderEntry = new Order_Entry__c();
        orderEntry.isReviewed__c = false;
        orderEntry.Status__c = 'Pending For Review';        
        oeList.add(orderEntry);
        insert oeList;
        return oeList;
    }
    
      public static List<Order_Entry__c> createOrderEntryExportAll(){
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
          orderEntry.Status__c = 'Reviewed'; 
          orderEntry.Transaction_Amount_Financial_Transaction__c= '200';
          oeList.add(orderEntry);
          insert oeList;
          return oeList;
    }
    
          public static Order_Entry__c createOrderEntryRecord(){
              
          Order_Entry__c orderEntry = new Order_Entry__c();
          orderEntry.Transaction_Type__c='Purchase';
          orderEntry.scheme_plan_export__c ='Direct';
          orderEntry.Product_Type_Order_Entry__c='MF';
          orderEntry.isReviewed__c = true;
          orderEntry.Folio__c ='55555';
          orderEntry.UCC__c ='5255';
          orderEntry.Transaction_Amount_Export__c='2000';
          orderEntry.OrderEntryMF__c=false;
          orderEntry.Status__c = 'Reviewed'; 
          orderEntry.Transaction_Amount_Financial_Transaction__c= '200';
          orderEntry.End_Date__c =Date.valueOf('2020-06-30');
          orderEntry.Start_Date__c =Date.valueOf('2020-06-22');
          insert orderEntry;

              
		  return orderEntry;
    }
    
      public static IPO_Master__c createIPOMasterRecord(){        
 		
          IPO_Master__c ipo= new IPO_Master__c();
          ipo.Name__c='SBICards';
          ipo.Type__c ='Bond IPO';
          ipo.Code__c ='AIRTELIPO';
          
          insert ipo;
          return ipo;
    }
    
         public static void createCusSettingData(){        
 		
             //Custom Setting Record
             OrderEntrySchem__c setting= new OrderEntrySchem__c(Name='Euindefault', value__c='E331257');
             insert setting;
             
             OrderEntrySchem__c setting1= new OrderEntrySchem__c(Name='HardCuttOffTime', value__c='14.00');
             insert setting1;    
             
             OrderEntrySchem__c setting2= new OrderEntrySchem__c(Name='LiquidCuttoffTime', value__c='12.20');
             insert setting2;  
             
             OrderEntrySchem__c setting3= new OrderEntrySchem__c(Name='NonLiquidCuttoffTime < 2L', value__c='14.50');
             insert setting3; 
             
             
             OrderEntrySchem__c setting4= new OrderEntrySchem__c(Name='NonLiquidCuttoffTime > 2L', value__c='13.20');
             insert setting4; 
             
             
             OrderEntrySchem__c setting5= new OrderEntrySchem__c(Name='SoftCuttOffTime', value__c='13.30');
             insert setting5; 

             
    }
    
    
    
    
    public static User getUserProfile(){        
        User userObj = new User();
        List<Profile> profileObj = [Select Id from Profile Where Name = 'Client Experience Office (CXO)'];
        userObj.ProfileId = profileObj[0].Id;
        userObj.Username = 'rk50@test.com';
        userObj.LastName = 'Test Last Name';
        userObj.Email = 'Test@test.com';
        userObj.Alias ='tst';
        userObj.TimeZoneSidKey ='America/Los_Angeles';
        userObj.LocaleSidKey ='en_IN';
        userObj.EmailEncodingKey ='ISO-8859-1';
        userObj.LanguageLocaleKey ='en_US';
        insert userObj;
        return userObj;
    }
    public static List<Product2> getProduct2(){  
        
        List<RecordsData> recordsDataList = new List<RecordsData>();
        List<Product2> prodList = new List<Product2>();
        Product2 prodObj = new Product2();
        prodObj.Name = 'Prod1';
        prodObj.ISIN__c ='ProdISIN';
        prodObj.Amc_Code__c= 'ProdAMCTest';
        prodObj.Risk_Profile_of_Product__c = 'Aggressive';
        prodList.add(prodObj);
        
        //Insert prodList;
        return prodList;
        
               
    }
    public class RecordsData {
        public String label;
        public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    //Record Creation For Transaction Controller
       public static Account createFamilyRecord() {
           
           Account accRec = new Account();
           accRec.name = 'Test';
           accRec.RecordTypeId =Schema.SObjectType.account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
           accRec.GWM_Online_Id__c = '12345';
           accRec.Pan_Number__c = 'DDMGG7447H';
           insert accRec;
           return accRec;
    }
    public static Account createClientRecord() {
        //Account accRec=TestDataFactory.createFamilyRecord();
        Account accRec1 = new Account();
        accRec1.name = 'Test1'; 
        accRec1.RecordTypeId =Schema.SObjectType.account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        //accRec1.ParentId = accRec.Id;
        //insert accRec1; 
        return accRec1;
    }

    
        public static Pricebook2 createPriceBook() {
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            Update standardPricebook;
            return standardPricebook;
        }
     public static Product2 createProductRecord() {
         
         Product2 prodRec = new Product2();
         prodRec.name = 'test';
         prodRec.ProductCode = 'test1';
         prodRec.Sub_Asset_Class__c = 'Mutual';
         prodRec.Risk_Profile_of_Product__c = 'Conservative';
         prodRec.Sub_Asset_Class__c = 'Mutual';
         prodRec.ISIN__c='123';
         insert prodRec;
         
         Product2 prodRec1 = new Product2();
         prodRec1.name = 'HDFCMutualFund_MF';
         prodRec1.Manufacturer_Name__c='HDFCMutualFund_MF';
         prodRec1.ProductCode = 'test1';
         prodRec1.Sub_Asset_Class__c = 'Mutual';
         prodRec1.Risk_Profile_of_Product__c = 'Conservative';
         prodRec1.Sub_Asset_Class__c = 'Mutual';
         prodRec1.ISIN__c='123';
         insert prodRec1; 
         
         return prodRec;
     }
    
    public static Client_Asset_Information__c createClientAssetInformationRecord()
    {
        Client_Asset_Information__c clientAssRec = new Client_Asset_Information__c();
        //clientAssRec.Client_Account__c = cAccRec.Id;
        clientAssRec.Annual_Record__c = false;
        //clientAssRec.Product__c = prodRec.Id;
        clientAssRec.Folio_Number__c = 'test';
        clientAssRec.Sub_Asset_Class__c = 'Mutual Fund';
        clientAssRec.Amc_Code__c='82';
        clientAssRec.Amc_Name__c ='HDFCMutualFund_MF';
        return clientAssRec;
    }
    
        public static void createUnRelatedRecords()
    {
        Scheme_Mapping__c scheme=new Scheme_Mapping__c();
        scheme.BSEStarAMCCode__c ='HDFCMutualFund_MF';
        scheme.BSEStarAMCName__c ='test';
        scheme.BSEStarSchemeName__c='HDFC EQUITY FUND - DIRECT PLAN - DIVIDEND PAYOUT';
        scheme.MilesAMCCode__c='82';
        scheme.MilesSchemeName__c='HDFC Equity Direct-D';
        insert scheme;
        
        Scheme_Mapping__c sceMapRec = new Scheme_Mapping__c();
        sceMapRec.BSEStarSchemeName__c = 'test';
        sceMapRec.MilesSchemeCode__c = 'test1';
        insert sceMapRec;
        
        Schema_Master__c schemaRec = new Schema_Master__c();
        schemaRec.AMC_Code__c = '12345';
        schemaRec.Purchase_Allowed__c = 'Y';
        schemaRec.scheme_Type__c='LIQUID';
        schemaRec.scheme_name__c='HDFCMutualFund_MF';
        insert schemaRec;
            
       
        Plutus_Family_Details__c familyRec = new Plutus_Family_Details__c();
        familyRec.Family_Code__c = '12345';
        familyRec.Family_Name__c = 'test';
        insert familyRec;
        
        BSE_STAR_UCC__c bseRec = new BSE_STAR_UCC__c();
        bseRec.CLIENT_CODE__c = '12345';
        bseRec.FIRST_APPLICANT_PAN__c = 'DDMGG7447H';
        insert bseRec;
        
        
        FolioToBlock__c folio=new FolioToBlock__c();
        folio.Folio__c='FolioBlock-0001';
        folio.Type__c ='INA000003098';
        insert folio;
        
        EUIN_Master__c euinRec = new EUIN_Master__c();
        euinRec.EMP_Code__c = '12345';
        euinRec.Valid_From__c = '02-Feb-20';
        euinRec.Valid_To__c = '02-Feb-20';
        insert euinRec;
    }
    
    public static Order_Entry__c createOrderEntryCommitment()
    {
        Order_Entry__c orderCommitment = new Order_Entry__c();
        orderCommitment.Transaction_Type__c='Log Commitment';
        orderCommitment.scheme_plan_export__c ='Direct';
        orderCommitment.Product_Type_Order_Entry__c='PE / AIF';
        orderCommitment.Folio__c ='55555';
        orderCommitment.Transaction_Amount_Export__c='2000';
        orderCommitment.OrderEntryMF__c=false;
        orderCommitment.Status__c = 'Reviewed'; 
        orderCommitment.Transaction_Amount_Financial_Transaction__c= '200';
        orderCommitment.End_Date__c =Date.valueOf('2020-06-30');
        orderCommitment.End_Date__c =Date.valueOf('2020-06-22');
        orderCommitment.InternalPEID__c='1234';
        // orderCommitment.Product_lookup__c= prodRec.id;
        orderCommitment.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        //orderCommitment.Client_Account_Display__c =cAccRec.Name;
        return orderCommitment; 
    }
    
    
}