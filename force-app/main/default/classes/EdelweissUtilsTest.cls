@isTest
private class EdelweissUtilsTest {
   @istest
   public  static void TestCheckDependency()
   {
       List<Case> caselist=TestclassUtils.createTestCaseForFT();
       EdelweissUtils.CheckDependency('',caselist[0]);
   }
}