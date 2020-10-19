global class SchedulerForPFYNPSDataDeletion implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
      database.executebatch(new RollUpBatchToClearPFYNPSData(),200);
      //String scheduleString = '0 0 5 1 4 ? *';
      //SchedulerForPFYNPSDataDeletion  sh1 = new SchedulerForPFYNPSDataDeletion();
      //system.schedule('NPS Yearly Values CleanUp', scheduleString , sh1);
    }
}