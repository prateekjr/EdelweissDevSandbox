@istest
public class IPSTriggerHandlerTest
{
    private static testmethod void TestAllMethod()
    {
        Investment_Policy_Statement_IPS__c IPSData = new Investment_Policy_Statement_IPS__c();
        List<Investment_Policy_Statement_IPS__c> lstIPS = new List<Investment_Policy_Statement_IPS__c>();
        List<Id> accIds = New List<Id>();
        Account acc = TestClassUtils.createAccount();
        insert acc;
        IPSData.Client_Name__C = acc.Id;
        IPSData.Risk_Rating__c = 'Conservative';
        IPSData.How_often_does_client_monitor_po__c = '2';
        Map<Id,Investment_Policy_Statement_IPS__c> IPSAccountMap =  new Map<Id,Investment_Policy_Statement_IPS__c>();
        IPSAccountMap.put(IPSData.Client_Name__C,IPSData);
        insert IPSData;
        lstIPS.add(IPSData);
        
        IPSTriggerHandler obj = new IPSTriggerHandler();
        Test.startTest();
        IPSTriggerHandler.updateaccountOnIPSCreation(lstIPS);
        Test.stopTest();
    }

}