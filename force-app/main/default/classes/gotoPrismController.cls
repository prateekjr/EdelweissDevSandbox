public class gotoPrismController{
            public class lightingCallBackPrism{
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
            public static string validateUser1(){
                String isValid = 'Success';
                
                                /*String userId = UserInfo.getUserId();
                List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
                if(userList != null && userList.size() > 0){
                User currentUser = userList[0];
                string pName =  currentUser.Profile.Name;
                system.debug('pName--'+pName);
                if(!(pName .containsIgnoreCase('Administrator') || 
                pName .containsIgnoreCase('Product Manager') || 
                pName .containsIgnoreCase('Regional Head') || pName .containsIgnoreCase('Business Head') || 
                pName .containsIgnoreCase('Financial Advisor') || pName .containsIgnoreCase('Team Leader Advisory') || 
                pName .containsIgnoreCase('Client Experience Office (CXO)') || pName .containsIgnoreCase('CXO National Head') || 
                pName .containsIgnoreCase('CXO Zonal Head') )){
                isValid  = Label.Unauthorized_Access_is_denied;
                }        
                }        */
                
                return isValid;
            }
            
            @AuraEnabled
            public static  lightingCallBackPrism redirectURLCall(){
                
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
                HTTPResponse res;
                if(isSuccess){          
                     res = gotoPrismController.httpCallToAccessToken(intEdelweissEmployeeId);
                }
                lightingCallBackPrism objcallBack = new lightingCallBackPrism();
                String responseString = res.getBody();
                if(responseString.contains('Token=false')){
                    isSuccess = false;
                    objcallBack.isSuccess = false;
                    objcallBack.errorMessage = 'Prism Error : Unautherised user ';
                }
                if(res.getStatusCode() == 200){
               
               
                 }
                else{
                    objcallBack.isSuccess = false;
                    objcallBack.errorMessage = 'Prism Error : Something went wrong.Please contact Administrator ';
                }
                
                if(isSuccess == true){
                    objcallBack.isSuccess = true;
                    objcallBack.errorMessage = '';
                    System.debug('Return Body'+res.getBody());
                    objcallBack.returnBody = res.getBody();  
                }
                return objcallBack;
            }
            
            public static HTTPResponse httpCallToAccessToken(integer  intEdelweissEmployeeId){
                String apiUrl = '';
                String  apiUser = '';
                String  apiPass = '';
                String  apiDomain = '';
                List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
                for(IntegrationSetting__mdt setting : IntegrationSetting){
                    if(setting.DeveloperName == 'PrismGetTokenURL')
                        apiUrl = setting.Value__c;
                    if(setting.DeveloperName == 'PrismRedirectionUser')
                        apiUser = setting.Value__c;
                    if(setting.DeveloperName == 'PrismRedirectionPass')
                        apiPass = setting.Value__c;
                }
                
                apiUrl=apiUrl+'?EmpNo='+intEdelweissEmployeeId;
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(apiUrl);
                req.setHeader('userId', apiUser);
                req.setHeader('pwd', apiPass);
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(120000);
                req.setMethod('GET'); 
                
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeNumberField('EmpNo', intEdelweissEmployeeId);
                gen.writeEndObject();
                String JSONString = gen.getAsString(); 
                String JSONFinal = JSONString;
                JSONString = JSONFinal ;              
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                boolean redirect = false;
                System.debug(res.getStatusCode());
                return res;
            }
          
        }