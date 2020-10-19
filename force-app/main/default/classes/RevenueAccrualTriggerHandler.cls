public class RevenueAccrualTriggerHandler {
    public static void parseRevenueData(List<Revenue_Accrual__c> lstRevenue){
        User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
        Set<String> setEmployeeId = new Set<String>();
        Map<String, User> mapUser = new Map<String, User>();
        Map<String, Revenue_Accrual__c> mapRevenue = new Map<String, Revenue_Accrual__c>();
        Set<String> setPAN = new Set<String>();
        Map<String, Account> mapClient = new Map<String, Account>();
        Map<String, Product2> productMapOfScriptAndSource = new Map<String, Product2>();
        Set<String> setofScriptCode = new Set<String>();
        Set<String> setofSourceCode = new Set<String>();
        Set<String> setofScriptName = new Set<String>();
        
        
        for(Revenue_Accrual__c revenue : lstRevenue){
            if(revenue.Edelweiss_Employee_Id__c!=null){
                setEmployeeId.add(revenue.Edelweiss_Employee_Id__c);
            }
            
            //mapRevenue.put(revenue.ProductRevenueId__c, revenue);
            setPAN.add(revenue.PAN__c);
            setofScriptCode.add(revenue.Script_Key__c);
            setofSourceCode.add(revenue.Source_Code__c);
            setofScriptName.add(revenue.Script_Name__c);
        }     
        
        //List<Product2> productList = [SELECt Id, Name, Family, Sub_Asset_Class__c, ProductCode, Source_Id__c FROM Product2 WHERE ProductCode !=null and (ProductCode IN :setofScriptCode OR Source_Id__c IN :setofSourceCode)]; 
        List<Product2> productList = [SELECt Id, Name, Family, Sub_Asset_Class__c, ProductCode, Source_Id__c FROM Product2 WHERE ProductCode !=null and Name IN :setofScriptName];
        
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
        if(productList!=null){
            for(Product2 objsObject:productList ) {
                //productMapOfScriptAndSource.put(string.ValueOf(objsObject.get('ProductCode'))+':'+string.ValueOf(objsObject.get('Source_Id__c')), objsObject);
            productMapOfScriptAndSource.put(objsObject.Name,objsObject);
            }
        }
        String productkey;
        for(Revenue_Accrual__c newRecord : lstRevenue){
            productkey=null;
            //Revenue_Accrual__c newRecord = mapRevenue.get(key);
            User fa = mapUser.get(newRecord.Edelweiss_Employee_Id__c);
            Account client = mapClient.get(newRecord.PAN__c);
            //productkey=newRecord.Script_Key__c+':'+newRecord.Source_Code__c;
            productkey=newRecord.Script_Name__c;
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
            if(productkey!=null){
              Product2 obj= productMapOfScriptAndSource.get(productkey);
                if(obj!=null){
                newRecord.Product__c=obj.Id;
                }
                //newRecord.Product_Percent__c=obj.Revenue_Accrual_Percent__c;
            }
        }
        
    }
    
}