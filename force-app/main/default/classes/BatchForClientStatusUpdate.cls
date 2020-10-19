global class BatchForClientStatusUpdate implements Database.Batchable<sObject> ,Database.Stateful{
    global String strQuery; 
    global String clientRecordtype=EdelweissConstants.CLIENT_RECORD_TYPE;
    global BatchForClientStatusUpdate() {
       String clientId = EdelweissConstants.AccountRecordTypeMap.get('Client');
       strQuery = 'Select Id, Miles_Account_Status__c,(Select Id,Miles_Account_Status__c from Client_Account__r) From Account Where RecordTypeId IN (\''+clientId+'\')';
       //strQuery = 'Select Id, Miles_Account_Status__c,(Select Id,Miles_Account_Status__c from Client_Account__r) From Account Where id= \'0012800001353cn\' ' ; 
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
      return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<sObject> listBatchRecords) 
    {
        try{
        List<Client_Account__c> childAccounts;
        Map<Id,Account> parentMapToUpdate=new Map<Id,Account>();
        String milesStatus=null;
        Integer closedCount=0;
        Integer activeCount=0;
        Integer othersCount=0;
        Integer childCount=0;
        for(sObject s : listBatchRecords)
        {
         milesStatus=null;
         closedCount=0;
         activeCount=0;
         othersCount=0;
         childCount=0;
            Account acc = (Account)s;
            boolean isFamilyWithoutClient = false;
            if(acc.Client_Account__r != null && acc.Client_Account__r.size() > 0){
                childAccounts=acc.Client_Account__r;
                for(Client_Account__c accObj:childAccounts){
                    childCount++;
                    if(accObj.Miles_Account_Status__c!=null){
                    if(accObj.Miles_Account_Status__c.equalsIgnoreCase(EdelweissConstants.MILES_ACCOUNT_STATUS_ACTIVE)){
                        activeCount++;
                    }else if(accObj.Miles_Account_Status__c.equalsIgnoreCase(EdelweissConstants.MILES_ACCOUNT_STATUS_CLOSED) || accObj.Miles_Account_Status__c.equalsIgnoreCase(EdelweissConstants.MILES_ACCOUNT_STATUS_CLOSE)){
                        closedCount++;
                    }else{
                        othersCount++;
                    }
                    }
                
                }
                if(activeCount>0){
				milesStatus =EdelweissConstants.MILES_ACCOUNT_STATUS_ACTIVE;                 
                }else if(closedCount==childCount & childCount>0 ){
                milesStatus =EdelweissConstants.MILES_ACCOUNT_STATUS_CLOSED;
                }else{
               	milesStatus ='';     
                }
                
            }
            acc.Miles_Account_Status__c=milesStatus;
            parentMapToUpdate.put(acc.Id,acc);
        }
            if(parentMapToUpdate.size()>0){
                update parentMapToUpdate.values();
            } 
        }catch(Exception e){
            system.debug('Exception in Client Update Status : '+e);
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
        }
        
    }
    // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        database.executeBatch(new  BatchForFamilyStatusUpdate(), 1000);
    }
}