global class Edelweiss_batchNegativeSurveyScheduler implements Schedulable{

global void execute(SchedulableContext ctx) {
      database.executebatch(new Edelweiss_batchSurveyNegativeFeedback());
	}

}