@isTest
public class CreateProspectTest {
  
    public testmethod static void saveProspectTest(){
        List<Lead> leadlist=TestClassutils.createLead();
           Test.startTest();
          system.debug(EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect'));
          Lead l=leadlist[0];
          l.Organizations__c='PSL';

          ApexPages.StandardController sc = new ApexPages.standardController(l); 
          ApexPages.currentPage().getParameters().put('RecordType',EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect'));
          CreateProspect obj=new CreateProspect(sc);
          ApexPages.currentPage().getParameters().put('RecordType',EdelweissConstants.LeadrecordTypeMap.get('Both_Prospect'));
          CreateProspect obj1=new CreateProspect(sc); 
          ApexPages.currentPage().getParameters().put('RecordType',EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect'));
          CreateProspect obj2=new CreateProspect(sc); 
          List<Lead> leadlist1=TestClassutils.createLead();

          Lead l1=leadlist1[0];
          l1.Organizations__c='PSL';
          l1.phone='7276378766';
          l1.lastName ='TestLastName';
          l1.firstName ='TestFirstName';
          ApexPages.StandardController sc1 = new ApexPages.standardController(new Lead()); 
          ApexPages.currentPage().getParameters().put('RecordType',EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect'));
          CreateProspect objl1=new CreateProspect(sc1);
            objl1.lastName='TestLastName';
           objl1.newLeadObj=l1;
          objl1.saveProspects();
          
        Lead l2=new Lead();
        l2.Category__c='Individual';
        l2.Sub_Category__c='Institutions';
        l2.LeadSource='Internal';
        l2.Sub_Source_Level_1__c='Internal Referral';
        l2.Sub_Source_Level_2__c='FA Referral';
        l2.Employee_name__c='TestEmployee';
        l2.Size_of_Deal__c=15233.0;
        l2.Company='Persistent Systems Ltd';
        //l2.LastName='Singh'+c2;
        //l1.Sub_Source_Level_1__c = 'Database';
        //l1.Database_Name__c = '';
        l2.PAN_Number__c='CXBPP2043Q';
        l2.Office_Number__c='2067982014';
        l2.Phone='0987654321';
          l2.Organizations__c='PSL';
          l2.phone='7276378766';
          l2.lastName ='TestLastName';
          l2.firstName ='TestFirstName';
          ApexPages.StandardController sc2 = new ApexPages.standardController(new Lead()); 
          ApexPages.currentPage().getParameters().put('RecordType',EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect'));
          CreateProspect objl2=new CreateProspect(sc2);
          objl2.lastName='TestLastName';
           objl2.newLeadObj=l2;
           system.debug('l2.id=='+l2.id);
          objl2.saveProspects();

          

                     //insert l;
                 
         
          l.Organizations__c = 'PSL';
          l.Sub_Source_Level_1__c = '';
          l.Sub_Source_Level_2__c = '';
          obj.newLeadObj=l;
          obj.saveProspects();
           
          
      
          l.Sub_Source_Level_2__c ='Stake Sale';
          l.Date_of_News__c=null;
          obj.newLeadObj=l;
          obj.saveProspects();
          
      
          
          l.Sub_Source_Level_2__c ='';
          l.Date_of_News__c=null;
          l.Sub_Source_Level_1__c ='Third Party Intelligence';
          obj.newLeadObj=l;
          obj.saveProspects();
        
        
          
         
          l.Sub_Source_Level_2__c ='';
          l.Date_of_News__c=null;
          l.Sub_Source_Level_1__c ='Third Party Intelligence';
          l.Name_of_Third_Party__c='XYZ';
          obj.newLeadObj=l;
          obj.saveProspects();
        
        
          
          l.Sub_Source_Level_2__c  ='Other Edelweiss Employee';
          l.Sub_Source_Level_1__c ='';
          obj.newLeadObj=l;
          obj.saveProspects();
        
        
        
          l.Sub_Source_Level_1__c = 'Database';
          obj.newLeadObj=l;
          obj.saveProspects();

       
         
 /*
          l.Sub_Source_Level_2__c  ='Other Edelweiss Employee';
          obj.newLeadObj=l;
          obj.saveProspects();
        */
        
          obj.saveProspects();
        
          obj.toggleVisibility();
          l.Organization_Type__c='Listed';
          obj.newLeadObj=l;
        
          obj.toggleVisibility();
          Test.stopTest();
    }

}