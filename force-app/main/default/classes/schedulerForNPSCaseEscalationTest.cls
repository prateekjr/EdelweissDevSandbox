@isTest
public class schedulerForNPSCaseEscalationTest 
{
    public testmethod static void testexecute() 
    {
         Test.startTest();
	
		 schedulerForNPSCaseEscalation obj = new schedulerForNPSCaseEscalation();   
    	 String chron = '0 0 23 * * ?';        
    	 String jobid = System.schedule('testScheduledApex', chron, obj);

    	 CronTrigger ct = [Select id , CronExpression from CronTrigger where id =:jobId];
    	 System.assertEquals(chron,ct.CronExpression); 
		
		 Test.stopTest();
    }
}