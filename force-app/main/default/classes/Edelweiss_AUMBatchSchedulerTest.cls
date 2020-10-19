@isTest

public with sharing class Edelweiss_AUMBatchSchedulerTest {
    public testmethod static void TestEdelweiss_AUMBatchScheduler()
    {
        Test.startTest();
        Edelweiss_Integration_Utility.chornExpression(1);
        
        StagingErrorResult__c cs = new StagingErrorResult__c();
        cs.Name='AUM Staging';
        cs.ErrorExist__c = true;
        insert cs;        
        //StagingErrorResult__c AUMStagingMappingFlag= StagingErrorResult__c.getValues('AUM Staging');
        //if(AUMStagingMappingFlag != null){
            Edelweiss_AUMBatchScheduler sh1 = new Edelweiss_AUMBatchScheduler();      
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('Sample_Heading1', CRON_EXP, new Edelweiss_AUMBatchScheduler());   
        //}
        Test.stopTest();    
    }
}