global class BatchForFamilyWithoutClient implements Database.Batchable<sObject>{
    
   global final String Query;

   global BatchForFamilyWithoutClient(){
        String FamilyId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        
        Query = 'Select Id,Name,OwnerId,Is_Family_Without_Client__c,Primary_FA__c,Primary_CXO__c, (Select Id, Name, Primary_FA__c from ChildAccounts), (Select Id, CaseNumber,OwnerId From Cases) From Account Where RecordTypeId IN (\''+FamilyId+'\')';
        system.debug('--->'+query);
      
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('--->'+query);     
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        // new Added client to update sharing and Owner
        List<Account> FamilyWithClient = new List<Account>();
        List<Case> caseTobeUpadte = new List<Case>();
        List<Id> caseIdDeleteSharing = new List<Id>();
        List<FA_CSO_Mapping__c> lstcso = [Select FA_User__c, CSO_User__c, IsActive__c from FA_CSO_Mapping__c Where IsActive__c = true Limit 5000];
        Map<Id,Id> FACSOId = new Map<Id,Id>();  
        for(FA_CSO_Mapping__c fc : lstcso){
            FACSOId.put(fc.FA_User__c, fc.CSO_User__c);
        }
        for(sObject s : scope)
        {
            Account acc = (Account)s;
            boolean isFamilyWithoutClient = false;
            if(acc.ChildAccounts != null && acc.ChildAccounts.size() > 0){
                if(acc.Is_Family_Without_Client__c){
                    isFamilyWithoutClient = true;
                    acc.Is_Family_Without_Client__c = false;
                    acc.OwnerId = acc.Primary_FA__c = acc.ChildAccounts[0].Primary_FA__c;
                    FamilyWithClient.add(acc);
                }               
            }
            if(acc.Cases != null && acc.Cases.size() > 0){
                if(isFamilyWithoutClient){
                    for(case c : acc.Cases){
                        if(FACSOId.get(acc.OwnerId)  != null){
                            c.OwnerId = FACSOId.get(acc.OwnerId);
                            caseTobeUpadte.add(c);
                        }                           
                    }                   
                }               
            }
            
        }
        
        if(FamilyWithClient != null && FamilyWithClient.size() > 0){
            database.update(FamilyWithClient,true);
        }
        
        
        // Family Without Client Update Account. 
        List<Account> familyWithoutClientUpdate = new List<Account>();
        List<Id> accIds = new List<Id>();
        List<User> users = [SELECT Id,Name FROM User WHERE Profile.Name = 'System Administrator'];
        Map<Id,User> UserIdMap = new Map<Id,User>();
        Map<String,User> UserNameMap = new Map<String,User>();
        for(User u :users){
            UserIdMap.put(u.Id,u);
            UserNameMap.put(u.Name,u);
        }
        
        for(sObject s : scope)
        {
            Account acc = (Account)s;
            if(acc.ChildAccounts.size() == 0){

                if(UserNameMap != null && UserNameMap.get('PWM SalesForceUpdate') != null){
                    acc.OwnerId = acc.Primary_FA__c = UserNameMap.get('PWM SalesForceUpdate').Id;
                }else{
                    acc.OwnerId = acc.Primary_FA__c = users[0].Id;
                }                   
                acc.Primary_CXO__c = null;
                acc.Is_Family_Without_Client__c = true;
                familyWithoutClientUpdate.add(acc);
                accIds.add(acc.Id);
                
                if(acc.Cases != null && acc.Cases.size() > 0){
                    for(case c : acc.Cases){
                        if(UserNameMap != null && UserNameMap.get('PWM SalesForceUpdate') != null){
                            c.OwnerId = UserNameMap.get('PWM SalesForceUpdate').Id;
                        }else{
                            c.OwnerId = users[0].Id;
                        }
                        caseIdDeleteSharing.add(c.id);                      
                        caseTobeUpadte.add(c);
                    }       
                }
                
            }
        } 
        system.debug('familyWithoutClientUpdate===='+familyWithoutClientUpdate);
        system.debug('accIds===='+accIds);
        
        if(familyWithoutClientUpdate != null && familyWithoutClientUpdate.size() > 0){
            database.update(familyWithoutClientUpdate,false);
        }
        if(caseTobeUpadte != null && caseTobeUpadte.size() > 0){
            database.update(caseTobeUpadte,true);
        }
        List<AccountShare > sharesToDelete =  new List<AccountShare >();
        if(accIds != null && accIds.size() > 0){
            sharesToDelete = [Select Id, AccountId From AccountShare where AccountId=: accIds And RowCause = 'Manual'];
        }
        system.debug('sharesToDelete===='+sharesToDelete);
        if (!sharesToDelete.isEmpty()) {
            delete sharesToDelete;
        }
        
        //Delete Case manual sharing record in case of FamilyWithoutClient
        List<CaseShare > caseSharesToDelete =  new List<CaseShare >();
        if(caseIdDeleteSharing != null && caseIdDeleteSharing.size() > 0){
            caseSharesToDelete = [Select Id,CaseId From CaseShare where CaseId=: caseIdDeleteSharing And RowCause = 'Manual'];
        }      
        if (!caseSharesToDelete.isEmpty()) {
            delete caseSharesToDelete;
        }
     
    }

   global void finish(Database.BatchableContext BC){
       Database.executeBatch(new Edelweiss_batchCloseAccountOpeningCases(), 50);
   }
}