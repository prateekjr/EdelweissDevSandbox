public class ProductRevenueTriggerHandler {
		public static void parseRevenueData(List<ProductRevenue__c> lstRevenue){
        User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
        Set<String> setEmployeeId = new Set<String>();
        Map<String, User> mapUser = new Map<String, User>();
        Map<String, ProductRevenue__c> mapRevenue = new Map<String, ProductRevenue__c>();
        Set<String> setPAN = new Set<String>();
        Map<String, Account> mapClient = new Map<String, Account>();
        
       for(ProductRevenue__c revenue : lstRevenue){
            setEmployeeId.add(revenue.Edelweiss_Employee_Id__c);
            mapRevenue.put(revenue.ProductRevenueId__c, revenue);
            setPAN.add(revenue.PAN__c);
        }     
        
        if(!setPAN.isEmpty()){
            for(Account client : [SELECT Id, ParentId, Pan_Number__c, OwnerId,Primary_TL__c FROM Account WHERE RecordType.Name = 'Client' AND PAN_Number__c IN :setPAN]){
                mapClient.put(client.PAN_Number__c, client);
            }
        }
            
        if(!setEmployeeId.isEmpty()){
            for(User userRecord : [SELECT Id, Edelweiss_Employee_Id__c FROM User WHERE Edelweiss_Employee_Id__c IN :setEmployeeId]){
                mapUser.put(userRecord.Edelweiss_Employee_Id__c, userRecord);
            }
        }
       for(String key : mapRevenue.keySet()){
            ProductRevenue__c newRecord = mapRevenue.get(key);
            User fa = mapUser.get(newRecord.Edelweiss_Employee_Id__c);
            Account client = mapClient.get(newRecord.PAN__c);
           
            if(fa != null){
                newRecord.Primary_FA__c = fa.Id;
                newRecord.OwnerId = fa.Id;
            }else{
                newRecord.Primary_FA__c = defaultOwner.Id;
                newRecord.OwnerId = defaultOwner.Id;
            }
            if(client != null){
                newRecord.Client__c = client.Id;
                newRecord.Family__c = client.ParentId;
                if(client.Primary_TL__c != null){
              newRecord.Primary_TL__c =  client.Primary_TL__c;
           }
            }
        }
        
    }
   
}