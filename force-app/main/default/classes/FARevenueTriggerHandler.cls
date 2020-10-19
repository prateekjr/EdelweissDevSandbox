public class FARevenueTriggerHandler {
	
    public static void parseFARevenueData(List<FA_Revenue__c> lstRevenue){
        
        Set<String> setEmployeeId = new Set<String>();
        Set<Date> setDate = new Set<Date>();
        Map<String, User> mapUser = new Map<String, User>();
        Map<String, FA_Revenue__c> mapRevenue = new Map<String, FA_Revenue__c>();
        User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
        
        for(FA_Revenue__c revenue : lstRevenue){
            setEmployeeId.add(revenue.Edelweiss_Employee_Id__c);
            mapRevenue.put(revenue.RevenueId__c, revenue);
        }
        
        if(!setEmployeeId.isEmpty()){
            for(User userRecord : [SELECT Id, Edelweiss_Employee_Id__c FROM User WHERE Edelweiss_Employee_Id__c IN :setEmployeeId]){
                mapUser.put(userRecord.Edelweiss_Employee_Id__c, userRecord);
            }
        }

        for(String key : mapRevenue.keySet()){
            FA_Revenue__c newRecord = mapRevenue.get(key);
            User fa = mapUser.get(newRecord.Edelweiss_Employee_Id__c);
            
            if(fa != null){
                newRecord.Financial_Adviser__c = fa.Id;
                newRecord.OwnerId = fa.Id;
            }else{
                newRecord.OwnerId = defaultOwner.Id;
            }
        }
        
    }
}