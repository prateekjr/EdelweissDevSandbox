global class BatchToUpdateInteractionDetails implements Database.Batchable<sObject>, Database.Stateful {
    global String strQuery;
    
    
    global BatchToUpdateInteractionDetails(){
        strQuery= 'select Id,Last_Portfolio_Review_Date__c,createdById,Interaction_Meeting_Done_Counter__c, Coverage__c,Focus_30__c,Total_AUM_INR_Cr__c,Share_of_Wallet_For_Client__c,High_Priority__c,Rollup_AUM_of_Family__c,Mandate__c,Asset_Classes_Count__c,In_Person_Meeting_Done__c,Last_In_Person_Meeting_Date__c,RecordTypeId,Last_Interraction_Date_Phone_InPerson__c , R5_FA_PFReview__c,R3_FA_PFReview__c, R5_ProductManager_Interaction__c,R5_RHBHPH_Interaction__c,R5_TL_Interaction__c,R4_TL_Interaction__c,R5_FA_Interaction__c ,R4_FA_Interaction__c,R3_FA_Interaction__c,OwnerId,Event_Creation_DateTime__c,Last_RHBHPH_Interaction_Date__c,How_Often_Does_Client_Monitor_Portfolio__c,Last_Interaction_Date__c, Last_TL_Interaction_Date__c,Family_Networth__c,(select Id,OwnerId,WhatId,Status__c,EndDateTime,Type_of_Communication__c,Agenda__c from ActivityHistories where status__c=\'Completed\' and ActivitySubtype=\'Event\'order by EndDateTime desc limit 1) from Account where recordtype.name=\'Family\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Account> accountsList) 
    {
        
       /* List<Account> accountsList=[select Id,Last_Portfolio_Review_Date__c,createdById,Interaction_Meeting_Done_Counter__c, Coverage__c,Focus_30__c,Total_AUM_INR_Cr__c,Share_of_Wallet_For_Client__c,High_Priority__c,Rollup_AUM_of_Family__c,Mandate__c,Asset_Classes_Count__c,In_Person_Meeting_Done__c,Last_In_Person_Meeting_Date__c,RecordTypeId,Last_Interraction_Date_Phone_InPerson__c , R5_FA_PFReview__c,R3_FA_PFReview__c, 
                                    R5_ProductManager_Interaction__c,R5_RHBHPH_Interaction__c,R5_TL_Interaction__c,R4_TL_Interaction__c,R5_FA_Interaction__c ,R4_FA_Interaction__c,R3_FA_Interaction__c,OwnerId,Event_Creation_DateTime__c,Last_RHBHPH_Interaction_Date__c,How_Often_Does_Client_Monitor_Portfolio__c,Last_Interaction_Date__c, Last_TL_Interaction_Date__c,Family_Networth__c,(select Id,OwnerId,WhatId,Status__c,EndDateTime,Type_of_Communication__c,Agenda__c from ActivityHistories where 
                                                                                                                                                                                                                                                                                                                                                                                               status__c='Completed' and ActivitySubtype='Event'order by EndDateTime desc limit 1) from Account where recordtype.name='Family' and LastModifiedDate  < 2019-06-10t00:00:00.000Z and LastModifiedDate  > 2019-06-10T15:00:00.000Z ];
        */
        boolean isChanged=false;
         Map<Id,User> userMap = new Map<Id,User>([SELECT Id,ProfileId, Profile.Name FROM User]);
		Set<Id> accIdSet=new Set<Id>();
        List<Account> updatedClientList=new List<Account>();
        for(Account acc:accountsList){
            if(acc.ActivityHistories!=null && acc.ActivityHistories.size()>0){
            isChanged=false;
                ActivityHistory eventObj=acc.ActivityHistories.get(0);
                if(eventObj.WhatId.getSObjectType() == Account.sObjectType){
                   
            
                    Integer evntEndMonth = eventObj.EndDateTime.month();
                    integer CurrentMonth = date.today().month();
                    boolean isCMonthIntraction = false;
                    if(evntEndMonth == CurrentMonth)
                        isCMonthIntraction = true;
                    
                    List<System_Constant__mdt> sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Quarter_Month_Number'];
                    Set<Integer> quarterMonth = new Set<Integer>();
                    Map<Integer,Set<Integer>> quarterMonthMap = new Map<Integer,Set<Integer>>();
                    for(System_Constant__mdt constant : sysConstant ){
                        if(constant.Value__c != null){
                            for(String str : constant.Value__c.split(',')){
                                integer monthNumber = (integer.valueof(str) >= 12) ? 1 : integer.valueof(str)+1;
                                integer next1 = (monthNumber >= 12) ? 1 : monthNumber+1;
                                integer next2 = (next1 >= 12) ? 1 : next1+1;
                                quarterMonthMap.put(monthNumber,new Set<Integer>{monthNumber,next1,next2});
                            }
                        }
                    }
                    
                    boolean isCQuaterIntraction = false;
                    for(Set<Integer> months : quarterMonthMap.values()){
                        if(months.contains(CurrentMonth) && months.contains(evntEndMonth)){						
                            isCQuaterIntraction = true;
                        }
                    }
                    Integer BiAnnualMonthNumber = 9;
                    sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Bi_Annual_Month_Number'];
                    Map<Integer,Set<Integer>> BiAnnualMonthMap = new Map<Integer,Set<Integer>>();
                    if(sysConstant != null && sysConstant.size() > 0){
                        BiAnnualMonthNumber = integer.valueof(sysConstant[0].Value__c);
                        integer monthNumber = (BiAnnualMonthNumber >= 12) ? 1 : BiAnnualMonthNumber+1;
                        integer next1 = (monthNumber >= 12) ? 1 : monthNumber+1;
                        integer next2 = (next1 >= 12) ? 1 : next1+1;
                        integer next3 = (next2 >= 12) ? 1 : next2+1;
                        integer next4 = (next3 >= 12) ? 1 : next3+1;
                        integer next5 = (next4 >= 12) ? 1 : next4+1;
                        BiAnnualMonthMap.put(monthNumber,new Set<Integer>{monthNumber,next1,next2,next3,next4,next5});
                        
                        monthNumber = (next5 >= 12) ? 1 : next5+1;
                        next1 = (monthNumber >= 12) ? 1 : monthNumber+1;
                        next2 = (next1 >= 12) ? 1 : next1+1;
                        next3 = (next2 >= 12) ? 1 : next2+1;
                        next4 = (next3 >= 12) ? 1 : next3+1;
                        next5 = (next4 >= 12) ? 1 : next4+1;
                        BiAnnualMonthMap.put(monthNumber,new Set<Integer>{monthNumber,next1,next2,next3,next4,next5});
                        
                    }
                    
                    boolean isCBiAnnualIntraction = false;
                    for(Set<Integer> months : BiAnnualMonthMap.values()){
                        if(months.contains(CurrentMonth) && months.contains(evntEndMonth)){						
                            isCBiAnnualIntraction = true;
                        }
                    }
                    
                    List<System_Constant__mdt> sysBiMonthConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Bi_Monthly_Month_Number'];
                    Map<Integer,Set<Integer>> biMonthlyMonthMap = new Map<Integer,Set<Integer>>();
                    for(System_Constant__mdt constant : sysBiMonthConstant ){
                        if(constant.Value__c != null){
                            for(String str : constant.Value__c.split(',')){
                                integer monthNumber = (integer.valueof(str) >= 12) ? 1 : integer.valueof(str)+1;
                                integer next1 = (monthNumber >= 12) ? 1 : monthNumber+1;
                                biMonthlyMonthMap.put(monthNumber,new Set<Integer>{monthNumber,next1});
                            }
                        }
                    }
                    
                    boolean isBiMonthlyIntraction = false;
                    for(Set<Integer> months : biMonthlyMonthMap.values()){
                        if(months.contains(CurrentMonth) && months.contains(evntEndMonth)){						
                            isBiMonthlyIntraction = true;
                        }
                    }
                    
                    Account clientObj=acc;
                    
                    
                    //update In persone meeting flag and move to R0 to R1 stage
                   
                    if(eventObj.Type_of_Communication__c == 'In-Person' && (clientObj.Coverage__c == 'R0' ||clientObj.Coverage__c == 'Lead Database')){
                        clientObj.In_Person_Meeting_Done__c = true;
                        clientObj.Coverage__c = 'R1';
                    }
                    Boolean isFAOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Financial Advisor')) ? true : false;
           
                    if(clientObj.ownerId == eventObj.ownerId){
                        Date myDate = date.newinstance(eventObj.EndDateTime.year(), eventObj.EndDateTime.month(), eventObj.EndDateTime.day());
                        if(eventObj.Type_of_Communication__c == 'In-Person' && clientObj.RecordTypeId == EdelweissConstants.AccountRecordTypeMap.get('Family')){
                            if(clientObj.Last_In_Person_Meeting_Date__c < myDate ){
                                clientObj.Last_In_Person_Meeting_Date__c = myDate;
                                isChanged=true;
                            }else if(clientObj.Last_In_Person_Meeting_Date__c == null){
                                clientObj.Last_In_Person_Meeting_Date__c = myDate;
                                isChanged=true;
                            }
                            if(clientObj.Last_Interraction_Date_Phone_InPerson__c < myDate ){
                                clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                                isChanged=true;
                            }else if(clientObj.Last_Interraction_Date_Phone_InPerson__c == null){
                                clientObj.Last_Interraction_Date_Phone_InPerson__c =	myDate;
                                isChanged=true;
                            }
                        }
                        if(eventObj.Type_of_Communication__c == 'Phone' && clientObj.RecordTypeId == EdelweissConstants.AccountRecordTypeMap.get('Family')){
                            if(clientObj.Last_Interraction_Date_Phone_InPerson__c < myDate){
                                clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                                isChanged=true;
                            }else if(clientObj.Last_Interraction_Date_Phone_InPerson__c == null){
                                clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                                isChanged=true;
                            }
                        }
                        
                    }
                    
                    if(!isFAOwner){
                        if(eventObj.ownerId == clientObj.ownerId)
                            isFAOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Team Leader Advisory')) ? true : false;
                    }
                    
                    Boolean isRHOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Regional Head')) ? true : false;
                    if(!isRHOwner)
                        isRHOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.equalsIgnoreCase('FOIG')) ? true : false;                  
                    Boolean isBHOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Business Head')) ? true : false;
                    Boolean isPMOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Product Manager')) ? true : false;
                    Boolean isTLOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Team Leader Advisory')) ? true : false;
                    Boolean isPHOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Product Head')) ? true : false;
                    
                    Boolean isIntractionDone = false;
                    Boolean isFAIntractionDone = false;
                    Boolean isTLIntractionDone = false;
                    Boolean isRHBHPHIntractionDone = false;
                    Boolean isPortfolioDone = false;
                    
                    Boolean isTagFA = false;
                    Boolean isTagRH = false;
                    Boolean isTagBH = false;
                    Boolean isTagPM = false; 
                    Boolean isTagTL = false;
                    Boolean isTagPH = false;
                    
                    if(eventObj.Agenda__c=='Portfolio Review' && (isFAOwner || isTagFA )){
                        String pfReviewOften = clientObj.How_Often_Does_Client_Monitor_Portfolio__c ;
                        if(string.isBlank(pfReviewOften))
                            pfReviewOften = 'Quarterly';
                        boolean isValidReview = false;
                        Integer evntEndYear = eventObj.EndDateTime.year();
                        integer Currentyear = date.today().year();
                        
                        if(pfReviewOften == 'Quarterly' && isCQuaterIntraction)
                            isValidReview = true;
                        if(pfReviewOften == 'Annually' && evntEndYear == Currentyear)
                            isValidReview = true;
                        if(pfReviewOften == 'Bi-Annually' && isCBiAnnualIntraction)
                            isValidReview = true;
                        if(pfReviewOften == 'Monthly' && isCMonthIntraction)
                            isValidReview = true;
                        if(pfReviewOften == 'Bi-Monthly' && isBiMonthlyIntraction)
                            isValidReview = true;
                        
                        //if(isValidReview){
                        if(clientObj.Coverage__c == 'R5') clientObj.R5_FA_PFReview__c = true;
                        if(clientObj.Coverage__c == 'R4') clientObj.R4_FA_PFReview__c = true;
                        if(clientObj.Coverage__c == 'R3') clientObj.R3_FA_PFReview__c = true;
                        if(clientObj.Coverage__c == 'R3' || clientObj.Coverage__c == 'R4' || clientObj.Coverage__c == 'R5'){
                            Date evntEndDate = eventObj.EndDateTime.date(); 
                            if(clientObj.Last_Portfolio_Review_Date__c != null && clientObj.Last_Portfolio_Review_Date__c < evntEndDate){
                                clientObj.Last_Portfolio_Review_Date__c = evntEndDate;
                                isChanged=true;
                            }
                            else if(clientObj.Last_Portfolio_Review_Date__c == null ){
                                clientObj.Last_Portfolio_Review_Date__c = evntEndDate;
                                isChanged=true;
                            }
                        }
                        //}                        
                        //isPortfolioDone = true;
                    }
                    
                    //Interaction Logic
                    if(!isPortfolioDone){
                        if(isFAOwner || isTagFA ){
                            if(isCMonthIntraction){
                                if(clientObj.Coverage__c == 'R5') clientObj.R5_FA_Interaction__c = true;
                                if(clientObj.Coverage__c == 'R4') clientObj.R4_FA_Interaction__c = true;
                                if(clientObj.Coverage__c == 'R3') clientObj.R3_FA_Interaction__c = true;
                                isFAIntractionDone = true;								
                            }
                            isIntractionDone = true;							
                        }
                        
                        if(isRHOwner || isBHOwner || isPHOwner || isTagRH || isTagBH || isTagPH ){
                            if(clientObj.Coverage__c == 'R5') {
                                if(isCBiAnnualIntraction){
                                    clientObj.R5_RHBHPH_Interaction__c = true;                                    
                                }
                                isIntractionDone = true;
                            }
                        }                       
                        if((isPMOwner || isTagPM || isPHOwner || isTagPH) && clientObj.Coverage__c == 'R5'){
                            if(isCQuaterIntraction){
                                clientObj.R5_ProductManager_Interaction__c = true;								
                                isRHBHPHIntractionDone = true;
                            }
                            isIntractionDone = true;
                        }
                        
                        if(isTLOwner || isTagTL){
                            if(isCBiAnnualIntraction){
                                if(clientObj.Coverage__c == 'R4'){
                                    clientObj.R4_TL_Interaction__c = true;									
                                    isTLIntractionDone = true;
                                }
                                if(clientObj.Coverage__c == 'R5'){
                                    clientObj.R5_TL_Interaction__c = true;
                                    isTLIntractionDone = true;
                                }
                            }
                            isIntractionDone = true;
                        }
                        Date evntEndDate = eventObj.EndDateTime.date();                        
                        if((clientObj.Coverage__c == 'R3' || clientObj.Coverage__c == 'R4' || clientObj.Coverage__c == 'R5') && isIntractionDone){
                            if((isTLOwner || isTagTL )&& (clientObj.Coverage__c == 'R4' || clientObj.Coverage__c == 'R5') ){
                                if(clientObj.Last_TL_Interaction_Date__c != null && clientObj.Last_TL_Interaction_Date__c < evntEndDate){
                                    clientObj.Last_TL_Interaction_Date__c = evntEndDate;
                                    isChanged=true;
                                }
                                else if(clientObj.Last_TL_Interaction_Date__c == null){
                                    clientObj.Last_TL_Interaction_Date__c = evntEndDate;
                                    isChanged=true;
                                }
                            }                               
                            if((isFAOwner || isTagFA )){
                                if(clientObj.Last_Interaction_Date__c != null && clientObj.Last_Interaction_Date__c < evntEndDate){
                                    clientObj.Last_Interaction_Date__c = evntEndDate;
                                    isChanged=true;
                                }
                                else if(clientObj.Last_Interaction_Date__c == null){
                                    clientObj.Last_Interaction_Date__c = evntEndDate;	
                                    isChanged=true;
                                }
                                    							
                            }
                            if((isRHOwner || isBHOwner || isPHOwner || isTagRH || isTagBH || isTagPH ) && clientObj.Coverage__c == 'R5'){
                                if(clientObj.Last_RHBHPH_Interaction_Date__c != null && clientObj.Last_RHBHPH_Interaction_Date__c < evntEndDate){
                                    clientObj.Last_RHBHPH_Interaction_Date__c = evntEndDate;
                                     isChanged=true;
                                }
                                else if(clientObj.Last_RHBHPH_Interaction_Date__c == null){
                                    clientObj.Last_RHBHPH_Interaction_Date__c = evntEndDate;
                                    isChanged=true;
                                }
                            }                                
                        }
                        
                    }
                    if(isChanged){
                    clientObj.Event_Creation_DateTime__c = DateTime.now().getTime();   
                    updatedClientList.add(clientObj);
                    }
                    
                }
            }
        }
        if(updatedClientList!=null && updatedClientList.size()>0){
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            try{ 
                update updatedClientList;            
            }catch(Exception e){
                system.debug('Exception in Lead updation and reason is::'+e);
            }
        }
    }
    
    global void finish(Database.BatchableContext bcMain){
        
    }
}