public class TrendReportController {
    
    public String apiUser{get;set;}
    public String apiUrl{get;set;}
    public String apiPass{get;set;}
    public String apiDomain{get;set;}
    
    public String selectedPeriod {get;set;}
    public List<ResponseList> respList {get;set;}
    public boolean isAccess {get;set;}
    public boolean isGWM {get;set;}
    public boolean isZonal {get;set;}
    public boolean isFA {get;set;}
    public String selectedRH {get;set;}
    public String selectedFA {get;set;}
    public String selectedSubLob{get;set;}
    public String selectedFamily {get;set;}
    public boolean isInlineVF {get;set;}
    public boolean noDataFound {get;set;}
    private Map<Id,string> ProfileMap = new Map<Id,string>();
    private string familyId;
    public User u;
    
    public class ListofParams{
    public String ToDate; //optional
    public Integer IsGwmHead;
    public Integer IsZoneHead;
    public integer Period;
    public Integer SubLob; //optional
    public Integer Fam_Code;
    public Integer FA_ID;
    public  Integer Emp_Code;
    public String CurrType;
    public String Denomination;
    
    public ListofParams(String todaydate, Integer isGWM, Integer isZone, Integer months, Integer SubLobCat, Integer FamCode, Integer FId, Integer EmpCode, String CurrType, String denom){
        ToDate = todaydate;
        isGWMHead = isGWM;
        isZoneHead = isZone;
        Period = months;
        SubLob = SubLobCat;
        Fam_Code= FamCode;
        FA_ID= FId;
        Emp_Code = EmpCode;
        CurrType= CurrType;
        Denomination= denom;
    }   
}
    public TrendReportController(ApexPages.StandardController controller) {
    	Sys_Properties__c FamilyTrendApiUrl = Sys_Properties__c.getValues('FamilyTrendApiUrl');
    	Sys_Properties__c FamilyTrendApiUser = Sys_Properties__c.getValues('FamilyTrendApiUser');
    	Sys_Properties__c FamilyTrendApiPass = Sys_Properties__c.getValues('FamilyTrendApiPass');
    	Sys_Properties__c FamilyTrendApiDomain = Sys_Properties__c.getValues('FamilyTrendApiDomain');
    	 
    	apiUrl = FamilyTrendApiUrl.Value__c;
    	apiUser = FamilyTrendApiUser.Value__c;
    	apiPass = FamilyTrendApiPass.Value__c;
    	apiDomain = FamilyTrendApiDomain.Value__c;
    	
    	System.debug('DildarLog: user, url, pass, domain - ' + apiUser+', ' + apiUrl + ', ' + apiPass + ', ' + apiDomain);
    	
        isInlineVF = true;
        noDataFound = false;
        isGWM= false;
        isFA = false;
        isZonal = false;
        familyId = controller.getId();
        if(familyId == null)isInlineVF = false;
        if(selectedPeriod == null || selectedPeriod == '')
            selectedPeriod = '6months';
        Id profileID = UserInfo.getProfileId();
        isAccess =  true;
        List<Profile> pro = new List<Profile>();
        pro = [select id, name from Profile limit 500];
        if(pro != null && pro.size()> 0){
            for(Profile prof : pro)
                ProfileMap.put(prof.Id,prof.name);
        }
        system.debug('pro ----'+pro);
        String ProfileName = ProfileMap.get(profileID);
        system.debug('ProfileName ----'+ProfileName);
        if(ProfileName == 'Business Head' || ProfileName == 'System Administrator'){
            isGWM = true;
        }   
        else if(ProfileName == 'Regional Head'){
            isZonal = true;
        }   
        else if(ProfileName == 'Financial Advisor'){
            isFA = true;
        }   
        else
            isAccess = false;
        if(isAccess && isInlineVF){
            u = [select id, Edelweiss_Employee_Id__c,Miles_Id__c from User where id =: UserInfo.getUserId() limit 1];
            getDataFromAPI(isGWM,isZonal,isFA,u,familyID);
            //runReport();
        }
        
    }
    
    public List<SelectOption> getRegionalOptions() {
        system.debug('isInlineVF ----'+isInlineVF); 
        List<SelectOption> options = new List<SelectOption>();
        Id proID;
        for(Id pname: ProfileMap.keySet()){
            if(ProfileMap.get(pname) == 'Regional Head'){
                proID = pname;
                break;
            }   
        }
        system.debug('proID ----'+proID);   
        List<User> userList = [select id,name, ProfileID from user where ProfileID =:proID and Business_Head__c =: UserInfo.getUserId() limit 10000];
        options.add(new SelectOption('None','---None----'));
        for(User u : userList)
            options.add(new SelectOption(u.Id, u.name));
        system.debug('options ----'+options);   
        return options;
    }
    
