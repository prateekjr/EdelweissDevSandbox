@istest
public class Edelweiss_travelRequestTriggerTest {

    
    public static testmethod void Edelweiss_travelRequestTriggerTest()
    {
        List<Travel_Request__c> trList = new List<Travel_Request__c>();
        TravelRequestTriggerHandler tr = new TravelRequestTriggerHandler();
        Travel_Request__c trObj = new Travel_Request__c();
        trObj.OwnerId = UserInfo.getUserId();
        trobj.Actual_Cost_In_Rs__c = 50.00;
        trList.add(trObj);
        insert(trList);
        TravelRequestTriggerHandler.validateData(trList);
        /*TestClassUtils.InsertSysProperties();
       
        RecordType rt = [Select Id, Name, SobjectType, DeveloperName From RecordType where SobjectType = 'Case' AND Name =: EdelweissConstants.Financial_Transaction];
        List<Lead> lstLead = TestClassUtils.createLead();
        lstLead[0].status ='R2';
        insert lstLead ;
        List<Case> caselist=TestClassutils.createTestCaseForFT();
        Case c=caselist[0];
        c.Status='In Progress';
        c.Lead__c = lstLead[0].id;
        c.RecordTypeId=rt.Id;
        
        insert caselist;
        
        System.debug(c.Status+' log '+c.Case_Type__c);
        
        Edelweiss_batchCaseUpdate obj=new Edelweiss_batchCaseUpdate();
        
      
        
        //Test.startTest();
        //Test.isRunningTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNew());
        Database.executeBatch(obj);
        Test.stopTest();*/
        

}
    
    
    
    
    
    
}