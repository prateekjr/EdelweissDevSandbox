global class Edelweiss_batchFaCxoMappingDelete implements Database.Batchable<sObject>,Database.Stateful{
    global String strQuery;
    global List<Id> deletedRecs;
    global Integer faCXOMappingCount;
    // Class Constructor - set query string
    global Edelweiss_batchFaCxoMappingDelete() 
    {
        strQuery = 'SELECT id FROM FA_CSO_Mapping__c';
        faCXOMappingCount = Database.countQuery('select count() from FA_CXO_Staging_Container__c');
        deletedRecs = new List<Id>();
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<FA_CSO_Mapping__c> listBatchRecords) 
    {
        StagingErrorResult__c customSetting =StagingErrorResult__c.getValues('FACXO Staging');
        boolean errorExists = false;
        if(customSetting  != null){
            errorExists = customSetting.ErrorExist__c;
        }
        if(listBatchRecords.size() > 0 && listBatchRecords !=null && faCXOMappingCount > 0  && errorExists == false )
        {
            for(FA_CSO_Mapping__c mapping : listBatchRecords){
                    deletedRecs.add(mapping.Id);
                }           
            delete listBatchRecords;
        }
    }
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        /*Sys_Properties__c batchOrder = Sys_Properties__c.getValues('IntegrationBatchProcessOrder');
        if(batchOrder  ==  null){
            batchOrder = new  Sys_Properties__c(name = 'IntegrationBatchProcessOrder');
        }
        batchOrder.value__c = '';
        batchOrder.value__c = 'batchSyncFaCxoMaping'+system.now().format() + '\n';
        upsert batchOrder;*/
        //Edelweiss_Error_Log__c er = new Edelweiss_Error_Log__c (Error_Details__c = 'Edelweiss_batchSyncFaCxoMaping'+system.now() + '' );
        //insert er; 
        Database.executeBatch(new Edelweiss_batchSyncFaCxoMaping(deletedRecs));
        // Optional - you can send an email to an admin with results
    }
}