global class ProductMaturityReminderScheduler  implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
		Database.executeBatch(new BatchSendProductMaturityReminders(),100);
	}
}