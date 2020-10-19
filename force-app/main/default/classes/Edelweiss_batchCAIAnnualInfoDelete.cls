global class Edelweiss_batchCAIAnnualInfoDelete implements Database.Batchable<sObject>,Database.Stateful {
	global String strQuery;
    global List<Id> deletedRecs;
    global Integer clientAssetStagingCount;
    global List<Account> mapFamilyRecord;
    global List<Date> stagingDates;
    global Map<Id, String> batchErrors {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    
    global Edelweiss_batchCAIAnnualInfoDelete() 
    {
        batchErrors = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        stagingDates = new List<Date>();
        for (AggregateResult aggregate : [SELECT As_On_Date__c FROM Client_Asset_Staging_Container__c WHERE Annual_Record__c = '1' GROUP BY As_On_Date__c])
        {
            stagingDates.add((Date)aggregate.get('As_On_Date__c'));
        }
        
        strQuery = 'SELECT id, Name, Asset_Class__c, Client__c, Client_Account__c, Family__c, Scrip_Key__c, Product__c, Source_ID__c, Sub_Asset_Class__c, Total_AUM__c, Annual_Record__c, Outdated_Record__c,Networth__c FROM Client_Asset_Information__c WHERE Annual_Record__c=true AND (As_On_Date__c IN :stagingDates OR Outdated_Record__c = true)';
        mapFamilyRecord = new List<Account>([Select id,recordtypeid, Name,GWM_Online_Id__c from Account Where GWM_Online_Id__c !=null AND RecordTypeId =:EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.FAMILY_RECORD_TYPE)]);
        deletedRecs = new List<Id>();
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listBatchRecords) 
    {
        StagingErrorResult__c customSetting =StagingErrorResult__c.getValues('AUM Staging');
        boolean errorExists = false;
        if(customSetting  != null){
            errorExists = customSetting.ErrorExist__c;
        }
        if(listBatchRecords !=null && stagingDates.size() > 0 && errorExists == false)
        {
            for(Client_Asset_Information__c client : listBatchRecords){
                deletedRecs.add(client.Id);
        	}
            
            Database.DeleteResult[] drList = database.delete(listBatchRecords,false);

            if(drList.size() > 0 ){
                Integer index = 0; 
                for(Database.DeleteResult dr : drList){
                    if(!dr.isSuccess()){
                        for(Database.Error err : dr.getErrors()) {
                            batchErrors.put(listBatchRecords[index].id, err.getMessage() + ',[Fields]: ' + err.getFields());
                            IdToSObjectMap.put(listBatchRecords[index].Id, listBatchRecords[index]);
                        }
                    }
                    index++;
                }
            }
        }
    }
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain)
    {
        try{
            if(batchErrors.isEmpty()){
                Database.executeBatch(new Edelweiss_batchRetrieveProductRecords(deletedRecs, true), 2000);    
            }
            else {
                
                Database.executeBatch(new Edelweiss_batchUndeleteCAI(deletedRecs), 1000);
                
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
                
                string mailHtmlBody = '<br /><b>Below is the list of error records. </b><br />';
                String errorTable = '<br/><br/><b>Errors found in Annual AUM Integration process.</b><br/><table><tr><td><b>Record Id</b></td><td><b>Record Name</b></td><td><b>Error Message<b/></td></tr>';    
                String signature = '<br/><br/><br/><b>Edeleweiss Integration Support</b>';
                String errorRows = '';
                
                for(Id recordId: batchErrors.keySet()){
                    Client_Asset_Information__c record = (Client_Asset_Information__c)IdToSObjectMap.get(recordId);
                    errorRows = errorRows + '<tr><td>'+record.Id+'</td><td>'+record.Name+'</td><td>'+batchErrors.get(recordId)+'</td></tr>';
                }
                
                mail.HtmlBody= mailHtmlBody + errorTable+errorRows+'</table>' + signature;  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
    	}catch(Exception ex){
    		System.debug('Exception in CAI Deletion batch - ' + ex);
    	}        
    } 
}