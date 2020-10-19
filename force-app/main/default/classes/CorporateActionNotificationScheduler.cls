global class CorporateActionNotificationScheduler  implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
	database.executeBatch(new  DeleteCorporateActions());
	}
}