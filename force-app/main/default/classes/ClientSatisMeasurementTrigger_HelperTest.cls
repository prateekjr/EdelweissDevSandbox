@istest(SeeAllData=false)
public class ClientSatisMeasurementTrigger_HelperTest {

    public testmethod static void testClientSatisMeasurementTrigger_Helper()
    {
        RecordType recordType = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Account' and RecordType.DeveloperName='Client' LIMIT 1];
         
        TestClassutils.InsertSysProperties();
        Account fam = TestClassutils.createFamily();
        insert fam;
        Account acc=TestClassutils.createAccount();
        acc.RecordTypeId= recordType.id;
        acc.ParentId = fam.id;
        acc.name='Sample Account';
        insert acc;
       
        Client_Satisfaction_Measurement__c csm=new Client_Satisfaction_Measurement__c();
        List<Client_Satisfaction_Measurement__c> GetCSmData = New List<Client_Satisfaction_Measurement__c>();
        csm.Client_Recommendation_on_scale_of__c='4';
        
        csm.Client_Name__c = acc.Id;
        csm.Date_of_Call__c= Date.valueOf('2017-03-13');
        csm.Customer_Sentiment__c ='Negative';
        csm.Investment_Suggestions_As_Requirement__c = 'Yes';
        csm.Financial_advisor_FA_connect__c ='Monthly';
        csm.Satisfied_With_Your_FA__c = 'Yes';
        csm.Queries_requests_resolved_within_time__c = 'No';
        csm.Close_Looping_to_be_Done_by__c = 'FA';
        csm.Nature__c = 'Query';
        csm.NPS_Synopsis__c='KK';
        insert csm;
        
        GetCSmData.add(csm);
        //insert GetCSmData;
        csm.Client_Recommendation_on_scale_of__c='7';
            update GetCSmData;
        csm.Client_Recommendation_on_scale_of__c='10';
            update GetCSmData;
        Test.startTest();
        ClientSatisMeasurementTrigger_Helper.updateNPSValue(GetCSmData);
        Test.stopTest();
    }
}