global class Edelweiss_batchCaseUpdateScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
       database.executeBatch(new  Edelweiss_batchCaseUpdate(), 2000);
       Edelweiss_batchCaseUpdateScheduler batch = new Edelweiss_batchCaseUpdateScheduler();
       //String cronStr = '0 5 * * * ?';
       //String jobId = System.schedule('Process Case Update', cronStr, batch);
       /*Datetime sysTime = System.now().addMinutes(5);      
       String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
       System.schedule( 'Financial Task Closure ' + sysTime, chronExpression, new Edelweiss_batchCaseUpdateScheduler() );*/
    }
}