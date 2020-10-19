global class Scheduler_SendMail_EscalatedCases implements Schedulable{
    global void execute(SchedulableContext sc) {
        Edelweiss_Batch_SendMail_EscalatedCases b1 = new Edelweiss_Batch_SendMail_EscalatedCases();
        ID batchprocessid = Database.executeBatch(b1);           
    }
}