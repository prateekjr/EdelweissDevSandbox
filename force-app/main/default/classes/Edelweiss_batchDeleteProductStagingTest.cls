@istest
public class Edelweiss_batchDeleteProductStagingTest {

    public static testmethod void testEdelweiss_batchDeleteProductStaging()
    {
        Product_Staging_Container__c psc=new Product_Staging_Container__c();
     	psc.Product_Name__c='GTN Industries Ltd';
     	psc.Scrip_Key__c='6720';
     	psc.Source_Id__c='2';
     	psc.Source__c='Equity';
     	psc.Sub_Asset_Class__c='Direct Equity/Stocks';
     	psc.Asset_Class__c = 'Equity';
        insert psc;
    }
}