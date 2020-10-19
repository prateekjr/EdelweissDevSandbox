@istest
public class IndividualIPSControllerTest {

    public testmethod static void testIndividualIPSController()
    {
        Account a=TestClassutils.createAccount();
        insert a;
        
        Recordtype rt=[SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName = 'Individual'];
        Investment_Policy_Statement_IPS__c ips=new Investment_Policy_Statement_IPS__c();
        ips.Client_Name__c=a.id;
        ips.RecordTypeId=rt.Id;
        
        ips.Promoter_Holdings_Target_Per__c = 50;
        ips.Real_Estate_Residence_Target_Per__c = 50;
        insert ips;
        
        ApexPages.currentPage().getParameters().put('parentId',a.id);
        ApexPages.currentPage().getParameters().put('Id',ips.Id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(ips);
        
        Test.startTest();
        IndividualIPSController obj1=new IndividualIPSController(sc);
        IndividualIPSController obj2=new IndividualIPSController(); 
        
        obj1.saveRecord();
        obj1.cancel();
        obj1.viewAsPdf();
        obj1.EditRecord();
        
        obj2.getAcc();
        obj2.saveRecord();
        obj2.cancel();
        obj2.viewAsPdf();
        obj2.EditRecord();
        
        Test.stopTest();
        
        
    }
}