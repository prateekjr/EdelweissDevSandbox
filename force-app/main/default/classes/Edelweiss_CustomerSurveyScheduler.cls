global class Edelweiss_CustomerSurveyScheduler  implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
      database.executebatch(new Edelweiss_batchSendSurvey());
	}
}