global class SchedulerForFamilyInteraction_SendEmail implements Schedulable{
    //Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
    //Expression to schedule job at midnight of every last day of month 
    public String CRON_EXP; 
    
    global void execute(SchedulableContext sc){
        //Method to send emails to all FA.
        Id batchProcessId = Database.executeBatch(new BatchForSendEmail_FamilyInteraction(), 2000);
        System.abortJob(sc.getTriggerId());
        //SchedulerForPrimaryFALDBQ.schedule();
    }

    /*
		Integer fiveDaysBeforeLastDay = Date.today().addMonths(1).toStartOfMonth().addDays(-6).day();

		SchedulerForFamilyInteraction_SendEmail scheduler = new SchedulerForFamilyInteraction_SendEmail();
		scheduler.CRON_EXP = '0 0 0 ' + fiveDaysBeforeLastDay + ' * ?';
		String jobId = System.schedule('Send email for Family interaction', scheduler.CRON_EXP, scheduler);

	*/
}