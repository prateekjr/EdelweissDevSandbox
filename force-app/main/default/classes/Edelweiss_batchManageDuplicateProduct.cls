global class Edelweiss_batchManageDuplicateProduct implements Database.Batchable<sObject>, Database.Stateful {

    global String strQuery {get; set;}
    
    global Edelweiss_batchManageDuplicateProduct(){
        strQuery = 'SELECT Id, Name, ProductCode, Family, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c, '+
            'ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c, Product_Class_Miles__c, '+
            'Source_Id__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c, ProductCode_SourceId__c, Created_By_Integration__c, Amc_Code__c , Amc_Name__c, SchemeType__c,Scheme_Plan__c, '+
            '(SELECT Id, CaseNumber FROM Cases__R), (SELECT Id, Name FROM Opportunities__r) '+
            'FROM Product2 WHERE Created_By_Integration__c = true';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product2> lstBatchRecords) {
        
        Map<String, Product2> mapOpsProductName = new Map<String, Product2>();
        Map<String, Product2> mapProductCodeSourceId = new Map<String, Product2>();
        Map<String, Product_Staging_Container__c> mapStgProductCodeSourceId = new Map<String, Product_Staging_Container__c>();
        Map<String, Product_Staging_Container__c> mapStgProductName = new Map<String, Product_Staging_Container__c>();
        List<String> lstProductName = new List<String>();
        List<Id> lstProductToDelete = new List<Id>();
        List<Id> lstOppId = new List<Id>();
        List<Case> lstCasesToUpdate = new List<Case>();
        Map<Id, Product2> mapProductToUpdate = new Map<Id, Product2>();
        Map<Id, Opportunity> mapOppToUpdate = new Map<Id, Opportunity>();
        Map<Id,Id> mapOldNewProduct = new Map<Id,Id>();
        
        for(Product2 objProduct : lstBatchRecords){
            mapProductCodeSourceId.put(objProduct.ProductCode_SourceId__c, objProduct);
        }
        
        List<Product_Staging_Container__c> lstStgRecords = [
            SELECT Id, Asset_Class__c, ProductCode_SourceId__c, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c,
            is_Deleted__c, ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c,
            Product_Class_Miles__c, Product_Name__c, Scrip_Key__c, Source_Id__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c, Error_Message__c , Amc_Code__c , Amc_Name__c , SchemeType__c
            FROM Product_Staging_Container__c WHERE ProductCode_SourceId__c IN :mapProductCodeSourceId.keySet() AND Synch__c = false
        ];
        
        if(!lstStgRecords.isEmpty()){
            
            for(Product_Staging_Container__c objStgRecord : lstStgRecords){
                mapStgProductCodeSourceId.put(objStgRecord.ProductCode_SourceId__c, objStgRecord);
                mapStgProductName.put(objStgRecord.Product_Name__c, objStgRecord);
            }
            
            for(Product2 objProduct : lstBatchRecords){
                Product_Staging_Container__c objStg = mapStgProductCodeSourceId.get(objProduct.ProductCode_SourceId__c);
                if(objStg != null && objStg.Product_Name__c != objProduct.Name){
                    lstProductName.add(objStg.Product_Name__c);
                }
            }
            
            if(!lstProductName.isEmpty()){
                List<Product2> lstOpsProduct = [
                    SELECT Id, Name, ProductCode, Family, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c,
                    ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c, Product_Class_Miles__c,
                    Source_Id__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c, ProductCode_SourceId__c, Created_By_Integration__c 
                    FROM Product2 WHERE Created_By_Integration__c = false and Name IN :lstProductName and ProductCode = Null AND Source_Id__c = Null
                ];
                
                for(Product2 objOpsProduct : lstOpsProduct){
                    if(mapStgProductName.get(objOpsProduct.Name) != null && 
                       mapStgProductName.get(objOpsProduct.Name).ProductCode_SourceId__c != null &&
                       mapProductCodeSourceId.get(mapStgProductName.get(objOpsProduct.Name).ProductCode_SourceId__c) != null){
                           
                           Product2 objIntegrationProductToDelete = mapProductCodeSourceId.get(mapStgProductName.get(objOpsProduct.Name).ProductCode_SourceId__c);
                           mapOldNewProduct.put(objIntegrationProductToDelete.Id, objOpsProduct.Id);
                           lstProductToDelete.add(objIntegrationProductToDelete.Id);
                           for(Case objCase : objIntegrationProductToDelete.Cases__r){
                               objCase.Script_Name__c = objOpsProduct.Id;
                               lstCasesToUpdate.add(objCase);
                           }
                           for(Opportunity objOpp : objIntegrationProductToDelete.Opportunities__r){
                               objOpp.Scrip_Name__c = objOpsProduct.Id;
                               mapOppToUpdate.put(objOpp.Id, objOpp);
                           }
                           
                           Product2 objProductUpdate = Edelweiss_batchProductIntegration.updateProductDetails(objOpsProduct, mapStgProductName.get(objOpsProduct.Name));
                           System.debug('objProductUpdate '+ objProductUpdate);
                           
                           if(objProductUpdate != Null){
                               objProductUpdate.ProductCode = mapStgProductName.get(objOpsProduct.Name).Scrip_Key__c;
                               objProductUpdate.Source_Id__c = mapStgProductName.get(objOpsProduct.Name).Source_Id__c;
                               mapProductToUpdate.put(objProductUpdate.Id, objProductUpdate);        
                           }else if(objProductUpdate == Null){
                               objProductUpdate = objOpsProduct;
                               objProductUpdate.Product_Stage__c = 'Active';
                               objProductUpdate.Bypass_Validation__c = true;
                               objProductUpdate.ProductCode = mapStgProductName.get(objOpsProduct.Name).Scrip_Key__c;
                               objProductUpdate.Source_Id__c = mapStgProductName.get(objOpsProduct.Name).Source_Id__c;
                               mapProductToUpdate.put(objProductUpdate.Id, objProductUpdate);        
                           }
                           
                       }
                }
                
                if(!mapProductToUpdate.isEmpty()){
                    Database.update(mapProductToUpdate.values(), true);
                }
                
                if(!mapOppToUpdate.isEmpty() && !mapProductToUpdate.isEmpty()){
                    
                    List<OpportunityLineItem> lstOppLineItem = [
                        SELECT Id, Product2Id, PricebookEntryId, OpportunityId FROM OpportunityLineItem WHERE Product2Id IN :lstProductToDelete
                    ];
                    Map<Id,Id> MapOpportunityItemProduct = new Map<Id,Id>();
                    for(OpportunityLineItem item : lstOppLineItem){
                        MapOpportunityItemProduct.put(item.Id, item.Product2Id);
                    }
                    
                    List<PricebookEntry> productlst = [
                        SELECT Id, Name, Pricebook2Id, Product2Id, unitprice FROM PricebookEntry Where Product2Id IN: mapProductToUpdate.keySet()
                    ];
                    Map<Id, PricebookEntry> MapProductprice = new Map<Id, PricebookEntry>();
                    for(PricebookEntry price : productlst){
                        MapProductprice.put(price.Product2Id, price);
                    }
                    
                    List<OpportunityLineItem> insertLineItem = new List<OpportunityLineItem>();
                    List<OpportunityLineItem> deleteLineItem = new List<OpportunityLineItem>();
                    
                    for(OpportunityLineItem lineItem : lstOppLineItem){
                        
                        Id productOldId = MapOpportunityItemProduct.get(lineItem.Id);
                        Id productNewId = mapOldNewProduct.get(productOldId);
                        
                        if(productNewId != null ){ 
                            PricebookEntry priceObj = MapProductprice.get(productNewId);
                            
                            if(priceObj != null){
                                opportunitylineitem lineItemObj = new opportunitylineitem();
                                lineItemObj.unitprice = priceObj.unitprice;
                                lineItemObj.quantity = 1;
                                lineItemObj.pricebookentryid = priceObj.id;
                                lineItemObj.OpportunityId = lineItem.OpportunityId;
                                insertLineItem.add(lineItemObj);
                                deleteLineItem.add(lineItem);
                            }
                        }
                    }
                    
                    if(!insertLineItem.isEmpty()){
                        Database.insert(insertLineItem, true);
                    }
                    if(!deleteLineItem.isEmpty()){
                        Database.delete(deleteLineItem, true);
                    }
                    if(!mapOppToUpdate.isEmpty()){
                        Database.update(mapOppToUpdate.values(), true);
                    }
					
                }
                if(!lstCasesToUpdate.isEmpty()){
                    Database.update(lstCasesToUpdate, true);
                }
                if(!lstProductToDelete.isEmpty()){
                    Database.delete(lstProductToDelete, true);
                }

            }
        }
        
    }
    
	global void finish(Database.BatchableContext bcMain) {
        Database.executeBatch(new Edelweiss_batchProductIntegration(), 1000); 
    }
}