/*
Scheduler_SendMail_Daily_EscalatedCases m = new Scheduler_SendMail_Daily_EscalatedCases ();
String sch = '0 0 24 * * ? *';
String jobID = system.schedule('Scheduler send mail daily for escalated cases', sch, m);

*/

global class Scheduler_SendMail_Daily_EscalatedCases implements Schedulable{
    global void execute(SchedulableContext sc) {
        Edelweiss_Batch_SendMail_EscalatedCases b1 = new Edelweiss_Batch_SendMail_EscalatedCases(true);
        ID batchprocessid = Database.executeBatch(b1);           
    }
}