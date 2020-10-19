@istest
public class IPSCorporateExtensionsTest {
   
    
      
  public testmethod static void testIPSCorporateExtensions2()
    {
        
        Account a=TestClassutils.createAccount();
        insert a;
        
        Recordtype rt=[SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName = 'Individual'];
        Investment_Policy_Statement_IPS__c ips=new Investment_Policy_Statement_IPS__c();
      
        Investment_Policy_Statement_IPS__c ips2=new Investment_Policy_Statement_IPS__c();
        ips2.Client_Name__c=a.id;
        ips2.RecordTypeId=rt.Id;
        /*
        ips2.AAA_Rated_Each_Issuer__c=60;
        ips2.AA_Plus_Rated_Each_Issuer__c=60;
        ips2.AA_Rated_Each_Issuer__c=60;
        */
        ips.Promoter_Holdings_Target_Per__c = 50;
        ips.Real_Estate_Residence_Target_Per__c = 50;          
        
       
        ApexPages.currentPage().getParameters().put('parentId',a.id);
        //ApexPages.currentPage().getParameters().put('Id',ips.Id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(ips2);
        
        Test.startTest(); 
       
        IPSCorporateExtensions obj=new IPSCorporateExtensions(sc);
       
        obj.Save();
        obj.editIps();
        obj.cancel();
        Test.stopTest();
      
    }
    
    
    
    
    
  public testmethod static void testIPSCorporateExtensions()
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
        
        Investment_Policy_Statement_IPS__c ips2=new Investment_Policy_Statement_IPS__c();
        ips2.Client_Name__c=a.id;
        ips2.RecordTypeId=rt.Id;
        ips2.AAA_Rated_Each_Issuer__c=60;
        ips2.AA_Plus_Rated_Each_Issuer__c=60;
        ips2.AA_Rated_Each_Issuer__c=60;
        
       
        ApexPages.currentPage().getParameters().put('parentId',a.id);
        ApexPages.currentPage().getParameters().put('Id',ips.Id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(ips);
        
        Test.startTest(); 
       
        IPSCorporateExtensions obj=new IPSCorporateExtensions(sc);
       
        obj.Save();
        obj.editIps();
        obj.cancel();
        Test.stopTest();
      
    }
    
    
    
  
    
    

    
    
}