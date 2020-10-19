global class Edelweiss_batchCaseUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts{

global Database.QueryLocator start(Database.BatchableContext BC)
{
    String query = 'Select Id, Financial_Transaction_Id__c,Product_Type__c, IsOrderInMiles__c, Case_Type__c, Status, Comments__c from Case where Status != \'Closed – Success\' and Status != \'Closed – Rejected\' and Case_Type__c = \'Financial Transaction\'';
    return Database.getQueryLocator(query);
}

global class ListofParams{
    public Integer TransactionID;
    public Id CaseID;
    public Integer Status;
    public String Comments;
    public String productType;
    public String systemName;
    
    public ListofParams(Integer transId, Boolean isMiles, Id cId, Integer stat, String comment,String productType){
        TransactionID = transId;
        CaseID = cId;
        Status = stat;
        Comments = comment;
        this.productType = productType;
        systemName = 'MILES';
        if(!isMiles){
            systemName = 'TT';
        }
    }   
}

global void execute(Database.BatchableContext BC, List<sObject> scope)
{

    Sys_Properties__c FinancialTransactionURL= Sys_Properties__c.getValues('FinancialTransactionURL');
        Sys_Properties__c FianancialTransactionUser= Sys_Properties__c.getValues('FianancialTransactionUser');
        Sys_Properties__c FinancialTransactionPass= Sys_Properties__c.getValues('FinancialTransactionPass');
        Sys_Properties__c FianancialTransactionDomain= Sys_Properties__c.getValues('FianancialTransactionDomain');
         
        String apiUrl = FinancialTransactionURL.Value__c;
        String  apiUser = FianancialTransactionUser.Value__c;
        String  apiPass = FinancialTransactionPass.Value__c;
        String  apiDomain = FianancialTransactionDomain.Value__c;
    List<Case> Cases = (List<case>)scope;
    List<Case> updateCases = new List<Case>();
    List<ListofParams> CaseParams  = new List<ListofParams>();
    Map<Id, Case> IdRecMap = new Map<Id,Case>();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(apiUrl);
    req.setHeader('userId', apiUser);
    req.setHeader('pwd', apiPass);
    req.setHeader('Content-Type', 'application/json');
    req.setTimeout(120000);
    req.setMethod('POST');  
    for (Case checkCase : Cases){
        Integer transactId;
        if(!String.isEmpty(checkCase.Financial_Transaction_Id__c) && checkCase.Financial_Transaction_Id__c.isNumeric()){
            transactId = Integer.valueOf(checkCase.Financial_Transaction_Id__c);
            CaseParams.add(new ListofParams(transactId ,checkCase.IsOrderInMiles__c,checkCase.Id,0,'',checkCase.Product_Type__c));
            IdRecMap.put(checkCase.Id,checkCase);
        }
        
    } 
    String JSONString = JSON.serialize(CaseParams); 
    String JSONFinal = JSONString;
    JSONFinal = JSONFinal.replace('"','\\"');
    JSONFinal  = '"' + JSONFinal + '"';
    JSONString = JSONFinal ;
    system.debug('JSONString========='+JSONString);
    req.setBody(JSONString);
    Http http = new Http();
    HTTPResponse res = http.send(req);
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
    
    String response = res.getBody();
    if(response != null){
    System.debug(res.getBody());
    response = response.removeStart('"');
    response = response.removeEnd('"');
    response = response.remove('\\');
    system.debug('response --'+response );
   // List<Object> objList = (List<Object>)JSON.deSerializeUntyped(res.getBody());
    List<ListofParams> responseList =  (List<ListofParams>)JSON.deserializeStrict(response ,List<ListofParams>.class );
    system.debug('respList : '+responseList );
    for(ListofParams responseKey : responseList)
    {
        Case caseRec = IdRecMap.get(responseKey.CaseID);
        if(responseKey.status == 1){
            caseRec.Status = 'Closed – Rejected';
        }else if(responseKey.status == 2){
            caseRec.Status = 'Closed – Success';
        }
        
        caseRec.Comments__c = responseKey.Comments;
        updateCases.add(caseRec);
    }

    update updateCases;
} 
}
global void finish(Database.BatchableContext BC)
{
    //Send email notification
}

}