@RestResource(urlMapping='/BotCaseService/*')
global class BotCaseService {

    @HttpPost
    global static void BotCaseService() {
        List<Case> lstCases = new List<Case>();
        List<CaseDetails> lstErrorCaseDetails = new List<CaseDetails>();
         List<CaseDetails> lstInitialErrorCaseDetails = new List<CaseDetails>();
            
        User objDefaultUser = [SELECT Id, Name FROM User WHERE Name='PWM SalesForceUpdate'];
        Id serviceRequestCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.SERVICE_REQUEST).getRecordTypeId();        
        
        String body = System.RestContext.request.requestBody.toString();
        RestResponse res = System.RestContext.response;
        List<CaseDetails> listCaseDetails = new List<CaseDetails>(); 
        List<CaseDetails> listOfQulifiedCaseDetails = new List<CaseDetails>(); 
        try{
           listCaseDetails = (List<CaseDetails>)JSON.deserialize(body, List<CaseDetails>.class); 
            if(listCaseDetails != null && !listCaseDetails.isEmpty()){
                Set<String> setGWMOnlineId = new Set<String>();
                
                for(CaseDetails objCaseDetails : listCaseDetails){
                       Boolean hasDataError = false;
                      objCaseDetails.errorMessage = '';
                      if(String.isEmpty(objCaseDetails.nature)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Nature is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.serviceRequestProductType)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Service request product type is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.serviceRequestSubType)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Service request sub type  is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.ServiceRequestType)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Service request type is missing.'; 
                    }
                     if(String.isEmpty(objCaseDetails.communicationMode)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Communication mode is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.contactedBy)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Contacted by is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.status)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field status is missing.'; 
                    }
                    if(String.isEmpty(objCaseDetails.clientCode)){
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Value for mandatory field Client code is missing.'; 
                    }
                    if(hasDataError){
                        lstErrorCaseDetails.add(objCaseDetails);
                    }else{
                        listOfQulifiedCaseDetails.add(objCaseDetails);
                    }
                   
                }
            
                for(CaseDetails objCaseDetails : listOfQulifiedCaseDetails){
                    if(objCaseDetails.clientCode != null){
                        setGWMOnlineId.add(objCaseDetails.clientCode);
                    }
                    objCaseDetails.errorMessage = '';
                    objCaseDetails.ticketNumber = '';
                }
                Map<Id, Account> mapAccount = new Map<Id, Account>([
                    SELECT Id, GWM_Online_Id__c, Primary_FA__c , Primary_CXO__c FROM Account WHERE GWM_Online_Id__c IN :setGWMOnlineId
                ]);
                
                
                Map<String, Id> mapGWMId_AccountId = new Map<String, Id>();
                for(Account acc : mapAccount.values()){
                    mapGWMId_AccountId.put(acc.GWM_Online_Id__c, acc.Id);
                }
                System.debug('mapGWMId_AccountId :'+mapGWMId_AccountId);
                //Create case records
                for(CaseDetails objCaseDetails : listOfQulifiedCaseDetails){
                    Boolean hasDataError = false;
                    objCaseDetails.errorMessage = '';
                    Case objCase = new Case();
                    objCase.RecordTypeId = serviceRequestCaseRecordTypeId;
                   if(mapGWMId_AccountId.get(objCaseDetails.clientCode) != null){
                             objCase.AccountId = mapGWMId_AccountId.get(objCaseDetails.clientCode);
                    }else{
                        hasDataError = true;
                        objCaseDetails.errorMessage += 'Client Code is missing or invalid.';
                    }
                    
                    if(objCase.AccountId != null){
                        objCase.OwnerId = mapAccount.get(objCase.AccountId).Primary_CXO__c; //ticketOwner
                    } else{
                        objCase.OwnerId = objDefaultUser.Id;
                    }

                    objCase.Priority = objCaseDetails.priority;
                    objCase.Service_Request_Product_Type__c = objCaseDetails.serviceRequestProductType;
                    objCase.Service_Request_Sub_Type__c = objCaseDetails.serviceRequestSubType;
                    objCase.Service_Request_Type__c = objCaseDetails.ServiceRequestType;
                    objCase.Nature__c = objCaseDetails.nature;
                    objCase.Status = objCaseDetails.status;
                    objCase.Contacted_By__c = objCaseDetails.contactedBy; 
                    objCase.Origin = objCaseDetails.communicationMode;
                    objCase.Description = objCaseDetails.description;
					objCase.Contacted_By_Others__c = objCaseDetails.others;
                    objCase.Client_Name__c = objCaseDetails.clientName;
                    objCase.BotUniqueId__c = objCaseDetails.uniqueID;
                    objCase.Remarks__c = objCaseDetails.remarks;
                    objCase.Due_Date_Time__c = null;
                    objCase.Due_Date__c = null;
                    
                    objCaseDetails.ownerId = objCase.ownerID;
                    
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
            objResult.caseDetailList = generateResponse(lstErrorCaseDetails);
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
                        if(listOfQulifiedCaseDetails[index] != null ){
                            listOfQulifiedCaseDetails[index].errorMessage =errorMessage; 
                        }
                    }else{
                        if(listOfQulifiedCaseDetails[index] != null ){
                            listOfQulifiedCaseDetails[index].ticketNumber = sr.getId(); 
                            successId.add(sr.getId());
                        }
                    }
                    index++;
                }
                if(isError){
                    for(CaseDetails cd : listOfQulifiedCaseDetails){
                        cd.ticketNumber='';
                    }
                    Result objResult = new Result();
                    objResult.isSuccess = false;
                    objResult.caseDetailList = generateResponse(listOfQulifiedCaseDetails);
                    res.responseBody = Blob.valueOf(JSON.serialize(objResult));
                    res.statusCode = 500;
                    Database.rollback( sp );
                }else{
                    
                    Map<Id, Case> mapCase = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN : successId]);
                    
                    for(CaseDetails cd : listOfQulifiedCaseDetails){
                        if(!String.isEmpty(cd.ticketNumber)){
                            cd.ticketNumber = mapCase.get(cd.ticketNumber).CaseNumber;
                        }
                    }
                    
                    Result objResult = new Result();
                    objResult.isSuccess = true;
                    objResult.caseDetailList = generateResponse(listOfQulifiedCaseDetails);
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
        public String status;
        public String nature;
        public String contactedBy;
        public String others;
        public String requestType;
        public String priority;
        public String subType;
        public String subSubType;
        public String description;
        public String remarks;
        public String errorMessage;
        public String ticketNumber;
        public String uniqueID;
        public String ownerId;
  
        public String serviceRequestProductType;
        public String ServiceRequestType;
        public String serviceRequestSubType;
        
        
    }
    
    public class CaseDetailsResponse{
        public String errorMessage;
        public String ticketNumber;
        public String uniqueID;
        public String ticketOwner;
    }
    
    public class Result {
        public boolean isSuccess;        
        public List<CaseDetailsResponse> caseDetailList;
    }
    
    private static List<CaseDetailsResponse> generateResponse(List<CaseDetails> lstCaseDetails){
        List<CaseDetailsResponse> lstResponse = new List<CaseDetailsResponse>();
                Map<ID, user> userList = EdelweissConstants.userList;

        for(CaseDetails objCaseDetails : lstCaseDetails){
        	CaseDetailsResponse objResponse = new CaseDetailsResponse();
            user owner = userList.get(objCaseDetails.ownerID);
            if(owner != null){
               objResponse.ticketOwner = owner.Name + '('+owner.Edelweiss_Employee_Id__c + ')';
            }
            objResponse.ticketNumber = objCaseDetails.ticketNumber;	
            objResponse.uniqueID = objCaseDetails.uniqueID;
            objResponse.errorMessage = objCaseDetails.errorMessage;
            lstResponse.add(objResponse);
        }
        return lstResponse;
    }
}