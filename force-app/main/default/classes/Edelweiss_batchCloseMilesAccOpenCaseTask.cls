////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 8 FEB 2016
//Description: Batch is used to CLose all the "Open Miles Account" Case's Tasks.
// Batch collect PAN no. and check the open Cases for PAN no. After collecting Case
// it will identify "Open Miles Account" subject task and set its Status = Completed.
// After closing task, it will update Lead and marked, Miles account open check box.
//@ 2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_batchCloseMilesAccOpenCaseTask implements Database.Batchable<sObject>, Database.Stateful
{
    global String strQuery;
    global Map<Id, String> batchErrors {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    global Id leadRecordTypeId {get; set;}
    global Id clientRecordTypeId {get; set;}
    List<Edelweiss_Error_Log__c> errors = new List<Edelweiss_Error_Log__c>();
    Map<String, Additional_Lead__c> mapAdditionalLead  {get; set;}
     
    global Edelweiss_batchCloseMilesAccOpenCaseTask() 
    {
        batchErrors = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.LEAD_RECORD_TYPE);
        clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.CLIENT_RECORD_TYPE);
        strQuery = 'SELECT Account_Name__c,ErrorMessage__c,Additional_Lead__c,Account_Type__c,Client_First_Name__c,Client_Last_Name__c,Client_Middle_Name__c,Client_Name__c,Client_Type__c,Contact_Email__c,Contact_Number__c,Date_of_Birth__c,Family_Name__c,Focus_30_Client__c,Gender__c,GWM_Online_Account_Id__c,GWM_Online_Client_Id__c,GWM_Online_Family_Id__c,High_Priority_Client__c,Is_Converted_Lead__c,Mailing_Postal_Code__c,Mailing_Address__c,Mailing_City__c,Mailing_Country__c,Mailing_State__c,Mailing_Street__c,Mobile_No__c,Nationality__c,Office_Number__c,Official_Address__c,Official_City__c,Official_Country__c,Official_Email__c,Official_Pin__c,Official_State__c,PAN_Number__c,Primary_CXO_Employee_Id__c,Primary_CXO_Miles_Id__c,Primary_Email__c,Primary_FA_Employee_Id__c,Primary_FA_Miles_Id__c,Salutation__c,Secondary_Email__c,Trading_Account_Number__c,DP_ID__c,Demat_Account_Number__c,Miles_Account_Status__c,Residential_Phone__c FROM Edelweiss_Clients_Staging_Container__c where Is_Converted_Lead__c = false AND Rejected__c = false';
         
        mapAdditionalLead = new Map<String, Additional_Lead__c>();
        for(Additional_Lead__c objLead : [SELECT Id, Name, PAN_Number__c, Case__c FROM Additional_Lead__c WHERE Converted_To_Client__c = false]){
            mapAdditionalLead.put(objLead.PAN_Number__c, objLead);
        }
    }
    
     // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Clients_Staging_Container__c> listBatchRecords) 
    {
        Integer errorFlag = 0;
        Set<String> PANNoSet = new Set<String>();
        List<Edelweiss_Clients_Staging_Container__c> updateValidationErrorList= new List<Edelweiss_Clients_Staging_Container__c>();
        List<Edelweiss_Clients_Staging_Container__c> updateAdditionalLeadFlag = new List<Edelweiss_Clients_Staging_Container__c>();
    	// Collect Map of Client Staging object
        Map<string, Edelweiss_Clients_Staging_Container__c> mapClientStagingPANAndRecords = new Map<string, Edelweiss_Clients_Staging_Container__c>();
        for(Edelweiss_Clients_Staging_Container__c objClientCont: listBatchRecords)
        {
            
           /* if(objClientCont.PAN_Number__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid PAN Number.' : objClientCont.ErrorMessage__c + '. Please enter valid PAN Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
                updateValidationErrorList.add(objClientCont); 
            }else if(objClientCont.PAN_Number__c != Null){
               	Pattern MyPattern = Pattern.compile('((([a-zA-Z]{5})\\d{4})[a-zA-Z]{1})');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.PAN_Number__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid PAN Number .' : objClientCont.ErrorMessage__c + '. Please enter valid PAN Number.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                	updateValidationErrorList.add(objClientCont); 
                }
            }*/
            
            //system.debug('Calling validateStagingData');
            validateStagingData(objClientCont,updateValidationErrorList,errorFlag);
            
            mapClientStagingPANAndRecords.put(objClientCont.PAN_Number__c, objClientCont);
            
            if(mapAdditionalLead.keySet().contains(objClientCont.PAN_Number__c)){
                if(errorFlag != 1){
                objClientCont.Additional_Lead__c = true;
                updateAdditionalLeadFlag.add(objClientCont);
            }
        }
        }
        
        if(!updateAdditionalLeadFlag.isEmpty()){
            Database.update(updateAdditionalLeadFlag);
        }
        if(!updateValidationErrorList.isEmpty()){
            Database.update(updateValidationErrorList); 
        }        
        System.debug('Take1 >> Staging Container Size = '+mapClientStagingPANAndRecords.size());
        System.debug('Take1 >> Staging Container = '+mapClientStagingPANAndRecords);
        
        Map<Id,Account> leads = new Map<Id,Account>([
	        SELECT id, PAN_Number__c FROM Account 
	        WHERE RecordTypeId = :leadRecordTypeId 
	        AND Coverage__c = 'R2'
	        AND PAN_Number__c in: mapClientStagingPANAndRecords.keySet()
        ]);
        
        System.debug('Take1 >> leads size = '+leads.size());
        System.debug('Take1 >> Leads = '+leads);
        
        Map<String,id> leadIdMap = new Map<String,id>();
        for(Account lead : leads.values()){
            leadIdMap.put(lead.Pan_Number__c,lead.id);
        }
        
        Map<String, List<Task>> mapClientPANAndCompetedTask= Edelweiss_Integration_Utility.getCompletedMilesAccountOpeningTask(mapClientStagingPANAndRecords);
        List<Task> listCompletedStatusTasks = new List<Task>();
        
        System.debug('Take1 >> MAP Case Mapping size = '+mapClientPANAndCompetedTask.size());
        
        if(mapClientPANAndCompetedTask !=null)
        {
			PANNoSet.addAll(mapClientPANAndCompetedTask.keySet());
            for(String panNumber : mapClientPANAndCompetedTask.keySet())
            {
                if(mapClientPANAndCompetedTask.get(panNumber) != null)
                {
                    for(Task objTask: mapClientPANAndCompetedTask.get(panNumber))
                    {                    
                        listCompletedStatusTasks.add(objTask);
                    }
                }
            }
        }        
        
        for(String PAN : mapClientStagingPANAndRecords.keySet()){
            if(PANNoSet.size() > 0 && !PANNoSet.contains(PAN) && leadIdMap.get(PAN) != null){
                    Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
                    exceptionRec.Error_Details__c = PAN + ' PAN no. not found in Case';
                    exceptionRec.Error_Occurred_In__c = 'Edelweiss_batchCloseMilesAccOpenCaseTask';
                    exceptionRec.Error_Type__c = 'WARNING';
                    exceptionRec.Related_Object_Name__c = 'CASE';
                    errors.add(exceptionRec);
            }
        }
        
        if(!errors.isEmpty()){
        	upsert errors;
        }
        system.debug('Final listCompletedStatusTasks>>'+listCompletedStatusTasks);
        
        // re-Assign task to its original owner
        Set<Id> successTaskIds = new set<Id>();
        if(listCompletedStatusTasks.size() > 0){
            List<Database.Saveresult> saveResultList = Edelweiss_Integration_Utility.updateMilesAccountOpeningTasks(listCompletedStatusTasks);
            System.debug('DildarLog: saveResultList - ' + saveResultList);
            if(saveResultList.size() > 0 ){
                Integer index = 0;
                for (Database.SaveResult sr : saveResultList) {
                    if(sr.isSuccess()){
                        successTaskIds.add(sr.getId());
                    }
                    else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            batchErrors.put(listCompletedStatusTasks[index].id, err.getMessage());
                            IdToSObjectMap.put(listCompletedStatusTasks[index].Id, listCompletedStatusTasks[index]);
                        }
                    }
                    index++;
                }
            }
            // Update Client Staging And mark Converted Client for which Account opening task is completed
            List<Edelweiss_Clients_Staging_Container__c> updatedClientStaging = new List<Edelweiss_Clients_Staging_Container__c>();
			set<Id> staggingId = new Set<Id>();
            if(mapClientPANAndCompetedTask.keySet() !=null)
            {
                for(String panNumber: mapClientPANAndCompetedTask.keySet())
                {
                    for(Task objTask: mapClientPANAndCompetedTask.get(panNumber)){
                        if(successTaskIds.contains(objTask.id)){
                            Edelweiss_Clients_Staging_Container__c objStag = mapClientStagingPANAndRecords.get(panNumber);
							if(objStag != null && !staggingId.contains(objStag.Id)){								
								objStag.Is_Converted_Lead__c = true;
								updatedClientStaging.add(objStag);
								staggingId.add(objStag.Id);
							}
                        }
                    }
                }
            }
            
            // Update Staging
            system.debug('updatedClientStaging>>>>'+updatedClientStaging);
            if(!updatedClientStaging.isEmpty()){
                Database.update(updatedClientStaging);
        }
            
            
    }
