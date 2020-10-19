@istest
public class TrendReportControllerTest {

    public testmethod static void testTrendReportController()
    {
       
        
        Account a=TestClassutils.createAccount();
        insert a;
        a.GWM_Online_Id__c='0985767';
        update a;
        List<User> u = [select id,Miles_Id__c from User where Id =: UserInfo.getUserId()];
        u[0].Miles_Id__c ='001134321';
        update u;
        TestClassUtils.InsertSysPropertiesForTrend();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        TrendReportController trc=new TrendReportController(sc);
         /*Test.startTest();
        
        Test.stopTest();*/
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        

        trc.getsublLobs();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNew());
        trc.selectedSubLob ='19';
        trc.getFAOptions();
        trc.getFamilyOptions();
        trc.getRegionalOptions();
        trc.runReport();
        
        Test.stopTest();
        
    }
    
}