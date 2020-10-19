global class Edelweiss_SchedulerForNonPOAIntegration implements Schedulable{

global void execute(SchedulableContext ctx) {
      database.executeBatch(new  Edelweiss_batchDeleteNonPOABankDetails(), 200);
	}

}