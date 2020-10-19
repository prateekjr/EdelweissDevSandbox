global class PostRefreshContactMasking implements Database.Batchable<sObject>, Database.Stateful  {    
    global String strQuery;
    global PostRefreshContactMasking(){
        strQuery = 'SELECT id ,Official_Email__c,Primary_Email__c,Secondry_Email__c,Email FROM Contact' ;        
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Contact> toBeMasted) {
        List<Contact> toUpdated = new List<Contact> ();
        for(Contact eObj : toBeMasted){
            Boolean isChanged = false;
            if(eObj.Official_Email__c != null){
                eObj.Official_Email__c = '111'+eObj.Official_Email__c  ;
                isChanged = true;
            }    
            if(eObj.Primary_Email__c != null){
                eObj.Primary_Email__c = '111'+eObj.Primary_Email__c  ;
                isChanged = true;
            }  
            if(eObj.Secondry_Email__c != null){
                eObj.Secondry_Email__c = '111'+eObj.Secondry_Email__c  ;
                isChanged = true;
            }  
            if(eObj.Email != null){
                eObj.Email = '111'+eObj.Email  ;
                isChanged = true;
            }  
            if(isChanged){
                toUpdated.add(eObj);
            }
            
        }
        Database.update(toUpdated , false);
    }   
    global void finish(Database.BatchableContext bcMain){}
}