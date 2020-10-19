/*

schedulerForNPSCaseEscalation m = new schedulerForNPSCaseEscalation();
String sch = '0 0 23 * * ? *';
String jobID = system.schedule('scheduler For NPS Case Escalation', sch, m);

*/

global class schedulerForNPSCaseEscalation implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executeBatch(new  Edelweiss_Batch_SendMail_EscalatedCases(), 100);
   }
}