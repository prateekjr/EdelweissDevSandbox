@isTest
public class UtilityActionTest {

    @istest
    public static void TestSendEmail()
    {
         Test.startTest();
         TestClassUtils.InsertSysProperties();
         List<Lead> l=TestClassUtils.createLead();
         insert l;
         Lead ll=new Lead();
         for(Lead ld:l)
            ll=ld;
         Task t=new Task();
         t=TestClassUtils.createTask(ll);
         insert t;
         Account accountObj =TestClassUtils.createAccount();
         insert accountObj;
         Id whoId=ll.Id;
         Id whatId;
         String description='New mail to send.';
         String activityId=t.Id;
         Id relatedToId=accountObj.Id;
         String keyDeliverable='Message to be send.';
         String nextFollowup ;
         UtilityAction.sendEmail( whoId, whatId, description, activityId, relatedToId, keyDeliverable, nextFollowup );
      
        // Account 
         Account a=TestClassUtils.createAccount();
         a.Coverage__c = 'R2';
         insert a;
         whatId =a.Id;
         //UtilityAction.sendEmail( whoId, whatId, description, activityId, relatedToId, keyDeliverable, nextFollowup );
        
        
        //Case
        List<Case> caseList = new List<Case>();
        
        caseList=TestClassUtils.createTestCaseForFT();
        caseList[0].AccountId = a.id;
        insert caseList;
        Case cObj=new Case();
        for(Case cs:caseList)
            cObj=cs;
        relatedToId=cObj.Id; 
        Case c =cObj;
        whatId = c.Id;
        description= c.MinutesOfMeeting__c;
        activityId = c.EventId__c;
        nextFollowup = c.Next_Follow_up__c;
        keyDeliverable = c.Key_Deliverable__c;
       // UtilityAction.sendEmail( whoId, whatId, description, activityId, relatedToId, keyDeliverable, nextFollowup );
        
        
        //Opportunity 
		/*
        Opportunity o=TestClassUtils.createOpportunity();
        insert o;
        relatedToId=o.Id;
        whatId = o.Id;
        System.debug('Opportunity Result :'+(whatId.getSObjectType() == Opportunity.sObjectType));
         description= o.MinutesOfMeeting__c;
         activityId= o.EventId__c;
         nextFollowup = o.Next_Follow_up__c;
         keyDeliverable = o.Key_Deliverable__c;
         UtilityAction.sendEmail( whoId, whatId, description, activityId, relatedToId, keyDeliverable, nextFollowup );
       
        
         UtilityAction.sendEmail( whoId, whatId, description, activityId, relatedToId, keyDeliverable, nextFollowup );
		 */
         Test.stopTest();
    }
}