global class BatchForSendEmail_FamilyInteraction implements Database.Batchable<sObject>{
    
    global final String Query;

    global BatchForSendEmail_FamilyInteraction(){
        List<Id> recordTypeIds = new List<Id>();
        String FamilyId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        
        Query = 'Select Id, Name, Coverage__c, R3_FA_PFReview__c, R4_FA_PFReview__c, R5_FA_PFReview__c, R3_FA_Interaction__c, R4_FA_Interaction__c, R5_FA_Interaction__c, R4_TL_Interaction__c, R5_TL_Interaction__c, Primary_FA__c, Primary_FA__r.Name, Primary_FA__r.Email, Primary_FA__r.Zone__c, How_Often_Does_Client_Monitor_Portfolio__c, R5_ProductManager_Interaction__c, R5_RHBHPH_Interaction__c, Last_FA_PFReview__c, Last_FA_Interaction__c,Last_R5_ProductManager_Interaction__c,Last_R5_RHBHPH_Interaction__c, Last_TL_Interaction__c From Account Where RecordTypeId IN (\''+FamilyId+'\') AND Primary_FA__c != NULL ORDER BY Primary_FA__r.Name, Coverage__c';
        system.debug('--->'+query);
      
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
   
        // Get Quarter_Month_Number,Bi_Annual_Month_Number and Year_End_Month_Number from Metadata.
        List<System_Constant__mdt> sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Quarter_Month_Number'];
        Set<Integer> quarterMonth = new Set<Integer>();     
        for(System_Constant__mdt constant : sysConstant ){
            if(constant.Value__c != null){
                for(String str : constant.Value__c.split(',')){
                    quarterMonth.add(integer.valueof(str));
                }
            }
        }
        
        sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Bi_Monthly_Month_Number'];
        Set<Integer> biMonth = new Set<Integer>();     
        for(System_Constant__mdt constant : sysConstant ){
            if(constant.Value__c != null){
                for(String str : constant.Value__c.split(',')){
                    biMonth.add(integer.valueof(str));
                }
            }
        }
        
        Integer YearEndMonth = 3;
        sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Year_End_Month_Number'];        
        if(sysConstant != null && sysConstant.size() > 0){
            YearEndMonth = integer.valueof(sysConstant[0].Value__c);
        }
        
        Integer BiAnnualMonthNumber = 9;
        sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Bi_Annual_Month_Number'];        
        if(sysConstant != null && sysConstant.size() > 0){
            BiAnnualMonthNumber = integer.valueof(sysConstant[0].Value__c);
        }
        
        //Boolean isR5 = (acc.Coverage__c == 'R5') ? true : false;
        //Boolean isR4 = (acc.Coverage__c == 'R4') ? true : false;
        //Boolean isR3 = (acc.Coverage__c == 'R3') ? true : false;
        
        integer CurrentMonth = date.today().month();
        //IS Quarterly Check  
        if(quarterMonth.contains(CurrentMonth)){ 
        	SendEmail_FamilyInteraction.interactForPFReview(scope);
            SendEmail_FamilyInteraction.familyInteractionForPH(scope);
        } 
        else if (biMonth.contains(CurrentMonth)){ // Bi Monthly
            SendEmail_FamilyInteraction.interactForPFReview(scope);
        }
        // Bi Annually
        if(BiAnnualMonthNumber == CurrentMonth){
            //SendEmail_FamilyInteraction.familyInteractionForTL(scope);
            //SendEmail_FamilyInteraction.familyInteractionForBH_RH_PH(scope);
        }
        //Annually Check
        if(YearEndMonth == CurrentMonth){
            
        }
        // Monthly Check
        if(CurrentMonth != null){
            SendEmail_FamilyInteraction.familyInteractionForFA(scope);
        }
    }

   global void finish(Database.BatchableContext BC){
       Database.executeBatch(new BatchForSendEmail_FamilyInteractionV2(), 2000);
   }
}