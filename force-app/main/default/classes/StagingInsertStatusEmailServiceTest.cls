@isTest
private class StagingInsertStatusEmailServiceTest  {
    
    static testMethod void testHandleEmail() {
    
      // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
      // setup the data for the email
      email.subject = 'Test Job Applicant';
      email.fromname = 'FirstName LastName';
      env.fromAddress = 'someaddress@email.com';
      email.plainTextBody ='ref:Insert Client - false:ref';  
      
      // call the email service class and test it with the data in the testMethod
      StagingInsertStatusEmailService emailProcess = new StagingInsertStatusEmailService ();
      emailProcess .handleInboundEmail(email, env);
      StagingErrorResult__c res = StagingErrorResult__c.getInstance('Insert Client');
      system.assert(res != null);
    
    }

}