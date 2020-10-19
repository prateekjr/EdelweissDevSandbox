public class TaskManagementTriggerHandler {
    public static boolean stopTaskTrigger = false;
    
    public static Map<Id, Case> getCaseDetails(Set<Id> caseIds){
        Map<Id, Case> mapCase = new Map<Id, Case>([
            SELECT Phone__c,Salutation__c,Family__c,Current_FA__c,Address_Line_1__c,State__c,City__c,Country__c,PinCode__c,Single_Joint__c,Address__c,Email_Id__c,Joint_Holder_Client2_Contact_Number__c,Joint_Holder_Client2_Email_ID__c,Joint_Holder_Client2_Aadhar_Number__c,
            Address_Line_2__c,Joint_Holder_Client2_Name__c,Joint_Holder_Client1_Aadhar_Number__c,Joint_Holder_Client1_Name__c,Joint_Holder_Client1_Contact_Number__c,Joint_Holder_Client1_Email_ID__c,Account.Risk_Profile_Based_on_IPS__c , Aadhar_number__c , Delivery_Slab__c,Delivery_Minimum_P__c,Delivery_Sides__c,
            Intraday_Minimum_P__c,Intraday_Sides__c, Intraday_Slab__c,Currency_Futures_Minimum_P__c,Currency_Futures_Sides__c,Currency_Futures_Slab__c,
            Currency_Options_Minimum_P__c,Currency_Options_Sides__c,Currency_Options_Slab__c,CaseNumber, Special_Brokerage_Approval_Status__c, Special_Brokerage_RM_Approval_Required__c,
            Derivatives_Futures_Minimum_P__c,Derivatives_Futures_Sides__c,Derivatives_Options_Minimum_P__c,Derivatives_Options_Sides__c, Joint_Holder_Client1_Entity_Type__c, Joint_Holder_Client2_Entity_Type__c,
            Derivatives_Options_Slab__c,Derivatives_Futures_Slab__c,DOB_DOI__c,Entity_Type__c,CIN_Number__c,Number_of_Joint_Holders_Max_2__c,Joint_Holder_Client1_PAN_Number__c,Joint_Holder_Client1_DOB_DOI__c,Joint_Holder_Client2_PAN_Number__c,Joint_Holder_Client2_DOB_DOI__c,Is_Family_Head__c,IsNewFamily__c,MainLead__c,
            IsNewClient__c,recordTypeId,CreatedDate, Status, AccountId, Account.OwnerId, Account.Name, Account.recordTypeId, KRA_Status__c, POA__c, Lead_Account__c, Product_Type__c, Case_Type__c, Meeting_Fixed__c, PAN_Number__c, Account.GWM_Online_Id__c,Account.Family_Head_Name__c,Account.Family_Head_Name__r.Name,Account.Family_Head_Name__r.Pan_Number__c,MainLead__r.Name,MainLead__r.Pan_Number__c, MainLead__r.Recordtype.Name,MainLead__r.Parent.Family_Head_Name__c,MainLead__r.Parent.Family_Head_Name__r.Name,MainLead__r.Parent.Family_Head_Name__r.Pan_Number__c,MainLead__r.Family_Head_Name__c,MainLead__r.Family_Head_Name__r.Name,MainLead__r.Family_Head_Name__r.Pan_Number__c, 
            isCorporate__c ,Equity_Markets__c,Age_RiskProfile__c,Investment_philosophy__c,Investment_goal__c,Financial_Goals__c,worst_and_best_one_year_return__c,
            Amount_of_fluctuations__c,Interest_in_leverage_borrowing_products__c,Alternative_Investments__c,
            Diversified_portfolio__c,Investment_portfolio__c,Investment_Style__c,Alternative_Investments_Non_Ind1__c,Alternative_Investments_Non_Ind__c,Interest_leverage_products_Non_Ind1__c,Interest_leverage_products_Non_Ind__c,worst_and_best_one_year_return_Non_Ind__c,worst_and_best_one_year_return_Non_Ind_1__c, Risk_Profile_Categories__c,Time_line_for_Trading__c,Amount_of_fluctuations_Non_Ind_1__c,Amount_of_fluctuations_Non_Ind__c,(SELECT Id, Name, Pan_Number__c FROM Additional_Leads__r)
            FROM Case WHERE id =: caseIds
        ]);
        return mapCase;
    }
    
    public static void createSequenceTask(List<Task> currentTaskList, Map<Id,Task>oldTask){
        List<Task> newTaskList = new List<Task>{};
        String isNewClient = 'FALSE';
        Map<Integer, String> message = new Map<Integer, String>{};
        Set<Id> caseIds = new Set<Id>(); 
        for(Task t : currentTaskList){
            caseIds.add(t.WhatId);
        }

        Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(caseIds);
        
        if(currentTaskList != null && currentTaskList.size() > 0){
            for(Task currentTaskRecord : currentTaskList){
                Task oldObj = oldTask.get(currentTaskRecord.Id);
                /* Update only when the status is changed to completed. */
                if((currentTaskRecord.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) || currentTaskRecord.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.BANK_ACCOUNT_TASK_RECORD_TYPE)|| currentTaskRecord.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.TRADING_DEMAT)) && currentTaskRecord.Status != oldObj.Status && currentTaskRecord.Status == EdelweissConstants.TASK_COMPLETED_STATUS)
                {
                    
                    
                    Case relatedCase = mapCases.get(currentTaskRecord.WhatId);
                     
                    /* Check stage dependencies and produce error message as applicable. */
                    message = EdelweissUtils.checkDependency(currentTaskRecord.Subject, relatedCase);
                    if(message.get(1) != null){
                        currentTaskRecord.WhatId.addError(message.get(1));
                    } else if(currentTaskRecord.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) && !currentTaskRecord.MOUI_Success_Response__c && currentTaskRecord.Subject == EdelweissConstants.UPDATE_MANDATORY_DETAILS){
                        currentTaskRecord.addError('Please send MOUI request before closing this task.');
                    }
                    Sys_Properties__c commonproductstypes = Sys_Properties__c.getValues('CommonProductTypes');
                    isNewClient = commonproductstypes.Value__c.contains(relatedCase.product_type__c) ? 'NA' : relatedCase.AccountId != null ? 'FALSE' : 'TRUE';  
                    if(relatedCase.AccountId != null){
                        isNewClient = (isNewClient == 'FALSE' && (String.isBlank(relatedCase.Account.GWM_Online_Id__c) || relatedCase.Lead_Account__c != null)) ? 'TRUE': 'FALSE';
                        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
                        if(clientRecordTypeId == relatedCase.Account.recordTypeId && !String.isBlank(relatedCase.Account.GWM_Online_Id__c)){
                            isNewClient = 'TRUE';
                        }
                    }
					if(EdelweissConstants.CaseRecordTypeMap.get(relatedCase.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                        isNewClient = 'TRUE';
                    }
                    
                    Set<String> productTypeSet = new Set<String>();
                    List<String> productTypeList = (relatedCase.Product_Type__c).split(';');
                    productTypeSet.addAll(productTypeList);
                    List<String> ProductTypes = new List<String>();
                    
                    if(((relatedCase.IsNewFamily__c || relatedCase.IsNewClient__c )&& currentTaskRecord.Subject == EdelweissConstants.MILES_ACCOUNT_OPENING_AUTO_CLOSURE) || (!relatedCase.IsNewFamily__c && !relatedCase.IsNewClient__c && currentTaskRecord.Subject == EdelweissConstants.MOUI_AUTO_CLOSURE)){
                        if(productTypeSet.contains('Funding')){
                            ProductTypes.add('Funding');
                        }
                        if(productTypeSet.contains('ComodityTrad')){
                            ProductTypes.add('ComodityTrad');
                        }
                        if(productTypeSet.contains('ComodityTrack')){
                            ProductTypes.add('ComodityTrack');
                        }
                        system.debug('ProductTypes'+ProductTypes);
                    }else{
                        ProductTypes.add(productTypeList[0]);
                    }
                    
                    Integer intSequence = (Integer)currentTaskRecord.Task_Sequence__c;
                    //Extisting Family Exting Client
                    if(!relatedCase.IsNewFamily__c && !relatedCase.IsNewClient__c && currentTaskRecord.Subject == EdelweissConstants.MOUI_AUTO_CLOSURE){
                        intSequence = intSequence+2;
                    }
                       
                    
                    //Extisting Family New Client
                    if(!relatedCase.IsNewFamily__c && relatedCase.IsNewClient__c && currentTaskRecord.Subject == EdelweissConstants.MOUI_AUTO_CLOSURE){
                        intSequence = intSequence+1;
                    }
                    
                    //New Family New Client
                    if(relatedCase.IsNewFamily__c && currentTaskRecord.Subject == EdelweissConstants.MOUI_AUTO_CLOSURE){
                        intSequence = intSequence+1;
                    }
                    
                   List<Account_Opening_Process_and_TAT__c> nextTaskList = getNextTaskInformation(intSequence, currentTaskRecord.Task_Type__c, relatedCase.POA__c, ProductTypes, isNewClient);            
                    if(nextTaskList.size() > 0){
                        for(Account_Opening_Process_and_TAT__c nextTaskRecord: nextTaskList){
                            Task newTask = new Task();
                            newTask.Subject = nextTaskRecord.Tasks__c;
                            newTask.whatid=(Id)currentTaskRecord.whatid;
                            newTask.Task_Sequence__c = nextTaskRecord.Sequence__c;
                            newTask.Task_Type__c = nextTaskRecord.Account_Type__c;
                            //Datetime dueDateTime = System.Now().addHours(((EdelweissUtils.getOffDaysWithinTat((Integer)nextTaskRecord.Turnaround_Time__c, System.Now())+(Integer)nextTaskRecord.Turnaround_Time__c)*24));
                            Datetime dueDateTime = relatedCase.CreatedDate.addHours(((EdelweissUtils.getOffDaysWithinTat((Integer)nextTaskRecord.Turnaround_Time__c, relatedCase.CreatedDate)+(Integer)nextTaskRecord.Turnaround_Time__c)*24));
                            //newTask.Due_Date_Time__c = System.now();
                            //DateTime dT = System.now();
							//Date myDate =date.newinstance(dT.year(), dT.month(), dT.day());		   
                            //newTask.ActivityDate = myDate; 
                            newTask.Priority = currentTaskRecord.Priority;
                            newTask.OwnerId = currentTaskRecord.OwnerId;
                            if(currentTaskRecord.Related_Email__c != null && currentTaskRecord.Related_Email__c != ''){
                                newTask.Related_Email__c = currentTaskRecord.Related_Email__c;
                            }
                            
                            if(newTask.Subject == EdelweissConstants.BANK_ACCOUNT_OPENING){
                                newTask.RecordTypeId = EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.BANK_ACCOUNT_TASK_RECORD_TYPE);
                            }else if(newTask.Subject == EdelweissConstants.TRADING_DEMAT_OPENED || newTask.Subject == EdelweissConstants.ONLY_TRADING_OPENED || newTask.Subject == EdelweissConstants.ONLY_DEMAT_OPENED ){
                                newTask.RecordTypeId = EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.TRADING_DEMAT);
                            }else{
                                newTask.RecordTypeId = EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK);
                            }
                            
                            //newTask.TAT__c = String.valueOf(nextTaskRecord.Turnaround_Time__c);
                            newTaskList.add(newTask);
                        }
                    }
                }
            }
            try{
                stopTaskTrigger = true;
                if(newTaskList.size() > 0)
                    insert newTaskList;   
            }catch(Exception ex){
                System.debug('Exception @ TaskManagementTriggerHelper: createSequenceTask - ' + ex);
            }
        }                          
    }

    public static List<Account_Opening_Process_and_TAT__c> getNextTaskInformation(Integer currentTaskSequence, String taskType, Boolean POA, list<String> productType, String isNewClient){
        List<Account_Opening_Process_and_TAT__c> nonPOATasksList = new List<Account_Opening_Process_and_TAT__c>{};
        system.debug('Account_Type__c=='+','+taskType +','+productType +','+isNewClient+','+currentTaskSequence);
        List<Account_Opening_Process_and_TAT__c> taskList = [Select Sequence__c, 
                                       Turnaround_Time__c,
                                       Bank_Account_Required__c,
                                       Tasks__c,
                                       Account_Type__c,
                                       Turnaround_Time_From__c,
                                       New__c
                                       from Account_Opening_Process_and_TAT__c 
                                       where Turnaround_Time_From__c =: currentTaskSequence AND
                                       Account_Type__c =: taskType AND
                                       Product_Type__c IN: productType AND
                                       New__c =: isNewClient                                     
                                       ];
        Boolean flag = false;
        for(Account_Opening_Process_and_TAT__c taskRecord: taskList){
	        for(String producttypevar : productType){
                if(producttypevar.equals(EdelweissConstants.OTHER_NON_EXCHANGE_PRODUCTS)){
                    flag = true;    
                }
			}
            if(!POA && taskRecord.Bank_Account_Required__c != false && 
                taskRecord.Bank_Account_Required__c != null && 
                taskType == EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING && !flag)
                {
                    
                nonPOATasksList = [Select Sequence__c, 
                                       Turnaround_Time__c,
                                       Bank_Account_Required__c,
                                       Tasks__c,
                                       Account_Type__c,
                                       Turnaround_Time_From__c,
                                       New__c
                                       from Account_Opening_Process_and_TAT__c 
                                       where Turnaround_Time_From__c =: (taskRecord.Sequence__c) AND
                                       Account_Type__c =: taskType AND
                                       Product_Type__c IN : productType AND
                                       New__c =: isNewClient                                      
                                       ];
            }else if(!POA && taskRecord.Bank_Account_Required__c != false && taskRecord.Bank_Account_Required__c != null){
                nonPOATasksList = [Select Sequence__c, 
                                       Turnaround_Time__c,
                                       Bank_Account_Required__c,
                                       Tasks__c,
                                       Account_Type__c,
                                       Turnaround_Time_From__c,
                                       New__c
                                       from Account_Opening_Process_and_TAT__c 
                                       where Turnaround_Time_From__c =: (taskRecord.Sequence__c + 1) AND
                                       Account_Type__c =: taskType AND
                                       Product_Type__c IN : productType AND
                                       New__c =: isNewClient                                      
                                       ];
            }
        }
        if(nonPOATasksList.size() > 0){
            return nonPOATasksList;
        }else{
            return taskList;
        }        
    }
    
    public static void maintainServiceActivityHistory(List<Task> ticket, Map<Id,Task>oldMap){
        List<Service_Activity_History__c> newServiceHistoryList = new List<Service_Activity_History__c>{};
        List<Service_Activity_History__c> updateServiceHistoryList = new List<Service_Activity_History__c>{};
        if(oldMap == null){
            for(Task ticketRecord : ticket){
                if(EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                    Service_Activity_History__c serviceHistory = new Service_Activity_History__c();
                    serviceHistory.Case__c = ticketRecord.WhatId;
                    serviceHistory.Owner__c = ticketRecord.OwnerId;
                    serviceHistory.Owner_Assignment_Date__c = System.now();
                    serviceHistory.Owner_Change_Reason__c = 'New Ticket';
                    serviceHistory.Stage__c = ticketRecord.Subject;
                    newServiceHistoryList.add(serviceHistory);
                }
            }
        }else{
            For(Task ticketRecord: ticket){
                if(EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                    Task oldObj = oldMap.get(ticketRecord.Id);
                    if(ticketRecord.OwnerId != oldObj.OwnerId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c, Owner_Change_Date__c, Stage__c 
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null 
                                                      and Stage_Completion_Date__c = null 
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){ 
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);
                            newSh.Owner_Change_Date__c = System.now();
                            newSh.Owner_Change_Reason__c = ticketRecord.Owner_Change_Reason__c;
                            if(ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS){
                                newSh.On_Hold_Release_Date__c = System.now();
                            }
                            updateServiceHistoryList.add(newSh);
                        }
                    
                        Service_Activity_History__c serviceHistory = new Service_Activity_History__c();
                        if(ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS){
                            serviceHistory.On_Hold_Date__c = System.now();
                        }
                        serviceHistory.Case__c = ticketRecord.WhatId;
                        serviceHistory.Owner__c = ticketRecord.OwnerId;
                        serviceHistory.Owner_Assignment_Date__c = System.now();
                        serviceHistory.Stage__c = ticketRecord.Subject;
                        newServiceHistoryList.add(serviceHistory);
                    }else if(ticketRecord.Status != oldObj.Status && oldObj.Status == EdelweissConstants.CASE_ON_HOLD_STATUS && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c, On_Hold_Date__c, Total_On_Hold_Duration__c
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null 
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);
                            if(record.Total_On_Hold_Duration__c != null){
                                newSh.Total_On_Hold_Duration__c = record.Total_On_Hold_Duration__c + ((System.Now().getTime())/1000/60/60)-((record.On_Hold_Date__c.getTime())/1000/60/60);// return hours
                            }else{
                                newSh.Total_On_Hold_Duration__c = ((System.Now().getTime())/1000/60/60)-((record.On_Hold_Date__c.getTime())/1000/60/60);// return hours
                                system.debug('Total On hold duration'+newSh.Total_On_Hold_Duration__c);
                                    
                            }
                            newSh.On_Hold_Date__c = null;
                            updateServiceHistoryList.add(newSh);
                        }
                    }else if(ticketRecord.Status != oldObj.Status && ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c, On_Hold_Date__c
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);                        
                            newSh.On_Hold_Date__c = System.now();
                            updateServiceHistoryList.add(newSh);
                        }
                    }else if(ticketRecord.Status != oldObj.Status && ticketRecord.Status ==EdelweissConstants.TASK_COMPLETED_STATUS  && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c, On_Hold_Date__c
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null 
                                                      and Stage_Completion_Date__c = null
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);                        
                            newSh.Stage_Completion_Date__c = System.now();
                            updateServiceHistoryList.add(newSh);
                        }
                    }/*else if(ticketRecord.Status != oldObj.Status && ticketRecord.Status == EdelweissConstants.CASE_ESCALATED_STATUS && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null 
                                                      and Stage_Completion_Date__c = null
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);                        
                            newSh.Escalated__c = true;
                            updateServiceHistoryList.add(newSh);
                        } 
                    }else if(ticketRecord.Send_Due_Date_Reminder__c != oldObj.Send_Due_Date_Reminder__c && ticketRecord.Send_Due_Date_Reminder__c == true && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                        List<Service_Activity_History__c> sh = [Select Id, Case__c
                                                      from Service_Activity_History__c 
                                                      where Case__c =:ticketRecord.WhatId and Owner__c =: oldObj.OwnerId
                                                      and Owner_Change_Date__c = null 
                                                      and Stage_Completion_Date__c = null
                                                      and Stage__c =:ticketRecord.Subject
                                                     ];
                        for(Service_Activity_History__c record :sh){
                            Service_Activity_History__c newSh = new Service_Activity_History__c(id=record.Id);                        
                            newSh.Send_Due_Date_Reminder__c = true;
                            updateServiceHistoryList.add(newSh);
                        }
                    }*/
                }
                if(updateServiceHistoryList!=null && updateServiceHistoryList.size()>0){
                    stopTaskTrigger= true;
                   try{
                        update updateServiceHistoryList;              
                   }catch(Exception ex){
                        System.debug(ex);
                   }           
               }
            }
        }
        if(newServiceHistoryList !=null && newServiceHistoryList.size()>0){
            try{
                insert newServiceHistoryList;              
            }catch(Exception ex){
                System.debug(ex);
            }       
        }
    }
    
        public static void populateDueDate(List<Task> taskList, Map<Id,Task>oldMap){
            Set<Id> caseIds = new Set<Id>(); 
            for(Task t : taskList){
            		caseIds.add(t.WhatId);
       		 }

        Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(caseIds);
            
            for(Task t : taskList){
                	Task oldobj = oldMap.get(t.Id);
                 	Case relatedCase = mapCases.get(t.WhatId);
                if((t.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) || t.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.BANK_ACCOUNT_TASK_RECORD_TYPE)|| t.RecordTypeId == EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.TRADING_DEMAT)) && t.Status != oldObj.Status && t.Status == EdelweissConstants.TASK_COMPLETED_STATUS ) 
      			{ System.debug('before Inside');
                    if(EdelweissConstants.CaseRecordTypeMap.get(relatedCase.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                        System.debug('Inside');
                        t.Due_Date_Time__c = system.now();
                   	 	DateTime dT = System.now();
						Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    	t.ActivityDate = myDate;
                    }
        		}
            }     
       }
    public static void recalculateServiceActivityDueDate(List<Task> ticket, Map<Id,Task>oldMap){
        For(Task ticketRecord: ticket){
            Decimal releaseDateDuedateTimeDiff = 0;
            Decimal onHoldDurationHrs = 0;
            Integer onHoldDurationDays = 0;
            Integer offDays = 0;
            Integer newOnHoldDurationHrs = 0;
            Task oldObj = oldMap.get(ticketRecord.Id);          
            Datetime onHoldDateTime = ticketRecord.On_Hold_Date__c;
            Datetime dueDateTime = ticketRecord.Due_Date_Time__c;
            if(ticketRecord.Status != oldObj.Status && oldObj.Status == EdelweissConstants.CASE_ON_HOLD_STATUS && EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK) == ticketRecord.RecordTypeId){
                releaseDateDuedateTimeDiff = ((dueDateTime.getTime())/1000/60/60) - ((System.Now().getTime())/1000/60/60);// return hours                
                onHoldDurationHrs = ((System.Now().getTime())/1000/60/60)-((onHoldDateTime.getTime())/1000/60/60);// return hours
                System.debug('DildarLog: onHoldDuration - ' + onHoldDurationHrs);
                System.debug('DildarLog: releaseDateDuedateTimeDiff - ' + releaseDateDuedateTimeDiff);
                
                if(releaseDateDuedateTimeDiff < 0){
                    onHoldDurationHrs = onHoldDurationHrs+releaseDateDuedateTimeDiff;
                }
                
                if(onHoldDurationHrs > 0){
                    if(onHoldDurationHrs < 24){
                        newOnHoldDurationHrs = EdelweissUtils.checkFutureOffDays(dueDateTime, onHoldDurationHrs);
                    }else{
                        newOnHoldDurationHrs = EdelweissUtils.checkPastOffDays(onHoldDateTime, onHoldDurationHrs);
                        newOnHoldDurationHrs = EdelweissUtils.checkFutureOffDays(dueDateTime, newOnHoldDurationHrs);
                    }
                    
                    ticketRecord.Due_Date_Time__c = ticketRecord.Due_Date_Time__c.addHours(newOnHoldDurationHrs);
                    Datetime dt = ticketRecord.Due_Date_Time__c; //update due date time custom field
                    ticketRecord.ActivityDate = dt.date(); //update duedate
                    if(ticketRecord.Total_On_Hold_Duration__c != null){
                        if(newOnHoldDurationHrs > onHoldDurationHrs) 
                            ticketRecord.Total_On_Hold_Duration__c = String.valueOf(Integer.valueOf(ticketRecord.Total_On_Hold_Duration__c) + onHoldDurationHrs);
                        else
                            ticketRecord.Total_On_Hold_Duration__c = String.valueOf(Integer.valueOf(ticketRecord.Total_On_Hold_Duration__c) + newOnHoldDurationHrs);
                    }else{
                        if(newOnHoldDurationHrs > onHoldDurationHrs)
                            ticketRecord.Total_On_Hold_Duration__c = String.valueOf(onHoldDurationHrs);
                        else
                            ticketRecord.Total_On_Hold_Duration__c = String.valueOf(newOnHoldDurationHrs);                      
                    }
                }
            }
        }
    }
    
    public static void createEventFromTaskofOutlook(List<Task> tasks){
        
        Id taskRecordTypeId =  EdelweissConstants.TaskRecordTypeMap.get('Generic_Task_Record_Type');
        //Who
        Set<Id> contactIdSet  = new Set<Id>();
        for(Task t : tasks){
          if(t.WhoId!=null && t.WhoId.getSObjectType() == Contact.sObjectType && t.WhatId == null){
            contactIdSet.add(t.WhoId);
          }
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Id contactRecordTypeId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get(EdelweissConstants.EDELWEISS_CONTACT_RECORD_TYPE).getRecordTypeId();
        if(contactIdSet != null && contactIdSet.size() > 0){
            contactMap = new Map<Id,Contact>([SELECT recordTypeId,Id,AccountId 
                                       FROM Contact
                                       WHERE Id IN:contactIdSet AND AccountId != NULL AND RecordTypeId =: contactRecordTypeId 
                                      ]);
        }
        
        //SELECT AccountId,ActivityDate,Agenda__c,Description,Description__c,Due_Date_Time__c,OwnerId,Reason_For_Not_Sending_MoM__c,Related_Email__c,Status,Status__c,Subject,Type,Type_of_Communication__c,WhatId,WhoId,RecordTypeId FROM Task WHERE Id = '00TN000000Bq8J8'
        //SELECT Agenda__c,Description,EndDateTime,EventSubtype,Id,OwnerId,Reason_For_Not_Sending_MoM__c,StartDateTime,Status__c,Subject,WhoId FROM Event
        
        List<Event> eventInsert = new List<Event>();
        List<Task> taskDelete = new List<Task>();

        for(Task t : tasks){
            if(t.WhoId!=null &&  contactMap.get(t.WhoId) != null){
                Contact cntRecord = contactMap.get(t.WhoId);
                Event e = new Event();
                e.Agenda__c = 'General';
                e.Subject = t.Subject;
                e.Description = t.Description;
                e.Type_of_Communication__c = 'Email';
                System.debug('t.ActivityDate===='+t.ActivityDate);
                Date activityDate = (t.ActivityDate != null) ? t.ActivityDate: Date.Today() ;
                System.debug('activityDate===='+activityDate);              
                e.StartDateTime = DateTime.newInstance(activityDate, System.now().addHours(-2).time());
                e.EndDateTime = DateTime.newInstance(activityDate, System.now().addHours(-1).time());
                System.debug('e.StartDateTime===='+e.StartDateTime);    
                System.debug('e.EndDateTime===='+e.EndDateTime);    
                e.Status__c = 'Open';
                e.WhoId = t.WhoId;
                eventInsert.add(e);
                taskDelete.add(t);
            }
            
        }
        System.debug('eventInsert===='+eventInsert);
        if(eventInsert != null && eventInsert.size() > 0)
            Database.insert(eventInsert,true);      
        
        if(taskDelete != null && taskDelete.size() > 0){
            List<Task> tobeDelete = new List<Task>();
            for(Task t : taskDelete){
                Task tn = new Task();
                tn.Id = t.Id;
                tobeDelete.add(tn);
            } 
            //Database.delete(tobeDelete,true);
        }
            
        
    }
}