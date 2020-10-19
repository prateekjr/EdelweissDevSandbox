@isTest
public class Edelweiss_IntegrationBatchSchedulerTest{
    @istest
    public static void teststart() {
    
        Test.startTest();
        
        StagingErrorResult__c cs = new StagingErrorResult__c();
        cs.Name='FACXO Staging';
        cs.ErrorExist__c = true;
        insert cs;                
        
        StagingErrorResult__c cs1 = new StagingErrorResult__c();
        cs1.Name='Product Staging';
        cs1.ErrorExist__c = true;
        insert cs1;                
        
        Datetime dt = Datetime.now().addMinutes(1);
       // String CRON_EXP = '0 '+ dt.minute() + dt.hour() + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('Sample_Heading1', CRON_EXP, new Edelweiss_IntegrationBatchScheduler());   
            
        test.stopTest();
    }

}