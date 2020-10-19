global class RollUpBatchToClearNPS implements Database.Batchable<sObject>, Database.Stateful {
    global String strQuery;
    global RollUpBatchToClearNPS(){
        strQuery = 'SELECT Id,Client_NPS_Score_YTD__c,Family_NPS_Score_YTD__c,Previous_Year_NPS_YTD_Family__c,Client_NPS_Score_Previous_FY__c FROM Account WHERE Client_NPS_Score_YTD__c != null OR Family_NPS_Score_YTD__c != null OR Client_NPS_Score_Previous_FY__c!=null OR Previous_Year_NPS_YTD_Family__c!=null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> listOfAccounts) {
        try{
        List<Account> tobeUpdated = new List<Account>();   
        for(Account acc : listOfAccounts){
            acc.Client_NPS_Score_YTD__c =null;
			acc.Family_NPS_Score_YTD__c =null;
            acc.Client_NPS_Score_Previous_FY__c =null;
            acc.Previous_Year_NPS_YTD_Family__c =null;
            
            tobeUpdated.add(acc);
            }
            
        	update(tobeUpdated);
        }
        catch(Exception ex){
            system.debug('RollUpBatchToClearNPS has errors '+ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext bcMain){
        
    }

}