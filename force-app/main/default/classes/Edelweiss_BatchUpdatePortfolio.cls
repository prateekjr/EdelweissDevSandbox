global class Edelweiss_BatchUpdatePortfolio implements Database.Batchable<sObject>, Database.Stateful {
	global String strQuery;
   	global boolean hasErrors;
    global List<Id> successRecordIds;
	global Map<Id, Portfolio_Staging_Container__c> mapErrorStagingRecords;
    
    global Edelweiss_BatchUpdatePortfolio() 
    {
        hasErrors = false;
        mapErrorStagingRecords = new Map<Id, Portfolio_Staging_Container__c>();
        strQuery = 'SELECT Id, Name, As_On_Date__c, CNXMidcapPortfolio_Return_ITD__c, CNXMidcapPortfolio_Return_MTD__c, '+
            ' CNXMidcapPortfolio_Return_YTD__c, CNXNiftyPortfolio_Return_ITD__c, CNXNiftyPortfolio_Return_MTD__c, '+
            ' CNXNiftyPortfolio_Return_YTD__c, Crisil_CB_IndexPortfolio_Return_ITD__c, Crisil_CB_IndexPortfolio_Return_MTD__c, '+
            ' Crisil_CB_IndexPortfolio_Return_YTD__c, Crisil_Composite_Bond_Index_Value__c, Crisil_LF_IndexPortfolio_Return_ITD__c, '+
            ' Crisil_LF_IndexPortfolio_Return_MTD__c, Crisil_LF_IndexPortfolio_Return_YTD__c, Crisil_Liquid_Fund_Index_Value__c, '+
            ' Family_Name__c, Family_Code__c, Date_of_Inception__c, CNXNiftyValue__c, CNXMidcapValue__c, '+
            ' Portfolio_Return_ITD__c, Portfolio_Return_MTD__c, Portfolio_Return_YTD__c '+
            ' FROM Portfolio_Staging_Container__c ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Portfolio_Staging_Container__c> listBatchRecords) 
    {
        List<String> lstFamilyCodes = new List<String>();
		List<Account> lstUpdatedFamilies = new List<Account>();
        Map<String, Account> mapGWMIDFamily = new Map<String, Account>();
        Map<String, Portfolio_Staging_Container__c> mapGWMIDStgRecord = new Map<String, Portfolio_Staging_Container__c>();
        
        for(Portfolio_Staging_Container__c record: listBatchRecords){
            lstFamilyCodes.add(record.Family_Code__c);
            mapGWMIDStgRecord.put(record.Family_Code__c, record);
        }
        
        Map<Id, Account> mapFamily = new Map<Id, Account>([
            SELECT Id, Name, GWM_Online_Id__c FROM Account 
            WHERE GWM_Online_Id__c IN :lstFamilyCodes
            AND RecordType.Name='Family'
        ]);
        
        for(Account objFamily : mapFamily.values()){
            mapGWMIDFamily.put(objFamily.GWM_Online_Id__c, objFamily);
        }
        
        for(Portfolio_Staging_Container__c objStaging : listBatchRecords){
            
            Account objFamily = mapGWMIDFamily.get(String.valueOf(objStaging.Family_Code__c).replace('.0', ''));
            
            System.debug('objFamily Recod :::: '+ objFamily);
            
            if(objFamily != null){
                objFamily.Portfolio_As_On_Date__c = objStaging.As_On_Date__c;
                objFamily.Date_of_Inception__c = objStaging.Date_of_Inception__c;
                objFamily.CNXNiftyValue__c = objStaging.CNXNiftyValue__c;
                objFamily.CNXMidcapValue__c = objStaging.CNXMidcapValue__c;
                objFamily.CNXMidcapPortfolio_Return_ITD__c = objStaging.CNXMidcapPortfolio_Return_ITD__c;
                objFamily.CNXMidcapPortfolio_Return_MTD__c = objStaging.CNXMidcapPortfolio_Return_MTD__c;
                objFamily.CNXMidcapPortfolio_Return_YTD__c = objStaging.CNXMidcapPortfolio_Return_YTD__c;
                objFamily.CNXNiftyPortfolio_Return_ITD__c = objStaging.CNXNiftyPortfolio_Return_ITD__c;
                objFamily.CNXNiftyPortfolio_Return_MTD__c = objStaging.CNXNiftyPortfolio_Return_MTD__c;
                objFamily.CNXNiftyPortfolio_Return_YTD__c = objStaging.CNXNiftyPortfolio_Return_YTD__c;
                objFamily.Crisil_CB_IndexPortfolio_Return_ITD__c = objStaging.Crisil_CB_IndexPortfolio_Return_ITD__c;
                objFamily.Crisil_CB_IndexPortfolio_Return_MTD__c = objStaging.Crisil_CB_IndexPortfolio_Return_MTD__c;
                objFamily.Crisil_CB_IndexPortfolio_Return_YTD__c = objStaging.Crisil_CB_IndexPortfolio_Return_YTD__c;
                objFamily.Crisil_Composite_Bond_Index_Value__c = objStaging.Crisil_Composite_Bond_Index_Value__c;
                objFamily.Crisil_LF_IndexPortfolio_Return_ITD__c = objStaging.Crisil_LF_IndexPortfolio_Return_ITD__c;
                objFamily.Crisil_LF_IndexPortfolio_Return_MTD__c = objStaging.Crisil_LF_IndexPortfolio_Return_MTD__c;
                objFamily.Crisil_LF_IndexPortfolio_Return_YTD__c = objStaging.Crisil_LF_IndexPortfolio_Return_YTD__c;
                objFamily.Crisil_Liquid_Fund_Index_Value__c = objStaging.Crisil_Liquid_Fund_Index_Value__c;
                objFamily.Portfolio_Return_ITD__c = objStaging.Portfolio_Return_ITD__c;
                objFamily.Portfolio_Return_MTD__c = objStaging.Portfolio_Return_MTD__c;
                objFamily.Portfolio_Return_YTD__c = objStaging.Portfolio_Return_YTD__c;
                
                lstUpdatedFamilies.add(objFamily);
            }
            else{
                hasErrors = true;
                objStaging.Error_Message__c='Family record is not present';
                mapErrorStagingRecords.put(objStaging.Id, objStaging);
            }
        }
        
        System.debug('lstUpdatedFamilies >> '+ lstUpdatedFamilies);
        
        try{
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            
            Database.SaveResult[] srList = Database.update(lstUpdatedFamilies, false);

            AccountTriggerhandler.stopAccountTrigger = false;
            AccountTriggerhandler.stopUpdatefamily = false;
            
            if(srList.size() > 0 ){
                for (Database.SaveResult sr : srList){
                    
                    if(!sr.isSuccess()){
                        hasErrors = true;
                        for(Database.Error err : sr.getErrors()) {
                            Portfolio_Staging_Container__c stgRecord = mapGWMIDStgRecord.get((mapFamily.get(sr.getId())).GWM_Online_Id__c);
                            stgRecord.Error_Message__c = err.getMessage() + ',[Fields]: ' + err.getFields();
                            mapErrorStagingRecords.put(stgRecord.Id, stgRecord);
                        }
                    }
                }
            }
            
            if(!mapErrorStagingRecords.isEmpty()){
                Database.update(mapErrorStagingRecords.values(), false);
            }
            
        }
        catch(DmlException de){
            system.debug('Portfolio Update Issue ==>'+de.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bcMain) 
    {
        List<String> lstToAddress = new List<String>();
        Sys_Properties__c custSettingEmailRecipient = Sys_Properties__c.getValues('Integration Email Recipient User');
        String strUserName = String.isEmpty(custSettingEmailRecipient.Value__c) ? 'PWM SalesforceUpdate' : custSettingEmailRecipient.Value__c ;
        
        List<User> listUsers = [
          SELECT Id, Email FROM User WHERE Name =: strUserName   
        ];
        for(User objUser: listUsers){
           lstToAddress.add(objUser.Email); 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(lstToAddress);
       
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Portfolio Integration Batch Execution : '+ system.Today());
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/>';
        
        System.debug('hasErrors : '+hasErrors);
        
        if(!hasErrors){
            mailHtmlBody += 'Portfolio integration batch executed successfully.';
        }else{
            mailHtmlBody += 'There were some errors occurred while running Update Portfolio Batch. Please check the errors updated on Portfolio Staging Records.';
        }
        
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        mail.HtmlBody= mailHtmlBody+ signature;
        
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}