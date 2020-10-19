global class BatchToUpdateNPSYTD implements Database.Batchable<sObject>, Database.Stateful {
    global String strQuery;
    global BatchToUpdateNPSYTD(){
        strQuery = 'Select id,Client_Name__c,Date_of_Call__c,Client_Recommendation_on_scale_of__c from Client_Satisfaction_Measurement__c where Date_of_Call__c=THIS_FISCAL_YEAR';
   
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Client_Satisfaction_Measurement__c> listNPS) {
        try{
       createNPSYTDOnAccount(listNPS);
        }
        catch(Exception ex){
            system.debug('BatchToUpdateNPSYTD has errors '+ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext bcMain){
        
    }
public  void createNPSYTDOnAccount(List<Client_Satisfaction_Measurement__c> listNPS)
     {
        List<Id> lstAccIds=  new List<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Account> accountMapAll = new Map<Id,Account>();
        Map<Id,Account> getParentIdMap = new Map<Id,Account>();
        List<Account> lstupdateAccount = new List<Account>();
        List<Account> lstgetParentId = new list<Account>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {
        	if(EdelweissUtils.isDateWithinCurrentFiscalYear(objNPS.Date_of_Call__c)){
           lstAccIds.add(objNPS.Client_Name__c);
        	}
        }
        accountMapAll = new map<Id,Account>([Select Id, NPS_Score_YTD__c,ParentId,NPS_Creation_DateTime__c From Account Where Id In : lstAccIds]);
        Map<Id,Decimal> CurrentNPSValue = new Map<Id,Decimal>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {  
            if(objNPS.Client_Recommendation_on_scale_of__c != null && objNPS.Client_Recommendation_on_scale_of__c != 'No Rating' && EdelweissUtils.isDateWithinCurrentFiscalYear(objNPS.Date_of_Call__c))
            {
            Account acc = accountMapAll.get(objNPS.Client_Name__c);
            acc.NPS_Score_YTD__c = Decimal.valueOf(objNPS.Client_Recommendation_on_scale_of__c) ;
            acc.NPS_Creation_DateTime__c = datetime.now().getTime();
            accountMap.put(acc.id, acc);
            CurrentNPSValue.put(acc.id, acc.NPS_Score_YTD__c);  
            }            
        }  
    //Update Family with avarage NPS score 
        List<Id> lstParentIds = new List<Id>();
        if(accountMap != null && accountMap.values().size() > 0){
          for(Account objAcc: accountMap.values())
          {
             lstParentIds.add(objAcc.ParentId);
          }
        }
        List<Account> lstFamily = [Select Id,NPS_YTD_Family__c,NPS_Creation_DateTime__c,No_of_client_Detractor__c,No_of_Client_NPS_Filled__c,No_of_client_Promoter__c, (Select Id,NPS_Score_YTD__c From ChildAccounts ) From Account Where Id =:lstParentIds];
        
        if(lstFamily != null && lstFamily.size() > 0)
        {           
            for(Account parent :lstFamily)
            {
                List<Account> childs = parent.ChildAccounts;
                integer count = 0;
                integer countDetractor = 0;
                integer countPromoter = 0;
                
                if(childs != null && childs.size() > 0){
                   Decimal totalNPS = 0.00; 
                  for(Account child : childs){
                    if(CurrentNPSValue.get(child.Id) != null){
                      Decimal newNPS = CurrentNPSValue.get(child.Id);
                      totalNPS += newNPS;
                      count++;
                      if(newNPS <= 6)
                        countDetractor++;
                       if(newNPS <= 10 && newNPS > 8)
                        countPromoter++;
                    }else{
                      if(child.NPS_Score_YTD__c !=  null)
                      {
                        totalNPS +=child.NPS_Score_YTD__c;
                        count++;
                        if(child.NPS_Score_YTD__c <= 6)
                            countDetractor++;
                        if(child.NPS_Score_YTD__c <= 10 && child.NPS_Score_YTD__c > 8)
                            countPromoter++;    
                      }
                    }            
                  }
                    if(!CurrentNPSValue.isEmpty()){
                    system.debug('ClientSatisfaction::parent.No_of_client_Detractor__c ::'+parent.No_of_client_Detractor__c);
                    system.debug('ClientSatisfaction::parent.No_of_Client_NPS_Filled__c ::'+parent.No_of_Client_NPS_Filled__c);
                    system.debug('Parent Id :: totalNPS'+parent.Id+'::'+totalNPS+'::'+count);
                    Parent.NPS_Creation_DateTime__c = datetime.now().getTime();
                    parent.NPS_YTD_Family__c = totalNPS/count;                  
                    parent.No_of_client_Detractor__c = countDetractor;
                    parent.No_of_client_Promoter__c = countPromoter;
                    parent.No_of_Client_NPS_Filled__c =count;
                   
                    }
                }
            }
        }
        if(accountMap.values().size() > 0)
        {
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            database.upsert(accountMap.values());
        }
        if(lstFamily != null && lstFamily.size() > 0)
        {
           
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            System.debug('lstFamily:::'+lstFamily);
            database.update(lstFamily);
        }
    }
   
}