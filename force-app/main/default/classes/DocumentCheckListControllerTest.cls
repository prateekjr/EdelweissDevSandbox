@istest
public class DocumentCheckListControllerTest {

    public testmethod static void testgetRequiredDocuments()
    {
        
        List<Lead> llist=Testclassutils.createLead();
        Lead l=llist[0];
        insert llist;
        
        Account fam = TestClassUtils.createFamily();
        insert fam;
        Account a=TestClassutils.createAccount();
        a.ParentId = fam.id;
        a.Coverage__c = 'R2';
        insert a;
        TestClassutils.InsertSysProperties();
        List<Case> clist=TestClassutils.createTestCaseForMAO();
        Case c=clist[0];
        c.AccountId=a.Id;
        insert clist;
        String s='Address Proof;Bank Proof – Cancelled Cheque;Letter of Authority - Only Demat;Incorporation Certificate;Financial proof (Last 2 years)';
        
        List<String> slist=s.split(';');
        
        Document_Checklist__c dc=new Document_Checklist__c();
        dc.Case__c=c.Id;
        dc.Required_Documents__c='Address Proof;Bank Proof – Cancelled Cheque;Letter of Authority - Only Demat;Incorporation Certificate;Financial proof (Last 2 years)';
        insert dc;
      
        Test.startTest();
        DocumentCheckListController obj=new DocumentCheckListController();
        obj.caseId=c.id;
        List<String> rlist=obj.getRequiredDocuments();
        system.assert(rlist==slist);
        Test.stopTest();
        
    }
}