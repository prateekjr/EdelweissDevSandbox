@isTest
public class TestClassUtilsTest{
    public  testmethod static void chkTestUtilityTest(){
        Test.startTest();
        
        TestClassUtils.createTestCaseForMAO();
        TestClassUtils.createTestCaseForSR();
        TestClassUtils.createTestCaseForSROnHold();
        TestClassUtils.createTestCaseForFT();
        TestClassUtils.createLead();
        TestClassUtils.createOpportunity();
        TestClassUtils.createAccount();
        TestClassUtils.LoadMeetingFrequency();
        TestClassUtils.InsertSysProperties();
        
        Test.stopTest();
    }
}