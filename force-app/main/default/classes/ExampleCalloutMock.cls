@isTest
global class ExampleCalloutMock{// implements HttpCalloutMock{
/*
    global class ListofParams{
    public String TransactionID;
    public boolean isOrderinMiles;
    public Id CaseID;
    public String Status;
    public String Comments;
    
    public ListofParams(String transId, Boolean isMiles, Id cId, String stat, String comment){
        TransactionID = transId;
        isOrderinMiles = isMiles;
        CaseID = cId;
        Status = stat;
        Comments = comment;
    }   
}

    
    
  global HttpResponse respond(HTTPRequest req){
      
      List<ListofParams> CaseParams  = new List<ListofParams>();
    
       HttpResponse res = new HttpResponse();
      
       res.setStatus('OK');
      
       res.setStatusCode(200);
      
        RecordType rt = [Select Id, Name, SobjectType, DeveloperName From RecordType where SobjectType = 'Case' AND Name =: EdelweissConstants.Financial_Transaction];
      
        List<Case> caselist=TestClassutils.createTestCaseForFT();
        Case checkCase=caselist[0];
        checkCase.Status='In Progress';
        checkCase.RecordTypeId=rt.Id;
        insert caselist;
      
       CaseParams.add(new ListofParams(checkCase.Financial_Transaction_Id__c,checkCase.IsOrderInMiles__c,checkCase.Id,checkCase.Status,checkCase.Comments__c));
      
      // CaseParams.add(new ListofParams(null,true,null,'In Progress',null));
      
       String JSONString = JSON.serialize(CaseParams);
    
      system.debug('JSONString========='+JSONString);
    
      req.setBody(JSONString); 

      system.debug(req);
      
     return res;
  }
*/
}