global class Edelweiss_IntegrationBatchScheduler implements Schedulable {
 global void execute(SchedulableContext SC){
     
     StagingErrorResult__c FaCxoMappingFlag = StagingErrorResult__c.getValues('FACXO Staging');
     StagingErrorResult__c ProductStagingFlag = StagingErrorResult__c.getValues('Product Staging');
     
     // is there is no error in staging record insertions, delete the records of FA-CXO mapping
     if(!FaCxoMappingFlag.ErrorExist__c){
        database.executeBatch(new  Edelweiss_batchFaCxoMappingDelete(), 200);
        System.debug('DildarLog: FaCxoMappingFlag - '+ FaCxoMappingFlag.ErrorExist__c);
     }
     /*
     if(!ProductStagingFlag.ErrorExist__c){
        database.executeBatch(new  Edelweiss_batchCheckProductMismatch(), 2000);
        System.debug('DildarLog: Flag - '+ ProductStagingFlag.ErrorExist__c);
     }
     */   /*Edelweiss_IntegrationBatchScheduler schedulerObj = new Edelweiss_IntegrationBatchScheduler();
        String cronStr = '0 30 10 * * ?';
        String jobId = System.schedule('Fa-Cxo Mapping records deletion', cronStr, schedulerObj);*/
       
    }
}