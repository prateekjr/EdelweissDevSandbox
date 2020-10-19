/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Client_AccountTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Client_AccountTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Client_Account__c());
    }
}