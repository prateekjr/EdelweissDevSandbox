global class Edelweiss_SchedularDeleteErrorLogs implements Schedulable{

    global void execute(SchedulableContext ctx) {
      database.executebatch(new Edelweiss_BatchDeleteErrorLogs() , 6000);
	}
}