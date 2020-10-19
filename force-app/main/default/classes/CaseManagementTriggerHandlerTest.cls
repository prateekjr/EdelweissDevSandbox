/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CaseManagementTriggerHandlerTest {
    
    @istest
   public  static void Testcaseinsert()
   {
       test.startTest();
       TestClassUtils.InsertSysProperties();
       Account_Opening_Process_and_TAT__c t=new Account_Opening_Process_and_TAT__c();
       t.Sequence__c=1;
       t.Turnaround_Time__c=2;
       t.Tasks__c = 'Request Receive';
       t.Product_Type__c = 'Comtrade Only';
       t.Account_Type__c = 'Exchange Account Opening';
       t.Turnaround_Time_From__c=null;
       insert t;
       
        Account Acc = TestClassUtils.createAccount();
        Id leadRecordId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId(); 
        Acc.Open_an_account_opening_Case__c = true;
        Acc.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId(); 
        insert Acc;
       
        Service_Type_TAT_Mapping__c sttp=new Service_Type_TAT_Mapping__c();
        sttp.RecordTypeId=EdelweissConstants.ServiceTatRecordTypeMap.get('East');
        sttp.Customer_TAT__c='12';
        sttp.Name='Reports/Statement';
        sttp.Subtype__c='Contract Notes';
        sttp.Sub_Sub_Type__c='Non-Receipt of contract notes';
        insert sttp;
        test.stopTest();
    // Insertion Of Case       
     
       List<Case> mylist=new List<Case>();
       List<Case> caselist=TestclassUtils.createTestCaseForFT();
       Case c=caselist[0];
       
       
       //c.Lead__c=l.id;
       c.On_Hold_Date__c=Date.today()-12;
       //c.Status=EdelweissConstants.CASE_ON_HOLD_STATUS;
       c.Total_On_Hold_Duration__c='100';
       
        Account leadAcc1=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        leadAcc1.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Lead'); 
        leadAcc1.In_Person_Meeting_End_Date__c=Date.today();
        leadAcc1.Coverage__c='R2';
        insert leadAcc1;

        c.product_type__c ='Comtrade Only';
        c.POA__c=false;     
        c.AccountId= leadAcc1.id;
        
       mylist.add(c);
       
       insert caselist;
   
       c.Status='In Progress';
        update caselist;
       
       //Update Case
        List<Case> cslst = TestClassUtils.createTestCaseForSR(); 
        Case ca=cslst[0];
        ca.Type='Reports/Statement';
        ca.Subtype__c='Contract Notes';
        ca.Sub_Sub_Type__c='Non-Receipt of contract notes';
        ca.Status='In Progress';
        ca.On_Hold_Date__c=Date.today()-12;
        ca.Total_On_Hold_Duration__c='100';
        insert cslst;
  
        ca.Status=EdelweissConstants.CASE_ON_HOLD_STATUS;
       // update ca;  
        update cslst;
   }
      static testMethod void testRecalculateServiceRequestDueDate() {
        test.startTest();
        TestClassutils.InsertSysProperties();
        List<Case> cslst = TestClassUtils.createTestCaseForSROnHold();
        insert cslst;
        for(Case caseRecord: cslst){
            caseRecord.Status = 'In Progress';
            caseRecord.Description = 'Sample description';
            Service_History__c sh = [Select On_Hold_Date__c from Service_History__c where case__c =: caseRecord.Id];
            sh.On_Hold_Date__c = System.Now();
            update sh;
            update caseRecord;           
            caseRecord.Status = EdelweissConstants.CASE_CLOSED_REJECTED_STATUS;
            caseRecord.Remarks__c ='test';
            update sh;
            update caseRecord;  
        }
        CaseManagementTriggerHandler.stopCaseTrigger = false;
        test.stopTest();
    }

    static testMethod void testmaintainServiceHistory()
    {
        Test.startTest();
        TestClassutils.InsertSysProperties();
        List<Case> cslst=TestClassutils.createTestCaseForSR();
        insert cslst;
        for(Case caseRecord: cslst){
            caseRecord.Status = EdelweissConstants.CASE_CLOSED_REJECTED_STATUS;
            caseRecord.Description = 'Sample description';
            caseRecord.Remarks__c ='test';
            update caseRecord;           
                       
        }
        CaseManagementTriggerHandler.stopCaseTrigger = false;
        test.stopTest();
    } 
    /*
    public static testMethod void TestcaseSharing()
    {
        Test.startTest();
        TestClassUtils.InsertSysProperties();
        List<Case> cslist=TestClassUtils.createTestCaseForFT();
        Profile profileId=[SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        System.debug('cslist'+cslist);
        User use = new User(alias = 'ceo', email='admin@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', 
        timezonesidkey='America/Los_Angeles', username='adminTas@testorg.com', profileid = profileId.Id);
        insert use;
     
        Account leadAcc=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        leadAcc.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Lead'); 
        leadAcc.In_Person_Meeting_End_Date__c=Date.today();
        leadAcc.Coverage__c='R2';
        insert leadAcc;
     
        Case c=cslist[0];
        c.OwnerId=use.Id;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Exchange Account Opening').getRecordTypeId();
        c.AccountId = leadAcc.id;
        c.product_type__c ='Comtrade Only';
        c.POA__c=false; 
        System.debug('cslist::OwnerId'+c.OwnerId);
        System.debug('cslist::CreatedById'+c.CreatedById);
       
        Insert c;
        cslist.add(c);
        CaseManagementTriggerHandler.caseSharing(cslist);
        test.stopTest();
    }*/
    /*public static testmethod void TestcaseSharing()
    {
        Test.startTest();
        List<Lead> lstLead = TestClassUtils.createLead();
        lstLead[0].status ='R2';
        insert lstLead ;
        TestClassUtils.InsertSysProperties();
        List<Case> cslist=TestClassUtils.createTestCaseForFT();
        Profile profileId=[SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        
        User use = new User(alias = 'ceo', email='admin@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', 
        timezonesidkey='America/Los_Angeles', username='adminTas@testorg.com', profileid = profileId.Id);
        insert use;
        
        User use2 = new User(alias = 'ceo2', email='admin2@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', 
        timezonesidkey='America/Los_Angeles', username='admin2@testorg.com', profileid = profileId.Id);
        insert use2;
        
        Case c=cslist[0];
        c.OwnerId=use.Id;
        //c.CreatedById = use2.Id;
        c.Lead__c= lstLead[0].id;
        //c.recordtypeId = EdelweissConstants.CaseRecordTypeMap.get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING);
        cslist.add(c);
        //update nc;
        Insert cslist;
        System.debug('cslist'+cslist);
        //CaseManagementTriggerHandler CaseMethod = new CaseManagementTriggerHandler();
        CaseManagementTriggerHandler.caseSharing(cslist);
        
        Case newcase=cslist[1];
        List<User> ulist=[SELECT Id FROM User WHERE ProfileId = :profileId.Id];
        newcase.Owner_Change_Reason__c='NO Reason';
        newcase.OwnerId=use2.Id; //ulist[1].Id;
        Update cslist;
        newcase.Lead__c= lstLead[0].id;
        update newcase; 
        test.stopTest();
    }*/
}