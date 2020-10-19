@istest
public class BatchUpdateMINIAndDetailedIPSTest 
{
    public testmethod static void testUpdatebatch()
    {
      	Account acc=TestClassutils.createAccount();
        acc.Coverage__c ='R4';
        acc.IsReview_DetailIPS__c = True;
        acc.DetailIPS_Review_Date__c = date.today().addMonths(24);
        acc.MINIIPS_filled_Due_Date__c = date.today().addMonths(6);
        acc.DetailIPS_filled_Due_Date__c = date.today().addMonths(12);
        
     	acc.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
     	insert acc;
     	
        BatchUpdateMINIAndDetailedIPS obj=new BatchUpdateMINIAndDetailedIPS();
     	Test.startTest();
     	Database.executeBatch(obj);
     	Test.stopTest(); 
    }
    public testmethod static void testUpdate()
    {
      	Account acc=TestClassutils.createAccount();
        acc.Coverage__c ='R3';
        acc.IsReview_MINIIPS__c = True;
        acc.MINI_IPS_Review_Date__c = date.today().addMonths(12);
        acc.MINIIPS_filled_Due_Date__c = date.today().addMonths(12);
        acc.DetailIPS_filled_Due_Date__c = date.today().addMonths(24);
        
     	acc.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
     	insert acc;
     	
        BatchUpdateMINIAndDetailedIPS obj=new BatchUpdateMINIAndDetailedIPS();
     	Test.startTest();
     	Database.executeBatch(obj);
     	Test.stopTest(); 
    }
   
}