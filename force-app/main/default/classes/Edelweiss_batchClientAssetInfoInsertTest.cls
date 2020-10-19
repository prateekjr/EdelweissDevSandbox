@isTest(seeAlldata=true)
public class Edelweiss_batchClientAssetInfoInsertTest {

    public static testmethod void testassetinsert()
    {
       Account a=new Account();
        a.Name='RAjesh';
        a.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family');
        insert a;
        
        Account aa=new Account();
        aa.Name='RAjesh';
        
        aa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        aa.ParentId=a.id;
        insert aa;
        
        
        Client_Account__c ca=new Client_Account__c();
        ca.Client__c=aa.Id;
        ca.Name='Rajesh';
      
        insert ca;
        
        Client_Asset_Information__c csi=new Client_Asset_Information__c();
        csi.Family__c=a.id;
        csi.Client_Account__c=ca.id;
        csi.Total_AUM__c=200;
        csi.Asset_Class__c = 'Equity';
        csi.Sub_Asset_Class__c = 'Sp- Equity Sp';
        insert csi;
        
        //TestClassutils.InsertSysProperties();
        
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
        
        //delete casc;
        
        List<ID> l=new List<ID>();
        l.add(casc.Id);
        Map<String, ID> mapProductScripId = new Map<String, ID>();
        
        Product2 p2=new Product2();
        p2.Name='DueDiligence';
        insert p2;
        Map<Id, Product2> mapProductRecord = new Map<Id, Product2>();
        mapProductRecord.put(p2.Id, p2);
        
        mapProductScripId.putAll(Edelweiss_Integration_Utility.collectMapForProductRecords(mapProductRecord)); 
        
        Edelweiss_batchClientAssetInfoInsert obj=new Edelweiss_batchClientAssetInfoInsert(l,mapProductScripId);
        
        
        Client_Asset_Staging_Container__c casc2=new Client_Asset_Staging_Container__c();
        casc2.Account_Code__c = '112';
        casc2.Account_Name__c = 't1est';
        casc2.As_On_Date__c = System.today();
        casc2.Asset_Class__c = 'Equity';
        casc2.Client_Code__c = '211';
        casc2.Client_Name__c = 'te1sting';
        casc2.Family_Code__c = '413';
        casc2.Family_Name__c = 'q1werty';
        casc2.Total_AUM__c = 200;
        casc2.Sub_Asset_Class__c = 'Sp- Equity Sp';
        casc2.Source_Id__c = '112';
        casc2.Scrip_Key__c = '1112';
        casc2.Scrip_Name__c = 'qw';
        insert casc2;
        
        Test.startTest();
        //Database.executeBatch(obj);
        Test.stopTest();
        
   
    }
}