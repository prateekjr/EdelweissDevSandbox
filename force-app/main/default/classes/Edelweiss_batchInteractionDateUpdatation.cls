global class Edelweiss_batchInteractionDateUpdatation implements Database.Batchable<sObject>, Database.Stateful {
    global String strQuery;
    global Edelweiss_batchInteractionDateUpdatation(){
        //strQuery = 'SELECT Id, Name,Last_In_Person_Meeting_Date__c,Last_Interraction_Date_Phone_InPerson__c ,(SELECT Id , EndDateTime ,  Type_of_Communication__c FROM ActivityHistories where EndDateTime != null AND (Type_of_Communication__c = \'In-Person\' OR Type_of_Communication__c = \'Phone\') )FROM Account where recordtype.name = \'Family\'';
        strQuery = 'SELECT Id, OwnerId, Name, Last_In_Person_Meeting_Date__c, Last_Interraction_Date_Phone_InPerson__c ,(SELECT Id , OwnerId, EndDateTime , Activity_Creator_Profile__c, Type_of_Communication__c FROM ActivityHistories where EndDateTime != null AND (Type_of_Communication__c = \'In-Person\' OR Type_of_Communication__c = \'Phone\') )FROM Account where recordtype.name = \'Family\' AND Is_Family_Without_Client__c=false';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> listOfAccounts) {
        List<Account> tobeUpdated = new List<Account>();   
        for(Account a : listOfAccounts){
            Date MaxInPersonDate;
            Date MaxPhoneDate;
            List<ActivityHistory> ah  = a.ActivityHistories;
            List<Date> AllInPersonDates = new List<Date>(); 
            List<Date> AllInPhoneDates = new List<Date>(); 
            for(ActivityHistory Activity : ah){
                if(a.OwnerId == Activity.OwnerId){
                    Date myDate = date.newinstance(Activity.EndDateTime.year(), Activity.EndDateTime.month(), Activity.EndDateTime.day());
                    if(Activity.Type_of_Communication__c == 'In-Person'){
                        AllInPersonDates.add(myDate);
                    }
                    if(Activity.Type_of_Communication__c == 'Phone'){
                        AllInPhoneDates.add(myDate);
                    }
                }
            }      
            if(!AllInPersonDates.isEmpty()){
                AllInPersonDates.sort();
                MaxInPersonDate = AllInPersonDates[AllInPersonDates.size()-1];
            }
            if(!AllInPhoneDates.isEmpty()){
                AllInPhoneDates.sort();
                MaxPhoneDate = AllInPhoneDates[AllInPhoneDates.size()-1];
            }
            
            if(MaxPhoneDate == null && MaxInPersonDate == null){
                a.Last_In_Person_Meeting_Date__c = null;
                a.Last_Interraction_Date_Phone_InPerson__c = null;
            }
            else{
                if(MaxInPersonDate != null && (a.Last_In_Person_Meeting_Date__c == null || a.Last_In_Person_Meeting_Date__c <= MaxInPersonDate )){
                    a.Last_In_Person_Meeting_Date__c = MaxInPersonDate;
                }else{
                    a.Last_In_Person_Meeting_Date__c = null;
                }
                
                if(MaxInPersonDate != null && MaxPhoneDate != null){
                    if(MaxInPersonDate < MaxPhoneDate){
                        a.Last_Interraction_Date_Phone_InPerson__c = MaxPhoneDate; 
                    }else{
                        a.Last_Interraction_Date_Phone_InPerson__c = MaxInPersonDate;
                    }
                }
                else if(MaxInPersonDate != null){
                    a.Last_Interraction_Date_Phone_InPerson__c = MaxInPersonDate;
                }
                else if(MaxPhoneDate != null){
                    a.Last_Interraction_Date_Phone_InPerson__c = MaxPhoneDate; 
                }
                else{
                    a.Last_Interraction_Date_Phone_InPerson__c = null;
                }
            }
            tobeUpdated.add(a);
        }
        
        update(tobeUpdated);
    }
    global void finish(Database.BatchableContext bcMain){
        
    }
}