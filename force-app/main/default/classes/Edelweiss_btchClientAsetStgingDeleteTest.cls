@istest
public class Edelweiss_btchClientAsetStgingDeleteTest {
 
    public testmethod static void testEdelweiss_batchClientAssetStagingDelete()
    {
        Client_Asset_Staging_Container__c casc=new Client_Asset_Staging_Container__c();
        casc.Account_Code__c = '12';
        casc.Account_Name__c = 'test';
        casc.As_On_Date__c = System.today();
        casc.Asset_Class__c = 'Equity';
        casc.Client_Code__c = '21';
        casc.Client_Name__c = 'testing';
        casc.Family_Code__c = '43';
        casc.Family_Name__c = 'qwerty';
        casc.Total_AUM__c = 200;
        casc.Sub_Asset_Class__c = 'Sp- Equity Sp';
        casc.Source_Id__c = '12';
        casc.Scrip_Key__c = '12';
        casc.Scrip_Name__c = 'qw';
        
        insert casc;
        Edelweiss_batchClientAssetStagingDelete obj=new Edelweiss_batchClientAssetStagingDelete();
        
        Test.startTest();
        Database.executeBatch(obj);
        Test.stopTest();
        
    }
    
}