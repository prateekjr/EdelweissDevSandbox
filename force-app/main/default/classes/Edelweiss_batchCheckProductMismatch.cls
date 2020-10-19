global class Edelweiss_batchCheckProductMismatch implements Database.Stateful, Database.Batchable<sObject> 
{
    global String strQuery;
    global List<Product2> productRecords;
    global Map<String, Product2> productNameRecordMap;
    static Map<String, Product_Staging_Container__c> stagingNameRecordMap;
    //static List<Product_Staging_Container__c> productStagingRecords;
    global List<String> productNames;
    static List<String> productNamesInStaging;
    static List<Reported_Mismatch_Product__c> duplicateProductRecordList;
    static List<Reported_Mismatch_Product__c> duplicateStagingRecordList;
    
    static List<Reported_Mismatch_Product__c> finalMismatchList;
    global boolean notifyAdminFlag;
    global integer numberOfFailedRecords;
    Set<String> mismatchedProductFilterSet{get;set;}
    global Edelweiss_batchCheckProductMismatch() 
    {
        mismatchedProductFilterSet = MisMatchProductsFilters__c.getAll().keySet();
        strQuery = 'SELECT Asset_Class__c, Product_Name__c, Scrip_Key__c, Source__c, Source_Id__c, Sub_Asset_Class__c From Product_Staging_Container__c where Sub_Asset_Class__c IN :mismatchedProductFilterSet';
        productRecords = new List<Product2>([Select id, Name, Family, Sub_Asset_Class__c,ProductCode,Source_Name__c,Source_Id__c from Product2 where Sub_Asset_Class__c in :mismatchedProductFilterSet]);
        productNames= new List<String>();
        productNameRecordMap= new Map<String, Product2>();
        for(Product2 product: productRecords){
                productNames.add(product.Name);
                productNameRecordMap.put(product.Name,product);
        }
        notifyAdminFlag = false;
        numberOfFailedRecords=0;
        //Delete previous data from mismatch object
        id batchJobId= Database.executeBatch(new BatchDeleteRelatedMismatchProduct(),2000);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product_Staging_Container__c> stagingRecords) 
    {
        productNamesInStaging= new List<String>();
        Product_Staging_Container__c mismatchedStagingRecord;
        Product2 mismatchedProductRecord;
        stagingNameRecordMap= new Map<String, Product_Staging_Container__c>();
        Map <String, Set<String>> mismatchedProducts;
        Set <String> productsNotInCRM;
        Set <String> productsNotInMiles;
        Set <String> duplicateProductsInCRM = new Set <String>();
       
        Set<String> cloneOfDuplicateProductsInCRM;
        
        
        Map<String, Reported_Mismatch_Product__c> productsToBeReported= new Map<String, Reported_Mismatch_Product__c>();
        
        for(Product_Staging_Container__c stagingRecord: stagingRecords){
                productNamesInStaging.add(stagingRecord.Product_Name__c);
                stagingNameRecordMap.put(stagingRecord.Product_Name__c, stagingRecord);
        }
        system.debug('Total Product Names in name list of products=========>'+productNames.size());
        system.debug('Total Product Names in name list of staging records=========>'+productNames.size());

        mismatchedProducts=Edelweiss_Integration_Utility.getMismatchedProducts(productNames,productNamesInStaging);
        if(!mismatchedProducts.isEmpty()){
                productsNotInCRM=mismatchedProducts.get('productsNotInCRM');
                productsNotInMiles=mismatchedProducts.get('productsNotInMiles');
                duplicateProductsInCRM=mismatchedProducts.get('duplicateProductsInCRM');
                
        }
        system.debug('Number of products, present in CRM but not in miles=========>'+productsNotInMiles.size());
        system.debug('Number of products, present in Miles but not in CRM=========>'+productsNotInCRM.size());
        //system.debug('Number of duplicate products in CRM=========>'+duplicateProductsInCRM.size());
    
        for(String productName: productsNotInCRM){
            if(stagingNameRecordMap.containsKey(productName)){
                Reported_Mismatch_Product__c reportedProductNotInCRM= new Reported_Mismatch_Product__c();
                mismatchedStagingRecord=stagingNameRecordMap.get(productName);
                
                    reportedProductNotInCRM.GWM_Product_Name__c=mismatchedStagingRecord.Product_Name__c;
                    reportedProductNotInCRM.Asset_Class__c=mismatchedStagingRecord.Asset_Class__c;
                    reportedProductNotInCRM.Sub_Asset_Class__c=mismatchedStagingRecord.Sub_Asset_Class__c;
                    reportedProductNotInCRM.Scrip_Key__c=mismatchedStagingRecord.Scrip_Key__c;
                    reportedProductNotInCRM.Source__c=mismatchedStagingRecord.Source__c;
                    reportedProductNotInCRM.Source_Id__c=mismatchedStagingRecord.Source_Id__c;
                    reportedProductNotInCRM.Available_only_in_Miles__c=true;
                    productsToBeReported.put(reportedProductNotInCRM.GWM_Product_Name__c, reportedProductNotInCRM);
        }
        
        }
        for(String productName: productsNotInMiles){
            if(productNameRecordMap.containsKey(productName)){
                Reported_Mismatch_Product__c reportedProductNotInMiles= new Reported_Mismatch_Product__c();
                mismatchedProductRecord=productNameRecordMap.get(productName);
                
                    reportedProductNotInMiles.GWM_Product_Name__c=mismatchedProductRecord.Name;
                    reportedProductNotInMiles.Asset_Class__c=mismatchedProductRecord.Family;
                    reportedProductNotInMiles.Sub_Asset_Class__c=mismatchedProductRecord.Sub_Asset_Class__c;
                    reportedProductNotInMiles.Scrip_Key__c=mismatchedProductRecord.ProductCode;
                    reportedProductNotInMiles.Source__c=mismatchedProductRecord.Source_Name__c;
                    reportedProductNotInMiles.Source_Id__c=mismatchedProductRecord.Source_Id__c;
                    reportedProductNotInMiles.Available_only_in_CRM__c=true;
                    
                productsToBeReported.put(reportedProductNotInMiles.GWM_Product_Name__c,reportedProductNotInMiles);
            }
        }
        
        // if there are duplicate product names in CRM and a name mismatch is also there for them, then create their records in reporting object
        if(duplicateProductsInCRM != null && duplicateProductsInCRM.size()>0 ){
            cloneOfDuplicateProductsInCRM= new Set<String>();
            cloneOfDuplicateProductsInCRM=duplicateProductsInCRM.clone();
            cloneOfDuplicateProductsInCRM.retainAll(productsNotInMiles);
            duplicateProductsInCRM.retainAll(productsNotInCRM);
            duplicateProductsInCRM.addAll(cloneOfDuplicateProductsInCRM);
        
            List<Product2> duplicateProductObjectRecords=new List<Product2>([Select id, Name, Family, Sub_Asset_Class__c,ProductCode,Source_Name__c,Source_Id__c from Product2 where Name in: duplicateProductsInCRM]);
            duplicateProductRecordList= new List<Reported_Mismatch_Product__c>();
        for(Product2 duplicate: duplicateProductObjectRecords){
                
                productsToBeReported.remove(duplicate.Name);
                Reported_Mismatch_Product__c reportedDuplicateProduct= new Reported_Mismatch_Product__c();
                    reportedDuplicateProduct.GWM_Product_Name__c=duplicate.Name;
                    reportedDuplicateProduct.Asset_Class__c=duplicate.Family;
                    reportedDuplicateProduct.Sub_Asset_Class__c=duplicate.Sub_Asset_Class__c;
                    reportedDuplicateProduct.Scrip_Key__c=duplicate.ProductCode;
                    reportedDuplicateProduct.Source__c=duplicate.Source_Name__c;
                    reportedDuplicateProduct.Source_Id__c=duplicate.Source_Id__c;
                    reportedDuplicateProduct.Product_with_duplicate_name__c=true;
                    reportedDuplicateProduct.Available_only_in_CRM__c=true;
                duplicateProductRecordList.add(reportedDuplicateProduct);
                
                //productsToBeReported.put(reportedDuplicateProduct.GWM_Product_Name__c,reportedDuplicateProduct);
                  
        }
                
        }
        		finalMismatchList= new List<Reported_Mismatch_Product__c>();
             	if(productsToBeReported != null && productsToBeReported.size() > 0){
                	finalMismatchList.addAll(productsToBeReported.Values());
             	}
             	if(duplicateProductRecordList != null && duplicateProductRecordList.size() > 0){
             		finalMismatchList.addAll(duplicateProductRecordList);
             	}
                
        system.debug('Total number of Products to be reported===========>'+productsToBeReported.size());
        if(finalMismatchList != null && finalMismatchList.size()>0){
            try{
                    //List<Reported_Mismatch_Product__c> mismatchedProductList= productsToBeReported.getValues();
                    database.insert(finalMismatchList);
                }
                catch(DMLException e){
                        notifyAdminFlag = true;
                        numberOfFailedRecords= numberOfFailedRecords+e.getNumDml();
                        system.debug('Product mismatch failed: '+e.getMessage()+'notify: ' + notifyAdminFlag);
                    
                }
        
        }
    }
    // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        system.debug('inside finish method, value of notification flag..'+notifyAdminFlag);
        if(notifyAdminFlag){
            system.debug('notification flag raised..');       
        // collect users for profile.
        String recipientProfileName='System Administrator';
        Profile userProfile = [select id, Name from profile where Name=:recipientProfileName];
        List<User> listProfileUsers = [Select id,Email from user where ProfileID =: userProfile.Id];
        
        String strToEmail;
        for(User objUser: listProfileUsers )
        {
            if(strToEmail==null)
                strToEmail=objUser.Email;
            else
                strToEmail = strToEmail + ','+objUser.Email;
        }
        String[] toAddresses;
        if(strToEmail !=null)
            toAddresses = strToEmail.split(',');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Needs your attention: Product mismatch process unsuccessful');
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>Edelweiss_batchCheckProductMismatch</b> batch.'+numberOfFailedRecords+' records could not be stored in the <b>Reported Mismatch Product</b> object. Please take appropriate actions.<br />';
        String signature = '<br /><b>Edeleweiss Salesforce Integration Support</b>';
        mail.HtmlBody= mailHtmlBody+ signature;
        
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
    }
        }
    }