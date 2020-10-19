public class CaseInfinityInWardingController {
    
    public static string finalresult;
    @AuraEnabled
    public static Account getRelatedFieldValues(string accid) {
        Account acc= new Account();
        if(accid != null)
        {
            acc =[select id, PAN_Number__c, Primary_Email__c from Account where id= :accid];  
        }
        return acc;
    }
    
    
    @AuraEnabled
    public static wrapCase saveRecord(Case caseRecord) {
        wrapCase wrapper = new wrapCase();
        
        
        if(caseRecord != null)
        {
            caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Wealth Inwarding').getRecordTypeId();
            Database.SaveResult saveResult = Database.insert(caseRecord, false);
            System.debug('Case Record :'+caseRecord);
            
            if (saveResult.isSuccess()) {
                wrapper.saveId =  saveResult.getId();
                case caseNum=[select id, CaseNumber from case where id=: wrapper.saveId];
                wrapper.caseNumber = caseNum.CaseNumber;
                System.debug('wrapCases :'+wrapper);
            }
            else {
                wrapper.caseNumber = 'Error '+saveResult.getErrors();
                wrapper.saveId = 'Error '+saveResult.getErrors();
                
            }
        }
        
        if(wrapper.caseNumber != null && wrapper.saveId != null){
            return wrapper;
        }
        
        return wrapper;
        
    } 
    
    
    
    @AuraEnabled
    public static String getClientLeadAccount(Case caseRecordObj){
        if( caseRecordObj.Lead_Account__c != null){
            Account clientLead = [Select id , Name from Account where id =:caseRecordObj.Lead_Account__c ];
            return clientLead.Name;
            //orderEntryObj.Family_Name_Display__c = family.Name;
        }
        return '';
    }
    
    public class wrapCase {
        
        @AuraEnabled  public string saveId {get; set;}
        @AuraEnabled public string caseNumber {get; set;}
        
    }
    
    @AuraEnabled 
    public static lightingCallBack callApi(string CaseId, string ClientName, string ClientPan, string ClientEmail, string Mode){
        Boolean isSuccess = true;
        string redirectURL='';
        string strErrorMessage='';
        String apiUrl = '';
        String  apiUser = '';
        String  apiPass = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'CaseInfinityRedirectionURL')
                apiUrl = setting.Value__c;
            if(setting.DeveloperName == 'CaseInfinityRedirectionUser')
                apiUser = setting.Value__c;
            if(setting.DeveloperName == 'CaseInfinityRedirectionPass')
                apiPass = setting.Value__c;
        }
        
        System.debug('apiUrl :'+apiUrl);
        System.debug('apiUser :'+apiUser);
        System.debug('apiPass :'+apiPass);
        
        
        
        ClientName = ClientName.replace(' ','_');
        system.debug(ClientName);
        
        String parameterStr = 'CaseId=##&ClientName=##&ClientPan=##&ClientEmail=##&Mode=##';
        parameterStr = parameterStr.replace('CaseId=##' , 'CaseId='+CaseId);
        parameterStr = parameterStr.replace('ClientName=##' , 'ClientName='+ClientName);
        parameterStr = parameterStr.replace('ClientPan=##' , 'ClientPan='+ClientPan);
        parameterStr = parameterStr.replace('ClientEmail=##' , 'ClientEmail='+ClientEmail);
        parameterStr = parameterStr.replace('Mode=##' , 'Mode='+Mode);
        
        apiUrl = apiUrl + parameterStr;
        System.debug('** apiUrl'+apiUrl);
        HTTPRequest req = new HTTPRequest();
        Http http = new Http();
        req.setMethod('GET'); 
        req.setEndpoint(apiUrl);
        Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);   
        req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        
        boolean redirect = false;
        System.debug('Response'+res);
        System.debug('Response Status Code'+res.getStatusCode());
        System.debug('Response getBody'+res.getBody());
        if(res.getStatusCode() == 200 ) {
            redirectURL = res.getBody();
            redirectURL = redirectURL.removeStart('"');
            redirectURL = redirectURL.removeEnd('"');
            redirectURL = redirectURL.remove('\\"');
            redirectURL = redirectURL.remove('\\');
            system.debug('redirectURL--'+redirectURL);
            if(!redirectURL.containsIgnoreCase('http')){
                isSuccess = false;
                strErrorMessage = redirectURL;
            }
            else
            {
                isSuccess = true; 
            }
            System.debug('redirectURL :'+redirectURL);
            
        }
        else{
            
            /*   String resStr = res.getBody();
resStr = resStr.removeStart('"');
resStr = resStr.removeEnd('"');
resStr = resStr.remove('\\"');
resStr = resStr.remove('\\');
ListofParams response =  (ListofParams)JSON.deserializeStrict(resStr ,ListofParams.class );
isSuccess = false;
strErrorMessage = response.message; */
            isSuccess = false;
            strErrorMessage = 'Error'+res.getBody();
            
        }
        
        lightingCallBack objcallBack = new lightingCallBack();
        if(isSuccess){
            objcallBack.isSuccess = true;
            objcallBack.errorMessage = '';
            objcallBack.returnBody = redirectURL;  
        }else{
            objcallBack.isSuccess = false;
            objcallBack.errorMessage = strErrorMessage;
            objcallBack.returnBody = 'https://www.google.co.in/';
        }
        return objcallBack;
        
    }       
    //return res;
    
    public class ListofParams{
        public Integer Status;
        public String message;
        
        public ListofParams(Integer Status, String message){
            Status = Status;
            message = message;
        }   
    }
    
    public class lightingCallBack{
        @AuraEnabled Public boolean isSuccess {get;set;}
        @AuraEnabled Public String errorMessage {get;set;}
        @AuraEnabled Public String returnBody {get;set;}        
    }
    
    
}