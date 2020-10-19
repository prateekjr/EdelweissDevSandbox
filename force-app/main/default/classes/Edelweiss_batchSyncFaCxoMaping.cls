////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 21 FEB 2016
//Description: Apex batch class to check mapping will remain in sync with GWM Online.
// Data loder push FA-CXO maping to this staging container and apex Batch class execute to sync maping in SF CRM.
//@2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_batchSyncFaCxoMaping implements Database.Batchable<sObject> 
{
    global String strQuery;
    global List<FA_CXO_Staging_Container__c> listFaCxoStagingContainerRecords;    
    global Map<String, User> mapFaCxoUser;
    public List<Id> deletedList;
    
    // Class Constructor - set query string
    global Edelweiss_batchSyncFaCxoMaping(List<Id> deletedIds)
    {
        deletedList = deletedIds;
        strQuery = 'SELECT id, CXO_Employee_Id__c, CXO_Miles_Id__c, FA_Employee_Id__c, FA_Miles_Id__c, Mapping_Available_in_CRM__c From FA_CXO_Staging_Container__c where is_Deleted__c != true';        
        
        Sys_Properties__c custSettFaProfileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
        Sys_Properties__c custSettCxoProfileId = Sys_Properties__c.getValues('Profile Client Experience Office Id');
		Sys_Properties__c custSettCxoZonalHeadProfileId = Sys_Properties__c.getValues('Profile CXO Zonal Head Id');
		Sys_Properties__c custSettCxoNationalHeadProfileId = Sys_Properties__c.getValues('Profile CXO National Head Id');
		Sys_Properties__c custSettFaFOIGProfileId = Sys_Properties__c.getValues('Profile Financial Advisor FOIG Id');
		Sys_Properties__c custSettTLAdvoisoryProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory Id');
        Sys_Properties__c custSettTLAdvoisoryFOIGProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory FOIG Id');
		Sys_Properties__c custSettRegionalHeadProfileId = Sys_Properties__c.getValues('Profile Regional Head Id');
		
        Set<Id> setFaCxoId = new Set<Id>();
		if(custSettFaProfileId != null)
			setFaCxoId.add(custSettFaProfileId.Value__c);
        if(custSettCxoProfileId != null)
			setFaCxoId.add(custSettCxoProfileId.Value__c);
		if(custSettCxoZonalHeadProfileId != null)
			setFaCxoId.add(custSettCxoZonalHeadProfileId.Value__c);
		if(custSettCxoNationalHeadProfileId != null)
			setFaCxoId.add(custSettCxoNationalHeadProfileId.Value__c);
		if(custSettFaFOIGProfileId != null)
			setFaCxoId.add(custSettFaFOIGProfileId.Value__c);
        if(custSettTLAdvoisoryProfileId != null)
			setFaCxoId.add(custSettTLAdvoisoryProfileId.Value__c);
        if(custSettTLAdvoisoryFOIGProfileId != null)
			setFaCxoId.add(custSettTLAdvoisoryFOIGProfileId.Value__c);
		if(custSettRegionalHeadProfileId != null)
			setFaCxoId.add(custSettRegionalHeadProfileId.Value__c);
        
        system.debug('setFaCxoId>>'+setFaCxoId);
        // collect all FA & Cxo Profile Users
        mapFaCxoUser = new Map<String, User>();
        For(User objUserFaCxo : [Select Id, Name, Edelweiss_Employee_Id__c, Miles_Id__c From User where ProfileId =:setFaCxoId AND Edelweiss_Employee_Id__c!=null AND Miles_Id__c!=null])
        {
            system.debug('objUserFaCxo>>>'+objUserFaCxo);
            
            if(objUserFaCxo.Edelweiss_Employee_Id__c !=null && objUserFaCxo.Miles_Id__c !=null)
            {
                mapFaCxoUser.put(objUserFaCxo.Edelweiss_Employee_Id__c+objUserFaCxo.Miles_Id__c, objUserFaCxo);
            }
        }
        
        system.debug('in constructor:::: mapFaCxoUser>>'+mapFaCxoUser);
    }
    
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        system.debug('in execute function::: mapFaCxoUser>>'+mapFaCxoUser);
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<FA_CXO_Staging_Container__c> listBatchRecords){
    	try{
            List<FA_CSO_Mapping__c> listFaCxo = Edelweiss_Integration_Utility.generateFaCxoMappingRecordList(listBatchRecords, mapFaCxoUser);
            system.debug('Http Post FA-CXO mapping:: listFaCxo if valid request::'+listFaCxo);         
            if(listFaCxo.size() > 0 && listFaCxo != null)
            	Database.insert(listFaCxo);
            
            // check is there any mapping not available in CRM
            List<FA_CXO_Staging_Container__c> notMatchedFaCxoStaging= Edelweiss_Integration_Utility.checkFaCxoUsersAvailableInCRM(listBatchRecords, mapFaCxoUser);            
            system.debug('notMatchedFaCxoStaging>>>>'+notMatchedFaCxoStaging);
            if(notMatchedFaCxoStaging.size() > 0 && notMatchedFaCxoStaging != null)
            	Database.update(notMatchedFaCxoStaging, false);
                
        }
        catch(DMLException Ex){
        	if(deletedList.size() > 0)
        		Database.undelete(deletedList, true);
        		
	        Sys_Properties__c custSettingToEmailProfile = Sys_Properties__c.getValues('ProfileSendNotification MilesTicket');
            // collect users for profile.
	        List<User> listProfileUsers = Edelweiss_Integration_Utility.getProfileUserList(custSettingToEmailProfile.value__c);
	        String strToEmail;
	        for(User objUser: listProfileUsers ){
	            if(strToEmail==null)
	                strToEmail=objUser.Email;
	            else
	                strToEmail = strToEmail + ','+objUser.Email;
	        }
	        String[] toAddresses;
	        if(strToEmail !=null)
	            toAddresses = strToEmail.split(','); 
	        //add To email
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(toAddresses);
	        mail.setSenderDisplayName('Edeleweiss Integration Support');
	        mail.setSubject('FA-CXO Mapping Batch Execution : '+ system.Today());
	        string mailHtmlBody = '<br /><b>Errors found in FA-CXO mapping process. </b>';
	       
	        String signature = '<br/><br/><br/><b>Edeleweiss Integration Support</b>';
	        mail.HtmlBody= mailHtmlBody + '<br/><br/>' + Ex.getMessage() + signature;
	        System.debug('Complete Html Body >>>'+mailHtmlBody);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        Id jobId = bcMain.getJobID();
	        System.abortJob(jobId);        
        }
    }
    // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain){
       Database.executeBatch(new Edelweiss_batchCloseMilesAccOpenCaseTask());
    }   
}