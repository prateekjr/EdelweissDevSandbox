public class Edelweiss_Integration_Utility
{
    
    public static Map<String, ID> collectMapForClientRelatedRecordsNew(Map<Id, Account> accountRecordMap, String sObjectName)
    {
        Map<String, ID> mapsObjectNameID = new Map<String, ID>();
        try
        {  
                for(Account accObject : accountRecordMap.values())
                {
                    if(accObject.RecordType.Name == EdelweissConstants.CLIENT_RECORD_TYPE){
                      mapsObjectNameID.put(EdelweissConstants.CLIENT_RECORD_TYPE+(string.ValueOf(accObject.get('GWM_Online_Id__c'))), accObject.ID);

                    }else if(accObject.RecordType.Name == EdelweissConstants.FAMILY_RECORD_TYPE){
                      mapsObjectNameID.put(EdelweissConstants.FAMILY_RECORD_TYPE+(string.ValueOf(accObject.get('GWM_Online_Id__c'))), accObject.ID);
                    }
                }   
        }
        catch(exception ex)
        {
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : collectMapForClientRelatedRecordsNew()');
        }
        
        return mapsObjectNameID;
    }
    
    
    
    
    //Create Name & Id field Map
    public static Map<String, ID> collectMapForClientRelatedRecords(Map<id, sObject> sObjectRecordMap, String sObjectName)
    {
        Map<String, ID> mapsObjectNameID = new Map<String, ID>();
        try
        {  
            if(sObjectName == EdelweissConstants.OBJECT_PRODUCT)
            {
                // For Product, comaring Scrip_ID field of GWM Online
                for(sObject objsObject : sObjectRecordMap.values())
                {
                    mapsObjectNameID.put(string.ValueOf(objsObject.get('ProductCode')), objsObject.ID);
                }
            }
            else if(sObjectName == EdelweissConstants.OBJECT_ACCOUNT)
            {                 
                for(sObject objsObject : sObjectRecordMap.values())
                {
                    mapsObjectNameID.put(string.ValueOf(objsObject.get('GWM_Online_Id__c')), objsObject.ID);
                }   
            }
            else if(sObjectName == EdelweissConstants.OBJECT_CLIENT_ACCOUNT)
            {
                for(sObject objsObject : sObjectRecordMap.values())
                {
                    mapsObjectNameID.put(string.ValueOf(objsObject.get('GWM_Client_Account_Id__c')), objsObject.ID);
                }
            }
            else if(sObjectName == EdelweissConstants.OBJECT_LEAD)
            {
                for(Account objLead : (List<Account>)sObjectRecordMap.values())
                {
                    mapsObjectNameID.put(string.ValueOf(objLead.PAN_Number__c), objLead.Id);
                }
            }
            
        }
        catch(exception ex)
        {
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : collectMapForClientRelatedRecords()');
        }
        
        return mapsObjectNameID;
    }
    
    // collect product map key (productCode & Source_Id)
    public static Map<String, ID> collectMapForProductRecords(Map<id, sObject> sObjectRecordMap)
    {
        Map<String, ID> mapsObjectNameID = new Map<String, ID>();
        try
        {
            for(sObject objsObject : sObjectRecordMap.values())
            {
                mapsObjectNameID.put(string.ValueOf(objsObject.get('ProductCode'))+string.ValueOf(objsObject.get('Source_Id__c')), objsObject.ID);
            } 
        }
        catch(exception ex)
        {       
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : collectMapForProductRecords()');
        }
        return mapsObjectNameID;
    }
    
    
    //generate Client_Asset_Information__c object records
    //TODO Old - public static List<Client_Asset_Information__c> generateClientAssetInfoRecords(Map<String, ID> mapProductScripId, Map<String, ID> mapFamilyNameId, Map<String, ID> mapClientNameId, Map<String, ID> mapAccountNameId, List<Client_Asset_Staging_Container__c> listBatchRecords)
    public static List<Client_Asset_Information__c> generateClientAssetInfoRecords(Map<String, ID> mapProductScripId, Map<String, ID> mapFamilyAccountNameId, Map<String, ID> mapAccountNameId, List<Client_Asset_Staging_Container__c> listBatchRecords)
    {
       
        Set<Id> accountRecordTypeIdSet = new Set<Id>();
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId());
		accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId());
        Map<Id , Account> mapOfAccount = new Map<Id , Account>([SELECT Id, RecordTypeId, Name, GWM_Online_Id__c FROM Account WHERE GWM_Online_Id__c !=null 
            AND RecordTypeId IN :accountRecordTypeIdSet ]);
        
        List<Client_Asset_Information__c> listClientAssetInfo = new List<Client_Asset_Information__c>();
        for(Client_Asset_Staging_Container__c objAssetStaging : listBatchRecords)
        {            
            Client_Asset_Information__c objClientAsset = new Client_Asset_Information__c();
            try
            {                
                objClientAsset.Asset_Class__c = objAssetStaging.Asset_Class__c;
                                
                // add Client lookup
            if(mapFamilyAccountNameId.containskey(EdelweissConstants.CLIENT_RECORD_TYPE+objAssetStaging.Client_Code__c))
                {
                    objClientAsset.Client__c =mapFamilyAccountNameId.get(EdelweissConstants.CLIENT_RECORD_TYPE+objAssetStaging.Client_Code__c);
                }
                
                // add Account lookup
                if(mapAccountNameId.containskey(objAssetStaging.Account_Code__c))
                {
                    objClientAsset.Client_Account__c = mapAccountNameId.get(objAssetStaging.Account_Code__c);
                }
                
                // add Family lookup
                
      		  if(mapFamilyAccountNameId.containskey(EdelweissConstants.FAMILY_RECORD_TYPE+objAssetStaging.Family_Code__c))
                {
                    objClientAsset.Family__c = mapFamilyAccountNameId.get(EdelweissConstants.FAMILY_RECORD_TYPE+objAssetStaging.Family_Code__c);
                }
                                
                //add condition for Product
                string keyForProduct = objAssetStaging.Scrip_Key__c + objAssetStaging.Source_Id__c;
                if(mapProductScripId.containskey(keyForProduct))
                {
                    objClientAsset.Product__c = mapProductScripId.get(keyForProduct); 
                }         
                
                objClientAsset.Scrip_Key__c = objAssetStaging.Scrip_Key__c;
                objClientAsset.Source_ID__c = objAssetStaging.Source_Id__c;
                objClientAsset.Scrip_Name__c = objAssetStaging.Scrip_Name__c;
                objClientAsset.Sub_Asset_Class__c = objAssetStaging.Sub_Asset_Class__c;
                objClientAsset.Total_AUM__c = objAssetStaging.Total_AUM__c;
                objClientAsset.Networth__c = objAssetStaging.Networth__c;
                objClientAsset.Staging_Client_Code__c = objAssetStaging.Client_Code__c;
                objClientAsset.Staging_Family_Code__c = objAssetStaging.Family_Code__c;
                if(objAssetStaging.Folio_Number__c != null){
                    objClientAsset.Folio_Number__c =  objAssetStaging.Folio_Number__c;
                }
                if(objAssetStaging.Amc_Code__c != null){
                    objClientAsset.Amc_Code__c =  objAssetStaging.Amc_Code__c;
                }
                if(objAssetStaging.Amc_Name__c != null){
                    objClientAsset.Amc_Name__c =  objAssetStaging.Amc_Name__c;
                }
 				if(objAssetStaging.Quantity__c != null){
                    objClientAsset.Quantity__c = objAssetStaging.Quantity__c;
                }
                if(objAssetStaging.Investment_Value__c != null){
                    objClientAsset.Investment_Value__c = objAssetStaging.Investment_Value__c;
                }
                If(objAssetStaging.As_On_Date__c !=null)
                    objClientAsset.As_On_Date__c =Date.ValueOf(objAssetStaging.As_On_Date__c);
                
                if(objAssetStaging.Annual_Record__c == '1'){
                    objClientAsset.Annual_Record__c = true;
                } else if(objAssetStaging.Annual_Record__c == '0'){
                    objClientAsset.Annual_Record__c = false;
                }
                //add to list
                listClientAssetInfo.add(objClientAsset);
            }
            catch(exception ex)
            {
                Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateClientAssetInfoRecords()');
            }
        }  
        return listClientAssetInfo;
    }
    
    //
    //Method Name : chornExpression()
    //Description : This method forms a cron expression used to initiate the schedule
    //   
    public static String chornExpression(Integer hours)
    {    
        system.debug('Inside chornExpression'); 
        Datetime sysTime = System.now();
        sysTime = sysTime.addHours(hours);
        String chron_exp =sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        system.debug('chornExpression for Cerner ::'+chron_exp); 
        return chron_exp;
    }
    
    // returns the leads got converted into Client.
    // check in all R2 Status Leads having same PAN or not.
    public static Map<String, Id> getConvertedLead(Map<String, ID> mapLeadPANId, List<Edelweiss_Clients_Staging_Container__c> listBatchRecords)
    {
        Map<String, Id> mapPANNoConvertedLeadId = new Map<String, ID>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        if(mapLeadPANId != null)
        {
            for(Edelweiss_Clients_Staging_Container__c objClientStaging : listBatchRecords)
            {
                try
                {
                    // Check inetgration staging record contains tentetive client or contains converted lead.
                    // for tentavie client id will be Account object id.
                    if(mapLeadPANId.containsKey(objClientStaging.PAN_Number__c))
                    {
                        //Add leads Id for converted client...
                        mapPANNoConvertedLeadId.put(objClientStaging.PAN_Number__c,mapLeadPANId.get(objClientStaging.PAN_Number__c));
                    }
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : getConvertedLead(); Client PAN Card : '+objClientStaging.PAN_Number__c);
                    listError.add(objError);
                }
            }
        }
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        return mapPANNoConvertedLeadId ;
    }
    
    //generate Contacts for converted clients
    public static List<Contact> generateConvertedClientContact(Map<String, Account> mapGwmIdNewCreatedClient, Map<String, Id> mapConvertedLead, 
                                    Map<id, Account> mapLeadRecord, Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord)
    {
        list<Contact> listConvertedClientContact = new List<Contact>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        
        for(String convertedLeadPAN: mapConvertedLead.keySet())
        {
            // create Client Account only when newly create Client is there...
			Edelweiss_Clients_Staging_Container__c stagingRecord = mapPanClientStagingRecord.get(convertedLeadPAN);
			
            if(stagingRecord !=Null && mapGwmIdNewCreatedClient.containsKey(stagingRecord.GWM_Online_Client_Id__c))
            {
                try
                {
                    // generate Client record
                    Contact objConvertedClientContact = new Contact();
                    //objConvertedClientContact.FirstName=stagingRecord.Client_First_Name__c;
                    //objConvertedClientContact.MiddleName=stagingRecord.Client_Middle_Name__c;
                    // since there is no concept of Naming in GWM so keeping Client Name as Contact Last name
                    objConvertedClientContact.LastName=stagingRecord.Client_Name__c;
                    objConvertedClientContact.Gender__c=stagingRecord.Gender__c;                    
                    objConvertedClientContact.RecordTypeId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(EdelweissConstants.EDELWEISS_CONTACT_RECORD_TYPE).getRecordTypeId();
                    // accept only "YYY-mm-dd" format of date field
                    if(stagingRecord.Date_of_Birth__c != null)
                        objConvertedClientContact.Birth_Date__c=Date.valueOf(stagingRecord.Date_of_Birth__c);
                    objConvertedClientContact.AccountId=mapGwmIdNewCreatedClient.get(stagingRecord.GWM_Online_Client_Id__c).Id;
                    objConvertedClientContact.OwnerId=mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).OwnerId;
                    objConvertedClientContact.Is_Primary_Contact__c=true;                    
                    objConvertedClientContact.Office_Phone__c=stagingRecord.Office_Number__c;
                    objConvertedClientContact.Official_Email__c=stagingRecord.Official_Email__c;
                    objConvertedClientContact.Salutation=stagingRecord.Salutation__c;
                    objConvertedClientContact.Nationality__c=stagingRecord.Nationality__c;
                    objConvertedClientContact.Official_Email__c=stagingRecord.Official_Email__c;
                    
                    if(stagingRecord.Anniversary_Date__c !=null)
                        objConvertedClientContact.Wedding_Anniversary__c=Date.valueOf(stagingRecord.Anniversary_Date__c );
                    /*
                    objConvertedClientContact.Phone = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Phone;
                    objConvertedClientContact.Mobile_1__c = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Mobile_1__c;
                    objConvertedClientContact.Mobile_2__c = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Mobile_2__c;
                    objConvertedClientContact.Mobile_3__c = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Mobile_3__c;
                    objConvertedClientContact.Official_Address__c=mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Official_Address__c;
                    objConvertedClientContact.Residence_Address__c=mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Residence_Address__c;
                    objConvertedClientContact.Primary_Email__c = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Primary_Email__c;    
                    objConvertedClientContact.Secondry_Email__c = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Secondary_Email__c;                    
					*/
                    listConvertedClientContact.add(objConvertedClientContact);
                    
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN);
                    listError.add(objError);
                }
            }
        }
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        return listConvertedClientContact;
    }
    
    
    // Generate Client Account record for object : Client_Account__c.
    public static List<Client_Account__c> generateConvertedClientAccountRecords(Map<String, Id> mapConvertedLead, Map<id, Account> mapLeadRecord, 
                                    Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord,
                                    Map<String, Id> mapAccountAccNameId, Map<String, Account> mapGwmIdNewCreatedClient)
    {
        List<Client_Account__c> listConvertedClientAccount = new List<Client_Account__c>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        
        for(String convertedLeadPAN: mapConvertedLead.keySet())
        {
            // create Client Account only when newly create Client is there...
            if(mapPanClientStagingRecord.get(convertedLeadPAN) !=Null && mapGwmIdNewCreatedClient.containsKey(mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Client_Id__c))
            {
                try
                {
                    // generate Client record
                    Client_Account__c objConvertedClientAccount = new Client_Account__c();
                    objConvertedClientAccount.Name =mapPanClientStagingRecord.get(convertedLeadPAN).Account_Name__c;
                    objConvertedClientAccount.GWM_Client_Account_Id__c=mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Account_Id__c;
                    objConvertedClientAccount.Asset_Classes_Client_is_Interested_in__c=mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Asset_Classes_Client_is_Interested_in__c;
                    //objConvertedClientAccount.Zone__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Zone__c;
                    objConvertedClientAccount.Gender__c=mapPanClientStagingRecord.get(convertedLeadPAN).Gender__c;
                    //objConvertedClientAccount.Zone__c =
                    objConvertedClientAccount.Annual_Income__c= mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Annual_Income__c;                    
                    objConvertedClientAccount.Current_Investment_Portfolio__c=integer.valueOf(mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Current_Investment_Portfolio_formula__c);
                    objConvertedClientAccount.PAN_Number__c=mapPanClientStagingRecord.get(convertedLeadPAN).PAN_Number__c;
                    objConvertedClientAccount.Client_Type__c= mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Entity_Type__c;
                    //objConvertedClientAccount.Date_of_Birth__c=mapPanClientStagingRecord.get(convertedLeadPAN).Date_of_Birth__c ;
                    objConvertedClientAccount.Client__c=mapGwmIdNewCreatedClient.get(mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Client_Id__c).Id;
                    //objConvertedClientAccount.Converted_From_Lead__c=mapConvertedLead.get(convertedLeadPAN);
                    objConvertedClientAccount.Account_type__c=mapPanClientStagingRecord.get(convertedLeadPAN).Account_type__c;
                    
                    //add family record in list
                    listConvertedClientAccount.add(objConvertedClientAccount);
                    
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN);
                    listError.add(objError);
                    Edelweiss_Clients_Staging_Container__c edlClient = mapPanClientStagingRecord.get(convertedLeadPAN);
                    edlClient.synch__c = false;
                    edlClient.ErrorMessage__c =  'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN + ex.getMessage();
                    update edlClient;
                }
            }
        }
        
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        system.debug('Integration_Helper::generateConvertedClientAccountRecords()::listConvertedClientAccount>>> '+listConvertedClientAccount);
        return listConvertedClientAccount;
    }
    
    
    // generate Client record for Account object.
    // Function checks existing Family, if not create new Family.
    public static List<Account> generateConvertedClientRecords(Map<String, Id> mapConvertedLead, Map<id, Account> mapLeadRecord, 
                                    Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord, 
                                    Map<String, Id> mapFamilyNameId, Map<String, Id> mapClientNameId, String strFamilyOrClient, 
                                    Map<String, User> mapFaUser, Map<String, Account> mapNewFamilyCreated, Map<String, List<Account>> mapFamilyAndExistingClientsOfCrm,Map<Id,Account>existingClient)
    {
        Map<String, Account> gwmIdWithClientMap = new Map<String, Account>();
        List<Account> listConvertedClient = new List<Account>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        if(strFamilyOrClient == EdelweissConstants.CLIENT_RECORD_TYPE)
        {
            for(String convertedLeadPAN: mapConvertedLead.keySet())
            {
                Edelweiss_Clients_Staging_Container__c stagingRecord = mapPanClientStagingRecord.get(convertedLeadPAN);
                Account objLead = mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN));
                
                if(stagingRecord !=Null && !mapClientNameId.containsKey(stagingRecord.GWM_Online_Client_Id__c))
                {
                    try
                    {
                        
                        // generate Client record
                        Account objConvertedClients = objLead;
                        objConvertedClients.RecordTypeId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
                        objConvertedClients.IPS_Done__c = 'No';
                        objConvertedClients.Coverage__c = 'R3';
                        objConvertedClients.Name =stagingRecord.Client_Name__c;
                        objConvertedClients.GWM_Online_Id__c = stagingRecord.GWM_Online_Client_Id__c;
                        objConvertedClients.Focus_30__c = stagingRecord.Focus_30_Client__c == '1' ? true : false;
                        objConvertedClients.High_Priority__c = stagingRecord.High_Priority_Client__c == '1' ? true : false;
                        objConvertedClients.Anniversary_Date__c = stagingRecord.Anniversary_Date__c;
                        objConvertedClients.POA__c = stagingRecord.POA__c;
                        objConvertedClients.Sub_Lob__c = stagingRecord.Sub_Lob__c ;
                        objConvertedClients.Gender__c=stagingRecord.Gender__c;
                        objConvertedClients.PAN_Number__c=stagingRecord.PAN_Number__c;
                        objConvertedClients.Nationality__c=stagingRecord.Nationality__c;
                        objConvertedClients.MilesActivationDate__c=stagingRecord.Miles_Activation_Date__c;
                        objConvertedClients.Mandate__c = stagingRecord.Mandate__c == '1' ? true : false;
                        
                        if(!String.isBlank(stagingRecord.Gender__c)){
                            objConvertedClients.Gender__c = stagingRecord.Gender__c;
                        }
                        
                        
                        //Assign Client's Family..
                        if(mapNewFamilyCreated !=null  && mapNewFamilyCreated.containsKey(stagingRecord.GWM_Online_Family_Id__c)){
                            objConvertedClients.ParentId =mapNewFamilyCreated.get(stagingRecord.GWM_Online_Family_Id__c).Id;
                        }
                        else if(mapFamilyNameId.containsKey(stagingRecord.GWM_Online_Family_Id__c)){
                            objConvertedClients.ParentId =mapFamilyNameId.get(stagingRecord.GWM_Online_Family_Id__c);
                        }
						
                        // collect Fa user salesforce id 
                        string strFaUniqueId = stagingRecord.Primary_FA_Employee_Id__c + stagingRecord.Primary_FA_Miles_Id__c;
                        string strCxoUniqueId = stagingRecord.Primary_CXO_Employee_Id__c + stagingRecord.Primary_CXO_Miles_Id__c;
                        
                        if(mapFaUser.get(strFaUniqueId) !=null){
                            objConvertedClients.Primary_FA__c=mapFaUser.get(strFaUniqueId).Id;
                            objConvertedClients.OwnerId=mapFaUser.get(strFaUniqueId).Id;
                        }
                        
                        if(mapFaUser.get(strCxoUniqueId) !=null)
                            objConvertedClients.Primary_CXO__c =mapFaUser.get(strCxoUniqueId).Id;
						
                        If(stagingRecord.Date_of_Birth__c !=null)
							objConvertedClients.Date_of_Birth__c=Date.valueOf(stagingRecord.Date_of_Birth__c) ;
						
						// check in existing Client list for the current Family, is there any one client having Family_Head = True or False.
                        // if false; Update current Family else skip.....
                        Boolean flagFamilyHead;
                        if(mapFamilyAndExistingClientsOfCrm.containsKey(stagingRecord.GWM_Online_Family_Id__c))
                        {
                            for(Account objExistClnt: mapFamilyAndExistingClientsOfCrm.get(stagingRecord.GWM_Online_Family_Id__c))
                            {
                                if(objExistClnt.Is_Client_Family_Head__c == 'Yes')
                                {
                                    flagFamilyHead=true;
                                    break;
                                }
                            }
                        }
                        else
                        {
                            flagFamilyHead=false;
                        }
						
                        if(flagFamilyHead == false)
                            objConvertedClients.Is_Client_Family_Head__c=stagingRecord.Is_Client_Family_Head__c;
                        
                        //Generate Address
                        String officeAddress = ''; 
                        String ResidentialAddr = '';
                        
                        if(!String.isBlank(stagingRecord.Official_Address__c)){
                            officeAddress += stagingRecord.Official_Address__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Official_City__c)){
                            officeAddress += stagingRecord.Official_City__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Official_State__c)){
                            officeAddress += stagingRecord.Official_State__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Official_Country__c)){
                            officeAddress += stagingRecord.Official_Country__c+ ' '; 
                        }
                        if(!String.isBlank(stagingRecord.Official_Pin__c)){
                            officeAddress += stagingRecord.Official_Pin__c; 
                        }
                        if(!String.isBlank(officeAddress)){
                            objConvertedClients.Official_Address__c=officeAddress ;
                        }
                        
                        
    
                        if(!String.isBlank(stagingRecord.Mailing_Address__c)){
                            ResidentialAddr += stagingRecord.Mailing_Address__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Mailing_Street__c)){
	                    	ResidentialAddr += stagingRecord.Mailing_Street__c+ ', '; 
	                    }
                        if(!String.isBlank(stagingRecord.Mailing_City__c)){
                            ResidentialAddr += stagingRecord.Mailing_City__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Mailing_State__c)){
                            ResidentialAddr += stagingRecord.Mailing_State__c+ ', '; 
                        }
                        if(!String.isBlank(stagingRecord.Mailing_Country__c)){
                            ResidentialAddr += stagingRecord.Mailing_Country__c+ ' '; 
                        }
                        if(!String.isBlank(stagingRecord.Mailing_Postal_Code__c)){
                            ResidentialAddr += stagingRecord.Mailing_Postal_Code__c; 
                        }
                        if(!String.isBlank(ResidentialAddr)){
                            objConvertedClients.Residence_Address__c=ResidentialAddr ;
                        }
                        
                        if(stagingRecord.Office_Number__c != null){
                            objConvertedClients.Office_Phone_Number__c = stagingRecord.Office_Number__c;
                        }
                        
                        /*
                        if(stagingRecord.Mobile_No__c != null && (objConvertedClients.Mobile_1__c != stagingRecord.Mobile_No__c)){
                            //System.debug('Inside mobile if');
                            objConvertedClients.Mobile_2__c = objConvertedClients.Mobile_1__c;  
                            objConvertedClients.Phone = stagingRecord.Mobile_No__c;
                            objConvertedClients.Mobile_1__c = stagingRecord.Mobile_No__c;
                        }
                        else if(stagingRecord.Alternate_Number__c != null){
                            //System.debug('Inside mobile else');
                            objConvertedClients.Mobile_2__c = stagingRecord.Alternate_Number__c;
                        }
                        
                        if(stagingRecord.Primary_Email__c != null && (objConvertedClients.Primary_Email__c != stagingRecord.Primary_Email__c)){
                            objConvertedClients.Secondary_Email__c = objConvertedClients.Primary_Email__c;
                            objConvertedClients.Primary_Email__c = stagingRecord.Primary_Email__c;
                        }
                        else if(stagingRecord.Secondary_Email__c != null){
                            objConvertedClients.Secondary_Email__c = stagingRecord.Secondary_Email__c;
                        }*/
                        
                        gwmIdWithClientMap.put(objConvertedClients.GWM_Online_Id__c, objConvertedClients);
                        //listConvertedClient.add(objConvertedClients);
                        
                        
                    }
                    catch(exception ex)
                    {
                        Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN);
                        listError.add(objError);
                        Edelweiss_Clients_Staging_Container__c edlClient = stagingRecord;
                        edlClient.synch__c = false;
                        edlClient.ErrorMessage__c =  'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN + ex.getMessage();
                        update edlClient;
                    }
                }else{
                    Account objExistingClient = existingClient.get(mapClientNameId.get(stagingRecord.GWM_Online_Client_Id__c));
                    gwmIdWithClientMap.put(objExistingClient.GWM_Online_Id__c, objExistingClient);
                    //listConvertedClient.add(objExistingClient);
                }
            }
        }
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        system.debug('Integration_Helper::generateClientRecords()::gwmIdWithClientMap >>> '+gwmIdWithClientMap.values());
        //return listConvertedClient;
        return gwmIdWithClientMap.values();
    }
    
    
    public static List<Account> updateFamilyRecordsList(List<Edelweiss_Clients_Staging_Container__c> listBatchRecords, Map<String, Account> mapFamilyGwmIdNewCreatedFamily)
    {
        List<Account> listUpdatedFamily = new List<Account>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        
        for(Edelweiss_Clients_Staging_Container__c objStaging : listBatchRecords){
            try{
                Account objFamilyRecord = mapFamilyGwmIdNewCreatedFamily.get(objStaging.GWM_Online_Family_Id__c);
                if(objFamilyRecord != null){
                    
                    System.debug('Inside Family Updation');
                    objFamilyRecord.Focus_30__c = objStaging.Focus_30_Client__c == '1' ? true : false;
                    objFamilyRecord.High_Priority__c = objStaging.High_Priority_Client__c == '1' ? true : false;
                    //objFamilyRecord.Mandate__c = objStaging.Mandate__c == '1' ? true : false;
                    /**  Update Family Mandate only if client's mandate is 1  
                    If(objStaging.Mandate__c == '1')
                    {
                    	objFamilyRecord.Mandate__c=true;
                    } **/
                    
                    objFamilyRecord.Backoffice_Code_NBFC__c =objStaging.Backoffice_Code_NBFC__c;
                    
                    listUpdatedFamily.add(objFamilyRecord);
                }
            }
            Catch(exception ex)
            {
                Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : ');
                listError.add(objError);          
            }
        }
        
        if(!listError.isEmpty()){
            database.insert(listError);
        }
        return listUpdatedFamily;
    }

    
    // generate Family record for Account object.
    // Function checks existing Family, if not create new Family.
    public static List<Account> generateConvertedFamilyRecords(Map<String, Id> mapConvertedLead, Map<id, Account> mapLeadRecord, Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord, Map<String, Id> mapFamilyNameId, Map<String, Id> mapClientNameId, String strFamilyOrClient, Map<String, User> mapFaCxoUser, Map<Id,Account> mapExistingCrmFamilyRecord)
    {
        List<Account> listConvertedFamily = new List<Account>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();        
        
        System.debug('mapPanClientStagingRecord <><>< : '+ mapPanClientStagingRecord);
        
        if(strFamilyOrClient == EdelweissConstants.FAMILY_RECORD_TYPE)
        {
            for(String convertedLeadPAN: mapConvertedLead.keySet())
            {   
                try
                {
                    if(mapPanClientStagingRecord.get(convertedLeadPAN) !=Null && !mapFamilyNameId.containsKey(mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Family_Id__c))
                    {   
                    	System.debug('Inside New Family Creation');
                        // generate Family record
                        Account objConvertedClientsFamily = new Account();
                        objConvertedClientsFamily.Name =mapPanClientStagingRecord.get(convertedLeadPAN).Family_Name__c;
                        objConvertedClientsFamily.GWM_Online_Id__c =mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Family_Id__c;
                        objConvertedClientsFamily.RecordTypeId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
                        objConvertedClientsFamily.Coverage__c=EdelweissConstants.FAMILY_CLIENT_R3_STATUS;
                        objConvertedClientsFamily.Nationality__c=mapPanClientStagingRecord.get(convertedLeadPAN).Nationality__c;
                        objConvertedClientsFamily.MilesActivationDate__c=mapPanClientStagingRecord.get(convertedLeadPAN).Miles_Activation_Date__c;
                        
                        //Focus_30_Client__c
                        if(mapPanClientStagingRecord.get(convertedLeadPAN).Focus_30_Client__c == '1')
                            objConvertedClientsFamily.Focus_30__c=true;
                        else if(mapPanClientStagingRecord.get(convertedLeadPAN).Focus_30_Client__c == '0')
                            objConvertedClientsFamily.Focus_30__c=false;
                        
                        //High_Priority_Client__c
                        if(mapPanClientStagingRecord.get(convertedLeadPAN).High_Priority_Client__c == '1')
                            objConvertedClientsFamily.High_Priority__c=true;
                        else if(mapPanClientStagingRecord.get(convertedLeadPAN).High_Priority_Client__c == '0')
                            objConvertedClientsFamily.High_Priority__c=false;
                            
                       /**** commenting else if because update Family Mandate whenever any client's mandate is true 
                        if(mapPanClientStagingRecord.get(convertedLeadPAN).Mandate__c == '1'){
                            objConvertedClientsFamily.Mandate__c=true;
                        }
                        /**
                        
                        else if(mapPanClientStagingRecord.get(convertedLeadPAN).Mandate__c == '0')
                            objConvertedClientsFamily.Mandate__c=false; */
                        
                        // collect Fa user salesforce id 
                        string strFaUniqueId = mapPanClientStagingRecord.get(convertedLeadPAN).Primary_FA_Employee_Id__c+ mapPanClientStagingRecord.get(convertedLeadPAN).Primary_FA_Miles_Id__c;
                        string strCxoUniqueId = mapPanClientStagingRecord.get(convertedLeadPAN).Primary_CXO_Employee_Id__c+ mapPanClientStagingRecord.get(convertedLeadPAN).Primary_CXO_Miles_Id__c;
                        
                        if(mapFaCxoUser.get(strFaUniqueId) !=null) 
                            objConvertedClientsFamily.Primary_FA__c=mapFaCxoUser.get(strFaUniqueId).Id;
                        
                        if(mapFaCxoUser.get(strCxoUniqueId) !=null)
                            objConvertedClientsFamily.Primary_CXO__c =mapFaCxoUser.get(strCxoUniqueId).Id;
                        
                        //Assign Rollup Family AUM to Zero at the time of family creation
                        objConvertedClientsFamily.Rollup_AUM_of_Family__c =Integer.ValueOf(0);
                        objConvertedClientsFamily.Family_Networth__c =Integer.ValueOf(0);
                        
                        objConvertedClientsFamily.OwnerId =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).OwnerId;
                        objConvertedClientsFamily.Risk_Profile_Based_on_IPS__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Risk_Profile_Based_on_IPS__c;
                        objConvertedClientsFamily.How_Often_Does_Client_Monitor_Portfolio__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).How_Often_Does_Client_Monitor_Portfolio__c;
                        objConvertedClientsFamily.Lead_Category__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Lead_Category__c;
                        objConvertedClientsFamily.AccountSource =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).AccountSource;
                        objConvertedClientsFamily.Account_Source_Other__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Account_Source_Other__c;
                        objConvertedClientsFamily.Referrer_Name__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Referrer_Name__c;
                        objConvertedClientsFamily.Referrer_Contact__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Referrer_Contact__c;
                        objConvertedClientsFamily.Trading_Account_Number__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Trading_Account_Number__c;
                        objConvertedClientsFamily.DP_ID__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).DP_ID__c;                     
                        objConvertedClientsFamily.Account_Type__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Account_Type__c;                       
                        objConvertedClientsFamily.Demat_Account_Number__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Demat_Account_Number__c;                       
                        objConvertedClientsFamily.Miles_Account_Status__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Miles_Account_Status__c;
                        
                        //For Mini IPS
                        objConvertedClientsFamily.IsFilled_MINIIPS__c = true;
                        
                        //New fields Added in Staging
                        objConvertedClientsFamily.Backoffice_Code_NBFC__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Backoffice_Code_NBFC__c;
                        
                        //add family record in list
                        system.debug('New Family >>>'+objConvertedClientsFamily);
                        listConvertedFamily.add(objConvertedClientsFamily);
                        
                    }
                    else if(mapPanClientStagingRecord.get(convertedLeadPAN) !=Null && mapFamilyNameId.containsKey(mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Family_Id__c))
                    {
                    	System.debug('Inside Old Family Creation');
                        // check exiting client records having focus 30 and Hight priority field then updated existing Family focus 30 & hight priority
                        // If Set current Client Focus 30 & Hight priority value in existing family.
                        Account objExistingFamily = mapExistingCrmFamilyRecord.get(mapFamilyNameId.get(mapPanClientStagingRecord.get(convertedLeadPAN).GWM_Online_Family_Id__c));
                        
                        objExistingFamily.Focus_30__c = mapPanClientStagingRecord.get(convertedLeadPAN).Focus_30_Client__c == '1' ? true : false;
                        objExistingFamily.High_Priority__c = mapPanClientStagingRecord.get(convertedLeadPAN).High_Priority_Client__c == '1' ? true : false;
                        //objExistingFamily.Mandate__c = mapPanClientStagingRecord.get(convertedLeadPAN).Mandate__c == '1' ? true : false;
                        /** Commenting to update family based on client
                        if(mapPanClientStagingRecord.get(convertedLeadPAN).Mandate__c == '1')
                        {
                        	objExistingFamily.Mandate__c=true;
                        } **/
                        
                        objExistingFamily.Backoffice_Code_NBFC__c =mapLeadRecord.get(mapConvertedLead.get(convertedLeadPAN)).Backoffice_Code_NBFC__c;
                        
                        listConvertedFamily.add(objExistingFamily);
                    }                
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+convertedLeadPAN);
                    listError.add(objError);
                }
            }
        }        
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        Set<Account> familySet = new Set<Account>();
        familySet.addAll(listConvertedFamily);
        List<Account> lstFamily = new List<Account>();
        lstFamily.addAll(familySet);
            
        system.debug('Integration_Helper::generateFamilyAndClientRecords()::listFamily >>> '+lstFamily);
        return lstFamily;
    }
   
    // Build response for HttpPost callout for FA-CXO mapping   
    public static String generateHttpPostResponseMessages(String message, Integer statusCode)
    {
       /* Edelweiss_Json2ApexRestApiResponse insResponseClass = new Edelweiss_Json2ApexRestApiResponse();
        Edelweiss_Json2ApexRestApiResponse.Response  insPostResponseCls = new Edelweiss_Json2ApexRestApiResponse.Response();
        insPostResponseCls.response_code = statusCode;
        insPostResponseCls.response_message = message;
        
        insResponseClass.response =  insPostResponseCls;
        
        return JSON.serialize(insResponseClass);*/
        return null;
    }
    
    
    
    // Generate Fa-Cxo Mapping object record list
    public static List<FA_CSO_Mapping__c> generateFaCxoMappingRecordList(List<FA_CXO_Staging_Container__c> listFaCxoStagingData, Map<String, User> mapFaCxoUser)
    {
        List<FA_CSO_Mapping__c> finalFaCxoList = new List<FA_CSO_Mapping__c>();        
        
        //Itrate on list of FA_CXO_Staging_Container__c
        for(FA_CXO_Staging_Container__c instFaCxoStaging : listFaCxoStagingData)
        {
            FA_CSO_Mapping__c objSfFaCxo= new FA_CSO_Mapping__c();
            String strFaEmpIdMilesId = instFaCxoStaging.FA_Employee_Id__c+instFaCxoStaging.FA_Miles_Id__c;
            String strCxoEmpIdMilesId = instFaCxoStaging.CXO_Employee_Id__c+instFaCxoStaging.CXO_Miles_Id__c;
            system.debug('strFaEmpIdMilesId >>>'+strFaEmpIdMilesId);
            system.debug('strCxoEmpIdMilesId >>'+strCxoEmpIdMilesId);
            
            User objFaUser = mapFaCxoUser.get(strFaEmpIdMilesId);
            User objCxoUser = mapFaCxoUser.get(strCxoEmpIdMilesId);
            system.debug('objFaUser >>>'+objFaUser );
            system.debug('objCxoUser >>'+objCxoUser );
            
            if(objFaUser != Null && objCxoUser != null)
            {
                objSfFaCxo.CSO_User__c = objCxoUser.id;
                objSfFaCxo.FA_User__c= objFaUser.Id;
                /* Testing Field */
                //objSfFaCxo.Testing_Email_Field__c = 'abc.com';
                /* Testing Field */
                finalFaCxoList.add(objSfFaCxo);
            }
        }
        
        system.debug('Inside generateFaCxoMappingRecordList ::: finalFaCxoList::'+finalFaCxoList);
        return finalFaCxoList;   
    }
    
    
    // check FA-CXO Users exists in CRM or not
    // return staging record which is not mapped with updated field Mapping_Available_in_CRM__c
    public static List<FA_CXO_Staging_Container__c> checkFaCxoUsersAvailableInCRM( List<FA_CXO_Staging_Container__c> listFaCxoStagingData, Map<String, User> mapFaCxoUser) //List<FA_CXO_Staging_Container__c> listBatchRecords, Map<String, User> mapFaCxoUser)
    {
        List<FA_CXO_Staging_Container__c> listNotMappedFaCxoStagingRecords = new List<FA_CXO_Staging_Container__c>();
        for(FA_CXO_Staging_Container__c objFaCxoStaging: listFaCxoStagingData)
        {
            String uniqueFaIds = objFaCxoStaging.FA_Employee_Id__c +objFaCxoStaging.FA_Miles_Id__c;
            String uniqueCxoIds = objFaCxoStaging.CXO_Employee_Id__c +objFaCxoStaging.CXO_Miles_Id__c;
            system.debug('uniqueFaIds>>>'+uniqueFaIds);
            system.debug('uniqueCxoIds>>>'+uniqueCxoIds);
            system.debug('mapFaCxoUser.keySet()>>>'+mapFaCxoUser.keySet());
            system.debug('mapFaCxoUser.containsKey(uniqueFaIds)>>>'+mapFaCxoUser.containsKey(uniqueFaIds));
            system.debug('mapFaCxoUser.containsKey(uniqueCxoIds)>>>'+mapFaCxoUser.containsKey(uniqueCxoIds));
            
            if(!mapFaCxoUser.containsKey(uniqueFaIds) || !mapFaCxoUser.containsKey(uniqueCxoIds))
            {
                objFaCxoStaging.Mapping_Available_in_CRM__c = 'No';
                listNotMappedFaCxoStagingRecords.add(objFaCxoStaging);
            }
        }
        return listNotMappedFaCxoStagingRecords;
    
    }
    
    
    // generate REST Api integration Container records
    public static Edelweiss_Integration_Container__c generateIntegrationContainerRecord(string gwmJsonRequest, string inboundApiName, Boolean isValidRequest, string requestOperationalStatus, string sfJsonResponse)
    {
        Edelweiss_Integration_Container__c objIntgrContainer = new Edelweiss_Integration_Container__c();
            
        try
        {
            objIntgrContainer.GWM_JSON_Request__c=gwmJsonRequest;
            objIntgrContainer.Inbound_API_Name__c=inboundApiName;
            objIntgrContainer.IsValidRequest__c=isValidRequest;
            objIntgrContainer.Request_Operational_Status__c=requestOperationalStatus;
            objIntgrContainer.Salesforce_JSON_Response__c=sfJsonResponse;
            
            
        }
        catch(exception ex)
        {
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateIntegrationContainerRecord()');
        }
        
        return objIntgrContainer;
    }
    
    
    public static Map<String, List<Task>> getCompletedMilesAccountOpeningTask(Map<string, Edelweiss_Clients_Staging_Container__c> mapClientStagingPANAndRecords)
    {
        Map<String, List<Task>> mapClientPANAndCompetedTask = new Map<String, List<Task>>();
        list<Edelweiss_Error_Log__c> listError = new List<Edelweiss_Error_Log__c>();
        List<Id> caseRecordType = new List<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        
        for(Case objCase: [SELECT Id, CaseNumber, Status, PAN_Number__c,
                               (SELECT Id, Subject, Status, WhatId FROM Tasks 
                                WHERE (Subject =: EdelweissConstants.MILES_ACCOUNT_OPENING_TASK_TYPE OR Subject =: EdelweissConstants.MILES_ACCOUNT_OPENING_AUTO_CLOSURE_TASK_TYPE)
                                AND (Status =: EdelweissConstants.IN_PROGRESS_STATUS OR Status =: EdelweissConstants.CASE_ESCALATED_STATUS)) 
                           FROM Case 
                           WHERE RecordTypeId IN:caseRecordType 
                           AND (Status =: EdelweissConstants.IN_PROGRESS_STATUS OR Status =: EdelweissConstants.CASE_OPEN_STATUS) AND PAN_Number__c IN:mapClientStagingPANAndRecords.keySet()])
        {
            try
            {
                system.debug('objCase >>>'+objCase);
                if(objCase.Tasks !=Null)
                {
                    for(Task objTask: objCase.Tasks)
                    {
                        system.debug('objTask >>>'+objTask);
                        system.debug('objCase.PAN_Number__c>>>'+objCase.PAN_Number__c);
                        if(mapClientPANAndCompetedTask.containsKey(objCase.PAN_Number__c))
                        {
                            List<Task> completedTask = mapClientPANAndCompetedTask.get(objCase.PAN_Number__c);
                            objTask.Status = EdelweissConstants.TASK_COMPLETED_STATUS;
                            completedTask.add(objTask);
                            mapClientPANAndCompetedTask.put(objCase.PAN_Number__c, completedTask);
                        }
                        else
                        {
                            List<Task> completedTask = New List<Task>();
                            objTask.Status = EdelweissConstants.TASK_COMPLETED_STATUS;
                            completedTask.add(objTask);
                            mapClientPANAndCompetedTask.put(objCase.PAN_Number__c, completedTask);
                        }
                    }
                }
            }
            catch(exception ex)
            {
            
                Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : getCompletedMilesAccountOpeningTask(): Case PAN_Number__c ::'+ objCase.PAN_Number__c);
                listError.add(objError);
                
            }
        }
                       
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        return mapClientPANAndCompetedTask;
    }
    
    
    public static Map<String, Lead> getAllInProgreeLeads(Set<String> setClientPAN)
    {
        Map<String, Lead> mapClientPANAndReadyToConvertLead = new Map<String, Lead>();
        list<Edelweiss_Error_Log__c> listError = new List<Edelweiss_Error_Log__c>();
        if(setClientPAN!= null && setClientPAN.size() >0)
        {
            for(Lead objLead: [Select id, Status, PAN_Number__c, FA_had_open_a_ticket_case__c FROM Lead where PAN_Number__c IN:setClientPAN])
            {
                try
                {
                    objLead.FA_had_open_a_ticket_case__c= true;
                    mapClientPANAndReadyToConvertLead.put(objLead.PAN_Number__c, objLead);
                    
                }
                catch(exception ex)
                {
                
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : getAllInProgreeLeads(): objLead PAN_Number__c ::'+ objLead.PAN_Number__c);
                    listError.add(objError);
                    
                }
            }
        }
            
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        return mapClientPANAndReadyToConvertLead;
    }
      //Method added by Abhishek Rajput to find product name mismatch
    public static Map<String, Set <String>> getMismatchedProducts(List<String> CRMProductNames,List<String> stagingProductNames){
        Set<String> productsNotInMiles= new set<String>();
        Set<String> productsNotInCRM= new set<String>();
        Map<String, Set<String>> mismatchedProducts= new Map<String, Set<String>>();
        Set<String> duplicateProductsInCRM;
        productsNotInMiles.addAll(CRMProductNames);
        //check if there are more than one products with same name in CRM
        if(productsNotInMiles.size()!=CRMProductNames.size()){
                duplicateProductsInCRM= new set<String>();
                productsNotInMiles.clear();
                for(String productNameInCRM: CRMProductNames){
                    if(!productsNotInMiles.add(productNameInCRM)){
                        duplicateProductsInCRM.add(productNameInCRM);
                    }
                    else{
                        productsNotInMiles.add(productNameInCRM);
                    }
                }
        }
        
        for(String stagingProductName: stagingProductNames){
        if(!productsNotInMiles.add(stagingProductName)){
        productsNotInMiles.remove(stagingProductName);
        }
        else{
        productsNotInCRM.add(stagingProductName);
        }
        }
        mismatchedProducts.put('productsNotInCRM',productsNotInCRM);
        mismatchedProducts.put('productsNotInMiles',productsNotInMiles);
        mismatchedProducts.put('duplicateProductsInCRM',duplicateProductsInCRM);
        return mismatchedProducts;
    }
    public static List<Database.SaveResult> updateMilesAccountOpeningTasks(List<Task> completedTaskList){
        Map<id, Task> caseTaskContainerMap = new Map<id, Task>();
        String MAO = EdelweissConstants.MILES_ACCOUNT_OPENING;
        for(Task taskRecord: completedTaskList){   
               caseTaskContainerMap.put(taskRecord.WhatId, taskRecord);
        }
        List<Service_Activity_History__c> activityHistoryList = [SELECT Case__c,CreatedDate,LastModifiedDate,OwnerId,Owner_Assignment_Date__c,Owner_Change_Date__c,Owner_Change_Reason__c,Owner__c,Stage__c FROM Service_Activity_History__c where case__c IN: caseTaskContainerMap.keySet() and Stage__c=:MAO and Owner_Change_Reason__c!=null order by LastModifiedDate ASC LIMIT 1];
                
        Map<id, Task> completedTasksToUpdateMap = new Map<id, Task>();
        List<Task> completedTasksToUpdateList = new List<Task>();
        
        for(Service_Activity_History__c activityRecord: activityHistoryList){
                        
            Task completedTask = caseTaskContainerMap.get(activityRecord.Case__c);
            completedTask.OwnerId = activityRecord.Owner__c;
            completedTask.Owner_Change_Reason__c = '.';
            completedTasksToUpdateList.add(completedTask);
            completedTasksToUpdateMap.put(activityRecord.Case__c, completedTask);
        }
        
        for(id caseId: caseTaskContainerMap.keySet()){
            if(!completedTasksToUpdateMap.containsKey(caseId)){
                completedTasksToUpdateList.add(caseTaskContainerMap.get(caseId)); 
            }
        }
        
        List<Database.SaveResult> saveResultList = new List<Database.SaveResult>();
        if(completedTasksToUpdateList!=null){
            saveResultList = database.update(completedTasksToUpdateList, false);
        }
        return saveResultList;
    }
    public static  List<User> getProfileUserList(String profileName){
        Profile userProfile = [select id, Name from profile where Name=:profileName];
        List<User> listProfileUsers = [Select id,Email from user where ProfileID =: userProfile.Id and IsActive = true];
        return listProfileUsers;
    } 
    
    // this method is used in the staging objects record deletion batches
    public static void sendDeletionNotificationToAdmin(String batchName, String objectName, String tabName, integer deletedRecords, integer failedRecords){
        // collect users for profile.
        String recipientProfileName='System Administrator';
        Profile userProfile = [select id, Name from profile where Name=:recipientProfileName];
        List<User> listProfileUsers = [Select id,Email from user where ProfileID =: userProfile.Id and IsActive = true];
        
        String strToEmail;
        for(User objUser: listProfileUsers )
        {
            if(strToEmail==null)
                strToEmail=objUser.Email;
            else
                strToEmail = strToEmail + ','+objUser.Email;
        }
        String[] toAddresses;
        if(strToEmail !=null)
            toAddresses = strToEmail.split(',');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Integration Support');
        mail.setSubject('Needs your attention: Staging record deletion');
        
        string mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>'+batchName+'</b> batch. ' +failedRecords+ ' records could not be deleted from <b>'+objectName+'</b> object. <br/><br/>To view these records, go to <b>'+tabName+'</b> tab. <b>Is Deleted</b> checkbox will be checked against these records.<br /><br/>Number of successfully deleted records: '+deletedRecords+'</br> Number of failed records: '+failedRecords;
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        mail.HtmlBody= mailHtmlBody+ signature;
        
        System.debug('Complete Html Body >>>'+mailHtmlBody);
		if(!Test.isRunningTest())
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
    
    public static Account generateNewFamilyOnFamilyChange(Edelweiss_Clients_Staging_Container__c objStaging, Map<String, User> mapFaCxoUser)
    {
        Account newFamilyOnFamilyChange = new Account();
        // Generate Family record type based on the data availbale in Client Data Integration.
        newFamilyOnFamilyChange.Name =objStaging.Family_Name__c;
        newFamilyOnFamilyChange.GWM_Online_Id__c =objStaging.GWM_Online_Family_Id__c;
        newFamilyOnFamilyChange.RecordTypeId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
        newFamilyOnFamilyChange.Coverage__c=EdelweissConstants.FAMILY_CLIENT_R3_STATUS;
        newFamilyOnFamilyChange.Nationality__c=objStaging.Nationality__c;
        
        //Focus_30_Client__c
        if(objStaging.Focus_30_Client__c == '1')
            newFamilyOnFamilyChange.Focus_30__c=true;
        else if(objStaging.Focus_30_Client__c == '0')
            newFamilyOnFamilyChange.Focus_30__c=false;
        
        //High_Priority_Client__c
        if(objStaging.High_Priority_Client__c == '1')
            newFamilyOnFamilyChange.High_Priority__c=true;
        else if(objStaging.High_Priority_Client__c == '0')
            newFamilyOnFamilyChange.High_Priority__c=false;
        
        // collect Fa user salesforce id 
        string strFaUniqueId = objStaging.Primary_FA_Employee_Id__c+ objStaging.Primary_FA_Miles_Id__c;
        string strCxoUniqueId = objStaging.Primary_CXO_Employee_Id__c+ objStaging.Primary_CXO_Miles_Id__c;
        
        if(mapFaCxoUser.get(strFaUniqueId) !=null)
            newFamilyOnFamilyChange.Primary_FA__c=mapFaCxoUser.get(strFaUniqueId).Id;
        
        if(mapFaCxoUser.get(strCxoUniqueId) !=null)
            newFamilyOnFamilyChange.Primary_CXO__c =mapFaCxoUser.get(strCxoUniqueId).Id;
        
        //Assign Rollup Family AUM to Zero at the time of family creation
        newFamilyOnFamilyChange.Rollup_AUM_of_Family__c =Integer.ValueOf(0);
        newFamilyOnFamilyChange.Family_Networth__c =Integer.ValueOf(0);    
             
        newFamilyOnFamilyChange.MilesActivationDate__c=objStaging.Miles_Activation_Date__c;
       
        newFamilyOnFamilyChange.Backoffice_Code_NBFC__c =objStaging.Backoffice_Code_NBFC__c;       
        
        
        return newFamilyOnFamilyChange;
    }
    public static List<Account> updateFamilyAUMBatch(List<Client_Asset_Information__c>clientInfoList)
    {
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        Map<Id,List<Client_Asset_Information__c>>familyIdClientAssetInfolistMap = new Map<Id,List<Client_Asset_Information__c>>(); 
        
        List<Account>updatedFamilyList = new List<Account>();
        List<Client_Asset_Information__c>tempClientAssetInfoList;
        Set<Id>familyIdSet = new Set<Id>();

        Map<Id,Account>familyIdObjMap = new Map<Id,Account>();

        List<Account>familyList = new List<Account>();

        for(Client_Asset_Information__c clientAssetInfo:clientInfoList){
            if(familyIdClientAssetInfolistMap!=null && familyIdClientAssetInfolistMap.size()>0 && 
            familyIdClientAssetInfolistMap.containsKey(clientAssetInfo.Family__c))
            {
                tempClientAssetInfoList = familyIdClientAssetInfolistMap.get(clientAssetInfo.Family__c);
                tempClientAssetInfoList.add(clientAssetInfo);
                familyIdClientAssetInfolistMap.put(clientAssetInfo.Family__c,tempClientAssetInfoList);
            }else{
                tempClientAssetInfoList = new List<Client_Asset_Information__c>();
                tempClientAssetInfoList.add(clientAssetInfo);
                familyIdClientAssetInfolistMap.put(clientAssetInfo.Family__c,tempClientAssetInfoList);
            }
            familyIdSet.add(clientAssetInfo.Family__c);
        }
        

        if(familyIdSet!=null && familyIdSet.size()>0){
            familyList = [SELECT Rollup_AUM_of_Family__c, RecordTypeId, Id,Asset_Classes_Client_is_Interested_in__c,Asset_Classes_Count__c,Family_Networth__c  FROM Account  
                     WHERE 
                     RecordTypeId =:familyRecordTypeId 
                     AND Id IN: familyIdSet FOR UPDATE];
        }

        for(Account family:familyList){
            familyIdObjMap.put(family.Id,family);
        
        }
        for(Id familyId: familyIdClientAssetInfolistMap.keySet()){
            Account familyObj;
            if(familyIdObjMap!=null && !familyIdObjMap.isEmpty() && familyIdObjMap.containsKey(familyId)){
                familyObj = familyIdObjMap.get(familyId);
                system.debug('in if part=familyObj =='+familyObj );
            }
            else{
                system.debug('in else part===');
                familyObj = new Account(Id = familyId);
            }
            // Check is Family having Rollup AUM = 0 or not
            Double totalAUM = 0.0;
            Double familyNetworth=0.0;
            Decimal AssetClassCOUNT = 0;
            String AssetClassList ='';
            if(familyIdObjMap.get(familyId) !=null)            
            {
                system.debug('Existing family AUM>>>>'+familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c);
                
                if(familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c !=null && familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c != 0 )
                {
                    totalAUM = familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c ;
                    AssetClassCOUNT = familyIdObjMap.get(familyId).Asset_Classes_Count__c ;
                    AssetClassList = familyIdObjMap.get(familyId).Asset_Classes_Client_is_Interested_in__c;
                }
                
                if(familyIdObjMap.get(familyId).Family_Networth__c !=null && familyIdObjMap.get(familyId).Family_Networth__c != 0 )
                {
                	familyNetworth=familyIdObjMap.get(familyId).Family_Networth__c;
                }
            }          
            system.debug('Total AUM of existing Family = '+totalAUM );
            system.debug(' familyIdClientAssetInfolistMap.get(familyId)>>'+familyIdClientAssetInfolistMap.get(familyId));
            Date AUMDATE;
            for(Client_Asset_Information__c clientAssetInfoObj: familyIdClientAssetInfolistMap.get(familyId)){
                
                if(clientAssetInfoObj.Total_AUM__c!=null){
                system.debug('AUM =='+totalAUM+',ClientInfoAUM='+clientAssetInfoObj.Total_AUM__c);
                    totalAUM = totalAUM+clientAssetInfoObj.Total_AUM__c;  
                    if(!AssetClassList.contains(clientAssetInfoObj.Asset_Class__c))
                    {
                        AssetClassList = AssetClassList + ';'+clientAssetInfoObj.Asset_Class__c;
                        AssetClassCOUNT =AssetClassCOUNT +1;
                    }
                    if(clientAssetInfoObj.AS_On_Date__c!=null )
                    {
                        AUMDATE =clientAssetInfoObj.AS_On_Date__c;
                    }
                }
                
                if(clientAssetInfoObj.Networth__c !=null)
                {
                	familyNetworth=familyNetworth+clientAssetInfoObj.Networth__c;
                }
                
            }
            system.debug('totalAUMfor update on existing Family>>>'+totalAUM);
            familyObj.Rollup_AUM_of_Family__c = totalAUM;
            familyObj.Family_Networth__c=familyNetworth;
            familyObj.AUM_As_on_Date_Family__c = AUMDATE;
            familyObj.Asset_Classes_Count__c = AssetClassCOUNT;
            familyObj.Asset_Classes_Client_is_Interested_in__c = AssetClassList;
            familyObj.Bypass_Validation__c = true;
            system.debug('familyObj.Rollup_AUM_of_Family__c======'+familyObj.Rollup_AUM_of_Family__c);
            system.debug('familyObj.AUM_As_on_Date_Family__c ======'+familyObj.AUM_As_on_Date_Family__c );
            if(familyObj.RecordTypeId == familyRecordTypeId)
                updatedFamilyList.add(familyObj);
        }
       
        System.debug('DildarLog: updatedFamilyList - ' + updatedFamilyList);
        System.debug('DildarLog: updatedFamilyList - ' + updatedFamilyList.size());
        if(updatedFamilyList!=null && updatedFamilyList.size()>0){
            return updatedFamilyList;
        }else{
            return null;
        }
    }
    
    /* public static void setDueDates(List<Account>accountList){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>familyList = new List<Account>();
        Set<Id> familyIdSet = new Set<Id>();
        
        system.debug('=========familyList size===='+familyList.size());
        if(accountList!=null && accountList.size()>0){
            setinPersonMeetingDate(accountList);
            setRH_BHMeetingDate(accountList);
            setInterationDate(accountList);
            setPortfolioDate(accountList);
        }
        
    }*/
    
    public static void setinPersonMeetingDate(Map<Id,Account> mapFamilyRecord){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:mapFamilyRecord.values()){
           // updatedFamilyObj = new Account(id=familyobj.id);
            Integer criteriaNumber  = checkCriteria(familyobj);
            String criteriaName;
            if(criteriaNumber == 1){
                system.debug('=====In Criteria 1');
                criteriaName = system.Label.InPersonMeeting_Criteria1;
            }
            if(criteriaNumber == 2){
                system.debug('=====In Criteria 2');
                criteriaName = system.Label.InPersonMeeting_Criteria2;
            }
            if(criteriaNumber == 3){
                system.debug('=====In Criteria 3');
                criteriaName = system.Label.InPersonMeeting_Criteria3;
            }
            isChange = false;
            system.debug('================criteriaName'+criteriaName);
            if(criteriaName!= '' && criteriaName!= null){
                familyobj.Communication_Criteria_Number__c = criteriaNumber ;
                    getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,familyobj,false,familyobj.InPersonMeeting_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,familyobj,false,familyobj.In_Person_Meeting_End_Date__c);
                    isChange = true;
                    System.debug('DildarLog: 0');
            }
            if(isChange ){
                familyobj.ClientAssetInformationUpdateCompleted__c = false;
                mapFamilyRecord.put(familyobj.id,familyobj);
            }
        }
        
    } 
    public static void setRH_BHMeetingDate(Map<Id,Account> mapFamilyRecord){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:mapFamilyRecord.values()){
            //updatedFamilyObj = new Account(id=familyobj.id);
            Integer criteriaNumber  = checkCriteria(familyobj);
            String criteriaName;
            
            if(criteriaNumber == 2){
                system.debug('=====In Criteria 2');
                criteriaName = system.Label.RH_BH_Criteria_2;
            }
            if(criteriaNumber == 3){
                system.debug('=====In Criteria 3');
                criteriaName = system.Label.RH_BH_Criteria_3;
            }
            isChange = false;
            system.debug('================criteriaName'+criteriaName);
            if(criteriaName!= '' && criteriaName!= null){
                familyobj.Communication_Criteria_Number__c = criteriaNumber ;
                    getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,familyobj,false,familyobj.RH_BH_Meeting_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,familyobj,false,familyobj.RH_BH_Meeting_End_Date__c);
                    isChange = true;
            }
            else
            {
            
                familyobj.Portfolio_Review_End_Date__c=null; familyobj.Portfolio_Review_Due_Date__c=null;
                System.debug('familyobj='+familyobj);
                isChange =true;
            }
            
            if(isChange ){
                familyobj.ClientAssetInformationUpdateCompleted__c = false;
                mapFamilyRecord.put(familyobj.id,familyobj);
            }
        }
        
    }
    public static void setInterationDate(Map<Id,Account> mapFamilyRecord){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:mapFamilyRecord.values()){
            //updatedFamilyObj = new Account(id=familyobj.id);
            Integer criteriaNumber  = checkCriteria(familyobj);
            String criteriaName;
            if(criteriaNumber == 1){
                system.debug('=====In Criteria 1');
                criteriaName = system.Label.Interaction_Criteria1;
            }
            if(criteriaNumber == 2){
                system.debug('=====In Criteria 2');
                criteriaName = system.Label.Interaction_Criteria2;
            }
            isChange = false;
            system.debug('================criteriaName'+criteriaName);
            if(criteriaName!= '' && criteriaName!= null ){
                familyobj.Communication_Criteria_Number__c = criteriaNumber ;
                    getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,familyobj,false,familyobj.Interaction_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,familyobj,false,familyobj.Interaction_End_Date__c);
                    isChange = true;
            }
            if(isChange ){
                familyobj.ClientAssetInformationUpdateCompleted__c = false;
                 mapFamilyRecord.put(familyobj.id,familyobj);
            }
        }
        
    }
    public static void setPortfolioDate(Map<Id,Account> mapFamilyRecord){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:mapFamilyRecord.values()){
            //updatedFamilyObj = new Account(id=familyobj.id);
            Integer criteriaNumber  = checkCriteria(familyobj);
            String criteriaName;
            if(criteriaNumber == 1){
                system.debug('=====In Criteria 1');
                criteriaName = system.Label.Portfolio_Review_Criteria1;
            }
            if(criteriaNumber == 2){
                system.debug('=====In Criteria 2');
                criteriaName = system.Label.Portfolio_Review_Criteria2;
            
            }
            if(criteriaNumber == 3){
                system.debug('=====In Criteria 3');
                criteriaName = system.Label.Portfolio_Review_Criteria3;
            }
            
            isChange = false;
            system.debug('================criteriaName'+criteriaName);
            if(criteriaName!= '' && criteriaName!= null){
                familyobj.Communication_Criteria_Number__c = criteriaNumber ;
                    getNextPortfolioReviewDueDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaName,familyobj,false,familyobj.Portfolio_Review_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaNumber,familyobj,false,familyobj.Portfolio_Review_End_Date__c);
                    isChange = true;
            }
            
            if(isChange ){
                 mapFamilyRecord.put(familyobj.id,familyobj);
                 familyobj.ClientAssetInformationUpdateCompleted__c = false;
            }
        }
        
    }
    /*Set due date for Interaction ,Inperson and RH-BH meeting*/
    public static void getNextDueDate(String calledFrom,String criteriaName,Account clientObj,Boolean isUpdate,Date currentdueDate,Integer notificationCounter){
       system.debug('My Log:=='+criteriaName);
        Meeting_Frequency__c mf = Meeting_Frequency__c.getValues(criteriaName);
        system.debug('mf===='+mf);
        List<String>frequencies = mf.Frequency__c.split(',');
        notificationCounter = notificationCounter+1;
        String freq;
        Date dueDate;
        /*condition fire when span of communication is not complete  */
        if(notificationCounter<frequencies.size()){
            freq = frequencies[notificationCounter];
            List<String>freqArr =  freq.split(':');
            System.debug('DildarLog: freqArr - ' + freqArr);
            System.debug('DildarLog: currentdueDate - ' + currentdueDate);
            if(currentdueDate != null){
                Integer numberOfDays = Date.daysInMonth(currentdueDate.year(), currentdueDate.month());
                if((currentdueDate).day() < Integer.valueOf(freqArr[1])){
                    if(Integer.valueOf(freqArr[1])<=numberOfDays){
                        dueDate = Date.newInstance((currentdueDate).year(), 
                                                   (currentdueDate).month(),
                                                   Integer.valueOf(freqArr[1]));
                        System.debug('DildarLog: dueDate - ' + dueDate);
                        setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
                    }else{
                        dueDate = Date.newInstance((currentdueDate).year(), 
                                                    currentdueDate.month(),
                                                    numberOfDays);
                        System.debug('DildarLog: dueDate - ' + dueDate);
                        setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
                    } 
                }else{
                    Date tempDueDate = (currentdueDate).addMonths(1);
                    dueDate = Date.newInstance(tempDueDate.year(), 
                                               tempDueDate.month(),
                                               Integer.valueOf(freqArr[1]));
                    System.debug('DildarLog: dueDate - ' + dueDate);
                    setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
                }
            }else{
                Date currentDate = system.today();
                system.debug('Current Date===>'+currentDate);
                /*To Check if it is a insert of a record or Family AUM is updated for first time*/
                if(!isUpdate){                
                    Date tempDueDate = currentDate.addMonths(1);
                    dueDate = Date.newInstance(tempDueDate.year(), 
                                               tempDueDate.month(),
                                               Integer.valueOf(freqArr[1]));
                    setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
                }else{
                    Integer numberOfDays = Date.daysInMonth(currentDate.year(),currentDate.month());
                    Integer counter = -1;
                    /*to iterate over all meeting frequiency values for first month only*/
                    for(String tempFreq:frequencies ){
                        counter++;
                        List<String> tempFreqArr = tempFreq.split(':');
                        /*condition to break the loop when number of days in Month is less than frequency value  */
                        /*specifically to handle february month */
                        if(numberOfDays>=Integer.valueOf(tempFreqArr[1]) && Integer.valueOf(tempFreqArr[0]) == 1){
                            /*condition to iterate till we find next due date after todays date or todays date if it is mentioned frequency date*/
                            if(currentDate.day()<=Integer.valueOf(tempFreqArr[1])){
                                dueDate = Date.newInstance(currentDate.year(), 
                                                   currentDate.month(),
                                                   Integer.valueOf(tempFreqArr[1]));
                                setNextDueDate(calledFrom,dueDate,clientObj,counter);
                                break;                  
                            }
                        
                        }else{
                            break; 
                        }
                    }
                    /*set due date as last day of month if current month date is not found in frequency except RH_BH_Meeting */
                    /*In Case of RH-BH it is the same date criteria is changed*/ 
                    if(numberOfDays >= currentDate.day() && dueDate == null && calledFrom != EdelweissConstants.CALLED_FROM_RH_BH_MEETING  ){
                        dueDate = Date.newInstance(currentDate.year(), 
                                                   currentDate.month(),
                                                   numberOfDays);
                        system.debug('Due Date is==='+dueDate);
                        setNextDueDate(calledFrom,dueDate,clientObj,counter);
                                 
                    }
                    
                }
            }
        
        }else{
            /*condition fire when span of communication is complete  */
            /*following code set due date to first frequency date of communication of next month*/
            freq = frequencies[0];
            List<String>freqArr =  freq.split(':');
            currentdueDate = currentdueDate.addMonths(1);
            dueDate = Date.newInstance((currentdueDate).year(), 
                                                   (currentdueDate).month(),
                                                   Integer.valueOf(freqArr[1]));
            setNextDueDate(calledFrom,dueDate,clientObj,0);
        
        }
        /*Set RH_BH due date to current date when Frequency date has been already passed that is 1st of current Month*/
        if(calledFrom == EdelweissConstants.CALLED_FROM_RH_BH_MEETING && dueDate== null ){
            system.debug('=======dueDate ======'+dueDate);
            dueDate = system.Today()+1;
            setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
            
        }
        
        
    }                                                                                                                                        
    public static void getNextPortfolioReviewDueDate(String calledFrom,String criteriaName,Account clientObj,Boolean isUpdate,Date currentdueDate,Integer notificationCounter){
        Meeting_Frequency__c mf = Meeting_Frequency__c.getValues(criteriaName);
        List<String>frequencies = mf.Frequency__c.split(',');
        notificationCounter = notificationCounter+1;
        String freq;
        Integer nuberOfDays;
        Date dueDate;
        if(notificationCounter<frequencies.size()){            
            freq = frequencies[notificationCounter];
            if(currentdueDate != null){
                nuberOfDays = Integer.valueOf(freq);
                dueDate = currentdueDate.addDays(nuberOfDays);
                setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
            }else{
                Date currentDate = system.today();
                system.debug('Current Date===>'+currentDate);
                nuberOfDays = Integer.valueOf(freq);
                dueDate = currentDate.addDays(nuberOfDays);
                setNextDueDate(calledFrom,dueDate,clientObj,notificationCounter);
            }
        }else{
            /*condition fire when span of communication is complete  */
            /*following code set due date to first frequency date of communication of next month*/
            freq = frequencies[0];
            nuberOfDays = Integer.valueOf(freq);
            List<String>freqArr =  freq.split(':');
            dueDate = currentdueDate.addDays(nuberOfDays);
            setNextDueDate(calledFrom,dueDate,clientObj,0);
        
        } 
    }   
    public static void getEndDate(String calledFrom,Integer criteriaNumber,Account clientObj,Boolean isUpdate,Date currentEndDate){
        Date endDate;
        Date currentDate = system.Today();
        system.debug('currentDate before====='+currentDate);
        if(criteriaNumber == 1  ){
            Integer duration;
            if(calledFrom == EdelweissConstants.CALLED_FROM_INPERSON_MEETING){
                duration = 2;
                system.debug('In person meeting condition-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                //duration is in Days for Portfolio Review
                duration = 90;
                system.debug('In portfoilo review condition-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_INTERACTION){
                duration = 1;
                system.debug('In Interaction condition-------------');
            } 
            
            if(!isupdate){
                system.debug('In insert condition------------');
                system.debug('duration=='+duration);
                system.debug('currentDate====='+currentDate);
                Date tempEndDate;
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    tempEndDate = currentDate.addDays(duration);
                
                }else{
                
                    tempEndDate = currentDate.addMonths(duration);
                
                }
                
                system.debug('temDate==='+tempEndDate);
                Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    endDate = tempEndDate;
                
                }else{
                    endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                }
                
                setEndDate(calledFrom,endDate,clientObj);
            }else{
                if(currentEndDate!=null){
                    system.debug('In end date regular update--------');
                    Date tempEndDate;
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentEndDate.addDays(duration);
                    
                    }else{
                    
                        tempEndDate = currentEndDate.addMonths(duration);
                    
                    }
                    
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    
                        endDate = tempEndDate;
                    }else{
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }else{
                    system.debug('In end date on update condition =============');
                    Date tempEndDate;
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentDate.addDays(duration);
                    
                    }else{
                    
                        tempEndDate = currentDate.addMonths(duration-1);
                    
                    }
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    
                        endDate = tempEndDate;
                    }else{
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }
            }
        }
        system.debug('Criteria No='+ criteriaNumber);
        
        if(criteriaNumber == 2){
            Integer duration;
            if(calledFrom == EdelweissConstants.CALLED_FROM_INPERSON_MEETING){
                duration = 1;
                system.debug('In person meeting condition 2-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                //duration is in Days for Portfolio Review
                duration = 90;
                system.debug('In portfoilo review condition 2-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_INTERACTION){
                duration = 1;
                system.debug('In Interaction condition 2-------------');
            } 
            if(calledFrom == EdelweissConstants.CALLED_FROM_RH_BH_MEETING){
                duration = 6;
                system.debug('In Interaction condition-------------');
            }
            if(!isupdate){
                system.debug('In insert condition 2------------');
                Date tempEndDate;
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    tempEndDate = currentDate.addDays(duration);
                
                }else{
                
                    tempEndDate = currentDate.addMonths(duration);
                
                }
                
                Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    
                    endDate = tempEndDate;
                }else{
                    
                    endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                
                }
                
                setEndDate(calledFrom,endDate,clientObj);
            }else{
                if(currentEndDate!=null){
                    system.debug('In end date regular update 2--------');
                    Date tempEndDate;
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentEndDate.addDays(duration);
                    }else{
                    
                        tempEndDate = currentEndDate.addMonths(duration);
                    
                    }
                    
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        endDate = tempEndDate;
                    
                    }else{
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }else{
                    system.debug('In end date on update condition 2 =============');
                    Date tempEndDate;
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentDate.addDays(duration);
                    
                    }else{
                    
                        tempEndDate = currentDate.addMonths(duration-1);
                    
                    }
                   
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        endDate = tempEndDate;
                    
                    }else{
                    
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }
            }
        }
        if(criteriaNumber == 3){
            Integer duration;
            if(calledFrom == EdelweissConstants.CALLED_FROM_INPERSON_MEETING){
                duration = 1;
                system.debug('In person meeting condition 3-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                //duration is in Days for Portfolio Review for other it is in months
                duration = 30;
                system.debug('In portfoilo review condition 3-------------');
            }
            if(calledFrom == EdelweissConstants.CALLED_FROM_RH_BH_MEETING){
                duration = 2;
                system.debug('In Interaction condition-------------');
            }
            if(!isupdate){
                system.debug('In insert condition 3------------');
                Date tempEndDate;
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentDate.addDays(duration);
                }else{
                    
                    tempEndDate = currentDate.addMonths(duration);
                    
                }
                
                Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    
                    endDate = tempEndDate;
                }else{
                    endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    
                }
                
                setEndDate(calledFrom,endDate,clientObj);
            }else{
                if(currentEndDate!=null){
                    system.debug('In end date regular update 3--------');
                    Date tempEndDate;
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentEndDate.addDays(duration);
                    }else{
                        
                        tempEndDate = currentEndDate.addMonths(duration);
                        
                    }
                    
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                    
                        endDate = tempEndDate;
                    }else{
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }else{
                    currentDate = system.Today();
                    system.debug('In end date on update condition 3============='+currentDate);
                    system.debug('In end date on update condition 3 (duration-1)============='+(duration-1));
                    Date tempEndDate;
                    
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        tempEndDate = currentDate.addDays(duration);
                    }else{
                        
                        tempEndDate = currentDate.addMonths(duration-1);
                        
                    }
                    Integer numberOfDays = Date.daysInMonth(tempEndDate.year(), tempEndDate.month());                    
                    if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
                        endDate = tempEndDate;
                    }else{
                        endDate = Date.newInstance(tempEndDate.year(), tempEndDate.month(), numberOfDays);
                    
                    }
                    
                    setEndDate(calledFrom,endDate,clientObj);
                }
            }
        }
        
    }
    public static void setEndDate(String calledFrom,Date endDate,Account clientObj){
        if(calledFrom == EdelweissConstants.CALLED_FROM_INPERSON_MEETING){
            clientObj.In_Person_Meeting_End_Date__c = endDate;
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
            clientObj.Portfolio_Review_End_Date__c = endDate;
        
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_INTERACTION){
            clientObj.Interaction_End_Date__c = endDate;
        
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_RH_BH_MEETING){
            clientObj.RH_BH_Meeting_End_Date__c = endDate;
        
        }
    }
    public static void setNextDueDate(String calledFrom,Date dueDate,Account clientObj,Integer Counter){
        if(calledFrom == EdelweissConstants.CALLED_FROM_INPERSON_MEETING){
            clientObj.InPersonMeeting_Due_Date__c = dueDate;
            clientObj.inPersonNotificationCounter__c = counter;
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW){
            clientObj.Portfolio_Review_Due_Date__c = dueDate;
            clientObj.PortfolioReviewNotificationCounter__c = counter;
        
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_INTERACTION){
            clientObj.Interaction_Due_Date__c = dueDate;
            clientObj.InteractionNotificationCounter__c = counter;
        
        }
        if(calledFrom == EdelweissConstants.CALLED_FROM_RH_BH_MEETING){
            clientObj.RH_BH_Meeting_Due_Date__c = dueDate;
            clientObj.RH_BH_Notification_Counter__c = counter;
        
        }
    
    }
    
    public static Integer checkCriteria(Account clientobj){
        Integer creiteriaNumber = 1;

        if(clientobj != null){
            if(clientobj.Total_AUM_INR_Cr__c>=50  || 
               clientobj.Coverage__c == 'R5'||
               clientobj.High_Priority__c||
               clientobj.Focus_30__c || clientobj.Mandate__c ||(clientobj.Total_AUM_INR_Cr__c>25 && clientobj.Share_of_Wallet_For_Client__c>=30)){
                creiteriaNumber = 3;
                system.debug('========In FirstLoop======');
             }else{
                if((clientobj.Total_AUM_INR_Cr__c>=20 && clientobj.Total_AUM_INR_Cr__c<50 ) || 
                   clientobj.Total_AUM_INR_Cr__c>5 || clientobj.Coverage__c == 'R4'){
                    creiteriaNumber = 2;
                    system.debug('========In Second Loop======');
                 }else{
                    if(clientobj.Total_AUM_INR_Cr__c<20 || clientobj.Coverage__c == 'R3'){                
                        creiteriaNumber = 1;
                        system.debug('========In Third======');
                     }
                 }
             }
           }
         return creiteriaNumber;
    }

    public static void changeStatusToR4(Map<Id,Account> mapFamilyRecord){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>updatedAccountList = new List<Account>();
        for(Account accountObj:mapFamilyRecord.values()){
            if(accountObj.RecordTypeId == familyRecordTypeId && accountObj.Coverage__c == 'R3' && accountObj.Total_AUM_INR_Cr__c > 5 ){
                accountObj.Coverage__c = 'R4';
                mapFamilyRecord.put(accountObj.id,accountObj);
            }
        }
    }

    /*Replacement of Workflow "Update Family Coverage to R5"*/
    /*
    public static void changeStatusToR5(Map<Id,Account> mapFamilyRecord){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>updatedAccountList = new List<Account>();

        for(Account accountObj:mapFamilyRecord.values()){
            if(accountObj.RecordTypeId ==familyRecordTypeId && accountObj.Total_AUM_INR_Cr__c !=NULL && accountObj.Total_AUM_INR_Cr__c !=0 )
            {
            	if(accountObj.Mandate__c == true && accountObj.Total_AUM_INR_Cr__c > 25 ){
                    accountObj.Coverage__c = 'R5';
                    mapFamilyRecord.put(accountObj.id,accountObj);
                }
                else if(accountObj.Investible_Assets__c!=NULL && accountObj.Investible_Assets__c !=0){
                    if((accountObj.Total_AUM_INR_Cr__c > 25 && accountObj.Share_Of_Wallet_for_Family__c >= 30)){
                        accountObj.Coverage__c = 'R5';
                        mapFamilyRecord.put(accountObj.id,accountObj);
                
                    }
                }
            }
        }
    }
    */
    
    public static void createUserContact(){
        
        Id leadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        Id ContactRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Edelweiss User').getRecordTypeId();
        
        //Create Edelweiss User Contact Account
        List<Account> lstAccount = [
            SELECT Id, Name FROM Account WHERE Name='Edelweiss User Contact Account' AND RecordTypeId = :leadRecordTypeId LIMIT 1
        ]; 
        
        IF(lstAccount.isEmpty()){
            Account objAcc = new Account(Name='Edelweiss User Contact Account', RecordTypeId = leadRecordTypeId, Company__c = 'Don\'t delete this account. This account is being used for Edelweiss User Contacts.');
            lstAccount.add(objAcc);
            insert lstAccount;
        }
        
        //Delete existing Edelwies User contact
        List<Contact> lstExistingContact = [
            SELECT Id, Name FROM Contact WHERE RecordTypeId=:ContactRecordTypeId
        ];
        if(!lstExistingContact.isEmpty()){
            delete lstExistingContact;
        }
        
        //Create new Edelweiss User contact for active users
        List<Contact> lstContact = new List<Contact>();
        List<User> lstUser = [
            SELECT Id, Name, FirstName, LastName, Zone__c, Email, Phone 
            FROM User WHERE isActive = true
        ];
        
        for(User objUser : lstUser){
            Contact objContact = new Contact();
            objContact.RecordTypeId = ContactRecordTypeId;
            objContact.OwnerId = objUser.Id;
            objContact.FirstName = objUser.FirstName;
            objContact.LastName = objUser.LastName;
            objContact.Email = objUser.Email;
            objContact.AccountId = lstAccount[0].Id;
            
            lstContact.add(objContact);
        }
        if(!lstContact.isEmpty()){
            System.debug('Contact Inserted <><>< '+lstContact);
            insert lstContact;
        }

    }
    
    public static List<Contact> generateAdditionalClientContact(Map<String, Account> mapGwmIdNewCreatedClient,
		Map<String, Additional_Lead__c> mapPan_AdditionalLeadRecord, Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord)
    {
        list<Contact> listAdditionalClientContact = new List<Contact>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        
        for(Account newClient: mapGwmIdNewCreatedClient.values())
        {
            
            // create Client Account only when newly create Client is there...
			Edelweiss_Clients_Staging_Container__c stagingRecord = mapPanClientStagingRecord.get(newClient.Pan_Number__c);
			Additional_Lead__c objAdditionalLead = mapPan_AdditionalLeadRecord.get(stagingRecord.PAN_Number__c);
            
            if(stagingRecord !=Null && objAdditionalLead != Null && mapGwmIdNewCreatedClient.containsKey(stagingRecord.GWM_Online_Client_Id__c))
            {
                try
                {
                    Contact objAdditionalClientContact = new Contact();
                    objAdditionalClientContact.Mobile_1__c = objAdditionalLead.Mobile__c;
                    objAdditionalClientContact.Primary_Email__c	= objAdditionalLead.Email__c;
                    objAdditionalClientContact.RecordTypeId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(EdelweissConstants.EDELWEISS_CONTACT_RECORD_TYPE).getRecordTypeId();
                    objAdditionalClientContact.LastName=stagingRecord.Client_Name__c;
                    objAdditionalClientContact.Gender__c=stagingRecord.Gender__c;                    
                    objAdditionalClientContact.AccountId=newClient.Id;
                    objAdditionalClientContact.OwnerId=newClient.OwnerId;
                    objAdditionalClientContact.Is_Primary_Contact__c=true;                    
                    objAdditionalClientContact.Office_Phone__c=stagingRecord.Office_Number__c;
                    objAdditionalClientContact.Official_Email__c=stagingRecord.Official_Email__c;
                    objAdditionalClientContact.Salutation=stagingRecord.Salutation__c;
                    objAdditionalClientContact.Nationality__c=stagingRecord.Nationality__c;
                    objAdditionalClientContact.Official_Email__c=stagingRecord.Official_Email__c;
                    
                    // accept only "YYY-mm-dd" format of date field
                    if(stagingRecord.Date_of_Birth__c != null)
                        objAdditionalClientContact.Birth_Date__c=Date.valueOf(stagingRecord.Date_of_Birth__c);
                    
                    if(stagingRecord.Anniversary_Date__c !=null)
                        objAdditionalClientContact.Wedding_Anniversary__c=Date.valueOf(stagingRecord.Anniversary_Date__c );
                    
                    listAdditionalClientContact.add(objAdditionalClientContact);
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateAdditionalClientContactRecords(); Client PAN Card : '+newClient.Pan_Number__c);
                    listError.add(objError);
                }
            }
        }
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        
        return listAdditionalClientContact;
    }
    
    // Generate Client Account record for object : Client_Account__c.
    public static List<Client_Account__c> generateAdditionalClientAccountRecords( Map<String, Account> mapGwmIdNewCreatedClient, 
                                    Map<String, Edelweiss_Clients_Staging_Container__c> mapPanClientStagingRecord)
    {
        List<Client_Account__c> listAdditionalClientAccount = new List<Client_Account__c>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        List<Edelweiss_Clients_Staging_Container__c> lstErrorStagingRecords = new List<Edelweiss_Clients_Staging_Container__c>();
        
        for(Account newClient : mapGwmIdNewCreatedClient.values())
        {
            Edelweiss_Clients_Staging_Container__c stagingRecord = mapPanClientStagingRecord.get(newClient.Pan_Number__c);
            
            // create Client Account only when newly create Client is there...
            if(stagingRecord !=Null && mapGwmIdNewCreatedClient.containsKey(stagingRecord.GWM_Online_Client_Id__c))
            {
                try
                {
                    // generate Client record
                    Client_Account__c objAdditionalClientAccount = new Client_Account__c();
                    objAdditionalClientAccount.PAN_Number__c=newClient.PAN_Number__c;
                    objAdditionalClientAccount.Client__c=newClient.Id;
                    objAdditionalClientAccount.Name =stagingRecord.Account_Name__c;
                    objAdditionalClientAccount.GWM_Client_Account_Id__c=stagingRecord.GWM_Online_Account_Id__c;
                    objAdditionalClientAccount.Gender__c=stagingRecord.Gender__c;
                    objAdditionalClientAccount.Account_type__c=stagingRecord.Account_type__c;
                    
                    if(stagingRecord.Date_of_Birth__c != null){
                        objAdditionalClientAccount.Date_of_Birth__c=Date.valueOf(stagingRecord.Date_of_Birth__c);
                    }
                    
                    //add family record in list
                    listAdditionalClientAccount.add(objAdditionalClientAccount);
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+newClient.PAN_Number__c);
                    listError.add(objError);
                    Edelweiss_Clients_Staging_Container__c edlClient = mapPanClientStagingRecord.get(newClient.PAN_Number__c);
                    edlClient.synch__c = false;
                    edlClient.ErrorMessage__c =  'Class : Edelweiss_Integration_Utility; Function : generateAdditionalClientAccountRecords(); Client PAN Card : '+newClient.PAN_Number__c + ex.getMessage();
                    lstErrorStagingRecords.add(edlClient);
                }
            }
        }
        
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        if(!lstErrorStagingRecords.isEmpty()){
            update lstErrorStagingRecords;
        }
        
        system.debug('Integration_Helper::generateAdditionalClientAccountRecords()::listAdditionalClientAccount>>> '+listAdditionalClientAccount);
        return listAdditionalClientAccount;
    }
    
    // generate Client record for Account object.
    // Function checks existing Family, if not create new Family.    

    public static List<Account> generateAdditionalClientRecords(List<Edelweiss_Clients_Staging_Container__c> listBatchRecords, 
        Map<String, Additional_Lead__c> mapPan_AdditionalLeadRecord, Map<String, Account> mapGWMId_FamilyId, Map<String, User> mapFaCxoUser)
    {
        List<Account> lstNewClients = new List<Account>();
        List<Edelweiss_Error_Log__c > listError = new List<Edelweiss_Error_Log__c >();
        List<Edelweiss_Clients_Staging_Container__c> lstErrorStagingRecords = new List<Edelweiss_Clients_Staging_Container__c>();
        
     	for(Edelweiss_Clients_Staging_Container__c stgRecord : listBatchRecords){
            Additional_Lead__c objAdditionalLead = mapPan_AdditionalLeadRecord.get(stgRecord.PAN_Number__c);
            if(objAdditionalLead != null && !stgRecord.Rejected__c){
                try
                {
                    Account clientRecord = new Account();
                    clientRecord.Phone = objAdditionalLead.Mobile__c;
                    clientRecord.Mobile_1__c = objAdditionalLead.Mobile__c;
                    clientRecord.Primary_Email__c = objAdditionalLead.Email__c;
                    clientRecord.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
                    clientRecord.Name = stgRecord.Client_Name__c;
                    clientRecord.IPS_Done__c = 'No';
                    clientRecord.Coverage__c = 'R3';
                    clientRecord.GWM_Online_Id__c = stgRecord.GWM_Online_Client_Id__c;
                    clientRecord.Focus_30__c = stgRecord.Focus_30_Client__c == '1' ? true : false;
                    clientRecord.High_Priority__c = stgRecord.High_Priority_Client__c == '1' ? true : false;
                    clientRecord.Anniversary_Date__c = stgRecord.Anniversary_Date__c;
                    clientRecord.POA__c = stgRecord.POA__c;
                    clientRecord.Sub_Lob__c = stgRecord.Sub_Lob__c ;
                    clientRecord.PAN_Number__c=stgRecord.PAN_Number__c;
                    clientRecord.Nationality__c=stgRecord.Nationality__c;
                    clientRecord.MilesActivationDate__c=stgRecord.Miles_Activation_Date__c;
                    clientRecord.Mandate__c=stgRecord.Mandate__c== '1' ? true : false;
                    clientRecord.ParentId =mapGWMId_FamilyId.get(stgRecord.GWM_Online_Family_Id__c).Id;

                    // collect Fa user salesforce id 
                    string strFaUniqueId = stgRecord.Primary_FA_Employee_Id__c + stgRecord.Primary_FA_Miles_Id__c;
                    string strCxoUniqueId = stgRecord.Primary_CXO_Employee_Id__c + stgRecord.Primary_CXO_Miles_Id__c;
                    
                    if(mapFaCxoUser.get(strFaUniqueId) != null){
                        clientRecord.Primary_FA__c=mapFaCxoUser.get(strFaUniqueId).Id;
                        clientRecord.OwnerId=mapFaCxoUser.get(strFaUniqueId).Id;
                    }
                    if(mapFaCxoUser.get(strCxoUniqueId) !=null){
                        clientRecord.Primary_CXO__c =mapFaCxoUser.get(strCxoUniqueId).Id;
                    }
                    If(stgRecord.Date_of_Birth__c !=null){
                        clientRecord.Date_of_Birth__c=Date.valueOf(stgRecord.Date_of_Birth__c) ;
                    }
                    if(stgRecord.Office_Number__c != null){
                        clientRecord.Office_Phone_Number__c = stgRecord.Office_Number__c;
                    }
                    if(!String.isBlank(stgRecord.Gender__c)){
                        clientRecord.Gender__c = stgRecord.Gender__c;
                    }
                    
                    lstNewClients.add(clientRecord);
                }
                catch(exception ex)
                {
                    Edelweiss_Error_Log__c objError = Edelweiss_ErrorLogging_Utility.generateGenericException(ex, 'Class : Edelweiss_Integration_Utility; Function : generateAdditionalClientRecords(); Client PAN Card : '+stgRecord.PAN_Number__c);
                    listError.add(objError);
                    Edelweiss_Clients_Staging_Container__c edlClient = stgRecord;
                    edlClient.synch__c = false;
                    edlClient.ErrorMessage__c =  'Class : Edelweiss_Integration_Utility; Function : generateFamilyAndClientRecords(); Client PAN Card : '+stgRecord.PAN_Number__c + ex.getMessage();
                    lstErrorStagingRecords.add(edlClient);
                }
            }
        }
        
     
        // insert error log:
        if(listError != null)
        {
            database.insert(listError);
        }
        if(!lstErrorStagingRecords.isEmpty()){
            update lstErrorStagingRecords;
        }
        
        system.debug('Integration_Helper::generateAdditionalClientRecords()::lstNewClients >>> '+lstNewClients);
        return lstNewClients;
    }

}