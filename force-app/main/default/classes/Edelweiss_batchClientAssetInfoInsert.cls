////////////////////////////////////
//Date: 13 JAN 2016
//@ 2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_batchClientAssetInfoInsert implements Database.Batchable<sObject>,Database.Stateful 
{
    global String strQuery;
    global Map<String, ID> mapAccountNameId;
    global Map<String, ID> mapFamilyAccountNameId;
    global Map<String, ID> mapProductScripId;  
    public Static integer aumBatchCount=0;  
    public List<Id> DeletionList;
    public List<Id> InsertedIds;
    public Boolean isErrorExist;
    //List<Edelweiss_Error_Log__c> errors = new List<Edelweiss_Error_Log__c>();
    
	global Edelweiss_batchClientAssetInfoInsert(){}  
    
    // Parametrized Constructor to get deleted records in case of error - set query string    
    global Edelweiss_batchClientAssetInfoInsert(List<Id> deletedIds, Map<String, Id> mapProductScripIdReceived) 
    {
        InsertedIds = new List<Id>();
        DeletionList = deletedIds;
		
		Set<Id> accountRecordTypeIdSet = new Set<Id>();
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId());
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId());
        strQuery = 'SELECT Account_Code__c, Investment_Value__c, Quantity__c, Account_Name__c, Asset_Class__c, Client_Code__c, Client_Name__c, Family_Code__c, Family_Name__c, Scrip_Key__c, Scrip_Name__c, Source_Id__c, Source_Name__c, Sub_Asset_Class__c, Total_AUM__c, Is_Picked_By_Scheduler__c, As_On_Date__c, Annual_Record__c,Networth__c,Folio_Number__c,Amc_Name__c,Amc_Code__c FROM Client_Asset_Staging_Container__c WHERE (Annual_Record__c=\'0\' OR Annual_Record__c=null)';

        
        Map<Id, Account> mapFamilyClientRecord = new Map<Id, Account>([
            SELECT Id, RecordTypeId, Name, GWM_Online_Id__c,RecordType.Name 
            FROM Account 
            WHERE GWM_Online_Id__c !=null 
            AND RecordTypeId IN :accountRecordTypeIdSet 
        ]);
        
		Map<Id, Client_Account__c> mapClientAccountRecord = new Map<Id, Client_Account__c>([
            SELECT Id, Name, GWM_Client_Account_Id__c
            FROM Client_Account__c 
            WHERE GWM_Client_Account_Id__c !=null 
        ]);
        
		mapFamilyAccountNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecordsNew(mapFamilyClientRecord,EdelweissConstants.OBJECT_ACCOUNT);
		mapAccountNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapClientAccountRecord,EdelweissConstants.OBJECT_CLIENT_ACCOUNT);        
        mapProductScripId = mapProductScripIdReceived;
    }
    
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Staging_Container__c> listBatchRecords){   
        
        List<Client_Asset_Information__c> listClientAssetInfo = Edelweiss_Integration_Utility.generateClientAssetInfoRecords(mapProductScripId,mapFamilyAccountNameId,mapAccountNameId,listBatchRecords);
		List<Edelweiss_Error_Log__c> lstErrors = new List<Edelweiss_Error_Log__c>();
        if(listClientAssetInfo.size() > 0)  
        {
            Database.SaveResult[] srList = database.insert(listClientAssetInfo,false);
             if(srList.size() > 0 ){
                Integer index = 0; 
                for (Database.SaveResult sr : srList){
                    
                    if(sr.isSuccess()){
                        InsertedIds.add(sr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
                            exceptionRec.Error_Details__c = 'Family Code:- '+listClientAssetInfo[index].Staging_Family_Code__c+ ' Client Code:- '+listClientAssetInfo[index].Staging_Client_Code__c+ 'Total AUM :- '+ listClientAssetInfo[index].Total_AUM__c+' Error Message :- '+err.getMessage();
                            exceptionRec.Error_Occurred_In__c = 'AUA Batch';
                            exceptionRec.Error_Type__c = 'ERROR';
                            exceptionRec.Related_Object_Name__c = 'Client_Asset_Information__c';                            
                            lstErrors.add(exceptionRec);
                        }
                    }
                    index++;
                }
            }
            aumBatchCount=aumBatchCount+1;     
            if(!lstErrors.isEmpty()){
                isErrorExist = true;
				database.insert(lstErrors,false);
			}
        }
    }
    global void finish(Database.BatchableContext bcMain){ 
                
        try{
            List<String> lstToAddress = new List<String>();
            Sys_Properties__c custSettingEmailRecipient = Sys_Properties__c.getValues('Integration Email Recipient User');
            String strUserName = String.isEmpty(custSettingEmailRecipient.Value__c) ? 'PWM SalesforceUpdate' : custSettingEmailRecipient.Value__c ;
            
            List<User> listUsers = [
                SELECT Id, Email FROM User WHERE Name =: strUserName   
            ];
            for(User objUser: listUsers){
                lstToAddress.add(objUser.Email); 
            }
            
            Integer recordCount = [
                SELECT COUNT() FROM Edelweiss_Error_Log__c
                WHERE Error_Occurred_In__c = 'AUA Batch' 
                AND Related_Object_Name__c = 'Client_Asset_Information__c'
                AND CreatedDate = TODAY LIMIT 1
            ];
            
            if(recordCount > 0){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(lstToAddress); 
        mail.setSenderDisplayName('Edeleweiss Integration Support');
                mail.setSubject('AUM Integration Batch Execution : '+ system.Today());
        
                string baseURL = '';
                List<Report> reports  = [select id from Report where DeveloperName = 'AUA_Batch_Error_Report'];
                if(reports.size() > 0){
                    baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].id;
                }
                string mailHtmlBody = '<br />Hello Admin team,<br /><br />There were errors reported while running the AUM Integration batch.<br />';
                mailHtmlBody += '<br />To view failed records, go to <b><a href="'+baseURL +'">AUA Data Error Report </a></b><br />';
                String signature = '<br/><br/>Regards,<br/>Edeleweiss Salesforce Integration Support';
            
                //mail.HtmlBody= mailHtmlBody + errorTable+errorRows+'</table>' + signature;  
                mail.HtmlBody= mailHtmlBody + signature;  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
            
            Database.executeBatch(new Edelweiss_batchUpdateFamilyAUM(), 2000);
            
        } catch(Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
            Database.executeBatch(new Edelweiss_batchDeleteInsertedCAI(InsertedIds, DeletionList), 1000);
        }
    }
}