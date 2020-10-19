global class Schedular_ProductIntegration implements Schedulable {
    global void execute(SchedulableContext sc) {
        Edelweiss_batchManageDuplicateProduct b1 = new Edelweiss_batchManageDuplicateProduct();
        ID batchprocessid = Database.executeBatch(b1, 1000);           
    }
}