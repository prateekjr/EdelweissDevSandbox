global class RollUpBatchToClearPFYNPSData implements Database.Batchable<sObject>, Database.Stateful {
    global String strQuery;
    global RollUpBatchToClearPFYNPSData(){
        strQuery = 'Select id,recordtype.name,name,Client_NPS_Score_Previous_FY__c,Previous_Year_NPS_YTD_Family__c,(SELECT id From Client_Satisfaction_Measurement__r where Date_of_Call__c = LAST_FISCAL_YEAR) from Account where Client_NPS_Score_Previous_FY__c <=0 OR Previous_Year_NPS_YTD_Family__c <=0 ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> listOfAccounts) {
        try{
            List<Account> updateList=new List<Account>();
            For ( Account acc : listOfAccounts ) 
            { 
                if( acc .Client_Satisfaction_Measurement__r.size() == 0 ) 
                { 
                    acc.Client_NPS_Score_Previous_FY__c=null;
                    acc.Previous_Year_NPS_YTD_Family__c=null;
                    updateList.add(acc);
                } 
            }
            if(updateList!=null){
                update updateList;
            }
            
        }
        catch(Exception ex){
            system.debug('RollUpBatchToClearPFYNPSData has errors '+ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bcMain){
        
    }
    
}