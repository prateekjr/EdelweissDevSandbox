@isTest
public class TaskOnleadTriggerHandlerTest {
    @istest
    public static void testUpdateCommunicationCount(){
        Test.startTest();
       
        
      
        
        List<Task> tObject=new List<Task>();
        Task t=new Task();
        
       // List<Lead> leadLst=TestClassUtils.createLead();
       // Lead lObj=leadlst[0];
      //  lObj.Status=EdelweissConstants.LEAD_WARM_STATUS;
        
        Lead lObj=new Lead();
        lObj.Phone='0987654321';       
        lObj.LastName='XYZ';
        lObj.Company='PSL';
        lObj.Status=EdelweissConstants.LEAD_HOT_STATUS ;
        lObj.Warm_Communication_Count__c = null;
        insert lObj;
        
        Task t1=new Task();
        t1.CallDurationInSeconds=45;
        t1.Description__c='jdfghkdghd';
        t1.Status = EdelweissConstants.TASK_COMPLETED_STATUS ;
        t1.Type = EdelweissConstants.MoM_TASK_TYPE;
        t1.Subject='Call';
        t1.WhoId=lObj.Id;
        insert t1;
        
        Account a=TestClassutils.createAccount();
        a.Coverage__c = 'R2';
        insert a;
        
        
        Task t2=new Task();
        t2.CallDurationInSeconds=45;
        t2.Description__c='jdfghkdghd';
        t2.Status = EdelweissConstants.TASK_COMPLETED_STATUS ;
        t2.Type = EdelweissConstants.MoM_TASK_TYPE;
        t2.Subject='Call';
        t2.WhatId=a.id;
        insert t2;
        
        
        
        
        Opportunity o=new Opportunity();
        o.StageName='ongoing';
        o.Name='ABC';
        o.CloseDate=Date.today()+10;
        
        insert o;
        
        
        Task t3=new Task();
        t3.CallDurationInSeconds=45;
        t3.Description__c='jdfghkdghd';
        t3.Status = EdelweissConstants.TASK_COMPLETED_STATUS ;
        t3.Type = EdelweissConstants.MoM_TASK_TYPE;
        t3.Subject='Call';
        t3.WhatId=o.Id;
        insert t3;
        TestClassutils.InsertSysProperties();
        List<Case> clist=TestClassutils.createTestCaseForMAO();
        Case c=clist[0];
        c.AccountId=a.id;
        insert clist;
        
        
        Task t4=new Task();
        t4.CallDurationInSeconds=45;
        t4.Description__c='jdfghkdghd';
        t4.Status = EdelweissConstants.TASK_COMPLETED_STATUS ;
        t4.Type = EdelweissConstants.MoM_TASK_TYPE;
        t4.Subject='Call';
        t4.WhatId=c.Id;
        insert t4;
        
        
        lObj.Warm_Communication_Count__c = 1;
       
        update lObj;
        
        
        update t1;
        update t2;

        
        
        System.debug('Inserted Lead'+[SELECT Id,Status,Cold_Communication_Count__c,Hot_Communication_Count__c,Warm_Communication_Count__c FROM Lead]);
        
        Test.stopTest();
    }
}