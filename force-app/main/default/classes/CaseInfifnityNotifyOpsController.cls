public class CaseInfifnityNotifyOpsController {
    
    
    public class lightingCallBack{
        @AuraEnabled Public boolean isSuccess {get;set;}
        @AuraEnabled Public String errorMessage {get;set;}
        @AuraEnabled Public String returnBody {get;set;}        
    }
    
    @AuraEnabled 
    public static lightingCallBack callApi(string caseRecordId){ 
        
        lightingCallBack objcallBack = new lightingCallBack();
        string strErrorMessage='';
        if(caseRecordId != null)
        {
            case caseRecord = [select id, caseNumber, ClientLead_Name_Display__c, PAN__c, Email__c from case where id=:caseRecordId];
            string CaseId = caseRecord.caseNumber;
            string ClientName = caseRecord.ClientLead_Name_Display__c;
            string ClientPan =  caseRecord.PAN__c;
            string ClientEmail =  caseRecord.Email__c;
            string Mode='0';
            
            Boolean isSuccess = true;
            string redirectURL='';
            
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
            
            
            if(isSuccess){
                objcallBack.isSuccess = true;
                objcallBack.errorMessage = '';
                objcallBack.returnBody = redirectURL;  
            }else{
                objcallBack.isSuccess = false;
                objcallBack.errorMessage = strErrorMessage;
                objcallBack.returnBody = 'https://www.google.co.in/';
            }
            
            
        }
        else{
                objcallBack.isSuccess = false;
                objcallBack.errorMessage = strErrorMessage;
                objcallBack.returnBody = 'https://www.google.co.in/';
            }
        return objcallBack;
    }
    
    
    
}