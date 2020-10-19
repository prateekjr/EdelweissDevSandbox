global class Edelweiss_batchPostAUMFamilyUpdate implements Database.Batchable<sObject>,Database.Stateful  {
    global String strQuery;
    global Id familyRecordTypeId;
    global Id clientRecordTypeId;
    global Map<Id, String> batchErrors {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    public List<Id> InsertedIds;
    global list<Account> lstAccount;
    
    /* Constructor */
    global Edelweiss_batchPostAUMFamilyUpdate(){
        batchErrors = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        InsertedIds = new List<Id>();
        //Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get(EdelweissConstants.FAMILY_RECORD_TYPE);
        strQuery = 'SELECT a.RecordTypeId, a.setRH_BHEndDateRegular__c, a.setRH_BHDueDateRegular__c, a.setPortfolioEndDateRegular__c, a.setPortfolioDueDateRegular__c,a.setInteractionEndDateRegular__c, a.setInteractionDueDateRegular__c, a.Total_AUM_INR_Cr__c,a.setInPersonEndDateRegular__c, a.setInPersonDueDateRegular__c, a.inPersonNotificationCounter__c, a.Rollup_AUM_of_Family__c, a.RH_BH_Meeting_End_Date__c, a.RH_BH_Meeting_Due_Date__c, a.RH_BH_Meeting_Done__c, a.Portfolio_Review_End_Date__c, a.Portfolio_Review_Due_Date__c,a.Portfolio_Review_Done__c, a.PortfolioReviewNotificationCounter__c, a.Mandate__c,  a.Interaction_End_Date__c, a.Interaction_Due_Date__c, a.Interaction_Done__c, a.In_Person_Meeting_End_Date__c, a.In_Person_Meeting_Done__c, a.InPersonMeeting_Due_Date__c,a.InteractionNotificationCounter__c,a.Asset_Classes_Count__c, a.Communication_Criteria_Number__c ,a.High_Priority__c,a.Name, a.Focus_30__c, a.Coverage__c,a.Share_of_Wallet_For_Client__c,a.RH_BH_Notification_Counter__c,a.ClientAssetInformationUpdateCompleted__c,a.Family_Networth__c FROM Account a';
        //mapFamilyRecord = new Map<Id,Account>([Select setRH_BHEndDateRegular__c, setRH_BHDueDateRegular__c, setPortfolioEndDateRegular__c, setPortfolioDueDateRegular__c, setInteractionEndDateRegular__c, setInteractionDueDateRegular__c, setInPersonEndDateRegular__c, setInPersonDueDateRegular__c, inPersonNotificationCounter__c, Share_Of_Wallet_for_Family__c, RH_BH_Notification_Counter__c, RH_BH_Meeting_End_Date__c, RH_BH_Meeting_Due_Date__c, RH_BH_Meeting_Done__c, RH_BH_Meeting_Done_Earlier__c, Portfolio_Review_End_Date__c, Portfolio_Review_Due_Date__c, Portfolio_Review_Done__c, Portfolio_Review_Done_Earlier__c, Portfolio_Details_with_Edelwiess__c, MinutesOfMeeting__c, Interaction_Meeting_Done_Counter__c, Interaction_End_Date__c, Interaction_Due_Date__c, Interaction_Done__c, Interaction_Done_Earlier__c, InpersonMeeting_Done_Earlier__c, In_Person_Meeting_End_Date__c, In_Person_Meeting_Done__c, InPersonMeeting_Due_Date__c, Asset_Classes_Count__c From Account where recordtypeid = :familyRecordTypeId ]);
    }
    
    /* "Start" runs when the class in instanciated */
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bcMain, List<Account> listBatchRecords){
        Map<Id,Account> mapFamilyRecord = new Map<Id,Account>();
        //Edelweiss_Integration_Utility.setDueDates(listBatchRecords);
        lstAccount = listBatchRecords;
        System.debug('Inside execute='+lstAccount );
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
         System.debug('familyRecordTypeId='+familyRecordTypeId );
        for(Account accObj:lstAccount ){
            /*Added "accObj.ClientAssetInformationUpdateCompleted__c == true" condition for Insert condition handling*/
            system.debug('accObj.RecordTypeId='+accObj.RecordTypeId+',familyRecordTypeId '+familyRecordTypeId );
            if(accObj.RecordTypeId == familyRecordTypeId ){
            accObj.InPersonMeeting_Due_Date__c = null;accObj.In_Person_Meeting_End_Date__c=null;
            accObj.Interaction_Due_Date__c = null;accObj.Interaction_End_Date__c= null;
            accObj.RH_BH_Meeting_End_Date__c=null; accObj.RH_BH_Meeting_Due_Date__c=null;
            accObj.Portfolio_Review_End_Date__c=null; accObj.Portfolio_Review_Due_Date__c=null;
            accobj.Bypass_Validation__c=true;
            Integer CriteriaNumber = Edelweiss_Integration_Utility.checkCriteria(accObj);
            if(accObj.Communication_Criteria_Number__c !=CriteriaNumber)
            {
                mapFamilyRecord.put(accObj.Id,accObj);
            }
               // system.debug('mapFamilyRecord11='+mapFamilyRecord);
                //Account newAccountObj = new Account(id= accObj.Id);
                //newAccountObj.ClientAssetInformationUpdateCompleted__c  = false;
                //updatedfamilyList.add(newAccountObj );
            }
        }
        system.debug('mapFamilyRecord='+mapFamilyRecord);
        boolean isFailed =false;
        Edelweiss_Integration_Utility.setinPersonMeetingDate(mapFamilyRecord );
            Edelweiss_Integration_Utility.setRH_BHMeetingDate(mapFamilyRecord );
            Edelweiss_Integration_Utility.setInterationDate(mapFamilyRecord );
            Edelweiss_Integration_Utility.setPortfolioDate(mapFamilyRecord );
            Edelweiss_Integration_Utility.changeStatusToR4(mapFamilyRecord );
            //Edelweiss_Integration_Utility.changeStatusToR5(mapFamilyRecord );
            system.debug('mapFamilyRecordUpdated='+mapFamilyRecord);
             Database.SaveResult[] srList = database.update(mapFamilyRecord.values(),false);
             if(srList.size() > 0 ){
                Integer index = 0; 
                for (Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        
                    }
                    else{
                        // Operation failed, so get all errors
                        isFailed = true;                        
                       
                    }
                    index++;
                }
            }
    }
    global void finish(Database.BatchableContext bcMain){
        AccountTriggerhandler.stopUpdateFamily =true;
        AccountTriggerhandler.stopAccountTrigger = true;
        AccountTriggerhandler.stopSharingRules=true;
    }
}