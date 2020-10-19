global class PostRefreshAccountMasking implements Database.Batchable<sObject>, Database.Stateful  {    
    global String strQuery;
    global PostRefreshAccountMasking(){
	strQuery = 'SELECT id ,Business_Head_Email__c ,Secondary_Email__c ,Client_Representative_Email_Id__c,Email_Id_of_CR__c,Official_Email__c , Primary_Email__c ,Regional_Head_Email__c,  Secondary_Email_Id_Of_CR__c FROM Account' ;        system.debug(strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> allAccountsToBeMasked) {
        List<Account> toBeUpdated = new List<Account>();
        Boolean isChanged = false;
        for(Account cObj : allAccountsToBeMasked){
            
          if(cObj.Business_Head_Email__c != null){
                cObj.Business_Head_Email__c = '111'+cObj.Business_Head_Email__c  ;
                isChanged = true;
            }
            
            if(cObj.Secondary_Email__c != null){
                cObj.Secondary_Email__c = '111'+cObj.Secondary_Email__c  ;
                isChanged = true;
            }
            
            if(cObj.Client_Representative_Email_Id__c != null){
                cObj.Client_Representative_Email_Id__c = '111'+cObj.Client_Representative_Email_Id__c  ;
                isChanged = true;
            }
            
            if(cObj.Email_Id_of_CR__c != null){
                cObj.Email_Id_of_CR__c = '111'+cObj.Email_Id_of_CR__c  ;
                isChanged = true;
            }
            if(cObj.Official_Email__c != null){
                cObj.Official_Email__c = '111'+cObj.Official_Email__c  ;
                isChanged = true;
            }
            if(cObj.Primary_Email__c != null){
                cObj.Primary_Email__c = '111'+cObj.Primary_Email__c  ;
                isChanged = true;
            }
            if(cObj.Regional_Head_Email__c != null){
                cObj.Regional_Head_Email__c = '111'+cObj.Regional_Head_Email__c  ;
                isChanged = true;
            }
            if(cObj.Secondary_Email_Id_Of_CR__c != null){
                cObj.Secondary_Email_Id_Of_CR__c = '111'+cObj.Secondary_Email_Id_Of_CR__c  ;
                isChanged = true;
            }
            
            if(isChanged){
                toBeUpdated.add(cObj);
            }
            
            
        }
        database.update(toBeUpdated,false);
    }   
    global void finish(Database.BatchableContext bcMain){}
}