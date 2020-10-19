global class Edelweiss_DeleteRevenueAccrualSchedular implements Schedulable {
    global void execute(SchedulableContext SC){
	    	database.executeBatch(new  Edelweiss_batchDeleteRevenueAccrual(), 200);
    }
}