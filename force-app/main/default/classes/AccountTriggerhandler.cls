public class AccountTriggerhandler{
    public static boolean stopAccountTrigger= false;
    //public static boolean stopUpdateClient= false;
    public static boolean stopUpdatefamily= false;
    public static boolean stopSharingRules= false;
    
    public static void setDueDates(List<Account>accountList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>familyList = new List<Account>();
        //List<Account>updatedfamilyList = new List<Account>();
        Set<Id> familyIdSet = new Set<Id>();
        for(Account accObj:accountList){
            /*Added "accObj.ClientAssetInformationUpdateCompleted__c == true" condition for Insert condition handling*/
            if(accObj.RecordTypeId == familyRecordTypeId ){
                familyIdSet.add(accObj.Id);
                //Account newAccountObj = new Account(id= accObj.Id);
                //newAccountObj.ClientAssetInformationUpdateCompleted__c  = false;
                //updatedfamilyList.add(newAccountObj );
            }
        }
        
        if(familyIdSet!=null && familyIdSet.size()>0){
            familyList = [SELECT a.setRH_BHEndDateRegular__c, a.setRH_BHDueDateRegular__c, 
                          a.setPortfolioEndDateRegular__c, a.setPortfolioDueDateRegular__c, 
                          a.setInteractionEndDateRegular__c, a.setInteractionDueDateRegular__c, a.Total_AUM_INR_Cr__c,
                          a.setInPersonEndDateRegular__c, a.setInPersonDueDateRegular__c, a.inPersonNotificationCounter__c, 
                          a.Rollup_AUM_of_Family__c, a.RH_BH_Meeting_End_Date__c, a.RH_BH_Meeting_Due_Date__c, 
                          a.RH_BH_Meeting_Done__c, a.Portfolio_Review_End_Date__c, a.Portfolio_Review_Due_Date__c,
                          a.Portfolio_Review_Done__c, a.PortfolioReviewNotificationCounter__c, a.Mandate__c, 
                          a.Interaction_End_Date__c, a.Interaction_Due_Date__c, a.Interaction_Done__c, 
                          a.In_Person_Meeting_End_Date__c, a.In_Person_Meeting_Done__c, a.InPersonMeeting_Due_Date__c,
                          a.InteractionNotificationCounter__c,a.Asset_Classes_Count__c, a.Communication_Criteria_Number__c ,
                          a.High_Priority__c,a.Name, a.Focus_30__c, a.Coverage__c,a.Share_of_Wallet_For_Client__c,a.RH_BH_Notification_Counter__c,
                          a.ClientAssetInformationUpdateCompleted__c,a.Family_Networth__c FROM Account a
                          WHERE a.Id IN:familyIdSet
                         ];
        }
        system.debug('=========familyList size===='+familyList.size());
        if(familyList!=null && familyList.size()>0){
            stopAccountTrigger = true;
            setinPersonMeetingDate(familyList,accountOldMap,isUpdate);
            setRH_BHMeetingDate(familyList,accountOldMap,isUpdate);
            setInterationDate(familyList,accountOldMap,isUpdate);
            setPortfolioDate(familyList,accountOldMap,isUpdate);
            /*try{
                if(updatedfamilyList!=null && updatedfamilyList.size()>0){
                
                    upsert updatedfamilyList;
                }
            
            }catch(Exception e){
            
                system.debug('Exception in Family update for reset=='+updatedfamilyList);
            }*/
        }
        
    }
    public static Integer checkCriteria(Account clientobj){
        Integer creiteriaNumber = 1;
        //system.debug('clientobj.Rollup_AUM_of_Family__c==='+clientobj.Rollup_AUM_of_Family__c);
        //system.debug('clientobj.Coverage__c==='+clientobj.Coverage__c);
        //system.debug('clientobj.High_Priority__c==='+clientobj.High_Priority__c);
        //system.debug('clientobj.Focus_30__c==='+clientobj.Focus_30__c);
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
    public static void setinPersonMeetingDate(List<Account>familyList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:familyList){
            Account oldFamilyObj = accountOldMap.get(familyobj.Id);
            updatedFamilyObj = new Account(id=familyobj.id);
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
                updatedFamilyObj.Communication_Criteria_Number__c = criteriaNumber ;
                if(!isUpdate ){
                    getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.InPersonMeeting_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.In_Person_Meeting_End_Date__c);
                    isChange = true;
                    System.debug('DildarLog: 0');
                }else{
                    if(oldFamilyObj.setInPersonDueDateRegular__c != familyobj.setInPersonDueDateRegular__c && 
                        familyobj.setInPersonDueDateRegular__c && criteriaName!= ''){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.InPersonMeeting_Due_Date__c,Integer.valueOf(familyobj.inPersonNotificationCounter__c));
                        updatedFamilyObj.setInPersonDueDateRegular__c = false;                     
                        isChange = true;
                        System.debug('DildarLog: 1');
                    }
                    if(oldFamilyObj.setInPersonEndDateRegular__c != familyobj.setInPersonEndDateRegular__c && 
                        familyobj.setInPersonEndDateRegular__c && criteriaName!= ''){
                        getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.In_Person_Meeting_End_Date__c);
                        
                        if(familyobj.In_Person_Meeting_Done__c == false){
                            updatedfamilyobj.InpersonMeeting_Done_Earlier__c = familyobj.In_Person_Meeting_Done__c;
                        
                        }else{
                            updatedfamilyobj.In_Person_Meeting_Done__c  = false;
                        }
                        updatedfamilyobj.setInPersonEndDateRegular__c = false;   
                        isChange = true;
                        System.debug('DildarLog: 2');
                    }
                    if( familyobj.InPersonMeeting_Due_Date__c!=null && familyobj.In_Person_Meeting_End_Date__c !=null 
                        && updatedFamilyObj.Communication_Criteria_Number__c!= familyobj.Communication_Criteria_Number__c
                        && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,updatedFamilyObj,isUpdate,null,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,null);
                        isChange = true;
                        System.debug('DildarLog: 3');
                    }
                    system.debug('familyobj.In_Person_Meeting_End_Date__c===='+familyobj.In_Person_Meeting_End_Date__c);
                    system.debug('oldFamilyObj.Rollup_AUM_of_Family__c====>'+oldFamilyObj.Rollup_AUM_of_Family__c);
                    system.debug('familyobj.Rollup_AUM_of_Family__c========'+familyobj.Rollup_AUM_of_Family__c);
                    system.debug('familyobj.Name===='+familyobj.Name);
                    system.debug('familyobj.InPersonMeeting_Due_Date__c===='+familyobj.InPersonMeeting_Due_Date__c);
                    if( criteriaName!= '' && familyobj.InPersonMeeting_Due_Date__c == null && familyobj.In_Person_Meeting_End_Date__c == null && 
                        familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,updatedFamilyObj,false,familyobj.InPersonMeeting_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,updatedFamilyObj,false,familyobj.In_Person_Meeting_End_Date__c);
                        isChange = true;
                        System.debug('DildarLog: 2');
                    }
                    if(familyobj.In_Person_Meeting_Done__c && familyobj.In_Person_Meeting_Done__c!=oldFamilyObj.In_Person_Meeting_Done__c){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.In_Person_Meeting_End_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INPERSON_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.In_Person_Meeting_End_Date__c);
                        updatedfamilyobj.In_Person_Meeting_Done__c = false;
                        isChange = true;
                        System.debug('DildarLog: Wrong Param....');
                    }
                }
            }
            if(isChange ){
                updatedFamilyObj.ClientAssetInformationUpdateCompleted__c = false;
                updatedFamilyList.add(updatedFamilyObj);
            }
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            update updatedFamilyList;
        }
    } 
    public static void setRH_BHMeetingDate(List<Account>familyList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:familyList){
            Account oldFamilyObj = accountOldMap.get(familyobj.Id);
            updatedFamilyObj = new Account(id=familyobj.id);
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
                updatedFamilyObj.Communication_Criteria_Number__c = criteriaNumber ;
                if(!isUpdate ){
                    getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_End_Date__c);
                    isChange = true;
                }else{
                    
                    if(oldFamilyObj.setRH_BHDueDateRegular__c != familyobj.setRH_BHDueDateRegular__c && 
                        familyobj.setRH_BHDueDateRegular__c && criteriaName!= ''){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_Due_Date__c,Integer.valueOf(familyobj.RH_BH_Notification_Counter__c));
                        updatedFamilyObj.setRH_BHDueDateRegular__c = false;                     
                        isChange = true;
                    }
                    if(oldFamilyObj.setRH_BHEndDateRegular__c != familyobj.setRH_BHEndDateRegular__c && 
                        familyobj.setRH_BHEndDateRegular__c && criteriaName!= ''){
                        getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_End_Date__c);
                        if(familyobj.RH_BH_Meeting_Done__c == false){
                            updatedfamilyobj.RH_BH_Meeting_Done_Earlier__c = familyobj.RH_BH_Meeting_Done__c;
                        
                        }else{
                            updatedfamilyobj.RH_BH_Meeting_Done__c  = false; 
                        } 
                        updatedfamilyobj.setRH_BHEndDateRegular__c = false;  
                                       
                        isChange = true;
                    }
                    if( criteriaName!= '' && familyobj.RH_BH_Meeting_Due_Date__c != null && familyobj.RH_BH_Meeting_End_Date__c != null
                        && updatedFamilyObj.Communication_Criteria_Number__c!= familyobj.Communication_Criteria_Number__c 
                        && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,isUpdate,null,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,null);
                        isChange = true;
                    }
                    if( criteriaName!= '' && familyobj.RH_BH_Meeting_Due_Date__c == null && familyobj.RH_BH_Meeting_End_Date__c == null
                        && familyobj.InPersonMeeting_Due_Date__c ==null && familyobj.Portfolio_Review_Due_Date__c == null
                        && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,false,familyobj.RH_BH_Meeting_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,false,familyobj.RH_BH_Meeting_End_Date__c);
                        isChange = true;
                    }
                    /*condition to handle when AUM is updated and coverage chaneg from R3 to R4*/
                    if(criteriaName!= '' && familyobj.RH_BH_Meeting_Due_Date__c == null && familyobj.RH_BH_Meeting_End_Date__c == null
                        && familyobj.InPersonMeeting_Due_Date__c != null && familyobj.Portfolio_Review_Due_Date__c != null
                        && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,true,familyobj.RH_BH_Meeting_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,true,familyobj.RH_BH_Meeting_End_Date__c);
                        isChange = true;
                    }
                     if(familyobj.RH_BH_Meeting_Done__c && familyobj.RH_BH_Meeting_Done__c!=oldFamilyObj.RH_BH_Meeting_Done__c){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaName,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_End_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.RH_BH_Meeting_End_Date__c);
                        updatedfamilyobj.RH_BH_Meeting_Done__c = false;
                        isChange = true;
                    }
                }
            }else{
                if( familyobj.RH_BH_Meeting_Due_Date__c != null && familyobj.RH_BH_Meeting_End_Date__c != null
                    && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        setNextDueDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,null,updatedFamilyObj,-1);
                        setEndDate(EdelweissConstants.CALLED_FROM_RH_BH_MEETING,null,updatedFamilyObj);
                        isChange = true;
                }
            
            
            }
            
            if(isChange ){
                updatedFamilyObj.ClientAssetInformationUpdateCompleted__c = false;
                updatedFamilyList.add(updatedFamilyObj);
            }
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            update updatedFamilyList;
        }
    }
    public static void setInterationDate(List<Account>familyList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:familyList){
            Account oldFamilyObj = accountOldMap.get(familyobj.Id);
            updatedFamilyObj = new Account(id=familyobj.id);
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
                updatedFamilyObj.Communication_Criteria_Number__c = criteriaNumber ;
                if(!isUpdate ){
                    getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,isUpdate,familyobj.Interaction_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Interaction_End_Date__c);
                    isChange = true;
                }else{
                    
                    if(oldFamilyObj.setInteractionDueDateRegular__c != familyobj.setInteractionDueDateRegular__c && 
                        familyobj.setInteractionDueDateRegular__c && criteriaName!= ''){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,isUpdate,familyobj.Interaction_Due_Date__c,Integer.valueOf(familyobj.InteractionNotificationCounter__c));
                        updatedFamilyObj.setInteractionDueDateRegular__c = false;                     
                        isChange = true;
                    }
                    if(oldFamilyObj.setInteractionEndDateRegular__c != familyobj.setInteractionEndDateRegular__c && 
                        familyobj.setInteractionEndDateRegular__c && criteriaName!= ''){
                        getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Interaction_End_Date__c);
                        if(familyobj.Interaction_Done__c == false){
                            updatedfamilyobj.Interaction_Done_Earlier__c = familyobj.Interaction_Done__c;
                        
                        }else{
                            updatedfamilyobj.Interaction_Done__c  = false;    
                        }  
                        updatedfamilyobj.setInteractionEndDateRegular__c = false; 
                                    
                        isChange = true;
                    }
                    if( criteriaName!= '' && familyobj.Interaction_Due_Date__c != null && familyobj.Interaction_End_Date__c != null
                        && updatedFamilyObj.Communication_Criteria_Number__c!= familyobj.Communication_Criteria_Number__c
                        && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,isUpdate,null,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,isUpdate,null);
                        isChange = true;
                    }
                    
                    if(criteriaName!= ''  && familyobj.Interaction_Due_Date__c == null && familyobj.Interaction_End_Date__c == null
                    && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,false,familyobj.Interaction_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,false,familyobj.Interaction_End_Date__c);
                        isChange = true;
                    }
                    /*Use to check first AUM update refer for bug fixing for interaction in case of R5 to R4*/
                    /*condition for R5 and R4 is checked as for new entry Reverse flow of coverage never happen for new entry*/
                    if(familyobj.InPersonMeeting_Due_Date__c != null && familyobj.Portfolio_Review_Due_Date__c != null && criteriaName!= ''  
                       && familyobj.Interaction_Due_Date__c == null && familyobj.Interaction_End_Date__c == null
                         ){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,true,familyobj.Interaction_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,true,familyobj.Interaction_End_Date__c);
                        isChange = true;
                    }
                    if(familyobj.Interaction_Done__c && familyobj.Interaction_Done__c!=oldFamilyObj.Interaction_Done__c){
                        getNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaName,updatedFamilyObj,isUpdate,familyobj.Interaction_Due_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Interaction_End_Date__c);
                        updatedfamilyobj.Interaction_Done__c = false;
                        isChange = true;
                    }
                }
            }else{
                if( familyobj.Interaction_Due_Date__c != null && familyobj.Interaction_End_Date__c != null
                    && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        setNextDueDate(EdelweissConstants.CALLED_FROM_INTERACTION,null,updatedFamilyObj,-1);
                        setEndDate(EdelweissConstants.CALLED_FROM_INTERACTION,null,updatedFamilyObj);
                        isChange = true;
                }
            
            
            }
            if(isChange ){
                updatedFamilyObj.ClientAssetInformationUpdateCompleted__c = false;
                updatedFamilyList.add(updatedFamilyObj);
            }
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            update updatedFamilyList;
        }
    }
    public static void setPortfolioDate(List<Account>familyList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Account updatedFamilyObj;
        List<Account>updatedFamilyList = new List<Account>();
        Boolean isChange = false;
        for(Account familyobj:familyList){
            Account oldFamilyObj = accountOldMap.get(familyobj.Id);
            updatedFamilyObj = new Account(id=familyobj.id);
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
                updatedFamilyObj.Communication_Criteria_Number__c = criteriaNumber ;
                if(!isUpdate ){
                    getNextPortfolioReviewDueDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaName,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_Due_Date__c,-1);
                    getEndDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_End_Date__c);
                    isChange = true;
                }else{
                    
                    if(oldFamilyObj.setPortfolioDueDateRegular__c != familyobj.setPortfolioDueDateRegular__c && 
                        familyobj.setPortfolioDueDateRegular__c && criteriaName!= ''){
                        getNextPortfolioReviewDueDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaName,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_Due_Date__c,Integer.valueOf(familyobj.PortfolioReviewNotificationCounter__c));
                        updatedFamilyObj.setPortfolioDueDateRegular__c = false;                     
                        isChange = true;
                    }
                    if(oldFamilyObj.setPortfolioEndDateRegular__c != familyobj.setPortfolioEndDateRegular__c && 
                        familyobj.setPortfolioEndDateRegular__c && criteriaName!= ''){
                        getEndDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_End_Date__c);
                        if(familyobj.Portfolio_Review_Done__c == false){
                            updatedfamilyobj.Portfolio_Review_Done_Earlier__c = familyobj.Portfolio_Review_Done__c;
                        
                        }else{
                            updatedfamilyobj.Portfolio_Review_Done__c  = false;
                        }
                        updatedfamilyobj.setPortfolioEndDateRegular__c = false;  
                                        
                        isChange = true;
                    }
                    if( criteriaName!= '' && updatedFamilyObj.Communication_Criteria_Number__c!= familyobj.Communication_Criteria_Number__c
                    && familyobj.ClientAssetInformationUpdateCompleted__c == true){
                        getNextPortfolioReviewDueDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaName,updatedFamilyObj,isUpdate,null,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaNumber,updatedFamilyObj,isUpdate,null);
                        isChange = true;
                    }
                    if(familyobj.Portfolio_Review_Done__c && familyobj.Portfolio_Review_Done__c!=oldFamilyObj.Portfolio_Review_Done__c){
                        getNextPortfolioReviewDueDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaName,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_End_Date__c,-1);
                        getEndDate(EdelweissConstants.CALLED_FROM_PORTFOILIO_REVIEW,criteriaNumber,updatedFamilyObj,isUpdate,familyobj.Portfolio_Review_End_Date__c);
                        updatedfamilyobj.Portfolio_Review_Done__c = false;
                        isChange = true;
                    }
                }
            }
            
            if(isChange ){
                updatedFamilyList.add(updatedFamilyObj);
            }
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            updatedFamilyObj.ClientAssetInformationUpdateCompleted__c = false;
            update updatedFamilyList;
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
    
    public static void upadateClientAssetCount(List<Account>accountList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        Map<Id,List<Account>>parentIdClientMap = new Map<Id,List<Account>>();
        Map<Id,Account>updatedFamilyIdObjectMap = new Map<Id,Account>();
        Set<Id> familyIdSet = new Set<Id>();
        List<Account>updatedFamilyList = new List<Account>();
        List<Account>clientList = new List<Account>();
        for(Account clientObj:accountList){
            
            if(clientObj.RecordTypeId == clientRecordTypeId){
                Set<String>classSet = new Set<String>();
                if(clientObj.Asset_Classes_Client_is_Interested_in__c!=null  ){
                        List<String>assetClassList = clientObj.Asset_Classes_Client_is_Interested_in__c.split(';');
                        classSet.addAll(assetClassList);
                }
                //clientObj.Asset_Classes_Count__c = classSet.size();
                Account oldAccountObj;
                if(isUpdate){
                    oldAccountObj = accountOldMap.get(clientObj.Id);
                }else{
                    oldAccountObj = clientObj;
                
                }
                
                
                if(clientObj.RecordTypeId == clientRecordTypeId &&
                    (
                      (isUpdate && 
                        (clientObj.Asset_Classes_Client_is_Interested_in__c != oldAccountObj.Asset_Classes_Client_is_Interested_in__c
                         || clientObj.ParentId!=oldAccountObj.ParentId
                        )
                      ) 
                      || 
                      (!isUpdate )
                    )
                  ){
                    if(clientObj.ParentId!=oldAccountObj.ParentId){
                        familyIdSet.add(oldAccountObj.ParentId);
                        familyIdSet.add(clientObj.ParentId);
                    }else{
                        familyIdSet.add(clientObj.ParentId);
                    }
                    system.debug('In Family Id Set Population updateClient AssetCount &&&&&&&&&&&&&&&&&&&&&&&'+familyIdSet);
                }
            }
            
        }
        
        if(familyIdSet!=null && familyIdSet.size()>0){
             clientList = [SELECT Id,ParentId, Asset_Classes_Client_is_Interested_in__c
                                       FROM Account
                                       WHERE 
                                          RecordTypeId =: clientRecordTypeId 
                                          AND ParentId IN:familyIdSet
                          ];
            system.debug('*********** familyList Size==='+clientList.size());
        }
        for(Id familyId :familyIdSet){
            if(clientList !=null && clientList.size()>0){
                List<Account>tempClientList;
                Boolean clientFound = false;
                for(Account clientObj : clientList){
                    if(familyId == clientObj.ParentId){
                        clientFound = true;
                        system.debug('clientObj.ParentId=========='+clientObj.ParentId);
                        if(!parentIdClientMap.isEmpty() && parentIdClientMap.containsKey(clientObj.ParentId)){
                            tempClientList = parentIdClientMap.get(clientObj.ParentId);
                            tempClientList.add(clientObj);
                            parentIdClientMap.put(clientObj.ParentId,tempClientList);
                        }else{
                            tempClientList = new List<Account>();
                            tempClientList.add(clientObj);
                            parentIdClientMap.put(clientObj.ParentId,tempClientList);
                        }
                    }
                }
                if(!clientFound){
                    Account familyObj = new Account(Id = familyId);
                    familyObj.Asset_Classes_Client_is_Interested_in__c = '';
                    familyObj.Asset_Classes_Count__c = 0;
                    updatedFamilyList.add(familyObj);
                }
            }
        }
        for(Id familyId:parentIdClientMap.keySet()){
            Account familyObj = new Account(Id = familyId);
            Set<String>classSet = new Set<String>();
            for(Account clientObj: parentIdClientMap.get(familyId)){
                system.debug('clientObj==='+clientObj.Id);
                if(clientObj.Asset_Classes_Client_is_Interested_in__c!=null){
                    system.debug('clientObj.Asset_Classes_Client_is_Interested_in__c===>'+clientObj.Asset_Classes_Client_is_Interested_in__c);
                    List<String>assetClassList = clientObj.Asset_Classes_Client_is_Interested_in__c.split(';');
                    classSet.addAll(assetClassList);
                }
            }
            system.debug('classSet size===>'+classSet.size());
            system.debug('classSet===>'+classSet);
            String assetClass = '';
            for(String classes:classSet){
                assetClass= assetClass+';'+ classes;
            }
            familyObj.Asset_Classes_Client_is_Interested_in__c = assetClass;
            familyObj.Asset_Classes_Count__c = classSet.size();
            updatedFamilyList.add(familyObj);
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            stopUpdatefamily = true;
            update updatedFamilyList;
        }
    
    }
    
    public static void upadateInvestibleAsset(List<Account>accountList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        Map<Id,List<Account>>parentIdClientMap = new Map<Id,List<Account>>();
        Map<Id,Account>updatedFamilyIdObjectMap = new Map<Id,Account>();
        Set<Id> familyIdSet = new Set<Id>();
        List<Account>updatedFamilyList = new List<Account>();
        List<Account>clientList = new List<Account>();
        
        for(Account clientObj:accountList){
            
            if(clientObj.RecordTypeId == clientRecordTypeId){
                Account oldAccountObj;
                if(isUpdate){
                    oldAccountObj = accountOldMap.get(clientObj.Id);
                }else{
                    oldAccountObj = clientObj;
                
                }
                if(clientObj.RecordTypeId == clientRecordTypeId &&
                    (
                      (isUpdate && 
                        (clientObj.Investible_Assets__c != oldAccountObj.Investible_Assets__c
                         || clientObj.ParentId!=oldAccountObj.ParentId
                        )
                      ) 
                      || 
                      (!isUpdate )
                    )
                  ){
                    if(clientObj.ParentId!=oldAccountObj.ParentId){
                        familyIdSet.add(oldAccountObj.ParentId);
                        familyIdSet.add(clientObj.ParentId);
                    }else{
                        familyIdSet.add(clientObj.ParentId);
                    }
                    system.debug('In Family Id Set Population updateClient AssetCount &&&&&&&&&&&&&&&&&&&&&&&'+familyIdSet);
                }
            }
            
        }
        
        //patch
        familyIdSet.remove(null);
        
        if(familyIdSet!=null && familyIdSet.size()>0){
             clientList = [SELECT Id,ParentId, Investible_Assets__c,Asset_Classes_Client_is_Interested_in__c
                                       FROM Account
                                       WHERE 
                                          RecordTypeId =: clientRecordTypeId 
                                          AND ParentId IN:familyIdSet
                          ];
            system.debug('*********** familyList Size==='+clientList.size());
        }
        for(Id familyId :familyIdSet){
            if(clientList !=null && clientList.size()>0){
                List<Account>tempClientList;
                Boolean clientFound = false;
                for(Account clientObj : clientList){
                    if(familyId == clientObj.ParentId){
                        clientFound = true;
                        system.debug('clientObj.ParentId=========='+clientObj.ParentId);
                        if(!parentIdClientMap.isEmpty() && parentIdClientMap.containsKey(clientObj.ParentId)){
                            tempClientList = parentIdClientMap.get(clientObj.ParentId);
                            tempClientList.add(clientObj);
                            parentIdClientMap.put(clientObj.ParentId,tempClientList);
                        }else{
                            tempClientList = new List<Account>();
                            tempClientList.add(clientObj);
                            parentIdClientMap.put(clientObj.ParentId,tempClientList);
                        }
                    }
                }
                if(!clientFound){
                    Account familyObj = new Account(Id = familyId);
                    familyObj.Total_Investible_Assets__c = 0;
                    updatedFamilyList.add(familyObj);
                }
            }
        }
        for(Id familyId:parentIdClientMap.keySet()){
            Account familyObj = new Account(Id = familyId);
            Double totalInvestibleAsset = 0.0;
            for(Account clientObj: parentIdClientMap.get(familyId)){
                system.debug('clientObj==='+clientObj.Id);
                if(clientObj.Investible_Assets__c!=null){
                    totalInvestibleAsset = totalInvestibleAsset+clientObj.Investible_Assets__c;  
                }
            }
            familyObj.Total_Investible_Assets__c = totalInvestibleAsset;
            updatedFamilyList.add(familyObj);
        }
        if(updatedFamilyList!= null && updatedFamilyList.size()>0){
            stopUpdatefamily = true;
            update updatedFamilyList;
        }
    
    }
    
     /*Replacement of Workflow "Update Family Coverage to R4"*/
    public static void changeStatusToR4(List<Account>accountList){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>updatedAccountList = new List<Account>();
        for(Account accountObj:accountList){
            Account newAccountObj = new Account(Id = accountObj.Id);
            if(accountObj.RecordTypeId == familyRecordTypeId && accountObj.Coverage__c == 'R3' && accountObj.Total_AUM_INR_Cr__c > 5){
                    newAccountObj.Coverage__c = 'R4';
                    updatedAccountList.add(newAccountObj);
            }
        }
        if(updatedAccountList!=null && updatedAccountList.size()>0){
            stopAccountTrigger = true;
            update updatedAccountList;
        }
        }
    
    /*Replacement of Workflow "Update Family Coverage to R5"*/
    /*
    public static void changeStatusToR5(List<Account>accountList){
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        List<Account>updatedAccountList = new List<Account>();
        for(Account accountObj:accountList){
            Account newAccountObj = new Account(Id = accountObj.Id);
                
            if(accountObj.RecordTypeId ==familyRecordTypeId && accountObj.Total_AUM_INR_Cr__c !=NULL && accountObj.Total_AUM_INR_Cr__c !=0 )
            {
                if(accountObj.Mandate__c == true && accountObj.Total_AUM_INR_Cr__c > 25){
                    newAccountObj.Coverage__c = 'R5';
                    updatedAccountList.add(newAccountObj);
                }else if(accountObj.Investible_Assets__c!=NULL && accountObj.Investible_Assets__c !=0){
                    if(accountObj.Total_AUM_INR_Cr__c > 25 && accountObj.Share_Of_Wallet_for_Family__c >= 30){
                        newAccountObj.Coverage__c = 'R5';
                        updatedAccountList.add(newAccountObj);
                    }
                }
            }
        }
        
        if(updatedAccountList!=null && updatedAccountList.size()>0){
            stopAccountTrigger = true;
            update updatedAccountList;
        }
    }
	*/
    
    public static void shareAccountWithCXO(List<Account>accountList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Set<Id> FAIdSet = new Set<Id>();
		Map<Id,Id> CXOIdMap = new Map<Id,Id>();
        Map<Id,Id>FAIdCSOIdMap = new Map<Id,Id>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        Map<Id,Id>accountIdownerIdMap = new Map<Id,Id>();
        Map<Id,Account> mapIDAccountToFetchRT = new Map<Id,Account>([SELECT ID,RecordTypeId,Open_an_account_opening_Case__c from Account where id in:accountList]);
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        Id leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Lead');
        
        for(Account accountObj:accountList){
            if(!isUpdate){
                FAIdSet.add(accountObj.OwnerId);
				if(accountObj.Primary_CXO__c != null)
					CXOIdMap.put(accountObj.Id,accountObj.Primary_CXO__c);
                accountIdownerIdMap.put(accountObj.Id,accountObj.OwnerId);
            }else{
                Account oldAccountObj = accountOldMap.get(accountObj.Id);
                if((oldAccountObj.OwnerId != accountObj.OwnerId ) || (oldAccountObj.Primary_CXO__c != accountObj.Primary_CXO__c)){
                    FAIdSet.add(accountObj.OwnerId);
					if(accountObj.Primary_CXO__c != null)
						CXOIdMap.put(accountObj.Id,accountObj.Primary_CXO__c);
                    accountIdownerIdMap.put(accountObj.Id,accountObj.OwnerId);
                }
            }
            
        } 
        system.debug('FAIdSet=='+FAIdSet);
       
        if(FAIdSet!=null && FAIdSet.size()>0){
            FAIdCSOIdMap = getFAMappedCSO(FAIdSet); 
        } 
         system.debug('FAIdCSOIdMap =='+FAIdCSOIdMap );  
        for(Id accountId:accountIdownerIdMap.keySet()){
            Id CSOId;
            Id FAId = accountIdownerIdMap.get(accountId);
            if(FAIdCSOIdMap!=null && !FAIdCSOIdMap.isEmpty() && FAIdCSOIdMap.containsKey(FAId) &&((mapIDAccountToFetchRT.get(accountId).recordTypeID==familyRecordTypeId || mapIDAccountToFetchRT.get(accountId).recordTypeID==clientRecordTypeId)||(mapIDAccountToFetchRT.get(accountId).recordTypeID==leadRecordTypeId && mapIDAccountToFetchRT.get(accountId).Open_an_account_opening_Case__c ))){
                CSOId = FAIdCSOIdMap.get(FAId);
                AccountShare accountShareObj = new AccountShare(AccountId = accountId, UserOrGroupId = CSOId, AccountAccessLevel='Read',RowCause='Manual',OpportunityAccessLevel = 'Read');
                accountShareList.add(accountShareObj);
            } 
			if(CXOIdMap != null && CXOIdMap.get(accountId) != null){
				AccountShare accountShareObj = new AccountShare(AccountId = accountId, UserOrGroupId = CXOIdMap.get(accountId), AccountAccessLevel='Read',RowCause='Manual',OpportunityAccessLevel = 'Read');
                accountShareList.add(accountShareObj);
				
			}
        }
    
        if(accountShareList!=null && accountShareList.size()>0){
            try{
            
                database.insert(accountShareList,false);
            }catch(Exception e){
                system.debug('*********Error in insertion for Account Share record*********');
            
            }
            
        
        }
    }
    public static void updateFamilyHead(List<Account>accountList,Map<Id,Account>accountOldMap,Boolean isUpdate){
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        List<Account>familyList = new List<Account>();
        Map<id, Account> MapFamilytoClient = new Map<id, Account>();
        List<Account> updatedFamily = new List<Account>();
        Map<Id,Account> updatedFamilyMap = new Map<Id,Account>();
        //List<Account>updatedfamilyList = new List<Account>();
        Set<Id> FamilyIdSet= new Set<Id>();
        for(Account accObj :accountList){
            
            if(accObj.Is_Client_Family_Head__c=='Yes' && accObj.RecordTypeId == clientRecordTypeId ){
               if(!isUpdate){
                   FamilyIdSet.add(accObj.ParentId);
                   MapFamilytoClient.put(accObj.ParentId,accObj);
                   //accObj.Parent.Family_Head_Name__c = accObj.id;
                   //updatedFamily.add(accObj.Parent);
               }
               else
               {
                    Account oldAccountObj = accountOldMap.get(accObj.Id);
                    if((oldAccountObj.Is_Client_Family_Head__c!=accObj.Is_Client_Family_Head__c) ||(oldAccountObj.sub_lob__c!=accObj.sub_lob__c))
                    {
                        //System.debug('accObj.Parent=='+accObj.ParentId);
                        FamilyIdSet.add(accObj.ParentId);
                        MapFamilytoClient.put(accObj.ParentId,accObj);
                        //accObj.Parent.Family_Head_Name__c = accObj.id;
                        //updatedFamily.add(accObj.Parent);
                    }
               }
               
            }
            }
            if(FamilyIdSet!=null && FamilyIdSet.size()>0)
            {
                familyList =[select id,Family_Head_Name__c from Account where id in:FamilyIdSet];
            }
            if(familyList!=null && familyList.size()>0)
            {
                for(Account FamilyObj : familyList)
                {
                    Account clientHead = MapFamilytoClient.get(FamilyObj.id);
                    FamilyObj.Family_Head_Name__c =clientHead.id;
                    FamilyObj.sub_lob__c= clientHead.sub_lob__c;
                    //updatedFamily.add(FamilyObj);
                    updatedFamilyMap.put(FamilyObj.id, FamilyObj);
                }
            }
        
        //if(updatedFamily !=null && updatedFamily .size()>0){
        if(updatedFamilyMap !=null && updatedFamilyMap.size()>0){
            stopUpdateFamily = true;
            update updatedFamilyMap.values();
        
        }
         /*for(Account accountObj:accountList){
            if(!isUpdate){
                FAIdSet.add(accountObj.OwnerId);
                accountIdownerIdMap.put(accountObj.Id,accountObj.OwnerId);
            }else{
                Account oldAccountObj = accountOldMap.get(accountObj.Id);
                if(oldAccountObj.OwnerId != accountObj.OwnerId){
                    FAIdSet.add(accountObj.OwnerId);
                    accountIdownerIdMap.put(accountObj.Id,accountObj.OwnerId);
                }
            }
            
        } */
    
    }
    
    public static Map<Id,Id> getFAMappedCSO(Set<Id> FAIdSet){
        Map<Id,Id>FAIdCSOIdMap = new Map<Id,Id>();
        List<FA_CSO_Mapping__c>FACSOUsersList = new List<FA_CSO_Mapping__c>();
        if(FAIdSet!=null && FAIdSet.size()>0){
        
            FACSOUsersList = [Select f.Is_Mapped_CXO__c, f.Id, f.FA_User__c, f.CSO_User__c 
                          From FA_CSO_Mapping__c f
                          Where f.FA_User__c IN:FAIdSet];
        }
        for(FA_CSO_Mapping__c FACSOUser : FACSOUsersList){
            FAIdCSOIdMap.put(FACSOUser.FA_User__c,FACSOUser.CSO_User__c);   
        }
        return FAIdCSOIdMap;
    }
    
    // update critreria on basis of lead creteria 
    public static void updateCriteria(List<Account> accountList){
        
        if(accountList != null && accountList.size() > 0){
            for(Account accRecord : accountList){
                String strCat= accRecord.Lead_Category__c;
                if(strCat != null && strCat != ''){
                        if(strCat.equalsIgnoreCase('Corporate Treasury') || strCat.equalsIgnoreCase('Trusts') || strCat.equalsIgnoreCase('Institutions') )
                            accRecord.Category__c = 'Corporate'; 
                        else
                            accRecord.Category__c = 'Individual';
                    
                }
            }
        }
    }
    
    // update LDBQ last date
    public static void updateLeadDataBaseQueue(List<Account> accountList){
        List<System_Constant__mdt> sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Lead_Database_Span'];
        integer dayAdd = 180;
        if(sysConstant != null && sysConstant.size() > 0){
            dayAdd = integer.valueOf(sysConstant[0].Value__c);
        }       
        
        if(accountList != null && accountList.size() > 0){
            for(Account accRecord : accountList){
                system.debug('##############'+accRecord.IsValidLDBQ__c);
                if(accRecord.IsValidLDBQ__c){
                    Date myDate = Date.today();
                    Date newDate = mydate.addDays(dayAdd);
                    accRecord.Lead_Database_Due_Date__c = newDate;
                }
                system.debug('##############'+accRecord.Lead_Database_Due_Date__c); 
            }
        }
    }
    
    public static void copyFields(List<Account> accountList){
    
    	Id leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Lead');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
    	for(Account acc : accountList){
    		if(acc.recordTypeId == leadRecordTypeId){
    			acc.Mobile_1__c = acc.Phone;
    		}
            else if(acc.recordTypeId == clientRecordTypeId){
    			acc.Phone = acc.Mobile_1__c;
    		}
            MAP<ID , User> tempMap = EdelweissConstants.userList;
            User u1 = tempMap.get(acc.OwnerId);
             if(u1.Manager.email != null){
               acc.Account_Owner_RA_Email__c = u1.Manager.email;
            }
    	}
    }
    
    // Account record Share with LDBQ Public Group.
    public static void updateSharingRuleForLDBQ(List<Account> accountList, Map<Id,Account> OldMap){        
                
        List<Id> userId = New List<Id>();
        for(Account accRecord : accountList){
            userId.add(accRecord.OwnerId);
            if(accRecord.Lead_Database_Prvious_User__c != null)
                userId.add(accRecord.Lead_Database_Prvious_User__c);            
        }
        system.debug('userId##############'+userId);
        Map<Id,User> userZoneMap = new Map<Id,User>([SELECT Zone__c FROM User Where Id IN : userId]);
        Map<String,Id> groupZoneMap =  new Map<String,Id>();
        List<Group> userGrp = [SELECT DeveloperName,Id,Type FROM Group WHERE DeveloperName LIKE '%Lead_Database_Queue%' AND Type != 'Queue'];
        for(Group gr :userGrp){
            groupZoneMap.put(gr.DeveloperName,gr.Id);
        }
        system.debug('userZoneMap##############'+userZoneMap);
        system.debug('groupZoneMap##############'+groupZoneMap);
        List<AccountShare> newAccountShares = new List<AccountShare>();
        
        if(accountList != null && accountList.size() > 0){
            for(Account accRecord : accountList){ 
                 
                if(accRecord.coverage__c == 'Lead Database' && OldMap != null && OldMap.get(accRecord.Id).coverage__c != 'Lead Database'){                   
                    Account OldRecord = OldMap.get(accRecord.Id);            
                    String queueZone = 'Lead_Database_Queue_';
                    String strZone = '';
                    if(userZoneMap.containsKey(OldRecord.ownerId)){
                        User u = userZoneMap.get(OldRecord.ownerId);
                        system.debug('u##############'+u);
                        if(u != null && !string.isBlank(u.Zone__c))
                            strZone = u.Zone__c;
                    }
                    system.debug('strZone##############'+strZone);
                    if(!string.isBlank(strZone )){
                    queueZone = queueZone+strZone;
                    system.debug('queueZone##############'+queueZone);
                    AccountShare thisAccountShare = new AccountShare(); //a new empty AccountShare object
                    thisAccountShare.userorgroupid = groupZoneMap.get(queueZone);
                    thisAccountShare.accountid = accRecord.Id;
                    thisAccountShare.accountaccesslevel = 'Edit';
                    thisAccountShare.OpportunityAccessLevel = 'None';
                    thisAccountShare.CaseAccessLevel = 'None';
                        newAccountShares.add(thisAccountShare);
                    }

                }
                
            }
        }
        
        if(newAccountShares != null && newAccountShares.size() >0){
            database.insert(newAccountShares, true);
        }       
    }

    public static void updateSharingRuleForLeadDataBaseQueueToR0(List<Account> accountList,Map<Id,Account> oldAccountMap){
               
        List<AccountShare > sharesToDelete =  new List<AccountShare >();
        List<Id> accIds = new List<Id>();
        if(accountList != null && accountList.size() > 0){            
                              
            for(Account accRecord : accountList){               
                if(oldAccountMap != null){
                    Account oldAcc = oldAccountMap.get(accRecord.Id);          
                    if(oldAcc.coverage__c == 'Lead Database' && oldAcc.coverage__c != accRecord.coverage__c){
                        accIds.add(accRecord.Id);                        
                    }
                }                               
            }
            if(accIds != null && accIds.size() > 0){
                sharesToDelete = [Select Id, AccountId From AccountShare where AccountId=: accIds And RowCause = 'Manual'];
            }           
        }
        if (!sharesToDelete.isEmpty()) {
            delete sharesToDelete;
        }
    }

    // update LDBQ to R0
    public static void updateLeadDataBaseQueueToR0(List<Account> accountList,Map<Id,Account> oldAccountMap){               
        List<AccountShare > sharesToDelete =  new List<AccountShare >();
        String strProfileName = ''+EdelweissConstants.FAProfileName+'%';
        Map<Id,Profile> faProfileMAP = new Map<Id,Profile>([SELECT Name, Id FROM Profile WHERE Name Like :strProfileName]);
        List<Id> accIds = new List<Id>();
        if(accountList != null && accountList.size() > 0){
            
            List<Id> accIPSIds =  new List<Id>();
            for(Account accRecord : accountList){ 
                accIPSIds.add(accRecord.Id);
            }
            List<Investment_Policy_Statement_IPS__c> lstIPS = [Select Client_Name__c, Id From Investment_Policy_Statement_IPS__c Where Client_Name__c IN : accIPSIds];
            
            Map<Id,Investment_Policy_Statement_IPS__c> IPSMap = new Map<Id,Investment_Policy_Statement_IPS__c>();
            for(Investment_Policy_Statement_IPS__c IPS : lstIPS){ 
                IPSMap.put(IPS.Client_Name__c,IPS);
            }
            
            List<Account> addLDQAccount = new List<Account>();
            for(Account accRecord : accountList){               
                if(oldAccountMap != null){
                    Account oldAcc = oldAccountMap.get(accRecord.Id);
                    system.debug('accRecord.Lead_Database_Prvious_User__c'+accRecord.Lead_Database_Prvious_User__c);
                    system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
                    system.debug('oldAcc.coverage__c '+oldAcc.coverage__c );
                    
                    if(accRecord.Lead_Database_Prvious_User__c == UserInfo.getUserId() && oldAcc.coverage__c == 'Lead Database'){
                        accRecord.addError('Action Not Allowed!');
                    }else if(oldAcc.coverage__c == 'Lead Database' && faProfileMAP != null && faProfileMAP.containsKey(UserInfo.getProfileId())){
                        if(accRecord.coverage__c != 'R1')
                            accRecord.coverage__c = 'R0';
                        accRecord.IsValidLDBQ__c = true;
                        accRecord.Basic_Details_of_Mini_IPS_filled__c = false;
                        if(accRecord.coverage__c != 'R1')
                            accRecord.In_Person_Meeting_Done__c = false;
                        accRecord.Open_an_account_opening_Case__c = false;
                        accRecord.OwnerId = UserInfo.getUserId();
                        accIds.add(accRecord.Id);  
						addLDQAccount.add(accRecord);
                    }
                    
                    if(oldAcc != null && oldAcc.Lead_Category__c != accRecord.Lead_Category__c){
                        Investment_Policy_Statement_IPS__c IPSRecord = IPSMap.get(accRecord.Id);
                        string compare = oldAcc.Lead_Category__c;
                        string newSelected = accRecord.Lead_Category__c;
                        System.debug('**Old selected '+compare);
                        System.debug('*** newSelected'+newSelected);
						
						if(IPSRecord != null && accRecord.IsFilled_MINIIPS__c && ((newSelected.equals('Edelweiss Staff Account') && ((compare.equals('Trusts') || compare.equals('Corporate Treasury') || compare.equals('Institutions')))) || (!newSelected.equals('Edelweiss Staff Account')))){
                            accRecord.addError('Not allowed to change Lead Category after Mini IPS is created.');
                        }
                    }
                        
                }                               
            }
			
			if(addLDQAccount != null && addLDQAccount.size() > 0)
				updateLeadDataBaseQueue(addLDQAccount);
            
            if(accIds != null && accIds.size() > 0){
                sharesToDelete = [Select Id, AccountId From AccountShare where AccountId=: accIds And RowCause = 'Manual'];
            }           
        }
        if (!sharesToDelete.isEmpty()) {
            //delete sharesToDelete;
        }
    }   
    
    // update Owner for LDBQ
    public static boolean stopupdateOwnerLeadDataBase= false;
    public static void updateOwnerLeadDataBase(List<Account> accountList,Map<Id,Account> oldAccountMap){               
        
        List<User> users = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate'];
        if(!(users != null && users.size() > 0)){
            users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'];
        }
        if(accountList != null && accountList.size() > 0 && oldAccountMap != null){
            for(Account accRecord : accountList){ 
                Account accOld = oldAccountMap.get(accRecord.Id);
                if(accOld.coverage__c != 'Lead Database' && accRecord.coverage__c == 'Lead Database'){                    
                    accRecord.Lead_Database_Prvious_User__c = accRecord.ownerId;                    
                    accRecord.ownerId = users[0].Id;
                    stopupdateOwnerLeadDataBase = true;
                }
            }
        }
    }
    
    
