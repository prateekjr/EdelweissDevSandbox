////////////////////////////////////
//Author: Shailesh Chimote
//Date: 31 July 2017
//Description: Apex batch class converts Additional Lead records to Client's came from GWM Online.
//@ 2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_ProcessAdditionalLeads implements Database.Batchable<sObject> ,Database.Stateful
{
    
    //*****************************
    Map<String, User> mapFaCxoUser;
    global Id leadRecordTypeId {get; set;}
    global Id clientRecordTypeId {get; set;}
    global Id familyRecordTypeId {get; set;}
    global Boolean hasPreviousBatchError {get; set;}
    
    global Map<Id, Additional_Lead__c> mapLeadRecord;
    global Map<String, Additional_Lead__c> mapPan_AdditionalLeadRecord;
    global Set<String> primaryLeadPanToCase = new Set<String>();
    global Map<String, Account> mapGWMId_FamilyId = new Map<String, Account>();
    global Map<Id, Case> caseMap {get; set;}
    global Set<String> setOfExistingPrimaryClientPAN {get; set;}
    List<Id> caseRecordType {get; set;}
    //*****************************
    
    global String strQuery; 
    // Map<GWM_Id, SF_Id> for Family, Client, Account   
    
    global Map<String, ID> mapClientAccNameId;
    // Scrip id as Key and Product ID as Value

    // PAN no. as Key & Lead ID as Value
    global Map<String, ID> mapLeadPANId;        


    
    // Error Related Variables
    private boolean isError;
    private Set<Edelweiss_Clients_Staging_Container__c> errorStagingClients;
    
    
    global Edelweiss_ProcessAdditionalLeads(Boolean batchError) 
    {
        System.debug('Constructor Executed Start');
        
        hasPreviousBatchError = batchError;
        isError = false;
        strQuery = 'SELECT ID,ISDELETED,NAME,ACCOUNT_NAME__C,ACCOUNT_TYPE__C,ALTERNATE_NUMBER__C,ANNIVERSARY_DATE__C,CLIENT_FIRST_NAME__C,CLIENT_LAST_NAME__C,CLIENT_MIDDLE_NAME__C,CLIENT_NAME__C,CLIENT_TYPE__C,CONTACT_EMAIL__C,CONTACT_NUMBER__C,ERRORMESSAGE__C,FAMILY_NAME__C,FOCUS_30_CLIENT__C,GWM_ONLINE_ACCOUNT_ID__C,GWM_ONLINE_CLIENT_ID__C,GWM_ONLINE_FAMILY_ID__C,GENDER__C,HIGH_PRIORITY_CLIENT__C,IS_CONVERTED_LEAD__C,MAILING_ADDRESS__C,MAILING_CITY__C,MAILING_COUNTRY__C,MAILING_POSTAL_CODE__C,MAILING_STATE__C,MAILING_STREET__C,MOBILE_NO__C,NATIONALITY__C,OFFICE_NUMBER__C,OFFICIAL_ADDRESS__C,OFFICIAL_CITY__C,OFFICIAL_COUNTRY__C,OFFICIAL_EMAIL__C,OFFICIAL_PIN__C,OFFICIAL_STATE__C,PAN_NUMBER__C,PRIMARY_CXO_EMPLOYEE_ID__C,PRIMARY_CXO_MILES_ID__C,PRIMARY_EMAIL__C,PRIMARY_FA_EMPLOYEE_ID__C,PRIMARY_FA_MILES_ID__C,RESIDENTIAL_PHONE__C,SALUTATION__C,SECONDARY_EMAIL__C,SYNCH__C,IS_DELETED__C,IS_CLIENT_FAMILY_HEAD__C,DATE_OF_BIRTH__C,POA__C,SUB_LOB__C,MANDATE__C,MILES_ACTIVATION_DATE__C , Trading_Account_Number__c,DP_ID__c,Demat_Account_Number__c,Miles_Account_Status__c FROM Edelweiss_Clients_Staging_Container__c WHERE Synch__c = false AND Additional_Lead__c = true AND is_Deleted__c = false AND Rejected__c = false';
        errorStagingClients= new Set<Edelweiss_Clients_Staging_Container__c>();
        leadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        clientRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
        familyRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
        
        caseRecordType = new List<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        
        
        caseMap = new Map<Id, Case>([
            SELECT Id, CaseNumber, Status, Pan_Number__c,
            	(SELECT Id, Name, PAN_Number__c, Mobile__c, Email__c, Converted_To_Client__c, Case__c, Case__r.Pan_Number__c FROM Additional_Leads__r WHERE Converted_To_Client__c = false),
            	(SELECT Id, Subject FROM ActivityHistories WHERE Subject='Miles Account Opening')
            FROM Case
            WHERE Status NOT IN ('Closed – Success', 'Closed – Rejected', 'On Hold')
            AND RecordTypeId IN : caseRecordType
            AND Pan_Number__c <> Null
        ]);
        
        mapPan_AdditionalLeadRecord = new Map<String, Additional_Lead__c>();
        
        for(Case objCase : caseMap.values()){
            if(objCase.ActivityHistories != null && !objCase.ActivityHistories.isEmpty() && 
               objCase.Additional_Leads__r != null && !objCase.Additional_Leads__r.isEmpty()){
                
                primaryLeadPanToCase.add(objCase.Pan_Number__c);
                for(Additional_Lead__c lead : objCase.Additional_Leads__r){
                    mapPan_AdditionalLeadRecord.put(lead.Pan_Number__c, lead);
                }
            } 
        }
        System.debug('primaryLeadPanToCase '+primaryLeadPanToCase);
        
        
        Map<String, Edelweiss_Clients_Staging_Container__c> mapPan_PrimaryLead = new Map<String, Edelweiss_Clients_Staging_Container__c>();
        List<Edelweiss_Clients_Staging_Container__c> lstPrimaryLead = [
            SELECT ID,ISDELETED,NAME,ACCOUNT_NAME__C,ACCOUNT_TYPE__C,ALTERNATE_NUMBER__C,ANNIVERSARY_DATE__C,CLIENT_FIRST_NAME__C,CLIENT_LAST_NAME__C,CLIENT_MIDDLE_NAME__C,CLIENT_NAME__C,CLIENT_TYPE__C,CONTACT_EMAIL__C,CONTACT_NUMBER__C,ERRORMESSAGE__C,FAMILY_NAME__C,FOCUS_30_CLIENT__C,GWM_ONLINE_ACCOUNT_ID__C,GWM_ONLINE_CLIENT_ID__C,GWM_ONLINE_FAMILY_ID__C,GENDER__C,HIGH_PRIORITY_CLIENT__C,IS_CONVERTED_LEAD__C,MAILING_ADDRESS__C,MAILING_CITY__C,MAILING_COUNTRY__C,MAILING_POSTAL_CODE__C,MAILING_STATE__C,MAILING_STREET__C,MOBILE_NO__C,NATIONALITY__C,OFFICE_NUMBER__C,OFFICIAL_ADDRESS__C,OFFICIAL_CITY__C,OFFICIAL_COUNTRY__C,OFFICIAL_EMAIL__C,OFFICIAL_PIN__C,OFFICIAL_STATE__C,PAN_NUMBER__C,PRIMARY_CXO_EMPLOYEE_ID__C,PRIMARY_CXO_MILES_ID__C,PRIMARY_EMAIL__C,PRIMARY_FA_EMPLOYEE_ID__C,PRIMARY_FA_MILES_ID__C,RESIDENTIAL_PHONE__C,SALUTATION__C,SECONDARY_EMAIL__C,SYNCH__C,IS_DELETED__C,IS_CLIENT_FAMILY_HEAD__C,DATE_OF_BIRTH__C,POA__C,SUB_LOB__C,MANDATE__C,MILES_ACTIVATION_DATE__C 
            FROM Edelweiss_Clients_Staging_Container__c 
            WHERE is_Deleted__c = false AND Rejected__c = false 
            AND Pan_Number__c IN :primaryLeadPanToCase AND Error__c = false
        ];
        

        
        for(Edelweiss_Clients_Staging_Container__c lead : lstPrimaryLead){
            mapPan_PrimaryLead.put(lead.Pan_Number__c, lead);
        }
        
        for(Account family : [SELECT Id, GWM_Online_Id__c FROM Account WHERE RecordTypeId = :familyRecordTypeId]){
            mapGWMId_FamilyId.put(family.GWM_Online_Id__c, family);        
        }
        
        // collect all FA & Cxo Profile Users
        mapFaCxoUser = new Map<String, User>();
        Sys_Properties__c custSettFaProfileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
        Sys_Properties__c custSettCxoProfileId = Sys_Properties__c.getValues('Profile Client Experience Office Id');
		Sys_Properties__c custSettCxoZonalHeadProfileId = Sys_Properties__c.getValues('Profile CXO Zonal Head Id');
		Sys_Properties__c custSettCxoNationalHeadProfileId = Sys_Properties__c.getValues('Profile CXO National Head Id');
		Sys_Properties__c custSettFaFOIGProfileId = Sys_Properties__c.getValues('Profile Financial Advisor FOIG Id');
        Sys_Properties__c custSettTLAdvoisoryProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory Id');
        Sys_Properties__c custSettTLAdvoisoryFOIGProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory FOIG Id');
		Sys_Properties__c custSettRegionalHeadProfileId = Sys_Properties__c.getValues('Profile Regional Head Id');
		
        Set<Id> setFaCxoId = new Set<Id>();
        setFaCxoId.add(custSettFaProfileId.Value__c);
        setFaCxoId.add(custSettCxoProfileId.Value__c);
		setFaCxoId.add(custSettCxoZonalHeadProfileId.Value__c);
		setFaCxoId.add(custSettCxoNationalHeadProfileId.Value__c);
		setFaCxoId.add(custSettFaFOIGProfileId.Value__c);
        setFaCxoId.add(custSettTLAdvoisoryProfileId.Value__c);
        setFaCxoId.add(custSettTLAdvoisoryFOIGProfileId.Value__c);
		setFaCxoId.add(custSettRegionalHeadProfileId.Value__c);
        
        list<User> listFaCxoUsers= [Select Id, Name, Edelweiss_Employee_Id__c, Miles_Id__c From User where ProfileId =:setFaCxoId];
        For(User objUserFa : listFaCxoUsers)
        {
            mapFaCxoUser.put(objUserFa.Edelweiss_Employee_Id__c+objUserFa.Miles_Id__c, objUserFa);
        }
        
        
        
        Set<String> casePanSet = new Set<String>();
        for(Additional_Lead__c lead : mapPan_AdditionalLeadRecord.values()){
            casePanSet.add(lead.Case__r.Pan_Number__c);
        }
        //Primary Client - It's Client whose PAN number is assciated with Case. These clients are not converted from Additional Leads.
        List<Account> lstExistingPrimaryClient = [
            SELECT Id, Name, Pan_Number__c FROM Account 
            WHERE RecordTypeId = :clientRecordTypeId AND Pan_Number__c IN :casePanSet
        ];
        
        setOfExistingPrimaryClientPAN = new Set<String>();
        for(Account acc : lstExistingPrimaryClient){
            setOfExistingPrimaryClientPAN.add(acc.Pan_Number__c);
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
        System.debug('listBatchRecords '+listBatchRecords.size());
        try
        {   
            List<Account> listOfConvertedClient = new List<Account>();
            List<Account> listOfConvertedFamily = new List<Account>();
            List<Client_Account__c> listOfConvertedAccountOfClient = new List<Client_Account__c>();
            Map<String, Id> mapConvertedLead = new Map<String, Id>();
            Map<String, Account> mapFamilyGwmIdNewCreatedFamily ;
            Map<String, List<Account>> mapExistingClientOfCrm;
            Map<Id, Contact> mapSfIdCreatedClientAndContact;
            Map<string, Account> mapGwmIdNewCreatedClient;
            Map<String, String> mapExistingClientGwmIdAndFamilyGwmId;
            
            // Stop event unnecessary trigger execution
            EventTriggerHandler.stopEventTrigger = true;
            Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord = new Map<String, Edelweiss_Clients_Staging_Container__c>();
            
            //Collect existing Family, Client, Account....
            Map<Id,Account> mapExistingCrmFamilyRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c, Lead_Category__c, Mandate__c from Account Where RecordTypeId =: familyRecordTypeId]);
            Map<Id,Account> mapClientRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, Parent.GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c,Is_Client_Family_Head__c from Account Where RecordTypeId =: clientRecordTypeId]);
            Map<Id,Client_Account__c> mapAccountRecord = new Map<Id, Client_Account__c>([Select id, Name,GWM_Client_Account_Id__c  from Client_Account__c]);
            
            //collect Map of Name, ID for all Family, Client and Account.
            mapClientAccNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapClientRecord,EdelweissConstants.OBJECT_ACCOUNT);        
            system.debug('mapClientGWMIdandSFId >>>'+mapClientAccNameId);
            system.debug('mapFaCxoUser>>>'+mapFaCxoUser);
            
            Map<String,Edelweiss_Clients_Staging_Container__c> mapGWMFamilyStaging = new Map<String,Edelweiss_Clients_Staging_Container__c>();
            Map<String,Edelweiss_Clients_Staging_Container__c> mapGWMClientStaging = new Map<String,Edelweiss_Clients_Staging_Container__c>();
            Map<String,Edelweiss_Clients_Staging_Container__c> mapGWMAccountStaging = new Map<String,Edelweiss_Clients_Staging_Container__c>();
            
            // create Map of PAN no. & Edelweiss_Clients_Staging_Container__c record.
            for(Edelweiss_Clients_Staging_Container__c objStaging : listBatchRecords)
            {
                mapPanClientStagingRecord.put(objStaging.PAN_Number__c, objStaging);
                mapGWMFamilyStaging.put(objStaging.GWM_Online_Family_Id__c,objStaging);
                mapGWMClientStaging.put(objStaging.GWM_Online_Client_Id__c,objStaging);
                mapGWMAccountStaging.put(objStaging.GWM_Online_Account_Id__c,objStaging);
            }
            
            
            List<Edelweiss_Clients_Staging_Container__c> lstStgRecords = new List<Edelweiss_Clients_Staging_Container__c>();
            for(Edelweiss_Clients_Staging_Container__c stgRecord : listBatchRecords){
                if(mapPan_AdditionalLeadRecord.get(stgRecord.Pan_Number__c) != null &&
                    setOfExistingPrimaryClientPAN.contains(mapPan_AdditionalLeadRecord.get(stgRecord.Pan_Number__c).Case__r.Pan_Number__c)){
                    stgRecord.Rejected__c = false;
                }
                else{
                    stgRecord.Rejected__c = true;
                    if(String.isEmpty(stgRecord.ErrorMessage__c)){
                        stgRecord.ErrorMessage__c = 'Rejected - Primary lead is not converted to Client';
                    }
                    else{
                        stgRecord.ErrorMessage__c += '*********** Rejected - Primary lead is not converted to Client **********';
                    }
                }
                lstStgRecords.add(stgRecord);
            }
            
            if(!lstStgRecords.isEmpty()){
                Database.update(lstStgRecords);
            }
            
            //********************** Additional Lead Conversion Process - START ********************
            
			List<Account> lstNewClients = Edelweiss_Integration_Utility.generateAdditionalClientRecords(lstStgRecords, mapPan_AdditionalLeadRecord, mapGWMId_FamilyId, mapFaCxoUser);
            
            System.debug('lstNewClients :'+lstNewClients);
            
            List<Account> newInsertedClient = new List<Account>();
            List<Additional_Lead__c> lstLeadsProcessed = new List<Additional_Lead__c>();
            Map<Id,Edelweiss_Clients_Staging_Container__c> clientAndStagingMapContainer = new Map<Id,Edelweiss_Clients_Staging_Container__c>();
            
            if(!lstNewClients.isEmpty()){
                
                Database.SaveResult [] ClientRes= database.insert(lstNewClients, false);
                Integer index = 0;
                
                for(Database.SaveResult sr : ClientRes)
                {
                    if(sr.isSuccess()){
                        
                        newInsertedClient.add(lstNewClients[index]);
                        Additional_Lead__c objAdditionalLead = mapPan_AdditionalLeadRecord.get(lstNewClients[index].Pan_Number__c);
                        objAdditionalLead.Converted_To_Client__c = true;
                        lstLeadsProcessed.add(objAdditionalLead);
                        clientAndStagingMapContainer.put(sr.getId(),mapGWMClientStaging.get(lstNewClients[index].GWM_Online_Id__c));
                        
                        if(mapGWMClientStaging.get(lstNewClients[index].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMClientStaging.get(lstNewClients[index].GWM_Online_Id__c);
                            stage.synch__c = true;
                            stage.Is_Converted_Lead__c = true;
                            stage.ErrorMessage__c = '';
                            errorStagingClients.add(stage);
                        }
                    }else{
                        String errorMessage = '';
                        if(mapGWMClientStaging.get(lstNewClients[index].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMClientStaging.get(lstNewClients[index].GWM_Online_Id__c);
                            if(String.isEmpty(stage.ErrorMessage__c)){
                                stage.ErrorMessage__c = '';
                            }
                            errorMessage = stage.errorMessage__c;
                            for(Database.Error err : sr.getErrors()) {
                                stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;
                            errorStagingClients.add(stage);
                        }
                        isError = true;    
                    }
                    index++;
                }
            }
                
            if(!lstLeadsProcessed.isEmpty()){
                update lstLeadsProcessed;
            }
            //********************** Additional Lead Conversion Process - END ********************
            
            //If new additional leads crated successfully, create Client Acount and Contacts
            if(!newInsertedClient.isEmpty()){
                mapGwmIdNewCreatedClient= new Map<string, Account>();
                Map<Id, Id> mapClientIdFamilyId = new Map<Id, Id>();
                
                for(Account objNewClient : newInsertedClient)
                {
                    mapGwmIdNewCreatedClient.put(objNewClient.GWM_Online_Id__c, objNewClient);
                    mapClientIdFamilyId.put(objNewClient.Id, objNewClient.ParentId);
                }
                
               
                //********************** Create Contact for new Client ********************
                
                List<Contact> listConvertedClientContact = Edelweiss_Integration_Utility.generateAdditionalClientContact(mapGwmIdNewCreatedClient, mapPan_AdditionalLeadRecord, mapPanClientStagingRecord);
                system.debug('listConvertedClientContact>>'+listConvertedClientContact);
                Integer index = 0;
                Database.SaveResult[] clientContact  = database.insert(listConvertedClientContact,false);
                System.debug('Client Created>>>'+clientContact);
                for(Database.SaveResult sr : clientContact)
                {
                	System.debug('sr.isSuccess() >>>'+sr.isSuccess());
                    if(!sr.isSuccess()){
                        String errorMessage = '';
                        if(clientAndStagingMapContainer.get(listConvertedClientContact[index].AccountId) != null){
                            Edelweiss_Clients_Staging_Container__c stage = clientAndStagingMapContainer.get(listConvertedClientContact[index].AccountId);
                            if(String.isEmpty(stage.ErrorMessage__c)){
                                stage.ErrorMessage__c = '';
                            }
                            errorMessage = stage.ErrorMessage__c = '';
                            for(Database.Error err : sr.getErrors()) {
                                stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;
                            errorStagingClients.add(stage);
                        }
                        isError = true;
                            
                    }else{
                        if(clientAndStagingMapContainer.get(listConvertedClientContact[index].AccountId) != null){
                        	Edelweiss_Clients_Staging_Container__c stage = clientAndStagingMapContainer.get(listConvertedClientContact[index].AccountId);
                            stage.Synch__c = true;
                            stage.ErrorMessage__c = '';
                            errorStagingClients.add(stage);
                        }
                    }
                    index++;
                }
                //********************** Create Contact for new Client - END ********************

                
                
                //********************** Create Client Account for new Client ********************

                listOfConvertedAccountOfClient =Edelweiss_Integration_Utility.generateAdditionalClientAccountRecords(mapGwmIdNewCreatedClient, mapPanClientStagingRecord);                
                System.debug('listOfConvertedAccountOfClient  >>>'+listOfConvertedAccountOfClient);
                
                Set<ID> FailedAccountsToBeDeleted = new Set<ID>();
                Database.SaveResult [] ClientAccRes= database.insert(listOfConvertedAccountOfClient,false);
                index = 0;
                for(Database.SaveResult sr : ClientAccRes)
                {
                	System.debug('Client Account sr.isSuccess() >>>'+sr.isSuccess());
                    if(!sr.isSuccess()){
                        String errorMessage = '';
                        if(mapGWMAccountStaging.get(listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMAccountStaging.get(listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c);
                            if(String.isEmpty(stage.ErrorMessage__c)){
                                stage.ErrorMessage__c = '';
                            }
                            errorMessage = stage.errorMessage__c;
                            for(Database.Error err : sr.getErrors()) {
                                stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;
                            errorStagingClients.add(stage);
                        }
                        isError = true;
                            
                    }else{
                        if(mapGWMAccountStaging.get(listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c) != null){
                            
                            System.debug('Inside else 1>>> GWM Client Account Id >>> '+listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c);
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMAccountStaging.get(listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c);
                            stage.synch__c = true;
                            stage.errorMessage__c = '';
                            errorStagingClients.add(stage);
                        }
                    }
                    index++;
                }
                
            }
            //********************** Create Client Account for new Client - END ********************
            
           
        }
        catch(exception ex)
        {
            system.debug('My LOg'+ex);
            isError = true;
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_ProcessAdditionalLeads; Function : execute()');
        }
    }
    
    
    // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {

        // Optional - we can send an email to an admin with results
        EventTriggerHandler.stopEventTrigger =false;
        if(errorStagingClients != null && errorStagingClients.size() > 0){
            List<Edelweiss_Clients_Staging_Container__c> listStaging = new List<Edelweiss_Clients_Staging_Container__c>();
            listStaging.addALL(errorStagingClients);
            update listStaging;
        }
        
        List<String> lstMissingPan = getMissingAdditionalLeadsPAN();
        
        if(!lstMissingPan.isEmpty()){
            sendMissingPanNotification(lstMissingPan);
        }
        
        if(isError || hasPreviousBatchError){
            sendNotificationToAdmin();
        }
        
		//Database.executeBatch(new Edelweiss_batchUpdateClientData(),200);
		//
		Database.executeBatch(new Edelweiss_batchCreateClientForHNI(),200);
        

    }
    
      // this method is used in the staging objects record deletion batches
    public  void sendNotificationToAdmin(){
        
        // collect users for profile.
        List<String> tos = new List<String>();
        Sys_Properties__c custSettingToEmailProfile = Sys_Properties__c.getValues('ProfileSendNotification MilesTicket');

        // collect users for profile.
        List<User> listProfileUsers = Edelweiss_Integration_Utility.getProfileUserList(custSettingToEmailProfile.value__c);
        String strToEmail;
        for(User objUser: listProfileUsers ){
           tos.add(objUser.email); 
        }
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(tos); 
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Create Client Error Report');
        
        List<Report> reports  = [select id from Report where DeveloperName = 'Client_Staging_Error_report'];
        string baseURL = '';
        if(reports.size() > 0){
            baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].id;
        }
        String mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>Client Creation</b> batch. ' + '<br/><br/>To view failed records, go to <b> <a href="'+baseURL +'"> Client Data Error Report</a> </b>';
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        
        mail.HtmlBody= mailHtmlBody+ signature;
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public void sendMissingPanNotification(List<String> lstPan){
        
        // collect users for profile.
        List<String> tos = new List<String>();
        Sys_Properties__c custSettingToEmailProfile = Sys_Properties__c.getValues('ProfileSendNotification MilesTicket');

        // collect users for profile.
        List<User> listProfileUsers = Edelweiss_Integration_Utility.getProfileUserList(custSettingToEmailProfile.value__c);
        String strToEmail;
        for(User objUser: listProfileUsers ){
           tos.add(objUser.email); 
        }
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(tos); 
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Additional Lead PAN record missing in Client Staging Container');
        
        String mailHtmlBody = 'Hello Admin team,<br/><br/>Below listed Additional Lead PAN record missing in Client Staging Container';
        String panNumber = '<br/>';
        for(String pan : lstPan){
            panNumber+= '<br/>'+pan;
        }
        mailHtmlBody += panNumber;
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        
        mail.HtmlBody= mailHtmlBody+ signature;
        System.debug('Complete Missing PAN Html Body >>>'+mailHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public List<String> getMissingAdditionalLeadsPAN(){
        List<String> lstPan = new List<String>();
        
		List<Edelweiss_Clients_Staging_Container__c> lstStgRecords = [SELECT ID, Pan_Number__c FROM Edelweiss_Clients_Staging_Container__c WHERE Synch__c = false];        
        Set<String> setStgPan = new Set<String>();
        for(Edelweiss_Clients_Staging_Container__c STG : lstStgRecords){
            setStgPan.add(STG.Pan_Number__c);
        }
        
        
        Map<Id, Case> caseTempMap = new Map<Id, Case>([
            SELECT Id, CaseNumber, Status, Pan_Number__c,
            	(SELECT Id, Name, PAN_Number__c, Mobile__c, Email__c, Converted_To_Client__c, Case__c, Case__r.Pan_Number__c FROM Additional_Leads__r WHERE Converted_To_Client__c = false),
            	(SELECT Id, Subject FROM ActivityHistories WHERE Subject='Miles Account Opening')
            FROM Case
            WHERE Status NOT IN ('Closed – Success', 'Closed – Rejected', 'On Hold')
            AND RecordTypeId IN : caseRecordType
            AND Pan_Number__c <> Null
        ]);
        
        Map<String, Additional_Lead__c> mapTempPan_AdditionalLeadRecord = new Map<String, Additional_Lead__c>();
        
        for(Case objCase : caseTempMap.values()){
            if(objCase.ActivityHistories != null && !objCase.ActivityHistories.isEmpty() && 
               objCase.Additional_Leads__r != null && !objCase.Additional_Leads__r.isEmpty()){
                
                for(Additional_Lead__c lead : objCase.Additional_Leads__r){
                    mapTempPan_AdditionalLeadRecord.put(lead.Pan_Number__c, lead);
                }
            } 
        }
        
        if(!mapTempPan_AdditionalLeadRecord.isEmpty()){
            for(String PAN : mapTempPan_AdditionalLeadRecord.keySet()){
                if(!setStgPan.contains(PAN)){
                    lstPan.add(PAN);
                }
            }
        }
        
        return lstPan;
    }
}