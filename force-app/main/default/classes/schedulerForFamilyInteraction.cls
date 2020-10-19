//schedulerForFamilyInteraction m = new schedulerForFamilyInteraction();
//String sch = '0 30 23 L * ?';
//String jobID = system.schedule('schedulerForFamilyInteraction', sch, m);
global class schedulerForFamilyInteraction implements Schedulable {
   global void execute(SchedulableContext SC) {
        database.executeBatch(new  BatchForFamilyInteraction(), 2000);
        
   }
}