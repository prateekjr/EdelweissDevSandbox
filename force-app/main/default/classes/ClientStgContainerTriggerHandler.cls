public class ClientStgContainerTriggerHandler {

    public static void updateErrorFlag(List<Edelweiss_Clients_Staging_Container__c > stgRecords){
        for(Edelweiss_Clients_Staging_Container__c  record : stgRecords){
            if(String.isBlank(record.ErrorMessage__c)){
                record.Error__c=false;
            }
            else{
                record.Error__c=true;
            }
        }
    }
    public static void updatePOA(List<Edelweiss_Clients_Staging_Container__c > stgRecords){
        for(Edelweiss_Clients_Staging_Container__c Obj : stgRecords){
            if(Obj.Account_Type__c == 'IAS'){
                Obj.POA__c = true;
            }
        }
    }
    
    public static void updateLeadOrClient(List<Edelweiss_Clients_Staging_Container__c > stgRecords){
		List<Account> accList = [Select Id, PAN_Number__c From Account Where PAN_Number__c != null LIMIT 10000];
        Map<String,Id> PANMap = new Map<String,Id>();
        for(Account acc : accList){
            PANMap.put(acc.PAN_Number__c,acc.Id);
        }
		List<User> users = [Select Id, Edelweiss_Employee_Id__c, Miles_Id__c From User Limit 10000];
		Map<String,Id> UserMAp = new Map<String,Id>();
		for(User u : users){
			if(u.Edelweiss_Employee_Id__c != null && u.Miles_Id__c != null)
			UserMAp.put(u.Edelweiss_Employee_Id__c+'--'+u.Miles_Id__c,u.Id);
		}
        for(Edelweiss_Clients_Staging_Container__c  record : stgRecords){
            if(PANMap.containsKey(record.PAN_Number__c)){
                record.Lead_Or_Client__c=PANMap.get(record.PAN_Number__c);
            }
			if(UserMAp.containsKey(record.Primary_FA_Employee_Id__c+'--'+record.Primary_FA_Miles_Id__c)){
				record.FA_Name__c =UserMAp.get(record.Primary_FA_Employee_Id__c+'--'+record.Primary_FA_Miles_Id__c);
			}
			if(UserMAp.containsKey(record.Primary_CXO_Employee_Id__c+'--'+record.Primary_CXO_Miles_Id__c)){
				record.CXO_Name__c =UserMAp.get(record.Primary_CXO_Employee_Id__c+'--'+record.Primary_CXO_Miles_Id__c);
			}
            if(String.isNotEmpty(record.Account_Name__c) && record.Account_Name__c.length() > 80){
                record.Account_Name__c = record.Account_Name__c.subString(0,80);
            }
        }
    }
}