//Sync Client Information in Contact
    
     public static void updateContact(List<Account> accountList, Map<Id,Account> OldMapAccount){               
        
         system.debug('accountList: '+accountList);
         system.debug('OldMapAccount: '+OldMapAccount);

        List<Contact> listContactForUpdate = new List<Contact>();
         List<Id> AccIds = New List<Id>();
         for (Account acc : accountList){
             AccIds.add(acc.Id);
         } 
         
         List<Contact> lstContact = [Select Id, Primary_Email__c, Secondry_Email__c, Gender__c, Birth_Date__c, MobilePhone, Mobile_1__c, Mobile_2__c, Mobile_3__c, Office_Phone__c, Official_Email__c, Official_Address__c, Residence_Address__c, Wedding_Anniversary__c, Nationality__c, AccountID From Contact Where AccountID IN : AccIds ];
         
         system.debug('QlstContact : '+ lstContact);
         
         Map<Id,Contact> contactAccountMAp =  new Map<Id,Contact>();     
         for(Contact cnt : lstContact){
            contactAccountMAp.put(cnt.AccountID,cnt); 
         }
         
         for(Account acc : accountList){
             if(contactAccountMAp.get(acc.Id) != null){
                 Contact cnt = contactAccountMAp.get(acc.Id);
                 if(OldMapAccount.get(acc.Id) != null){
                 
                 if(OldMapAccount.get(acc.Id).Primary_Email__c != acc.Primary_Email__c){
                    cnt.Primary_Email__c = acc.Primary_Email__c;
                 }
                 if(OldMapAccount.get(acc.Id).Secondary_Email__c != acc.Secondary_Email__c){
                    cnt.Secondry_Email__c = acc.Secondary_Email__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Gender__c != acc.Gender__c){
                    cnt.Gender__c = acc.Gender__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Date_of_Birth__c != acc.Date_of_Birth__c){
                    cnt.Birth_Date__c = acc.Date_of_Birth__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Phone != acc.Phone){
                    cnt.MobilePhone = acc.Phone;
                 } 
                 if(OldMapAccount.get(acc.Id).Mobile_1__c != acc.Mobile_1__c){
                    cnt.Mobile_1__c = acc.Mobile_1__c;
                 }
                 if(OldMapAccount.get(acc.Id).Mobile_2__c != acc.Mobile_2__c){
                    cnt.Mobile_2__c = acc.Mobile_2__c;
                 }
                 if(OldMapAccount.get(acc.Id).Mobile_3__c != acc.Mobile_3__c){
                    cnt.Mobile_3__c = acc.Mobile_3__c;
                 }
                 if(OldMapAccount.get(acc.Id).Office_Phone_Number__c != acc.Office_Phone_Number__c){
                    cnt.Office_Phone__c = acc.Office_Phone_Number__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Official_Email__c != acc.Official_Email__c){
                    cnt.Official_Email__c = acc.Official_Email__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Official_Address__c != acc.Official_Address__c){
                    cnt.Official_Address__c = acc.Official_Address__c;
                 }
                 if(OldMapAccount.get(acc.Id).Residence_Address__c != acc.Residence_Address__c){
                    cnt.Residence_Address__c = acc.Residence_Address__c;
                 }
                 if(OldMapAccount.get(acc.Id).Anniversary_Date__c != acc.Anniversary_Date__c){
                    cnt.Wedding_Anniversary__c = acc.Anniversary_Date__c;
                 } 
                 if(OldMapAccount.get(acc.Id).Nationality__c != acc.Nationality__c){
                    cnt.Nationality__c = acc.Nationality__c;
                 }
                }
                 
               listContactForUpdate.add(cnt);
             }
         }
        
        update listContactForUpdate; 
    }
    
    public static void addExtensionDays(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Id leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Lead');
        for(Account objNewAcc : newAccountMap.values()){
            if(objNewAcc.RecordTypeId == leadRecordTypeId && objNewAcc.ExtensionGranted__c == True && oldAccountMap.get(objNewAcc.Id).ExtensionGranted__c == False){
                system.debug('objNewAcc.IsValidLDBQ__c ###### : '+ objNewAcc.IsValidLDBQ__c);
                objNewAcc.Lead_Database_Due_Date__c = objNewAcc.Lead_Database_Due_Date__c.addDays(150);
                objNewAcc.IsValidLDBQ__c = true;
                system.debug('objNewAcc.IsValidLDBQ__c 333 ###### : '+ objNewAcc.IsValidLDBQ__c);
            }
        }
    }
    
    public Static void updateIPSFilledDateOnAccount(List<Account> accData)
    {
        List<Account> updateAccountList = new List<Account>();
        List<Id> accIds = New List<Id>();
        for(Account acc : accData){
            if(acc.MilesActivationDate__c != null)
            {
                DateTime MilesActivationDate = acc.MilesActivationDate__c.addMonths(12);
                acc.IPS_filled_Due_Date__c = Date.valueOf(MilesActivationDate);
            }
        }  
    }
    
    public Static void riskProfileHistory(List<Account> lstAcc,Map<Id,Account> oldMap)
    {
		Boolean isValueChanged = false;
        List<Risk_Profile_History__c> toBeUpdated = new  List<Risk_Profile_History__c>();
        for(Account newAccount : lstAcc){
         
         Account oldAccount = oldMap.get(newAccount.id);
            if(oldAccount.Risk_Profile_Based_on_IPS__c != newAccount.Risk_Profile_Based_on_IPS__c){
                Risk_Profile_History__c riskObj = new Risk_Profile_History__c();
           		riskObj.Old_Value__c = oldAccount.Risk_Profile_Based_on_IPS__c ;
                riskObj.New_Value__c = newAccount.Risk_Profile_Based_on_IPS__c;
                riskObj.Field__c    = 'Risk Profile Based on IPS';
                riskObj.Date__c = System.now();
                riskObj.User__c = newAccount.LastModifiedById;
                riskObj.Account__c = newAccount.Id;
              	toBeUpdated.add(riskObj);
            }
            if(oldAccount.Risk_Profile_Categories__c != newAccount.Risk_Profile_Categories__c){
                Risk_Profile_History__c riskObj = new Risk_Profile_History__c();
           		riskObj.Old_Value__c = oldAccount.Risk_Profile_Categories__c ;
                riskObj.New_Value__c = newAccount.Risk_Profile_Categories__c;
                riskObj.Field__c    = 'Risk Profile Categories';
                riskObj.Date__c = System.now();
                riskObj.User__c = newAccount.LastModifiedById;
                riskObj.Account__c = newAccount.Id;
              	toBeUpdated.add(riskObj);
            }
            if(oldAccount.Mandate__c != newAccount.Mandate__c){
                Risk_Profile_History__c riskObj = new Risk_Profile_History__c();
           		riskObj.Old_Value__c = String.valueOf(oldAccount.Mandate__c);
                riskObj.New_Value__c = String.valueOf(newAccount.Mandate__c);
                riskObj.Field__c    = 'Mandate';
                riskObj.Date__c = System.now();
                riskObj.User__c = newAccount.LastModifiedById;
                riskObj.Account__c = newAccount.Id;
              	toBeUpdated.add(riskObj);
            }
            
        }
        
        if(toBeUpdated!=null && !toBeUpdated.isEmpty()) {
            database.insert(toBeUpdated,false);
        }
        	
    }
	
	public Static void rollupCreditEligibility(List<Account> lstAcc,Map<Id,Account> oldMap)
    {
        List<Id> accIds = New List<Id>();
        for(Account acc : lstAcc){			
            if(acc.Credit_Eligibility__c != null && acc.ParentId != null && oldMap != null && oldMap.get(acc.Id) != null)
            {
                Account old = oldMap.get(acc.Id);
				if(acc.Credit_Eligibility__c !=  old.Credit_Eligibility__c )
					accIds.add(acc.ParentId);
            }
        }		
		if(accIds != null && accIds.size() > 0){
			List<Account> tobeUpdate = [Select Id,Family_Credit_Eligibility__c, (Select Id, Credit_Eligibility__c From ChildAccounts) From Account Where Id =: accIds];
			
			if(tobeUpdate != null && tobeUpdate.size() >0){
				for(Account acc : tobeUpdate){
					acc.Family_Credit_Eligibility__c = 0;
					for(Account child : acc.ChildAccounts){
						if(child.Credit_Eligibility__c != null)
							acc.Family_Credit_Eligibility__c += child.Credit_Eligibility__c;
					}
				}				
				database.update(tobeUpdate,true);				
			}
		}	
    }

    public static void shareWithReferar(List<Account> lstAcc, Map<Id, Account> mapOldAcc){
        
        Set<Id> setOfAccountIds = new Set<Id>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        Id leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Lead');
        for(Account acc : lstAcc){
            if(Trigger.isInsert && acc.Referrer_Contact__c != null){
                setOfAccountIds.add(acc.Id);
            }
            else if(Trigger.isUpdate && acc.Referrer_Contact__c != null && mapOldAcc.get(acc.Id).Referrer_Contact__c != acc.Referrer_Contact__c ){
                setOfAccountIds.add(acc.Id);
            }
            else if(Trigger.isUpdate && acc.Referrer_Contact__c != null && leadRecordTypeId==acc.RecordTypeId && mapOldAcc.get(acc.Id).OwnerId != acc.OwnerId){
                setOfAccountIds.add(acc.Id);
            }
        }
        if(!setOfAccountIds.isEmpty()){
            Map<Id, String> mapAccountIdEmail = new Map<Id, String>();
            Map<String, Id> mapEmailUserId = new Map<String, Id>();
            
            Map<Id, Account> mapAccount = new Map<Id, Account>([
                SELECT Id, Referrer_Contact__r.Email, OwnerId FROM Account WHERE Id IN :setOfAccountIds
            ]);
            for(Account a : mapAccount.values()){
                mapAccountIdEmail.put(a.Id, a.Referrer_Contact__r.Email);
            }
            
            List<User> lstUser = [
                SELECT Id, Email FROM User WHERE Email IN :mapAccountIdEmail.values()
            ];
            for(User u : lstUser){
                mapEmailUserId.put(u.Email, u.Id);
            }
            for(Id accId : mapAccountIdEmail.keySet() ){
                if(mapAccountIdEmail.get(accId) != null 
                   	&& mapEmailUserId.get(mapAccountIdEmail.get(accId)) != null
                  	&& mapAccount.get(accId).OwnerId != mapEmailUserId.get(mapAccountIdEmail.get(accId))){
                    AccountShare accountShareObj = new AccountShare(AccountId = accId, UserOrGroupId = mapEmailUserId.get(mapAccountIdEmail.get(accId)), AccountAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read', RowCause='Manual', OpportunityAccessLevel='Read');
                    accountShareList.add(accountShareObj);
                }
            }
        }
        
        if(!accountShareList.isEmpty()){
            insert accountShareList;
        }
    }
}