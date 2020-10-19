@isTest(SeeAllData = true)
public class ProductTriggerHandlerTest {


   static void setup(){
       
        List<Product2> products = new List<Product2>();
        for(Integer i = 1; i <= 100; i++){
            Product2 p = new Product2(
                        Name = 'Test Product ' + i,
                        ProductCode = 'testprod' + i,
                        IsActive = Math.mod(i, 2) == 0 ? true : false);
            products.add(p); 
        }
        insert products;

        Id stdPriceBook = Test.getStandardPriceBookId();
        
        /*List<PricebookEntry> entries = new List<PricebookEntry>();
        for(Integer i = 1; i <= 100; i++){
            PricebookEntry entry = new PriceBookEntry(
                                   PriceBook2Id = stdPriceBook,
                                   Product2Id = products[i].Id,
                                   //UseStandardPrice = false,
                                   //CurrencyIsoCode = 'INR',
                                   UnitPrice = 1000.00 + i*10);
            entries.add(entry);
        }
        insert entries; */
     }
    
    static testMethod void testSetStandardPrice(){
        ProductTriggerHandlerTest.setup();
       
        List<Product2> products = [SELECT Name, IsActive FROM Product2  LIMIT 1000];
        
        Id stdPriceBook = Test.getStandardPriceBookId();
        List<PricebookEntry> entries = [SELECT PriceBook2Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE PriceBook2Id =: stdPriceBook AND Product2Id IN :products ORDER BY Product2Id Limit 100];
        
        Integer i = 1;
        for(PricebookEntry e : entries){
            //System.assertEquals(1000.00 + i*10 , e.UnitPrice, 'Unit Price not updated.');    
        }
        
    }

}