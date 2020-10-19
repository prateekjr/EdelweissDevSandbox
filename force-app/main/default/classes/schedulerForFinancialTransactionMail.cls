/*

Schedule from Apex class scheduler to every month 

*/

global class schedulerForFinancialTransactionMail implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executeBatch(new FinancialTransactionMailBatch());
   }
}