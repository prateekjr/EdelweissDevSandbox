public class MOUIIntegration {
    
    @AuraEnabled
    public static String sendReq(String taskId){
        
        String strResponse = 'Case details updated';
        strResponse = validateCaseMandatoryDetails(taskId);
        if(strResponse != 'Success'){
            return strResponse;
        }
        
        try{
            List<Task> lstTask = [
                SELECT Id, WhatId, MOUI_Success_Response__c FROM Task WHERE Id=:taskId
            ];
            
            System.debug('Related Task '+lstTask);
            
            if(!lstTask.isEmpty()){
                
                Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(new Set<Id>{lstTask[0].WhatId}); 
                System.debug('Related Case '+mapCases.values());
                if(!mapCases.isEmpty()){
                    Case relatedCase = mapCases.get(lstTask[0].WhatId);
                    
                    MOUIPojo pojoObj = MOUIIntegration.mouiRequestObject(relatedCase);
                    String jsonString = JSON.serialize(pojoObj,true); 
                    System.debug('Request JSON String = '+jsonString);
                    
                    Sys_Properties__c MOUIUser = Sys_Properties__c.getValues('MOUIUser');
                    Sys_Properties__c MOUIPassword = Sys_Properties__c.getValues('MOUIPassword');
                    Sys_Properties__c MOUIURL= Sys_Properties__c.getValues('MOUIURL');
                    String MOUIUserVar = MOUIUser.Value__c;
                    String MOUIURLVar =  MOUIURL.Value__c;
                    String MOUIPasswordVar = MOUIPassword.Value__c;
                    
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST'); 
                    req.setEndpoint(MOUIURLVar);
                    req.setHeader('Authorization', MOUIUserVar+':'+MOUIPasswordVar);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Content-Length', '1950');
                    req.setHeader('User-Agent', 'Fiddler');
                    req.setHeader('Host', 'www.edelbusiness.in');
                    req.setTimeout(120000);
                    req.setBody(jsonString);
                    
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    System.debug('Response Body '+res.getBody());
                    System.debug('Response Status Code '+res.getStatusCode());
                    
                    if(res.getStatusCode() == 401) {
                        strResponse = 'MOUI - '+'401 : Unauthorized: Access is denied due to invalid credentials.';
                    } else if(res.getStatusCode() == 500) {
                        strResponse = 'MOUI - '+'500 : Internal Server Error. Please try after some time.';
                    } else {
                        MOUIResponse objResponseDetails = MOUIResponse.parse(res.getBody()); 
                        
                        if(objResponseDetails.StatusCode == '200') {
                            if(objResponseDetails.StatusDesc == 'Success'){
                                lstTask[0].MOUI_Success_Response__c = true;
                                lstTask[0].Status = EdelweissConstants.TASK_COMPLETED_STATUS;
                                update lstTask;
                                strResponse = 'Case details updated successfully at MOUI';
                            } else {
                                strResponse = 'MOUI Error Response : ' + objResponseDetails.StatusDesc;
                            }
                            
                        } else if(objResponseDetails.StatusCode == '201') {
                            if(objResponseDetails.ErrorMsg == 'Duplicate record found.'){
                                strResponse = 'Case details are already updated at MOUI';
                                if(!lstTask[0].MOUI_Success_Response__c){
                                    lstTask[0].MOUI_Success_Response__c = true;
                                    lstTask[0].Status = EdelweissConstants.TASK_COMPLETED_STATUS;
                                    update lstTask;
                                }
                            } else {
                                strResponse = 'MOUI - '+objResponseDetails.ErrorMsg;
                            }
                            
                        } else if(objResponseDetails.Message == 'The request is invalid.') {
                            if(String.isNotEmpty(objResponseDetails.ModelState.salesforce_data_ErrorMessage)){
                                strResponse = objResponseDetails.ModelState.salesforce_data_ErrorMessage;
                            } else if(String.isNotEmpty(objResponseDetails.ModelState.salesforce_data)){
                                strResponse = 'MOUI : '+objResponseDetails.ModelState.salesforce_data;
                            }                            
                        }  
                    }
                }
            }
        } catch(Exception e){
            strResponse = e.getMessage();
            System.debug('Error Message : '+e.getMessage());
            System.debug('Stack Stress : '+e.getStackTraceString());
        }
		return strResponse;
}
    
        @AuraEnabled
    public static Boolean isIntroductoryMailSent(String taskId){
        System.debug('*********a'+taskId);
        Task taskObj = [SELECT Id, Subject, WhatId , Client_Introduction_Mail_Sent__c FROM Task WHERE Id=:taskId];
       
        return taskObj.Client_Introduction_Mail_Sent__c;
    }
    
    
    @AuraEnabled
    public static object getClientDetails(String taskId){
        case caseObj;
        Task taskObj = [SELECT Id, Subject, WhatId ,  Client_Introduction_Mail_Sent__c FROM Task WHERE Id=:taskId];
         if(taskObj != null){
                caseObj = [SELECT Id, Account.OwnerId, Account.Primary_Email__c , Email_Id__c , Account.Name , salutation__c FROM Case WHERE id =: taskObj.WhatId ];
       }
        return caseObj;
    }
    
    @AuraEnabled
    public static String sendIntroductionMail(String taskId , String Val){
        Map<ID, user> userList = EdelweissConstants.userList;
        list<Task> toBeUpdated = new list<Task>();Integer Flag = 0;
        User u;String templateName,fullTemplateName;
        FA_CSO_Mapping__c  mappingObj;
        List<String> toAddress = new List<String>();List<String> ccAddress = new List<String>();
        Id objectId;
        Task taskObj = [SELECT Id, Subject, WhatId , Client_Introduction_Mail_Sent__c FROM Task WHERE Id=:taskId];
        Case caseObj;
        if(taskObj.Client_Introduction_Mail_Sent__c){
            System.debug('Success Mail already sent');
           return 'Success Mail already sent';
        }
        if(val == 'No'){
           return 'Success Mail 1';
        }
        if(val == 'Yes' && taskObj.Client_Introduction_Mail_Sent__c != true){
            if(taskObj != null){
                caseObj = [SELECT Id, Account.OwnerId, Account.Primary_Email__c , Email_Id__c , Account.Name,Salutation__c FROM Case WHERE id =: taskObj.WhatId ];
            }
            if(caseObj != null){
                try{
                    mappingObj = [SELECT CSO_User__c , FA_User__c , IsActive__c FROM FA_CSO_Mapping__c WHERE FA_User__c =:caseObj.Account.OwnerId ];
                }Catch(Exception e){
                    return 'Error1';
                }
                
                if(mappingObj != null){
                    u = userList.get(mappingObj.CSO_User__c); 
					fullTemplateName = u.Name;
                    templateName =  u.Name;	
                    templateName = templateName.replace(' ', '_');
                    objectId =  mappingObj.CSO_User__c;
                    system.debug('objectId'+objectId);
                    toAddress.add(caseObj.Email_Id__c);
                    //ccAddress.add(u.Email);
                }else{
                    templateName = 'blank';
                    return 'Error';
                }
            }
             EmailTemplate templateA;OrgWideEmailAddress owa;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			try{
			 owa = [select id, Address from OrgWideEmailAddress where displayName =:fullTemplateName];
			}catch(Exception e){
				 return 'Error2';
			}
			if(owa == null){
				 return 'Error2';
			}
				
            if(templateName != 'blank'){
                try{
                templateA = [SELECT id , HtmlValue FROM EmailTemplate WHERE developerName =: templateName];

                }catch(Exception e){
                    system.debug('Inside catch');
                     return 'Error';
                }
                if(templateA == null){
                    return 'Error';
                }else{
                    String salutation,name;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    EmailTemplate em = new EmailTemplate(); 
                    em = templateA;
                    mail.setTemplateId(em.id);
                    //mail.setSaveAsActivity(false);
                     //mail.setTreatTargetObjectAsRecipient(false);
                    //mail.setTargetObjectId(objectId);
                    //mail.setSaveAsActivity(false);
					mail.setOrgWideEmailAddressId(owa.id);
                    String htmlValue = em.HtmlValue;
                    if(caseObj.Salutation__c == null){
                        salutation = '';
                    }else{
                        salutation = caseObj.Salutation__c;
                    }
                    name = salutation+caseObj.Account.Name;
                    String htmlValueModified = htmlValue.replace('[ACNAME]', name);
                    mail.htmlBody  = htmlValueModified;
                    mail.setToAddresses(toAddress);  
                    ccAddress.add(owa.Address);
                    mail.setCcAddresses(ccAddress);
                    System.debug('ccAddress'+ccAddress);
                    mail.setSubject('Welcome to Edelweiss Global Wealth Management!');
                    mail.setBccSender(false);
                    mails.add(mail);
                    taskObj.Client_Introduction_Mail_Sent__c = true;
                    Messaging.sendEmail(mails);
                    toBeUpdated.add(taskObj);
                    Flag = 1;
                }
            }
        }
        if(flag == 1){
            update(toBeUpdated);
            System.debug('toBeUpdated ****'+toBeUpdated);
            return 'Success Mail Sent';
        }
        return '';
    }
    
    @AuraEnabled
    public static String skipMOUI(String taskId){
        String strResponse = 'Something went wrong...';
        try{
            List<Task> lstTask = [
                SELECT Id, Subject, WhatId, MOUI_Success_Response__c FROM Task WHERE Id=:taskId
            ];
            if(!lstTask.isEmpty()){
                Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(new Set<Id>{lstTask[0].WhatId}); 
                if(!mapCases.isEmpty()){
                    Case relatedCase = mapCases.get(lstTask[0].WhatId);
                    relatedCase.Sub_Status__c = 'Closed-Success';
                    relatedCase.MOUI_Skipped__c = true;
                    update relatedCase;
                    
                    lstTask[0].MOUI_Success_Response__c = true;
                    lstTask[0].Status = EdelweissConstants.TASK_COMPLETED_STATUS;
                    update lstTask;
                    strResponse = 'TaskClosed';
                }
            } 
        } catch(Exception e){
            strResponse = e.getMessage();
            System.debug('Error Message : '+e.getMessage());
            System.debug('Stack Stress : '+e.getStackTraceString());
        }
        return strResponse;
    }
    
    @AuraEnabled
    public static String updateSubStatus(String taskId){
        
        String strResponse = 'Something went wrong...';
        try{
            List<Task> lstTask = [
                SELECT Id, Subject, WhatId, MOUI_Success_Response__c FROM Task WHERE Id=:taskId
            ];
            
            if(!lstTask.isEmpty()){
                Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(new Set<Id>{lstTask[0].WhatId}); 
                if(!mapCases.isEmpty()){
                    Case relatedCase = mapCases.get(lstTask[0].WhatId);
                    //relatedCase.Sub_Status__c = 'Closed-Success';
                    //update relatedCase;
                    
                    List<Task> lstTask2 = [SELECT Id, Status FROM Task WHERE WhatId=:relatedCase.Id AND Subject = 'MOUI Auto Closure' AND Status <> 'Completed'];
                    System.debug('Next Task k2 ::: '+lstTask2);
                    if(!lstTask2.isEmpty()){
                        for(Task t : lstTask2){
                            t.Status = 'Completed';
                            t.MOUI_Sub_Status_Received__c = true;
                        }
                        update lstTask2;
                    }
                    strResponse = 'MOUI request skipped successfully';
                }
            } 
        } catch(Exception e){
            strResponse = e.getMessage();
            System.debug('Error Message : '+e.getMessage());
            System.debug('Stack Stress : '+e.getStackTraceString());
        }
        return strResponse;
    }
    
    
    @AuraEnabled
    public static String validateCaseMandatoryDetails(String taskId){
        String strStatus = 'Success';
        Task t;
        
        List<Task> lstTask = [
            SELECT Id, WhatId, Status, Subject, MOUI_Success_Response__c FROM Task WHERE Id=:taskId AND RecordType.Name='Service Task'
        ];
        
        if(lstTask.isEmpty()){
            return 'Salesforce - Invalid task record';
        }else{
            t = lstTask[0];
            if(t.Status == EdelweissConstants.TASK_COMPLETED_STATUS || t.MOUI_Success_Response__c){
                return 'Salesforce - Case details are already updated at MOUI';
            } else if(t.Subject != EdelweissConstants.UPDATE_MANDATORY_DETAILS){
                return 'Salesforce - This action is only allowed for Update Mandatory Details task';
            }
        }
        
        Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(new Set<Id>{t.WhatId});        
        if(mapCases.isEmpty()){
            return 'Case record not found';
        }
        
        Map<Integer, String> message = EdelweissUtils.checkDependency(t.Subject, mapCases.get(t.WhatId));
        if(message.get(1) != null){
            return message.get(1);
        }
                
        return strStatus;
    }
    
    @AuraEnabled
    public static String validateDetailsForSkipMOUI(String taskId){
        String strStatus = 'Success';
        Task t;
        
        List<Task> lstTask = [
            SELECT Id, WhatId, Status, Subject, MOUI_Success_Response__c FROM Task WHERE Id=:taskId AND RecordType.Name='Service Task'
        ];
        
        if(lstTask.isEmpty()){
            return 'Salesforce - Invalid task record';
        }else{
            t = lstTask[0];
            if(t.Status == EdelweissConstants.TASK_COMPLETED_STATUS || t.MOUI_Success_Response__c){
                return 'Salesforce - Case details are already skiped for MOUI';
            } else if(t.Subject != EdelweissConstants.UPDATE_MANDATORY_DETAILS){
                return 'Salesforce - This action is only allowed for Update Mandatory Details task';
            }
        }
        
        Map<Id, Case> mapCases = TaskManagementTriggerHandler.getCaseDetails(new Set<Id>{t.WhatId});        
        if(mapCases.isEmpty()){
            return 'Case record not found';
        }
        
        Map<Integer, String> message = EdelweissUtils.checkDependency(t.Subject, mapCases.get(t.WhatId));
        if(message.get(1) != null){
            return message.get(1);
        }
                
        return strStatus;
    }
    
    private static MOUIPojo mouiRequestObject(Case c){
        MOUIPojo pojoObj =  new MOUIPojo();
        pojoObj.CLIENT_NAME = c.Account.Name;
        if(c.Entity_Type__c == 'Company') pojoObj.ENTITY_TYPE=1;
        if(c.Entity_Type__c == 'LLP') pojoObj.ENTITY_TYPE=2;
        if(c.Entity_Type__c == 'Trust') pojoObj.ENTITY_TYPE=3;
        if(c.Entity_Type__c == 'AOP') pojoObj.ENTITY_TYPE=4;
        if(c.Entity_Type__c == 'HUF') pojoObj.ENTITY_TYPE=5;
        if(c.Entity_Type__c == 'Society') pojoObj.ENTITY_TYPE=6;
        if(c.Entity_Type__c == 'Individual') pojoObj.ENTITY_TYPE=7;
        if(c.Entity_Type__c == 'Partnership') pojoObj.ENTITY_TYPE=8;
        
        if((c.Product_Type__c).contains('Trading')) pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE + '1'+',';
        if((c.Product_Type__c).contains('Demat')) pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE + '2'+',';
        if((c.Product_Type__c).contains('POA')) pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE + '3'+',';
        if((c.Product_Type__c).contains('Miles')) pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE + '4'+',';
        if((c.Product_Type__c).contains('Advisory')) pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE + '5'+',';
        system.debug('Product_Type__c '+c.Product_Type__c);
        pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE.remove('null');
        pojoObj.PRODUCT_TYPE = pojoObj.PRODUCT_TYPE.removeEnd(',');
        pojoObj.CONTACT_NUMBER= c.Phone__c;
        pojoObj.EMAIL_ID= c.Email_Id__c;
        pojoObj.PAN_NUMBER= c.PAN_Number__c;
        //pojoObj.AADHAR_NUMBER= c.Aadhar_number__c;
        if(c.DOB_DOI__c == null){
            pojoObj.DOB_DOI = date.newInstance(1900, 01, 01);
        }else{
            date myDate = date.newInstance(c.DOB_DOI__c.year(), c.DOB_DOI__c.month(), c.DOB_DOI__c.day());
            pojoObj.DOB_DOI = myDate;
        }
        if(c.CIN_Number__c != null) pojoObj.CIN_NUMBER = string.valueOf(c.CIN_Number__c);
        
        //Send NONE for String Type and 0.0 for Numeric type
        if(!((c.Product_Type__c).contains('Trading'))){
            pojoObj.DELIVERY_SLAB_CASH = 0.0;
            pojoObj.DELIVERY_SLAB_CASH_SIDES = 'NONE';
            pojoObj.DELIVERY_CASH_MIN = 0.0;
            
            pojoObj.INTRADAY_SLAB_CASH = 0.0;
            pojoObj.INTRADAY_SLAB_CASH_SIDES = 'NONE';
            pojoObj.INTRADAY_CASH_MIN = 0.0;
            
            pojoObj.CURRENCY_FUTURES_SLAB = 0.0;
            pojoObj.CURRENY_FUTURES_MIN = 0.0;
            pojoObj.CURRENCY_FUTURES_SIDES = 'NONE';
            
            pojoObj.CURRENY_OPTIONS_SLAB = 0.0;
            pojoObj.CURRENCY_OPTIONS_MIN = 0.0;
            pojoObj.CURRENCY_OPTIONS_SIDES = 'NONE';
            
            pojoObj.DERIVATIVES_FUTURES_SLAB = 0.0;
            pojoObj.DERIVATIVES_FUTURES_MIN = 0.0;
            pojoObj.DERIVATIVES_FUTURES_SIDES = 'NONE';
            
            pojoObj.DERIVATIVES_OPTIONS_SLAB = 0.0;
            pojoObj.DERIVATIVES_OPTIONS_MIN = 0.0;
            pojoObj.DERIVATIVES_OPTIONS_SIDES = 'NONE';
        }
        else{
            pojoObj.DELIVERY_SLAB_CASH = c.Delivery_Slab__c;
            pojoObj.DELIVERY_SLAB_CASH_SIDES = c.Delivery_Sides__c;
            pojoObj.DELIVERY_CASH_MIN = c.Delivery_Minimum_P__c;
            
            
            pojoObj.INTRADAY_SLAB_CASH = c.Intraday_Slab__c;
            pojoObj.INTRADAY_SLAB_CASH_SIDES = c.Intraday_Sides__c;
            pojoObj.INTRADAY_CASH_MIN = c.Intraday_Minimum_P__c;
            
            pojoObj.CURRENCY_FUTURES_SLAB = c.Currency_Futures_Slab__c;
            pojoObj.CURRENY_FUTURES_MIN = c.Currency_Futures_Minimum_P__c;
            pojoObj.CURRENCY_FUTURES_SIDES = c.Currency_Futures_Sides__c;
            
            pojoObj.CURRENY_OPTIONS_SLAB = c.Currency_Options_Slab__c;
            pojoObj.CURRENCY_OPTIONS_MIN = c.Currency_Options_Minimum_P__c;
            pojoObj.CURRENCY_OPTIONS_SIDES = c.Currency_Options_Sides__c;
            
            pojoObj.DERIVATIVES_FUTURES_SLAB = c.Derivatives_Futures_Slab__c;
            pojoObj.DERIVATIVES_FUTURES_MIN = c.Currency_Futures_Minimum_P__c;
            pojoObj.DERIVATIVES_FUTURES_SIDES = c.Derivatives_Futures_Sides__c;
            
            pojoObj.DERIVATIVES_OPTIONS_SLAB = c.Derivatives_Options_Slab__c;
            pojoObj.DERIVATIVES_OPTIONS_MIN = c.Derivatives_Options_Minimum_P__c;
            pojoObj.DERIVATIVES_OPTIONS_SIDES = c.Derivatives_Options_Sides__c;
        } 
        if(String.isNotEmpty(c.Product_Type__c) && c.Product_Type__c.contains('Demat')){
            
            pojoObj.JOINT_ACCT_HOLDER1_NAME = c.Joint_Holder_Client1_Name__c;
            pojoObj.JOINT_ACCT_HOLDER1_CONTACT = c.Joint_Holder_Client1_Contact_Number__c;
            pojoObj.JOINT_ACCT_HOLDER1_EMAIL = c.Joint_Holder_Client1_Email_ID__c;
            pojoObj.JOINT_ACCT_HOLDER1_PAN = c.Joint_Holder_Client1_PAN_Number__c;
           // pojoObj.JOINT_ACCT_HOLDER1_AADHAR = c.Joint_Holder_Client1_Aadhar_Number__c;
            if(c.Joint_Holder_Client1_DOB_DOI__c != null){
                date JOINT_ACCT_HOLDER1_DOB_DOI = date.newInstance(c.Joint_Holder_Client1_DOB_DOI__c.year(), c.Joint_Holder_Client1_DOB_DOI__c.month(), c.Joint_Holder_Client1_DOB_DOI__c.day());
                pojoObj.JOINT_ACCT_HOLDER1_DOB_DOI = JOINT_ACCT_HOLDER1_DOB_DOI;
            }
            
            if(c.Number_of_Joint_Holders_Max_2__c == '2'){
                pojoObj.JOINT_ACCT_HOLDER2_NAME = c.Joint_Holder_Client2_Name__c;
                pojoObj.JOINT_ACCT_HOLDER2_CONTACT = c.Joint_Holder_Client2_Contact_Number__c;
                pojoObj.JOINT_ACCT_HOLDER2_EMAIL = c.Joint_Holder_Client2_Email_ID__c;
                pojoObj.JOINT_ACCT_HOLDER2_PAN = c.Joint_Holder_Client2_PAN_Number__c;
               // pojoObj.JOINT_ACCT_HOLDER2_AADHAR = c.Joint_Holder_Client2_Aadhar_Number__c;
                if(c.Joint_Holder_Client2_DOB_DOI__c != null){
                    date JOINT_ACCT_HOLDER2_DOB_DOI = date.newInstance(c.Joint_Holder_Client2_DOB_DOI__c.year(), c.Joint_Holder_Client2_DOB_DOI__c.month(), c.Joint_Holder_Client2_DOB_DOI__c.day());
                    pojoObj.JOINT_ACCT_HOLDER2_DOB_DOI = JOINT_ACCT_HOLDER2_DOB_DOI;
                }
            }
        }
        pojoObj.SYSTEM_ID = 'SALES_FORCE';
        pojoObj.SALES_RM_NAME = c.Current_FA__c;
        pojoObj.CASE_NO = c.CaseNumber;
        pojoObj.CRM_CLIENT_CODE = '0000';
        pojoObj.ADDRESS_1 = c.Address__c;
        pojoObj.ADDRESS_2 = c.Address_Line_1__c;
        pojoObj.ADDRESS_3 = c.Address_Line_2__c;
        pojoObj.CITY = c.City__c;
        pojoObj.COUNTRY_CODE = '123';
        pojoObj.STATE_CODE = '123';
        //pojoObj.COUNTRY = c.Country__c;
        //pojoObj.STATE = c.State__c;
        pojoObj.COUNTRY_NAME = 'INDIA';
        pojoObj.STATE_NAME = 'Maharashtra';
        pojoObj.PINCODE = '123456';
        //pojoObj.REG_NUMBER = '123459';
        system.debug('c.PinCode__c '+c.PinCode__c);
        //pojoObj.PINCODE = string.valueOf(c.PinCode__c);
        if(c.Single_Joint__c == null || c.Single_Joint__c == ''){
            pojoObj.SINGLE_JOINT_HOLDER = 'NONE';
        }else{
            pojoObj.SINGLE_JOINT_HOLDER = c.Single_Joint__c;
        }
        System.debug('c.Account'+c.Account);
        System.debug('c.Account.OwnerId'+c.Account.OwnerId);
        if(Account.OwnerId != null){
            User u = [SELECT Miles_Id__c , Name FROM user WHERE id=:c.Account.OwnerId LIMIT 1];
            if(u.Miles_Id__c != null){
                pojoObj.SALES_RM_CODE = Integer.valueOf(u.Miles_Id__c);
            }
            if(u.Name != null){
                pojoObj.SALES_RM_NAME = u.Name;
                pojoObj.ACCOUNT_NAME = 'POA';
            }
        }
        if(c.IsNewFamily__c){
            pojoObj.FAMILY_NAME = c.Family__c;
            pojoObj.FAMILY_HEAD_ID=c.MainLead__c;
            pojoObj.FAMILY_HEAD_NAME = c.MainLead__r.Name;
            pojoObj.FAMILY_HEAD_PAN = c.MainLead__r.Pan_Number__c;
            setRiskProfilerValues(c,pojoObj);
        }
        else if(c.IsNewClient__c){
            Account a = [select Name,Parent.name,Parent.GWM_Online_Id__c,Parent.Family_Head_Name__r.Name,Parent.Family_Head_Name__r.Pan_Number__c from account where id=:c.AccountId];
            Account family = [select Name,GWM_Online_Id__c,Family_Head_Name__c,Family_Head_Name__r.Name,Family_Head_Name__r.Pan_Number__c from account where id=:c.MainLead__c];
            if(family!= null){
                pojoObj.FAMILY_NAME = family.Name; 
                pojoObj.FAMILY_CODE = String.isEmpty(family.GWM_Online_Id__c) ? 0000 : Integer.valueOf(family.GWM_Online_Id__c);
                pojoObj.FAMILY_HEAD_ID = family.Family_Head_Name__c;
                pojoObj.FAMILY_HEAD_NAME = family.Family_Head_Name__r.Name;
                pojoObj.FAMILY_HEAD_PAN = family.Family_Head_Name__r.Pan_Number__c;
            }
            setRiskProfilerValues(c,pojoObj);
            
            
        }
        else if(!c.IsNewFamily__c && !c.IsNewClient__c){
            Account a = [SELECT Parent.name, Parent.GWM_Online_Id__c, GWM_Online_Id__c,Parent.Family_Head_Name__c,Parent.Family_Head_Name__r.Name,Parent.Family_Head_Name__r.Pan_Number__c from Account where id=:c.AccountId ];
            if(a.Parent.name != null){
                pojoObj.FAMILY_NAME = a.Parent.name;
                pojoObj.FAMILY_CODE = Integer.valueOf(a.Parent.GWM_Online_Id__c);
                pojoObj.FAMILY_HEAD_ID = a.Parent.Family_Head_Name__c;
                pojoObj.FAMILY_HEAD_NAME = a.Parent.Family_Head_Name__r.Name;
                pojoObj.FAMILY_HEAD_PAN = a.Parent.Family_Head_Name__r.Pan_Number__c;
            }
            if(String.isNotBlank(a.GWM_Online_Id__c)){
                pojoObj.CRM_CLIENT_CODE = a.GWM_Online_Id__c;
                
            }
        }
        if(String.isNotBlank(c.Family__c)){
            pojoObj.FAMILY_NAME = c.Family__c;
        }
        return pojoObj;
    }
    
    
    public static void setRiskProfilerValues(Case caseObj,MOUIPojo pojoObj){
        
       Task tObj = [SELECT MOUI_Success_Response__c FROM Task WHERE Subject='Update Mandatory Details' AND WhatId =:caseObj.id];
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
        System.debug('****Inside1');
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
        
        
        Map<String, String> worst_and_best_one_year_return_Non_Ind = new Map<String, String>();
        fieldResult = case.worst_and_best_one_year_return_Non_Ind_1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            worst_and_best_one_year_return_Non_Ind.put(f.getLabel(), f.getValue());
        }  		
        
        Map<String, String> Amount_of_fluctuations = new Map<String, String>();
        fieldResult = case.Amount_of_fluctuations1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Amount_of_fluctuations.put(f.getLabel(), f.getValue());
        }  			
        
        Map<String, String> Amount_of_fluctuations_Non_Ind = new Map<String, String>();
        fieldResult = case.Amount_of_fluctuations_Non_Ind_1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Amount_of_fluctuations_Non_Ind.put(f.getLabel(), f.getValue());
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
        
        Map<String, String> Interest_in_leverage_borrowing_products_Non_Ind = new Map<String, String>();
        fieldResult = case.Interest_leverage_products_Non_Ind1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Interest_in_leverage_borrowing_products_Non_Ind.put(f.getLabel(), f.getValue());
        }  
        
        Map<String, String> Alternative_Investments = new Map<String, String>();
        fieldResult = case.Alternative_Investments1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Alternative_Investments.put(f.getLabel(), f.getValue());
        }  	
        
        Map<String, String> Alternative_Investments_Non_Ind = new Map<String, String>();
        fieldResult = case.Alternative_Investments_Non_Ind1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Alternative_Investments_Non_Ind.put(f.getLabel(), f.getValue());
        }  
        
        Map<String, String> Investment_portfolio = new Map<String, String>();
        fieldResult = case.Investment_portfolio1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Investment_portfolio.put(f.getLabel(), f.getValue());
        }  	
        Map<String, String> Investment_Style = new Map<String, String>();
        fieldResult = case.Investment_Style1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Investment_Style.put(f.getLabel(), f.getValue());
        }  	
        
         Map<String, String> time_line_For_Trading = new Map<String, String>();
        fieldResult = case.Time_line_for_Trading1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            time_line_For_Trading.put(f.getLabel(), f.getValue());
        }  
        
        Map<String, String> risk_Profile_Categories = new Map<String, String>();
        fieldResult = case.Risk_Profile_Categories1__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            risk_Profile_Categories.put(f.getLabel(), f.getValue());
        }  
        
        
        
        List<RiskProfilePojo> listOfRiskProfile = new List<RiskProfilePojo>();
         	Date deployDate = Date.newInstance(2019, 1, 19);
             Date createdDateOnly = Date.newInstance(caseObj.CreatedDate.year(), caseObj.CreatedDate.month(), caseObj.CreatedDate.day());
		if(deployDate <= createdDateOnly){
        if(caseObj.IsNewClient__c || caseObj.IsNewFamily__c){
            if(caseObj.isCorporate__c == true){
                if(caseObj.Equity_Markets__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_EQUITY_MARKETS'; 
                    rObj.ANSWER_ID = Equity_Markets.get(caseObj.Equity_Markets__c);
                    listOfRiskProfile.add(rObj);
                }
                
                if(caseObj.Investment_philosophy__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_PHILOSOPHY'; 
                    rObj.ANSWER_ID = Investment_philosophy.get(caseObj.Investment_philosophy__c);
                    listOfRiskProfile.add(rObj); 
                }
                if(caseObj.Investment_goal__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_GOAL'; 
                    rObj.ANSWER_ID = Investment_goal.get(caseObj.Investment_goal__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Financial_Goals__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_FINANCIAL_GOALS'; 
                    rObj.ANSWER_ID = Financial_Goals.get(caseObj.Financial_Goals__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.worst_and_best_one_year_return_Non_Ind__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_WORST_AND_BEST_ONE_YEAR_RETURN'; 
                    rObj.ANSWER_ID = worst_and_best_one_year_return_Non_Ind.get(caseObj.worst_and_best_one_year_return_Non_Ind__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                
                if(caseObj.Amount_of_fluctuations_Non_Ind__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_AMOUNT_OF_FLUCTUATIONS'; 
                    rObj.ANSWER_ID = Amount_of_fluctuations_Non_Ind.get(caseObj.Amount_of_fluctuations_Non_Ind__c);
                    listOfRiskProfile.add(rObj); 
                }
                if(caseObj.Diversified_portfolio__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_DIVERSIFIED_PORTFOLIO'; 
                    rObj.ANSWER_ID = Diversified_portfolio.get(caseObj.Diversified_portfolio__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Interest_leverage_products_Non_Ind__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INTEREST_IN_LEVERAGE_BORROWING_PRODUCTS'; 
                    rObj.ANSWER_ID = Interest_in_leverage_borrowing_products_Non_Ind.get(caseObj.Interest_leverage_products_Non_Ind__c);
                    listOfRiskProfile.add(rObj); 
                    
                }  
                
                
                if(caseObj.Alternative_Investments_Non_Ind__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_ALTERNATIVE_INVESTMENTS'; 
                    rObj.ANSWER_ID = Alternative_Investments_Non_Ind.get(caseObj.Alternative_Investments_Non_Ind__c);
                    listOfRiskProfile.add(rObj); 
                }
                if(caseObj.Investment_portfolio__c != null){
                    //  pojoObj.Q_INVESTMENT_PORTFOLIO=Integer.valueOf(Investment_portfolio.get(caseObj.Investment_portfolio__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_PORTFOLIO'; 
                    rObj.ANSWER_ID = Investment_portfolio.get(caseObj.Investment_portfolio__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Risk_Profile_Categories__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_RISK_PROFILE_CATEGORIES'; 
                    rObj.ANSWER_ID = risk_Profile_Categories.get(caseObj.Risk_Profile_Categories__c);
                    listOfRiskProfile.add(rObj); 
                }   
                
                
                
                
            }else{ // Individual
                
                if(caseObj.Age_RiskProfile__c != null){
                    system.debug('************ Inside 3');
                    system.debug('************ Inside 3');
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_AGE'; 
                    rObj.ANSWER_ID = age.get(caseObj.Age_RiskProfile__c);
                    listOfRiskProfile.add(rObj); 
                    
                }
                if(caseObj.Investment_philosophy__c != null){
                    //pojoObj.Q_INVESTMENT_PHILOSOPHY= Integer.valueOf(Investment_philosophy.get(caseObj.Investment_philosophy__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_PHILOSOPHY'; 
                    rObj.ANSWER_ID = Investment_philosophy.get(caseObj.Investment_philosophy__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Investment_goal__c != null){
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_GOAL'; 
                    rObj.ANSWER_ID = Investment_goal.get(caseObj.Investment_goal__c);
                    listOfRiskProfile.add(rObj); 
                }
                if(caseObj.Financial_Goals__c != null){
                    // pojoObj.Q_FINANCIAL_GOALS=Integer.valueOf(Financial_Goals.get(caseObj.Financial_Goals__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_FINANCIAL_GOALS'; 
                    rObj.ANSWER_ID = Financial_Goals.get(caseObj.Financial_Goals__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                
                
                
                
                if(caseObj.worst_and_best_one_year_return__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_WORST_AND_BEST_ONE_YEAR_RETURN'; 
                    rObj.ANSWER_ID = worst_and_best_one_year_return.get(caseObj.worst_and_best_one_year_return__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Amount_of_fluctuations__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_AMOUNT_OF_FLUCTUATIONS'; 
                    rObj.ANSWER_ID = Amount_of_fluctuations.get(caseObj.Amount_of_fluctuations__c);
                    listOfRiskProfile.add(rObj); 
                }
                if(caseObj.Diversified_portfolio__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_DIVERSIFIED_PORTFOLIO'; 
                    rObj.ANSWER_ID = Diversified_portfolio.get(caseObj.Diversified_portfolio__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                
                
                if(caseObj.Interest_in_leverage_borrowing_products__c != null){
                    // pojoObj.Q_INTEREST_IN_LEVERAGE_BORROWING_PRODUCTS=Integer.valueOf(Interest_in_leverage_borrowing_products.get(caseObj.Interest_in_leverage_borrowing_products__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INTEREST_IN_LEVERAGE_BORROWING_PRODUCTS'; 
                    rObj.ANSWER_ID = Interest_in_leverage_borrowing_products.get(caseObj.Interest_in_leverage_borrowing_products__c);
                    listOfRiskProfile.add(rObj); 
                    
                }
                
                
                if(caseObj.Alternative_Investments__c != null){
                    //  pojoObj.Q_ALTERNATIVE_INVESTMENTS=Integer.valueOf(Alternative_Investments.get(caseObj.Alternative_Investments__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_ALTERNATIVE_INVESTMENTS'; 
                    rObj.ANSWER_ID = Alternative_Investments.get(caseObj.Alternative_Investments__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Investment_portfolio__c != null){
                    //  pojoObj.Q_INVESTMENT_PORTFOLIO=Integer.valueOf(Investment_portfolio.get(caseObj.Investment_portfolio__c));
                    
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_PORTFOLIO'; 
                    rObj.ANSWER_ID = Investment_portfolio.get(caseObj.Investment_portfolio__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                if(caseObj.Investment_Style__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_INVESTMENT_STYLE'; 
                    rObj.ANSWER_ID = Investment_Style.get(caseObj.Investment_Style__c);
                    listOfRiskProfile.add(rObj); 
                }   
                
                if(caseObj.Time_line_for_Trading__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_TIME_LINE_FOR_TRADING'; 
                    rObj.ANSWER_ID = time_line_For_Trading.get(caseObj.Time_line_for_Trading__c);
                    listOfRiskProfile.add(rObj); 
                }
                
                
                
                if(caseObj.Risk_Profile_Categories__c != null){
                    RiskProfilePojo rObj = new RiskProfilePojo();
                    rObj.QUESTION_ID = 'Q_RISK_PROFILE_CATEGORIES'; 
                    rObj.ANSWER_ID = risk_Profile_Categories.get(caseObj.Risk_Profile_Categories__c);
                    listOfRiskProfile.add(rObj); 
                }   
                
            }
            
            if(!listOfRiskProfile.isEmpty()){
                 pojoObj.List_Risk_Profile = listOfRiskProfile; 
            }
           
            
        } // If new Fam
    }//Date Logic
    }
    
}