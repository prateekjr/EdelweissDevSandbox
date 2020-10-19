@RestResource(urlMapping='/CaseSubStatus/*')
global class CaseSubStatusService {

    @HttpPost
    global static void updateCaseSubStatus() {

        Id AccountOpeningCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId();        
        
        String body = System.RestContext.request.requestBody.toString();
        RestResponse res = System.RestContext.response;
        System.debug('Royals MOUI Request JSON : '+body);
        CaseDetails objCaseDetails = null;
        Boolean isError = false;
        
		try{
			objCaseDetails = (CaseDetails)JSON.deserialize(body, CaseDetails.class); 
			System.debug('List : '+objCaseDetails);
            
            if(objCaseDetails != null){
                objCaseDetails.errorMessage = '';
                objCaseDetails.Status = '';
                Map<String, String> subStatusMap = new Map<String, String>();  
                List<Schema.PicklistEntry> values = Case.Sub_Status__c.getDescribe().getPicklistValues();
                for(Schema.PicklistEntry f : values){
                    subStatusMap.put(f.getLabel().ToUpperCase(), f.getLabel());
                } 
                
                if(String.isEmpty(objCaseDetails.CaseNumber) || !objCaseDetails.CaseNumber.isNumeric()){
                    objCaseDetails.errorMessage = 'Case Number is missing or invalid';
                    objCaseDetails.Status = 'Error';
                } else if(String.isEmpty(objCaseDetails.SubStatus)){
                    objCaseDetails.errorMessage = 'Case Sub Status is required';
                    objCaseDetails.Status = 'Error';
                } else if (!subStatusMap.containsKey(objCaseDetails.SubStatus.ToUpperCase())){
                    objCaseDetails.errorMessage = 'Invalid Case Sub Status';
                    objCaseDetails.Status = 'Error';
                } else {
                    List<Case> lstCase = [
                        SELECT Id, CaseNumber, Sub_Status__c FROM Case 
                        WHERE RecordTypeId = :AccountOpeningCaseRecordTypeId AND CaseNumber = :objCaseDetails.CaseNumber LIMIT 1
                    ];
                    
                    if(!lstCase.isEmpty()){
                        Case c = lstCase[0];
                        if(String.isNotEmpty(c.Sub_Status__c) && ('Closed-Success'.equals(c.Sub_Status__c) || 'Closed-Rejected'.equals(c.Sub_Status__c))){
                            objCaseDetails.errorMessage = 'Case Sub Status is already processed as '+ c.Sub_Status__c;
                            objCaseDetails.Status = 'Error';
                        } else {
                            c.Sub_Status__c = subStatusMap.get(objCaseDetails.SubStatus.ToUpperCase());
                            
                            if('Closed-Rejected'.equals(c.Sub_Status__c)){
                                c.Status = 'Closed - Rejected';
                            } else if('Closed-Success'.equals(c.Sub_Status__c) || 'Closed-Failed'.equals(c.Sub_Status__c)){
                                List<Task> lstTask = [SELECT Id, Status, MOUI_Sub_Status_Received__c FROM Task WHERE WhatId=:c.Id AND Subject = 'MOUI Auto Closure' AND Status <> 'Completed'];
                                if(!lstTask.isEmpty()){
                                    for(Task t : lstTask){
                                        t.Status = 'Completed';
                                        t.MOUI_Sub_Status_Received__c = true;
                                    }
                                    update lstTask;
                                }
                            }
                            
                            try{
                                update c;
                                objCaseDetails.Status = 'Success';
                            }catch(Exception e){
                                objCaseDetails.errorMessage = e.getMessage();
                            	objCaseDetails.Status = 'Error';
                            }
                        }
                    } else {
                        objCaseDetails.errorMessage = 'Case record not found';
                        objCaseDetails.Status = 'Error';
                    }
                }
            }
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
            isError = true;
        }
        
        if(!isError){
            res.responseBody = Blob.valueOf(JSON.serialize(objCaseDetails));
            res.statusCode = 200; 
        }
    }

    public class CaseDetails{
        public String CaseNumber;
        public String SubStatus;
		public String Status;
        public String errorMessage;
    }
    public class Result {
        public boolean isSuccess;        
        public List<CaseDetails> caseDetailList;
    }
    
}