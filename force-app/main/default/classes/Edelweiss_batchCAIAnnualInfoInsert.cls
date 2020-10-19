global class Edelweiss_batchCAIAnnualInfoInsert implements Database.Batchable<sObject>,Database.Stateful 
{
    global String strQuery;
    global Map<String, ID> mapAccountNameId;
    global Map<String, ID> mapFamilyAccountNameId;
    global Map<String, ID> mapProductScripId;  
    public Static integer aumBatchCount=0;  
    public List<Id> DeletionList;
    public List<Id> InsertedIds;
    global Map<Id, String> batchErrors {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    global Map<Id, Product2> mapProductRecord {get; set;}
    
	global Edelweiss_batchCAIAnnualInfoInsert(){
        
    }   
    // Parametrized Constructor to get deleted records in case of error - set query string    
    global Edelweiss_batchCAIAnnualInfoInsert(List<Id> deletedIds, Map<String, Id> mapProductScripIdReceived) 
    {
        batchErrors = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        DeletionList = new list<Id>();
        InsertedIds = new List<Id>();
        DeletionList = deletedIds;
		
		Map<Id, Account> mapFamilyClientRecord = new Map<Id, Account>();
		Map<Id, Client_Account__c> mapClientAccountRecord = new Map<Id, Client_Account__c>();
        
        Set<Id> accountRecordTypeIdSet = new Set<Id>();
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId());
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId());
        strQuery = 'SELECT Quantity__c, Investment_Value__c , Account_Code__c, Account_Name__c, Asset_Class__c, Client_Code__c, Client_Name__c, Family_Code__c, Family_Name__c, Scrip_Key__c, Scrip_Name__c, Source_Id__c, Source_Name__c, Sub_Asset_Class__c, Total_AUM__c, Is_Picked_By_Scheduler__c, As_On_Date__c, Annual_Record__c,Networth__c FROM Client_Asset_Staging_Container__c WHERE Annual_Record__c=\'1\'';
		
        mapFamilyClientRecord = new Map<Id, Account>([
            SELECT Id, RecordTypeId, Name, GWM_Online_Id__c 
            FROM Account 
            WHERE GWM_Online_Id__c !=null 
            AND RecordTypeId IN :accountRecordTypeIdSet 
        ]);
        
        mapClientAccountRecord = new Map<Id, Client_Account__c>([
            SELECT Id, Name, GWM_Client_Account_Id__c
            FROM Client_Account__c 
            WHERE GWM_Client_Account_Id__c !=null 
        ]);
		
        mapFamilyAccountNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapFamilyClientRecord,EdelweissConstants.OBJECT_ACCOUNT);
		mapAccountNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapClientAccountRecord,EdelweissConstants.OBJECT_CLIENT_ACCOUNT);        
        mapProductScripId = mapProductScripIdReceived;
    }
    
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Staging_Container__c> listBatchRecords){   
        boolean isFailed = false;
        List<Client_Asset_Information__c> listClientAssetInfo = new List<Client_Asset_Information__c>();
        List<Client_Asset_Information__c> InsertionList = new List<Client_Asset_Information__c>();
        Map<Client_Asset_Information__c,String> FailureMap = new Map<Client_Asset_Information__c,String>();
                
        listClientAssetInfo = Edelweiss_Integration_Utility.generateClientAssetInfoRecords(mapProductScripId,mapFamilyAccountNameId,mapAccountNameId,listBatchRecords);

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
                            batchErrors.put(listClientAssetInfo[index].id, err.getMessage() + ',[Fields]: ' + err.getFields());
                            IdToSObjectMap.put(listClientAssetInfo[index].Id, listClientAssetInfo[index]);
                        }
                    }
                    index++;
                }
            }
            aumBatchCount=aumBatchCount+1;     
        }
    }
    global void finish(Database.BatchableContext bcMain){ 
        
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
        mail.setSenderDisplayName('Edeleweiss Integration Support');
        mail.setSubject('AUM Integration Annual Batch Execution : '+ system.Today());
        string mailHtmlBody = '<br /><b>Below are the list of failed Annual AUM Records. </b><br />';
        String errorTable = '<br/><br/><b>Errors found in Annual AUM Integration process.</b><br/><table><tr><td><b>CRM Family</b></td><td><b>CRM Client</b></td><td><b>Staging Family</b></td><td><b>Staging Client</b></td><td><b>Source ID</b></td><td><b>Total AUM<b/></td><td><b>Error Message<b/></td></tr>';    
        String signature = '<br/><br/><br/><b>Edeleweiss Integration Support</b>';
        String errorRows = '';
        
        if(batchErrors != null && batchErrors.size() > 0){
            Database.executeBatch(new Edelweiss_batchDeleteInsertedCAI(InsertedIds, DeletionList), 1000);
            for(Id recordId: batchErrors.keySet()){
                Client_Asset_Information__c record = (Client_Asset_Information__c)IdToSObjectMap.get(recordId);
                errorRows = errorRows + '<tr><td>'+record.Family__c+'</td><td>'+record.Client__c+'</td><td>'+'</td><td>'+record.Staging_Family_Code__c+'</td><td>'+'</td><td>'+record.Staging_Client_Code__c+'</td><td>'+record.Source_ID__c+'</td><td>'+record.Total_AUM__c+'</td><td>'+batchErrors.get(recordid)+'</td></tr>';
            }
            
            mail.HtmlBody= mailHtmlBody + errorTable+errorRows+'</table>' + signature;  
            System.debug('Complete Html Body >>>'+mailHtmlBody +errorTable+errorRows);
            Id jobId = bcMain.getJobID();
            System.abortJob(jobId);     
        }
        else{
            mailHtmlBody = '<br /><b>Annual AUM batch executed successfully. </b><br />';
            mail.HtmlBody= mailHtmlBody + signature;  
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}