public class gotoUNICA{
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_json_jsongenerator.htm
    
    public class lightingCallBack{
        @AuraEnabled Public boolean isSuccess {get;set;}
        @AuraEnabled Public String errorMessage {get;set;}
        @AuraEnabled Public String returnBody {get;set;}        
    }
    
   @AuraEnabled
    public static string validateUser(){
        String isValid = 'Success';
        
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            string pName =  currentUser.Profile.Name;
            if(!(pName .containsIgnoreCase('Administrator') || pName .containsIgnoreCase('Regional Head') || pName .containsIgnoreCase('Business Head') || pName .containsIgnoreCase(' Financial Advisor') || pName .containsIgnoreCase('Team Leader Advisory') )){
                isValid  = Label.Unauthorized_Access_is_denied;
            }        
        }        
        
        return isValid;
    }
    
    @AuraEnabled
    public static lightingCallBack redirectURLCall(String accId){
        system.debug('accId--'+accId);
       	String sUCMCode = '1234';
        List<Account> accList = [SELECT Id,UCM_Code__c FROM Account WHERE Id =:accId];
        system.debug('accList--'+accList);
        if(accList != null && accList.size() > 0 && accList[0].UCM_Code__c != null){
        	sUCMCode = accList[0].UCM_Code__c;
        }
        Sys_Properties__c URLProp = Sys_Properties__c.getValues('UNICA Mails Communication');
        String strURL = (URLProp != null && URLProp.Value__c != null) ? URLProp.Value__c : 'http://10.240.0.31:9080/CRM360/?ucm_code=';
        lightingCallBack objcallBack = new lightingCallBack();        
        objcallBack.isSuccess = true;
        objcallBack.errorMessage = '';
        objcallBack.returnBody = strURL+''+sUCMCode;
        return objcallBack;
    }
   
}