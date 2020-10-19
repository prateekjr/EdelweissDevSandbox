@istest
public class BatchDeleteRelatedMismatchProductTest {

    public testmethod static void testBatchDeleteRelatedMismatchProduct()
    {
        Client_Asset_Staging_Container__c casc=new Client_Asset_Staging_Container__c();
        //Start: required fields added by Abhishek Rajput
        casc.Account_Code__c='01234';
        casc.Account_Name__c='TestAccount'; 
        casc.Asset_Class__c='TestAssetClass';
        casc.Client_Code__c='01234';
        casc.Client_Name__c='TestClient';
        casc.Family_Code__c='01234';
        casc.Family_Name__c='TestFamily';
        casc.Scrip_Key__c='012abc';
        casc.Source_Id__c='01234';
        casc.Sub_Asset_Class__c='TestSubAsset';
        casc.As_On_Date__c=date.newInstance(2016, 06, 21);
        //End: required fields added by Abhishek Rajput
        insert casc;
        Reported_Mismatch_Product__c objReported = new Reported_Mismatch_Product__c();
        objReported .is_deleted__c=true;
        insert objReported ;
        
        BatchDeleteRelatedMismatchProduct obj=new BatchDeleteRelatedMismatchProduct();
        
        obj.notifyAdminFlag=true;
        
        Test.startTest();
        Database.executeBatch(obj);
        Test.stopTest();
        
        
    }
}