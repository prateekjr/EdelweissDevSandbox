////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 18 JAN 2016
//Description: Apex batch class to insert fresh records of Client's came from GWM Online.
//             This batch will run after the Data Loader will push all GWM Online data to Saleforce.
//             batch apex will collect all data from Edelweiss_Clients_Staging_Container__c and create Fa,ily, Client & Account data for the converted Lead.
//             After records creation, this class will convert Lead into Converted Lead. Apex batch also validate change of Family for client.
//@ 2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_batchCreateClient implements Database.Batchable<sObject> ,Database.Stateful
{
    global String strQuery; 
    // Map<GWM_Id, SF_Id> for Family, Client, Account   
    global Map<String, ID> mapFamilyAccNameId;
    global Map<String, ID> mapClientAccNameId;
    global Map<String, ID> mapAccountAccNameId;
    // Scrip id as Key and Product ID as Value
    global Map<String, ID> mapProductScripId;        
    // PAN no. as Key & Lead ID as Value
    global Map<String, ID> mapLeadPANId;        
    global Map<id, Account> mapLeadRecord;
    Map<String, User> mapFaCxoUser;
    global Id leadRecordTypeId {get; set;}
    global Id clientRecordTypeId {get; set;}
    global Id familyRecordTypeId {get; set;}
    
    // Error Related Variables
    private boolean isError;
    private Set<Edelweiss_Clients_Staging_Container__c> errorStagingClients;
    // Class Constructor - set query string
    global Edelweiss_batchCreateClient() 
    {
        isError = false;
        strQuery = 'SELECT ID,ISDELETED,NAME,ACCOUNT_NAME__C,ACCOUNT_TYPE__C,ALTERNATE_NUMBER__C,ANNIVERSARY_DATE__C,CLIENT_FIRST_NAME__C,CLIENT_LAST_NAME__C,CLIENT_MIDDLE_NAME__C,CLIENT_NAME__C,CLIENT_TYPE__C,CONTACT_EMAIL__C,CONTACT_NUMBER__C,ERRORMESSAGE__C,FAMILY_NAME__C,FOCUS_30_CLIENT__C,GWM_ONLINE_ACCOUNT_ID__C,GWM_ONLINE_CLIENT_ID__C,GWM_ONLINE_FAMILY_ID__C,GENDER__C,HIGH_PRIORITY_CLIENT__C,IS_CONVERTED_LEAD__C,MAILING_ADDRESS__C,MAILING_CITY__C,MAILING_COUNTRY__C,MAILING_POSTAL_CODE__C,MAILING_STATE__C,MAILING_STREET__C,MOBILE_NO__C,NATIONALITY__C,OFFICE_NUMBER__C,OFFICIAL_ADDRESS__C,OFFICIAL_CITY__C,OFFICIAL_COUNTRY__C,OFFICIAL_EMAIL__C,OFFICIAL_PIN__C,OFFICIAL_STATE__C,PAN_NUMBER__C,PRIMARY_CXO_EMPLOYEE_ID__C,PRIMARY_CXO_MILES_ID__C,PRIMARY_EMAIL__C,PRIMARY_FA_EMPLOYEE_ID__C,PRIMARY_FA_MILES_ID__C,RESIDENTIAL_PHONE__C,SALUTATION__C,SECONDARY_EMAIL__C,SYNCH__C,IS_DELETED__C,IS_CLIENT_FAMILY_HEAD__C,DATE_OF_BIRTH__C,POA__C,SUB_LOB__C,MANDATE__C,MILES_ACTIVATION_DATE__C,Trading_Account_Number__c,DP_ID__c,Demat_Account_Number__c,Miles_Account_Status__c,Backoffice_Code_NBFC__c FROM Edelweiss_Clients_Staging_Container__c where Synch__c = false AND is_Deleted__c = false AND Rejected__c = false AND Is_HNI_Client__c=false';  
        errorStagingClients= new Set<Edelweiss_Clients_Staging_Container__c>();
        leadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        clientRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
        familyRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
        
        //Modify the list of fields as per Account
        mapLeadRecord = new Map<Id, Account>([Select Id, Name, Last_Name_CR__c, Relationship_with_Lead_Client__c, Land_Line_Number_of_CR__c, Secondary_Email_Id_Of_CR__c, 
			Annual_Income__c,Asset_Allocation_across_wealth_managers__c, Asset_Classes_Client_is_Interested_in__c,Clubs__c, 
			Current_Investment_Portfolio_formula__c, Date_Proposal_is_submitted__c,GWM_Touch_Points__c, Interests_Hobbies__c,Investible_Assets__c,
			Investment_Horizon_Months__c,Is_Client_Family_Head__c,OwnerId,NGOs__c,Other_Edelweiss_SBU_Working_with_Client__c,Political_Affiliations__c,
			Preferred_Mode_of_Communication__c,Entity_Type__c, Preferred_Time_of_Communication_Picklist__c,Religious_Beliefs__c,
			Risk_Profile_Based_on_IPS__c,Current_Investment_Portfolio__c,Products_Client_is_Interested_in__c,Category__c,IPS_Done__c,
			Strong_Dislikes_If_Any__c,Sub_Lob__c, Total_Net_Worth__c,Zone__c, PAN_Number__c,Alternate__c,Alternate_Description__c,
			Balanced__c,Balanced_Description__c,Cash__c,Cash_Description__c, Connect_Information__c, Equity_Description__c,
			Connect_Within_Edelweiss__c,Database_Name__c,Date_of_Inception__c,Employee_Name__c,Equity__c, Derivatives_Futures_Slab_Derivative__c,
			Fixed_Income__c,Fixed_Income_Description__c,Entered_Meeting_Notes_For_R1__c,Name_of_Third_Party__c,Notes__c, Number_of_Locations__c,
			Other_Information_Shared_with_Prospect__c,RE__c,RE_Description__c,Relationship_with_Third_Party__c,SBU_Name__c,Size_of_Deal__c,
			Source_of_News__c,Sub_Broker_Name__c, Organization_Type__c,Other__c, Coverage__c, Company__c, Lead_Category__c, How_Often_Does_Client_Monitor_Portfolio__c,
			Sub_Category__c,Sub_Source_Level_1__c,Sub_Source_Level_2__c,Unique_Identifier__c, Type__c, Products_Recommended_to_Clients__c, 
			Current_Generators__c, SIC_Code__c, First_Name_CR__c, Mobile_Number_of_CR__c, Email_Id_of_CR__c, Address_of_CR__c, Account_Source_Other__c,
			Mobile_1__c, Mobile_2__c, Phone, Primary_Email__c, Secondary_Email__c, Residence_Address__c, Official_Address__c , AccountSource, Referrer_Name__c, 
            Referrer_Contact__c, Trading_Account_Number__c, Demat_Account_Number__c, Miles_Account_Status__c, DP_ID__c, Account_Type__c,Backoffice_Code_NBFC__c
			From Account  
			Where RecordTypeId = :leadRecordTypeId 
			AND Coverage__c = 'R2']);
        //Open_an_account_opening_Case__c
        //AND FA_had_open_a_ticket_case__c = True
			 
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
        //generate Map<Edelweiss_Employee_Id__c+Miles_Id__c , User>
        //mapProductScripId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapProductRecord,EdelweissConstants.OBJECT_PRODUCT);       
        mapLeadPANId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapLeadRecord,EdelweissConstants.OBJECT_LEAD);
        
    }
    
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Clients_Staging_Container__c> listBatchRecords) 
    {
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
            system.debug('listBatchRecords:: <><>< '+listBatchRecords);
            
            Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord = new Map<String, Edelweiss_Clients_Staging_Container__c>();
            
            //Collect existing Family, Client, Account....
            Map<Id,Account> mapExistingCrmFamilyRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c, Lead_Category__c, Mandate__c,Backoffice_Code_NBFC__c from Account Where RecordTypeId =: familyRecordTypeId]);
            Map<Id,Account> mapClientRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, Parent.GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c,Is_Client_Family_Head__c,Backoffice_Code_NBFC__c from Account Where RecordTypeId =: clientRecordTypeId]);
            Map<Id,Client_Account__c> mapAccountRecord = new Map<Id, Client_Account__c>([Select id, Name,GWM_Client_Account_Id__c  from Client_Account__c]);
            
            //collect Map of Name, ID for all Family, Client and Account.
            mapFamilyAccNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapExistingCrmFamilyRecord,EdelweissConstants.OBJECT_ACCOUNT);        
            mapClientAccNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapClientRecord,EdelweissConstants.OBJECT_ACCOUNT);        
            mapAccountAccNameId = Edelweiss_Integration_Utility.collectMapForClientRelatedRecords(mapAccountRecord,EdelweissConstants.OBJECT_CLIENT_ACCOUNT);        
                                  
            system.debug('mapFamilyGWMIdandSFId >>>'+mapFamilyAccNameId);
            system.debug('mapClientGWMIdandSFId >>>'+mapClientAccNameId);
            system.debug('mapAccountGWMIdandSFId >>>'+mapAccountAccNameId);
            system.debug('mapProductScripId>>>'+mapProductScripId);
            system.debug('mapLeadPANId>>>'+mapLeadPANId);
            system.debug('mapLeadRecord  >>>'+mapLeadRecord);
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
            
            
            Map<String, Account> mapGWMIdFamliy = new Map<String, Account>();
            for(Account objFamily : mapExistingCrmFamilyRecord.values()){
                mapGWMIdFamliy.put(objFamily.GWM_Online_Id__c, objFamily);
            }
            
            //******************** Family Update Start *******************
            
            List<Account> listUpdatedFamily = Edelweiss_Integration_Utility.updateFamilyRecordsList(listBatchRecords, mapGWMIdFamliy);
            
            if(!listUpdatedFamily.isEmpty()){
                try{
                    Set<Account> setUniqueFamily = new Set<Account>();
                    setUniqueFamily.addAll(listUpdatedFamily);
                    List<Account> listUniqueFamily = new List<Account>();
                    listUniqueFamily.addAll(setUniqueFamily);
                    
                    Database.SaveResult [] dsFamilyRecords= database.update(listUniqueFamily, false);
                    for(Database.SaveResult sr : dsFamilyRecords) {
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Family Update Error : '+err.getMessage()); 
                            }
                        }
                    }
                } catch(Exception e) {
                    System.debug('Error : '+e);
                }
            }
            
            //******************** Family Update End *********************
            //********************* Start*********************************
            //-------------- Lead Conversion Process ---------------------            
            
            // collect what are the leads got converted.
            mapConvertedLead = Edelweiss_Integration_Utility.getConvertedLead(mapLeadPANId, listBatchRecords);
            System.debug('Converted Lead Map :mapConvertedLead ::'+mapConvertedLead);            
            
            // If converted Lead having value then execute Create Family/Client/ Account/ Contact and Convert Lead....
            if(mapConvertedLead.Values() != null && mapConvertedLead.size() >0)
            {
                //******************************* Generate Family List *****************************
                listOfConvertedFamily= Edelweiss_Integration_Utility.generateConvertedFamilyRecords(mapConvertedLead, mapLeadRecord, mapPanClientStagingRecord, mapFamilyAccNameId, mapClientAccNameId, EdelweissConstants.FAMILY_RECORD_TYPE, mapFaCxoUser, mapExistingCrmFamilyRecord);
                
                system.debug('listOfConvertedFamily >><>< '+listOfConvertedFamily);
                //Insert Family
                system.debug('My Log Start');
                Database.UpsertResult [] FamilyRes= database.upsert(listOfConvertedFamily,false);
                List<Account> newInsertedFamily = new List<Account>();
                system.debug('My Log'+FamilyRes);
                Integer FamilyInd = 0;
                for(Database.UpsertResult sr : FamilyRes)
                {
                    if(sr.isSuccess()){
                        newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                        if(mapGWMFamilyStaging.get(listOfConvertedFamily[FamilyInd].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMFamilyStaging.get(listOfConvertedFamily[FamilyInd].GWM_Online_Id__c);
                            //stage.Synch__c = true;
                            //stage.ErrorMessage__c = '';
                             errorStagingClients.add(stage);
                        }
                    }
                    else{
                        String errorMessage = '';
                        if(mapGWMFamilyStaging.get(listOfConvertedFamily[FamilyInd].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMFamilyStaging.get(listOfConvertedFamily[FamilyInd].GWM_Online_Id__c);
                          if(String.isEmpty(stage.ErrorMessage__c)){
                                stage.ErrorMessage__c = '';
                            }
                            errorMessage = stage.errorMessage__c;
                            for(Database.Error err : sr.getErrors()) {
                                //stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;
                            errorStagingClients.add(stage);
                        }
                        isError = true;
                            
                    }
                    FamilyInd++;            
              }
                // ************************ Create Converted Client ***********************
                //generate Map <Family GWM id/AccountNumber, Account> so Client parent can retrive from new Family
                system.debug('newInsertedFamily----------'+newInsertedFamily);
                mapFamilyGwmIdNewCreatedFamily =new Map<String, Account>();
                Map<id,Account> mapOfFamily = new Map<id,Account>();
            //  List<Account> newInsertedFamily = new List<Account>();
            //    newInsertedFamily = [Select id, Name, GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c from Account Where Id in: successfullyInserted];s
                for(Account objAcc : newInsertedFamily)
                {
                    mapFamilyGwmIdNewCreatedFamily.put(objAcc.GWM_Online_Id__c, objAcc);
                    mapOfFamily.put(objAcc.id, objAcc);
                }
                
                //create Family GWM id and List Account map for existing Client of SF CRM
                mapExistingClientOfCrm =new Map<String, List<Account>>();
                for(Account objExistingClient : mapClientRecord.values())
                {
                    //system.debug('objExistingClient.ParentId>>'+objExistingClient.ParentId);
                    //system.debug('mapExistingCrmFamilyRecord.ParentId>>'+mapExistingCrmFamilyRecord);
                    //system.debug('mapExistingCrmFamilyRecord.ParentId>>'+ mapExistingCrmFamilyRecord.get(objExistingClient.ParentId));
                    if(objExistingClient.ParentId !=null && mapExistingCrmFamilyRecord.get(objExistingClient.ParentId) != null && mapExistingClientOfCrm.containsKey(mapExistingCrmFamilyRecord.get(objExistingClient.ParentId).GWM_Online_Id__c))
                    {
                        List<Account> listExistingAcc = mapExistingClientOfCrm.get(mapExistingCrmFamilyRecord.get(objExistingClient.ParentId).GWM_Online_Id__c);
                        listExistingAcc.add(objExistingClient);
                        mapExistingClientOfCrm.put(mapExistingCrmFamilyRecord.get(objExistingClient.ParentId).GWM_Online_Id__c,listExistingAcc);
                    }
                    else if(objExistingClient.ParentId!=null && mapExistingCrmFamilyRecord.get(objExistingClient.ParentId) != null && !mapExistingClientOfCrm.containsKey(mapExistingCrmFamilyRecord.get(objExistingClient.ParentId).GWM_Online_Id__c))
                    {
                        List<Account> listExistingAcc = new List<Account>();
                        listExistingAcc.add(objExistingClient);
                        mapExistingClientOfCrm.put(mapExistingCrmFamilyRecord.get(objExistingClient.ParentId).GWM_Online_Id__c,listExistingAcc);
                    }
                
                }
                
                listOfConvertedClient = Edelweiss_Integration_Utility.generateConvertedClientRecords(mapConvertedLead, mapLeadRecord, mapPanClientStagingRecord, mapFamilyAccNameId, mapClientAccNameId, EdelweissConstants.CLIENT_RECORD_TYPE, mapFaCxoUser, mapFamilyGwmIdNewCreatedFamily ,mapExistingClientOfCrm ,mapClientRecord );
                
                Database.SaveResult [] ClientRes= database.update(listOfConvertedClient,false);
                List<Account> newInsertedClient = new List<Account>();
                List<Account> SiblingClientsToBeDeleted = new List<Account>();
                Set<Id> ParentsOfFailedClients = new Set<ID>();
                
                Map<Id,Edelweiss_Clients_Staging_Container__c> clientAndStagingMapContainer = new Map<Id,Edelweiss_Clients_Staging_Container__c>();
                Integer index = 0;
                
                for(Database.SaveResult sr : ClientRes)
                {
                    if(sr.isSuccess()){
                        
                        newInsertedClient.add(listOfConvertedClient[index]);
                        clientAndStagingMapContainer.put(sr.getId(),mapGWMClientStaging.get(listOfConvertedClient[index].GWM_Online_Id__c));
                        if(mapGWMClientStaging.get(listOfConvertedClient[index].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMClientStaging.get(listOfConvertedClient[index].GWM_Online_Id__c);
                            stage.synch__c = true;
                            stage.ErrorMessage__c = '';
                            errorStagingClients.add(stage);
                        }
                    }else{
                        String errorMessage = '';
                        if(mapGWMClientStaging.get(listOfConvertedClient[index].GWM_Online_Id__c) != null){
                            Edelweiss_Clients_Staging_Container__c stage = mapGWMClientStaging.get(listOfConvertedClient[index].GWM_Online_Id__c);
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
                          
                // ************************ Create Converted Client ***********************
                //generate Map <Family GWM id/AccountNumber, Account> so Client parent can retrive from new Family
                
                mapGwmIdNewCreatedClient= new Map<string, Account>();
                Map<Id, Id> mapClientIdFamilyId = new Map<Id, Id>();
                Map<id,Account> mapOfClient = new Map<id,Account>();
                //newInsertedClient = [Select id, Name, GWM_Online_Id__c, Parent.GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c,Is_Client_Family_Head__c from Account Where Id IN: successfullyInserted and ParentID NOT IN: ParentsOfFailedClients];
                for(Account objNewClient : newInsertedClient)
                {
                     mapGwmIdNewCreatedClient.put(objNewClient.GWM_Online_Id__c, objNewClient);
                     mapClientIdFamilyId.put(objNewClient.Id, objNewClient.ParentId);
                     mapOfClient.put(objNewClient.id , objNewClient);
                }
                
                // ***************** Create Client Account record *****************************
                listOfConvertedAccountOfClient =Edelweiss_Integration_Utility.generateConvertedClientAccountRecords(mapConvertedLead,mapLeadRecord,mapPanClientStagingRecord,mapAccountAccNameId,mapGwmIdNewCreatedClient);                
                System.debug('listOfConvertedAccountOfClient  >>>'+listOfConvertedAccountOfClient);
                
                Set<ID> FailedAccountsToBeDeleted = new Set<ID>();
                Database.SaveResult [] CLAccRes= database.insert(listOfConvertedAccountOfClient,false);
                system.debug('Client Account Created >>> '+ClientRes);
                index = 0;
                for(Database.SaveResult sr : CLAccRes)
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
         
                
                //**********************create contact for new Client********************                
                List<Contact> listConvertedClientContact = Edelweiss_Integration_Utility.generateConvertedClientContact(mapGwmIdNewCreatedClient, mapConvertedLead, mapLeadRecord, mapPanClientStagingRecord);
                system.debug('listConvertedClientContact>>'+listConvertedClientContact);
                index = 0;
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
                        if(mapGWMAccountStaging.get(listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c) != null){
                        	
                        	System.debug('Inside else >>> GWM Client Account Id >>> '+listOfConvertedAccountOfClient[index].GWM_Client_Account_Id__c);
                            Edelweiss_Clients_Staging_Container__c stage = clientAndStagingMapContainer.get(listConvertedClientContact[index].AccountId);
                            stage.Synch__c = true;
                            stage.ErrorMessage__c = '';
                            errorStagingClients.add(stage);
                        }
                    }
                    index++;
                }
                
                //****************** Move IPS Client to Family *******************

                List<Account> familyToBeUpdated = new List<Account>();
				Map<Id, Investment_Policy_Statement_IPS__c> mapIPS = new Map<Id, Investment_Policy_Statement_IPS__c>([
                	SELECT Id, Name, Client_Name__c FROM Investment_Policy_Statement_IPS__c
                	WHERE Client_Name__c IN : mapClientIdFamilyId.keySet()
                ]);
                
				If(!mapIPS.isEmpty()){
					List<Investment_Policy_Statement_IPS__c> lstUpdatedIPS = new List<Investment_Policy_Statement_IPS__c>();
					for(Investment_Policy_Statement_IPS__c objIPS : mapIPS.values()){
                        Account clientTypeAccount = mapOfClient.get(objIPS.Client_Name__c);
                        Account FamilyTypeAccount = mapOfFamily.get(mapClientIdFamilyId.get(objIPS.Client_Name__c));
						objIPS.Client_Name__c = mapClientIdFamilyId.get(objIPS.Client_Name__c);
                        FamilyTypeAccount.Lead_Category__c = clientTypeAccount.Lead_Category__c;
                        FamilyTypeAccount.AccountSource = clientTypeAccount.AccountSource;
                        familyToBeUpdated.add(FamilyTypeAccount);
						lstUpdatedIPS.add(objIPS);
					}
                
                	System.debug('IPS updted with family >>>'+lstUpdatedIPS);
	                update lstUpdatedIPS;
 database.update(familyToBeUpdated,false);
				}
                //****************** Move IPS Client to Family End ***************
                
                //****************** Move Events from Client to Family ***********
			 EventTriggerHandler.updateClientOnEventTrigger= true;
				Map<Id, Event> mapEvents = new Map<Id, Event>([
                	SELECT Id, WhatId FROM Event
                	WHERE WhatId IN : mapClientIdFamilyId.keySet()
                ]);
                
				If(!mapEvents.isEmpty()){
					List<Event> lstUpdatedEvents = new List<Event>();
					for(Event objEvent : mapEvents.values()){
						objEvent.WhatId = mapClientIdFamilyId.get(objEvent.WhatId);
						lstUpdatedEvents.add(objEvent);
					}
                
                	System.debug('Events updted with family >>>'+lstUpdatedEvents);
	                update lstUpdatedEvents;
				}
                //****************** Move Events from Client to Family End ***************
                 EventTriggerHandler.updateClientOnEventTrigger= false;
            }
            //********************* End *********************************
            
           
        }
        catch(exception ex)
        {
            system.debug('My LOg'+ex);
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_batchCreateClient; Function : execute()');
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
  
        Database.executeBatch(new Edelweiss_ProcessAdditionalLeads(isError),200);
    }
    
      // this method is used in the staging objects record deletion batches
    public  void sendNotificationToAdmin(String batchName){
        // collect users for profile.
         List<String> tos = new List<String>();
        Sys_Properties__c custSettingToEmailProfile = Sys_Properties__c.getValues('ProfileSendNotification MilesTicket');
        system.debug('Custom Setting To emils:.............'+custSettingToEmailProfile.Value__c);
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
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/> Batch <b>'+batchName+'</b> executed with errors.';
        List<Report> reports  = [select id from Report where DeveloperName = 'Client_Staging_Error_report'];
        string baseURL = '';
        if(reports.size() > 0){
            baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].id;
        }
        mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>'+batchName+'</b> batch. ' + '<br/><br/>To view failed records, go to <b> <a href="'+baseURL +'"> Client Data Error Report</a> </b>';
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        
        mail.HtmlBody= mailHtmlBody+ signature;
        
        System.debug('Complete Html Body >>>'+mailHtmlBody);
        
        //Commented for timebeing
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}