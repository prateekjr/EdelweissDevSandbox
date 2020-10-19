global class Edelweiss_batchCloseAccountOpeningCases implements Database.Batchable<sObject>, Database.Stateful {
    
    global String strQuery;
    global Id ACCOUNT_OPENING;
    
    global Edelweiss_batchCloseAccountOpeningCases(){
        Id EXCHANGE_ACCOUNT_OPENING = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId();
        Id FUNDING_ACCOUNT_OPENING = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId();
        Id NON_EXCHANGE_ACCOUNT_OPENING = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId();
		ACCOUNT_OPENING = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId();	        
 
		strQuery = 'SELECT Id, PAN_Number__c, AccountId, Account.PAN_Number__c, Remarks__c, Account.RecordTypeId, RecordTypeId, IsNewClient__c, IsNewFamily__c, (SELECT Id, Subject FROM ActivityHistories WHERE Subject=\'Miles Account Opening\' OR Subject=\'Miles Account Opening Auto Closure\') , (SELECT Id FROM OpenActivities), (SELECT Id, Name, PAN_Number__c, Case__c FROM Additional_Leads__r WHERE Converted_To_Client__c = FALSE) FROM Case WHERE PAN_Number__c != null AND RecordTypeId IN (\''+EXCHANGE_ACCOUNT_OPENING+'\','+'\''+FUNDING_ACCOUNT_OPENING+'\','+'\''+NON_EXCHANGE_ACCOUNT_OPENING +'\','+'\''+ACCOUNT_OPENING +'\') And Status in (\''+EdelweissConstants.IN_PROGRESS_STATUS+'\','+'\''+EdelweissConstants.CASE_OPEN_STATUS+'\','+'\''+EdelweissConstants.CASE_ON_HOLD_STATUS+'\','+'\''+EdelweissConstants.CASE_ESCALATED_STATUS +'\')';
        system.debug(strQuery);
        system.debug('Inside Constructor');
    }

     global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        system.debug('Inside Start'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Case> listOfCase) 
    {
    	Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
    	List<String> listOfPan = new List<String>();
    	List<Case> updatedCases = new List<Case>();
    	Map<String, Id> mapPanID = new Map<String, Id>();
        
        for(Case c : listOfCase){
            listOfPan.add(c.Pan_Number__c);
        }
        
        List<Account> lstClient = [
            SELECT Id, Pan_Number__c FROM Account 
            WHERE RecordTypeId = :clientRecordTypeId
            AND Pan_Number__c IN :listOfPan
        ];
        
        for(Account acc : lstClient){
            mapPanID.put(acc.Pan_Number__c, acc.Id);
        }
        
        for(Case c : listOfCase){
            if(!c.ActivityHistories.isEmpty() && c.OpenActivities.isEmpty() && c.Additional_Leads__r.isEmpty() && mapPanID.containsKey(c.PAN_Number__c)){
                c.Status = EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS;
                c.Remarks__c = String.isEmpty(c.Remarks__c) ? '[Case closed by integration]' : c.Remarks__c+' [Case closed by integration]';
                updatedCases.add(c);
            }
            else if(c.RecordTypeId == ACCOUNT_OPENING && c.OpenActivities.isEmpty() && mapPanID.containsKey(c.PAN_Number__c) && !c.IsNewClient__c && !c.IsNewFamily__c){
                c.Status = EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS;
                c.Remarks__c = String.isEmpty(c.Remarks__c) ? '[Case closed by integration]' : c.Remarks__c+' [Case closed by integration]';
                updatedCases.add(c);
            }
        }
      	system.debug('*** List to be updated'+updatedCases);
        if(!updatedCases.isEmpty()){
           Database.update(updatedCases, false);
        }
      	 
    }

    global void finish(Database.BatchableContext bcMain){
        Database.executeBatch(new Edelweiss_BatchReferrerAccess(), 100);
    }
}