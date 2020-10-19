@istest
public class Edelweiss_batchClientAssetInfoDeleteTest {

    public testmethod static void  testEdelweiss_batchClientAssetInfoDelete()
    {
        Account a=new Account();
        a.Name='RAjesh';
        a.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family');
        a.GWM_Online_Id__c ='123XY';
        a.Asset_Classes_Client_is_Interested_in__c ='equity';
        a.Rollup_AUM_of_Family__c =10;
        insert a;
        
        Account aa=new Account();
        aa.Name='RAjesh';
        
        aa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        aa.ParentId=a.id;
        aa.Asset_Classes_Client_is_Interested_in__c ='equity';
        insert aa;
        TestClassUtils.LoadMeetingFrequency();
        
        Client_Account__c ca=new Client_Account__c();
        ca.Client__c=aa.Id;
        ca.Name='Rajesh';
      
        insert ca;
        
        Client_Asset_Information__c csi=new Client_Asset_Information__c();
        csi.Family__c=a.id;
        csi.Client_Account__c=ca.id;
        csi.Total_AUM__c=200;
        csi.Asset_class__c='equity';
        insert csi;
        TestClassUtils.InsertSysProperties();
        Edelweiss_batchClientAssetInfoDelete obj=new  Edelweiss_batchClientAssetInfoDelete(); 
        
        
        Test.startTest();
        Database.executeBatch(obj, 200);
        Test.stopTest();
        
    }
    
}