global class FamilyStatusUpdateScheduler implements Schedulable {
    global void execute(SchedulableContext SC){
        //database.executeBatch(new  BatchForFamilyStatusUpdate(), 1000);
        //First Execute Batch To update Client Status From Client Account and then Family Status update
        database.executeBatch(new  BatchForClientStatusUpdate(), 1000);
        
        }
}