public class EdelweissUtils {
    private static Integer TAT{get;set;}
    private static Integer offDaysCount{get;set;}
    public EdelweissUtils(){
    }   
    public static Integer getOffDaysWithinTat(Integer turnAroundTime, Datetime startDate){
        if(turnAroundTime >= 0){
            TAT = turnAroundTime;
            Integer totalTatCount = 0;
            Map<Date,Date> holidaysMap = new Map<Date, Date>{};
                List<Holiday> holidays = [SELECT ActivityDate FROM Holiday];
                for(Holiday record : holidays){
                    holidaysMap.put(record.activitydate, record.activitydate);
                }
            System.debug('DildarLog: @getOffDaysWithinTat - holidaysMap, TAT, startDate - '+holidaysMap+', '+TAT+', '+startDate);           
            return getOffDaysWithinTat(holidaysMap, 0, TAT, startDate); 
        }else{
            return 0;
        }
    }
    private static Integer getOffDaysWithinTat(Map<Date, Date> holidaysMap, Integer lastCount, Integer tatIterator, Datetime startDate){
        Integer inc = 0;
        for(Integer i=0;i<=tatIterator;i++){
                if(holidaysMap.containsKey((startDate.date()+i)) || startDate.addHours(i*24).format('EEE') == 'Sun' || startDate.addHours(i*24).format('EEE') == 'Sat'){
                inc = inc+1;       
            }
        }
        offDaysCount = inc;
        if(inc != lastCount && startDate.date() >= System.today())
            getOffDaysWithinTat(holidaysMap, inc, (TAT+inc), startDate);
         
        return offDaysCount;        
    }
    public static String getUserName(Id userId){
        List<User> usr = [Select Name from User where id=:userId];
        return usr[0].Name;
    }
    public static integer checkFutureOffDays(Datetime dueDateTime, Decimal onHoldDurationHrs){
        Integer newOnHoldDurationHrs = 0;
        Integer onHoldDurationDays = 0;
        Integer offDays = 0;
        
        onHoldDurationDays = dueDateTime.Date().daysBetween(dueDateTime.addHours((integer)onHoldDurationHrs).Date());
        System.debug('DildarLog: onHoldDurationDays, dueDateTime,dueDateTime.addHours((integer)onHoldDurationHrs).Date() - ' + onHoldDurationDays +', '+ dueDateTime +', '+ dueDateTime.addHours((integer)onHoldDurationHrs).Date());
        if(onHoldDurationDays != 0){
            offDays = EdelweissUtils.getOffDaysWithinTat(onHoldDurationDays, dueDateTime);
            System.debug('DildarLog: offDays - ' + offDays);
            if(offDays == 0){
                newOnHoldDurationHrs = (Integer)onHoldDurationHrs;
            }else{
                newOnHoldDurationHrs = (Integer)(onHoldDurationHrs+(offDays*24));
            }
        }else{
            newOnHoldDurationHrs = (Integer)onHoldDurationHrs;
        }
        System.debug('DildarLog: newOnHoldDurationHrs - ' + newOnHoldDurationHrs);
        return newOnHoldDurationHrs;
    }
    public static integer checkPastOffDays(Datetime onHoldDateTime, Decimal onHoldDurationHrs){
        Integer onHoldDurationDays = 0;
        Integer offDays = 0;
        Integer newOnHoldDurationHrs = 0;
        
        onHoldDurationDays = (Integer)System.Math.floor(onHoldDurationHrs/24);
        System.debug('DildarLog: onHoldDurationDays - ' + onHoldDurationDays);
        offDays = EdelweissUtils.getOffDaysWithinTat(onHoldDurationDays, onHoldDateTime);
        System.debug('DildarLog: offDays - ' + offDays);
        if(offDays == 0){
            newOnHoldDurationHrs = (Integer)onHoldDurationHrs;
        }else{
            newOnHoldDurationHrs = (Integer)(onHoldDurationHrs-(offDays*24));
        }
        System.debug('DildarLog: newOnHoldDurationHrs - ' + newOnHoldDurationHrs);
        return newOnHoldDurationHrs;
    }
    public static Map<Integer,String> checkDependency(String stage, Case relatedCase){
        Map<Integer, String> message = new Map<Integer, String>{};
        System.debug(stage +','+relatedCase);
        Boolean hasPan = true;
        List<String> errorMsg = new List<String>();
        
        List<Additional_Lead__c> lstAdditionalLeads = relatedCase.Additional_Leads__r;
        if(lstAdditionalLeads != null && !lstAdditionalLeads.isEmpty()){
            for(Additional_Lead__c additionallead : lstAdditionalLeads){
                if(String.isEmpty(additionallead.PAN_Number__c)){
                    hasPan = false;
                }
            }
        }
        if(EdelweissConstants.CaseRecordTypeMap.get(relatedCase.RecordTypeId) == EdelweissConstants.ACCOUNT_OPENING){
			if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS)  && (relatedCase.Case_Type__c != EdelweissConstants.SERVICE_REQUEST)){
				if(relatedCase.PAN_Number__c == null ) {
					message.put(1, 'Please Update PAN Number');
					errorMsg.add('PAN Number');
				}
                if(relatedCase.Salutation__c == null ) {
					message.put(1, 'Please Update Salutations');
					errorMsg.add('Salutations');
				}
				if(relatedCase.DOB_DOI__c == null && relatedCase.Entity_Type__c != 'Company' && relatedCase.Entity_Type__c != 'LLP'){
					message.put(1, 'Please Update DOB/DOI');
					errorMsg.add('DOB/DOI');
				} 
			}
			if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS) && (relatedCase.Entity_Type__c != null || relatedCase.Entity_Type__c != '')){
				if(relatedCase.Entity_Type__c == 'Company' || relatedCase.Entity_Type__c == 'LLP'){
					if(String.isBlank(relatedcase.CIN_Number__c)){
						message.put(1, 'Please Update CIN Number');
						errorMsg.add('CIN Number');
					}
				}
			}
			String pType = relatedcase.Product_Type__c;
			if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS)){
				/*if(pType.contains('Demat')){
					if(relatedCase.Number_of_Joint_Holders_Max_2__c != null || relatedCase.Number_of_Joint_Holders_Max_2__c != ''){
						if(relatedCase.Number_of_Joint_Holders_Max_2__c == '1'){
							if(relatedCase.Joint_Holder_Client1_PAN_Number__c == null || relatedcase.Joint_Holder_Client1_DOB_DOI__c == null ){
								message.put(1, 'Please Update Pan Number and DOB_DOI for Joint Holder 1');
								errorMsg.add('Pan Number and DOB/DOI of Joint Holder 1');
							}
						}
						if(relatedCase.Number_of_Joint_Holders_Max_2__c == '2'){
							if(relatedCase.Joint_Holder_Client2_PAN_Number__c == null || relatedcase.Joint_Holder_Client2_DOB_DOI__c == null ){
								message.put(1, 'Please Update Pan Number and DOB_DOI for Joint Holder 2');
								errorMsg.add('Pan Number and DOB/DOI of Joint Holder 2');
							}
						}
					}
				}  
				*/
				if(relatedcase.Product_Type__c != null){
					System.debug('############ Product Type'+relatedcase.Product_Type__c);
					if(pType.contains('Trading')){
						System.debug('############ inside trading '+relatedcase.Delivery_Slab__c);
						if(relatedcase.Delivery_Slab__c == null || relatedcase.Delivery_Minimum_P__c == null || relatedcase.Delivery_Sides__c == null || relatedcase.Intraday_Minimum_P__c == null || relatedcase.Intraday_Sides__c == null || relatedcase.Intraday_Slab__c == null || relatedcase.Currency_Futures_Minimum_P__c == null || relatedcase.Currency_Futures_Sides__c == null || relatedcase.Currency_Futures_Slab__c == null || relatedcase.Currency_Options_Minimum_P__c == null || relatedcase.Currency_Options_Sides__c == null || relatedcase.Currency_Options_Slab__c == null || relatedcase.Derivatives_Futures_Minimum_P__c == null || relatedcase.Derivatives_Futures_Sides__c == null || relatedcase.Derivatives_Futures_Minimum_P__c == null || relatedcase.Derivatives_Options_Minimum_P__c == null || relatedcase.Derivatives_Options_Sides__c ==   Null || relatedcase.Derivatives_Options_Slab__c == null)                   {
							message.put(1, 'Please fill all details in trading section');
							errorMsg.add('Trading Section Details');
						}           
					}
				}
			}
			if(!errorMsg.isEmpty()){
				message.put(1, 'Salesforce - Please fill mandatory details : ' + String.join(errorMsg, ', ')+'.');
			}
			if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS)  && relatedCase.Case_Type__c == EdelweissConstants.ACCOUNT_OPENING &&
			   relatedCase.Special_Brokerage_Approval_Status__c !='Approved' && relatedCase.Special_Brokerage_RM_Approval_Required__c ){
				   message.put(1, 'Salesforce - Special brokerage RA approval not received');
			}
			
			if(stage.contains(EdelweissConstants.MINI_IPS_RISK_PROFILE) && relatedCase.Account.Risk_Profile_Based_on_IPS__c == null && (relatedCase.Case_Type__c != EdelweissConstants.SERVICE_REQUEST)){
				message.put(1, 'Please Complete the details in Risk Profile');
			}
            if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS) && (relatedcase.Product_Type__c).contains('Demat')){
                
                if(relatedCase.Number_of_Joint_Holders_Max_2__c != null || relatedCase.Number_of_Joint_Holders_Max_2__c != ''){
                    String strErrorMsg = '';
                    if(relatedCase.Number_of_Joint_Holders_Max_2__c == '1' || relatedCase.Number_of_Joint_Holders_Max_2__c == '2'){
                        List<String> lstMissingFields = new List<String>();
                        if(String.isBlank(relatedCase.Joint_Holder_Client1_Name__c)){
                            lstMissingFields.add('Name');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client1_PAN_Number__c)){
                            lstMissingFields.add('Pan Number');
                        }
                        if(relatedCase.Joint_Holder_Client1_DOB_DOI__c == null){
                            lstMissingFields.add('DOB/DOI');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client1_Entity_Type__c)){
                            lstMissingFields.add('Entity Type');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client1_Contact_Number__c)){
                            lstMissingFields.add('Contact Number');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client1_Email_ID__c)){
                            lstMissingFields.add('Email Id');
                        }
                        if(!lstMissingFields.isEmpty()){
                            strErrorMsg = 'Please Update '+ String.join(lstMissingFields, ', ') +' for Joint Holder 1. ';
                        }
                    } if(relatedCase.Number_of_Joint_Holders_Max_2__c == '2'){
                        List<String> lstMissingFields = new List<String>();
                        if(String.isBlank(relatedCase.Joint_Holder_Client2_Name__c)){
                            lstMissingFields.add('Name');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client2_PAN_Number__c)){
                            lstMissingFields.add('Pan Number');
                        }
                        if(relatedCase.Joint_Holder_Client2_DOB_DOI__c == null){
                            lstMissingFields.add('DOB/DOI');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client2_Entity_Type__c)){
                            lstMissingFields.add('Entity Type');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client2_Contact_Number__c)){
                            lstMissingFields.add('Contact Number');
                        }
                        if(String.isBlank(relatedCase.Joint_Holder_Client2_Email_ID__c)){
                            lstMissingFields.add('Email Id');
                        }
                        if(!lstMissingFields.isEmpty()){
                            strErrorMsg += 'Please Update '+ String.join(lstMissingFields, ', ') +' for Joint Holder 2';
                        }
                    }
                    if(String.isNotBlank(strErrorMsg)){
                        message.put(1, strErrorMsg);
                    }
                }
            }
            if(stage.contains(EdelweissConstants.UPDATE_MANDATORY_DETAILS)){
            //Modified for Family Head Name and PanNumber for MOUI Auto Closure
                 if(relatedCase.MainLead__r.Recordtype.Name=='Lead'){        
                       if(relatedCase.MainLead__r.Name == null ){
						message.put(1, 'Please Update Main Lead Name');
						errorMsg.add('MainLead__r.Name');
						}
						
						if(relatedCase.MainLead__r.Pan_Number__c == null ){
						message.put(1, 'Please Update PAN Number for Main Lead');
						errorMsg.add('MainLead__r.Pan_Number__c');
						}
                }
                if(relatedCase.MainLead__r.Recordtype.Name=='Client'){        
                       if(relatedCase.MainLead__r.Parent.Family_Head_Name__r.Name == null ){
						message.put(1, 'Please Update Family Head Name');
						errorMsg.add('MainLead__r.Parent');
						}
						
						if(relatedCase.MainLead__r.Parent.Family_Head_Name__r.Pan_Number__c == null ){
						message.put(1, 'Please Update PAN Number for Family Head');
						errorMsg.add('MainLead__r.Parent');
						}
                }
                if(relatedCase.MainLead__r.Recordtype.Name=='Family'){        
                       if(relatedCase.MainLead__r.Family_Head_Name__r.Name == null ){
						message.put(1, 'Please Update Main Lead Name');
						errorMsg.add('MainLead__r.Family_Head_Name__c');
						}
            
						if(relatedCase.MainLead__r.Family_Head_Name__r.Pan_Number__c == null ){
						message.put(1, 'Please Update PAN Number for Family Head');
						errorMsg.add('MainLead__r.Family_Head_Name__c');
						}
                }
            }
		}
        if(stage.contains(EdelweissConstants.DOCUMENT_COLLECTION) && relatedCase.PAN_Number__c == null && (relatedCase.Case_Type__c != EdelweissConstants.SERVICE_REQUEST)){
            message.put(1, Label.PAN_Verification_on_Case);
        }
        else if(stage.contains(EdelweissConstants.DOCUMENT_COLLECTION) && !hasPan && (relatedCase.Case_Type__c != EdelweissConstants.SERVICE_REQUEST)){
            message.put(1, 'All additional leads should have PAN number');
        }
        else if(stage.contains(EdelweissConstants.KRA_VERIFICATION) && relatedCase.KRA_Status__c != 'Verified' && (relatedCase.Case_Type__c != EdelweissConstants.SERVICE_REQUEST)){
            message.put(1, Label.KRA_Verification_on_Case);
        }else if(stage.contains(EdelweissConstants.SENDING_CHECKLIST)){
            List<Task> tsk = [SELECT Id, Subject FROM Task Where WhatId =: relatedCase.Id And Subject Like '%Email: Required%' limit 1];
            if(tsk.size() < 1){
                message.put(1, Label.Send_Email_Checklist_on_Case);   
            }
        }else if(stage.contains(EdelweissConstants.SEND_WELCOME_EMAIL)){
            List<Task> tsk = [SELECT Id, Subject FROM Task Where WhatId =: relatedCase.Id And Subject Like '%Email: Welcome%' limit 1];
            if(tsk.size() < 1){
                message.put(1, Label.Welcome_Email_Sent_Check_on_Case);   
            }
        }else if(stage.contains(EdelweissConstants.SENDING_MoM)){
            List<Event> evnt = [SELECT Id, isMoMSend__c FROM Event Where WhatId =: relatedCase.Id And (isMoMSend__c = true OR Reason_For_Not_Sending_MoM__c != null OR Reason_For_Not_Sending_MoM__c != '') limit 1];
            if(evnt.size() < 1){
                message.put(1, Label.Sent_MoM_Check_on_Case);   
            }
        }else if(relatedCase.Status != EdelweissConstants.CASE_CLOSED_REJECTED_STATUS && (stage == '' || stage == null)){
            Integer pendingActivities = [SELECT count() FROM Task Where WhatId =: relatedCase.Id And Status !=: EdelweissConstants.TASK_COMPLETED_STATUS];
            if(pendingActivities != null && pendingActivities > 0){
                message.put(1, Label.Pending_Activities_Check_on_Case);   
            }
        }
        
        return message;
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
static Integer orgFiscalMonth;
    static{
         orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
    }
public static boolean isDateWithinCurrentFiscalYear(Date comparedate){
     Date orgFiscalYear;
     Integer todayMonth=system.today().month();
     Integer fiscalYear;
   
    if(orgFiscalMonth>todayMonth){
        fiscalYear=system.today().year()-1;
    }
    else{
        fiscalYear=system.today().year();
    }
    orgFiscalYear= Date.newinstance(fiscalYear, orgFiscalMonth, 1);
	
	Date nextFiscalYear = Date.newinstance(fiscalYear+1, orgFiscalMonth, 1);
	
	if(comparedate>=orgFiscalYear && comparedate<nextFiscalYear){
		return true;
	} 
	return false;
}
}