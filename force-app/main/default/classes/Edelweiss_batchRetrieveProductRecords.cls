global class Edelweiss_batchRetrieveProductRecords implements Database.Batchable<sObject>,Database.Stateful {

    global Map<String, ID> mapProductScripId;  
    global List<Id> lstDeletedIds {get; set;}
    global String strQuery {get; set;}
    global Boolean isAnnualRecord {get; set;}
    
    global Edelweiss_batchRetrieveProductRecords(){}
    
    global Edelweiss_batchRetrieveProductRecords(List<Id> deletedIds, Boolean isAnnual){
        
        isAnnualRecord = isAnnual;
        mapProductScripId = new Map<String, ID>();
        lstDeletedIds = deletedIds;
        strQuery = 'SELECt Id, Name, Family, Sub_Asset_Class__c, ProductCode, Source_Id__c FROM Product2 WHERE ProductCode !=null'; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product2> lstBatchRecords) {
        
        Map<Id, Product2> mapProductRecord = new Map<Id, Product2>();
        
        for(Product2 objProduct : lstBatchRecords){
            mapProductRecord.put(objProduct.Id, objProduct);
        }
        
        mapProductScripId.putAll(Edelweiss_Integration_Utility.collectMapForProductRecords(mapProductRecord));  
    }
    
	global void finish(Database.BatchableContext bcMain) {
        System.debug('Size of Product ScripID : '+ mapProductScripId.size());
        System.debug('Size of lstDeletedIds : '+ lstDeletedIds.size());
        System.debug('isAnnualRecord : '+ isAnnualRecord);
        if(isAnnualRecord){
        	Database.executeBatch(new Edelweiss_batchCAIAnnualInfoInsert(lstDeletedIds, mapProductScripId), 1000); 
        }else{
            Database.executeBatch(new Edelweiss_batchClientAssetInfoInsert(lstDeletedIds, mapProductScripId), 1000);
        }
    }
    
    
    
}