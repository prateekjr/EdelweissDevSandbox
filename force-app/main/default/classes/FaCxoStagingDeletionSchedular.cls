global class FaCxoStagingDeletionSchedular implements Schedulable {
    
    global void execute(SchedulableContext SC){
       database.executeBatch(new  BatchDeleteFromFaCxoStagingContainer(), 200);
       /*FaCxoStagingDeletionSchedular schedulerObj = new FaCxoStagingDeletionSchedular();
       String cronStr = '0 0 9 * * ?';
       String jobId = System.schedule('Staging records deletion', cronStr, schedulerObj);*/
       
    }
}