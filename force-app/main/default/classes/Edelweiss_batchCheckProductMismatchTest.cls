@istest(SeeAllData=true)

public class Edelweiss_batchCheckProductMismatchTest {

    public testmethod static void testEdelweiss_batchCheckProductMismatch()
    {
     Test.startTest();    
     Database.BatchableContext bcMain;
     List<Product_Staging_Container__c> listBatchRecords=new List<Product_Staging_Container__c>();
     Product_Staging_Container__c psc=new Product_Staging_Container__c();
     psc.Product_Name__c='GTN Industries Ltd TEST';
     psc.Scrip_Key__c='6720';
     psc.Source_Id__c='2';
     psc.Source__c='Equity';
     psc.Sub_Asset_Class__c='Direct Equity/Stocks';
     psc.Asset_Class__c='Share Trading';
     listBatchRecords.add(psc);
     insert listBatchRecords;    
        
     Product2 p=new Product2();  
     p.Sub_Asset_Class__c = 'Direct Equity/Stocks';     
     p.Name='GTN Industries Ltd New TEST';        
     insert p;
      
     Product2 p2=new Product2();   
     p2.Sub_Asset_Class__c = 'Direct Equity/Stocks';      
     p2.Name='GTN23 TEST';        
     insert p2;
           
     Product2 p3=new Product2();  
     p3.Sub_Asset_Class__c = 'Direct Equity/Stocks';       
     p3.Name='GTN2 TEST';        
     insert p3;
        
     Edelweiss_batchCheckProductMismatch obj=new Edelweiss_batchCheckProductMismatch();  
     
     MisMatchProductsFilters__c cs = new MisMatchProductsFilters__c();
     cs.Name='Direct Equity/Stocks TEST';
     cs.Sub_Asset_Class__c = 'Direct Equity/Stocks';
     insert cs;                
        if(!Test.isRunningTest()){
             Database.executeBatch(obj);
        }   
        
        
     Test.stopTest();
     }
    
}