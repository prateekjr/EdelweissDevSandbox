public with sharing class thirdPartyVisitingCalendar_Controller 
{

    public TPP_Meeting_Calendar__c objClientMeeting {get; set;}
    public ID selectedMeetingID {get; set;}
    public List<Meeting_Slot__c> listproposedSchedule {get; set;}
    public thirdPartyVisitingCalendar_Controller()
    {
        selectedMeetingID = ApexPages.currentPage().getParameters().get('id');
        objClientMeeting = [Select Associated_Product__c, Visiting_3rd_Party_Contact__r.Name, Associated_Product__r.Name, Meeting_Agenda__c, Notes_On_Meeting__c, Status__c, Visit_Date__c From TPP_Meeting_Calendar__c where id =:selectedMeetingID];
        
        listproposedSchedule=[Select id, Start_Time__c, Meeting_Date__c, End_Time__c ,Meeting_Reuester__c, Meeting_Status__c, Purpose_Of_Meeting__c From Meeting_Slot__c where Meeting_Number__c =: objClientMeeting.id AND Meeting_Status__c = 'Approved'];
    }   
}