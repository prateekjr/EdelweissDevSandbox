@isTest
public class TaskManagementTriggerHandlerTest {
    
    
    public testmethod static void callTrigger(){
    
        List<Account_Opening_Process_and_TAT__c> nonPOATasksList = new List<Account_Opening_Process_and_TAT__c>{};
         
         Account_Opening_Process_and_TAT__c objAccount1 = new Account_Opening_Process_and_TAT__c(Sequence__c =1,Turnaround_Time__c=3,Turnaround_Time_From__c=3,Tasks__c='testTask',Account_Type__c='Exchange Account Opening',Product_type__c='Comtrade Only',New__c='NA');
         Account_Opening_Process_and_TAT__c objAccount2 = new Account_Opening_Process_and_TAT__c(Sequence__c =1,Turnaround_Time__c=3,Turnaround_Time_From__c=3,Tasks__c='testTask',Account_Type__c='Exchange Account Opening',Product_type__c='Comtrade Only',New__c='TRUE');
         Account_Opening_Process_and_TAT__c objAccount3 = new Account_Opening_Process_and_TAT__c(Sequence__c =1,Turnaround_Time__c=3,Turnaround_Time_From__c=5,Tasks__c='testTask',Account_Type__c='Exchange Account Opening',Product_type__c='Comtrade Only',New__c='NA');
         insert objAccount1 ;
         insert objAccount2 ;
         insert objAccount3 ;
        Test.startTest();
        
        CaseTaskMapping__c mp=new CaseTaskMapping__c();
        mp.Sequence__c=1;
        mp.Turnaround_Time__c=5;
        mp.Controlling_Task__c='Call';
        mp.Dependent_Task__c='Fallow Up';
       //RecordTypeId=EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.Generic_Task_Record_Type);
        mp.Turnaround_Time_From__c=5;
        
        insert mp;
        
        List<CaseTaskMapping__c> imp=[Select Sequence__c,Turnaround_Time__c,Controlling_Task__c,Dependent_Task__c,RecordType.name,Turnaround_Time_From__c from CaseTaskMapping__c  where Turnaround_Time_From__c =: mp.Turnaround_Time_From__c  AND RecordType.name ='Miles Account Opening'];                                      
         
        //System.debug('case task mapping record type name'+imp[0].RecordType.name);
       
        TestClassUtils.InsertSysProperties();
        
        //Creating User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test453@testorg.com');

         User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test673@testorg.com');
        
        insert u;
        insert u2;
        List<Lead> lstLead = TestClassUtils.createLead();
        if(lstLead != null)
        {
        lstLead[0].status ='R2';
        }
        insert lstLead ;
        TestClassUtils.InsertSysProperties();
        
        Account leadAcc=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        leadAcc.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Lead'); 
        leadAcc.In_Person_Meeting_End_Date__c=Date.today();
        leadAcc.Coverage__c='R2';
        insert leadAcc;
        
        Case cs=new Case();
        RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Case' and (Name =: EdelweissConstants.MILES_ACCOUNT_OPENING Or Name =: EdelweissConstants.FUNDING_ACCOUNT_OPENING or Name =: EdelweissConstants.EXCHANGE_ACCOUNT_OPENING  )Limit 1];
        //Case testCase = new Case();
        if(leadAcc.id != null)
        {
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Exchange Account Opening').getRecordTypeId();//EdelweissConstants.CaseRecordTypeMap.get(EdelweissConstants.Exchange_Account_Opening);// //; '012O0000000597G';     //recordTypeList.id;
        cs.product_type__c ='Comtrade Only';
        cs.POA__c=false;
           cs.AccountId = leadAcc.id;
        }
        insert cs;
        list<Task> taskList=new List<Task>();
        
        Task t=new task();
        t.RecordTypeId=EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK);
        t.Status=EdelweissConstants.CASE_ON_HOLD_STATUS;
        t.On_Hold_Date__c=date.today()-20;
        t.Due_Date_Time__c=Date.today()+12;
        t.Total_On_Hold_Duration__c='';
        t.OwnerId=u2.id;
        t.Type='Call';
        t.whatId = cs.id;
        t.Subject ='Test';
        
        taskList.add(t);
        
        Task t2=new task();
        t2.RecordTypeId=EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK);
        t2.Status='In Progress';
        t2.On_Hold_Date__c=date.today()-20;
        t2.Due_Date_Time__c=Date.today()+12;
        t2.Total_On_Hold_Duration__c='';
        t2.Task_Type__c='Exchange Account Opening';
        t2.Task_Sequence__c=5;
        t2.WhatId=cs.Id;
        t2.Subject= 'Document collection';
        taskList.add(t2);
        
        Task t3=new task();
        
        t3.RecordTypeId=EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.Service_Task);
        t3.Status=EdelweissConstants.CASE_ON_HOLD_STATUS;
        t3.Due_Date_Time__c=Date.today()+12;
        t3.On_Hold_Date__c=date.today()-20;
        t3.Total_On_Hold_Duration__c='';
        t3.Subject= 'Document collection';
        t3.whatId = cs.id;
        t3.task_type__c='Exchange Account Opening';
        t3.Task_Sequence__c = 3;
        taskList.add(t3);
       
        insert taskList;
        t3.task_type__c='Exchange Account Opening';
        t3.Task_Sequence__c = 3;
        update t3;
        
        System.debug('befor Update====='+t.OwnerId);
     
        //Updation----------------------------
        
        t.Status=EdelweissConstants.CASE_ON_HOLD_STATUS;
       // t.OwnerId=u.Id;
        t.Owner_Change_Reason__c='TestClass ';
        t2.Status=EdelweissConstants.TASK_COMPLETED_STATUS;
       // t2.OwnerId=u.Id;
        t2.Owner_Change_Reason__c='TestClass ';
        t3.Due_Date_Time__c=Date.today()+12;
        t3.On_Hold_Date__c=date.today()-20;
        t3.Owner_Change_Reason__c='TestClass ';
        t3.Total_On_Hold_Duration__c='';
        t3.OwnerId=u.Id;
        t3.Status='In Progress';
        
        TaskManagementTriggerHandler.stopTaskTrigger=false;
        update taskList;
       System.debug('after Update====='+t.OwnerId);
       
       
        Test.stopTest();
    }

}