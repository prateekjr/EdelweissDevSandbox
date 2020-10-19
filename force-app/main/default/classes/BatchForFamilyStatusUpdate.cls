global class BatchForFamilyStatusUpdate implements Database.Batchable<sObject> ,Database.Stateful{
    global String strQuery; 
    global String clientRecordtype=EdelweissConstants.CLIENT_RECORD_TYPE;
    global BatchForFamilyStatusUpdate() {
       String familyId = EdelweissConstants.AccountRecordTypeMap.get('Family');
       strQuery = 'Select Id, Miles_Account_Status__c,Mandate__c, Is_Family_Without_Client__c ,(Select Id,Is_Client_Family_Head__c, Recordtype.Name, Miles_Account_Status__c,Mandate__c from ChildAccounts) From Account Where RecordTypeId IN (\''+familyId+'\')';
       //strQuery = 'Select Id, Miles_Account_Status__c,Mandate__c, Is_Family_Without_Client__c ,(Select Id, ,Is_Client_Family_Head__cRecordtype.Name,Miles_Account_Status__c from ChildAccounts) From Account Where id= \'0010K00001ix9Rz\' ' ; 
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
        List<Account> childAccounts;
        Map<Id,Account> parentMapToUpdate=new Map<Id,Account>();
        String milesStatus=null;
        boolean mandate=false;
        Integer closedCount=0;
        Integer activeCount=0;
        Integer othersCount=0;
        Integer childCount=0;
        Integer mandateCount=0;
        Id familyHeadId=null;
        for(sObject s : listBatchRecords)
        {
         milesStatus=null;
         closedCount=0;
         activeCount=0;
         othersCount=0;
         childCount=0;
         familyHeadId=null;
            Account acc = (Account)s;
            boolean isFamilyWithoutClient = false;
            if(acc.ChildAccounts != null && acc.ChildAccounts.size() > 0){
                childAccounts=acc.ChildAccounts;
                for(Account accObj:childAccounts){
                    
                    if(accObj.Recordtype.Name==clientRecordtype){
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
                    if(accObj.Mandate__c){
                    	mandate=true;
                    }else{
                    	mandateCount++;
                    }
                }
                //Check for Family Head
                if(accObj.Is_Client_Family_Head__c==EdelweissConstants.IS_CLIENT_HEAD_YES ){
                    familyHeadId=accObj.Id;
                }
                }
                
                if(activeCount>0){
				milesStatus =EdelweissConstants.MILES_ACCOUNT_STATUS_ACTIVE;                 
                }else if(closedCount==childCount & childCount>0 ){
                milesStatus =EdelweissConstants.MILES_ACCOUNT_STATUS_CLOSED;
                }else{
               	milesStatus ='';     
                }
                
                if(mandateCount==childCount && childCount>0){
                	mandate=false;
                }
                
                
            }
            acc.Miles_Account_Status__c=milesStatus;
            acc.Mandate__c=mandate;
           	acc.Family_Head_Name__c =familyHeadId;
            
            parentMapToUpdate.put(acc.Id,acc);
        }
            if(parentMapToUpdate.size()>0){
                update parentMapToUpdate.values();
            } 
        }catch(Exception e){
            system.debug('Exception in Family Update Status : '+e);
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
        Database.executeBatch(new BatchToUpdateInteractionDetails(),200);
    }
}