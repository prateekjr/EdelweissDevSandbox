@istest
public class Edelweiss_btchEdlClientStgingDeletTest {
   
    public testmethod static void testEdelweiss_batchEdelClientStagingDelete()
    {
        Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();
        ecsc.Account_Name__c='Test';
        ecsc.Account_Type__c = '1113';
        ecsc.Client_Name__c = 'Test';
        ecsc.Family_Name__c = 'Test';
        ecsc.GWM_Online_Account_Id__c='1112';
        ecsc.GWM_Online_Client_Id__c = '1122';
        ecsc.GWM_Online_Family_Id__c = '1121';
        ecsc.PAN_Number__c = 'RRRRR7777R';
        
        ecsc.Primary_CXO_Employee_Id__c='1221';
        ecsc.Primary_CXO_Miles_Id__c = '212';
        ecsc.Primary_FA_Employee_Id__c = '1121';
        ecsc.Primary_FA_Miles_Id__c = '121';
        ecsc.Is_Client_Family_Head__c = 'No';
        insert ecsc;  
        
        Edelweiss_batchEdelClientStagingDelete obj=new Edelweiss_batchEdelClientStagingDelete();
        
        
        Test.startTest();
        Database.executeBatch(obj);
        Test.stopTest();
        
    }
}