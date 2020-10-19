@istest
public class Edelweiss_btchCloseMileAccOpenCseTskTest {

    public static testmethod void testEdelweiss_batchCloseMilesAccOpenCaseTask()
    {
        TestClassutils.InsertSysProperties();
        Edelweiss_batchCloseMilesAccOpenCaseTask obj=new Edelweiss_batchCloseMilesAccOpenCaseTask();
        Database.BatchableContext bcMain;
        List<Edelweiss_Clients_Staging_Container__c> listBatchRecords=new List<Edelweiss_Clients_Staging_Container__c>();
        Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();
        ecsc.Client_First_Name__c='Rajesh';
        ecsc.Client_Last_Name__c='Pukale';
        ecsc.Contact_Email__c='test@xyz.com';
        ecsc.PAN_Number__c='CXBPP2043Q';
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
        listBatchRecords.add(ecsc);
        
        Account a=Testclassutils.createAccount();        
		a.Coverage__c = 'R2';       
        insert a;
        
        Case c=new Case();
        c.PAN_Number__c='CXBPP2043Q';
        c.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId();
        c.Status = EdelweissConstants.IN_PROGRESS_STATUS;
        c.AccountId=a.id;
      
        insert c;
        
        Task t=new Task();
        t.Subject = EdelweissConstants.MILES_ACCOUNT_OPENING_TASK_TYPE;
        t.Status = EdelweissConstants.IN_PROGRESS_STATUS;
        t.WhatId=c.id;
        insert t;
        
        Test.startTest();
        //Database.executeBatch(obj, 200);
        Test.stopTest();
    }
   
}