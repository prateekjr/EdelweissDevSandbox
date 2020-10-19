@istest(seeAllData=true)
public class LeadTriggerHandlerTest {

    public testmethod static void TestLeadInsert()
    {
       LeadTriggerHandler.stopLeadTrigger=false;
       List<Lead> llist=TestClassutils.createLead();
       Lead l=llist[0];
       Test.startTest();
       LeadTriggerHandler.stopLeadTrigger=false;
       l.Sub_Category__c = 'Treasury';
       l.Sub_Source_Level_2__c ='Client Referral';       
      // Added by Nimishekh: For Treasury firstname and lastname should be different       
       l.LastName = 'DingDong';
       l.FirstName= 'Singsong';
       insert l;
       test.stopTest(); 
    }

    public static testmethod void TestLeadupdate()
    {
      // To Execute reallocateLead method
        
           Test.startTest(); 
        List<Lead> newlist=TestClassutils.createLead();
        Lead l1=newlist[0];
        
        
        LeadTriggerHandler.stopLeadTrigger=false;
        l1.Sub_Category__c = 'Treasury';
        l1.Sub_Source_Level_2__c ='Client Referral';
        l1.Status='R0';
        l1.Company='PSL';
        // Added by Nimishekh: For Treasury firstname and lastname should be different       
        l1.LastName = 'DDong';
        l1.FirstName= 'Ssong';
        insert l1;
        
        l1.reallocate_Lead__c=true;
        leadTriggerHandler.stopLeadTrigger=false;
        
        update newlist;
       
        
        
        
        
        List<Lead> llist=TestClassutils.createLead();
        Lead l=llist[0];
        
        
        LeadTriggerHandler.stopLeadTrigger=false;
        l.Sub_Category__c = 'Treasury';
        l.Sub_Source_Level_2__c ='Client Referral';
        l.Status='R0';
        // Added by Nimishekh: For Treasury firstname and lastname should be different       
        l.LastName = 'ingDong';
        l.FirstName= 'ingsong';
        l.PAN_Number__c='CXBPX2043Q';
        l.Company='DDD Ltd';
        l.Phone='0987954321';

        
        Profile p=[SELECT Id,Name FROM Profile WHERE Name = 'Financial Advisor'];
        
        User FAuser = new User(alias = 'ceo', email='admin@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US',
        timezonesidkey='America/Los_Angeles', username='adminTas@testorg.com', profileid = p.Id);
        User FAuser1 = new User(alias = 'ceo1', email='admin@testorg1.com',
        emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
        localesidkey='en_US',
        timezonesidkey='America/Los_Angeles', username='adminTas@testorg1.com', profileid = p.Id);
        RecordType rt=[SELECT Id FROM RecordType WHERE DeveloperName = 'Corporate_Prospect'];
        
        insert FAuser;
        insert FAuser1;
        
        l.OwnerId=FAuser.Id;
        
        l.RecordTypeId = rt.Id;        
        system.runAs(FAuser)
        {
             insert l;
        }
       
       
        l.reallocate_Lead__c=true;
        
        leadTriggerHandler.stopLeadTrigger=false;
        
        update l;
        
       
        l.OwnerId=Label.Lead_Database_Queue_ID;

        
          // for Executing sendNotificationOnReallocation
      
        
         //   TO Execute resetLeadFields method


         //   Test.setCreatedDate(l.id,DateTime.newInstance(2015,12,12)); 
        
        List<Group> queueList = [Select Name, Id, DeveloperName,Type From Group 
                     Where Type ='Queue' 
                     AND 
                     DeveloperName =: EdelweissConstants.LEAD_DATABASE_QUEUE_API_NAME Limit 1 ];

        
        
        system.debug('Group==='+queueList);
        
        l.OwnerId=queueList[0].Id;
        l.reallocate_Lead__c =true;
        
        update l;
        
        
        System.debug('My Log==='+l.ownerId);        
      
        
        rt=[SELECT Id FROM RecordType WHERE DeveloperName = 'Lead_Approved_Record_Type'];
        
        
        List<Lead> newleadlist=TestClassutils.createLead();
        
        
        Lead newl=newleadlist[0];
        
        newl.LastName='XYZ1';
        //newl.ownerId=FAuser.id;
        
        //Added by Nimishekh: To remove duplicate through FirstName, PAN, Company and Phone
        newl.FirstName = 'ASAA';        
        newl.PAN_Number__c='CXCPP9043Q';

        newl.Phone='0987659311';

        newl.Company='BBA Ltd';
        
        newl.Status='Hot';
        
        newl.Hot_Communication_Count__c=0;
        
        newl.RecordTypeId=EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect');
        
        newl.Prospect_1st_Milestone_Complete__c=true;
               
      
        
        insert newl;
        
        newl.MiddleName='XYZ';
        
        newl.RecordTypeId=rt.Id;
        
        leadTriggerHandler.stopLeadTrigger=false;
        
        update newl;
        
        Lead Testlead=[Select OwnerId,Owner.Type,Age__c,CreatedDate from Lead Where id=:newl.id];
 
         test.stopTest();
    }
    
     public static testmethod void TestshareLeadWithCXO()
     {
         
           
        Profile p=[SELECT Id,Name FROM Profile WHERE Name = 'Financial Advisor'];
        
        User FAuser = new User(alias = 'ceo', email='admin@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US',
        timezonesidkey='America/Los_Angeles', username='adminTas@testorg.com', profileid = p.Id);
        
        insert FAuser;
    
        
         
        User FAuser2 = new User(alias = 'ceo2', email='admin2@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', 
        timezonesidkey='America/Los_Angeles', username='admin2@testorg.com', profileid = p.Id);
         
        insert FAuser2;
        
        FA_CSO_Mapping__c facso=new  FA_CSO_Mapping__c();
        
        facso.FA_User__c=FAuser.id;
        facso.CSO_User__c=FAuser2.id;
         
        insert facso;
         
         
        List<Lead> mylist=TestClassUtils.createLead();
        
        Lead mylead=mylist[0];
        
        mylead.OwnerId=FAuser.Id;
        
        mylead.Lead_1st_Milestone_Complete__c=true;
        //mylead.Status='R1';
        //Added by Nimishekh: To remove duplicate through FirstName, PAN, Company and Phone
        mylead.FirstName = 'ASAA';        
        mylead.PAN_Number__c='CXCPP2043Q';
        mylead.Company='ABDD Systems Ltd';
        mylead.Phone='0987654311';


        insert mylist;
        
        mylead.Lead_1st_Milestone_Complete__c=true;
        mylead.Lead_2nd_Milestone_Complete__c=true;
        mylead.Lead_3rd_Milestone_Complete__c=true;
        mylead.OwnerId=FAuser.Id;
        //mylead.Status='R2';
         
        update mylist;
        
     }
}