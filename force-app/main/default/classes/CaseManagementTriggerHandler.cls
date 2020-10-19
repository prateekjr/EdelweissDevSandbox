public class CaseManagementTriggerHandler {
    public static boolean stopCaseTrigger = false;
    public static void createInitialAccountOpeningTask(List<Case> currentCaseList){
        String isNewClient = 'FALSE';
         List<Id> accountIds =  new List<Id>();
        for(Case currentCaseRecord: currentCaseList){
            if(currentCaseRecord.AccountId != null)
                accountIds.add(currentCaseRecord.AccountId);
        }
        Map<Id,Account> accountMap =  new Map<Id,Account>([Select Id, GWM_Online_Id__c From Account Where Id IN : accountIds]);
        
        for(Case currentCaseRecord: currentCaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.EXCHANGE_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FUNDING_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                Sys_Properties__c commonproductstypes = Sys_Properties__c.getValues('CommonProductTypes');
                isNewClient = commonproductstypes.Value__c.contains(currentCaseRecord.product_type__c) ? 'NA' : currentCaseRecord.AccountId != null ? 'FALSE' : 'TRUE'; 
                if(currentCaseRecord.AccountId != null && accountMap.get(currentCaseRecord.AccountId) != null)
                    isNewClient = (isNewClient == 'FALSE' && String.isBlank(accountMap.get(currentCaseRecord.AccountId).GWM_Online_Id__c)) ? 'TRUE': 'FALSE';
                
                if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                    isNewClient = 'TRUE';
                }
                
                system.debug('isNewClient ----'+isNewClient);
                string pType = (currentCaseRecord.Product_Type__c != null) ? currentCaseRecord.Product_Type__c  : '';
                List<String> productTypeList = (pType).split(';');              
                List<Account_Opening_Process_and_TAT__c> taskList = getTaskInformation(currentCaseRecord.RecordTypeId, productTypeList[0], isNewClient);
                system.debug('taskList----'+taskList);
                if(taskList.size() > 0){
                    
                    List<Task> newTaskList = new List<Task>{};
                    for(Account_Opening_Process_and_TAT__c taskRecord: taskList){
                        Task newTask = new Task();
                        Datetime dueDateTime = System.Now().addHours(((EdelweissUtils.getOffDaysWithinTat((Integer)taskRecord.Turnaround_Time__c, System.Now())+(Integer)taskRecord.Turnaround_Time__c)*24));
                        //newTask.Due_Date_Time__c = dueDateTime;
                        //newTask.ActivityDate = dueDateTime.date(); 
                        newTask.Subject = taskRecord.tasks__c;
                        newTask.whatid = (Id)currentCaseRecord.id;
                        newTask.Task_Sequence__c = taskRecord.Sequence__c;
                        newTask.Task_Type__c = taskRecord.Account_Type__c;
                        newTask.Priority = currentCaseRecord.Priority;
                        newTask.OwnerId = currentCaseRecord.OwnerId;
                        newTask.RecordTypeId = EdelweissConstants.TaskRecordTypeMap.get(EdelweissConstants.SERVICE_TASK);
                        //newTask.TAT__c = String.valueOf(taskRecord.Turnaround_Time__c);
                        System.debug('****** New Task'+newTask);
                        newTaskList.add(newTask);
                    }
                    try{
                        insert newTaskList;
                    }catch(Exception ex){
                        System.debug('Exception @ CaseManagementTriggerHelper: createInitialAccountOpeningTask - ' + ex);
                    }
                }
            }
        }
    }
    
    private static List<Account_Opening_Process_and_TAT__c> getTaskInformation(Id recordTypeId, String productType, String isNewClient){
        String name = '';
        List<Account_Opening_Process_and_TAT__c> task = new List<Account_Opening_Process_and_TAT__c>{};
        RecordType rt = [Select name
                         from RecordType
                         where id =: recordTypeId
                        ];
        name = rt.Name;
        System.debug('DildarLog: Account Type - ' + name);
       
        task = [Select Sequence__c,
                        Turnaround_Time__c,
                        Bank_Account_Required__c,
                        Tasks__c,
                        Account_Type__c,
                        Turnaround_Time_From__c,
                        New__c
                        from Account_Opening_Process_and_TAT__c
                        where Account_Type__c =:name AND 
                        Product_Type__c =:productType AND 
                        Turnaround_Time_From__c = null AND
                        New__c =: isNewClient
                        Order By Sequence__c
                        ASC
                        ];
        System.debug('DildarLog: productType Type - ' + productType);
        System.debug('DildarLog: task - ' + task);
        System.debug('DildarLog: isNewClient - ' + isNewClient);
        return task;
    }
    public static void assignCaseOwner(List<Case> ticket,Map<Id,Case> oldMap){
        System.debug('oldMap - ' + oldMap);
        System.debug('ticket[0].IsCaseAssignToCSO__c - ' + ticket[0].IsCaseAssignToCSO__c);
        /*List<FA_CSO_Mapping__c> cso = [Select CSO_User__c,
                                                    IsActive__c
                                            from FA_CSO_Mapping__c 
                                            where FA_User__c =: ticket[0].OwnerId and IsActive__c = true];                                  
        
        System.debug('cso - ' + cso);*/
        List<Case> lstCaseUpdate = new List<Case>();
        if(oldMap == null){               
            for(Case c : ticket){
                if(EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) != EdelweissConstants.FINANCIAL_TRANSACTION || 
                   (EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && c.Buy_Sell__c == 'Sell') || 
                   (EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && c.Buy_Sell__c == 'Buy' && c.IsCaseAssignToCSO__c)){
                       lstCaseUpdate.add(c);
                   }
            }
        }else if(oldMap != null){
            for(Case c : ticket){
                case oldCase = oldMap.get(c.Id);
                if(EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && c.Buy_Sell__c == 'Buy' && oldCase.IsCaseAssignToCSO__c != c.IsCaseAssignToCSO__c && c.IsCaseAssignToCSO__c){
                    lstCaseUpdate.add(c);
                }
            }
        }
            
        if(lstCaseUpdate != null && lstCaseUpdate.size() > 0){
            List<FA_CSO_Mapping__c> lstcso = [Select FA_User__c, CSO_User__c, IsActive__c from FA_CSO_Mapping__c Where IsActive__c = true Limit 5000];
            Map<Id,Id> FACSOId = new Map<Id,Id>();  
            for(FA_CSO_Mapping__c fc : lstcso){
                FACSOId.put(fc.FA_User__c, fc.CSO_User__c);
            }
            List<CaseShare> lstshare = new List<CaseShare>();
            for(Case cs : lstCaseUpdate){
                if(FACSOId != null && FACSOId.get(cs.OwnerId) != null){
                    System.debug('FACSOId.get(cs.OwnerId ) - ' + FACSOId.get(cs.OwnerId ));
                    if(!cs.IsUnicaCase__c){
                    cs.OwnerId = FACSOId.get(cs.OwnerId);
                    }
                    System.debug('cs.OwnerId - ' + cs.OwnerId);
                    if(EdelweissConstants.CaseRecordTypeMap.get(cs.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && cs.Buy_Sell__c == 'Buy' && cs.Current_FA__c != null){
                        CaseShare caseShr  = new CaseShare();
                        caseShr.CaseId = cs.Id;
                        caseShr.UserOrGroupId = cs.Current_FA__c;
                        caseShr.CaseAccessLevel = 'Edit';
                        lstshare.add(caseShr);
                    }
                                            
                }               
            }
            System.debug('lstshare - ' + lstshare);
            //if(lstshare != null && lstshare.size() > 0)
                //database.insert(lstshare,true);                
        } 
    }
    
    public static void caseSharingForFT(List<Case> tickets,Map<Id,Case> oldMap){        
        List<Case> lstCaseUpdate = new List<Case>();
        if(oldMap == null){               
           for(Case c : tickets){
                if(EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && c.Buy_Sell__c == 'Buy' && c.IsCaseAssignToCSO__c){
                    lstCaseUpdate.add(c);
                }
            }
        }else if(oldMap != null){
            for(Case c : tickets){
                case oldCase = oldMap.get(c.Id);
                if(EdelweissConstants.CaseRecordTypeMap.get(c.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && c.Buy_Sell__c == 'Buy' && oldCase.IsCaseAssignToCSO__c != c.IsCaseAssignToCSO__c && c.IsCaseAssignToCSO__c){
                    lstCaseUpdate.add(c);
                }
            }
        }
        List<CaseShare> lstshare = new List<CaseShare>();
        for(Case cs : lstCaseUpdate){                
            if(cs.Current_FA__c != null){
                CaseShare caseShr  = new CaseShare();
                caseShr.CaseId = cs.Id;
                caseShr.UserOrGroupId = cs.Current_FA__c;
                caseShr.CaseAccessLevel = 'Edit';
                lstshare.add(caseShr);  
            }           
        } 
        
        System.debug('lstshare - ' + lstshare);
        if(lstshare != null && lstshare.size() > 0)
            database.insert(lstshare,false); 
    }
     public static void newTATCalculateServiceRequestDueDate(List<Case> ticket){
         System.debug('&&&&&&&ticket'+ticket);
         System.debug('******Inside Due Date calll New TAT');
         Integer customerTat = 0;
        List<Service_Type_TAT_Mapping__c> TAT = new List<Service_Type_TAT_Mapping__c>{};
        for(Case ticketRecord : ticket){
            if(EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST && !EdelweissConstants.ServiceTatRecordTypeMap.isEmpty()){
                Id redordTypeId = EdelweissConstants.ServiceTatRecordTypeMap.get('New TAT');
                System.debug('redordTypeId - ' + redordTypeId);
                TAT = [Select Customer_TAT__c
                        from Service_Type_TAT_Mapping__c
                        where RecordTypeId =: redordTypeId AND
                                Name =: ticketRecord.Service_Request_Type__c AND
                                Subtype__c =: ticketRecord.Service_Request_Sub_Type__c AND
								Nature_Of_Request__c =: ticketRecord.Nature__c AND 
								Product_Type__c =: ticketRecord.Service_Request_Product_Type__c
                      ];
            }
            System.debug('***********TAT'+TAT);
            if(TAT.size() > 0){
                for(Service_Type_TAT_Mapping__c tatRecord : TAT){
                    customerTat = Integer.valueOf(tatRecord.Customer_TAT__c);
                    Datetime tatStartFrom = System.now(); //default
                    ticketRecord.Due_Date__c = Date.today() + customerTAT;
                    ticketRecord.TAT__c = tatRecord.Customer_TAT__c;
                    System.debug('DildarLog: Customer TAT - ' + customerTAT);
                        Integer totalTat;
                        if(customerTat == 0){
                            totalTat = EdelweissUtils.getOffDaysWithinTat(customerTAT, tatStartFrom)+0;
                        }else{
                            totalTat = EdelweissUtils.getOffDaysWithinTat(customerTAT, tatStartFrom)+customerTat;
                            System.debug('EdelweissUtils.getOffDaysWithinTat(customerTAT, tatStartFrom) :'+EdelweissUtils.getOffDaysWithinTat(customerTAT, tatStartFrom));
                        }
                        if(customerTat == 0){
                            System.debug('^^^^Inside 0 TAT');
                            System.debug('^^^^totalTat '+totalTat);
                            Integer hour = System.now().hour();
                            if(hour >= 18){
                                 System.debug('^^^^Hours greater Than 18 '+totalTat);
                            		DateTime d = System.Now()+(totalTat);
									d = DateTime.newInstance(d.Year(),d.month(),d.day(),18,0,0);
                                	ticketRecord.Due_Date_Time__c = d;
                                System.debug('^^^^Hours Greater  Than 18  Due Date'+ ticketRecord.Due_Date_Time__c);
                            }else{
                                if(totalTat == 1){
                                System.debug('^^^^Hours Less  Than 18 ');
                                DateTime d = System.Now();
								d = DateTime.newInstance(d.Year(),d.month(),d.day(),18,0,0);
                                ticketRecord.Due_Date_Time__c = d;
                                System.debug('^^^^Hours Less  Than 18  Due Date'+ ticketRecord.Due_Date_Time__c);
                                }else{
                                DateTime d = (System.Now())+(totalTat);
								d = DateTime.newInstance(d.Year(),d.month(),d.day(),18,0,0);
                                ticketRecord.Due_Date_Time__c = d;
                                System.debug('^^^^Hours Less  Than 18  Due Date'+ ticketRecord.Due_Date_Time__c);
                                }
                            }
    
                        }else{
                    System.debug('DildarLog: totalTat - ' + totalTat);
                    ticketRecord.Due_Date_Time__c = System.Now().addHours((totalTat*24));
                    ticketRecord.TAT_Days__c = totalTat;
                    System.debug('Total TAT :'+  ticketRecord.TAT_Days__c );
                    System.debug('Total TAT 1 :'+ totalTat );
                    System.debug('********* Final Due Date '+ticketRecord.Due_Date_Time__c);
                }
            }
        }
        }
        }
    /*
     * Method will calculate the due date of the current ticket,
     * the due date will be calculated with the predefined Turnaround Time value in another custom
     * object 'Service_Type_TAT_Mapping__c'
     */
    public static void calculateServiceRequestDueDate(List<Case> ticket){
        Integer customerTat = 0;
        List<Service_Type_TAT_Mapping__c> TAT = new List<Service_Type_TAT_Mapping__c>{};
        for(Case ticketRecord : ticket){
            if(EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST && EdelweissConstants.ServiceTatRecordTypeMap.containsKey(ticketRecord.Owner_Zone__c) != null && !EdelweissConstants.ServiceTatRecordTypeMap.isEmpty()){
                Id redordTypeId = EdelweissConstants.ServiceTatRecordTypeMap.get(ticketRecord.Owner_Zone__c);
                System.debug('redordTypeId - ' + redordTypeId);
                System.debug('Owner_Zone__c - ' + ticketRecord.Owner_Zone__c);
                TAT = [Select Customer_TAT__c
                        from Service_Type_TAT_Mapping__c
                        where RecordTypeId =: redordTypeId AND
                                Name =: ticketRecord.Type AND
                                Subtype__c =: ticketRecord.Subtype__c AND
                                Sub_Sub_Type__c =: ticketRecord.Sub_Sub_Type__c
                      ];
            }
            if(TAT.size() > 0){
                for(Service_Type_TAT_Mapping__c tatRecord : TAT){
                    customerTat = Integer.valueOf(tatRecord.Customer_TAT__c);
                    Datetime tatStartFrom = System.now(); //default
                    ticketRecord.Due_Date__c = Date.today() + customerTAT;
                    ticketRecord.TAT__c = tatRecord.Customer_TAT__c;
                    System.debug('DildarLog: Customer TAT - ' + customerTAT);
                    Integer totalTat = EdelweissUtils.getOffDaysWithinTat(customerTAT, tatStartFrom)+customerTat;
                    System.debug('DildarLog: totalTat - ' + totalTat);
                    ticketRecord.Due_Date_Time__c = System.Now().addHours((totalTat*24));
                }
            }
        }
    }
    
    public static void resetOwnerChangeReason(List<Case> ticket,Map<Id,Case>oldMap){
       List<Case> updateCaseList = new List<Case>{};
       For(case ticketRecord: ticket){
           Case oldObj = oldMap.get(ticketRecord.Id);
           if(ticketRecord.OwnerId != oldObj.OwnerId){           
               Case cs = new Case(id=ticketRecord.Id);
               cs.Owner_Change_Reason__c = '';
               updateCaseList.add(cs);
           }                     
       }
       if(updateCaseList!=null && updateCaseList.size()>0){
           stopCaseTrigger = true;
           try{
                update updateCaseList;              
           }catch(Exception ex){
                System.debug('OWNERCHANGE OWNERCHANGEREASON NULLYFY @ SERVICE REQUEST EXCEPTION : ' + ex);
           }           
       }       
    }
    
    /*
     * Recalculate the DueDate of SR when ticket status released from OnHold
     */    
    public static void recalculateServiceRequestDueDate(List<Case> ticket,Map<Id,Case>oldMap){
        For(Case ticketRecord: ticket){
            Decimal releaseDateDuedateTimeDiff = 0;
            Decimal onHoldDurationHrs = 0;
            Integer onHoldDurationDays = 0;
            Integer offDays = 0;
            Integer newOnHoldDurationHrs = 0;
            Case oldObj = oldMap.get(ticketRecord.Id);          
            Datetime onHoldDateTime = ticketRecord.On_Hold_Date__c;
            Datetime dueDateTime = ticketRecord.Due_Date_Time__c;
            if(onHoldDateTime != null && dueDateTime != null && ticketRecord.Status != oldObj.Status && oldObj.Status == EdelweissConstants.CASE_ON_HOLD_STATUS &&
               (EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST || 
               EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION)){
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
    
    public static void setCasePriority(List<Case> ticket){
        for(Case record: ticket){
            List<Account> client = [Select Focus_30__c, High_Priority__c from Account where Id =:record.accountid];
            for(Account clientRecord: client){
                if(clientRecord.Focus_30__c == true || clientRecord.High_Priority__c == true){
                    record.Priority = 'High';
                    record.High_Priority__c = true;
                    //@TODO need to consider R5 type client                 
                }
            }
        } 
    }
    /*
Method complaintAcknowledgement is developed to send Acknowledgement
emails to clients email id if Non NPS , Service request complaint case is created.

*/
    public static void complaintAcknowledgement(List<Case> tickets){
        FA_CSO_Mapping__c  mappingObj;
        Sys_Properties__c complaintAcknowledgement;
        Map<Id, Id> mapOfAccountCase = new Map<Id,Id>();
        Map<Id,id> mapOfAccountFA = new Map<Id,Id>();
        Map<Id,FA_CSO_Mapping__c> mapOfFacso = new Map<Id,FA_CSO_Mapping__c>();
        Map<String , OrgWideEmailAddress> csoOwaMap= new Map<String , OrgWideEmailAddress>();
        Map<Id, user> userList = EdelweissConstants.userList;
        list<String> csoList = new list<String>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplateObj;
        String complaintAcknowledgementEmail = EdelweissConstants.COMPLAINT_ACK_EMAIL_TEMPLATE;
        if(complaintAcknowledgementEmail != null){
            complaintAcknowledgement = Sys_Properties__c.getValues(complaintAcknowledgementEmail);   
        }
        if(complaintAcknowledgement!=null && complaintAcknowledgement.value__c != null){
            emailTemplateObj = [SELECT id , HtmlValue FROM EmailTemplate WHERE developerName =:complaintAcknowledgement.value__c];
        }
        for(Case cObj : tickets){
            if(cObj.Send_Auto_Acknowledgement__c == 'Yes'){
                mapOfAccountCase.put(cObj.id , cObj.AccountId);    
            }
        }
        Map<id, Account> mapOfAccount = new  Map<id, Account>([SELECT id  , OwnerId , primary_email__c ,Salutation__c,Name FROM Account WHERE id IN:mapOfAccountCase.values()]);
        
        for(Account accObj : mapOfAccount.values()){
            mapOfAccountFA.put(accObj.id , accObj.OwnerId);
        }
        for(FA_CSO_Mapping__c facsoObj :[SELECT CSO_User__c , FA_User__c , IsActive__c FROM FA_CSO_Mapping__c WHERE FA_User__c =:mapOfAccountFA.values()]){
            mapOfFacso.put(facsoObj.FA_User__c , facsoObj);
            User csoUser = userList.get(facsoObj.CSO_User__c);
            csoList.add(csoUser.Name);
        }
        for(OrgWideEmailAddress addr : [select id, Address ,DisplayName from OrgWideEmailAddress where displayName =:csoList]){
            csoOwaMap.put(addr.DisplayName , addr);
        }
        List<OrgWideEmailAddress> list1 = new List<OrgWideEmailAddress>();
        
        for(Case cObj : tickets){
            Id accountId = mapOfAccountCase.get(cObj.id);
            Account accountObj = mapOfAccount.get(accountId);
            if((EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST) && (cObj.Nature__c == 'Complaint') && (cObj.Service_Request_Type__c != 'NPS') && accountObj != null && accountObj.OwnerId!=null & (cObj.status != 'Closed – Success' || cObj.status != 'Closed – Rejected')){
                    mappingObj = mapOfFacso.get(accountObj.OwnerId);
                    if(mappingObj != null){
                        String orgWideAddress,salutation,name;
                        Id objectId;
                        user csoUser,FaUser;
                        List<String> toAddress = new List<String>();
                        List<String> ccAddress = new List<String>();
                        List<String> bccAddresses = new List<String>();
                        
                        csoUser = userList.get(mappingObj.CSO_User__c); 
                        orgWideAddress = csoUser.Name;
                        FaUser = userList.get(mappingObj.FA_User__c); 
                        if(csoUser != null){
                            OrgWideEmailAddress owa;
                            owa = csoOwaMap.get(orgWideAddress);
                            if(owa != null){
                                if(emailTemplateObj != null){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    EmailTemplate em = new EmailTemplate(); 
                                    em = emailTemplateObj;	
                                    mail.setTemplateId(em.id);
                                    mail.setOrgWideEmailAddressId(owa.id);
                                    String htmlValue = em.HtmlValue;
                                    System.debug('**** htmlValue'+htmlValue);
                                    if(accountObj.Salutation__c == null){
                                        salutation = '';
                                    }else{
                                        salutation = accountObj.Salutation__c;
                                    }
                                    name = salutation+' '+accountObj.Name;
                                    String accountName = EdelweissConstants.COMPLAINT_ACK_ACCOUNT_NAME;
                                    String csoName = EdelweissConstants.COMPLAINT_ACK_CSO_NAME;
                                    String caseNumber = EdelweissConstants.COMPLAINT_ACK_CASE_NUMBER;
                                    String htmlValueModified;
                                    if(accountName != null){
                                        htmlValueModified = htmlValue.replace(accountName, name);
                                    }
                                    if(csoName != null){
                                        htmlValueModified = htmlValueModified.replace(csoName, csoUser.Name);  
                                    }
                                    if(caseNumber != null){
                                        htmlValueModified = htmlValueModified.replace(caseNumber, cObj.caseNumber); 
                                    }
                                    em.HtmlValue = htmlValueModified;
                                    if(accountObj.primary_email__c != null){
                                        toAddress.add(accountObj.primary_email__c);  
                                        mail.setReplyTo(accountObj.primary_email__c);
                                    }
                                    if(FaUser.Email != null){
                                        ccAddress.add(FaUser.Email);  
                                    }
                                    if(csoUser.Email != null){
                                        bccAddresses.add(csoUser.Email);  
                                    }
    
                                    mail.setToAddresses(toAddress);  
                                    mail.setCcAddresses(ccAddress);
                                    mail.setBccAddresses(bccAddresses);
                                    mail.setSubject('Email Acknowledgment');
                                    mail.setHtmlBody(htmlValueModified);
                                    mails.add(mail);
                                }
                            }
                        }
                    }
            }
    
        }
        
        if(mails!=null && !mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }

    public static void maintainServiceHistory(List<Case> ticket, Map<Id,Case>oldMap){
        List<Service_History__c> newServiceHistoryList = new List<Service_History__c>{};
        List<Service_History__c> updateServiceHistoryList = new List<Service_History__c>{};
        if(oldMap == null){
            for(Case ticketRecord : ticket){
                Service_History__c serviceHistory = new Service_History__c();
                serviceHistory.Case__c = ticketRecord.Id;
                serviceHistory.Owner__c = ticketRecord.OwnerId;
                serviceHistory.Owner_Assignment_Date__c = System.now();
                serviceHistory.Owner_Change_Reason__c = 'New Ticket';
				if(ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS)
					serviceHistory.On_Hold_Date__c = System.now();
                newServiceHistoryList.add(serviceHistory);
            }
        }else{
            For(case ticketRecord: ticket){
                Case oldObj = oldMap.get(ticketRecord.Id);
                if(ticketRecord.OwnerId != oldObj.OwnerId){
                    List<Service_History__c> sh = [Select Id, Case__c, Owner_Change_Date__c 
                                                  from Service_History__c 
                                                  where Case__c =:ticketRecord.Id and Owner__c =: oldObj.OwnerId
                                                  and Owner_Change_Date__c = null
                                                 ];
                    for(Service_History__c record :sh){
                        Service_History__c newSh = new Service_History__c(id=record.Id);
                        newSh.Owner_Change_Date__c = System.now();
                        newSh.Owner_Change_Reason__c = ticketRecord.Owner_Change_Reason__c;
                        if(ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS){
                            newSh.On_Hold_Release_Date__c = System.now();
                        }
                        updateServiceHistoryList.add(newSh);
                    }
                
                    Service_History__c serviceHistory = new Service_History__c();
                    if(ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS){
                        serviceHistory.On_Hold_Date__c = System.now();
                    }
                    serviceHistory.Case__c = ticketRecord.Id;
                    serviceHistory.Owner__c = ticketRecord.OwnerId;
                    serviceHistory.Owner_Assignment_Date__c = System.now();
                    newServiceHistoryList.add(serviceHistory);
                }else if(ticketRecord.Status != oldObj.Status && 
                         oldObj.Status == EdelweissConstants.CASE_ON_HOLD_STATUS && 
                         (EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST ||
                        EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION)){
                    List<Service_History__c> sh = [Select Id, Case__c, On_Hold_Date__c, Total_On_Hold_Duration__c
                                                  from Service_History__c 
                                                  where Case__c =:ticketRecord.Id and Owner__c =: oldObj.OwnerId
                                                  and Owner_Change_Date__c = null And On_Hold_Date__c != null
                                                 ];
                    for(Service_History__c record :sh){
                        Service_History__c newSh = new Service_History__c(id=record.Id);
                        if(record.Total_On_Hold_Duration__c != null){
                            newSh.Total_On_Hold_Duration__c = record.Total_On_Hold_Duration__c + ((System.Now().getTime())/1000/60/60)-((record.On_Hold_Date__c.getTime())/1000/60/60);// return hours
                        }else{
                            newSh.Total_On_Hold_Duration__c = ((System.Now().getTime())/1000/60/60)-((record.On_Hold_Date__c.getTime())/1000/60/60);// return hours
                        }
                        newSh.On_Hold_Date__c = null;
                        updateServiceHistoryList.add(newSh);
                    }
                }else if(ticketRecord.Status != oldObj.Status && 
                         ticketRecord.Status == EdelweissConstants.CASE_ON_HOLD_STATUS && 
                         (EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION)){
                    List<Service_History__c> sh = [Select Id, Case__c, On_Hold_Date__c
                                                  from Service_History__c 
                                                  where Case__c =:ticketRecord.Id and Owner__c =: oldObj.OwnerId
                                                  and Owner_Change_Date__c = null
                                                 ];
                    for(Service_History__c record :sh){
                        Service_History__c newSh = new Service_History__c(id=record.Id);                        
                        newSh.On_Hold_Date__c = System.now();
                        updateServiceHistoryList.add(newSh);
                    }
                }else if(ticketRecord.Status != oldObj.Status && 
                         (ticketRecord.Status == EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS || ticketRecord.Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS) && 
                         (EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.SERVICE_REQUEST ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.MILES_ACCOUNT_OPENING ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.EXCHANGE_ACCOUNT_OPENING ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FUNDING_ACCOUNT_OPENING ||
                         EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING)){// ||
                         //EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.TENTATIVE_MILES_ACCOUNT_OPENING)){
                    List<Service_History__c> sh = [Select Id, Case__c, On_Hold_Date__c
                                                  from Service_History__c 
                                                  where Case__c =:ticketRecord.Id and Owner__c =: oldObj.OwnerId
                                                  and Owner_Change_Date__c = null
                                                 ];
                    for(Service_History__c record :sh){
                        Service_History__c newSh = new Service_History__c(id=record.Id);                        
                        newSh.ClsDt__c = System.now();                          
                        updateServiceHistoryList.add(newSh);
                    } 
                }
            }
            if(updateServiceHistoryList!=null && updateServiceHistoryList.size()>0){
                stopCaseTrigger = true;
               try{
                    update updateServiceHistoryList;              
               }catch(Exception ex){
                    System.debug(ex);
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
    
    public static void calculateFinancialTransactionDueDate(List<Case> currentCaseList){
        Datetime transactionStartDate = System.Now();
        for(Case currentCaseRecord: currentCaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION){
                if(currentCaseRecord.Transaction_Date__c != null){
                    transactionStartDate = currentCaseRecord.Transaction_Date__c; 
                }
                List<String> productTypeList = (currentCaseRecord.Product_Type__c).split(';');
                List<Product_Type_TAT_Mapping__c> productTAT = [Select Turnaround_Time__c from Product_Type_TAT_Mapping__c where Products__c IN :productTypeList limit 1];
                if(productTAT.size() > 0){
                    for(Product_Type_TAT_Mapping__c TAT: productTAT){
                        System.debug('DildarLog: @calculateFinancialTransactionDueDate productTAT - ' + TAT.Turnaround_Time__c);
                        Integer totalTat = EdelweissUtils.getOffDaysWithinTat(Integer.valueOf(TAT.Turnaround_Time__c), transactionStartDate)+Integer.valueOf(TAT.Turnaround_Time__c);
                        System.debug('DildarLog: @calculateFinancialTransactionDueDate totalTat - ' + totalTat);
                        currentCaseRecord.Due_Date_Time__c = transactionStartDate.addHours((totalTat*24));
                        currentCaseRecord.TAT__c = TAT.Turnaround_Time__c;
                    }
                }
            }
        }
    }
    public static void checkDependency(List<Case> ticket, Map<Id,Case>oldMap){
        Map<Integer, String> message = new Map<Integer, String>{};
        Set<Id> setOfCaseId = new Set<Id>();
          
        for(Case ticketRecord: ticket){
            setOfCaseId.add(ticketRecord.Id);
        }
        /* Query Optimization 
        List<Profile> currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];*/
        List<Profile> currentUserProfile = new  List<Profile>();
       	Map<Id,Profile> tempProfileMap = new Map<Id,Profile>();
        tempProfileMap = EdelweissConstants.profileMap;
        for(Id key : tempProfileMap.keySet()){
            Profile obj = tempProfileMap.get(key);
            if(obj.Id == userinfo.getProfileId()){
                currentUserProfile.add(obj);
            }
        }
        //Query Optimization End
            
        Map<Id, Case> mapCaseDetails = new Map<Id, Case>([ 
            SELECT Id, CaseNumber, Status, (SELECT Id, Name, PAN_Number__c, Converted_To_Client__c FROM Additional_Leads__r), (SELECT MOUI_Success_Response__c FROM Tasks WHERE Subject='Update Mandatory Details')
            FROM Case WHERE Id =: setOfCaseId
        ]);
        
        for(Case ticketRecord: ticket){
            Case oldObj = oldMap.get(ticketRecord.Id);
            if(ticketRecord.Status != oldObj.Status && 
            (ticketRecord.Status == EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS || ticketRecord.Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS) && 
            (EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.MILES_ACCOUNT_OPENING ||
             EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.EXCHANGE_ACCOUNT_OPENING ||
                EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.FUNDING_ACCOUNT_OPENING ||
                EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING))
            {
                message = EdelweissUtils.checkDependency('', ticketRecord);
                if(message.get(1) != null){
                    ticketRecord.Status.addError(message.get(1));
                }
                 
                 String strPAN = '';
                for(Additional_Lead__c objAdditionalLead : mapCaseDetails.get(ticketRecord.Id).Additional_Leads__r){
                     if(!objAdditionalLead.Converted_To_Client__c){
                         if(String.isBlank(strPAN)){
                             strPAN += objAdditionalLead.PAN_Number__c;
                         }
                         else{
                             strPAN += ', '+objAdditionalLead.PAN_Number__c;
                         }
                     }
                 }
                 
                 if(!String.isBlank(strPAN)){
                     ticketRecord.Status.addError('Some related Additional Leads with PAN Number '+ strPAN + ' is not converted to Client. Hence the case can not be closed.');
                 }
                
                
            } else if (ticketRecord.Status != oldObj.Status && 
            (ticketRecord.Status == EdelweissConstants.CASE_CLOSED_SUCCESS_STATUS) && 
             EdelweissConstants.CaseRecordTypeMap.get(ticketRecord.RecordTypeId) == EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING ){
                 Integer pendingActivities = [SELECT count() FROM Task Where WhatId =: ticketRecord.Id And Status !=: EdelweissConstants.TASK_COMPLETED_STATUS];
                 if(pendingActivities != null && pendingActivities > 0){
                     ticketRecord.Status.addError(Label.Pending_Activities_Check_on_Case);
                 }
            }
            
            for(Task t : mapCaseDetails.get(ticketRecord.Id).Tasks){
                if(t.MOUI_Success_Response__c && !ticketRecord.MOUI_Skipped__c && currentUserProfile[0].Name != 'System Administrator'){
                    ticketRecord.addError('Case details can not be edited as MOUI success response is received');
                }
            }
        }
        
        
        
    }
    
    public static void caseAccountSharing(List<Case> ticket,  Map<Id,Case>oldMap){
        // Create new sharing object for the custom object Job.
        List<CaseShare> caseShrList = new List<CaseShare>{};
        List<AccountShare> accountShareList = new List<AccountShare>();
        for(Case ticketRecord: ticket){
            Case ticketOldRecord = null;
            if(oldMap != null)
                ticketOldRecord = oldMap.get(ticketRecord.Id);  
            
            if(((ticketOldRecord != null && ticketOldRecord.ownerId != ticketRecord.OwnerId) || (ticketOldRecord == null )) && !ticketRecord.FamilyWithoutClient__c){
                if(ticketRecord.Current_FA__c != null && ticketRecord.Current_FA__c != ticketRecord.OwnerId){
                    CaseShare caseShr  = new CaseShare();
                    caseShr.CaseId = ticketRecord.Id;
                    caseShr.UserOrGroupId = ticketRecord.Current_FA__c;
                    caseShr.CaseAccessLevel = 'Edit';
                    caseShrList.add(caseShr);                     
                }
                
                //Account Sharing
                AccountShare accountShareObj = new AccountShare(
                AccountId = ticketRecord.accountId, 
                UserOrGroupId = ticketRecord.OwnerId, 
                AccountAccessLevel='Read',
                RowCause='Manual',
                OpportunityAccessLevel = 'Read');
                accountShareList.add(accountShareObj);
            }
            system.debug('===>'+caseShrList);
            if(ticketOldRecord != null  && ticketOldRecord.Previous_FA__c != ticketRecord.Previous_FA__c  && !ticketRecord.FamilyWithoutClient__c){                
                    CaseShare caseShr  = new CaseShare();
                    caseShr.CaseId = ticketRecord.Id;
                    caseShr.UserOrGroupId = ticketRecord.Previous_FA__c;
                    caseShr.CaseAccessLevel = 'Read';
                    caseShrList.add(caseShr);
            } 
            if(((ticketOldRecord != null  && ticketOldRecord.Regional_Head__c != ticketRecord.Regional_Head__c) || (ticketOldRecord == null && ticketRecord.Regional_Head__c != null)) && !ticketRecord.FamilyWithoutClient__c){                
                    CaseShare caseShr  = new CaseShare();
                    caseShr.CaseId = ticketRecord.Id;
                    caseShr.UserOrGroupId = ticketRecord.Regional_Head__c;
                    caseShr.CaseAccessLevel = 'Edit';
                    caseShrList.add(caseShr);
            }           
            system.debug('===>'+caseShrList);           
                                
        }
        
        if(accountShareList.size() > 0){
           Database.insert(accountShareList,false); 
        }
        if(caseShrList.size() > 0){
            Database.insert(caseShrList,false);
        }
        
    }

    
    
    public static void caseSharing(List<Case> ticket){
        // Create new sharing object for the custom object Job.
        List<CaseShare> caseShrList = new List<CaseShare>{};
        List<AccountShare> accountShareList = new List<AccountShare>();
        for(Case ticketRecord: ticket){
            if(ticketRecord.CreatedById != ticketRecord.OwnerId  && !ticketRecord.FamilyWithoutClient__c){
                CaseShare caseShr  = new CaseShare();
                // Set the ID of record being shared.
                caseShr.CaseId = ticketRecord.Id;
                // Set the ID of user or group being granted access.
                caseShr.UserOrGroupId = ticketRecord.CreatedById;
                // Set the access level.
                caseShr.CaseAccessLevel = 'Edit';
                caseShrList.add(caseShr);                
                
                //Account Sharing
                AccountShare accountShareObj = new AccountShare(
                AccountId = ticketRecord.accountId, 
                UserOrGroupId = ticketRecord.OwnerId, 
                AccountAccessLevel='Read',
                RowCause='Manual',
                OpportunityAccessLevel = 'Read');
            accountShareList.add(accountShareObj);
                
            }
                                
            }
        
        if(accountShareList.size() > 0){
           Database.insert(accountShareList,false); 
        }
        if(caseShrList.size() > 0){
            // Insert the sharing record and capture the save result. 
            // The false parameter allows for partial processing if multiple records passed 
            // into the operation.
            Database.SaveResult[] lsr = Database.insert(caseShrList,false);
            // Create counter
            Integer i=0;
            // Process the save results
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    
                    // Check if the error is related to a trivial access level
                    // Access levels equal or more permissive than the object's default 
                    // access level are not allowed. 
                    // These sharing records are not required and thus an insert exception is 
                    // acceptable. 
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                                   &&  err.getMessage().contains('AccessLevel'))){
                        // Throw an error when the error is not related to trivial access level.
                        ticket[i].
                          addError(
                           'Unable to grant sharing access due to following exception: '
                           + err.getMessage());
                    }
                }
                i++;
            }
        }       
    }
    
    public static void validatePANNumber(List<Case> ticket){

        Set<String> panNumberSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> panNumberInSystem = new Set<String>();
        Set<String> phoneNumberInSystem = new Set<String>();
        Set<String> emailNumberInSystem = new Set<String>();
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());     
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());    
       
        for(Case objCase : ticket){
            if(!String.isEmpty(objCase.PAN_Number__c)){
              	  objCase.PAN_Number__c = (objCase.PAN_Number__c).toUppercase();
            }
            if(caseRecordType.contains(objCase.RecordTypeId)){
                panNumberSet.add(objCase.PAN_Number__c);
                phoneSet.add(objCase.Phone__c);
                emailSet.add(objCase.Email_Id__c);
            }
        }
        
        panNumberSet.remove(null);
        phoneSet.remove(null);
        emailSet.remove(null);
        
        Map<Id, Account> mapDuplicateAccount = new Map<Id, Account>([
            SELECT Id, Name, PAN_Number__c, Phone, Primary_Email__c
            FROM Account
            WHERE PAN_Number__c IN :panNumberSet
            OR Phone IN :phoneSet
            OR Primary_Email__c IN :emailSet
        ]);
        
        if(!mapDuplicateAccount.isEmpty()){

            Map<String, Id> mapPANAccId = new Map<String, Id>();
            Map<String, Id> mapPhoneAccId = new Map<String, Id>();
            Map<String, Id> mapEmailAccId = new Map<String, Id>();
            
            for(Account acc : mapDuplicateAccount.values()){
                
                if(!String.IsBlank(acc.PAN_Number__c)){
                    panNumberInSystem.add(acc.PAN_Number__c);
                    mapPANAccId.put(acc.PAN_Number__c, acc.id);
                }
                if(!String.IsBlank(acc.Phone)){
                    phoneNumberInSystem.add(acc.Phone);
                    mapPhoneAccId.put(acc.Phone, acc.id);
                }
                if(!String.IsBlank(acc.Primary_Email__c)){
                    emailNumberInSystem.add(acc.Primary_Email__c);
                    mapEmailAccId.put(acc.Primary_Email__c, acc.id);
                }
            }
            for(Case objCase : ticket){
                
                if(Trigger.isUpdate){
                    
                    Case oldCase = (Case)Trigger.OldMap.get(objCase.Id);
                    
                    if((objCase.IsNewFamily__c || objCase.IsNewClient__c) && objCase.PAN_Number__c != oldCase.PAN_Number__c && 
                       panNumberInSystem.contains(objCase.PAN_Number__c) && 
                       !(objCase.AccountId == mapPANAccId.get(objCase.PAN_Number__c) || 
                         objCase.Lead_Account__c == mapPANAccId.get(objCase.PAN_Number__c))
                      ){
                        objCase.addError('PAN number already present.');
                    }
                    
                    if(objCase.Phone__c != oldCase.Phone__c && 
                       phoneNumberInSystem.contains(objCase.Phone__c) && 
                       !(objCase.AccountId == mapPhoneAccId.get(objCase.Phone__c) || 
                         objCase.Lead_Account__c == mapPhoneAccId.get(objCase.Phone__c))
                      ){
                        //objCase.addError('Client Phone number already present.');
                    }
                    
                    if(objCase.Email_Id__c != oldCase.Email_Id__c && 
                       emailNumberInSystem.contains(objCase.Email_Id__c) && 
                       !(objCase.AccountId == mapEmailAccId.get(objCase.Email_Id__c) || 
                         objCase.Lead_Account__c == mapEmailAccId.get(objCase.Email_Id__c))
                      ){
                        //objCase.addError('Client Email Id already present.');
                    }
                }
                else{
                    if((objCase.IsNewFamily__c || objCase.IsNewClient__c) &&  panNumberInSystem.contains(objCase.PAN_Number__c) && 
                       !(objCase.AccountId == mapPANAccId.get(objCase.PAN_Number__c) || 
                         objCase.Lead_Account__c == mapPANAccId.get(objCase.PAN_Number__c)) 
                      ){
                          objCase.addError('PAN number already present.');
                      }
                      
                      if( phoneNumberInSystem.contains(objCase.Phone__c) && 
                       !(objCase.AccountId == mapPhoneAccId.get(objCase.Phone__c) || 
                         objCase.Lead_Account__c == mapPhoneAccId.get(objCase.Phone__c)) 
                      ){
                          //objCase.addError('Client Phone number already present.');
                      }
                      
                      if( emailNumberInSystem.contains(objCase.Email_Id__c) && 
                       !(objCase.AccountId == mapEmailAccId.get(objCase.Email_Id__c) || 
                         objCase.Lead_Account__c == mapEmailAccId.get(objCase.Email_Id__c)) 
                      ){
                          //objCase.addError('Client Email Id already present.');
                      }
                }
            }
        }
    }
    
	public static void validateJointHolder(List<Case> tickets){
        for(Case c : tickets){
            if(c.Entity_Type__c == 'Company' || c.Entity_Type__c == 'LLP' || c.Entity_Type__c == 'HUF'){
                if(//c.Joint_Holder_Client1_Aadhar_Number__c != null ||
                   c.Joint_Holder_Client1_Contact_Number__c != null ||
                   c.Joint_Holder_Client1_DOB_DOI__c != null ||
                   c.Joint_Holder_Client1_Email_ID__c != null ||
                   c.Joint_Holder_Client1_Entity_Type__c != null ||
                   c.Joint_Holder_Client1_Name__c != null ||
                   c.Joint_Holder_Client1_PAN_Number__c != null ||
                    //c.Joint_Holder_Client2_Aadhar_Number__c != null ||
                   c.Joint_Holder_Client2_Contact_Number__c != null ||
                   c.Joint_Holder_Client2_DOB_DOI__c != null ||
                   c.Joint_Holder_Client2_Email_ID__c != null ||
                   c.Joint_Holder_Client2_Entity_Type__c != null ||
                   c.Joint_Holder_Client2_Name__c != null ||
                   c.Joint_Holder_Client2_PAN_Number__c != null){
                       c.addError('Joint holder section should not have any value as Entity Type is selected as Componey, LLP OR HUF');
                   }               
            }
            
            if(String.isEmpty(c.Single_Joint__c) || 'Single'.equals(c.Single_Joint__c)){
                c.Number_of_Joint_Holders_Max_2__c = null;
            }
        }
    }
      public static void cleanIncorrectFieldsValues(List<Case> ticket){
         for(Case caseObj : ticket){
             if(EdelweissConstants.CaseRecordTypeMap.get(caseObj.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){

            if(caseObj.IsNewClient__c || caseObj.IsNewFamily__c){
                if(caseObj.isCorporate__c == false){
                    if(caseObj.Equity_Markets__c != null){
                        caseObj.Equity_Markets__c = '';
                    }
                    if(caseObj.Interest_leverage_products_Non_Ind__c != null){
                        caseObj.Interest_leverage_products_Non_Ind__c = '';
						}
                    
                    if(caseObj.Amount_of_fluctuations_Non_Ind__c != null){
                       caseObj.Amount_of_fluctuations_Non_Ind__c = '';
					   }
                    
                    
                    if(caseObj.worst_and_best_one_year_return_Non_Ind__c != null){
					caseObj.worst_and_best_one_year_return_Non_Ind__c = '';
                        }
                    
                    if(caseObj.Alternative_Investments_Non_Ind__c != null){
                      caseObj.Alternative_Investments_Non_Ind__c = '';
					  }
                }else if(caseObj.isCorporate__c == true){
                    if(caseObj.Age_RiskProfile__c != null){
                       caseObj.Age_RiskProfile__c = '';
					   }
                    
                    if(caseObj.Interest_in_leverage_borrowing_products__c != null){
                        caseObj.Interest_in_leverage_borrowing_products__c = '';
                    }
                    
                    if(caseObj.Alternative_Investments__c != null){
                        caseObj.Alternative_Investments__c = '';
					}
                    
                    if(caseObj.worst_and_best_one_year_return__c != null){
                        caseObj.worst_and_best_one_year_return__c = '';
					}
                    
                    if(caseObj.Amount_of_fluctuations__c != null){
                      caseObj.Amount_of_fluctuations__c = '';
                }
				}
			}
		}
	}
        
    }
    
    
    public static void saveIPS(List<Case> ticket){
        List<Profile> currentUserProfile = new  List<Profile>();
        Map<Id,Profile> tempProfileMap = new Map<Id,Profile>();
        tempProfileMap = EdelweissConstants.profileMap;
        for(Id key : tempProfileMap.keySet()){
            Profile obj = tempProfileMap.get(key);
            if(obj.Id == userinfo.getProfileId()){
                currentUserProfile.add(obj);
            }
        } 
        
        if(!(currentUserProfile[0].Name.contains('Client Experience Office'))){
            
        List<Account> toBeUpdated = new List<Account>();
        Map<id,case> ipsAccountMap = new Map<id,case>();
        Map<Id,Id> caseAccountMap = new  Map<id,Id>();
        set<id> accountId = new set<id>();
        Integer riskProfileTotal  = 0;
        //Get Schema Defination
        
        Schema.DescribeFieldResult fieldResult ;
        List<Schema.PicklistEntry> ple;
        Map<String, String> Investment_philosophy = new Map<String, String>();
        fieldResult = case.Investment_philosophy1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Investment_philosophy.put(f.getLabel(), f.getValue());
        }      
        Map<String, String> Equity_Markets = new Map<String, String>();
        fieldResult = case.Equity_Markets1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Equity_Markets.put(f.getLabel(), f.getValue());
        }      		
        
        Map<String, String> age = new Map<String, String>();
        fieldResult = case.Age1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            age.put(f.getLabel(), f.getValue());
        }     		
        Map<String, String> Investment_goal = new Map<String, String>();
        fieldResult = case.Investment_goal1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Investment_goal.put(f.getLabel(), f.getValue());
        }     				
        
        Map<String, String> Financial_Goals = new Map<String, String>();
        fieldResult = case.Financial_Goals1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Financial_Goals.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> worst_and_best_one_year_return = new Map<String, String>();
        fieldResult = case.worst_and_best_one_year_return1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            worst_and_best_one_year_return.put(f.getLabel(), f.getValue());
        }  		
        
        Map<String, String> Amount_of_fluctuations = new Map<String, String>();
        fieldResult = case.Amount_of_fluctuations1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Amount_of_fluctuations.put(f.getLabel(), f.getValue());
        }  			
        
        Map<String, String> Diversified_portfolio = new Map<String, String>();
        fieldResult = case.Diversified_portfolio1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Diversified_portfolio.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> Interest_in_leverage_borrowing_products = new Map<String, String>();
        fieldResult = case.Interest_in_leverage_borrowing_products1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Interest_in_leverage_borrowing_products.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> Alternative_Investments = new Map<String, String>();
        fieldResult = case.Alternative_Investments1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Alternative_Investments.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> Investment_portfolio = new Map<String, String>();
        fieldResult = case.Investment_portfolio1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Investment_portfolio.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> Interest_in_leverage_borrowing_products_Non_Ind = new Map<String, String>();
        fieldResult = case.Interest_leverage_products_Non_Ind1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Interest_in_leverage_borrowing_products_Non_Ind.put(f.getLabel(), f.getValue());
        }  
        
        Map<String, String> Alternative_Investments_Non_Ind = new Map<String, String>();
        fieldResult = case.Alternative_Investments_Non_Ind1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Alternative_Investments_Non_Ind.put(f.getLabel(), f.getValue());
        } 
        
        Map<String, String> Amount_of_fluctuations_Non_Ind = new Map<String, String>();
        fieldResult = case.Amount_of_fluctuations_Non_Ind_1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Amount_of_fluctuations_Non_Ind.put(f.getLabel(), f.getValue());
        } 
        
        
        Map<String, String> worst_and_best_one_year_return_Non_Ind = new Map<String, String>();
        fieldResult = case.worst_and_best_one_year_return_Non_Ind_1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            worst_and_best_one_year_return_Non_Ind.put(f.getLabel(), f.getValue());
        }
        
        for(Case caseObj : ticket){
            accountId.add(caseObj.AccountId);
        }
        Map<id,Account> accountMap = new Map<id,Account>([SELECT id , Risk_Profile_Based_on_IPS__c, RecordType.name FROM Account WHERE id IN:accountId ]);
       
        for(Case caseObj : ticket){
            Account acc = new Account();
            riskProfileTotal = 0;
         	Date deployDate = Date.newInstance(2019, 1, 19);
             Date createdDateOnly = Date.newInstance(caseObj.CreatedDate.year(), caseObj.CreatedDate.month(), caseObj.CreatedDate.day());
			if(deployDate <= createdDateOnly){
             if(EdelweissConstants.CaseRecordTypeMap.get(caseObj.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){

            if(caseObj.IsNewClient__c || caseObj.IsNewFamily__c){
                if(caseObj.AccountId != null){
                    acc = accountMap.get(caseObj.AccountId);
                }
                if(caseObj.isCorporate__c == true){
                    if(caseObj.Equity_Markets__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Equity_Markets.get(caseObj.Equity_Markets__c));
                    }else if(caseObj.Equity_Markets__c == null){
                        caseObj.addError('Equity Markets cannot be null');
                    }
                    if(caseObj.Interest_leverage_products_Non_Ind__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Interest_in_leverage_borrowing_products_Non_Ind.get(caseObj.Interest_leverage_products_Non_Ind__c));
                    }else if(caseObj.Interest_leverage_products_Non_Ind__c == null){
                        caseObj.addError('Interest in leverage borrowing products cannot be null');
                    }
                    
                    if(caseObj.Amount_of_fluctuations_Non_Ind__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Amount_of_fluctuations_Non_Ind.get(caseObj.Amount_of_fluctuations_Non_Ind__c));
                    }else if(caseObj.Amount_of_fluctuations_Non_Ind__c == null){
                        caseObj.addError('Amount Of Fluctuations cannot be null');
                    }
                    
                    
                    if(caseObj.worst_and_best_one_year_return_Non_Ind__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(worst_and_best_one_year_return_Non_Ind.get(caseObj.worst_and_best_one_year_return_Non_Ind__c));
                    }else if(caseObj.worst_and_best_one_year_return_Non_Ind__c == null){
                        caseObj.addError('Worst And Best One Year Return cannot be null');
                    }
                    
                    if(caseObj.Alternative_Investments_Non_Ind__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Alternative_Investments_Non_Ind.get(caseObj.Alternative_Investments_Non_Ind__c));
                    }else if(caseObj.Alternative_Investments_Non_Ind__c == null){
                        caseObj.addError('Alternative Investments cannot be null');
                    }
                }else{
                    if(caseObj.Age_RiskProfile__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(age.get(caseObj.Age_RiskProfile__c));
                    }else if(caseObj.Age_RiskProfile__c == null){
                        caseObj.addError('Age cannot be null');
                    }
                    
                    if(caseObj.Interest_in_leverage_borrowing_products__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Interest_in_leverage_borrowing_products.get(caseObj.Interest_in_leverage_borrowing_products__c));
                    }else{
                        caseObj.addError('Interest in leverage borrowing products cannot be null');
                    }
                    
                    if(caseObj.Alternative_Investments__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Alternative_Investments.get(caseObj.Alternative_Investments__c));
                    }else{
                        caseObj.addError('Alternative Investments cannot be null');
                    }
                    
                    if(caseObj.worst_and_best_one_year_return__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(worst_and_best_one_year_return.get(caseObj.worst_and_best_one_year_return__c));
                    }else{
                        caseObj.addError('Worst And Best One Year Return cannot be null');
                    }
                    
                    if(caseObj.Amount_of_fluctuations__c != null){
                        riskProfileTotal = riskProfileTotal + Integer.valueOf(Amount_of_fluctuations.get(caseObj.Amount_of_fluctuations__c));
                    }else{
                        caseObj.addError('Amount Of Fluctuations cannot be null');
                    }   
                }
                
                if(caseObj.Investment_philosophy__c != null){
                    riskProfileTotal = riskProfileTotal + Integer.valueOf(Investment_philosophy.get(caseObj.Investment_philosophy__c));
                }else{
                    caseObj.addError('Investment Philosophy cannot be null');
                }
                
                
                if(caseObj.Investment_goal__c != null){
                    riskProfileTotal = riskProfileTotal + Integer.valueOf(Investment_goal.get(caseObj.Investment_goal__c));
                }else{
                    caseObj.addError('Investment goal cannot be null');
                }
                
                if(caseObj.Financial_Goals__c != null){
                    riskProfileTotal = riskProfileTotal + Integer.valueOf(Financial_Goals.get(caseObj.Financial_Goals__c));
                }else{
                    caseObj.addError('Financial Goals cannot be null');
                }
                
                if(caseObj.Diversified_portfolio__c != null){
                    riskProfileTotal = riskProfileTotal + Integer.valueOf(Diversified_portfolio.get(caseObj.Diversified_portfolio__c));
                }else{
                    caseObj.addError('Diversified Portfolio cannot be null');
                }
                
                if(caseObj.Investment_portfolio__c != null){
                    riskProfileTotal = riskProfileTotal + Integer.valueOf(Investment_portfolio.get(caseObj.Investment_portfolio__c));
                }else{
                    caseObj.addError('Investment Portfolio cannot be null');
                }
                
                if(caseObj.Investment_Style__c != null){
                }else{
                    caseObj.addError('Investment Style cannot be null');
                }
                
                if(caseObj.Risk_Profile_Categories__c != null){
                }else{
                    caseObj.addError('Risk Profile Category cannot be null');
                }
                
                if(caseObj.Time_line_for_Trading__c !=null){
                }
                if(caseObj.Stop_Loss__c !=null){
                }if(caseObj.Direct_Equity__c !=null){
                }if(caseObj.Derivative__c !=null){
                }
                if(caseObj.Mutual_Funds__c !=null){
                }
            }// If Closes
            if(caseObj.IsNewClient__c || caseObj.IsNewFamily__c){
                
                System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& '+riskProfileTotal);
                if(caseObj.isCorporate__c == true){
                    System.debug('*****inside non');
                    if(riskProfileTotal <= 15){
                        acc.Risk_Profile_Based_on_IPS__c = 'Conservative';
                    }else if(riskProfileTotal > 15 && riskProfileTotal <= 25){
                        acc.Risk_Profile_Based_on_IPS__c = 'Balanced';
                    }else if(riskProfileTotal > 25){
                        acc.Risk_Profile_Based_on_IPS__c = 'Aggressive';
                    }
                }else{
                    System.debug('*****inside IND');
                    if(riskProfileTotal <= 20){
                        acc.Risk_Profile_Based_on_IPS__c = 'Conservative';
                    }else if(riskProfileTotal > 20 && riskProfileTotal <= 30){
                        acc.Risk_Profile_Based_on_IPS__c = 'Balanced';
                    }else if(riskProfileTotal > 30){
                        acc.Risk_Profile_Based_on_IPS__c = 'Aggressive';
                        
                    }
                } 
                
                if(caseObj.Risk_Profile_Categories__c != null){
                    acc.Risk_Profile_Categories__c = caseObj.Risk_Profile_Categories__c;
                }    
                
                System.debug('*** Account score'+acc.Risk_Profile_Based_on_IPS__c);
                if(acc.Recordtype.Name == 'Lead'){
                    toBeUpdated.add(acc);   
                }
                    
            }
             }//date logic
             }//if closes
    }// For loop
        //}
        System.debug('IPS to be updated'+toBeUpdated);
        if(!toBeUpdated.isEmpty()){
            database.upsert(toBeUpdated,false);
            // update new List<Account>(lstUpdatedAccount);
        }
        
    }//CXO     
    }
    
    public static void calculatePaymentMode(List<Case> ticket){
        for(case caseObj : ticket){
             if(EdelweissConstants.CaseRecordTypeMap.get(caseObj.RecordTypeId) == EdelweissConstants.FUND_TRANSFER){
				if(CaseObj.Beneficiary_bank_IFSC_code__c.contains('HDFC')){
					CaseObj.Payment_Mode__c = 'I';
				}else{
					if(CaseObj.Amount_Requested_for_Transfer__c > 200000){
						CaseObj.Payment_Mode__c = 'R';
					}else if(CaseObj.Amount_Requested_for_Transfer__c <= 200000){
						CaseObj.Payment_Mode__c = 'N';
					}
				}
        }
        }
    }
    
    /*public static void riskProfileHistory(List<Case> tickets,Map<Id,Case> oldMap){      

for(Case cObj : tickets){
Boolean isValueChanged = false;
if(EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
Risk_Profile_History__c riskObj = new Risk_Profile_History__c();
Case OldCase = oldMap.get(cObj.Id);
if((OldCase.Investment_philosophy__c != cObj.Investment_philosophy__c)){
riskObj.Investment_philosophy__c = OldCase.Investment_philosophy__c;
isValueChanged = true;
}

if((OldCase.Equity_Markets__c!= cObj.Equity_Markets__c)){
riskObj.Equity_Markets__c= OldCase.Equity_Markets__c;
isValueChanged = true;
}

if((OldCase.Age_RiskProfile__c != cObj.Age_RiskProfile__c)){
riskObj.Age__c = OldCase.Age_RiskProfile__c;
isValueChanged = true;
}

if((OldCase.Financial_Goals__c != cObj.Financial_Goals__c)){
riskObj.Financial_Goals__c = OldCase.Financial_Goals__c;
isValueChanged = true;
}

if((OldCase.Investment_goal__c != cObj.Investment_goal__c)){
riskObj.Investment_goal__c = OldCase.Investment_goal__c;
isValueChanged = true;
}

if((OldCase.Amount_of_fluctuations__c != cObj.Amount_of_fluctuations__c)){
riskObj.Amount_of_fluctuations__c = OldCase.Amount_of_fluctuations__c;
isValueChanged = true;
}

if((OldCase.worst_and_best_one_year_return__c != cObj.worst_and_best_one_year_return__c)){
riskObj.worst_and_best_one_year_return__c = OldCase.worst_and_best_one_year_return__c;
isValueChanged = true;
}

if((OldCase.Interest_in_leverage_borrowing_products__c != cObj.Interest_in_leverage_borrowing_products__c)){
riskObj.Interest_in_leverage_borrowing_products__c = OldCase.Interest_in_leverage_borrowing_products__c;
isValueChanged = true;
}

if((OldCase.Diversified_portfolio__c != cObj.Diversified_portfolio__c)){
riskObj.Diversified_portfolio__c = OldCase.Diversified_portfolio__c;
isValueChanged = true;
}

if((OldCase.Investment_portfolio__c != cObj.Investment_portfolio__c)){
riskObj.Investment_portfolio__c = OldCase.Investment_portfolio__c;
isValueChanged = true;
}

if((OldCase.Alternative_Investments__c != cObj.Alternative_Investments__c)){
riskObj.Alternative_Investments__c = OldCase.Alternative_Investments__c;
isValueChanged = true;
}

if((OldCase.Time_line_for_Trading__c != cObj.Time_line_for_Trading__c)){
riskObj.Time_line_for_Trading__c = OldCase.Time_line_for_Trading__c;
isValueChanged = true;
}

if((OldCase.Investment_Style__c != cObj.Investment_Style__c)){
riskObj.Investment_Style__c = OldCase.Investment_Style__c;
isValueChanged = true;
}

if((OldCase.Stop_Loss__c != cObj.Stop_Loss__c)){
riskObj.Stop_Loss__c = string.valueOf(OldCase.Stop_Loss__c);
isValueChanged = true;
}

if((OldCase.Direct_Equity__c != cObj.Direct_Equity__c)){
riskObj.Direct_Equity_Investment_Experience_Y__c = string.valueOf(OldCase.Direct_Equity__c);
isValueChanged = true;
}

if((OldCase.Derivative__c != cObj.Derivative__c)){
riskObj.Derivative_Investment_Experience_Yrs__c = string.valueOf(OldCase.Derivative__c);
isValueChanged = true;
}

if((OldCase.Mutual_Funds__c != cObj.Mutual_Funds__c)){
riskObj.Mutual_Funds_Investment_Experience_Y__c = string.valueOf(OldCase.Mutual_Funds__c);
isValueChanged = true;
}
riskObj.Case__c = OldCase.Id;
riskObj.LastModifiedBy__c = cObj.LastModifiedById;

if(isValueChanged){
CaseManagementTriggerHandler.createFieldHistory(riskObj);
}

}

}
}   

public static void createFieldHistory(Risk_Profile_History__c riskObj){ 
if(riskObj != null){
database.insert(riskObj,false);
} 
}*/
    
    
    public static void restrictRiskProfileUpdate(List<Case> tickets,Map<Id,Case> oldMap){    
        Map<id,Case> mapOfCaseId = new Map<id,Case>();
        for(Case cObj : tickets){
            if(EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                mapOfCaseId.put(cObj.id,cObj);
            }
        }
        
        List<Task> lstTask = [SELECT Id, Status,WhatId FROM Task WHERE WhatId=:mapOfCaseId.keySet() AND Subject = 'MOUI Auto Closure' AND Status = 'Completed'];
        List<Profile> currentUserProfile = new  List<Profile>();
        Map<Id,Profile> tempProfileMap = new Map<Id,Profile>();
        tempProfileMap = EdelweissConstants.profileMap;
        for(Id key : tempProfileMap.keySet()){
            Profile obj = tempProfileMap.get(key);
            if(obj.Id == userinfo.getProfileId()){
                currentUserProfile.add(obj);
            }
        }
        for(Task taskObj : lstTask){
            Case cObj = mapOfCaseId.get(taskObj.WhatId);
            if(cObj != null){
                case OldCase = oldMap.get(cObj.id);
                if((OldCase.Investment_philosophy__c != cObj.Investment_philosophy__c) &&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_philosophy__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                    
                }
                if((OldCase.Risk_Profile_Categories__c != cObj.Risk_Profile_Categories__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Risk_Profile_Categories__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                    
                }
                
                if((OldCase.Equity_Markets__c!= cObj.Equity_Markets__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Equity_Markets__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Age_RiskProfile__c != cObj.Age_RiskProfile__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Age_RiskProfile__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Financial_Goals__c != cObj.Financial_Goals__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Financial_Goals__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Investment_goal__c != cObj.Investment_goal__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_goal__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');                  
                }
                
                if((OldCase.Amount_of_fluctuations__c != cObj.Amount_of_fluctuations__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Amount_of_fluctuations__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.worst_and_best_one_year_return__c != cObj.worst_and_best_one_year_return__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.worst_and_best_one_year_return__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Interest_in_leverage_borrowing_products__c != cObj.Interest_in_leverage_borrowing_products__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Interest_in_leverage_borrowing_products__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Diversified_portfolio__c != cObj.Diversified_portfolio__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Diversified_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Investment_portfolio__c != cObj.Investment_portfolio__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Alternative_Investments__c != cObj.Alternative_Investments__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Alternative_Investments__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Time_line_for_Trading__c != cObj.Time_line_for_Trading__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Time_line_for_Trading__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Investment_Style__c != cObj.Investment_Style__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_Style__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Stop_Loss__c != cObj.Stop_Loss__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Stop_Loss__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Direct_Equity__c != cObj.Direct_Equity__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Direct_Equity__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');  
                }
                
                if((OldCase.Derivative__c != cObj.Derivative__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Derivative__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                
                if((OldCase.Mutual_Funds__c != cObj.Mutual_Funds__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Mutual_Funds__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }   
                if((OldCase.worst_and_best_one_year_return_Non_Ind__c != cObj.worst_and_best_one_year_return_Non_Ind__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                if((OldCase.Amount_of_fluctuations_Non_Ind__c != cObj.Amount_of_fluctuations_Non_Ind__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                if((OldCase.Interest_leverage_products_Non_Ind__c != cObj.Interest_leverage_products_Non_Ind__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }
                if((OldCase.Alternative_Investments_Non_Ind__c != cObj.Alternative_Investments_Non_Ind__c)&&	!(currentUserProfile[0].Name.contains('System Administrator'))){
                    cObj.Investment_portfolio__c.addError('Risk Profile section value is not allowed to change after Skip or Send MOUI');
                }   
                
            }// if account opening
            
            
            
        }// for
        
        
    }//method
    
    
    
    public static void restrictAmountUpdate(List<Case> tickets,Map<Id,Case> oldMap){        
        for(Case cObj : tickets){
            if(EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.FUND_TRANSFER){
                List<Profile> currentUserProfile = new  List<Profile>();
                Map<Id,Profile> tempProfileMap = new Map<Id,Profile>();
                tempProfileMap = EdelweissConstants.profileMap;
                for(Id key : tempProfileMap.keySet()){
                    Profile obj = tempProfileMap.get(key);
                    if(obj.Id == userinfo.getProfileId()){
                        currentUserProfile.add(obj);
                    }
                }
                Case OldCase = oldMap.get(cObj.Id);
                System.debug('currentUserProfile[0].Name'+currentUserProfile[0].Name);
                
            if((OldCase.Amount_Requested_for_Transfer__c!= cObj.Amount_Requested_for_Transfer__c) && cObj.OwnerId =='00G28000001mZgK'){
 					cObj.addError('WealthOps team is not allowed to change Amount Requested for Transfer');
            }
                if((OldCase.Amount_Requested_for_Transfer__c!= cObj.Amount_Requested_for_Transfer__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Amount Requested for Transfer');
                }
                if((OldCase.Exported__c!= cObj.Exported__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Exported');
                }
                if((OldCase.Trading_Account_Number__c!= cObj.Trading_Account_Number__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Trading Account Number');
                }
                if((OldCase.Payment_Mode__c!= cObj.Payment_Mode__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Payment Mode');
                }
                if((OldCase.Description!= cObj.Description) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Description');
                }
                if((OldCase.Remarks__c!= cObj.Remarks__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Remarks');
                }
                if((OldCase.Beneficiary_bank_IFSC_code__c!= cObj.Beneficiary_bank_IFSC_code__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Beneficiary bank IFSC code');
                }
                if((OldCase.Beneficiary_Name__c!= cObj.Beneficiary_Name__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Beneficiary Name');
                }
                if((OldCase.Beneficiary_Account_Number__c!= cObj.Beneficiary_Account_Number__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Beneficiary Account Number');
                }
                if((OldCase.Remitter_Name__c!= cObj.Remitter_Name__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Remitter Name');
                }
                if((OldCase.Remitter_Account_No__c!= cObj.Remitter_Account_No__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Remitter Account No');
                }
                if((OldCase.Risk_Approval__c!= cObj.Risk_Approval__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Risk Approval');
                }
                if((OldCase.Status!= cObj.Status) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Status');
                }
                if((OldCase.Priority!= cObj.Priority) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Priority');
                }
                if((OldCase.Contacted_By_Others__c!= cObj.Contacted_By_Others__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change 	Others');
                }
                if((OldCase.Contacted_By__c!= cObj.Contacted_By__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Contacted By');
                }
                if((OldCase.Telephone__c!= cObj.Telephone__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Telephone');
                }
                if((OldCase.Transfer_To__c!= cObj.Transfer_To__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Transfer To');
                }
                if((OldCase.Client_Account__c!= cObj.Client_Account__c) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Client Account');
                }
                if((OldCase.Origin!= cObj.Origin) && currentUserProfile[0].Name.contains('Client Experience Office')){
                    cObj.addError('CXO Profile is not allowed to change Case Origin');
                }
            }
        }
    }  
    public static void copyDateFields(List<Case> ticket){
          for(Case cObj : ticket){
           if(EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.FUND_TRANSFER){
        //Instruction Date
           DateTime dT = System.today();
            String mm =  String.valueOf(dT.month());
            String dd =  String.valueOf(dT.day());  
            String yyyy =  String.valueOf(dT.year());   
			String dateConverted = dd+'/'+mm+'/'+yyyy;
            cObj.Instruction_Date__c = dateConverted;
            cObj.Payment_Date__c   = dateConverted;
    		cObj.Date__c = dateConverted;
                
                String originalRemitterAccount = '';
                String remitterAccountWithPadding = '';
                if(cObj.Remitter_Account_No_Debit_Account_No__c != null){
                  cObj.Remitter_Code__c = cObj.Remitter_Account_No_Debit_Account_No__c;
                  cObj.Remitter_Code__c =  cObj.Remitter_Account_No_Debit_Account_No__c;
                  originalRemitterAccount = cObj.Remitter_Account_No_Debit_Account_No__c;
                  remitterAccountWithPadding = originalRemitterAccount.leftPad(15,'0');
                }
 				if(remitterAccountWithPadding !=null){
                    cObj.Account_No__c = remitterAccountWithPadding;
                    cObj.Remitter_Account_No__c = remitterAccountWithPadding;
                }   
                
           }}
    }
    public static void copyFields(List<Case> ticket){
        //Fund Transfer related fields copy
        for(Case cObj : ticket){
           if(EdelweissConstants.CaseRecordTypeMap.get(cObj.RecordTypeId) == EdelweissConstants.FUND_TRANSFER){
                 String originalRemitterAccount = '';
                String remitterAccountWithPadding = '';
                if(cObj.Remitter_Account_No_Debit_Account_No__c != null){
                  cObj.Remitter_Code__c = cObj.Remitter_Account_No_Debit_Account_No__c;
                  cObj.Remitter_Code__c =  cObj.Remitter_Account_No_Debit_Account_No__c;
                  originalRemitterAccount = cObj.Remitter_Account_No_Debit_Account_No__c;
                  remitterAccountWithPadding = originalRemitterAccount.leftPad(15,'0');
                }
 				if(remitterAccountWithPadding !=null){
                    cObj.Account_No__c = remitterAccountWithPadding;
                    cObj.Remitter_Account_No__c = remitterAccountWithPadding;
                }   
            if(cObj.Payment_Mode__c != null){
               cObj.Payment_Type__c = cObj.Payment_Mode__c;
            }
            if(cObj.Amount_Requested_for_Transfer__c != null){
                cObj.Amount_FundTransfer__c = cObj.Amount_Requested_for_Transfer__c;
            }
            if(cObj.CaseNumber != null){
                cObj.Customer_Reference_No__c = String.valueOf(cObj.CaseNumber);
            }
            if(cObj.Transfer_To__c != null){
                cObj.Narration__c = 'Corpus Out ('+cObj.Transfer_To__c+')';
            }
            if(cObj.Amount_Requested_for_Transfer__c != null){
                cObj.Debit__c = cObj.Amount_Requested_for_Transfer__c;
            }
                if(cObj.Client_Name__c!= null){
                    cObj.Beneficary_Code__c = cObj.Client_Name__c;
                }
            }
        }
		
    }
    public static void fetchSalutations(List<Case> ticket){
        System.debug('ticket'+ticket);
        System.debug('Inside fetch');
        List<Id> listOfAccountId = new List<Id> ();
        Map<Id,Case> mapOfAccountCase = new  Map<Id,Case>();
        for(Case c : ticket){
            listOfAccountId.add(c.AccountId);
            mapOfAccountCase.put(c.AccountId , c);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT id , Primary_Email__c , Salutation__c FROM Account WHERE id In:listOfAccountId]);
        
        for(Id accountId : mapOfAccountCase.keyset()){
            Case CaseObj = mapOfAccountCase.get(accountId);
            Account accountObj = accountMap.get(accountId);
            if(EdelweissConstants.CaseRecordTypeMap.get(caseObj.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){ 
                if(accountObj.Salutation__c != null){
                    CaseObj.Salutation__c = accountObj.Salutation__c;
                }
            }
            System.debug('CaseObj ***'+CaseObj);
        }
        
    }
	public static void updateManagerEmail(List<Case> ticket){
               MAP<ID , User> tempMap = EdelweissConstants.userList;
        List<ID> AccountList = new  List<ID>();
        for(Case objCase : ticket){
            if(objCase.OwnerId =='00G28000001mZgK'){
                 objCase.TicketOwnerManagerEmail__c = 'wealthops@edelweissfin.com';
            }
            else{
            User u = tempMap.get(UserInfo.getUserId());
			User u1 = tempMap.get(objCase.OwnerId);
            AccountList.add(objCase.accountId);
                if(u1 != null){
            if(u1.Manager.email != null){
               objCase.TicketOwnerManagerEmail__c = u1.Manager.email;
            }
                }
                if(u != null){
			if(u.Manager.email != null){
				objCase.TicketCreatorManagerEmail__c = u.Manager.email;
			}
            }
        }
    }
    }
    
    public static void updatePANonLead(List<Case> ticket){
        
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        Set<Id> accountIdSet = new Set<Id>();
        for(Case objCase : ticket){
            if(caseRecordType.contains(objCase.RecordTypeId) && (!String.isBlank(objCase.PAN_Number__c) || !String.isBlank(objCase.Entity_Type__c))){
                accountIdSet.add(objCase.AccountId);
                if(objCase.Lead_Account__c != null){
                    accountIdSet.add(objCase.Lead_Account__c);
                }
            }
        }
        
        if(!accountIdSet.isEmpty()){
        
            Map<Id, Account> mapAccount = new Map<Id, Account>([
                SELECT Id, Name, PAN_Number__c 
                FROM Account
                WHERE RecordTypeId = :Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId()
                AND Id IN :accountIdSet
            ]);
            
            Set<Account> lstUpdatedAccount = new Set<Account>();
            Set<Id> accountId = new Set<Id>();
            system.debug('###--->'+ticket);
            for(Case objCase : ticket){
                Account objAccount = mapAccount.get(objCase.AccountId);
                if(objAccount != null && caseRecordType.contains(objCase.RecordTypeId) && !accountId.contains(objAccount.Id)){
                    objAccount.PAN_Number__c = objCase.PAN_Number__c;
                    objAccount.Entity_Type__c = objCase.Entity_Type__c;
                    lstUpdatedAccount.add(objAccount);
                    accountId.add(objAccount.Id);
                }
                
                Account objBackendLeadAccount = mapAccount.get(objCase.Lead_Account__c);
                if(objBackendLeadAccount != null && caseRecordType.contains(objCase.RecordTypeId) && !accountId.contains(objBackendLeadAccount.Id)){
                    objBackendLeadAccount.PAN_Number__c = objCase.PAN_Number__c;
                    objBackendLeadAccount.Entity_Type__c = objCase.Entity_Type__c;
                    lstUpdatedAccount.add(objBackendLeadAccount);
                    accountId.add(objBackendLeadAccount.Id);
                }
            }
            if(!lstUpdatedAccount.isEmpty()){
                database.update(new List<Account>(lstUpdatedAccount),false);
               // update new List<Account>(lstUpdatedAccount);
            }
        }
    }
    
    public static void updateAccountOnAccountOpenCase(List<Case> currentCaseList){
        String isNewClient = 'FALSE';
         List<Id> accountIds =  new List<Id>();
        for(Case currentCaseRecord: currentCaseList){
            if(currentCaseRecord.AccountId != null)
                accountIds.add(currentCaseRecord.AccountId);
        }
        Map<Id,Account> accountMap =  new Map<Id,Account>([Select Id, Open_an_account_opening_Case__c,RecordTypeId From Account Where Id IN : accountIds]);
        List<Account> accountUpdate =  new List<Account>();
        Id leadRecordId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId(); 
        for(Case currentCaseRecord: currentCaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.EXCHANGE_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FUNDING_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING || EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
                Account accRecord = accountMap.get(currentCaseRecord.AccountId);
                if(!accRecord.Open_an_account_opening_Case__c && accRecord.RecordTypeId == leadRecordId ){                 
                    accRecord.Open_an_account_opening_Case__c = true;
                    accountUpdate.add(accRecord);
                }                                       
            }            
        }
        
        if(accountUpdate != null && accountUpdate.size() > 0){
            update accountUpdate;
        }
    
    }   
    
    public static void validationForNewLead(List<Case> lstCase){
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        Set<Id> accountRecordType = new Set<Id>();
               
        accountRecordType.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId());
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Case objCase : lstCase){
            if(caseRecordType.contains(objCase.RecordTypeId) ){
                accountIdSet.add(objCase.AccountId);
            }
        }
        if(accountIdSet != null && accountIdSet.size() > 0){
            accountMap = new Map<Id,Account>([Select Id,Coverage__c From Account Where Id IN:accountIdSet And RecordTypeId IN : accountRecordType]);
        }
        
        List<Account> lstInsertAccount =  new List<Account>();
        Map<String,Case> CaseparentAccountMap =  new Map<String,Case>();
        List<Case> lstUpdatecase =  new List<Case>();
        for(Case objCase : lstCase){
            if(accountMap.containsKey(objCase.AccountId) ){
                Account acc = accountMap.get(objCase.AccountId);
                if(acc.Coverage__c != 'R2'){
                    objCase.addError('User can open case only after Lead Coverage is in R2');
                }               
            }
        }
        
    }
    
    public static void validationForExistingFamily(List<Case> lstCase){
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        
        Set<Id> accountRecordType = new Set<Id>();
        Id LeadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        Id FamilyRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
        accountRecordType.add(LeadRecordTypeId);
        accountRecordType.add(FamilyRecordTypeId);
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Case objCase : lstCase){
            if(caseRecordType.contains(objCase.RecordTypeId) ){
                accountIdSet.add(objCase.AccountId);
            }
        }
        if(accountIdSet != null && accountIdSet.size() > 0){
            accountMap = new Map<Id,Account>([Select Id, RecordTypeId,Primary_Email__c From Account Where Id IN:accountIdSet And RecordTypeId IN : accountRecordType]);
        }
        
        for(Case objCase : lstCase){
            if(accountMap.containsKey(objCase.AccountId) && accountMap.get(objCase.AccountId).RecordTypeId == FamilyRecordTypeId){
                if(string.isBlank(objCase.Phone__c) || string.isBlank(objCase.Email_Id__c) || string.isBlank(objCase.Client_Name__c)){
                    objCase.addError('For new client of existing family Phone, Email and Client Name is required');
                    
                    if(string.isBlank(objCase.Phone__c))
                        objCase.Phone__c.addError('Value Required');
                    if(string.isBlank(objCase.Email_Id__c))
                        objCase.Email_Id__c.addError('Value Required');
                    if(string.isBlank(objCase.Client_Name__c))
                        objCase.Client_Name__c.addError('Value Required');
                }               
            }/*
            else if(accountMap.containsKey(objCase.AccountId) && accountMap.get(objCase.AccountId).RecordTypeId == LeadRecordTypeId){
                if(!string.isBlank(objCase.Phone__c) || !string.isBlank(objCase.Email_Id__c) || !string.isBlank(objCase.Client_Name__c)){
                    objCase.addError('For a case on Lead record the Phone, Email and Client Name fields of Existing Family New Client section should be blank');
                    
                    if(!string.isBlank(objCase.Phone__c))
                        objCase.Phone__c.addError('Value Not Required');
                    if(!string.isBlank(objCase.Email_Id__c))
                        objCase.Email_Id__c.addError('Value Not Required');
                    if(!string.isBlank(objCase.Client_Name__c))
                        objCase.Client_Name__c.addError('Value Not Required');
                } 
			}*/
        }
        
    }
    
     public static void createLeadForExistingFamily(List<Case> lstCase){
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        Set<Id> accountRecordType = new Set<Id>();
        accountRecordType.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId());
        accountRecordType.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId());
        
        Id LeadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Case objCase : lstCase){
            if(caseRecordType.contains(objCase.RecordTypeId) ){
                accountIdSet.add(objCase.AccountId);
            }
        }
        if(accountIdSet != null && accountIdSet.size() > 0){
            accountMap = new Map<Id,Account>([Select Id From Account Where Id IN:accountIdSet And RecordTypeId IN : accountRecordType]);
        }
        
        List<Account> lstInsertAccount =  new List<Account>();
        Map<String,Case> CaseparentAccountMap =  new Map<String,Case>();
        List<Case> lstUpdatecase =  new List<Case>();
        for(Case objCase : lstCase){
            if(accountMap.containsKey(objCase.AccountId) && !string.isBlank(objCase.Client_Name__c) ){
                Account accRecord = new Account();
                accRecord.Name = objCase.Client_Name__c;
                accRecord.Phone = objCase.Phone__c;
                accRecord.Primary_Email__c = objCase.Email_Id__c;
                accRecord.Coverage__c = 'R2';
                accRecord.In_Person_Meeting_Done__c = true;
                accRecord.Basic_Details_of_Mini_IPS_filled__c = true;
                accRecord.Open_an_account_opening_Case__c = true;
                CaseparentAccountMap.put(objCase.Phone__c+'__'+lstInsertAccount.size(),objCase); //accRecord.ParentId = objCase.AccountId;
                accRecord.RecordTypeId =LeadRecordTypeId;  
                accRecord.Lead_Created_From_Case__c = true;
                accRecord.Client_Representative_Mobile_Number__c = objCase.Client_Representative_Mobile_Number__c;
                accRecord.Client_Representative_Email_Id__c =objCase.Client_Representative_Email_Id__c;
                lstInsertAccount.add(accRecord);
            }
        }
        try{
            system.debug('***-->'+lstInsertAccount);
        	Database.insert(lstInsertAccount);     
            integer index = 0;
        	for(Account accRecord : lstInsertAccount){
                Case objCase = CaseparentAccountMap.get(accRecord.Phone+'__'+index);
            	if(objCase != null ){
                case newcase = new Case();
                newcase.Id = objCase.Id;
                    if(objCase.IsNewFamily__c){
                        newcase.AccountId =  accRecord.Id;
                    }else if(objCase.IsNewClient__c){
                        newcase.AccountId =  accRecord.Id;
                    }else{
                newcase.Lead_Account__c =  accRecord.Id;
                  	}  
                lstUpdatecase.add(newcase);
            }           
                index++;            
        }
        Database.update(lstUpdatecase);
        }catch(exception e){
            system.debug(e);
            if(e.getMessage().contains('DUPLICATES_DETECTED'))
                lstCase[0].addError('It looks like you are creating a duplicate Account.');
            else
                lstCase[0].addError(e.getMessage());
        }
        
    }
    

    public static void publishEmailIdFromLead(List<Case> lstCase)
    {
        
        Set<Id> caseRecordType = new Set<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());
        
        Set<Id> accountIdSet = new Set<Id>();
        for(Case objCase : lstCase){
            if(objCase.AccountId != null && caseRecordType.contains(objCase.RecordTypeId) && String.isBlank(objCase.Email_Id__c)){
                accountIdSet.add(objCase.AccountId);
            }
        }
        
        if(!accountIdSet.isEmpty()){
        
            Map<Id, Account> mapAccount = new Map<Id, Account>([
                SELECT Id, Name, Primary_Email__c, PAN_Number__c 
                FROM Account
                WHERE RecordTypeId = :Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId()
                AND Id IN :accountIdSet
            ]);
            
            for(Case objCase : lstCase){
                Account objAccount = mapAccount.get(objCase.AccountId);
                if(objAccount != null && caseRecordType.contains(objCase.RecordTypeId) && String.isBlank(objCase.Email_Id__c)){
                    objCase.Email_Id__c = objAccount.Primary_Email__c;
                }
            }
        }
    }
    
    public static void NPSCaseClose(List<Case> lstCase){
        Map<Id,User> listOfUsers = EdelweissConstants.userList;
        Set<Id> userId=new Set<Id>();
        Map<Id,Case> mapCase=new Map<Id,Case>();
        for (case caseobj: lstCase)
        {
           if(caseobj.Previous_FA__c == null)
           userId.add(caseobj.ownerId);
        }
        Map<Id,User> userMap = new Map<Id, User>([Select manager.Name,manager.Id,Profile.Name from User where id =: userId]);
        SYstem.debug('NPSCaseClose:::userMap:::'+userMap);
    
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeNameId.put(info.getName(),info.getRecordTypeId());
        }
    
        Sys_Properties__c custSettFaProfileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
        Sys_Properties__c custSettFaFOIGProfileId = Sys_Properties__c.getValues('Profile Financial Advisor FOIG Id');
        Sys_Properties__c custSettTLAdvoisoryProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory Id');
        Sys_Properties__c custSettTLAdvoisoryFOIGProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory FOIG Id');
        
        Sys_Properties__c custSettCXOProfileId = Sys_Properties__c.getValues('Profile Client Experience Office Id');
        Sys_Properties__c custSettCXONationalProfileId = Sys_Properties__c.getValues('Profile CXO National Head Id');
        Sys_Properties__c custSettCXOZonalProfileId = Sys_Properties__c.getValues('Profile CXO Zonal Head Id');     
            
        Set<Id> setFaId = new Set<Id>();
        setFaId.add(custSettFaProfileId.Value__c);
        setFaId.add(custSettFaFOIGProfileId.Value__c);
        setFaId.add(custSettTLAdvoisoryProfileId.Value__c);
        setFaId.add(custSettTLAdvoisoryFOIGProfileId.Value__c);
        setFaId.add(custSettCXOProfileId.Value__c);
        setFaId.add(custSettCXONationalProfileId.Value__c);
        setFaId.add(custSettCXOZonalProfileId.Value__c);
        
        for (case caseobj: lstCase)
        {
            User loggedInUser = listOfUsers.get(UserInfo.getUserId()); 
            
            Boolean isFAOwner = false;
            User currentUser = userMap.get(caseobj.OwnerId);
            
            if(String.isBlank(caseobj.Remarks__c) && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST) && (caseobj.Status=='Closed – Success' || caseobj.Status=='Closed – Rejected')){
                caseobj.addError('You Must Enter Remarks.');
                continue;
            }
            
            if(currentUser != null && setFaId.contains(currentUser.ProfileId)){
                isFAOwner = true;
            }
            
            if(isFAOwner && caseobj.description != null && caseobj.Status=='Closed – Success' && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {                   
                caseobj.Status ='In Progress';
                if(currentUser != null && currentUser.manager != null){
                    caseobj.Previous_FA__c = caseobj.OwnerId;
                    caseobj.OwnerId = currentUser.manager.Id;
                    caseobj.Owner_Change_Reason__c = 'NPS case close by FA.';
                }
                System.debug('NPSCaseClose:::caseobj:::'+caseobj);
            }
            
            if(loggedInUser.Profile.Name == 'CXO National Head' && caseobj.description != null && caseobj.Status=='Closed – Rejected'  && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST)){
               caseobj.Status ='Closed – Rejected';
            }else if(isFAOwner && caseobj.description != null && caseobj.Status=='Closed – Rejected'  && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {                   
                if(caseobj.Previous_FA__c != null)
                {
                    caseobj.OwnerId = caseobj.Previous_FA__c;
                    caseobj.Previous_FA__c = null;
                    caseobj.Owner_Change_Reason__c = 'Reject Case close comment';
                    caseobj.Status ='In Progress';
                }
                else{
                caseobj.addError('You Dont Have Privileges To Reject This Case');//You Can Not Reject This Case
            }
            }else if(!isFAOwner && caseobj.description != null && caseobj.Status=='Closed – Rejected'  && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {                   
                if(caseobj.Previous_FA__c != null){
                    caseobj.OwnerId = caseobj.Previous_FA__c;
                    caseobj.Previous_FA__c = null;
                    caseobj.Owner_Change_Reason__c = 'Reject Case close comment';
                    caseobj.Status ='In Progress';
                }
                System.debug('NPSCaseClose::: !isFAOwner:::caseobj:::'+caseobj);
            }
        }
    }   
    
    public static void updateDueDateAfterCaseCreate(List<Case> lstCase)
    {
        DateTime dueDate;
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            mapofCaseRecordTypeNameId.put(info.getName(),info.getRecordTypeId());
        }
        List<System_Constant__mdt> sysConstant = new List<System_Constant__mdt>();
        Integer Working5BussinessDaysInHours = 5;
        /* Query Optimization 
        sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Working5BussinessDaysInHours']; */
         Map<Id,System_Constant__mdt> tempMap = new Map<Id,System_Constant__mdt>();
        tempMap = EdelweissConstants.sysConstantMap;
        for(Id key : tempMap.keyset()){
          System_Constant__mdt obj = tempMap.get(key);
            if(obj.DeveloperName == 'Working5BussinessDaysInHours'){
                sysConstant.add(obj);
            }
        }
        // Query optimization end
        
        if(sysConstant != null && sysConstant.size() > 0){
            Working5BussinessDaysInHours = integer.valueof(sysConstant[0].Value__c);
        }
        /* Query optimization Star 
        BusinessHours stdBusinessHours = [select id from businesshours where isDefault = true];*/
        BusinessHours stdBusinessHours = EdelweissConstants.stdBusinessHours;
        
        //Query optimization End
        for (case caseobj: lstCase)
        {
            if(caseobj.CreatedDate != null)
            {
                dueDate = BusinessHours.add(stdBusinessHours.id, caseobj.CreatedDate, Working5BussinessDaysInHours * 60 * 60 * 1000);
                System.debug('Update:::updateDueDateAfterCaseCreate::dueDate::'+dueDate);
            }
            else
            {
                dueDate = BusinessHours.add(stdBusinessHours.id, System.now(),Working5BussinessDaysInHours * 60 * 60 * 1000);
                System.debug('Insert:::updateDueDateAfterCaseCreate::dueDate::'+dueDate);
            }
            /*if(dueDate != Null && caseobj.Type == 'NPS' && caseobj.RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {
               caseobj.Due_Date_Time__c = dueDate;
            }*/
        }
    }
    
    public static void ValidateForsaleFinancialTrasaction(List<Case> currentCaseList){
        Datetime transactionStartDate = System.Now();
        Map<Id,Id> caseAccountMap = new Map<Id,Id>();
        Map<Id,Id> caseProductMap = new Map<Id,Id>();
        for(Case currentCaseRecord: currentCaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && currentCaseRecord.Buy_Sell__c == 'Sell'){
                caseAccountMap.put(currentCaseRecord.Id,currentCaseRecord.AccountId);
                caseProductMap.put(currentCaseRecord.Id,currentCaseRecord.Script_Name__c);
            }
        }
        Map<Id,Set<Id>> accountProduct = new Map<Id,Set<Id>>();
        if(caseAccountMap != null && caseAccountMap.keySet().Size() > 0){
            List<Id> accId = new List<Id>(caseAccountMap.values());
            List<Client_Asset_Information__c> assetInfo = [Select Id,Client__c,Product__c From Client_Asset_Information__c Where Client__c =: accId];           
            for(Client_Asset_Information__c ass : assetInfo){
                Set<Id> prodIds = new Set<Id>();
                if(accountProduct.containsKey(ass.Client__c)){
                    prodIds = accountProduct.get(ass.Client__c);
                }
                prodIds.add(ass.Product__c);
                accountProduct.put(ass.Client__c,prodIds);
            }
        }
        
        //For Sell Product is match 
        for(Case currentCaseRecord: currentCaseList){
                if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && currentCaseRecord.Buy_Sell__c == 'Sell'){
                    if( !(Trigger.isUpdate && (currentCaseRecord.Status == 'Closed – Success' || currentCaseRecord.Status == 'Closed – Rejected')) 
                    && ((accountProduct == null || accountProduct.keySet().size() == 0) || (accountProduct.get(currentCaseRecord.AccountId) != null && !accountProduct.get(currentCaseRecord.AccountId).contains(currentCaseRecord.Script_Name__c))))
                        currentCaseRecord.addError(Label.Can_not_sell_non_purchased_product);
                }
        }
        
    }
        
    // Check is FT case product has recommended 
    public static void CheckProductRecommended(List<Case> currentCaseList){
        Map<Id,Id> CaseProductId = new Map<Id,Id> ();
        Map<Id,case> CaseMap = new Map<Id,case> ();
        List<Id> ProductId = new List<Id>();
        for(Case currentCaseRecord: currentCaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && currentCaseRecord.Buy_Sell__c != 'Sell'){                
                CaseProductId.put(currentCaseRecord.Id, currentCaseRecord.Script_Name__c);
                CaseMap.put(currentCaseRecord.Id, currentCaseRecord);
                ProductId.add(currentCaseRecord.Script_Name__c);                
            }
        }
        if(CaseProductId != null && CaseProductId.keySet().size() > 0){
            Map<Id,Product2> ProductMap = new Map<Id,Product2>([Select Id,Recommended_Product__c From Product2 Where Id =: ProductId]);
            /*query optimization 
             List<User> users = [SELECT Id,Name FROM User WHERE Profile.Name = 'System Administrator'];*/
            List<User> users =  new  List<User>();
            Map<ID , User> userMap = new Map<ID, user>();
            userMap = EdelweissConstants.userList;
            for(Id userId : userMap.keyset()){
                User u = userMap.get(userId);
                if(u.Profile.Name == 'System Administrator'){
                    users.add(u);
                }
            }
            Map<String,User> UserNameMap = new Map<String,User>();
            for(User u :users){
                UserNameMap.put(u.Name,u);
            }
            
            //Check Product recommended or not and initiate approval process.           
            for(Id caseId : CaseProductId.keySet()){
                Product2 prod = ProductMap.get(CaseProductId.get(caseId));
                case caseRec = CaseMap.get(caseId);
                if(prod != null && prod.Recommended_Product__c == 'Yes'){
                    caseRec.IsProductRecommended__c = true;
                    caseRec.Stage_Guide__c = '';
                }else{
                    caseRec.IsProductRecommended__c = false;
                    caseRec.Stage_Guide__c = 'Pending Product Recommendation Approval From RH and BH';      
                }               
            }
        }
        
    }
    
    // Check is risk profile suitability 
    public static void CheckRiskProfileSuitability(List<Case> currentCaseList, Map<Id,Case> oldMap){
        Map<Id,Id> CaseProductId = new Map<Id,Id> ();
        Map<Id,Id> CaseAccountId = new Map<Id,Id> ();
        Map<Id,case> CaseMap = new Map<Id,case> ();
        List<Id> productId = new List<Id>();
        List<Id> accId = new List<Id>();
        
        for(Case currentCaseRecord: currentCaseList){
            system.debug('currentCaseRecord==>'+currentCaseRecord);
            system.debug('oldCase==>'+oldMap);
            if( EdelweissConstants.CaseRecordTypeMap.get(currentCaseRecord.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION &&  
                currentCaseRecord.Buy_Sell__c != 'Sell' && 
                currentCaseRecord.IsProductRecommended__c == true  && 
                (((oldMap != null && currentCaseRecord.IsProductRecommended__c != oldMap.get(currentCaseRecord.Id).IsProductRecommended__c)|| oldMap == null) ||
                ((oldMap != null && currentCaseRecord.IsProductRiskProfile__c != oldMap.get(currentCaseRecord.Id).IsProductRiskProfile__c)|| oldMap == null) ) )
            {              
                CaseProductId.put(currentCaseRecord.Id, currentCaseRecord.Script_Name__c);
                CaseAccountId.put(currentCaseRecord.Id, currentCaseRecord.AccountId);
                CaseMap.put(currentCaseRecord.Id, currentCaseRecord);
                productId.add(currentCaseRecord.Script_Name__c);    
                accId.add(currentCaseRecord.AccountId);
            }
        }
        system.debug('CaseProductId==>'+CaseProductId);
        system.debug('CaseAccountId==>'+CaseAccountId);
        if(CaseProductId != null && CaseProductId.keySet().size() > 0 && CaseAccountId != null && CaseAccountId.keySet().size() > 0){
            Map<Id,Product2> ProductMap = new Map<Id,Product2>([Select Id,Risk_Profile_of_Product__c From Product2 Where Id =: productId]);
            Map<Id,Account> AccMap = new Map<Id,Account>([Select Id,Risk_Profile_Based_on_IPS__c,RecordTypeId,ParentId,Parent.Risk_Profile_Based_on_IPS__c,Parent.Rollup_AUM_of_Family__c From Account Where Id =: accId]);
            Id LeadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
            /* Query optimization Start 
		List<User> users = [SELECT Id,Name FROM User WHERE Profile.Name = 'System Administrator']; */
            List<User> users =  new  List<User>();
            Map<ID , User> userMap = new Map<ID, user>();
            userMap = EdelweissConstants.userList;
            for(Id userId : userMap.keyset()){
                User u = userMap.get(userId);
                if(u.Profile.Name == 'System Administrator'){
                    users.add(u);
                }
            }
            
            //Query optimization End 
            
            Map<String,User> UserNameMap = new Map<String,User>();
            for(User u :users){
                UserNameMap.put(u.Name,u);
            }
            
            MAP<String,Integer> riskProfileCount = new MAP<String,Integer>();
            riskProfileCount.put('Aggressive'.toUpperCase(),3);
            riskProfileCount.put('Balanced'.toUpperCase(),2);
            riskProfileCount.put('Conservative'.toUpperCase(),1);
            
            //Check Product recommended or not and initiate approval process.  
            List<Case> lstAssignToCSO = new List<Case>();
            for(Id caseId : CaseProductId.keySet()){
                Product2 prod = ProductMap.get(CaseProductId.get(caseId));
                case caseRec = CaseMap.get(caseId);
                Account acc = AccMap.get(CaseAccountId.get(caseId));
                system.debug('accRisk'+acc.Risk_Profile_Based_on_IPS__c);
                system.debug('prodRisk'+prod.Risk_Profile_of_Product__c);
                
                if(prod.Risk_Profile_of_Product__c != null){
                    //caseRec.IsProductRiskProfile__c = true;   
                    caseRec.Stage_Guide__c = '';
                }else{
                    //caseRec.IsProductRiskProfile__c = false;   
                    caseRec.Stage_Guide__c = 'Pending to Update Product with Risk Profile value';
                }
                
                if(prod.Risk_Profile_of_Product__c != null && ((acc.RecordTypeId == LeadRecordTypeId &&acc.Risk_Profile_Based_on_IPS__c != null) || (acc.RecordTypeId != LeadRecordTypeId && acc.ParentId != null && acc.Parent.Risk_Profile_Based_on_IPS__c != null))){
                    integer accRisk = 0;
                    if(acc.RecordTypeId != LeadRecordTypeId)
                        accRisk = riskProfileCount.get(acc.Parent.Risk_Profile_Based_on_IPS__c.toUpperCase());
                    else
                        accRisk = riskProfileCount.get(acc.Risk_Profile_Based_on_IPS__c.toUpperCase());
                    
                    Decimal familyAUAInLakh = 0;
                    if(acc.ParentId != null && acc.Parent.Rollup_AUM_of_Family__c != null && acc.Parent.Rollup_AUM_of_Family__c != 0)
                        familyAUAInLakh = (((acc.Parent.Rollup_AUM_of_Family__c /100000) * 10)/100);
                    
                    integer prodRisk = riskProfileCount.get(prod.Risk_Profile_of_Product__c.toUpperCase());
                    system.debug('accRisk'+accRisk);
                    system.debug('prodRisk'+prodRisk);
                    system.debug('familyAUAInLakh'+familyAUAInLakh);
                    //If CRP >= PRP direct change case owner to CSO
                    //CRP +1 = PRP then Amount of FT is <= 10% AUA submit for RH approval  
                    if(accRisk > = prodRisk){
                        caseRec.IsCaseAssignToCSO__c = true;
                        caseRec.Stage_Guide__c = '';
                        lstAssignToCSO.add(caseRec);
                    }else if((accRisk + 1) == prodRisk && caseRec.Amount__c <= familyAUAInLakh){
                        caseRec.IsSendToRHApproval__c = true;
                        caseRec.Stage_Guide__c = 'Pending Product Suitability Approval From RH';                        
                    }else{
                        caseRec.IsSendToFAUploadClientApproval__c = true;   
                        caseRec.Stage_Guide__c = 'Pending Upload Client Approval By FA';
                    }
                    
                }else{                  
                    //caseRec.Stage_Guide__c = 'Please fill risk profile on Family and select product';
                }           
            }
            
            if(lstAssignToCSO != null && lstAssignToCSO.size() > 0){
                CaseManagementTriggerHandler.assignCaseOwner(lstAssignToCSO,null);
            }
        }
        
    }
    
    // Check is risk profile suitability 
    public static void updateBHandRH(List<Case> CaseList, Map<Id,Case> oldMap){
        system.debug('updateBHandRH'+CaseList);
        /* Query Optimization Start
Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, Name, ManagerId, Business_Head__c,Regional_Head__c FROM User]); */
       Map<ID , User> userMap = new Map<ID, user>();
        userMap = EdelweissConstants.userList;
        //Query optimization end
        Set<Id> FAIdSet = new Set<Id>();
        List<Id> accIds = new List<Id>();
        for(Case caseRec : CaseList){
            if(oldMap == null){
                accIds.add(caseRec.AccountId);
            }else if(oldMap != null && oldMap.get(caseRec.Id).OwnerId != caseRec.OwnerId){
               accIds.add(caseRec.AccountId);
            }           
        }
        if(accIds != null && accIds.size() > 0){
            
            Map<Id,Account> mapAcc = new Map<Id,Account>([Select Id,OwnerId From Account Where Id =:accIds]);
            for(Case caseRec : CaseList){
                if(oldMap == null && caseRec.AccountId != null && mapAcc.get(caseRec.AccountId) != null && userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId) != null){
                    caseRec.Business_Head__c = userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId).Business_Head__c;
                    caseRec.Regional_Head__c = userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId).Regional_Head__c;
                    FAIdSet.add(mapAcc.get(caseRec.AccountId).OwnerId);
                }else if(oldMap != null && oldMap.get(caseRec.Id).OwnerId != caseRec.OwnerId  && caseRec.AccountId != null && mapAcc.get(caseRec.AccountId) != null && userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId) != null){
                    caseRec.Business_Head__c = userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId).Business_Head__c;
                    caseRec.Regional_Head__c = userMAP.get(mapAcc.get(caseRec.AccountId).OwnerId).Regional_Head__c;
                    FAIdSet.add(mapAcc.get(caseRec.AccountId).OwnerId);
                }           
            }
            if(FAIdSet != null && FAIdSet.size() > 0){
                Map<Id,Id>FAIdCSOIdMap = new Map<Id,Id>();
                List<FA_CSO_Mapping__c> FACSOUsersList = [Select Is_Mapped_CXO__c, Id, FA_User__c, CSO_User__c From FA_CSO_Mapping__c Where FA_User__c IN:FAIdSet];
                for(FA_CSO_Mapping__c FACSOUser : FACSOUsersList){
                    FAIdCSOIdMap.put(FACSOUser.FA_User__c,FACSOUser.CSO_User__c);   
                }
                if(FAIdCSOIdMap != null){
                    for(Case caseRec : CaseList){
                        if(FAIdCSOIdMap.get(caseRec.OwnerId) != null)
                        caseRec.CSO_User__c = FAIdCSOIdMap.get(caseRec.OwnerId);
                    }
                }
            }       
        }        
    }   
    
    // Check is risk profile suitability 
    public static void InitiateApprovalRequest(List<Case> CaseList, Map<Id,Case> oldMap){
        /* Query Optimization start 
Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, Name, ManagerId, Business_Head__c,Regional_Head__c FROM User]); */
        Map<ID , User> userMap = new Map<ID, user>();
        userMap = EdelweissConstants.userList;
        // Query Optimization End
        for(Case caseRec : CaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(caseRec.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && caseRec.Buy_Sell__c != 'Sell'){
                if(caseRec.IsProductRecommended__c == false && oldMap == null && caseRec.Regional_Head__c != null && caseRec.Business_Head__c != null ){
                    Approval.ProcessSubmitRequest req1 =   new Approval.ProcessSubmitRequest();
                    req1.setObjectId(caseRec.id);
                    req1.setSubmitterId(caseRec.OwnerId);
                    req1.setProcessDefinitionNameOrId('Product_Recommendation_Approval_RH_BH');
                    Approval.ProcessResult result = Approval.process(req1);
                }           
                if(caseRec.IsSendToRHApproval__c && (oldMap == null || oldMap.get(caseRec.Id).IsSendToRHApproval__c != caseRec.IsSendToRHApproval__c ) && caseRec.Regional_Head__c != null){
                    Approval.ProcessSubmitRequest req1 =   new Approval.ProcessSubmitRequest();
                    req1.setObjectId(caseRec.id);
                    req1.setSubmitterId(caseRec.OwnerId);
                    req1.setProcessDefinitionNameOrId('Product_Suitability_Approval_From_RH');
                    Approval.ProcessResult result = Approval.process(req1);
                }           
            }           
        }
    }
    
    public static void restrictTaskEscalation(List<Case> CaseList, Map<Id,Case> oldMap){
        
        Set<Id> rejectedCaseIds = new Set<Id>();
        Set<Id> notRejectedCaseIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        List<Task> lstTaskToUpdate = new List<Task>();
        
        for(Case c : CaseList){
            if(c.Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS && c.Status != oldMap.get(c.Id).Status){
                rejectedCaseIds.add(c.Id);
            }
            if(oldMap.get(c.Id).Status == EdelweissConstants.CASE_CLOSED_REJECTED_STATUS && c.Status != oldMap.get(c.Id).Status){
                notRejectedCaseIds.add(c.Id);
            }
        }
        
        caseIds.addAll(rejectedCaseIds);
        caseIds.addAll(notRejectedCaseIds);
        if(!caseIds.isEmpty()){
            List<Task> lstTask = [
                SELECT Id, WhatId, Case_Rejected__c FROM Task 
                WHERE WhatId IN :caseIds AND Status <> :EdelweissConstants.TASK_COMPLETED_STATUS
            ];
            
            if(!lstTask.isEmpty()){
                for(Task t : lstTask){
                    if(rejectedCaseIds.contains(t.WhatId) && !t.Case_Rejected__c){
                    t.Case_Rejected__c = true;
                        lstTaskToUpdate.add(t);
                    }else if(notRejectedCaseIds.contains(t.WhatId) && t.Case_Rejected__c){
                        t.Case_Rejected__c = false;
                        lstTaskToUpdate.add(t);
                    }
                }
            }
        }
            
        System.debug('lstTaskToUpdate '+lstTaskToUpdate);
        if(!lstTaskToUpdate.isEmpty()){
            update lstTaskToUpdate;
        }
    }
    public static void InitiateTradingApprovalRequest(List<Case> CaseList){
        for(Case caseRec : CaseList){
            if(EdelweissConstants.CaseRecordTypeMap.get(caseRec.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING && caseRec.Special_Brokerage_Approval_Status__c != 'Approved' && caseRec.Special_Brokerage_RM_Approval_Required__c){
                Approval.ProcessSubmitRequest req1 =   new Approval.ProcessSubmitRequest();
                req1.setObjectId(caseRec.id);
                req1.setSubmitterId(caseRec.CreatedById);
                req1.setProcessDefinitionNameOrId('Special_Brokerage_Approval_RA');
                Approval.ProcessResult result = Approval.process(req1);    
            }           
        }
    }
    
    // Reinitiate approval process for Special Brokerage
    public static void reinitiateTradingApprovalRequest(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        
        List<Id> caseSendApprovalReq = new List<Id>();
        
        for(Id caseId : newCaseMap.keySet()){
            Case caseRec = newCaseMap.get(caseId);
            Case oldCaseRec = oldCaseMap.get(caseId);
            if(EdelweissConstants.CaseRecordTypeMap.get(caseRec.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING && (
                caseRec.Delivery_Slab__c != oldCaseRec.Delivery_Slab__c ||
                caseRec.Delivery_Minimum_P__c != oldCaseRec.Delivery_Minimum_P__c ||
                caseRec.Delivery_Sides__c != oldCaseRec.Delivery_Sides__c ||
                caseRec.Intraday_Slab__c != oldCaseRec.Intraday_Slab__c ||
                caseRec.Intraday_Minimum_P__c != oldCaseRec.Intraday_Minimum_P__c ||
                caseRec.Intraday_Sides__c != oldCaseRec.Intraday_Sides__c ||
                caseRec.Currency_Futures_Slab__c != oldCaseRec.Currency_Futures_Slab__c ||
                caseRec.Currency_Futures_Minimum_P__c != oldCaseRec.Currency_Futures_Minimum_P__c ||
                caseRec.Currency_Futures_Sides__c != oldCaseRec.Currency_Futures_Sides__c ||
                caseRec.Derivatives_Futures_Slab__c != oldCaseRec.Derivatives_Futures_Slab__c ||
                caseRec.Derivatives_Futures_Minimum_P__c != oldCaseRec.Derivatives_Futures_Minimum_P__c ||
                caseRec.Derivatives_Futures_Sides__c != oldCaseRec.Derivatives_Futures_Sides__c ||
                caseRec.Derivatives_Options_Slab__c != oldCaseRec.Derivatives_Options_Slab__c ||
                caseRec.Derivatives_Options_Minimum_P__c != oldCaseRec.Derivatives_Options_Minimum_P__c ||
                caseRec.Derivatives_Options_Sides__c != oldCaseRec.Derivatives_Options_Sides__c ||
                caseRec.Currency_Options_Slab__c != oldCaseRec.Currency_Options_Slab__c ||
                caseRec.Currency_Options_Sides__c != oldCaseRec.Currency_Options_Sides__c ||
                caseRec.Currency_Options_Minimum_P__c != oldCaseRec.Currency_Options_Minimum_P__c )
              ){
                  caseSendApprovalReq.add(caseId);
              }
            
            /*if(!caseSendApprovalReq.isEmpty()){
                List<ProcessInstance> pi = [
                    SELECT ID, Status, TargetObjectId FROM ProcessInstance WHERE TargetObjectID = :caseSendApprovalReq AND Status = 'Rejected'
                ];
                
                if(!pi.isEmpty()){
                    for(ProcessInstance p : pi){
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setObjectId(p.TargetObjectId);
                        req1.setSubmitterId(newCaseMap.get(p.TargetObjectId).CreatedById);
                        req1.setProcessDefinitionNameOrId('Special_Brokerage_Approval_RA');
                        Approval.ProcessResult result = Approval.process(req1);
                    }
                }
}*/
            if(!caseSendApprovalReq.isEmpty()){
                List<ProcessInstance> pi = [
                    SELECT ID, Status, TargetObjectId FROM ProcessInstance WHERE TargetObjectID = :caseSendApprovalReq  ORDER BY createddate DESC];
                List<ProcessInstance> piNew = new List<ProcessInstance>();
                if(pi != null && !pi.isEmpty()){
                    if(pi[0] != null){
                        piNew.add(pi[0]); 
                    }
                }
                if(!pi.isEmpty()){
                    for(ProcessInstance p : piNew){
                        if(p.Status == 'Rejected'){
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setObjectId(p.TargetObjectId);
                            req1.setSubmitterId(newCaseMap.get(p.TargetObjectId).CreatedById);
                            req1.setProcessDefinitionNameOrId('Special_Brokerage_Approval_RA');
                            Approval.ProcessResult result = Approval.process(req1);
                        }
                    }
            }
        }
            
            
            
        }
    }
    
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
 }