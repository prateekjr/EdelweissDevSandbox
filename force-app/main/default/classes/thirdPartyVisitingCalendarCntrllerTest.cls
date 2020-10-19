@istest
public class thirdPartyVisitingCalendarCntrllerTest {

    public testmethod static void testthirdPartyVisitingCalendar_Controller()
    {
        TPP_Meeting_Calendar__c tmc=new TPP_Meeting_Calendar__c();
        tmc.Meeting_Agenda__c='Testing testthirdPartyVisitingCalendar_Controller';
        insert tmc;
        
        Meeting_Slot__c ms=new Meeting_Slot__c();
        ms.Meeting_Number__c=tmc.Id;
        ms.Meeting_Status__c='Approved';
        insert ms;
        ApexPages.currentPage().getParameters().put('id',tmc.Id);
        thirdPartyVisitingCalendar_Controller tpvc=new thirdPartyVisitingCalendar_Controller();
    }
    
}