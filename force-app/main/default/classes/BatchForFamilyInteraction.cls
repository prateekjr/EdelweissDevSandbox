global class BatchForFamilyInteraction implements Database.Batchable<sObject>{
    
    global final String Query;

   global BatchForFamilyInteraction(){
        List<Id> recordTypeIds = new List<Id>();
        String FamilyId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        //String ClientId =EdelweissConstants.AccountRecordTypeMap.get('Client');
        
        Query = 'Select Id,R4_FA_Interaction__c,Coverage__c,How_Often_Does_Client_Monitor_Portfolio__c, R5_ProductManager_Interaction__c,R5_FA_PFReview__c,R4_FA_PFReview__c,R3_FA_PFReview__c, R5_RHBHPH_Interaction__c, R5_TL_Interaction__c,R4_TL_Interaction__c,Last_FA_PFReview__c,Last_FA_Interaction__c,Last_R5_ProductManager_Interaction__c,Last_R5_RHBHPH_Interaction__c, Last_TL_Interaction__c,R3_FA_Interaction__c,R5_FA_Interaction__c From Account Where RecordTypeId IN (\''+FamilyId+'\')';
        system.debug('--->'+query);
		// IN (\''+FamilyId+'\','+'\''+ClientId+'\')';
      
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('--->'+query);     
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
      // Get Quarter_Month_Number and Year_End_Month_Number from Metadata.
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
        
      
      List<Account> accns = new List<Account>();
      for(sObject s : scope)
       {
            Account acc = (Account)s;
            
            integer CurrentMonth = date.today().month();
            String pfReviewOften = acc.How_Often_Does_Client_Monitor_Portfolio__c ;
			if(string.isBlank(pfReviewOften))
				pfReviewOften = 'Quarterly';
            Boolean isR5 = (acc.Coverage__c == 'R5') ? true : false;
            Boolean isR4 = (acc.Coverage__c == 'R4') ? true : false;
            Boolean isR3 = (acc.Coverage__c == 'R3') ? true : false;
			acc.Last_R5_ProductManager_Interaction__c = false;
			acc.Last_FA_PFReview__c = false;
			acc.Last_TL_Interaction__c = false;
			acc.Last_FA_Interaction__c = false;
			acc.Last_R5_RHBHPH_Interaction__c = false;
        
            //IS Quarterly Check  
            if(quarterMonth.contains(CurrentMonth)){                        
                if(isR5){
                    acc.Last_R5_ProductManager_Interaction__c =acc.R5_ProductManager_Interaction__c;
                    acc.R5_ProductManager_Interaction__c = false; 
                }               
                //FA PF review
                if(pfReviewOften == 'Quarterly'){ 
                    if(isR5) {
                        acc.Last_FA_PFReview__c =acc.R5_FA_PFReview__c;
                        acc.R5_FA_PFReview__c = false;
                    }else if(isR4){
                        acc.Last_FA_PFReview__c =acc.R4_FA_PFReview__c;
                        acc.R4_FA_PFReview__c = false;
                    }else if(isR3){
                        acc.Last_FA_PFReview__c =acc.R3_FA_PFReview__c;
                        acc.R3_FA_PFReview__c = false;
                    } 
                }                
            }
        
           //IS BiMonth Check  
            if(biMonth.contains(CurrentMonth)){                        
                if(isR5){
                    acc.Last_R5_ProductManager_Interaction__c =acc.R5_ProductManager_Interaction__c;
                    acc.R5_ProductManager_Interaction__c = false; 
                }               
                //FA PF review
                if(pfReviewOften == 'Bi-Monthly'){ 
                    if(isR5) {
                        acc.Last_FA_PFReview__c =acc.R5_FA_PFReview__c;
                        acc.R5_FA_PFReview__c = false;
                    }else if(isR4){
                        acc.Last_FA_PFReview__c =acc.R4_FA_PFReview__c;
                        acc.R4_FA_PFReview__c = false;
                    }else if(isR3){
                        acc.Last_FA_PFReview__c =acc.R3_FA_PFReview__c;
                        acc.R3_FA_PFReview__c = false;
                    } 
                }                
            }
           
            //Annually Check
            if(YearEndMonth == CurrentMonth){
                 
                if(pfReviewOften == 'Annually'){
                    if(isR5) {
                        acc.Last_FA_PFReview__c =acc.R5_FA_PFReview__c;
                        acc.R5_FA_PFReview__c = false;
                    }else if(isR4){
                        acc.Last_FA_PFReview__c =acc.R4_FA_PFReview__c;
                        acc.R4_FA_PFReview__c = false;
                    }else if(isR3){
                        acc.Last_FA_PFReview__c =acc.R3_FA_PFReview__c;
                        acc.R3_FA_PFReview__c = false;
                    } 
                }
                acc.IsReview_MINIIPS__c = false;
                acc.IsReview_DetailIPS__c = false;
            }
        
            // Bi Annually
            if(BiAnnualMonthNumber == CurrentMonth){
                
                if(isR5){
                    acc.Last_R5_RHBHPH_Interaction__c =acc.R5_RHBHPH_Interaction__c ;
                    acc.R5_RHBHPH_Interaction__c = false;
                }
                if(isR5){
                    acc.Last_TL_Interaction__c =acc.R5_TL_Interaction__c ;
                    acc.R5_TL_Interaction__c = false;
                }
                if(isR4){
                    acc.Last_TL_Interaction__c =acc.R4_TL_Interaction__c ;
                    acc.R4_TL_Interaction__c = false;
                }
                
                if(pfReviewOften == 'Bi-Annually'){
                    if(isR5) {
                        acc.Last_FA_PFReview__c =acc.R5_FA_PFReview__c;
                        acc.R5_FA_PFReview__c = false;
                    }else if(isR4){
                        acc.Last_FA_PFReview__c =acc.R4_FA_PFReview__c;
                        acc.R4_FA_PFReview__c = false;
                    }else if(isR3){
                        acc.Last_FA_PFReview__c =acc.R3_FA_PFReview__c;
                        acc.R3_FA_PFReview__c = false;
                    } 
                }
            }
        
            // Monthly Check
            if(CurrentMonth != null){               
                if(isR5){
                    acc.Last_FA_Interaction__c = acc.R5_FA_Interaction__c;
                    acc.R5_FA_Interaction__c = false;
                }
                if(isR4){
                    acc.Last_FA_Interaction__c = acc.R4_FA_Interaction__c;
                    acc.R4_FA_Interaction__c = false;
                }
                if(isR3){
                    acc.Last_FA_Interaction__c = acc.R3_FA_Interaction__c;
                    acc.R3_FA_Interaction__c = false;
                }
                
                if(pfReviewOften == 'Monthly'){
                    if(isR5) {
                        acc.Last_FA_PFReview__c =acc.R5_FA_PFReview__c;
                        acc.R5_FA_PFReview__c = false;
                    }else if(isR4){
                        acc.Last_FA_PFReview__c =acc.R4_FA_PFReview__c;
                        acc.R4_FA_PFReview__c = false;
                    }else if(isR3){
                        acc.Last_FA_PFReview__c =acc.R3_FA_PFReview__c;
                        acc.R3_FA_PFReview__c = false;
                    } 
                }
            }         
            
            accns.add(acc);
        }        
        database.update(accns,false); 
     
    }

   global void finish(Database.BatchableContext BC){
   }
}