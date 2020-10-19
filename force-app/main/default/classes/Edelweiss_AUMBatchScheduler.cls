global class Edelweiss_AUMBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC){
	StagingErrorResult__c AUMStagingMappingFlag= StagingErrorResult__c.getValues('AUM Staging');
    	// Check if AUM data is present in Staging and there is no error in data insertion
        if(!AUMStagingMappingFlag.ErrorExist__c){
        	database.executeBatch(new  Edelweiss_batchClientAssetInfoDelete(), 200);
       	}
	}
}