System.debug('Start Miles Cases: ');
        //Start - Reject staging record if miles account opening case is not closed before creating client
        List<String> lstPANOfNonExistingPrimaryClient = new List<String>();
        Set<String> setPANOfExistingClient = new Set<String>();
        List<Id> caseRecordType = new List<Id>();
        List<Edelweiss_Clients_Staging_Container__c> lstMilesTaskFailure = new List<Edelweiss_Clients_Staging_Container__c>();
        
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        
        List<Account> clients = new List<Account>([
	        SELECT Id, PAN_Number__c FROM Account 
	        WHERE RecordTypeId = :clientRecordTypeId 
	        AND PAN_Number__c in: mapClientStagingPANAndRecords.keySet()
        ]);
        
        for(Account acc : clients){
            setPANOfExistingClient.add(acc.PAN_Number__c);
        }
        
        for(Edelweiss_Clients_Staging_Container__c stgRecord : mapClientStagingPANAndRecords.values()){            
            if(!setPANOfExistingClient.contains(stgRecord.PAN_Number__c) && !stgRecord.Additional_Lead__c){
            	lstPANOfNonExistingPrimaryClient.add(stgRecord.PAN_Number__c);
            }
        }
        
        List<Case> lstCases = [
            SELECT Id, CaseNumber, Status, Pan_Number__c,
            	(SELECT Id, Subject FROM ActivityHistories WHERE (Subject =: EdelweissConstants.MILES_ACCOUNT_OPENING_TASK_TYPE OR Subject =: EdelweissConstants.MILES_ACCOUNT_OPENING_AUTO_CLOSURE_TASK_TYPE))
            FROM Case
            WHERE RecordTypeId IN : caseRecordType
            AND Pan_Number__c IN : lstPANOfNonExistingPrimaryClient
        ];
        
        for(String strPan : lstPANOfNonExistingPrimaryClient){
            for(Case objCase : lstCases){
                if(objCase.Pan_Number__c == strPan && (objCase.ActivityHistories == null || objCase.ActivityHistories.isEmpty())){
                    Edelweiss_Clients_Staging_Container__c stgRecord = mapClientStagingPANAndRecords.get(strPan);
                    stgRecord.Rejected__c = true;
                    stgRecord.ErrorMessage__c = String.isEmpty(stgRecord.ErrorMessage__c) ? 'Miles account opening task is not completed.' : stgRecord.ErrorMessage__c + '. Miles account opening task is not completed.';
                    lstMilesTaskFailure.add(stgRecord);
                }
            }
        }
    
        if(!lstMilesTaskFailure.isEmpty()){
            Database.update(lstMilesTaskFailure, false);
        }
        //End - Reject staging record if miles account opening case is not closed before creating client
        System.debug('Start Miles Cases: ');
    }
    
    
    private void validateStagingData(Edelweiss_Clients_Staging_Container__c objClientCont,List<Edelweiss_Clients_Staging_Container__c> updateValidationErrorList,Integer errorFlag){
         try{
          Boolean isErrorRecord;
          if(objClientCont.PAN_Number__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid PAN Number.' : objClientCont.ErrorMessage__c + '. Please enter valid PAN Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
                    isErrorRecord=true;
            }else if(objClientCont.PAN_Number__c != Null){
               	Pattern MyPattern = Pattern.compile('((([a-zA-Z]{5})\\d{4})[a-zA-Z]{1})');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.PAN_Number__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid PAN Number .' : objClientCont.ErrorMessage__c + '. Please enter valid PAN Number.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                	
                }  	
          }
          
           /*if(objClientCont.Mobile_No__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Mobile Number.' : objClientCont.ErrorMessage__c + '. Please enter valid Mobile Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
               // updateValidationErrorList.add(objClientCont); 
            }else*/ 
            if(objClientCont.Mobile_No__c != Null){
               	Pattern MyPattern = Pattern.compile('[0-9]{10}');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Mobile_No__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid 10 digit Mobile Number.' : objClientCont.ErrorMessage__c + '\n Please enter valid 10 digit Mobile Number.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                }  	
          }
          
          /* if(objClientCont.Contact_Number__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Contact Number.' : objClientCont.ErrorMessage__c + '. Please enter valid Contact Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
               // updateValidationErrorList.add(objClientCont); 
            }else */
            if(objClientCont.Contact_Number__c != Null){
               	Pattern MyPattern = Pattern.compile('[0-9]{10}');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Contact_Number__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid 10 digit Contact Number.' : objClientCont.ErrorMessage__c + '\n Please enter valid 10 digit Contact Number.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                	isErrorRecord=true;
                }  	
          }
          
          /*if(objClientCont.Office_Number__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Office Number.' : objClientCont.ErrorMessage__c + '. Please enter valid Office Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
            }else */
            if(objClientCont.Office_Number__c != Null){
               	Pattern MyPattern = Pattern.compile('[0-9]{3,4}-[0-9]{6,8}');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Office_Number__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Office Number.STD code should be 3-4 digit and landline number should be 6-8 digit. Ex. 022-123456' : objClientCont.ErrorMessage__c + '\n Please enter valid Office Number.STD code should be 3-4 digit and landline number should be 6-8 digit. Ex. 022-123456';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                }  	
          }
          
         /* if(objClientCont.Residential_Phone__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Residential Phone Number.' : objClientCont.ErrorMessage__c + '. Please enter valid Residential Phone Number.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
            }else */
            if(objClientCont.Residential_Phone__c != Null){
               	Pattern MyPattern = Pattern.compile('[0-9]{3,4}-[0-9]{6,8}');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Residential_Phone__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Residential Phone Number.STD code should be 3-4 digit and landline number should be 6-8 digit. Ex. 022-123456' : objClientCont.ErrorMessage__c + '\n Please enter valid Residential Phone Number. STD code should be 3-4 digit and landline number should be 6-8 digit. Ex. 022-123456';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                }  	
          }
          
         /* if(objClientCont.Primary_Email__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Primary Email.' : objClientCont.ErrorMessage__c + '. Please enter valid Primary Email.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
            }else*/
            if(objClientCont.Primary_Email__c != Null){
               	Pattern MyPattern = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,10}|[0-9]{1,10})');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Primary_Email__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Primary Email.' : objClientCont.ErrorMessage__c + '\n Please enter valid Primary Email.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                }  	
          }
          
           /*if(objClientCont.Secondary_Email__c == Null){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Secondary Email.' : objClientCont.ErrorMessage__c + '. Please enter valid Secondary Email.';
					objClientCont.Rejected__c = true;
               		errorFlag = 1;
            }else */
            if(objClientCont.Secondary_Email__c != Null){
               	Pattern MyPattern = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,10}|[0-9]{1,10})');
                Matcher MyMatcher = MyPattern.matcher(objClientCont.Secondary_Email__c);
                if(!MyMatcher.matches()){
                    objClientCont.ErrorMessage__c = String.isEmpty(objClientCont.ErrorMessage__c) ? 'Please enter valid Secondary Email.' : objClientCont.ErrorMessage__c + '\n Please enter valid Secondary Email.';
					objClientCont.Rejected__c = true;
                    errorFlag = 1;
                    isErrorRecord=true;
                }  	
          }
          
          if(isErrorRecord=true){
          	updateValidationErrorList.add(objClientCont); 
          }
         }
         catch(Exception ex){
         	 objClientCont.ErrorMessage__c = ' Error in validating Staging Data '+ex.getMessage();
			 objClientCont.Rejected__c = true;
             errorFlag = 1;
             updateValidationErrorList.add(objClientCont); 
         }
    }
    
    
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    { 
        List<Edelweiss_Clients_Staging_Container__c> listClientStaging = [SELECT GWM_Online_Client_Id__c, Client_Name__c, PAN_Number__c FROM Edelweiss_Clients_Staging_Container__c WHERE Is_Converted_Lead__c = True];
        
        List<String> toAddresses = new List<String>();
        Sys_Properties__c custSettingAdditionalToEmail = Sys_Properties__c.getValues('Client_Integration_To_EmailId');
        Sys_Properties__c custSettingEmailRecipient = Sys_Properties__c.getValues('Integration Email Recipient User');
        
        String strUserName = String.isEmpty(custSettingEmailRecipient.Value__c) ? 'PWM SalesforceUpdate' : custSettingEmailRecipient.Value__c ;
        
        List<User> listUsers = [
          SELECT Id, Email FROM User WHERE Name =: strUserName   
        ];
        for(User objUser: listUsers){
           toAddresses.add(objUser.Email); 
        }
        
        if(custSettingAdditionalToEmail != null && !String.isEmpty(custSettingAdditionalToEmail.value__c)){
        	toAddresses.addAll(custSettingAdditionalToEmail.value__c.split(','));
        }
        
        //add To email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Edeleweiss Integration Support');
        mail.setSubject('Miles Account Process Batch Execution : '+ system.Today());
        string mailHtmlBody = '<br /><b>Below are the list of PAN cards processed successfully. </b><br />';
                              
        String resultTable='';
        if(listClientStaging != null && listClientStaging.size()>0){
            for(Edelweiss_Clients_Staging_Container__c objClientStaging: listClientStaging){
                resultTable = resultTable + '<tr><td>'+objClientStaging.Client_Name__c+'</td><td>'+objClientStaging.GWM_Online_Client_Id__c+'</td><td>'+objClientStaging.PAN_Number__c+'</td></tr>';
            }
        }else{
            resultTable='<br/>Record not found!'; 
        }
        
        String errorTable = '<br/><br/><b>Errors found in Miles Account Opening process.</b><br/><table><tr><td><b>Case Id</b></td><td><b>Error Message<b/></td></tr>';
        String errorRows = '';
        if(batchErrors != null && batchErrors.size() > 0){
            for(Id recordId: batchErrors.keySet()){
                Task tsk = (Task)IdToSObjectMap.get(recordId);
                errorRows = errorRows + '<tr><td>'+tsk.whatid+'</td><td>'+batchErrors.get(recordId)+'</td></tr>';
            }
        }else{ 
            errorRows = errorRows + '<tr><td colspan="2">No error found!</td></tr>';
        }
           
        String signature = '<br/><br/><br/><b>Edeleweiss Integration Support</b>';
        mail.HtmlBody= mailHtmlBody +'<table>'+resultTable+'</table>' + errorTable+errorRows+'</table>' + signature;
        
        if(errors.size() > 0){
            String batchName = 'Edelweiss_batchCloseMilesAccOpenCaseTask';
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(toAddresses ); 
            mail1.setSenderDisplayName('Salesforce Integration Support');
            mail1.setSubject('Missing PAN Report');
            
            mailHtmlBody = 'Hello Admin team,<br/><br/> Batch <b>'+batchName+'</b> executed with errors.';
            List<Report> reports  = [select id from Report where DeveloperName = 'Missing_PAN_Error_Report'];
            string baseURL = '';
            if(reports.size() > 0){
                baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].id;
            }
            mailHtmlBody = 'Hello Admin team,<br/><br/>There were some missing PAN found while running the <b>'+batchName+'</b> batch. ' + '<br/><br/>To view the missing PAN no. , go to <b> <a href="'+baseURL +'"> Missing PAN Error Report</a> </b>';
            
            
            mail1.HtmlBody= mailHtmlBody+ signature;
            
            //Commented for timebeing
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
        }
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        
        //Commented for timebeing
        if(!Test.isRunningTest())
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //Start processing lead
		Database.executeBatch(new Edelweiss_batchCreateClient());
    }
    
}