global class Edelweiss_batchUpdateFamilyAUM implements Database.Batchable<sObject>,Database.Stateful  {
    global String strQuery;
    global Id familyRecordTypeId;
    global Id clientRecordTypeId;
    global Map<Id, String> batchErrors {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    public List<Id> InsertedIds;
    global Map<Id,Account> mapFamilyRecord;
     
    /* Constructor */
    global Edelweiss_batchUpdateFamilyAUM(){
        batchErrors = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        InsertedIds = new List<Id>();
        strQuery = 'SELECT Asset_Class__c, Client_Account__c, Product__c, Family__c, Scrip_Key__c, Scrip_Name__c, Source_Id__c, Source_Name__c, Sub_Asset_Class__c, Total_AUM__c, As_On_Date__c,Networth__c FROM Client_Asset_Information__c WHERE Annual_Record__c=false';
        mapFamilyRecord = new Map<Id, Account>([Select id,recordtypeid, Name,GWM_Online_Id__c from Account Where GWM_Online_Id__c !=null AND RecordTypeId =:EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.FAMILY_RECORD_TYPE)]);
    }
    
    /* "Start" runs when the class in instanciated */
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listBatchRecords){
   
        List<Account> processedFamilies = Edelweiss_Integration_Utility.updateFamilyAUMBatch(listBatchRecords);
        if(processedFamilies.size()>0 && processedFamilies != null){
            EdelweissUtils.runOnce();
            Database.SaveResult[] srList = database.update(processedFamilies,false);
             if(srList.size() > 0 ){
                Integer index = 0; 
                for (Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        InsertedIds.add(sr.getId());
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            batchErrors.put(processedFamilies[index].id, err.getMessage() + ',[Fields]: ' + err.getFields());
                            IdToSObjectMap.put(processedFamilies[index].Id, processedFamilies[index]);
                        }
                    }
                    index++;
                }
            }
        }
    }
    global void finish(Database.BatchableContext bcMain){
        /* Start of Added code for handling Communication Rule Insert condition */
        List<Account>updatedAccountList = new List<Account>();
        system.debug('mapFamilyRecord->'+mapFamilyRecord.size());
        for(Id accountId:mapFamilyRecord.keySet()){
            Account newAccountObj = new Account(id = accountId);
            newAccountObj.ClientAssetInformationUpdateCompleted__c = true;
            newAccountObj.Bypass_Validation__c = true;
            updatedAccountList.add(newAccountObj);
        }
        try{
            if(updatedAccountList!=null && updatedAccountList.size()>0){
                AccountTriggerhandler.stopUpdatefamily = true;
                AccountTriggerhandler.stopAccountTrigger = true;
                AccountTriggerhandler.stopSharingRules=true;
                Database.update(updatedAccountList, false);
                Database.executeBatch(new Edelweiss_batchPostAUMFamilyUpdate(), 2000);
            }
        }catch(Exception e){
            system.debug('Exception in Family Update ClientAssetInformationUpdateCompleted : '+e);
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
        }
        /* End of Added code for handling Communication Rule Insert condition */
    }
}