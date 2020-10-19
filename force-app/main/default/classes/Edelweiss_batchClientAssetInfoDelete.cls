////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 13 JAN 2016
//Description: Apex batch class to delete all the existing records of Client's Asset.
//             This batch will complete remove all records of Client_Asset_Information__c object.
//             This will scheduled on daily basis. After its execution, second batch will call and 
//             all GWM Online pushed Assets data will insert back to Client_Asset_Information__c
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class Edelweiss_batchClientAssetInfoDelete implements Database.Batchable<sObject>,Database.Stateful 
{
    global String strQuery;
    global String strFinalErrorRows;
    global boolean isFamilyError;
    global List<Id> deletedRecs;
    global Integer clientAssetStagingCount;
    global List<Account> mapFamilyRecord;
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    
    global Edelweiss_batchClientAssetInfoDelete() 
    {
    	System.debug('In Constructor');
        isFamilyError = false;
        
        IdToSObjectMap = new Map<Id, SObject>();
        strQuery = 'SELECT Id, Name FROM Client_Asset_Information__c WHERE Annual_Record__c=false';
        clientAssetStagingCount = Database.countQuery('select COUNT() from Client_Asset_Staging_Container__c WHERE Annual_Record__c = \'0\' ');
        mapFamilyRecord = new List<Account>([Select Id, Name from Account Where GWM_Online_Id__c !=null AND RecordTypeId =:EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.FAMILY_RECORD_TYPE)]);
        deletedRecs = new List<Id>();
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
    	System.debug('In Start');
        return Database.getQueryLocator(strQuery);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listBatchRecords) 
    {
    	try{
    		System.debug('In Execute');
        StagingErrorResult__c customSetting =StagingErrorResult__c.getValues('AUM Staging');
        boolean errorExists = false;
        if(customSetting  != null){
        	System.debug('In Custom Setting');
            errorExists = customSetting.ErrorExist__c;
        }
        if(listBatchRecords !=null && clientAssetStagingCount > 0 && errorExists == false)
        {
        	System.debug('In List Batch Processing');
            List<Edelweiss_Error_Log__c> lstErrorRecord = new List<Edelweiss_Error_Log__c>();
            for(Client_Asset_Information__c client : listBatchRecords){
                deletedRecs.add(client.Id);
        	}           
            
            Database.DeleteResult[] drList = database.delete(listBatchRecords,false);

            if(drList.size() > 0 ){
            	System.debug('In Delete List');
                Integer index = 0; 
                for(Database.DeleteResult dr : drList){
                    if(!dr.isSuccess()){
                        for(Database.Error err : dr.getErrors()) {
							Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
							exceptionRec.Error_Details__c = 'Client Asset Information Id :- '+listBatchRecords[index].id + ' Error Message :- '+err.getMessage()+ ',[Fields]: ' +err.getFields();
							exceptionRec.Error_Occurred_In__c = 'AUA Batch';
							exceptionRec.Error_Type__c = 'ERROR';
							exceptionRec.Related_Object_Name__c = 'Client_Asset_Information__c';
							lstErrorRecord.add(exceptionRec);
                        }
                    }
                    index++;
                }
            }
            if(!lstErrorRecord.isEmpty()){
            	System.debug('In Insert List');
                Database.insert(lstErrorRecord, false);
            }
            
        }
    	}
    	catch(Exception e){
    		System.debug('Exception type caught in execute: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
    	}
    }
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
    	try{
    		System.debug('In Finish');
            List<Edelweiss_Error_Log__c> errors = new List<Edelweiss_Error_Log__c>();
            
            if(mapFamilyRecord != null && mapFamilyRecord.size() > 0){
  
	    		for(Account familyRecord: mapFamilyRecord){
	    			familyRecord.Rollup_AUM_of_Family__c = 0;
	    			familyRecord.Family_Networth__c=0;
                    familyRecord.Bypass_Validation__c = true;
	    		}
                
	    		if(mapFamilyRecord.size() > 0 && mapFamilyRecord != null){
	    			AccountTriggerhandler.stopAccountTrigger = true;
	    			AccountTriggerhandler.stopUpdatefamily = true;
	    			AccountTriggerhandler.stopSharingRules=true;
				System.debug('In Family Update');
                    Database.SaveResult[] srList = database.update(mapFamilyRecord,false);
                    System.debug('After  Family Update');
                    if(srList.size() > 0 ){
                    	System.debug('In Update List after family');
                        Integer index = 0; 
                        for(Database.SaveResult sr : srList){
                            if(!sr.isSuccess()){
                                for(Database.Error err : sr.getErrors()) {
                                    isFamilyError = true;
									
									Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
									exceptionRec.Error_Details__c = 'Family Id :- '+ mapFamilyRecord[index].Id + ' Name :-'+ mapFamilyRecord[index].Name +' Error Message :- '+err.getMessage();
									exceptionRec.Error_Occurred_In__c = 'AUA Batch';
									exceptionRec.Error_Type__c = 'ERROR';
									exceptionRec.Related_Object_Name__c = 'Account';
									errors.add(exceptionRec);
                                }
                            }
                            index++;
                        }
                    }
                    
                    AccountTriggerhandler.stopAccountTrigger = false;
	    			AccountTriggerhandler.stopUpdatefamily = false;
	    			AccountTriggerhandler.stopSharingRules=false;
	    		} 
	    	}
			
			if(errors != null && errors.size() > 0){
				Database.insert(errors,false);
            }
            System.debug('Call to next batch');
            Database.executeBatch(new Edelweiss_batchRetrieveProductRecords(deletedRecs, false), 2000); 
            
    	}catch(Exception e){
    		System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
            System.debug('In Exception Undeleting');
            Database.executeBatch(new Edelweiss_batchUndeleteCAI(deletedRecs), 1000);
    	}        
    }
    /*
    public void sendEmailNotification(){
        
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
        mail.setSubject('AUM Integration Delete Batch Execution : '+ system.Today());
		
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
	*/
}