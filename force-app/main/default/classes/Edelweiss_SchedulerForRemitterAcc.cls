global class Edelweiss_SchedulerForRemitterAcc implements Schedulable{

global void execute(SchedulableContext ctx) {
      Database.executeBatch(new Edelweiss_batchDeleteRemitterAccDetails(),200);
      
      
      /*Edelweiss_SchedulerForRemitterAcc  p = new Edelweiss_SchedulerForRemitterAcc();
        String sch = '0 00 19 * * ? *';
        system.schedule('RemitterAccount Schedular', sch, p);*/


    }

}