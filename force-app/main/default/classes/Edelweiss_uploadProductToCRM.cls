/* This batch is used to insert missing products into CRM from Product Staging based on Script Id and Source Id */

global class Edelweiss_uploadProductToCRM implements Database.Stateful, Database.Batchable<sObject> 
{
    private integer totalErrorcount = 0;
    private integer  totalcount = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {    
        String strQuery = 'SELECT Asset_Class__c, Product_Name__c, Scrip_Key__c, Source__c, Source_Id__c, Sub_Asset_Class__c From Product_Staging_Container__c';
        return Database.getQueryLocator(strQuery );
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product_Staging_Container__c> stagingRecords) 
    {
       List<String> scriptIds = new List<String>(); 
       List<String> sourceIds = new List<String>();
       String uniqueKey;
       /* Create a map of Srip key + Source Id and Product Staging */
       Map<String,Product_Staging_Container__c> sourceScriptStaging = new Map<String,Product_Staging_Container__c>();
       for(Product_Staging_Container__c productStaging : stagingRecords){
           scriptIds.add(productStaging.Scrip_Key__c);
           sourceIds.add(productStaging.Source_Id__c);
           uniqueKey = productStaging.Scrip_Key__c  +''+ productStaging.Source_Id__c;
           sourceScriptStaging.put(uniqueKey ,productStaging );
       }
       
      /* Create a map of Srip key + Source Id and Product*/
       Map<String,Product2> product2Map = new Map<String,Product2>();
       List<Product2> productList = [select Id,ProductCode,Source_Id__c from Product2];
       for(Product2 prodct : productList){
           uniqueKey = prodct.ProductCode +''+prodct.Source_Id__c;
           product2Map.put(uniqueKey,prodct);
       }
       system.debug('product2Map: '+product2Map);
       system.debug('product2Map: '+product2Map);
       List<Product2> prodctInsertInCRMList = new List<Product2>();
       
       /* Check if Product Staging is already converted to Product in CRM if not add it in a list and  insert the product in CRM */
       for(String key : sourceScriptStaging.keySet() ){
           Product2 prod;
           system.debug('Key: '+key);
           system.debug('product2Map.get(key): '+product2Map.get(key));
           if(!product2Map.containsKey(key)){
               prod = new Product2();
               prod.ProductCode =  sourceScriptStaging.get(key).Scrip_Key__c;
               prod.Source_Id__c = sourceScriptStaging.get(key).Source_Id__c;
               prod.IsActive = true;
               prod.Product_Stage__c = 'Active';
           }else{
               prod = new Product2(id = product2Map.get(key).id);
           }
           prod.Family= sourceScriptStaging.get(key).Asset_Class__c ;
           prod.Sub_Asset_Class__c  = sourceScriptStaging.get(key).Sub_Asset_Class__c ;
           prod.Name = sourceScriptStaging.get(key).Product_Name__c;
           prodctInsertInCRMList.add(prod);
       }
       
       if(prodctInsertInCRMList.size () > 0){
           Database.UpsertResult[] srList = Database.upsert(prodctInsertInCRMList,false);
           for(Database.UpsertResult sr : srList){
                if (!sr.isSuccess()) {
                    totalErrorcount ++ ;
                }
                totalcount ++ ;
           }
       }
    }
    
    
    global void finish(Database.BatchableContext bcMain)
    {
        List<String> tos = new List<String>();
        system.debug('Total Count: '+ totalCount + 'Total Error Count: '+totalErrorCount);
        Sys_Properties__c custSettingToEmailProfile = Sys_Properties__c.getValues('ProfileSendNotification MilesTicket');
        system.debug('Custom Setting To emils:.............'+custSettingToEmailProfile.Value__c);
        // collect users for profile.
        List<User> listProfileUsers = Edelweiss_Integration_Utility.getProfileUserList(custSettingToEmailProfile.value__c);
        String strToEmail;
        for(User objUser: listProfileUsers ){
           tos.add(objUser.email); 
        }
        Integer successCount = totalCount - totalErrorCount;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(tos);
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Prouct Upload Report');
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/>Total Products: '+totalCount+'<br/>Total Products Successfully Inserted: '+ successCount  + '<br/> Total Products not inserted: '+totalErrorCount;
        String signature = '<br /><b>Edeleweiss Salesforce Integration Support</b>';
        mail.HtmlBody= mailHtmlBody+ signature;
        
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

}