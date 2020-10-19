public class EventTriggerHandler{
    public static boolean stopEventTrigger= false;
     public static boolean updateClientOnEventTrigger= false;
    public static void updateLeadOnMeetingCompletion(List<Event> eventList){
        
     
     }
     
     public static void updateLeadOnMeetingCreation(List<Event> eventList){
        
     
         
     }
     public static void updateOpportunityOnMeetingCompletion(List<Event> eventList){
       
     
     }
     
     public static void verifyAttendee(List<Event> eventList){
       Set<Id>accountIdSet  = new Set<Id>();
       List<Account>accountList = new List<Account>();
       Map<Id,Id>eventIdAccountIdMap = new Map<Id,Id>();
       Map<Id,Account> accountIdObjMap = new Map<Id,Account>();
       Id clientEventRecordTypeId =  EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
       Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family'); 
       Map<Id,set<Id>> eventIdAttenddeIdSetMap = new Map<Id,set<Id>>();
       
       for(Event eventObj : eventList){
          if(eventObj.WhatId!=null && eventObj.WhatId.getSObjectType() == Account.sObjectType ){
            
            accountIdSet.add(eventObj.WhatId);
            eventIdAccountIdMap.put(eventObj.Id,eventObj.WhatId);
          }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){
          accountList = [SELECT Id, Coverage__c,Focus_30__c,Share_of_Wallet_For_Client__c,Total_AUM_INR_Cr__c,High_Priority__c,Rollup_AUM_of_Family__c,Mandate__c,Asset_Classes_Count__c,Family_Networth__c 
                                       FROM Account
                                       WHERE 
                                          RecordTypeId =: familyRecordTypeId 
                                          AND Id IN:accountIdSet
                                      ];
        
        }
        
        for(Account accountObj:accountList){
          accountIdObjMap.put(accountObj.id,accountObj);
        }
        
       if(eventIdAccountIdMap!=null && !eventIdAccountIdMap.isEmpty()){
         eventIdAttenddeIdSetMap = getAttendiesSetMap(eventIdAccountIdMap.keySet());
       }
       for(Event eventObj : eventList){
         if(eventObj.RecordTypeId == clientEventRecordTypeId  
               && (eventObj.Status__c == 'Open' || eventObj.Status__c == 'Completed')
               && eventObj.Type== 'Meeting' && eventObj.WhatId!=null && eventObj.WhatId.getSObjectType() == Account.sObjectType && eventObj.Type_of_Communication__c == 'In-Person'){
           Id accountId = eventIdAccountIdMap.get(eventObj.Id);
           Account familyObj = accountIdObjMap.get(accountId);
           Integer criteriaNumber = AccountTriggerhandler.checkCriteria(familyObj);
           system.debug('=====criteriaNumber==='+criteriaNumber);
           if(criteriaNumber == 2 ||criteriaNumber == 3){
                     Boolean found = false;
                     if(eventIdAttenddeIdSetMap!=null && !eventIdAttenddeIdSetMap.isEmpty()){
                       for(Id attendeeId:eventIdAttenddeIdSetMap.get(eventObj.Id)){
                         if(EdelweissConstants.IAGContactMap.containsKey(attendeeId)){
                           system.debug('=========In Found True========');
                           found = true;
                           break;
                         }
                       }
                     
                     }
                     if(!found){
                       eventObj.addError('Add IAG member to Attendee List'); 
                     }
               }
          }
       }
     }
     public static void updateClient(List<Event> eventList){
        Set<Account>updatedClientSet = new Set<Account>();
        
		Map<Id,Account> updatedClientSetMap = new Map<Id,Account>();
        Set<Id>accountIdSet  = new Set<Id>();
        List<Account>updatedClientList = new List<Account>();   
        List<Account>accountList = new List<Account>();   
        Map<Id,Account> accountIdObjMap = new Map<Id,Account>(); 
        Map<Id,Id>eventIdAccountIdMap = new Map<Id,Id>();  
        List<Id> AccountRecordTypeId = new List<Id>();
        AccountRecordTypeId.add(EdelweissConstants.AccountRecordTypeMap.get('Family'));
        AccountRecordTypeId.add(EdelweissConstants.AccountRecordTypeMap.get('Lead'));
        Set<Id>clientIdSet = new Set<Id>();
        
        Id genericEventRecordTypeId =  EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');  
        List<Id> userIds = new List<Id>();
        List<Id> eventIds = new List<Id>();
        List<Id> ContactIds = new List<Id>();
        for(Event eventObj : eventList){
          if(eventObj.WhatId!=null && eventObj.WhatId.getSObjectType() == Account.sObjectType ){
            accountIdSet.add(eventObj.WhatId);
            eventIdAccountIdMap.put(eventObj.Id,eventObj.WhatId);
            userIds.add(eventObj.ownerId);
            //if(eventObj.Tag_Another_User__c != null)
                //userIds.add(eventObj.Tag_Another_User__c);
                       
            eventIds.add(eventObj.Id);
          }
        }
                
        if(accountIdSet!=null && accountIdSet.size()>0){
          accountList = [SELECT Id,createdById,Interaction_Meeting_Done_Counter__c, Coverage__c,Focus_30__c,Total_AUM_INR_Cr__c,Share_of_Wallet_For_Client__c,High_Priority__c,Rollup_AUM_of_Family__c,Mandate__c,Asset_Classes_Count__c, 
          In_Person_Meeting_Done__c,Last_In_Person_Meeting_Date__c,RecordTypeId,Last_Interraction_Date_Phone_InPerson__c , R5_FA_PFReview__c,R3_FA_PFReview__c, R5_ProductManager_Interaction__c,R5_RHBHPH_Interaction__c,R5_TL_Interaction__c,R4_TL_Interaction__c,R5_FA_Interaction__c ,R4_FA_Interaction__c,R3_FA_Interaction__c,OwnerId,Event_Creation_DateTime__c,Last_RHBHPH_Interaction_Date__c,How_Often_Does_Client_Monitor_Portfolio__c,Last_Interaction_Date__c, Last_TL_Interaction_Date__c,Family_Networth__c
                                       FROM Account
                                       WHERE 
                                          RecordTypeId IN: AccountRecordTypeId 
                                          AND Id IN:accountIdSet
                                      ];
        
        }
        
        for(Account accountObj:accountList){
          accountIdObjMap.put(accountObj.id,accountObj);
          userIds.add(accountObj.ownerId);
        }
        
        //User Profile query 
        
        List<EventWhoRelation> eventRelation = [SELECT EventId,RelationId FROM EventWhoRelation WHERE EventId =: eventIds AND Type = 'Contact'];
        system.debug('eventRelation:'+eventRelation);
        Map<Id,List<Id>> EventContactIdMap = new Map<Id,List<Id>>();
        for(EventWhoRelation er : eventRelation){
            List<Id> ctId = new List<Id>();         
            if(EventContactIdMap.containsKey(er.EventId)){
                ctId = EventContactIdMap.get(er.EventId);               
            }
            ctId.add(er.RelationId);
            EventContactIdMap.put(er.EventId,ctId);
            ContactIds.add(er.RelationId);
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        if(ContactIds != null && ContactIds.size() > 0){
            contactMap = new Map<Id,Contact>([Select OwnerId From Contact Where Id =: ContactIds]);
            if(contactMap != null && contactMap.values().size() > 0 ){
                for(Contact cntc : contactMap.values()){
                    userIds.add(cntc.OwnerId);
                }
            }
        }
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id,ProfileId, Profile.Name FROM User Where Id In : userIds]);
        
        for(Event eventObj : eventList){
            Id accountId = eventIdAccountIdMap.get(eventObj.Id);
            
            if(eventObj.RecordTypeId == genericEventRecordTypeId && eventObj.Status__c == 'Completed' && eventObj.WhatId!=null
               && eventObj.WhatId.getSObjectType() == Account.sObjectType && accountIdObjMap.get(eventObj.WhatId) != null ){
                
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
				system.debug('quarterMonthMap:'+quarterMonthMap);
				boolean isCQuaterIntraction = false;
				for(Set<Integer> months : quarterMonthMap.values()){
					if(months.contains(CurrentMonth) && months.contains(evntEndMonth)){						
						isCQuaterIntraction = true;
					}
				}
				system.debug('isCQuaterIntraction:'+isCQuaterIntraction);
				
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
				system.debug('BiAnnualMonthMap:'+BiAnnualMonthMap);
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
				system.debug('biMonthlyMonthMap:'+biMonthlyMonthMap);
				boolean isBiMonthlyIntraction = false;
				for(Set<Integer> months : biMonthlyMonthMap.values()){
					if(months.contains(CurrentMonth) && months.contains(evntEndMonth)){						
						isBiMonthlyIntraction = true;
					}
				}

				system.debug('isCBiAnnualIntraction:'+isCBiAnnualIntraction);
				system.debug('isCQuaterIntraction:'+isCQuaterIntraction);
				system.debug('isCMonthIntraction:'+isCMonthIntraction);
                system.debug('isBiMonthlyIntraction:'+isBiMonthlyIntraction);
							 
				 Account familyObj = accountIdObjMap.get(accountId);
                 Integer criteriaNumber = AccountTriggerhandler.checkCriteria(familyObj);
                 //Account clientObj = new Account(id = eventObj.WhatId);
                 Account clientObj;
                 if(updatedClientSetMap.containsKey(eventObj.WhatId)){
                 	clientObj = updatedClientSetMap.get(eventObj.WhatId);
                 }
                 else{
                 	clientObj = accountIdObjMap.get(eventObj.WhatId);
                 }
                  
                 
                 //update In persone meeting flag and move to R0 to R1 stage
                 system.debug('clientObj.Coverage__c:'+clientObj.Coverage__c);
                 if(eventObj.Type_of_Communication__c == 'In-Person' && (clientObj.Coverage__c == 'R0' ||clientObj.Coverage__c == 'Lead Database')){
                   clientObj.In_Person_Meeting_Done__c = true;
                   clientObj.Coverage__c = 'R1';
                 }
                  Boolean isFAOwner = (userMap.get(eventObj.ownerId) != null && userMap.get(eventObj.ownerId).Profile.Name.containsIgnoreCase('Financial Advisor')) ? true : false;
					System.debug('**** Account'+clientObj.createdById);
                   	System.debug('***'+eventObj.ownerId);
                   if(clientObj.ownerId == eventObj.ownerId){
                   Date myDate = date.newinstance(eventObj.EndDateTime.year(), eventObj.EndDateTime.month(), eventObj.EndDateTime.day());
                   if(eventObj.Type_of_Communication__c == 'In-Person' && clientObj.RecordTypeId == EdelweissConstants.AccountRecordTypeMap.get('Family')){
                   	if(clientObj.Last_In_Person_Meeting_Date__c < eventObj.EndDateTime ){
                        //clientObj.Last_In_Person_Meeting_Date__c = eventObj.EndDateTime;
                         myDate = date.newinstance(eventObj.EndDateTime.year(), eventObj.EndDateTime.month(), eventObj.EndDateTime.day());
						clientObj.Last_In_Person_Meeting_Date__c = myDate;
                  	 }else if(clientObj.Last_In_Person_Meeting_Date__c == null){
                         System.debug('Inside 44s');
                           		//clientObj.Last_In_Person_Meeting_Date__c = eventObj.EndDateTime;
                           		clientObj.Last_In_Person_Meeting_Date__c = myDate;
                       }
                       if(clientObj.Last_Interraction_Date_Phone_InPerson__c < eventObj.EndDateTime ){
                           clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                           //clientObj.Last_Interraction_Date_Phone_InPerson__c   = eventObj.EndDateTime;
                       }else if(clientObj.Last_Interraction_Date_Phone_InPerson__c == null){
                           clientObj.Last_Interraction_Date_Phone_InPerson__c =	myDate;
                           		//clientObj.Last_Interraction_Date_Phone_InPerson__c = eventObj.EndDateTime;
                       }
                   }
                   if(eventObj.Type_of_Communication__c == 'Phone' && clientObj.RecordTypeId == EdelweissConstants.AccountRecordTypeMap.get('Family')){
                       if(clientObj.Last_Interraction_Date_Phone_InPerson__c < eventObj.EndDateTime ){
                           //clientObj.Last_Interraction_Date_Phone_InPerson__c   = eventObj.EndDateTime;
                           clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                       }else if(clientObj.Last_Interraction_Date_Phone_InPerson__c == null){
                           clientObj.Last_Interraction_Date_Phone_InPerson__c = myDate;
                           		//clientObj.Last_Interraction_Date_Phone_InPerson__c = eventObj.EndDateTime;
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
                    
                    system.debug('EventContactIdMap:'+EventContactIdMap);
                    system.debug('contactMap:'+contactMap);
                    system.debug('userMap:'+userMap);
                    system.debug('eventObj.Id:'+eventObj.Id);
                    
                    if(contactMap != null && EventContactIdMap != null && EventContactIdMap.containsKey(eventObj.Id)){
                        List<id> ContIds = EventContactIdMap.get(eventObj.Id);
                        for(id contactId : ContIds){
                            Contact cntc = contactMap.get(contactId);
                            if(cntc != null && userMap.get(cntc.OwnerId) != null){
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Financial Advisor')){
                                    isTagFA = true; 
                                }
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Regional Head')){
                                    isTagRH = true; 
                                }
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Business Head')){
                                    isTagBH = true; 
                                }
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Product Manager')){
                                    isTagPM = true; 
                                }
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Team Leader Advisory')){
                                    isTagTL = true; 
                                }
                                if(userMap.get(cntc.OwnerId).Profile.Name.containsIgnoreCase('Product Head')){
                                    isTagPH = true; 
                                }
                            }
                        }
                    }
						
					system.debug('isCBiAnnualIntraction:'+isCBiAnnualIntraction);
					system.debug('isCQuaterIntraction:'+isCQuaterIntraction);
					system.debug('isCMonthIntraction:'+isCMonthIntraction);
                    system.debug('isBiMonthlyIntraction:'+isBiMonthlyIntraction); 
                     
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
								if(clientObj.Last_Portfolio_Review_Date__c != null && clientObj.Last_Portfolio_Review_Date__c < evntEndDate)
									clientObj.Last_Portfolio_Review_Date__c = evntEndDate;
								else if(clientObj.Last_Portfolio_Review_Date__c == null )
									clientObj.Last_Portfolio_Review_Date__c = evntEndDate;
							}
						//}                        
                        //isPortfolioDone = true;
                    }
                    
                    //Interaction Logic
                    if(!isPortfolioDone){
                        system.debug('isFAOwner:'+isFAOwner);
                        system.debug('isTagFA:'+isTagFA);
                        system.debug('isRHOwner:'+isRHOwner);
                        system.debug('isBHOwner:'+isBHOwner);
                        system.debug('isPHOwner:'+isPHOwner);
                        system.debug('isTagRH:'+isTagRH);
                        system.debug('isTagBH:'+isTagBH);
                        system.debug('isTagPH:'+isTagPH);
                        system.debug('isPMOwner:'+isPMOwner);
                        system.debug('isTLOwner:'+isTLOwner);
                        system.debug('isTagTL:'+isTagTL);
                        system.debug('isTagPM:'+isTagPM);
                        system.debug('clientObj.Coverage__c:'+clientObj.Coverage__c);					
                        
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
								if(clientObj.Last_TL_Interaction_Date__c != null && clientObj.Last_TL_Interaction_Date__c < evntEndDate)
									clientObj.Last_TL_Interaction_Date__c = evntEndDate;
								else if(clientObj.Last_TL_Interaction_Date__c == null)
									clientObj.Last_TL_Interaction_Date__c = evntEndDate;
							}                               
                            if((isFAOwner || isTagFA )){
								if(clientObj.Last_Interaction_Date__c != null && clientObj.Last_Interaction_Date__c < evntEndDate)
									clientObj.Last_Interaction_Date__c = evntEndDate;
								else if(clientObj.Last_Interaction_Date__c == null)
									clientObj.Last_Interaction_Date__c = evntEndDate;								
							}
                            if((isRHOwner || isBHOwner || isPHOwner || isTagRH || isTagBH || isTagPH ) && clientObj.Coverage__c == 'R5'){
								if(clientObj.Last_RHBHPH_Interaction_Date__c != null && clientObj.Last_RHBHPH_Interaction_Date__c < evntEndDate)
									clientObj.Last_RHBHPH_Interaction_Date__c = evntEndDate;
								else if(clientObj.Last_RHBHPH_Interaction_Date__c == null)
									clientObj.Last_RHBHPH_Interaction_Date__c = evntEndDate;
							}                                
                        }
                        
                    }
                 
                 /*if(eventObj.RA_RH_Meeting__c && criteriaNumber !=1){
                   clientObj.RH_BH_Meeting_Done__c = true;
                 }*/
               clientObj.Event_Creation_DateTime__c = DateTime.now().getTime();   
               //updatedClientSet.add(clientObj);
               updatedClientSetMap.put(clientObj.Id,clientObj);
            }
            
        }
        updatedClientList.addAll(updatedClientSetMap.values());
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
     public static Map<Id,set<Id>> getAttendiesSetMap(Set<Id>eventIdSet){
       Map<Id,set<Id>>eventIdAtendeeIdSetMap = new Map<Id,set<Id>>();
       List<EventRelation> eventrelationList = [SELECT  RelationId, Id, EventId FROM EventRelation WHERE EventId IN:eventIdSet];
       system.debug('eventrelationList==========='+eventrelationList.size());
       Set<Id>atendeeIdSet = new Set<Id>();
       for(EventRelation eventRelObj:eventrelationList){
         
         if(!eventIdAtendeeIdSetMap.isEmpty() && eventIdAtendeeIdSetMap.containsKey(eventRelObj.EventId)){
           atendeeIdSet = eventIdAtendeeIdSetMap.get(eventRelObj.EventId);
           if(eventRelObj.RelationId.getSObjectType() == Contact.sObjectType){
             atendeeIdSet.add(eventRelObj.RelationId);
             system.debug('===========IN Ateendde if=='+eventRelObj.RelationId);
             eventIdAtendeeIdSetMap.put(eventRelObj.EventId,atendeeIdSet);
           }
           
           
           
         }else{
           atendeeIdSet = new Set<Id>();
           if(eventRelObj.RelationId.getSObjectType() == Contact.sObjectType){
             atendeeIdSet.add(eventRelObj.RelationId);
             system.debug('===========IN Ateendde else=='+eventRelObj.RelationId);
             eventIdAtendeeIdSetMap.put(eventRelObj.EventId,atendeeIdSet);
           }
           
           
           
           
         }
       }
       return eventIdAtendeeIdSetMap;
     }
     public static void validateSalesOpp(List<Event>eventList){
       
     }
     /***************************************************************************************************************
     *   Method:         markEventStatusCompleted 
     *   Description:    > Called before insert and update of Event.
                         > This method marks the Event as Completed if the End Date is a Past Date and Comments or 
                           Description have been provided.
     *****************************************************************************************************************/
     public static void markEventStatusCompleted(List<Event> lstEvent)
     {
        for(Event evnt:lstEvent)
        {
            if(evnt.EndDateTime<System.now() && (evnt.Description__c!=null||evnt.Description__c!='')){
                evnt.Status__c='Completed';
        }
        }
    }
	
	public static void createEventonFamilyFromClient(List<Event> eventList){
        Set<Id>contactIdSet  = new Set<Id>();
		Set<Id>accountIdSet  = new Set<Id>();
        List<Account>accountList = new List<Account>();   
        Map<Id,Account> accountIdObjMap = new Map<Id,Account>(); 
		Map<Id,Contact> ContactIdObjMap = new Map<Id,Contact>();
        List<Id> AccountRecordTypeId = new List<Id>();
		AccountRecordTypeId.add(EdelweissConstants.AccountRecordTypeMap.get('Client'));
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');  
       
		//Who
        List<Id> ContactIds = new List<Id>();
        for(Event eventObj : eventList){
          if(eventObj.WhoId!=null && eventObj.WhoId.getSObjectType() == Contact.sObjectType ){
            contactIdSet.add(eventObj.WhoId);
          }
        }
		List<Contact> lstContact = new List<Contact>();
		Id contactRecordTypeId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(EdelweissConstants.EDELWEISS_CONTACT_RECORD_TYPE).getRecordTypeId();
		if(contactIdSet != null && contactIdSet.size() > 0){
			lstContact = [SELECT recordTypeId,Id,AccountId 
                                       FROM Contact
                                       WHERE Id IN:contactIdSet AND AccountId != NULL AND RecordTypeId =: contactRecordTypeId 
                                      ];
		}
		
		if(lstContact != null && lstContact.size() > 0){
			for(Contact cnt : lstContact){
				accountIdSet.add(cnt.AccountId);
				ContactIdObjMap.put(cnt.id,cnt);
			}
		}		
                
        if(accountIdSet!=null && accountIdSet.size()>0){
          accountList = [SELECT recordTypeId,Name,Id,ParentId , OwnerId
                                       FROM Account
                                       WHERE Id IN:accountIdSet AND ParentId != NULL AND RecordTypeId =: clientRecordTypeId 
                                      ];        
        }
        
        for(Account accountObj:accountList){
          accountIdObjMap.put(accountObj.id,accountObj);
        }		
		List<Event> eventlst = new List<Event>();
        
        for(Event eventObj : eventList){            
            if(eventObj.WhoId!=null && eventObj.WhoId.getSObjectType() == Contact.sObjectType && ContactIdObjMap.get(eventObj.WhoId) != null ){				
				Contact cntRecord = ContactIdObjMap.get(eventObj.WhoId);
				if(accountIdObjMap != null && accountIdObjMap.get(cntRecord.AccountId) != null){
					Account clientAcc = accountIdObjMap.get(cntRecord.AccountId);				
					Event familyEvent = eventObj.clone(false, false, false, false);
					familyEvent.WhatId = clientAcc.ParentId;
					familyEvent.WhoId = null;
					eventlst.add(familyEvent);	
				}							   
			   }
		}
		if(eventlst != null && eventlst.size() > 0){
			database.upsert(eventlst,true);
        }     
	}
    
    public static void sendEmailToTL(List<Event> eventList){
        Set<Id>accountIdSet  = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<String> emailUsers = new List<String>();
        for(Event eventObj : eventList){
            if(eventObj.WhatId!=null && eventObj.Agenda__c == 'Portfolio Review'){
                accountIdSet.add(eventObj.WhatId);
            }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){
            accountMap = new Map<Id,Account>([
                SELECT Id,Name, OwnerId, Owner.Name, Owner.Email,Owner.Manager.Email,Owner.Manager.Profile.Name
                FROM Account WHERE Id IN:accountIdSet
            ]);
        }
        System.debug('accountMap'+accountMap);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        List<String> toAddresstemp = new List<String>();
        for(Event eventObj : eventList){
            Account a = accountMap.get(eventObj.WhatId);
            if(a != null){
            	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                toAddress.add(a.Owner.Email);
                ccAddress.add(a.Owner.Manager.Email);
	            mail.setToAddresses(toAddress);
	            mail.setCcAddresses(ccAddress);
	            mail.setSubject('Portfolio Review Summary');
	            mail.htmlBody = getEmailBody(eventObj, a.Owner.Name, a);
	            mails.add(mail);
           }  
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);      
        }
        
    }   
    
    public static String getEmailBody(Event e, String mailTo, Account acc){
        String familyName = acc.Name;
        date startDate = date.newinstance(e.StartDateTime.year(),e.StartDateTime.month(),e.StartDateTime.day());
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();       
        String EventUrl = baseUrl + '/' + e.Id;
        String startBody ='</table></br></br>This is to inform you that the portfolio review was done on '+startDate.format()+' for '+familyName+' has been successfully completed. Below is a snapshot for your perusal, kindly log into to Salesforce for a detailed view.</br>';
        String emailBody =  '<p style="font-family:Calibri;"> Hi '+ mailTo +','+startBody+
            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:45%;">' +
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Event URL</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px"><a href="'+EventUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + e.id + '</a></td></tr>' +
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Primary purpose of this portfolio</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Primary_Purpose_Of_Portfolio__c)+ '</a></td></tr>' +
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Others__c</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+returnEmptyForNull(e.Others__c)+ '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Client’s Return Expectation</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Expectation_From_Portfolio__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Portfolio In Sync With Objectives?</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Is_portfolio_In_Sync__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Measures Being Proposed To Address gaps</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Concerns__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Scrutiny/Closer Monitoring Required?</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.scrutiny__c)+ '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Investments/Alternates Provided</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Investments_And_Alternates_Provided__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Client Satisfied With Portfolio Review?</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull(e.Is_Client_Satisfied_On_Portfolio_Review__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Reason For Dissatisfaction</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull( e.Reason_For_Dissatisfaction__c) + '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">Is Requested To Change Portfolio Review</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull( e.Is_Requested_Tochange_Portfolio_Review__c )+ '</a></td></tr>'+
            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:5px">How Often Does Client Monitor Portfolio</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:5px">'+ returnEmptyForNull( e.How_Often_Does_Client_Monitor_Portfolio__c )+ '</a></td></tr>';
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + endBody); 
    }
    public static String returnEmptyForNull(String str){
        if(null == str || str.trim() == ''){
           return ''; 
        }
        return str;
    }
    
}