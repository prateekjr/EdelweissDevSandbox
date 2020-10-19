public class gotoGWMPortal{
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_json_jsongenerator.htm
    
    public class lightingCallBack{
        @AuraEnabled Public boolean isSuccess {get;set;}
        @AuraEnabled Public String errorMessage {get;set;}
        @AuraEnabled Public String returnBody {get;set;}        
    }
    
    public class ListofParams{
        public Integer Status;
        public String message;
    
        public ListofParams(Integer Status, String message){
            Status = Status;
            message = message;
        }   
    }   
    
    
    @AuraEnabled
    public static string validateUser(){
        String isValid = 'Success';
        
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            string pName =  currentUser.Profile.Name;
			system.debug('pName--'+pName);
			// Temporary code change for AD testing
            /*if(!(pName .containsIgnoreCase('Administrator') || 
                 pName .containsIgnoreCase('Product Manager') || 
                 pName .containsIgnoreCase('Regional Head') || pName .containsIgnoreCase('Business Head') || 
                 pName .containsIgnoreCase('Financial Advisor') || pName .containsIgnoreCase('Team Leader Advisory') || 
                 pName .containsIgnoreCase('Client Experience Office (CXO)') || pName .containsIgnoreCase('CXO National Head') || 
                 pName .containsIgnoreCase('CXO Zonal Head') )){
                isValid  = Label.Unauthorized_Access_is_denied;
            }*/        
            if(!(pName .containsIgnoreCase('Administrator') || 
                 pName .containsIgnoreCase('System Admin New') || 
                 pName .containsIgnoreCase('Product Manager') || 
                 pName .containsIgnoreCase('Regional Head') || pName .containsIgnoreCase('Business Head') || 
                 pName .containsIgnoreCase('Financial Advisor') || pName .containsIgnoreCase('Team Leader Advisory') || 
                 pName .containsIgnoreCase('Client Experience Office (CXO)') || pName .containsIgnoreCase('CXO National Head') || 
                 pName .containsIgnoreCase('CXO Zonal Head') )){
                isValid  = Label.Unauthorized_Access_is_denied;
            } 
        }        
        
        return isValid;
    }
    
    @AuraEnabled
    public static lightingCallBack redirectURLCall(String accId){
        system.debug('accId--'+accId);
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT Edelweiss_Employee_Id__c,Id FROM User WHERE Id =:userId];
        Boolean isSuccess = true;
        String strErrorMessage = '';
        Integer intEdelweissEmployeeId = 0;
        String strAccessToken = '';
        String redirectURL = '';
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            if(!String.isEmpty(currentUser.Edelweiss_Employee_Id__c ) && currentUser.Edelweiss_Employee_Id__c.isNumeric()){
                intEdelweissEmployeeId = integer.valueof(currentUser.Edelweiss_Employee_Id__c);
            }else{
                isSuccess = false;
                strErrorMessage = Label.Unauthorized_Access_is_denied;
            }       
        } 
        
        if(isSuccess){          
            HTTPResponse res = gotoGWMPortal.httpCallToAccessToken(intEdelweissEmployeeId);
            if(res.getStatusCode() == 200){
                system.debug('res1--'+res);
                strAccessToken = res.getBody();
                System.debug('strAccessToken--'+strAccessToken);
                strAccessToken = strAccessToken.removeStart('"');
                strAccessToken = strAccessToken.removeEnd('"');
                strAccessToken = strAccessToken.remove('\\"');
                strAccessToken = strAccessToken.remove('\\');
                System.debug('strAccessToken--'+strAccessToken);
                integer intFamilyCode = 0;
                List<Account> accList = [SELECT Id,GWM_Online_Id__c FROM Account WHERE Id =:accId];
                system.debug('accList--'+accList);
                if(accList != null && accList.size() > 0 && accList[0].GWM_Online_Id__c != null){
                    if(accList[0].GWM_Online_Id__c.isNumeric()){
                        intFamilyCode = integer.valueof(accList[0].GWM_Online_Id__c);
                    }
                }   
                system.debug('intEdelweissEmployeeId--'+intEdelweissEmployeeId);
                system.debug('intFamilyCode--'+intFamilyCode);
                system.debug('strAccessToken--'+strAccessToken);
                res = gotoGWMPortal.httpCallToRedirectURL(intEdelweissEmployeeId, intFamilyCode, strAccessToken );
                system.debug('res2--'+res);
                if(res.getStatusCode() == 200){
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
                    
                }else{
                    String resStr = res.getBody();
                    resStr = resStr.removeStart('"');
                    resStr = resStr.removeEnd('"');
                    resStr = resStr.remove('\\"');
                    resStr = resStr.remove('\\');
                    ListofParams response =  (ListofParams)JSON.deserializeStrict(resStr ,ListofParams.class );
                    isSuccess = false;
                    strErrorMessage = response.message;
                }
            }else{
                String resStr = res.getBody();
                resStr = resStr.removeStart('"');
                resStr = resStr.removeEnd('"');
                resStr = resStr.remove('\\');
                System.debug('resStr--'+resStr);
                ListofParams response =  (ListofParams)JSON.deserializeStrict(resStr ,ListofParams.class );
                System.debug('response--'+response);
                isSuccess = false;
                strErrorMessage = response.message;
            }
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
        return null;
    }
    
    public static HTTPResponse httpCallToAccessToken(integer  intEdelweissEmployeeId){
            String apiUrl = '';
            String  apiUser = '';
            String  apiPass = '';
            String  apiDomain = '';
            List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
            for(IntegrationSetting__mdt setting : IntegrationSetting){
                if(setting.DeveloperName == 'GWMPortalGetTokenURL')
                    apiUrl = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionUser')
                    apiUser = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionPass')
                    apiPass = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionDomain')
                    apiDomain = setting.Value__c;
                //if(setting.DeveloperName == 'GWMPortalRedirectionURL')
                    //apiUrl = setting.Value__c;
             }
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setHeader('userId', apiUser);
            req.setHeader('pwd', apiPass);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('POST'); 
            
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('UserID', intEdelweissEmployeeId);
            gen.writeEndObject();
            //gen.writeStringField('def', 'xyz');
            String JSONString = gen.getAsString(); 
            String JSONFinal = JSONString;
            JSONFinal = JSONFinal.replace('"','\\"');
            JSONFinal  = '"' + JSONFinal + '"';
            JSONString = JSONFinal ;
            System.debug('Body--->');
            System.debug(JSONString);
            req.setBody(JSONString);
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            boolean redirect = false;
            System.debug(res.getStatusCode());
            if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                    redirect = false; // reset the value each time
                    String loc = res.getHeader('Location'); // get location of the redirect
                    if(loc == null) {
                        redirect = false;
                    }
                    req = new HttpRequest();
                    req.setEndpoint(apiDomain+loc);
                    req.setHeader('userId', apiUser);
                    req.setHeader('pwd', apiPass);
                    req.setHeader('X-HTTP-Method-Override','PATCH');
                    req.setHeader('Content-Type', 'application/json');
                    req.setTimeout(120000);
                    req.setMethod('GET'); 
                    res = http.send(req);
                    System.debug(res.getStatusCode());
                    if(res.getStatusCode() != 500) { // 500 = fail
                        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                            redirect= true;
                        }
                    }
            }
                     
            
            return res;
    }
    
    public static HTTPResponse httpCallToRedirectURL(integer  intEdelweissEmployeeId, integer  FamilyCode, String  TokenId ){
            String apiUrl = '';
            String  apiUser = '';
            String  apiPass = '';
            String  apiDomain = '';
            List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
            for(IntegrationSetting__mdt setting : IntegrationSetting){
                if(setting.DeveloperName == 'GWMPortalRedirectionURL')
                    apiUrl = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionUser')
                    apiUser = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionPass')
                    apiPass = setting.Value__c;
                if(setting.DeveloperName == 'GWMPortalRedirectionDomain')
                    apiDomain = setting.Value__c;
             }
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setHeader('userId', apiUser);
            req.setHeader('pwd', apiPass);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('POST'); 
            
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('EdelweissEmployeeID', intEdelweissEmployeeId);
            gen.writeNumberField('FamilyCode', FamilyCode);
            gen.writeStringField('TokenId', TokenId);
            gen.writeEndObject();
            String JSONString = gen.getAsString(); 
            String JSONFinal = JSONString;
            JSONFinal = JSONFinal.replace('"','\\"');
            JSONFinal  = '"' + JSONFinal + '"';
            JSONString = JSONFinal ;
            System.debug(JSONString);
            req.setBody(JSONString);
            
            System.debug(req);
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            boolean redirect = false;
            System.debug(res.getStatusCode());
            if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                    redirect = false; // reset the value each time
                    String loc = res.getHeader('Location'); // get location of the redirect
                    if(loc == null) {
                        redirect = false;
                    }
                    req = new HttpRequest();
                    req.setEndpoint(apiDomain+loc);
                    req.setHeader('userId', apiUser);
                    req.setHeader('pwd', apiPass);
                    req.setHeader('X-HTTP-Method-Override','PATCH');
                    req.setHeader('Content-Type', 'application/json');
                    req.setTimeout(120000);
                    req.setMethod('GET'); 
                    res = http.send(req);
                    System.debug(res.getStatusCode());
                    if(res.getStatusCode() != 500) { // 500 = fail
                        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                            redirect= true;
                        }
                    }
            }
                     
            
            return res;
    }
}