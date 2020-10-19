@isTest(SeeAllData = false)
public class CloseCommentTest {

    static testMethod void testCloseComment(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        TestClassutils.InsertSysProperties();
        Account acct = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeID);
        insert acct;
        
        recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Case c = new Case(
            	AccountId = acct.Id,
                Priority = 'High',
                Status = 'Escalated',
                Contacted_By__c = 'CSO',
                LOB__c = 'GWM',
                Product_Type__c = 'Demat Only');
        insert c;
        
        CaseComment caseComment = new CaseComment(
            	ParentId = c.Id);
        insert caseComment;
    }
}