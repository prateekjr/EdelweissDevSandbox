@istest
public with sharing class ClientAssetInformationTriggerHandlerTest {

@istest
 public static void TestupdateFamilyAUM()
 {
 Test.startTest();
        Account a=new Account();
        a.Name='Rajesh Pukale';
        AccountTriggerhandler.stopUpdatefamily=false;
        a.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family');
        a.Investible_Assets__c=200000000;
        a.Coverage__c='R5';
        a.InPersonMeeting_Due_Date__c=Date.today()+9;
        a.In_Person_Meeting_End_Date__c=Date.today()+15;
        a.Asset_Classes_Client_is_Interested_in__c='Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt';
        insert a;
        
     
        Account aa=new Account();
        aa.Name='Rajesh Pukale';
        AccountTriggerhandler.stopUpdatefamily=false;
        aa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        aa.Asset_Classes_Client_is_Interested_in__c='Debt-PMS;Mutual Funds - Liquid;Mutual Funds - Debt';
        aa.ParentId=a.Id;
        aa.Investible_Assets__c=200000000;
        aa.Coverage__c='R5';   
        insert aa;
 
        Client_Account__c cl=new Client_Account__c();
        cl.Client__c=aa.Id; 
        cl.Name='Rajesh';
       
        insert cl;
       
       Client_Asset_Information__c obj=new Client_Asset_Information__c();
       obj.Family__c=a.Id;
       obj.Client_Account__c=cl.id;
       obj.Total_AUM__c=5000000;
       insert obj;
     
     
       delete obj;
     
       Test.stopTest();
 }



}