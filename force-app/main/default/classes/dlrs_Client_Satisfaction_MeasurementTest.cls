/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Client_Satisfaction_MeasurementTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Client_Satisfaction_Measua0CTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Client_Satisfaction_Measurement__c());
    }
}