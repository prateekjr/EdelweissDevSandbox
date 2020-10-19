@istest
public class Edelweiss_BatchDeleteFromStagingTest {

    public static testmethod void testEdelweiss_BatchDeleteFromStaging()
    {
        Edelweiss_BatchDeleteFromStaging obj=new Edelweiss_BatchDeleteFromStaging();
        List<sObject> scope=new List<sObject>();
        Product_Staging_Container__c psc=new Product_Staging_Container__c();
        psc.Product_Name__c='GTN Industries Ltd';
     	psc.Scrip_Key__c='6720';
     	psc.Source_Id__c='2';
     	psc.Source__c='Equity';
     	psc.Sub_Asset_Class__c='Direct Equity/Stocks';
        psc.Asset_Class__c='share trading';
        scope.add(psc);
        insert scope;
        
        
        Test.startTest();
        Database.executeBatch(obj,200);
        Test.stopTest();
     }
}