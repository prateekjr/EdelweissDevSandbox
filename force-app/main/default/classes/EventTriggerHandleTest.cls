@istest(seeAllData = true)
public class EventTriggerHandleTest {
 
    
    @istest(seealldata=true)
    public static void TestEventInsert()
    {
        Event e=new Event();
        e.DurationInMinutes=30;
        e.ActivityDateTime=Date.today();
        e.RecordTypeId=EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        e.Status__c = 'Meeting Cancelled';
        e.Type= 'Meeting';
        e.Agenda__c='Follow Up';
        /*List<Lead> leadLst=TestClassUtils.createLead();
        insert leadLst;
        Lead l1=new Lead();
        for(Lead l:leadLst)
            l1=l;
        e.WhoId=l1.Id;*/
        Account accountObj = TestClassUtils.createFamily();
        insert accountObj;
        e.WhatId= accountObj.Id;
        e.Description='Heloooooo..';
        e.DescriptionNew__c = 'TESTCLASS';
        e.isMoMSend__c=true;
        insert e;
        
        
        
        //working
        Event e1=new Event();
        e1.DurationInMinutes=30;
        e1.ActivityDateTime=Date.today();
        e1.RecordTypeId=EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        e1.Status__c = 'Completed';
        e1.Type= 'Meeting';
        e1.Agenda__c='Follow Up';
        e1.Type_of_Communication__c = 'In-Person';
        
        accountObj = TestClassUtils.createFamily();
        insert accountObj;
        e1.WhatId= accountObj.Id;
        e1.Description='Heloooooo..';
        e1.DescriptionNew__c = 'TESTCLASS';
        e1.isMoMSend__c=true;
        insert e1;
        
        
        Event e2=new Event();
        
        e2.DurationInMinutes=30;
        e2.ActivityDateTime=Date.today();
        e2.RecordTypeId=EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        e2.Status__c = 'Completed';
        e2.Type= 'Meeting';
        e2.Agenda__c='Follow Up';
        e2.WhatId=accountObj.Id;
        e2.Description='Heloooooo..';
        e2.DescriptionNew__c = 'TESTCLASS';
        e2.Type_of_Communication__c = 'Email';
        e2.Agenda__c = 'Portfolio Review';
        e2.RA_RH_Meeting__c=true;
        e2.isMoMSend__c=true;
        //insert e2;
 
        Event e3=new Event(id=e1.id);
        Opportunity o1=TestClassUtils.createOpportunity();
        o1.Name='XYZ';
        insert o1;
        e3.WhatId=o1.Id; 
        e3.Agenda__c= EdelweissConstants.ACTIVITY_AGENDA_SALE_OPPORTUNITY;
        update e3;
        
        
       
    }
    
}