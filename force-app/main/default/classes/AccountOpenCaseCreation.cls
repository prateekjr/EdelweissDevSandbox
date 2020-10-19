public class AccountOpenCaseCreation {
    @AuraEnabled 
    public static Map<String,String> getRecordTypeInfo(){
        Map<String,String> MapRecordType = new Map<String,String>();
        List<RecordType> RecordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case'];
        for(RecordType rt : RecordTypeList){
            string strId = rt.Id;
            strId = strId.substring(0,15);
            MapRecordType.put(strId,rt.Name);
        }
        return MapRecordType;

    }
    
    @AuraEnabled 
    public static Map<Integer,String> SaveAllCases(List<Case> Cases){
        system.debug('Cases--'+Cases);
        Map<Integer,String> returnMap = new Map<Integer,String>();
        if(Cases != null && Cases.size() > 0){
            
            Boolean hasFamilyHead = false;
            List<Id> mainLead = new List<Id>();
            List<Id> mainLead2 = new List<Id>();
            for(Case c : Cases){
                if(c.Product_Type__c != null && !c.Product_Type__c.contains('Demat') || (c.Single_Joint__c=='Single' && c.Product_Type__c.contains('Demat'))){ 
                   // c.Joint_Holder_Client1_Aadhar_Number__c = null;
                    c.Joint_Holder_Client1_Contact_Number__c = null;
                    c.Joint_Holder_Client1_DOB_DOI__c = null;
                    c.Joint_Holder_Client1_Email_ID__c = null;
                    c.Joint_Holder_Client1_Entity_Type__c = null;
                    c.Joint_Holder_Client1_Name__c = null;
                    c.Joint_Holder_Client1_PAN_Number__c = null;
                   //c.Joint_Holder_Client2_Aadhar_Number__c = null;
                    c.Joint_Holder_Client2_Contact_Number__c = null;
                    c.Joint_Holder_Client2_DOB_DOI__c = null;
                    c.Joint_Holder_Client2_Email_ID__c = null;
                    c.Joint_Holder_Client2_Entity_Type__c = null;
                    c.Joint_Holder_Client2_Name__c = null;
                    c.Joint_Holder_Client2_PAN_Number__c = null;
                    c.Number_of_Joint_Holders_Max_2__c = null;
                } else if(c.Product_Type__c != null && c.Product_Type__c.contains('Demat') && c.Number_of_Joint_Holders_Max_2__c=='1'){
                   // c.Joint_Holder_Client2_Aadhar_Number__c = null;
                    c.Joint_Holder_Client2_Contact_Number__c = null;
                    c.Joint_Holder_Client2_DOB_DOI__c = null;
                    c.Joint_Holder_Client2_Email_ID__c = null;
                    c.Joint_Holder_Client2_Entity_Type__c = null;
                    c.Joint_Holder_Client2_Name__c = null;
                    c.Joint_Holder_Client2_PAN_Number__c = null;
                }
                
                if(c.MainLead__c != null && String.isBlank(c.Family__c)){
                    mainLead.add(c.MainLead__c);
                }
                if(c.Is_Family_Head__c){
                    hasFamilyHead = true;
                    mainLead2.add(c.MainLead__c);
                }
            }
            
            if(!mainLead.isEmpty()){
                Map<Id, Account> mapAccount = new Map<Id, Account>([
                    SELECT Id, Name, RecordType.Name, Parent.Name FROM Account WHERE Id =: mainLead
                ]);
                
                for(Case c : Cases){
                    if(!mapAccount.isEmpty() && String.isBlank(c.Family__c)){
                        Account a = mapAccount.get(c.MainLead__c);
                        if(a != null){
                            if(a.RecordType.Name == 'Family'){
                                c.Family__c = ((a.Name).length() > 50) ? (a.Name).substring(0, 50) : a.Name;
                            }
                            else if(a.RecordType.Name == 'Client'){
                                c.Family__c = ((a.Parent.Name).length() > 50) ? (a.Parent.Name).substring(0, 50) : a.Parent.Name;
                            }
                        }
                    }                
                }
            }
            
            if(!mainLead2.isEmpty()){
                 List<Account> lstAccount = [
                    SELECT Id, Name, (SELECT Id FROM Cases WHERE RecordType.Name='Account Opening') FROM Account WHERE Id =: mainLead2
                ];
                Boolean mainLeadExist = false;
                if(!lstAccount.isEmpty()){
                    for(Account acc : lstAccount){
                        if(acc.Cases != null && !acc.Cases.isEmpty()){
                            mainLeadExist = true;
                        }
                    }
                }
                if(mainLeadExist){
                    for(Case c : Cases){
                        if(c.Is_Family_Head__c){
                            c.Is_Family_Head__c = false;
                        }
                    }
                }
            }
            
            List<Database.SaveResult> results = new List<Database.SaveResult>(); 
            Savepoint sp = Database.setSavepoint();
            results = database.insert(Cases,false);
            integer index = 0;
            boolean isRollBack = true;
            system.debug('results--'+results);
            for(Database.SaveResult sr : results){
                if (sr.isSuccess()) {                   
                    returnMap.put(index,'SUCCESS--'+sr.getId());
                }
                else {
                    if(isRollBack){
                        Database.rollback(sp);
                        isRollBack = false;
                    }
                    String strMsg = '';               
                    for(Database.Error err : sr.getErrors()) {
                        strMsg = strMsg + err.getMessage(); 
                    } 
                    returnMap.put(index,'ERROR--'+strMsg);
                }
                index++;
            }
            system.debug(results);
        }
        return returnMap;
    }
}