@istest
public with sharing class OpportunityManagementTest {
    public testmethod static  void TestOpportunityManagement()
    {
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Ongoing';
        opp.Amount = 500;
        opp.CloseDate = Date.today();
        
        insert opp;
        
        opp.Amount = 600;
        update opp;
        
        Test.stopTest();
        
    }
}