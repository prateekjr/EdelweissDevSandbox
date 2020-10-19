@istest
public class Edelweiss_batchSyncFaCxoMapingTest {

    public testmethod static void TestEdelweiss_batchSyncFaCxoMaping()
    {
    TestClassUtils.InsertSysProperties();

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Financial Advisor' LIMIT 1];
    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Client Experience Office (CXO)' LIMIT 1];
    User u = new User(Alias = 'admtp', Email='sysAdmin@edel.dev', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@edel.dev',
        Edelweiss_Employee_Id__c = 'CXOEDEL1245',Miles_Id__c = 'CXOMILE1245' );
        insert u;
    User u1 = new User(Alias = 'admtp', Email='sysAdmin@edel.dev', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p1.Id, 
        TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@edel.dev',
        Edelweiss_Employee_Id__c = 'FA1EDEL123',Miles_Id__c = 'FA1MILE123' );
        insert u1;
    FA_CXO_Staging_Container__c fcsdelet=new FA_CXO_Staging_Container__c();
    fcsdelet.FA_Employee_Id__c='CXOEDEL1245';
    fcsdelet.FA_Miles_Id__c='CXOMILE1245';
    fcsdelet.CXO_Employee_Id__c='FA1EDEL123';
    fcsdelet.CXO_Miles_Id__c='FA1MILE123';
    fcsdelet.Is_Deleted__c = false;
    insert fcsdelet;
    List<ID> deletedId =new List<ID>();
    //deletedId.add(fcsdelet.id);  
    delete fcsdelet;
   
    TestClassutils.InsertSysProperties();
    Edelweiss_batchSyncFaCxoMaping obj=new Edelweiss_batchSyncFaCxoMaping(deletedId);
  
        
        
        
    List<FA_CXO_Staging_Container__c> listBatchRecords=new List<FA_CXO_Staging_Container__c>();
    FA_CXO_Staging_Container__c fcs=new FA_CXO_Staging_Container__c();
    fcs.FA_Employee_Id__c='CXOEDEL1245';
    fcs.FA_Miles_Id__c='CXOMILE1245';
    fcs.CXO_Employee_Id__c='FA1EDEL123';
    fcs.Is_Deleted__c = false;
    fcs.CXO_Miles_Id__c='FA1MILE123';
    listBatchRecords.add(fcs);      
    insert listBatchRecords; 
        
        
    Test.startTest();
    Database.executeBatch(obj, 200);
    Test.stopTest();
    }
    
    public testmethod static void TestEdelweiss_batchSyncFaCxoMapingPath2()
    {

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Financial Advisor' LIMIT 1];
    User u = new User(Alias = 'admtp', Email='sysAdmin@edel.dev', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@edel.dev',
        Edelweiss_Employee_Id__c = 'CXOEDEL1245',Miles_Id__c = 'CXOMILE1245' );
        insert u;
    
    FA_CXO_Staging_Container__c fcsdelet=new FA_CXO_Staging_Container__c();
    fcsdelet.FA_Employee_Id__c='CXOEDEL1245';
    fcsdelet.FA_Miles_Id__c='CXOMILE1245';
    fcsdelet.CXO_Employee_Id__c='FA1EDEL123';
    fcsdelet.CXO_Miles_Id__c='FA1MILE123';
    fcsdelet.Is_Deleted__c = false;
    insert fcsdelet;
    List<ID> deletedId =new List<ID>();
    //deletedId.add(fcsdelet.id);  
    delete fcsdelet;
   
    TestClassutils.InsertSysProperties();
    Edelweiss_batchSyncFaCxoMaping obj=new Edelweiss_batchSyncFaCxoMaping(deletedId);
  
        
        
        
    List<FA_CXO_Staging_Container__c> listBatchRecords=new List<FA_CXO_Staging_Container__c>();
    FA_CXO_Staging_Container__c fcs=new FA_CXO_Staging_Container__c();
    fcs.FA_Employee_Id__c='CXOEDEL1245';
    fcs.FA_Miles_Id__c='CXOMILE1245';
    fcs.CXO_Employee_Id__c='FA1EDEL123';
    fcs.Is_Deleted__c = false;
    //fcs.CXO_Miles_Id__c='FA1MILE123';
    listBatchRecords.add(fcs);      
    insert listBatchRecords; 
        
        
    Test.startTest();
    Database.executeBatch(obj, 200);
    
    List<ID> deletedId1 =new List<ID>();
    Edelweiss_batchSyncFaCxoMaping obj1=new Edelweiss_batchSyncFaCxoMaping(deletedId1);
    Database.executeBatch(obj1, 200);
    Test.stopTest();
    }
    
    
}