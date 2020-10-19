public class ClientRevenueTriggerHandler {

    public static void parseClientRevenueData(List<Client_Revenue__c> lstRevenue){
        
        Set<String> setPAN = new Set<String>();
        Set<Date> setDate = new Set<Date>();
        Map<String, Account> mapClient = new Map<String, Account>();
        Map<String, Client_Revenue__c> mapRevenue = new Map<String, Client_Revenue__c>();
        //Map<String, Client_Revenue__c> mapExistingRevenue = new Map<String, Client_Revenue__c>();
        User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
        
        for(Client_Revenue__c revenue : lstRevenue){
            setPAN.add(revenue.PAN__c);
            //setDate.add(revenue.Revenue_Date__c);
            mapRevenue.put(revenue.RevenueId__c, revenue);
        }
        
        if(!setPAN.isEmpty()){
            for(Account client : [SELECT Id, ParentId, Pan_Number__c, OwnerId FROM Account WHERE RecordType.Name = 'Client' AND PAN_Number__c IN :setPAN]){
                mapClient.put(client.PAN_Number__c, client);
            }
        }
        /*
        if(!setDate.isEmpty()){
            for(Client_Revenue__c rev : [SELECT Id, Revenue_Date__c, PAN__c FROM Client_Revenue__c WHERE Revenue_Date__c IN : setDate]){
                mapExistingRevenue.put(rev.Revenue_Date__c+'_'+rev.PAN__c, rev);
            }
        }
        */
        for(String key : mapRevenue.keySet()){
            Client_Revenue__c newRecord = mapRevenue.get(key);
            Account client = mapClient.get(newRecord.PAN__c);
            /*
            Client_Revenue__c existingRecord = mapExistingRevenue.get(key);
            if(existingRecord != null){
                newRecord.Id = existingRecord.Id;
            }
			*/
            if(client != null){
                newRecord.Client__c = client.Id;
                newRecord.Family__c = client.ParentId;
                newRecord.OwnerId = client.OwnerId;
            }else{
                newRecord.OwnerId = defaultOwner.Id;
            }
        }
        
    }
}