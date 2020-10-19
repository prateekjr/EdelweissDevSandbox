public class GrossSalesTriggerHandler {
    
    public static void parseGrossSalesData(List<Gross_Sales_Details__c> lstRevenue){
        
        Set<String> setPAN = new Set<String>();
        Set<Date> setDate = new Set<Date>();
        Map<String, Account> mapClient = new Map<String, Account>();
        Map<String, Gross_Sales_Details__c> mapRevenue = new Map<String, Gross_Sales_Details__c>();
        User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
        Map<String, Product2> productMapOfScriptName = new Map<String, Product2>();
        Set<String> setofScriptName = new Set<String>();
        
        for(Gross_Sales_Details__c detailObj : lstRevenue){
            setPAN.add(detailObj.Pan_No__c);
            setofScriptName.add(detailObj.Security_Name__c);
        }
        
        if(!setPAN.isEmpty()){
            for(Account client : [SELECT Id, ParentId, Pan_Number__c, OwnerId FROM Account WHERE RecordType.Name = 'Client' AND PAN_Number__c IN :setPAN]){
                mapClient.put(client.PAN_Number__c, client);
            }
        }
        
        if(!setofScriptName.isEmpty()){
            for(Product2 objsObject:[SELECt Id, Name, Family, Sub_Asset_Class__c, ProductCode, Source_Id__c FROM Product2 WHERE ProductCode !=null and Name IN :setofScriptName] ) {
                productMapOfScriptName.put(objsObject.Name,objsObject);
            }
        }
        String productkey;
        for(Gross_Sales_Details__c newRecord: lstRevenue){
            productkey=null;
            productkey=newRecord.Security_Name__c;
            Account client = mapClient.get(newRecord.Pan_No__c);
            if(client != null){
                newRecord.Client__c = client.Id;
                newRecord.Family__c = client.ParentId;
                newRecord.OwnerId = client.OwnerId;
            }else{
                newRecord.OwnerId = defaultOwner.Id;
                if(newRecord.Client__c!=null){
                    newRecord.Client__c=null;
                    newRecord.Family__c=null;
                }
            }
            if(productkey!=null){
                Product2 obj= productMapOfScriptName.get(productkey);
                if(obj!=null){
                    newRecord.Product__c=obj.Id;
                }
            }
        }
    }
}