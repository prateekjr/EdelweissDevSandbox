global with sharing class Edelweiss_BatchReferrerAccess implements Database.Batchable<sObject> , Database.Stateful{

    global String query;
    global List<User> activeUserList;
    global Map<String, Id> mapEmaiWithlUserId;
    
    global Edelweiss_BatchReferrerAccess(){
        query = 'SELECT Id, ParentId, Referrer_Contact__r.Email FROM Account WHERE RecordType.Name=\'Family\'';
        activeUserList = [SELECT Id, Name, Email FROM User WHERE IsActive = true];
        mapEmaiWithlUserId = new Map<String, Id>();
        for(User u : activeUserList){
            mapEmaiWithlUserId.put(u.Email, u.Id);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> listBatchRecords){
        Map<Id, Account> mapClientRecords = new Map<Id, Account>([
            SELECT Id, ParentId, Referrer_Contact__r.Email FROM Account WHERE RecordType.Name='Client' AND ParentId =:listBatchRecords
        ]);
        
        Map<Id, List<Account>> mapFamilyIdClientList = new Map<Id, List<Account>>();
        for(Account a : mapClientRecords.values()){
            if(mapFamilyIdClientList.get(a.ParentId) == null){
                mapFamilyIdClientList.put(a.ParentId, new List<Account>{a});
            } else {
                mapFamilyIdClientList.get(a.ParentId).add(a);
            }
        }
        for(Account family : listBatchRecords){
            if(family.Referrer_Contact__r.Email != null && mapEmaiWithlUserId.containsKey(family.Referrer_Contact__r.Email)){
                if(mapFamilyIdClientList.get(family.Id) == null){
                    mapFamilyIdClientList.put(family.Id, new List<Account>{family});
                } else {
                    mapFamilyIdClientList.get(family.Id).add(family);
                }
            }
        }
        
        Set<Id> familyAndClientIdSet = new Set<Id>();
        familyAndClientIdSet.addAll(mapClientRecords.keySet());
        familyAndClientIdSet.addAll(mapFamilyIdClientList.keySet());
        List<AccountShare> listInsertAccountShare = new List<AccountShare>();
        Map<String, AccountShare> mapTempAccountShare = new Map<String, AccountShare>();
        List<AccountShare> lstTempAccountShare = [
            SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId = :familyAndClientIdSet AND RowCause = 'Manual'
        ];
        for(AccountShare a : lstTempAccountShare){
            mapTempAccountShare.put(a.AccountId+'_'+a.UserOrGroupId, a);
        }
        
        for(Id familyId : mapFamilyIdClientList.keySet()){
            List<Account> listClient = mapFamilyIdClientList.get(familyId);
            Set<String> referrerEmail = new Set<String>();
            Boolean hasReferrer = false;
            if(listClient != null){
                for(Account c : listClient){
                    if(c.Referrer_Contact__r.Email != null && mapEmaiWithlUserId.containsKey(c.Referrer_Contact__r.Email)){
                        referrerEmail.add(c.Referrer_Contact__r.Email);
                        hasReferrer = true;
                    }
                }
            }
            
            if(hasReferrer){
                for(String email : referrerEmail){
                    if(mapTempAccountShare.get(familyId+'_'+mapEmaiWithlUserId.get(email)) == null){
                        AccountShare accountShareObj = new AccountShare(AccountId=familyId, UserOrGroupId=mapEmaiWithlUserId.get(email), RowCause='Manual', AccountAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read', OpportunityAccessLevel='Read');
                        listInsertAccountShare.add(accountShareObj);
                    }
                    
                    for(Account client : listClient){
                        if(mapTempAccountShare.get(client.Id+'_'+mapEmaiWithlUserId.get(email)) == null){
                            AccountShare accountShareObj = new AccountShare(AccountId=client.Id, UserOrGroupId=mapEmaiWithlUserId.get(email), RowCause='Manual', AccountAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read', OpportunityAccessLevel='Read');
                            listInsertAccountShare.add(accountShareObj);
                        }
                    }
                }
            }
        }
        list<Edelweiss_Error_Log__c> listError = new List<Edelweiss_Error_Log__c>();
           try{
           //Database.SaveResult [] FamilyRes= database.insert(listInsertAccountShare,false);
           
           insert listInsertAccountShare;
               /* for(Database.SaveResult sr : FamilyRes)
                {
                    if(sr.isSuccess()){
                    	
                    }else{
                    	System.debug('Error in'+FamilyRes);
                    }
                }*/
           }catch(exception ex){
           	if(listInsertAccountShare.size()<10){
           	system.debug('Size: '+listInsertAccountShare);
           	}else{
           		system.debug('Size is '+listInsertAccountShare.size());
           	}
           	 Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_BatchReferrerAccess Function : getCompletedMilesAccountOpeningTask(): Case PAN_Number__c ::');
             listError.add(objError);
           }
           
           if(listError != null)
        {
            database.insert(listError);
        }
        
        
      /*  try{
        if(!listInsertAccountShare.isEmpty()){
            insert listInsertAccountShare;
        }
        }catch(exception ex)
            {
            
                Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : getCompletedMilesAccountOpeningTask(): Case PAN_Number__c ::');
                listError.add(objError);
                
            }
            
            if(listError != null)
        {
            database.insert(listError);
        }*/
    }

    global void finish(Database.BatchableContext bcMain){
        
    }
}