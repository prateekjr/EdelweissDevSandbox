global with sharing class Edelweiss_batchUpdateClientData implements Database.Batchable<sObject> , Database.Stateful{
    
    global String query;
    global Boolean isError;
    global User defaultUser;
    
    global Edelweiss_batchUpdateClientData(){
        query = 'SELECT Client_name__c,Remitter_Account_No__c,Anniversary_date__c,gender__c,sub_lob__c,Date_of_birth__c,Account_Type__c,Alternate_Number__c,GWM_Online_Client_Id__c, '+
                    'Client_Type__c,Contact_Email__c,Contact_Number__c,Is_Client_Family_Head__c,'+
                    'Family_Name__c,Focus_30_Client__c,GWM_Online_Family_Id__c,'+
                    'High_Priority_Client__c,Is_Converted_Lead__c,Mailing_Postal_Code__c,Mailing_Address__c,Mailing_City__c,Mailing_Country__c,Mailing_State__c,'+
                    'Mailing_Street__c,Mobile_No__c,Nationality__c,Office_Number__c,Official_Address__c,Official_City__c,Official_Country__c,Official_Email__c,'+
                    'Official_Pin__c,Official_State__c,PAN_Number__c,Primary_CXO_Employee_Id__c,Primary_CXO_Miles_Id__c,Primary_Email__c,'+
            		'Primary_FA_Employee_Id__c,Primary_FA_Miles_Id__c,Residential_Phone__c,Miles_Account_Status__c,Demat_Account_Number__c,Trading_Account_Number__c,DP_ID__c,Salutation__c,Last_Traded_Date__c,Secondary_Email__c,Synch__c ,ErrorMessage__c,Miles_Activation_Date__c,'+ 
            'Account_Name__c, GWM_Online_Account_Id__c, UCM_Code__c,Risk_Profile_Based_on_IPS__c ,Risk_Profile_Categories__c,Backoffice_Code_Equity__c,Backoffice_Code_NBFC__c,Mandate__c '+
            		'FROM Edelweiss_Clients_Staging_Container__c';
                    isError = false;
        
        defaultUser = [SELECT Id, Name, Edelweiss_Employee_Id__c, Miles_Id__c FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1];
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Clients_Staging_Container__c> listBatchRecords){
        Sys_Properties__c tradingFrequency = Sys_Properties__c.getValues('Trading Inactive Time');//Trading Inactive Time
        Integer tradingInactiveTime = Integer.valueOf(tradingFrequency.value__c);
        set<String> familyGWMIdSet = new set<String>();
        set<String> clientGWMIdSet = new set<String>();
        Set<Id> existingFamilyAndClientId = new Set<Id>();
        List<Client_Account__c> lstNewExtngAccount = new List<Client_Account__c>();
        Map<Id, Id> mapAccountIdOldFA = new Map<Id, Id>();
        Map<String,List<Edelweiss_Clients_Staging_Container__c>> familyGWMIdToStagingMap = new Map<String,List<Edelweiss_Clients_Staging_Container__c>>();
        
		Map<String,Edelweiss_Clients_Staging_Container__c> clientGWMIdToStagingMap = new Map<String,Edelweiss_Clients_Staging_Container__c>();
        List<Accountshare> ListAccountshare = new List<Accountshare>();
        if(listBatchRecords!=null && listBatchRecords.size()>0){
            for(Edelweiss_Clients_Staging_Container__c stagingObj : listBatchRecords){
                familyGWMIdSet.add(stagingObj.GWM_Online_Family_Id__c);
                clientGWMIdSet.add(stagingObj.GWM_Online_Client_Id__c);
                if(familyGWMIdToStagingMap.get(stagingObj.GWM_Online_Family_Id__c)==null){
                    familyGWMIdToStagingMap.put(stagingObj.GWM_Online_Family_Id__c , new List<Edelweiss_Clients_Staging_Container__c>());
                }
                familyGWMIdToStagingMap.get(stagingObj.GWM_Online_Family_Id__c).add(stagingObj);
                clientGWMIdToStagingMap.put(stagingObj.GWM_Online_Client_Id__c,stagingObj);
            }
            
            system.debug('****familyGWMIdSet'+familyGWMIdSet);
            system.debug('****clientGWMIdSet'+clientGWMIdSet);
            
            Map<Id,Account> mapExistingCrmFamilyRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, OwnerId, Focus_30__c,High_Priority__c, Primary_FA__c, Primary_CXO__c,Backoffice_Code_NBFC__c from Account Where RecordTypeId =: Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId() and GWM_Online_Id__c in :familyGWMIdSet]);
            Map<Id,Account> mapExistingClientRecord = new Map<Id, Account>([Select id, Name, GWM_Online_Id__c, Parent.GWM_Online_Id__c, OwnerId, Annual_Income__c, Asset_Classes_Client_is_Interested_in__c,  
                                                                            Focus_30__c,High_Priority__c,Is_Client_Family_Head__c, Type__c, Primary_FA__c, Primary_CXO__c , Parent.Name, Mobile_1__c, Mobile_2__c, Phone, Primary_Email__c, Secondary_Email__c, Current_Investment_Portfolio_formula__c,Backoffice_Code_NBFC__c    
                        from Account Where RecordTypeId =: Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId() and GWM_Online_Id__c in :clientGWMIdSet ]);
                                
            List<Client_Account__c> lstExistingClientAccountRecord = ([Select id, Remitter_Account_No__c ,  Name,GWM_Client_Account_Id__c, Account_Type__c,Client__c , Client_Type__c , Backoffice_Code_Equity__c,Miles_Account_Status__c from Client_Account__c where Client__c IN: mapExistingClientRecord.KeySet()]);
            System.debug('*****************List Of Exisiting client account'+lstExistingClientAccountRecord);
            List<Contact> mapExistingClientContact = ([Select id,Salutation,    OwnerId, Name, LastName, AccountId, Is_Primary_Contact__c,Office_Phone__c,Official_Email__c, Primary_Email__c,
                        Mobile_1__c, Mobile_2__c, Phone, Official_Address__c,Residential_Phone__c, Secondry_Email__c , Residence_Address__c , MobilePhone , Email from Contact Where Is_Primary_Contact__c = True and AccountId IN: mapExistingClientRecord.KeySet()]);
            
			existingFamilyAndClientId.addAll(mapExistingCrmFamilyRecord.keySet());
            existingFamilyAndClientId.addAll(mapExistingClientRecord.KeySet());
            
            List<Case> mapExistingClientCases =[
                SELECT OwnerId, Owner.ProfileId, AccountId, Id, Status 
                FROM Case WHERE AccountId in :existingFamilyAndClientId 
                //AND Status NOT IN (:EdelweissConstants.CASE_CLOSED_REJECTED_STATUS, :EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS)
            ];
            
            List<Opportunity> mapExistingClientOppo = [
                SELECT OwnerId, AccountId, Id 
                FROM Opportunity WHERE AccountId in :mapExistingClientRecord.KeySet()
            	AND StageName NOT IN (:EdelweissConstants.OPP_WON_STATUS, :EdelweissConstants.OPP_LOST_STATUS)
            ];
            
            Map<Id,Contact> existingContactToClientIdMap = new Map<Id,Contact>();
            Map<Id,List<Case>> existingCaseToClientIdMap = new Map<Id,List<Case>>();
            Map<Id,List<Opportunity>> existingOpportunityToClientIdMap = new Map<Id,List<Opportunity>>();
            if(mapExistingClientContact!=null && mapExistingClientContact.size()>0){
                for(Contact contact : mapExistingClientContact){
                    existingContactToClientIdMap.put(contact.AccountId , contact);
                }
            }
            
            
            Map<Id, Set<Client_Account__c>> existingAccountToClientIdMap = new Map<Id, Set<Client_Account__c>>();
			Map<String, Client_Account__c> mapGWMIdClientAccount = new Map<String, Client_Account__c>();
            
            if(lstExistingClientAccountRecord!=null && lstExistingClientAccountRecord.size()>0){
                for(Client_Account__c account : lstExistingClientAccountRecord){
					
					Set<Client_Account__c> setClientAccountForClient = new Set<Client_Account__c>();
					if(existingAccountToClientIdMap.containsKey(account.Client__c)){
						setClientAccountForClient.addAll(existingAccountToClientIdMap.get(account.Client__c));
					}
					setClientAccountForClient.add(account);					
                    existingAccountToClientIdMap.put(account.Client__c , setClientAccountForClient);
					
					mapGWMIdClientAccount.put(account.GWM_Client_Account_Id__c, account);
                }
            }
            
			
			
			
            //Map of Case and Client
            if(mapExistingClientCases != null && mapExistingClientCases.size() > 0){
                for(Case caseRec : mapExistingClientCases){
                    List<Case> casesrec = existingCaseToClientIdMap.get(caseRec.AccountId);
                    if(casesrec == null){
                        casesrec = new List<Case>();
                    }
                    casesrec.add(caseRec);
                    existingCaseToClientIdMap.put(caseRec.AccountId , casesrec);
                }
            }
            
            //Map of Opportunity and Client
            if(mapExistingClientOppo!=null && mapExistingClientOppo.size()>0){
                for(Opportunity oppo : mapExistingClientOppo){
                    List<Opportunity> oppRecs = existingOpportunityToClientIdMap.get(oppo.AccountId);
                    if(oppRecs == null){
                        oppRecs = new List<Opportunity>();
                    }
                    oppRecs.add(oppo);
                    existingOpportunityToClientIdMap.put(oppo.AccountId , oppRecs);
                }
            }
            
            
            // Collect existing, Fa & CXO from CRM.
            Map<String, User> mapFaCxoUser = new Map<String, User>();
            Sys_Properties__c custSettFaProfileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
			Sys_Properties__c custSettCxoProfileId = Sys_Properties__c.getValues('Profile Client Experience Office Id');
			Sys_Properties__c custSettCxoZonalHeadProfileId = Sys_Properties__c.getValues('Profile CXO Zonal Head Id');
			Sys_Properties__c custSettCxoNationalHeadProfileId = Sys_Properties__c.getValues('Profile CXO National Head Id');
			Sys_Properties__c custSettFaFOIGProfileId = Sys_Properties__c.getValues('Profile Financial Advisor FOIG Id');
            Sys_Properties__c custSettTLAdvoisoryProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory Id');
            Sys_Properties__c custSettTLAdvoisoryFOIGProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory FOIG Id');
			Sys_Properties__c custSettRegionalHeadProfileId = Sys_Properties__c.getValues('Profile Regional Head Id');
			
            Set<Id> CXOProfileIDSet = new Set<Id>();
            CXOProfileIDSet.add(custSettCxoProfileId.Value__c);
            CXOProfileIDSet.add(custSettCxoZonalHeadProfileId.Value__c);
            CXOProfileIDSet.add(custSettCxoNationalHeadProfileId.Value__c);
            
            //Only FA Considered in FAProfileIDSet and not Team Lead, Regional Head
            Set<Id> FAProfileIDSet = new Set<Id>();
            FAProfileIDSet.add(custSettFaProfileId.Value__c);
            FAProfileIDSet.add(custSettFaFOIGProfileId.Value__c);
            
			Set<Id> setFaCxoId = new Set<Id>();
			setFaCxoId.add(custSettFaProfileId.Value__c);
			setFaCxoId.add(custSettCxoProfileId.Value__c);
			setFaCxoId.add(custSettCxoZonalHeadProfileId.Value__c);
			setFaCxoId.add(custSettCxoNationalHeadProfileId.Value__c);
			setFaCxoId.add(custSettFaFOIGProfileId.Value__c);
            setFaCxoId.add(custSettTLAdvoisoryProfileId.Value__c);
            setFaCxoId.add(custSettTLAdvoisoryFOIGProfileId.Value__c);
            setFaCxoId.add(custSettRegionalHeadProfileId.Value__c);
            
            list<User> listFaCxoUsers= [Select Id, Name, Edelweiss_Employee_Id__c, Miles_Id__c From User where ProfileId =:setFaCxoId
                and IsActive = true];
            For(User objUserFa : listFaCxoUsers)
            {
                mapFaCxoUser.put(objUserFa.Edelweiss_Employee_Id__c+objUserFa.Miles_Id__c, objUserFa);
            }
        
            Map<String,Account> gwmIdToFamilyMap = new Map<String,Account>();
            for( Account familyAcc : mapExistingCrmFamilyRecord.values()){
                gwmIdToFamilyMap.put(familyAcc.GWM_Online_Id__c , familyAcc);
                mapAccountIdOldFA.put(familyAcc.Id, familyAcc.Primary_FA__c);
            }
            
            Map<String,Account> gwmIdToExistingClientToFamilyIdMap = new Map<String,Account>();
            for( Account client : mapExistingClientRecord.values()){
                gwmIdToExistingClientToFamilyIdMap.put(client.GWM_Online_Id__c , client);
                mapAccountIdOldFA.put(client.Id, client.Primary_FA__c);
            }
            
            Map<String,Account> newFamilyGwmIdToFamilyMap = new Map<String,Account>();
            Map<String,String> clientToNewFamilyMap = new Map<String,String>();
            
            Map<Id, Account> clientUpdateMap = new Map<Id,Account>();
            Set<ID> uniqueClientIdSet= new Set<Id>();
            MAP<id,Contact> MapcontactUpdateList = new MAP<id,Contact>();
            List<Case> caseUpdateList = new List<Case>();
            Map<Id, Case> caseUpdateMap = new Map<Id, Case>();
            Map<Id, Case> caseMapForRemoveSharing = new Map<Id, Case>();
            Map<id,Opportunity> MapOpportunityUpdateList = new Map<id,Opportunity>();
            
            Map<id,Client_Account__c> accountUpdateListMap = new Map<id,Client_Account__c>();
            Map<Id,Account> familyNameChangeMap = new Map<Id,Account>();
            Map<Id,Id> clientFAID = new Map<Id,Id>();
            Map<Id,Id> caseIdAndOldFAId = new Map<Id,Id>();
            Map<Id, Id> mapCaseFAManualSharing = new Map<Id, Id>();
            Boolean isRecordChanged = false;
            Boolean isFAChanged = false;
            Boolean isCXOChanged = false;
            
            for(Edelweiss_Clients_Staging_Container__c stagingObj : listBatchRecords){
                isRecordChanged = false;
                isFAChanged = false;
                isCXOChanged = false;
                User stagingFAUser = mapFaCxoUser.get(stagingObj.Primary_FA_Employee_Id__c + stagingObj.Primary_FA_Miles_Id__c);
                User stagingCXOUser = mapFaCxoUser.get(stagingObj.Primary_CXO_Employee_Id__c + stagingObj.Primary_CXO_Miles_Id__c);
                
                if(stagingFAUser == null){
                    stagingFAUser = defaultUser;
                }
                if(stagingCXOUser == null){
                    stagingCXOUser = defaultUser;
                }
                
                if(gwmIdToExistingClientToFamilyIdMap!=null && gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c)!=null){
                     Account client = gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c);
                    if(gwmIdToFamilyMap.containsKey(stagingObj.GWM_Online_Family_Id__c) && gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c)!=null && gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).Parent.GWM_Online_Id__c != stagingObj.GWM_Online_Family_Id__c){
                            
                            client.ParentId = gwmIdToFamilyMap.get(stagingObj.GWM_Online_Family_Id__c).Id;
                            isRecordChanged = true; 
                    }else if(!gwmIdToFamilyMap.containsKey(stagingObj.GWM_Online_Family_Id__c) && !newFamilyGwmIdToFamilyMap.containsKey(stagingObj.GWM_Online_Family_Id__c)){
                            // Create new Family 
                            Account newFamily = Edelweiss_Integration_Utility.generateNewFamilyOnFamilyChange(stagingObj , mapFaCxoUser);
					newFamily.OwnerId=stagingFAUser.Id;
                            newFamily.Primary_FA__c = stagingFAUser.Id;
                            newFamily.Primary_CXO__c = stagingCXOUser.Id;
                            newFamilyGwmIdToFamilyMap.put(stagingObj.GWM_Online_Family_Id__c,newFamily);
                            client.ParentId = newFamily.Id;
                            clientToNewFamilyMap.put(stagingObj.GWM_Online_Client_Id__c ,stagingObj.GWM_Online_Family_Id__c );
                            isRecordChanged = true;
                    }else if(!gwmIdToFamilyMap.containsKey(stagingObj.GWM_Online_Family_Id__c) && newFamilyGwmIdToFamilyMap.containsKey(stagingObj.GWM_Online_Family_Id__c)){
                        
                        client.ParentId = newFamilyGwmIdToFamilyMap.get(stagingObj.GWM_Online_Family_Id__c).Id;
                        clientToNewFamilyMap.put(stagingObj.GWM_Online_Client_Id__c ,stagingObj.GWM_Online_Family_Id__c );
                        isRecordChanged = true;
                    }else if(gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).Parent.GWM_Online_Id__c == stagingObj.GWM_Online_Family_Id__c && gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).Parent.Name != stagingObj.Family_Name__c ){
                            Account family = gwmIdToFamilyMap.get(stagingObj.GWM_Online_Family_Id__c);
                            family.Name  = stagingObj.Family_Name__c;
                            family.High_priority__c = (stagingObj.High_Priority_Client__c == '1' ? true : false );
                            family.Focus_30__c=  (stagingObj.Focus_30_Client__c == '1' ? true : false ); 
                        family.Backoffice_Code_NBFC__c =stagingObj.Backoffice_Code_NBFC__c;
                            familyNameChangeMap.put(family.Id,family);
                    }
                    else if(gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).Parent.GWM_Online_Id__c == stagingObj.GWM_Online_Family_Id__c ){
                            Account family = gwmIdToFamilyMap.get(stagingObj.GWM_Online_Family_Id__c);
                            
                            family.High_priority__c = (stagingObj.High_Priority_Client__c == '1' ? true : false );
                            family.Focus_30__c=  (stagingObj.Focus_30_Client__c == '1' ? true : false ); 
                        family.Backoffice_Code_NBFC__c =stagingObj.Backoffice_Code_NBFC__c;
                            familyNameChangeMap.put(family.Id,family);
                    }
                    
               
                    Boolean highPriority = (stagingObj.High_Priority_Client__c == '1' ? true : false );
                    Boolean focus30Client = (stagingObj.Focus_30_Client__c == '1' ? true : false ); 
                    if(gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).High_Priority__c != highPriority){
                        client.High_Priority__c = highPriority;
                        isRecordChanged = true;
                    }
                    
                    if(gwmIdToExistingClientToFamilyIdMap.get(stagingObj.GWM_Online_Client_Id__c).Focus_30__c != focus30Client){
                        client.Focus_30__c = focus30Client;
                        isRecordChanged = true;
                    }
                    
					if(stagingFAUser.Id != client.Primary_FA__c){
                        client.Primary_FA__c = stagingFAUser.Id;
                        client.OwnerId = client.Primary_FA__c;
                        clientFAID.put(client.id, client.Primary_FA__c);
                        isRecordChanged = true;
                        isFAChanged = true;
                    }
					
					if(stagingCXOUser.Id != client.Primary_CXO__c){
                        client.Primary_CXO__c = stagingCXOUser.Id;
                        AccountShare accountShareObjClient = new AccountShare(AccountId = client.id, UserOrGroupId = client.Primary_CXO__c, AccountAccessLevel='Read',OpportunityAccessLevel = 'Read');
                        ListAccountshare.add(accountShareObjClient);
                        isRecordChanged = true;
                        isCXOChanged = true;
                    }
                    
                    Account familyRecord = gwmIdToFamilyMap.get(stagingObj.GWM_Online_Family_Id__c);
               
                    
                    if(familyRecord != null && ((familyRecord.Primary_CXO__c != stagingCXOUser.Id) || (familyRecord.Primary_FA__C != stagingFAUser.Id) || (familyRecord.OwnerId != stagingFAUser.Id) )){
                        familyRecord.OwnerId = client.Primary_FA__c;
                        familyRecord.Primary_FA__C = client.Primary_FA__c;
                        familyRecord.Primary_CXO__c = client.Primary_CXO__c;
                        clientFAID.put(familyRecord.id, familyRecord.Primary_FA__c);
                        AccountShare accountShareObjFamily = new AccountShare(AccountId = familyRecord.id, UserOrGroupId = familyRecord.Primary_CXO__c, AccountAccessLevel='Read', OpportunityAccessLevel = 'Read');
                        ListAccountshare.add(accountShareObjFamily);
                        familyNameChangeMap.put(familyRecord.Id,familyRecord);
                        isRecordChanged = true;
                    }
                    
                    
                    //Mapping added by sayali
                    client.name = stagingObj.client_name__c;
                    client.sub_lob__c = stagingObj.sub_lob__c;
                    client.gender__c = stagingObj.gender__c;
                    client.Date_of_birth__c = stagingObj.Date_of_birth__c;
                    client.Is_Client_Family_Head__c = stagingObj.Is_Client_Family_Head__c;
                    client.Anniversary_date__c= stagingObj.Anniversary_date__c;
                    client.UCM_Code__c = stagingObj.UCM_Code__c;
                    client.Mandate__c=stagingObj.Mandate__c== '1' ? true : false;
                    if(stagingObj.Risk_Profile_Based_on_IPS__c != null){
                       client.Risk_Profile_Based_on_IPS__c = stagingObj.Risk_Profile_Based_on_IPS__c; 
                    }else{
                         client.Risk_Profile_Based_on_IPS__c = '';
                    }
                    if(stagingObj.Risk_Profile_Categories__c != null){
                        String categoryUpper = (stagingObj.Risk_Profile_Categories__c).toUppercase();
                        if(categoryUpper == 'A'){
                            if(EdelweissConstants.CATEGORY_A != null){
                            client.Risk_Profile_Categories__c = EdelweissConstants.CATEGORY_A;
                            }
                        }else if(categoryUpper == 'B'){
                             if(EdelweissConstants.CATEGORY_B != null){
                            client.Risk_Profile_Categories__c = EdelweissConstants.CATEGORY_B;
                           }
                        }else {
                            client.Risk_Profile_Categories__c = '';
                        }
                    }else {
                         client.Risk_Profile_Categories__c = '';
                    }
                    
					//Trading Last 180 days
                    if(stagingObj.Last_Traded_Date__c == null){
                        client.Trading_Status__c = 'Inactive';
                    }else{
                        client.Last_Traded_Date__c = stagingObj.Last_Traded_Date__c;
                        Integer DateDiffernce = client.Last_Traded_Date__c.daysBetween(System.today());
                    
                        if(DateDiffernce > tradingInactiveTime){
                            client.Trading_Status__c = 'Inactive';
                        }else{
                            client.Trading_Status__c = 'Active';
                        }
                    }
					if(stagingObj.Salutation__c != null){
                        client.Salutation__c = stagingObj.Salutation__c; 
                    }
                    if(stagingObj.Trading_Account_Number__c != null){
                        client.Trading_Account_Number__c = stagingObj.Trading_Account_Number__c;
                    }
                    if(stagingObj.DP_ID__c != null){
                        client.DP_ID__c = stagingObj.DP_ID__c;
                    }
                    if(stagingObj.Account_Type__c != null){
                        client.Account_Type__c = stagingObj.Account_Type__c;
                    }
                    if(stagingObj.Demat_Account_Number__c != null){
                        client.Demat_Account_Number__c = stagingObj.Demat_Account_Number__c;
                    }
                   /* Client Status to be populated by batch and not from Staging
                    * if(stagingObj.Miles_Account_Status__c != null){
                        client.Miles_Account_Status__c = stagingObj.Miles_Account_Status__c;
                    }*/
                    if(stagingObj.Mobile_No__c != null && (client.Mobile_1__c != stagingObj.Mobile_No__c)){
						client.Mobile_2__c = client.Mobile_1__c;  
						client.Phone = stagingObj.Mobile_No__c;
						client.Mobile_1__c = stagingObj.Mobile_No__c;
					}
					else if(stagingObj.Alternate_Number__c != null){
						client.Mobile_2__c = stagingObj.Alternate_Number__c;
					}
					
					if(stagingObj.Primary_Email__c != null && (client.Primary_Email__c != stagingObj.Primary_Email__c)){
						client.Secondary_Email__c = client.Primary_Email__c;
						client.Primary_Email__c = stagingObj.Primary_Email__c;
					}
					else if(stagingObj.Secondary_Email__c != null){
						client.Secondary_Email__c = stagingObj.Secondary_Email__c;
					}
					
					String officeAddress = ''; 
					String ResidentialAddr = '';
					
					if(!String.isBlank(stagingObj.Official_Address__c)){
						officeAddress += stagingObj.Official_Address__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Official_City__c)){
						officeAddress += stagingObj.Official_City__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Official_State__c)){
						officeAddress += stagingObj.Official_State__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Official_Country__c)){
						officeAddress += stagingObj.Official_Country__c+ ' '; 
					}
					if(!String.isBlank(stagingObj.Official_Pin__c)){
						officeAddress += stagingObj.Official_Pin__c; 
					}
					if(!String.isBlank(officeAddress)){
						client.Official_Address__c=officeAddress ;
					}
					
					

					if(!String.isBlank(stagingObj.Mailing_Address__c)){
						ResidentialAddr += stagingObj.Mailing_Address__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Mailing_Street__c)){
						ResidentialAddr += stagingObj.Mailing_Street__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Mailing_City__c)){
						ResidentialAddr += stagingObj.Mailing_City__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Mailing_State__c)){
						ResidentialAddr += stagingObj.Mailing_State__c+ ', '; 
					}
					if(!String.isBlank(stagingObj.Mailing_Country__c)){
						ResidentialAddr += stagingObj.Mailing_Country__c+ ' '; 
					}
					if(!String.isBlank(stagingObj.Mailing_Postal_Code__c)){
						ResidentialAddr += stagingObj.Mailing_Postal_Code__c; 
					}
					if(!String.isBlank(ResidentialAddr)){
						client.Residence_Address__c=ResidentialAddr ;
					}
					
					if(stagingObj.Office_Number__c != null){
						client.Office_Phone_Number__c = stagingObj.Office_Number__c;
					}
					
					
                    if(existingContactToClientIdMap!=null){
                        Contact extngConact = existingContactToClientIdMap.get(client.Id);
                        if(extngConact!=null){
                            							
							extngConact.Phone = client.Phone;
							extngConact.Mobile_1__c = client.Mobile_1__c;
							extngConact.Mobile_2__c = client.Mobile_2__c;
							extngConact.Mobile_3__c = client.Mobile_3__c;
							extngConact.Official_Address__c=client.Official_Address__c;
							extngConact.Residence_Address__c=client.Residence_Address__c;
							extngConact.Primary_Email__c = client.Primary_Email__c;
                            extngConact.Email = client.Primary_Email__c;    
							extngConact.Secondry_Email__c = client.Secondary_Email__c;                    							
							extngConact.Office_Phone__c = client.Office_Phone_Number__c;
                            
                            if(stagingObj.Office_Number__c != null)
                                extngConact.Office_Phone__c = stagingObj.Office_Number__c;
                            
                            if(stagingObj.Residential_Phone__c != null)
                                extngConact.Residential_Phone__c = stagingObj.Residential_Phone__c; 
                            
                            if(stagingObj.Contact_Number__c != extngConact.MobilePhone)
                                extngConact.MobilePhone = stagingObj.Contact_Number__c;
                                 
                            if(stagingObj.Official_Email__c != null)
                                 extngConact.Official_Email__c = stagingObj.Official_Email__c;   
 
                            if(stagingObj.Contact_Email__c != extngConact.Email)
                                 extngConact.Email = stagingObj.Contact_Email__c;        

                            if(stagingObj.Salutation__c != null)
                                 extngConact.Salutation = stagingObj.Salutation__c;
                                                           
                            Id faID = clientFAID.get(client.Id);
                            if(faID != null){
                                extngConact.OwnerId = faId;
                            }                           
                            MapcontactUpdateList.put(extngConact.id,extngConact);
                        }
                    }
                    
                    if(existingCaseToClientIdMap.get(client.Id) != null && (isFAChanged || isCXOChanged)){
                        for(Case c :existingCaseToClientIdMap.get(client.id) ){
                            Boolean isClosed = (c.Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS || 
                                c.Status == EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS) ? true : false;

                            Id ownerID = client.Primary_CXO__c;
                            mapCaseFAManualSharing.put(c.Id, clientFAID.get(client.Id));
                            
                            if(isFAChanged){
                            	caseMapForRemoveSharing.put(c.Id, c);
                            }
                            
                            if(isClosed){
                                if(FAProfileIDSet.contains(c.Owner.ProfileId)){
                                	ownerID = defaultUser.Id;
                                }else{
                                    continue;
                                }
                            }
                            
                            if(ownerID != null && ownerID != c.OwnerId){
                                caseIdAndOldFAId.put(c.Id, ownerID);
                                c.OwnerId = ownerID;
                                c.Owner_Change_Reason__c  = 'Client FA Change';
                                caseUpdateMap.put(c.id, c);
                            }   
                        }
                    }
                    if(familyRecord != null && existingCaseToClientIdMap.get(familyRecord.Id) != null && (isFAChanged || isCXOChanged)){
                        for(Case c :existingCaseToClientIdMap.get(familyRecord.Id)){
                            Boolean isClosed = (c.Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS || 
                                c.Status == EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS) ? true : false;
                            
                            Id ownerID = familyRecord.Primary_CXO__c;
                            mapCaseFAManualSharing.put(c.Id, clientFAID.get(familyRecord.Id));
                            
                            if(isFAChanged){
                            	caseMapForRemoveSharing.put(c.Id, c);
                            }
                            
                            if(isClosed){
                                if(FAProfileIDSet.contains(c.Owner.ProfileId)){
                                	ownerID = defaultUser.Id;
                                }else{
                                    continue;
                                }
                            }
                            
                            if(ownerID != null && ownerID != c.OwnerId){
                                c.OwnerId = ownerID;
                                c.Owner_Change_Reason__c  = 'Client FA Change';
                                caseUpdateMap.put(c.id, c);
                            }   
                        }
                    }
                    
                    if(existingOpportunityToClientIdMap.get(client.id) != null && (isFAChanged || isCXOChanged)){
                        for(Opportunity  oppo : existingOpportunityToClientIdMap.get(client.id)){
                            Id faID = clientFAID.get(client.Id);
                            if(faID != null){
                                oppo.OwnerId = faId;
                                MapOpportunityUpdateList.put(oppo.id,oppo);
                            }   
                        }
                    }
                    
                    
                    if(existingAccountToClientIdMap!=null){
                        Set<Client_Account__c> setExtngAccount = existingAccountToClientIdMap.get(client.Id);
						
						if(setExtngAccount!=null){
							for(Client_Account__c extngAccount : setExtngAccount){
                                
                                if(extngAccount.GWM_Client_Account_Id__c == stagingObj.GWM_Online_Account_Id__c){
                                
                                    if(extngAccount.Name != stagingObj.Account_Name__c){
                                        extngAccount.Name = stagingObj.Account_Name__c;
                                    }
                                    if(extngAccount.Account_Type__c != stagingObj.Account_Type__c){
                                        extngAccount.Account_Type__c = stagingObj.Account_Type__c;
                                    }
                                    if(extngAccount.Client_Type__c != stagingObj.Client_Type__c){
                                        extngAccount.Client_Type__c = stagingObj.Client_Type__c;
                                    } 
                                        if(extngAccount.Remitter_Account_No__c != stagingObj.Remitter_Account_No__c){
                                            extngAccount.Remitter_Account_No__c = stagingObj.Remitter_Account_No__c;
                                    }
                                    if(stagingObj.Backoffice_Code_Equity__c != null){
                                        if(extngAccount.Backoffice_Code_Equity__c != stagingObj.Backoffice_Code_Equity__c){
                                            extngAccount.Backoffice_Code_Equity__c = stagingObj.Backoffice_Code_Equity__c;
                                        }
                                    }
                                    
                                    // Added Mapping for Miles Status
                                        if(extngAccount.Miles_Account_Status__c != stagingObj.Miles_Account_Status__c){
                                            extngAccount.Miles_Account_Status__c = stagingObj.Miles_Account_Status__c;
                                        }
                                    
                                    accountUpdateListMap.put(extngAccount.id, extngAccount);
                                }
							}
                        }
                    }
                    clientUpdateMap.put(client.Id , client); 
					
					if(!mapGWMIdClientAccount.containsKey(stagingObj.GWM_Online_Account_Id__c)){
						Client_Account__c objClientAccount = new Client_Account__c();
						objClientAccount.GWM_Client_Account_Id__c=stagingObj.GWM_Online_Account_Id__c;
                        objClientAccount.Name =stagingObj.Account_Name__c;
						objClientAccount.Gender__c=stagingObj.Gender__c;
						objClientAccount.PAN_Number__c=stagingObj.PAN_Number__c;
						objClientAccount.Account_type__c=stagingObj.Account_type__c;
                        objClientAccount.Client_Type__c= stagingObj.Client_Type__c;
						objClientAccount.Annual_Income__c= client.Annual_Income__c;                    
						objClientAccount.Client__c=client.Id;
						objClientAccount.Asset_Classes_Client_is_Interested_in__c=client.Asset_Classes_Client_is_Interested_in__c;
                        objClientAccount.Current_Investment_Portfolio__c=Integer.valueOf(client.Current_Investment_Portfolio_formula__c);
                        objClientAccount.Remitter_Account_No__c = stagingObj.Remitter_Account_No__c;
                        objClientAccount.Backoffice_Code_Equity__c = stagingObj.Backoffice_Code_Equity__c;
                        //Status from staging onto client Account and not on Client
                        objClientAccount.Miles_Account_Status__c=stagingObj.Miles_Account_Status__c;
						lstNewExtngAccount.add(objClientAccount);
					}
                }
                
                
            }
            
            
            List<Account> newFamilyInsertList = newFamilyGwmIdToFamilyMap.values();
            Map<Id,Edelweiss_Clients_Staging_Container__c > stagingRecUpdateMap = new Map<Id,Edelweiss_Clients_Staging_Container__c>();
            String errorMessage='';
            
            Database.Saveresult [] FamilyRes = database.insert(newFamilyGwmIdToFamilyMap.values() , false);
             Integer recIndx = 0;
             
            for(Database.Saveresult sr : FamilyRes)
                {
                    if(sr.isSuccess()){
                       // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                    }else{
                        isError = true;
                        List<Edelweiss_Clients_Staging_Container__c> stageLst = familyGWMIdToStagingMap.get(newFamilyInsertList[recIndx].GWM_Online_Id__c);
                        for(Edelweiss_Clients_Staging_Container__c stage : stageLst){
                            errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;
                             for(Database.Error err : sr.getErrors()) {
                                stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;        
                            stagingRecUpdateMap.put(stage.Id, stage);           
                        }
                    }
                     
                    recIndx++;
              }
              
             recIndx = 0;
             Database.Saveresult [] familyNameChangeRes = database.update(familyNameChangeMap.values(),false);
             for(Database.Saveresult sr : familyNameChangeRes){
                    if(sr.isSuccess()){
                       // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                    }else{
                        isError = true;    
                         List<Edelweiss_Clients_Staging_Container__c> stageLst = familyGWMIdToStagingMap.get(familyNameChangeMap.values()[recIndx].GWM_Online_Id__c);
                         for(Edelweiss_Clients_Staging_Container__c stage : stageLst){
                                 if(stagingRecUpdateMap.get(stage.Id)!=null)
                                    stage = stagingRecUpdateMap.get(stage.Id);
                                 errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                                 for(Database.Error err : sr.getErrors()) {
                                    stage.Synch__c = false;
                                    errorMessage+= err.getMessage() + '\n'; 
                                }
                                stage.ErrorMessage__c = errorMessage;        
                                stagingRecUpdateMap.put(stage.Id, stage);   
                         }                    
                    }
                    recIndx++;  
              }
              
            //insert newFamilyGwmIdToFamilyMap.values();
             recIndx = 0;
            for(String clientId : clientToNewFamilyMap.keySet()){
                
                 Account client = gwmIdToExistingClientToFamilyIdMap.get(clientId);  
                 
                 if(clientUpdateMap.containsKey(client.id))
                     client = clientUpdateMap.get(client.Id);
                 
                 client.ParentId = newFamilyGwmIdToFamilyMap.get(clientToNewFamilyMap.get(clientId)).Id;
                 clientUpdateMap.put(client.Id , client);
            }
            
           
            Database.Saveresult [] clientUpdateRes = database.update(clientUpdateMap.values(), false);
            recIndx =0;
            for(Database.Saveresult sr : clientUpdateRes)
            {
                if(sr.isSuccess()){
                    // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                }else{
                    isError = true;
                    Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.values()[recIndx].GWM_Online_Id__c);
                    if(stagingRecUpdateMap.get(stage.Id)!=null)
                        stage = stagingRecUpdateMap.get(stage.Id);    
                    errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                    for(Database.Error err : sr.getErrors()) {
                        stage.Synch__c = false;
                        if(errorMessage.contains(err.getMessage())){
                        }else{
                        errorMessage+= err.getMessage() + '\n'; 
                    }
                    }
                    stage.ErrorMessage__c = errorMessage;        
                    stagingRecUpdateMap.put(stage.Id, stage);                               
                }
                recIndx++;
            }
            Database.Saveresult [] AccountShare = database.insert(ListAccountShare, false);
            recIndx =0;
            for(Database.Saveresult sr : AccountShare)
            {
                if(!sr.isSuccess()){
                    isError = true;
                }
                recIndx++;
            }
            Database.Saveresult [] contactUpdateRes = database.update(MapcontactUpdateList.values(), false);
            recIndx = 0;
            for(Database.Saveresult sr : contactUpdateRes)
                {
                    if(sr.isSuccess()){
                       // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                    }else{
                        isError = true;
                        Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.get(MapcontactUpdateList.values()[recIndx].AccountId).GWM_Online_Id__c);
                         if(stagingRecUpdateMap.get(stage.Id)!=null)
                            stage = stagingRecUpdateMap.get(stage.Id);    
                         errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                         for(Database.Error err : sr.getErrors()) {
                            stage.Synch__c = false;
                        if(errorMessage.contains(err.getMessage())){
                        }else{
                            errorMessage+= err.getMessage() + '\n'; 
                        }
                    }
                        stage.ErrorMessage__c = errorMessage;        
                        stagingRecUpdateMap.put(stage.Id, stage);                            
                    }
                    recIndx++;
                     
              }
            
            
            recIndx = 0;
            Database.Saveresult [] accountUpdateRes = database.update(accountUpdateListMap.values(), false);
            for(Database.Saveresult sr : accountUpdateRes) {
                if(!sr.isSuccess()){
                    isError = true;          
                    Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.get(accountUpdateListMap.values()[recIndx].Client__c).GWM_Online_Id__c);
                    if(stagingRecUpdateMap.get(stage.Id)!=null)
                        stage = stagingRecUpdateMap.get(stage.Id);    
                    errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                    for(Database.Error err : sr.getErrors()) {
                        stage.Synch__c = false;
                        errorMessage+= err.getMessage() + '\n'; 
                    }
                    stage.ErrorMessage__c = errorMessage;        
                    stagingRecUpdateMap.put(stage.Id, stage);                            
                }
                recIndx++;              
            }
            
            recIndx = 0;
            Database.Saveresult [] accountInsertedRes = database.insert(lstNewExtngAccount, false);
            for(Database.Saveresult sr : accountInsertedRes) {
                if(!sr.isSuccess()){
                    isError = true;          
                    Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.get(lstNewExtngAccount[recIndx].Client__c).GWM_Online_Id__c);
                    if(stagingRecUpdateMap.get(stage.Id)!=null)
                        stage = stagingRecUpdateMap.get(stage.Id);    
                    errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                    for(Database.Error err : sr.getErrors()) {
                        stage.Synch__c = false;
                        errorMessage+= err.getMessage() + '\n'; 
                    }
                    stage.ErrorMessage__c = errorMessage;        
                    stagingRecUpdateMap.put(stage.Id, stage);                            
                }
                recIndx++;              
            }
            
                 recIndx = 0;
                Database.Saveresult [] caseUpdateRes = database.update(caseUpdateMap.values() , false);
                for(Database.Saveresult sr : caseUpdateRes) {
                        if(sr.isSuccess()){
                           // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                        }else{
                            isError = true;          
                    if(clientUpdateMap.get(caseUpdateMap.values()[recIndx].AccountId) != null){
                             Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.get(caseUpdateMap.values()[recIndx].AccountId).GWM_Online_Id__c);
                             if(stagingRecUpdateMap.get(stage.Id)!=null)
                                    stage = stagingRecUpdateMap.get(stage.Id);    
                                 errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                                 for(Database.Error err : sr.getErrors()) {
                                    stage.Synch__c = false;
                                    errorMessage+= err.getMessage() + '\n'; 
                                }
                                stage.ErrorMessage__c = errorMessage;        
                                stagingRecUpdateMap.put(stage.Id, stage);                            
                        }
                    else if(familyNameChangeMap.get(caseUpdateMap.values()[recIndx].AccountId) != null){
                        List<Edelweiss_Clients_Staging_Container__c> stageLst = familyGWMIdToStagingMap.get(familyNameChangeMap.get(caseUpdateMap.values()[recIndx].AccountId).GWM_Online_Id__c);
                        for(Edelweiss_Clients_Staging_Container__c stage : stageLst){
                            if(stagingRecUpdateMap.get(stage.Id)!=null)
                                stage = stagingRecUpdateMap.get(stage.Id);
                            errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                            for(Database.Error err : sr.getErrors()) {
                                stage.Synch__c = false;
                                errorMessage+= err.getMessage() + '\n'; 
                            }
                            stage.ErrorMessage__c = errorMessage;        
                            stagingRecUpdateMap.put(stage.Id, stage);   
                        } 
                    }
                }
                        recIndx++;              
                     }
                       
                       recIndx = 0;  
                Database.Saveresult [] oppUpdateRes = database.update(MapOpportunityUpdateList.values(), false);
                for(Database.Saveresult sr : oppUpdateRes) {
                        if(sr.isSuccess()){
                           // newInsertedFamily.add(listOfConvertedFamily[FamilyInd]);
                        }else{
                            isError = true;          
                             Edelweiss_Clients_Staging_Container__c stage = clientGWMIdToStagingMap.get(clientUpdateMap.get(MapOpportunityUpdateList.values()[recIndx].AccountId).GWM_Online_Id__c);
                             if(stagingRecUpdateMap.get(stage.Id)!=null)
                                    stage = stagingRecUpdateMap.get(stage.Id);    
                                 errorMessage = stage.ErrorMessage__c ==null ? '' : stage.ErrorMessage__c;  
                                 for(Database.Error err : sr.getErrors()) {
                                    stage.Synch__c = false;
                                    errorMessage+= err.getMessage() + '\n'; 
                                }
                                stage.ErrorMessage__c = errorMessage;        
                                stagingRecUpdateMap.put(stage.Id, stage);                            
                        }
                        recIndx++;              
                     }
                 database.update(stagingRecUpdateMap.values() , false);
                 
            //Delete access of old FA
            if(!caseMapForRemoveSharing.isEmpty()){
                List<CaseShare> lstCaseShare = [
                    SELECT Id, CaseId, Case.AccountId, UserOrGroupId, RowCause 
                    FROM CaseShare WHERE CaseId = :caseMapForRemoveSharing.keySet()
                    AND RowCause = 'Manual'
                ];
                     
                List<CaseShare> lstCaseShareToDelete = new List<CaseShare>();
                for(CaseShare share : lstCaseShare){
                    if(mapAccountIdOldFA.get(share.Case.AccountId) != Null && 
                       mapAccountIdOldFA.get(share.Case.AccountId) == share.UserOrGroupId){
                           lstCaseShareToDelete.add(share);
                       }
                }
                System.debug('lstCaseShareToDelete >>>> '+lstCaseShareToDelete);
                if(!lstCaseShareToDelete.isEmpty()){
                    Database.delete(lstCaseShareToDelete, false);
                }
            }    
            
            //Grant access to new FA
            if(!mapCaseFAManualSharing.isEmpty()){
                List<CaseShare> lstCaseShare = new List<CaseShare>();
                for(Id caseId : mapCaseFAManualSharing.keySet()){
                    if(caseId != null && mapCaseFAManualSharing.get(caseId) != null){
                        lstCaseShare.add(new CaseShare(CaseId=caseId, UserOrGroupId=mapCaseFAManualSharing.get(caseId), CaseAccessLevel='Edit'));
                    }
                }
                if(!lstCaseShare.isEmpty()){
                    Database.insert(lstCaseShare, false);
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bcMain) 
    {
        sendNotificationToAdmin('Client Data Update' , isError);
        //if(!isError){
            Database.executeBatch(new BatchForFamilyWithoutClient(), 1000);
        //}
    }

    // this method is used in the staging objects record deletion batches
    public  void sendNotificationToAdmin(String batchName, Boolean isError){

        List<String> tos = new List<String>();
        Sys_Properties__c custSettingEmailRecipient = Sys_Properties__c.getValues('Integration Email Recipient User');
        String strUserName = String.isEmpty(custSettingEmailRecipient.Value__c) ? 'PWM SalesforceUpdate' : custSettingEmailRecipient.Value__c ;
        
        List<User> listUsers = [
          SELECT Id, Email FROM User WHERE Name =: strUserName   
        ];
        for(User objUser: listUsers){
           tos.add(objUser.Email); 
        }
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(tos); 
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Client Data Update Report');
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/> Batch <b>'+batchName+'</b> executed successfully.';
        List<Report> reports  = [select id from Report where DeveloperName = 'Client_Staging_Error_report'];
        string baseURL = '';
        if(reports.size() > 0){
            baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].id;
        }
        if(isError)
            mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>'+batchName+'</b> batch. ' + '<br/><br/>To view failed records, go to <b> <a href="'+baseURL +'"> Client Data Error Report</a> </b>';
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        
        mail.HtmlBody= mailHtmlBody+ signature;
		if(!Test.isRunningTest())
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}