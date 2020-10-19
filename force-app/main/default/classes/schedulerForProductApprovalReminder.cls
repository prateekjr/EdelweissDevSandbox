/*
    Schedule from Apex class scheduler to every day
*/

global class schedulerForProductApprovalReminder implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executeBatch(new BatchForProductApprovalReminder()); 
   }
}