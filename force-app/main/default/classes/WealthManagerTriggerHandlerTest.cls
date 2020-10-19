@isTest
public class WealthManagerTriggerHandlerTest {
 private static Integer c1,c2;
    
     @istest
    public static void testUpdateLead()
    {
        Test.startTest();
        List<Wealth_Manager__c> WMObject=new List<Wealth_Manager__c>();
        List<Lead> LdLst=TestClassUtils.createLead();
        insert LdLst;
        Lead ld=new Lead();
        for(Lead o:LdLst)
            ld=o;
        Wealth_Manager__c WM=new Wealth_Manager__c();
       
        WM=TestClassUtils.createWealth_Manager(ld);
        WMObject.add(WM);
        Wealth_Manager__c WM1=new Wealth_Manager__c();
        WM1=TestClassUtils.createWealth_Manager(ld);
        WMObject.add(WM1);
        insert WMObject;
        
        WMObject=new List<Wealth_Manager__c>();
        WM.Name='Wealth Manager 1';
        WMObject.add(WM);
        WM1.Name='Wealth Manager 2';
        WMObject.add(WM1);
        update WMObject;
        
        WMObject=new List<Wealth_Manager__c>();
        WMObject.add(WM);
        WMObject.add(WM1);
        delete WMObject;
        Test.stopTest();
    }
}