    public List<SelectOption> getsublLobs() {
    	
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl+'/FetchSubLobs');
        String username = apiUser;
        String password = apiPass;
        req.setHeader('userId', apiUser);
        req.setHeader('pwd', apiPass);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setMethod('POST'); 
        List<User> u = [select Miles_Id__c from User where Id =: UserInfo.getUserId()];
        SubLobWrapper wrap;
        Integer milesId = 0;
        if(!String.isEmpty(u[0].Miles_Id__c)){
            milesId = Integer.valueOf(u[0].Miles_Id__c);
        }
        if(isGWM){
            wrap = new SubLobWrapper(milesId ,1);
        }else if(isZonal){
            wrap = new SubLobWrapper(milesId ,0);
        }
        String JSONString = JSON.serialize(wrap);
        JSONString =JSONString .remove('[');
        JSONString =JSONString .remove(']');
        String JSONFinal = JSONString;
        JSONFinal = JSONFinal.replace('"','\\"');
        JSONFinal  = '"' + JSONFinal + '"';
        JSONString = JSONFinal ;
        system.debug(' Sub-Lob Request JSONString : '+JSONString );
        req.setBody(JSONString);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res: '+res.getHeader('Location'));
        boolean redirect = false;
        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
            redirect = false; // reset the value each time
            String loc = res.getHeader('Location'); // get location of the redirect
            if(loc == null) {
                redirect = false;
            }
            req = new HttpRequest();
            req.setEndpoint(apiDomain+loc);
            req.setBody(JSONString);
            req.setHeader('userId', apiUser);
            req.setHeader('pwd', apiPass);
            req.setHeader('X-HTTP-Method-Override','PATCH');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('POST'); 
            res = http.send(req);
            if(res.getStatusCode() != 500) { // 500 = fail
                if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                    redirect= true;
                }
            }
        }
        System.debug('response----'+res.getBody());
        String response = res.getBody();
        response = response.removeStart('"');
        response = response.removeEnd('"');
        response = response.remove('\\');
        system.debug('response --'+response );
        List<SubLobResponseWrapper> respList =  (List<SubLobResponseWrapper>)JSON.deserializeStrict(response ,List<SubLobResponseWrapper>.class );
        system.debug('respList : '+respList );
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(SubLobResponseWrapper subLobWrapp : respList){
            options.add(new SelectOption(subLobWrapp .Id+'',subLobWrapp.name));
        }
        return options;
    }
    
     public List<SelectOption> getFAOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        system.debug('selectedSubLob: '+selectedSubLob);
        if(!String.isEmpty(selectedSubLob)){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl+'/FetchFAList');
            String username = apiUser;
            String password = apiPass;
            req.setHeader('userId', apiUser);
            req.setHeader('pwd', apiPass);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('POST'); 
            List<User> u = [select Miles_Id__c from User where Id =: UserInfo.getUserId()];
            Integer milesId = 0;
            if(!String.isEmpty(u[0].Miles_Id__c)){
                milesId = Integer.valueOf(u[0].Miles_Id__c);
            }
            FARequestWrapper wrap;
            if(isGWM ){
                wrap = new FARequestWrapper(milesId ,1,0,Integer.valueOf(selectedSubLob));
            }else if(isZonal){
                wrap = new FARequestWrapper(milesId ,0,1,Integer.valueOf(selectedSubLob));
            }
            String JSONString = JSON.serialize(wrap);
            JSONString =JSONString .remove('[');
            JSONString =JSONString .remove(']');
            String JSONFinal = JSONString;
            JSONFinal = JSONFinal.replace('"','\\"');
            JSONFinal  = '"' + JSONFinal + '"';
            JSONString = JSONFinal ;
            system.debug('FA Request JSONString : '+JSONString );
            req.setBody(JSONString);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('res: '+res.getHeader('Location'));
            boolean redirect = false;
            if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                redirect = false; // reset the value each time
                String loc = res.getHeader('Location'); // get location of the redirect
                if(loc == null) {
                    redirect = false;
                }
                req = new HttpRequest();
                req.setEndpoint(apiDomain+loc);
                req.setBody(JSONString);
                req.setHeader('userId', apiUser);
                req.setHeader('pwd', apiPass);
                req.setHeader('X-HTTP-Method-Override','PATCH');
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(120000);
                req.setMethod('POST'); 
                res = http.send(req);
                if(res.getStatusCode() != 500) { // 500 = fail
                    if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                        redirect= true;
                    }
                }
            }
            System.debug('response----'+res.getBody());
            String response = res.getBody();
            response = response.removeStart('"');
            response = response.removeEnd('"');
            response = response.remove('\\');
            system.debug('response --'+response );
            List<FAResponseWrapper> respList =  (List<FAResponseWrapper>)JSON.deserializeStrict(response ,List<FAResponseWrapper>.class );
            system.debug('respList : '+respList );
            for(FAResponseWrapper faWrap : respList){
                options.add(new SelectOption(faWrap .MilesID+'',faWrap.FAName));
            }
        }
        return options;
    }
    
    /*public List<SelectOption> getFAOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Id proID;
        for(Id pname: ProfileMap.keySet()){
            if(ProfileMap.get(pname) == 'Financial Advisor'){
                proID = pname;
                break;
            }   
        }
        options.add(new SelectOption('None','---None----'));
        system.debug('selectedRH-----'+selectedRH);
        List<User> userList = [select id,name, ProfileID from user where ProfileID =:proID and  Regional_Head__c =:selectedRH and Regional_Head__c != null limit 10000];
        for(User u : userList)
            options.add(new SelectOption(u.Id, u.name));
        system.debug('options ----'+options);
        return options;
    }*/
    
    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','---None----'));    
        List<User> u = [select Miles_Id__c from User where Id =: UserInfo.getUserId()];
        Integer milesId = 0;
        if(!String.isEmpty(u[0].Miles_Id__c)){
            milesId = Integer.valueOf(u[0].Miles_Id__c);
        }
        if(selectedFA == null){
            selectedFA = milesId+'';
        }
        system.debug('selectedFA Miles Id-----'+selectedFA);
        List<Account> AccountList = [select id, name, Primary_FA__c from Account where RecordTypeId =: Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId() and Primary_FA__r.Miles_Id__c =: selectedFA and Primary_FA__c != null limit 50000];
        for(Account acc : AccountList)
            options.add(new SelectOption(acc.Id, acc.name));
        return options;
    }

    public void runReport() {
       getDataFromAPI(isGWM,isZonal,isFA,u,familyID);
    }
    
    
    public void getDataFromAPI(boolean isGVM, boolean isZonal, boolean isFA,User u,String familyID){   
        Integer period =1;
        Account acc;
        try{
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl+'/FetchAUM');
        String username = apiUser;
        String password = apiPass;
        req.setHeader('userId', apiUser);
        req.setHeader('pwd', apiPass);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setMethod('POST'); 
        List<ListofParams> ReqParamsData = new List<ListofParams>();
        Integer isGVMInt = 0;
        Integer isZonalInt = 0;
        if(isGVM)isGVMInt = 1;
        if(isZonal)isZonalInt = 1;
        if(selectedPeriod == 'Quarterly')period = 2;
        Integer subLobIds = 0;
        system.debug('familyID : '+familyID );
        if(familyID != null){
            acc = [select id,GWM_Online_Id__c,Sub_Lob__c ,Primary_FA__r.Miles_Id__c, 
                        Primary_FA__r.Edelweiss_Employee_Id__c
                        from Account where id =: familyID limit 1]; 
        }
        else{
            if(selectedFamily != null)
                acc = [select id,GWM_Online_Id__c,Sub_Lob__c,Primary_FA__r.Miles_Id__c, 
                            Primary_FA__r.Edelweiss_Employee_Id__c  from Account where id =: selectedFamily limit 1];
        }
        system.debug('acc : '+acc );
        if(acc != null && !String.isEmpty(acc.Sub_Lob__c )){
                SubLobMapping__c subLobs = SubLobMapping__c.getValues(acc.Sub_Lob__c);
                subLobIds = Integer.valueOf(subLobs.Sub_Lob_ID__c);
        }
        Integer milesId =  0; 
        Integer empId  = 0;
        if(acc != null && !String.isEmpty(acc.Primary_FA__r.Miles_Id__c)){
            milesId = Integer.valueOf(acc.Primary_FA__r.Miles_Id__c);
        }else if(!String.isEmpty(u.Miles_Id__c)){
            milesId =Integer.valueOf(u.Miles_Id__c);
        }
        if(acc != null && !String.isEmpty(acc.Primary_FA__r.Edelweiss_Employee_Id__c)){
            empId  = Integer.valueOf(acc.Primary_FA__r.Edelweiss_Employee_Id__c);
        }else if(!String.isEmpty(u.Edelweiss_Employee_Id__c)){
            empId  = Integer.valueOf(u.Edelweiss_Employee_Id__c);
        }
        system.debug('isGVMInt :'+isGVMInt);
        system.debug('isZonalInt:'+isZonalInt);
        system.debug('period:'+period);
        system.debug('subLobIds:'+subLobIds);
        system.debug('acc.GWM_Online_Id__c: '+acc.GWM_Online_Id__c);
        ReqParamsData.add(new ListofParams('1/1/1900',isGVMInt,isZonalInt,period,subLobIds,Integer.valueOf(acc.GWM_Online_Id__c),
                milesId,empId
        ,'INR','CRORE'));
        String JSONString = JSON.serialize(ReqParamsData);
        JSONString =JSONString .remove('[');
        JSONString =JSONString .remove(']');
        String JSONFinal = JSONString;
        JSONFinal = JSONFinal.replace('"','\\"');
        JSONFinal  = '"' + JSONFinal + '"';
        JSONString = JSONFinal ;
        system.debug('AUM Chart Request JSONString : '+JSONString );
        req.setBody(JSONString);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res: '+res.getHeader('Location'));
        boolean redirect = false;
        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
            redirect = false; // reset the value each time
            String loc = res.getHeader('Location'); // get location of the redirect
            if(loc == null) {
                redirect = false;
            }
            req = new HttpRequest();
            req.setEndpoint(apiDomain+loc);
            req.setBody(JSONString);
            req.setHeader('userId', apiUser);
            req.setHeader('pwd', apiPass);
            req.setHeader('X-HTTP-Method-Override','PATCH');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('POST'); 
            res = http.send(req);
            if(res.getStatusCode() != 500) { // 500 = fail
                if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                    redirect= true;
                }
            }
        }
        System.debug('response----'+res.getBody());
        String response = res.getBody();
        response = response.removeStart('"');
        response = response.removeEnd('"');
        response = response.remove('\\');
        system.debug('response --'+response );
       // List<Object> objList = (List<Object>)JSON.deSerializeUntyped(res.getBody());
        respList =  (List<ResponseList>)JSON.deserializeStrict(response ,List<ResponseList>.class );
        system.debug('respList : '+respList );
        noDataFound = false;
        if(response == '[]')
        {
            noDataFound = true;
        }else{
            noDataFound = false;
        }
        }catch(Exception e){
            system.debug('E: '+e.getMessage());
        }
    }
    
    // Wrapper class
    public class ResponseList {

        public String TMonth { get; set; }
        public Double AUMValue{ get; set; }

        public ResponseList(String name, Integer data) {
            this.TMonth = name;
            this.AUMValue= data;
        }
    }
    
    //Sub-Lob Wrapper class
    public class SubLobWrapper {

        public Integer GwmOnlineID { get; set; }
        public Integer IsGWMHead{ get; set; }

        public SubLobWrapper(Integer GwmOnlineID, Integer IsGWMHead) {
            this.GwmOnlineID = GwmOnlineID;
            this.IsGWMHead= IsGWMHead;
        }
    }
    //Sublob Wrapper class
    public class SubLobResponseWrapper {

        public Integer Id { get; set; }
        public String name{ get; set; }

        public SubLobResponseWrapper(Integer Id, String name) {
            this.Id = Id;
            this.name= name;
        }
    }
    //FA request Wrapper class
    public class FARequestWrapper {

        public Integer GwmOnlineID { get; set; }
        public Integer IsGWMHead{ get; set; }
        public Integer IsZoneHead{ get; set; }
        public Integer SubLobID{ get; set; }

        
        
        public FARequestWrapper(Integer GwmOnlineID, Integer IsGWMHead,Integer IsZoneHead, Integer SubLobID) {
            this.GwmOnlineID = GwmOnlineID;
            this.IsGWMHead= IsGWMHead;
            this.IsZoneHead = IsZoneHead;
            this.SubLobID= SubLobID;
        }
    }
    //FA Response Wrapper Response class
    public class FAResponseWrapper {

        public Integer MilesID { get; set; }
        public String FAName{ get; set; }

        public FAResponseWrapper(Integer MilesID, String FAName) {
            this.MilesID = MilesID;
            this.FAName= FAName;
        }
    }
}