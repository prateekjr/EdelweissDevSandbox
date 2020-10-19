global class AnniversarySchedular implements Schedulable{

    global void execute(SchedulableContext ctx) {
      database.executebatch(new BatchSendEmployeeAnniversaryMail());
	}
}