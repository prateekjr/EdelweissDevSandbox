@istest
public class UserTrigger_Test {

    static testmethod void testUserCreate(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'sta123', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing111', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser111@testorg.com');
        insert u;
    }
}