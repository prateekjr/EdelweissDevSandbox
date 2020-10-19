@istest
public class IPSControllerTest {

    public testmethod static void testIPSController()
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
        
        ApexPages.currentPage().getParameters().put('Id',ips.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(ips);
        
        Test.startTest();
        IPSController obj=new IPSController(sc);
        obj.getIpsList();
        Test.stopTest();
    }
    
}