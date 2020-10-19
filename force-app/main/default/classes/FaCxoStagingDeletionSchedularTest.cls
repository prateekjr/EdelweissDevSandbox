@isTest
public class FaCxoStagingDeletionSchedularTest{
    @istest
    public static void testFaCxoStagingDeletionSchedular() {
    
        Test.startTest();
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading1', CRON_EXP, new FaCxoStagingDeletionSchedular());   
            
        test.stopTest();
    }

}