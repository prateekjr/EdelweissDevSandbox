global class SchedulerForPrimaryFALDBQ implements Schedulable{
	
    //Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
    //Expression to schedule job at midnight of every last day of month 
    public String CRON_EXP = '0 0 0 L * ?';
    
    global void execute(SchedulableContext sc){
        //Method to send emails to all FA.
        Id batchProcessId = Database.executeBatch(new SendEmailToPrimaryFAforLDBQ(), 2000);
        System.abortJob(sc.getTriggerId());
        //SchedulerForPrimaryFALDBQ.schedule();
    }
}

/*public static void schedule(){
        SchedulerForPrimaryFALDBQ scheduler = new SchedulerForPrimaryFALDBQ();
        String jobId = System.schedule('Send email to FA', scheduler.CRON_EXP, scheduler);
}*/