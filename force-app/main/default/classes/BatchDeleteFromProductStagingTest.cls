@istest
public class BatchDeleteFromProductStagingTest {

    public testmethod static void testBatchDeleteFromProductStaging()
    {
        Product_Staging_Container__c psc=new Product_Staging_Container__c();
        //Start: Required fields added by Abhishek Rajput
        	psc.Asset_Class__c='TestAssetClass';
        	psc.Product_Name__c='TestProduct';
        	psc.Scrip_Key__c='0123';
            psc.Source_Id__c='01234';
            psc.Sub_Asset_Class__c='TestSubAsset';
        //End: Required fields added by Abhishek Rajput
        insert psc;
        
        BatchDeleteFromProductStaging obj=new BatchDeleteFromProductStaging();
        
        Test.startTest();
        Database.executeBatch(obj);
        Test.stopTest();
        
    }
}