@istest
public class Edelweiss_uploadProductToCRMTest {

    public testmethod static void testEdelweiss_uploadProductToCRM()
    {
        TestCLassutils.InsertSysProperties();
        Product_Staging_Container__c psc=new Product_Staging_Container__c();
        psc.Asset_Class__c='ABC';
        psc.Product_Name__c='xyz';
        psc.Scrip_Key__c='8ui';
        psc.Source_Id__c='67';
        psc.Sub_Asset_Class__c='abc';
        insert psc;
        
         Edelweiss_uploadProductToCRM obj=new  Edelweiss_uploadProductToCRM();
        
        Test.startTest();
        //Database.executeBatch(obj);
        Test.stopTest();
        
    }
    
}