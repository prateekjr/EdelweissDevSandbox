@RestResource(urlMapping='/CaseService/*')
global class CaseService {

    @HttpPost
    global static void createCase() {
        
        List<Case> lstCases = new List<Case>();
        List<CaseDetails> lstErrorCaseDetails = new List<CaseDetails>();
        User objDefaultUser = [SELECT Id, Name FROM User WHERE Name='PWM SalesForceUpdate'];
        Id serviceRequestCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.SERVICE_REQUEST).getRecordTypeId();        
        
        String body = System.RestContext.request.requestBody.toString();
        RestResponse res = System.RestContext.response;
        System.debug('Unica Request JSON : '+body);
        List<CaseDetails> listCaseDetails = new List<CaseDetails>(); 
        try{
           listCaseDetails = (List<CaseDetails>)JSON.deserialize(body, List<CaseDetails>.class); 
            System.debug('List : '+listCaseDetails);
            
            if(listCaseDetails != null && !listCaseDetails.isEmpty()){
                Set<String> setGWMOnlineId = new Set<String>();
                for(CaseDetails objCaseDetails : listCaseDetails){
                    if(objCaseDetails.clientCode != null){
                        setGWMOnlineId.add(objCaseDetails.clientCode);
                    }
                    objCaseDetails.errorMessage = '';
                    objCaseDetails.ticketNumber = '';
                }
                
                Map<Id, Account> mapAccount = new Map<Id, Account>([
                    SELECT Id, GWM_Online_Id__c, Primary_FA__c FROM Account WHERE GWM_Online_Id__c IN :setGWMOnlineId
                ]);
                
                Map<String, Id> mapGWMId_AccountId = new Map<String, Id>();
                for(Account acc : mapAccount.values()){
                    mapGWMId_AccountId.put(acc.GWM_Online_Id__c, acc.Id);
                }
                
                //Create case records
                for(CaseDetails objCaseDetails : listCaseDetails){
                    Boolean hasDataError = false;
                    objCaseDetails.errorMessage = '';
                    Case objCase = new Case();
                    objCase.RecordTypeId = serviceRequestCaseRecordTypeId;
                    
                    if(mapGWMId_AccountId.get(objCaseDetails.clientCode) != null){
                        objCase.AccountId = mapGWMId_AccountId.get(objCaseDetails.clientCode);
                    }else {
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Client Code is missing or invalid.';
                    }
                    
                    if(objCase.AccountId != null){
                        objCase.OwnerId = mapAccount.get(objCase.AccountId).Primary_FA__c; //ticketOwner
                    } else {
                        objCase.OwnerId = objDefaultUser.Id;
                    }
                    
                    if(!String.isEmpty(objCaseDetails.dueDate)){
                        try{
                        	objCase.Due_Date_Time__c = DateTime.parse(objCaseDetails.dueDate);
                        }catch(Exception e){
                            hasDataError = true;
                            objCaseDetails.errorMessage += e.getMessage(); 
                        }
                    }
                    
                    if(!String.isEmpty(objCaseDetails.UCM_Code)){
                        objCase.UCM_Code__c = objCaseDetails.UCM_Code.trim();
                    }else{
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field UCM_Code is missing.'; 
                    }
                    
                    if(String.isEmpty(objCaseDetails.Treatment_Code)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Treatment_Code is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.Offer_Code)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Offer_Code is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.Campaign_Code)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Campaign_Code is missing.'; 
                    }
                    
                    objCase.Priority = String.isEmpty(objCaseDetails.priority) ? 'Medium' : objCaseDetails.priority;
                    objCase.Origin = String.isEmpty(objCaseDetails.communicationMode) ? 'Email Campaign' : objCaseDetails.communicationMode;
                    objCase.Status = String.isEmpty(objCaseDetails.status) ? 'In Progress' : objCaseDetails.status;
                    objCase.Contacted_By__c = String.isEmpty(objCaseDetails.contractedBy) ? 'RM' : objCaseDetails.contractedBy; 
                    objCase.Type = String.isEmpty(objCaseDetails.requestType) ? 'New Product Information' : objCaseDetails.requestType;
                    objCase.LOB__c = String.isEmpty(objCaseDetails.lob) ? 'GWM' : objCaseDetails.lob;
                    objCase.Nature__c = String.isEmpty(objCaseDetails.nature) ? 'Sales Opportunity' : objCaseDetails.nature;
                    objCase.Description = String.isEmpty(objCaseDetails.description) ? 'UNICA Case' : objCaseDetails.description;
                    
                    objCase.Contacted_By_Others__c = objCaseDetails.others;
                    objCase.Subtype__c = objCaseDetails.subType;
                    objCase.Sub_Sub_Type__c = objCaseDetails.subSubType;
                    objCase.Remarks__c = objCaseDetails.remarks;
                    objCase.Campaign_Name__c = objCaseDetails.campaignName;
                    objCase.Campaign_Product__c = objCaseDetails.campaignProduct;
                    objCase.IsUnicaCase__c = true;
                    
                    if(hasDataError){
                        lstErrorCaseDetails.add(objCaseDetails);    
                    } else {
                        lstCases.add(objCase);    
                    }
                }
            }
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
       
       boolean isError = false;
        if(!lstErrorCaseDetails.isEmpty()){
            isError = true;
            Result objResult = new Result();
            objResult.isSuccess = false;
            objResult.caseDetailList = generateResponse(listCaseDetails);
            res.responseBody = Blob.valueOf(JSON.serialize(objResult));
            res.statusCode = 500;            
        } else if(!lstCases.isEmpty()){
            try{
                
                Savepoint sp = Database.setSavepoint();
                Database.SaveResult[] insertSR = Database.insert(lstCases, false);
                
                integer index = 0;
                Set<Id> successId = new Set<Id>();
                
                for(Database.SaveResult sr : insertSR)
                {
                    System.debug('sr.isSuccess() >>>'+sr.isSuccess());
                    if(!sr.isSuccess()){
                        String errorMessage = '';
                        isError = true;
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage+= err.getMessage() + '\n'; 
                        } 
                        if(listCaseDetails[index] != null ){
                            listCaseDetails[index].errorMessage =errorMessage; 
                        }
                    }else{
                        //isError = false;
                        if(listCaseDetails[index] != null ){
                            listCaseDetails[index].ticketNumber = sr.getId(); 
                            successId.add(sr.getId());
                        }
                    }
                    index++;
                }
                
                
                
                if(isError){
                    
                    for(CaseDetails cd : listCaseDetails){
                        cd.ticketNumber='';
                    }
                    
                    Result objResult = new Result();
                    objResult.isSuccess = false;
                    objResult.caseDetailList = generateResponse(listCaseDetails);
                    res.responseBody = Blob.valueOf(JSON.serialize(objResult));
                    res.statusCode = 500;
                    Database.rollback( sp );
                }else{
                    
                    Map<Id, Case> mapCase = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN : successId]);
                    
                    for(CaseDetails cd : listCaseDetails){
                        if(!String.isEmpty(cd.ticketNumber)){
                            cd.ticketNumber = mapCase.get(cd.ticketNumber).CaseNumber;
                        }
                    }
                    
                    Result objResult = new Result();
                    objResult.isSuccess = true;
                    objResult.caseDetailList = generateResponse(listCaseDetails);
                    res.responseBody = Blob.valueOf(JSON.serialize(objResult));
                    res.statusCode = 200; 
                }
                
            } catch (Exception e) {
                res.responseBody = Blob.valueOf(e.getMessage());
                res.statusCode = 500;
            }
        }
    }

    public class CaseDetails{
        public String clientCode;
        public String communicationMode;
        public String clientName;
        public String dueDate;
        public String lob;
        public String status;
        public String nature;
        public String contractedBy;
        public String others;
        public String requestType;
        public String priority;
        public String subType;
        public String subSubType;
        public String description;
        public String remarks;
        public String campaignName;
        public String campaignProduct;
        public String errorMessage;
        public String ticketNumber;
        
        public String UCM_Code; //UNICA data field
		public String Treatment_Code; //UNICA data field
		public String Offer_Code; //UNICA data field
		public String Campaign_Code; //UNICA data field
    }
    
    public class CaseDetailsResponse{
        public String clientCode;
        public String Ack_Status;
        public String errorMessage;
        public String UCM_Code;
		public String Treatment_Code;
		public String Offer_Code;
		public String Campaign_Code;
    }
    
    public class Result {
        public boolean isSuccess;        
        public List<CaseDetailsResponse> caseDetailList;
    }
    
    private static List<CaseDetailsResponse> generateResponse(List<CaseDetails> lstCaseDetails){
        List<CaseDetailsResponse> lstResponse = new List<CaseDetailsResponse>();
        for(CaseDetails objCaseDetails : lstCaseDetails){
        	CaseDetailsResponse objResponse = new CaseDetailsResponse();
            objResponse.clientCode = objCaseDetails.clientCode;
            objResponse.errorMessage = objCaseDetails.errorMessage;
            objResponse.UCM_Code = objCaseDetails.UCM_Code;
            objResponse.Treatment_Code = objCaseDetails.Treatment_Code;
            objResponse.Offer_Code = objCaseDetails.Offer_Code;
            objResponse.Campaign_Code = objCaseDetails.Campaign_Code;
            objResponse.Ack_Status =  String.isEmpty(objCaseDetails.errorMessage) ? 'Yes' : 'No';   
            lstResponse.add(objResponse);
        }
        return lstResponse;
    }
}