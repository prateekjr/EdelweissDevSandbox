@isTest
public class MessagingBatchTest {
    @istest
    public static void testMessagingBatch(){
        
        List<Lead> llist=TestClassUtils.createLead();
        Lead l=llist[0];        
        Date dt=Date.today();
        l.Anniversary__c=Date.newInstance(1991,dt.month(),dt.day());
        l.Date_of_Birth__c=Date.newInstance(1991,dt.month(),dt.day());
        l.Lead_1st_Milestone_Complete__c=true;
        l.Status=EdelweissConstants.LEAD_R1_STATUS;
        l.Allocation_Fields_duly_completed__c=false;
        l.FA_had_open_a_ticket_case__c=false;
        l.All_Product_details_filled__c=false;
        l.R1_State_Change_Date__c=Date.today()-20;
        insert l;
        
        List<Lead> ll=TestClassUtils.createLead();
        Lead l2=ll[0];
        l2.LastName='ABC';
        l2.Anniversary__c=Date.newInstance(1991,dt.month(),dt.day());
        l2.Date_of_Birth__c=Date.newInstance(1991,dt.month(),dt.day());
        l2.Lead_1st_Milestone_Complete__c=true;
        l2.Lead_2nd_Milestone_Complete__c=true;
        l2.Lead_3rd_Milestone_Complete__c=true;
        l2.Status=EdelweissConstants.LEAD_R2_STATUS;
        l2.Allocation_Fields_duly_completed__c=false;
        l2.FA_had_open_a_ticket_case__c=false;
        l2.All_Product_details_filled__c=false;
        l2.R2_State_Change_Date__c=Date.today()-20;
        l2.Phone='0997654321';    
        l2.Company='EEEE';    
        l2.PAN_Number__c='XXBPP2043Q';
        insert l2;
        
        
        Account leadAcc=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        leadAcc.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Lead'); 
        leadAcc.In_Person_Meeting_End_Date__c=Date.today();
        leadAcc.Coverage__c='R2';
        insert leadAcc;
        
        Event e=new Event();
        e.Status__c='Open';
        e.Type='Meeting';
        e.Description='TESTCLASS';
        e.DescriptionNew__c = 'TESTCLASS';
        e.ActivityDateTime=Date.today()-10;
        e.EndDateTime=Date.today()-5;
        e.Reason_For_Not_Sending_MoM__c='TestClass';
        e.WhatId=leadAcc.id;
        insert e;
        
        //system.debug(Select WhoId, Type, Status__c,CreatedDate From Event Where Status__c != 'Completed\' AND Type = \'Meeting\' AND WhoId !=null AND EndDateTime <= N_DAYS_AGO:2');
        
        MessagingBatch MB=new MessagingBatch();
        Test.startTest();
        Database.executeBatch(MB);
        Test.stopTest();
        
        /*   
        Database.BatchableContext BC;
        List<SObject> scope=new List<SObject>();
        scope=TestClassUtils.createLead();
        MB.iterationCount=0;
    
        MB.iterationCount=4;
        MB.execute(BC, n);
        MB.iterationCount=5;
        MB.execute(BC, n);
        Test.stopTest();
        */
    }
}