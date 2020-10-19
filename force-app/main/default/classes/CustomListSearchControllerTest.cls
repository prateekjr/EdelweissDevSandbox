@isTest
private class CustomListSearchControllerTest {
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    @isTest
    private static void fetchRecordsAMCTest(){
        Pricebook2 priceBook2 = new Pricebook2(IsActive=true, id=Test.getStandardPricebookId());
        update priceBook2;
        List<Product2> prodList = TestDataFactory.getProduct2();
        insert prodList;
       /* PriceBookEntry priceBook = new PriceBookEntry();
        priceBook.IsActive = prodList[0].IsActive;
        priceBook.UnitPrice = 0.0;
        priceBook.Pricebook2Id = priceBook2.Id;
        priceBook.Product2ID = prodList[0].Id;
        insert priceBook; */
        Order_Entry__c oe = new Order_Entry__c();
        CustomListSearchController.fetchRecords('Product2','AMC_Code__c','','','','',String.valueOf(prodList[0].Id),oe,'','Equity IPO','Client');
    }
    
      @isTest
    private static void fetchRecordsproductISINTest(){
        Pricebook2 priceBook2 = new Pricebook2(IsActive=true, id=Test.getStandardPricebookId());
        update priceBook2;
        List<Product2> prodList = TestDataFactory.getProduct2();
        prodList[0].Sub_Asset_Class__c='Bonds (Others)';
        insert prodList;
       /* PriceBookEntry priceBook = new PriceBookEntry();
        priceBook.IsActive = prodList[0].IsActive;
        priceBook.UnitPrice = 0.0;
        priceBook.Pricebook2Id = priceBook2.Id;
        priceBook.Product2ID = prodList[0].Id;
        insert priceBook; */
        List<Order_Entry__c> oe = TestDataFactory.createOrderEntry();
        oe[0].Product_Type_Order_Entry__c ='Bond'; 
        oe[0].Transaction_Type__c ='Buy';  
        oe[0].Face_Value__c =20; 
        update oe;  
        CustomListSearchController.fetchRecords('Product2','productISIN__c','','','','',String.valueOf(prodList[0].Id),oe[0],'','Equity IPO','Client');
    }
    
}