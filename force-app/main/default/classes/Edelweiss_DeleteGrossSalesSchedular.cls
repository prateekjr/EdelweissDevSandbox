global class Edelweiss_DeleteGrossSalesSchedular implements Schedulable {
    global void execute(SchedulableContext SC){
	    	database.executeBatch(new  Edelweiss_batchDeleteGrossSalesData(), 200);
    }
}