global class Schedular_SendMail_UnicaCases implements Schedulable {
    global void execute(SchedulableContext sc) {
        Edelweiss_BatchSendMail_UnicaCases b1 = new Edelweiss_BatchSendMail_UnicaCases();
        ID batchprocessid = Database.executeBatch(b1);           
    }
}