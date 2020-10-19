global class EmployeeBirthdaySchedular  implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
      database.executebatch(new Edelweiss_batchSendEmployeeBirthdayMail());
	}
}