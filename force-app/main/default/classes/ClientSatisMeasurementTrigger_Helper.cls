////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 14 JAN 2016
//Description: Class is used for logging errors occurred during any process involved in integration.
//
//@ 2016 Persistent System Ltd.
////////////////////////////////////

public class ClientSatisMeasurementTrigger_Helper
{
       public static Boolean flag = true;

    public static void updateNPSValue(List<Client_Satisfaction_Measurement__c> listNewCreatedMeasurementRec)
    {
        for(Client_Satisfaction_Measurement__c objSatiMeasure: listNewCreatedMeasurementRec)
        {
            system.debug('objSatiMeasure.Client_Recommendation_on_scale_of__c>>'+objSatiMeasure.Client_Recommendation_on_scale_of__c);
            if(objSatiMeasure.Client_Recommendation_on_scale_of__c == 'No Rating')
            {
                  objSatiMeasure.NPS_Of_Client__c ='Passive';
                //objSatiMeasure.Customer_Sentiment__c='Positive';
            }
            Else if(Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) >=0 && Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) <=6)
            {    
                objSatiMeasure.NPS_Of_Client__c ='Detractor';
                //objSatiMeasure.Customer_Sentiment__c='Negative';
            }
            Else if(Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) >6 && Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) <=8)
            {
                objSatiMeasure.NPS_Of_Client__c ='Passive';
                //objSatiMeasure.Customer_Sentiment__c='Positive';
            }
            else if(Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) > 8 && Integer.ValueOf(objSatiMeasure.Client_Recommendation_on_scale_of__c) <=10)
            {
                objSatiMeasure.NPS_Of_Client__c ='Promoter';
                //objSatiMeasure.Customer_Sentiment__c='Positive';
            }
            system.debug('objSatiMeasure >>'+objSatiMeasure);
        }
    }
     public static void createCaseOnClientSatisfaction(List<Client_Satisfaction_Measurement__c> listNPS){
        List<Id> lstAccIds=  new List<Id>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {
            if((objNPS.NPS_Of_Client__c == 'Detractor' || objNPS.Customer_Sentiment__c == 'Negative') || (objNPS.Customer_Sentiment__c == 'Positive' && objNPS.Close_Looping_to_be_Done_by__c != Null) || (objNPS.Customer_Sentiment__c == 'Neutral' && objNPS.Close_Looping_to_be_Done_by__c != Null))
            {
                lstAccIds.add(objNPS.Client_Name__c);
                System.debug('Account ID'+lstAccIds);
            }
        }
        System.debug('createCaseOnClientSatisfaction :: Account ID'+lstAccIds);
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if(lstAccIds != null && lstAccIds.size() > 0){
            accountMap = New Map<Id,Account>([Select Id,Primary_Email__c, Primary_FA__c,Primary_CXO__c,Primary_FA__r.Business_Head__c,Parent.Coverage__c,ParentId From Account Where Id In : lstAccIds]);
        }
        List<Case> lstCase = new List<Case>();
        List<Case> lstgetCase = new List<Case>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {
            if((objNPS.NPS_Of_Client__c == 'Detractor'  || objNPS.Customer_Sentiment__c == 'Negative') || (objNPS.Customer_Sentiment__c == 'Positive' && objNPS.Close_Looping_to_be_Done_by__c != Null)|| (objNPS.Customer_Sentiment__c == 'Neutral' && objNPS.Close_Looping_to_be_Done_by__c != Null))
            {
                Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
                List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
                Map<String,Id> mapofCaseRecordTypeNameandId = new Map<String,Id>();
                for(Schema.RecordTypeInfo info : recordTypeInfo)
                {
                    mapofCaseRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
                }
                    Case newCase =new Case();
                    newCase.RecordTypeId = mapofCaseRecordTypeNameandId.get(EdelweissConstants.SERVICE_REQUEST);
                    newCase.AccountId = objNPS.Client_Name__c;
                	Account acc = accountMap.get(objNPS.Client_Name__c);
                	newCase.Client_Email__c = acc.Primary_Email__c;
                newCase.Service_Request_Product_Type__c  = 'Client engagement';
                newCase.Service_Request_Type__c = 'NPS'; 
                    newCase.Type = 'NPS';
                    newCase.LOB__c= 'GWM';
                    newCase.Contacted_By__c='Others';
                //newCase.Nature__c = 'Complaint';
                /*if(objNPS.NPS_Of_Client__c != 'Detractor'  && objNPS.Customer_Sentiment__c == 'Negative'){  
                             newCase.Nature__c = 'Request';
}*/
                newCase.Nature__c = objNPS.Nature__c;
                    newCase.Origin = 'Telephone';
                   /* string strDesc = objNPS.Reason_for_the_rating__c +'\n'+ objNPS.Remarks_Motivation_to_select_Edelweiss__c +'\n'+ objNPS.Remarks_FA_spent_time_to_understand__c +'\n'+ objNPS.Remarks_Logged_into_reporting_platform__c+'\n'+objNPS.Remarks_Is_your_FA_in_touch_with_you__c +'\n'+ objNPS.Remarks_FA_Connect__c +'\n'+ objNPS.Remarks_Connection_Frequency__c +'\n'+ objNPS.Remarks_Does_FA_Spend_Adequate_time__c +'\n'+ objNPS.Remarks_Are_you_satisfied_wt_timeframe__c +'\n'+ objNPS.Remarks_Portfolio_Frequency__c +'\n'+ objNPS.Remarks_Medium_used_Queries_requests__c +'\n'+ objNPS.Remarks_Queries_requests_resolved__c +'\n'+objNPS.Suggestion_to_improve_overall_rating__c;
                    strDesc = strDesc.replace('null','');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');
                    strDesc = strDesc.replace('\n\n','\n');*/
                    //BUG-00210
                    string strDesc = system.Label.NPS_Description;
                	//BUG-00223
                    newCase.Description = objNPS.NPS_Synopsis__c;
                    newCase.Client_Recommendation_on_scale_of_0_1__c = objNPS.Client_Recommendation_on_scale_of__c;
                    newCase.Client_Satisfaction_Measurement_NPS__c = objNPS.Id;
                    
                    if(objNPS.Close_Looping_to_be_Done_by__c == 'CXO')
                        newCase.Owner_Change_Reason__c = 'CXO';
                    else 
                        newCase.Owner_Change_Reason__c = 'FA';
                        
                    /*if(accountMap.get(objNPS.Client_Name__c) != null && accountMap.get(objNPS.Client_Name__c).Primary_FA__c != null)
                    {
                    //System.debug('accountMap.get(objNPS.Client_Name__c).Primary_FA__c'+accountMap.get(objNPS.Client_Name__c).Primary_FA__c);
                    newCase.OwnerId = accountMap.get(objNPS.Client_Name__c).Primary_FA__c;
                    newCase.Owner_Change_Reason__c = 'NPS detracter case assign to FA';
                        SYstem.debug('accountMap.get(objNPS.Client_Name__c).Primary_FA__c'+accountMap.get(objNPS.Client_Name__c).Primary_FA__c);
                    }*/
                    lstCase.add(newCase);
                System.debug('Case New Value ::::'+lstCase);
            }
        }
        List<CaseShare> lstshare = new List<CaseShare>();
        List<Client_Satisfaction_Measurement__c>  NPSList = new List<Client_Satisfaction_Measurement__c>();
         if(lstCase.size() > 0)
         {
           database.upsert(lstCase);
           for(Client_Satisfaction_Measurement__c objNPS: listNPS){  
               for(Case c : lstCase){
                   if(objNPS.Id == c.Client_Satisfaction_Measurement_NPS__c){
                       Client_Satisfaction_Measurement__c NPSRec = new Client_Satisfaction_Measurement__c();
                       NPSRec.Case__c = c.Id;
                       NPSRec.Id = objNPS.Id;
                       //updatePrimaryFaForAllRecords method created
                       /*if(accountMap.get(objNPS.Client_Name__c) != null)
                        NPSRec.Primary_FA__c = accountMap.get(objNPS.Client_Name__c).Primary_FA__c;*/
                       NPSList.add(NPSRec);
                   }
               }  
            }       
             if(NPSList.size() > 0) {
                 update(NPSList);
             }
           List<Case> updateCase = new List<Case>();
           List<Id> caseId = new List<Id>();
           for(Case caseObj :  lstCase){
                if(accountMap.get(caseObj.AccountId) != null)
                {
                    if(caseObj.Owner_Change_Reason__c != null && caseObj.Owner_Change_Reason__c.containsIgnoreCase('FA') &&accountMap.get(caseObj.AccountId).Primary_FA__c != null){
                        caseObj.OwnerId = accountMap.get(caseObj.AccountId).Primary_FA__c;
                        caseObj.Owner_Change_Reason__c = 'NPS detracter case assign to FA';
                    }else if(caseObj.Owner_Change_Reason__c != null && caseObj.Owner_Change_Reason__c.containsIgnoreCase('CXO') && accountMap.get(caseObj.AccountId).Primary_CXO__c != null){
                        caseObj.OwnerId = accountMap.get(caseObj.AccountId).Primary_CXO__c;
                        caseObj.Owner_Change_Reason__c = 'NPS detracter case assign to CXO';
                        if(accountMap.get(caseObj.AccountId).Primary_FA__c != null){
                            CaseShare caseShr  = new CaseShare();
                            caseShr.CaseId = caseObj.Id;
                            caseShr.UserOrGroupId = accountMap.get(caseObj.AccountId).Primary_FA__c;
                            caseShr.CaseAccessLevel = 'Read';
                            lstshare.add(caseShr);
                        }                       
                    } 
                    //caseObj.Due_Date_Time__c= System.now(); //Changes By Prateek
                    updateCase.add(caseObj);
                }
                caseId.add(caseObj.Id);
           }
            if(updateCase.size() > 0){
                database.update(updateCase);
                if(lstshare != null && lstshare.size() > 0)
                    database.insert(lstshare,false);
                System.debug('caseId @@:'+caseId);
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                List<Case> EmailSendCases = [
                	SELECT Id, Status, createdById, OwnerId, Owner.Email, CaseNumber, Type, Previous_FA__c,
                		Account.Name,Due_Date_Time__c,Case_Type__c,Priority,Description,Owner.Name,
                		Client_Satisfaction_Measurement_NPS__r.Name,Client_Satisfaction_Measurement_NPS__c,
                    Client_Satisfaction_Measurement_NPS__r.NPS_Of_Client__c,Client_Satisfaction_Measurement_NPS__r.Customer_Sentiment__c,Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c
            		FROM Case WHERE Id =:caseId
                ];
                Map<Id,User> userMAP = new Map<Id,User>([SELECT Id, isActive , profile.Name , Name, Email, ManagerId, Manager.Email,Manager.Profile.Name, UserRoleId, Business_Head__c,Regional_Head__c, UserRole.Name, Business_Head__r.Email,Regional_Head__r.Email FROM User]);
                List<String> listOfNSMEmail = new  List<String>();
                for(User u : userMAP.values()){
                    if(u.Profile.Name.contains('CXO National Head') && u.IsActive == true){
						listOfNSMEmail.add(u.Email);				                        
                    }
                }
                System.debug('EmailSendCases :'+EmailSendCases);
                for(case c : EmailSendCases){
                    integer flag = 0; 
                    account caseAcc = accountMap.get(c.AccountId);
                    user userDetail = userMAP.get(c.OwnerId);                   
                    user FAUser;
                    user CXOUser;
                    if(caseAcc.Primary_FA__c != null && caseAcc.Primary_CXO__c != null){
                    	List<String> lstToEmails = new List<String>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.subject = 'New NPS Case '+c.CaseNumber+' created';
                        
                        FAUser = userMAP.get(caseAcc.Primary_FA__c);
                        CXOUser = userMAP.get(caseAcc.Primary_CXO__c);                     
                        lstToEmails.add(FAUser.Email);
                        lstToEmails.add(CXOUser.Email);        
                        if(caseAcc.Parent.Coverage__c != 'R5' && c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c != Null && c.Client_Satisfaction_Measurement_NPS__r.Customer_Sentiment__c != 'Negative'){
                            //user loopingDoneBy = userMAP.get(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c );
                            if(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c.contains('FA')) {  //// Doubt
                        	if(String.isNotEmpty(FAUser.Manager.Email)){
                                    lstToEmails.add(FAUser.Manager.Email); //RA
                        	}
                            }
                            if(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c.contains('CXO')){
                                if(String.isNotEmpty(CXOUser.Manager.Email)){
                                    lstToEmails.add(CXOUser.Manager.Email);      
                        	}
                        	}                        	
                        }
                        mail.toAddresses = lstToEmails;
                        System.debug('lstToEmails :'+lstToEmails);
                        mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'}; //pwm.salesforceupdate@edelweissfin.com
                        mail.htmlBody = ClientSatisMeasurementTrigger_Helper.getEmailBody(c, userDetail.Name);
                        emails.add(mail);
                       
                                            
                    }                   
                    if(caseAcc.ParentId != null && caseAcc.Parent.Coverage__c == 'R5' && userDetail.Business_Head__c != null){
                        List<String> toAddresses = new List<String>();
                        toAddresses.addAll(listOfNSMEmail); //NSM
                        user BHUser = userMAP.get(userDetail.Business_Head__c);//Business Head
                        User creator = userMAP.get(c.CreatedById);
                        if(creator.Profile.Name.contains('Financial Advisor') || creator.Profile.Name.contains('Team Leader Advisory')){  //// Doubt
                            if(String.isNotEmpty(FAUser.Manager.Email)){
                                toAddresses.add(FAUser.Manager.Email); //RA
                            }
                        }
                        
                        if(c.Client_Satisfaction_Measurement_NPS__r.NPS_Of_Client__c != 'Detractor'){
                            if(c.Client_Satisfaction_Measurement_NPS__r.Customer_Sentiment__c == 'Positive' ||
                               c.Client_Satisfaction_Measurement_NPS__r.Customer_Sentiment__c == 'Neutral'){
                              if(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c != Null){
                                  flag = 1;
                                   if(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c.contains('FA')) {  //// Doubt
                                       if(String.isNotEmpty(FAUser.Manager.Email)){
                                           toAddresses.add(FAUser.Manager.Email); //RA
                                       } 
                                   }
                                   if(c.Client_Satisfaction_Measurement_NPS__r.Close_Looping_to_be_Done_by__c.contains('CXO')){
                                       if(String.isNotEmpty(CXOUser.Manager.Email)){
                                           toAddresses.add(CXOUser.Manager.Email);      
                                       }
                                   }
                               }
                    }else if(c.Client_Satisfaction_Measurement_NPS__r.Customer_Sentiment__c == 'Negative'){
                            if(String.isNotEmpty(FAUser.Business_Head__r.Email)){
                                toAddresses.add(FAUser.Business_Head__r.Email);   //BH
                            }
                            if(String.isNotEmpty(FAUser.Regional_Head__r.Email)){
                                toAddresses.add(FAUser.Regional_Head__r.Email);  //RH
                            } 
                            if(creator.Profile.Name.contains('Financial Advisor') || creator.Profile.Name.contains('Team Leader Advisory')){  //// Doubt
                                if(String.isNotEmpty(FAUser.Manager.Email)){
                                    toAddresses.add(FAUser.Manager.Email); //RA
                                }
                            }
                        }
                    }
                    else if(c.Client_Satisfaction_Measurement_NPS__r.NPS_Of_Client__c == 'Detractor'){
                        if(creator.Profile.Name.contains('Financial Advisor') || creator.Profile.Name.contains('Team Leader Advisory')){  //// Doubt
                            if(String.isNotEmpty(FAUser.Manager.Email)){
                                toAddresses.add(FAUser.Manager.Email); //RA
                            }
                        }
                        if(String.isNotEmpty(FAUser.Business_Head__r.Email)){
                            toAddresses.add(FAUser.Business_Head__r.Email);   //BH
                        }
                        if(String.isNotEmpty(FAUser.Regional_Head__r.Email)){
                            toAddresses.add(FAUser.Regional_Head__r.Email);  //RH
                        	}
                        }
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.subject = 'New NPS Case '+c.CaseNumber+' created';
                    //toAddresses.add(BHUser.Email);   //Doubt
                        mail.toaddresses = toAddresses; 
                        //mail.toAddresses = new String[]{BHUser.Email};           
                        mail.ccAddresses = new String[]{'pwm.salesforceupdate@edelweissfin.com'}; //pwm.salesforceupdate@edelweissfin.com
                        if(flag == 1){
                            mail.htmlBody = ClientSatisMeasurementTrigger_Helper.getEmailBody(c, 'All');
                        }else{
                        mail.htmlBody = ClientSatisMeasurementTrigger_Helper.getEmailBody(c, BHUser.Name);
                        }
                        emails.add(mail);
                    }
                }
                
                if(emails != null && emails.size() > 0)
                    Messaging.sendEmail(emails);
                
           }
         }
    }
    
    public static String getEmailBody(case c, String mailTo){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String caseUrl = baseUrl + '/' + c.Id;
        String npsUrl = baseUrl + '/' + c.Client_Satisfaction_Measurement_NPS__c;
        String emailBody =  '<p style="font-family:Calibri;">Dear ' + mailTo + ',</br></br>' + 'Following NPS case has been created.' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Case Number</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+caseUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.CaseNumber + '</a></td></tr>'+
                            
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Client</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Account.Name + '</td></tr>'+
                            
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">NPS Number</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+npsUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + c.Client_Satisfaction_Measurement_NPS__r.Name + '</a></td></tr>' +
                            
        '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">NPS Of Client</td>' +
        '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' +c.Client_Satisfaction_Measurement_NPS__r.NPS_Of_Client__c + '</td></tr>' +
        
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Due Date</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Due_Date_Time__c.format() + '</td></tr>'+
                            
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Case Type</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Case_Type__c + '</td></tr>'+
                            
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Priority</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Priority + '</td></tr>'+

                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Description</td>' +
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Description + '</td></tr>'+
                            
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Case Owner</td>'+
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + c.Owner.Name + '</td></tr>';
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + endBody);
    }
    
     public static void createNPSYTDOnAccount(List<Client_Satisfaction_Measurement__c> listNPS)
     {
        List<Id> lstAccIds=  new List<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
    Map<Id,Account> accountMapAll = new Map<Id,Account>();
        Map<Id,Account> getParentIdMap = new Map<Id,Account>();
        List<Account> lstupdateAccount = new List<Account>();
        List<Account> lstgetParentId = new list<Account>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {
        if(EdelweissUtils.isDateWithinCurrentFiscalYear(objNPS.Date_of_Call__c)){
           lstAccIds.add(objNPS.Client_Name__c);
        }
    }
    accountMapAll = new map<Id,Account>([Select Id, NPS_Score_YTD__c,ParentId,NPS_Creation_DateTime__c From Account Where Id In : lstAccIds]);
        System.Debug('ParentId::'+accountMap);
        Map<Id,Decimal> CurrentNPSValue = new Map<Id,Decimal>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {  
        if(objNPS.Client_Recommendation_on_scale_of__c != null && objNPS.Client_Recommendation_on_scale_of__c != 'No Rating' && EdelweissUtils.isDateWithinCurrentFiscalYear(objNPS.Date_of_Call__c))
            {
            Account acc = accountMapAll.get(objNPS.Client_Name__c);
            acc.NPS_Score_YTD__c = Decimal.valueOf(objNPS.Client_Recommendation_on_scale_of__c) ;
                acc.NPS_Creation_DateTime__c = datetime.now().getTime();
            accountMap.put(acc.id, acc);
                CurrentNPSValue.put(acc.id, acc.NPS_Score_YTD__c);  
            }            
        }  
    //Update Family with avarage NPS score 
        List<Id> lstParentIds = new List<Id>();
        if(accountMap != null && accountMap.values().size() > 0){
          for(Account objAcc: accountMap.values())
          {
             lstParentIds.add(objAcc.ParentId);
          }
        }
        List<Account> lstFamily = [Select Id,NPS_YTD_Family__c,NPS_Creation_DateTime__c,No_of_client_Detractor__c,No_of_Client_NPS_Filled__c,No_of_client_Promoter__c, (Select Id,NPS_Score_YTD__c From ChildAccounts ) From Account Where Id =:lstParentIds];
        
        if(lstFamily != null && lstFamily.size() > 0)
        {           
            for(Account parent :lstFamily)
            {
                List<Account> childs = parent.ChildAccounts;
                integer count = 0;
                integer countDetractor = 0;
                integer countPromoter = 0;
                
                if(childs != null && childs.size() > 0){
                   Decimal totalNPS = 0.00; 
                  for(Account child : childs){
                    if(CurrentNPSValue.get(child.Id) != null){
                      Decimal newNPS = CurrentNPSValue.get(child.Id);
                      totalNPS += newNPS;
                      count++;
                      if(newNPS <= 6)
                        countDetractor++;
                       if(newNPS <= 10 && newNPS > 8)
                        countPromoter++;
                    }else{
                      if(child.NPS_Score_YTD__c !=  null)
                      {
                        totalNPS +=child.NPS_Score_YTD__c;
                        count++;
                        if(child.NPS_Score_YTD__c <= 6)
                            countDetractor++;
                        if(child.NPS_Score_YTD__c <= 10 && child.NPS_Score_YTD__c > 8)
                            countPromoter++;    
                      }
                    }            
                  }
                    if(!CurrentNPSValue.isEmpty()){
                    Parent.NPS_Creation_DateTime__c = datetime.now().getTime();
                    parent.NPS_YTD_Family__c = totalNPS/count;                  
                    parent.No_of_client_Detractor__c = countDetractor;
                    parent.No_of_client_Promoter__c = countPromoter;
                    parent.No_of_Client_NPS_Filled__c =count;
                    system.debug('ClientSatisfaction::parent.No_of_client_Detractor__c ::'+parent.No_of_client_Detractor__c);
                    system.debug('ClientSatisfaction::parent.No_of_Client_NPS_Filled__c ::'+parent.No_of_Client_NPS_Filled__c);
                    }
                }
            }
        }
        if(accountMap.values().size() > 0)
        {
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            database.upsert(accountMap.values());
        }
        if(lstFamily != null && lstFamily.size() > 0)
        {
           
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            System.debug('lstFamily:::'+lstFamily);
            database.update(lstFamily);
        }
    }
    
    public static void updateFamilyHead(List<Client_Satisfaction_Measurement__c> listNPS){
        Map<Client_Satisfaction_Measurement__c, Account> mapOfNPSEmail = new Map<Client_Satisfaction_Measurement__c, Account>();
        List<String> familyName = new List<String>();
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();
        
        for(Client_Satisfaction_Measurement__c nps : listNPS){
            familyName.add(nps.Family_Name__c);
        }
        System.debug('familyName '+familyName);
        List<Account> accountList = [SELECT Name , Owner.id ,Family_Head_Email_Id__c , Family_Head_Name__c ,Family__c FROM account where name IN :familyName AND recordtypeId =: RecordTypeId];
        
        Map<String,Account> mapAccountName = new Map<String,Account>();
        for(Account a : accountList){
            mapAccountName.put(a.Name, a);
        }
        
        for(Client_Satisfaction_Measurement__c nps : listNPS){
            Account acc = mapAccountName.get(nps.Family_Name__c);
            if(acc != null){
                if(acc.Family_Head_Email_Id__c != null){
                    nps.Family_Head_Email__c = acc.Family_Head_Email_Id__c;
                }
            }
        }
    }
    
    public static void updatePrimaryFaForAllRecords(List<Client_Satisfaction_Measurement__c> listNPS){
       List<Id> lstAccIds=  new List<Id>();
       Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Client_Satisfaction_Measurement__c objNPS: listNPS)
        {
              lstAccIds.add(objNPS.Client_Name__c);
        }
        if(lstAccIds != null && lstAccIds.size() > 0){
            accountMap = New Map<Id,Account>([Select Id, Primary_FA__c , Primary_CXO__c From Account Where Id In : lstAccIds]);
        }
        
        for(Client_Satisfaction_Measurement__c objNPS : listNPS){
        	if(objNPS.Client_Name__c!=null && accountMap.get(objNPS.Client_Name__c)!=null){
            objNPS.Primary_FA__c = accountMap.get(objNPS.Client_Name__c).Primary_FA__c;
                objNPS.Primary_CXO__c = accountMap.get(objNPS.Client_Name__c).Primary_CXO__c;   
            }
        }
    }
    
    public static void updateNPSEmailUser(List<Client_Satisfaction_Measurement__c> listNPS){
        Map<ID, user> userList = EdelweissConstants.userList;
        MAP<String,NPSEmails__c> mcs = NPSEmails__c.getall();
        Map<String, Id> mapOfPickListAnduser = new Map<String, Id>();
        for(NPSEmails__c nObj: mcs.values()){
            mapOfPickListAnduser.put(nObj.Picklist_Name__c , nObj.User_Id__c);
        }
        
        for(Client_Satisfaction_Measurement__c npsObj : listNPS){
            if(npsObj.Pertaining_To__c != null){
            if(npsObj.Pertaining_To__c == 'Research' || npsObj.Pertaining_To__c == 'Financial Advisor'){
                   User faUser = userList.get(npsObj.Primary_FA__c); 
                    if(faUser != null){
                       user userId =  userList.get(faUser.Manager.Id);
                        if(userId != null){
                            user userObj = userList.get(UserId.id);
                            if(userObj != null){
                                npsObj.Email_User__c = userObj.id;
                            }
                        }
                    }
                }
                else{
                    id userId = mapOfPickListAnduser.get(npsObj.Pertaining_To__c); 
                    if(userId != null){
                        user userObj = userList.get(UserId);
                        if(userObj != null){
                            npsObj.Email_User__c = userObj.id;
                        }
                        
                    }
                }
        	}
        }
    }
}