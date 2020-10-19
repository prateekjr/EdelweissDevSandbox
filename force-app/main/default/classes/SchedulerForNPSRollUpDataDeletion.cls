global class SchedulerForNPSRollUpDataDeletion implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
      database.executebatch(new RollUpBatchToClearNPS(),200);
      //String scheduleString = '0 0 1 1 4 ? *';
      //SchedulerForNPSRollUpDataDeletion  sh1 = new SchedulerForNPSRollUpDataDeletion();
      //system.schedule('NPS Yearly Values CleanUp', scheduleString , sh1);
    }
}