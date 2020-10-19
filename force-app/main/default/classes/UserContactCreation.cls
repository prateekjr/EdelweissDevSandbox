public class UserContactCreation {

    @future
    public static void createContact(List<String> listOfUsersString) {
     List<user> listOfusers = new list<User>();
     Map<String,User> listOfUsersMap= new Map<String,User>();
      User u1 = new User();
     for (String ser : listOfUsersString)
     { 
         listOfusers.add((User) JSON.deserialize(ser,User.Class));
     }
     
        
        System.debug('List Of sersssssssssss ###'+listOfusers);
        Id leadRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
        Id ContactRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Edelweiss User').getRecordTypeId();
    
        //Create Edelweiss User Contact Account
        List<Account> lstAccount = [
            SELECT Id, Name FROM Account WHERE Name='Edelweiss User Contact Account' AND RecordTypeId = :leadRecordTypeId LIMIT 1
        ]; 
        
        IF(lstAccount.isEmpty()){
            Account objAcc = new Account(Name='Edelweiss User Contact Account', RecordTypeId = leadRecordTypeId, Company__c = 'Don\'t delete this account. This account is being used for Edelweiss User Contacts.');
            lstAccount.add(objAcc);
            insert lstAccount;
        }
        
       //Delete existing Edelwies User contact
        List<Contact> lstExistingContact = [
            SELECT Id, Name,FirstName,LastName FROM Contact WHERE RecordTypeId=:ContactRecordTypeId
        ];
        
        Map<String,Contact> MapContact = new Map<String,Contact>();
        
        for(Contact cntRec : lstExistingContact){
            MapContact.put(cntRec.FirstName+cntRec.LastName,cntRec);
        }
        
        //Create new Edelweiss User contact for active users
        List<Contact> lstContact = new List<Contact>();
        
        
        for(User objUser : listOfusers){
            if(MapContact != null && !MapContact.containsKey(objUser.FirstName+objUser.LastName)){
                System.debug('objUser.Email <><>< '+objUser.Email);
                System.debug('objUser.Email <><>< '+objUser.LastName);
                Contact objContact = new Contact();
                objContact.RecordTypeId = ContactRecordTypeId;
                objContact.OwnerId = objUser.Id;
                objContact.FirstName = objUser.FirstName;
                objContact.LastName = objUser.LastName;
                objContact.Email = objUser.Email;
                objContact.AccountId = lstAccount[0].Id;
                
                lstContact.add(objContact);
            }
        }
        if(!lstContact.isEmpty()){
            System.debug('Contact Inserted <><>< '+lstContact);
            database.insert(lstContact,true);
        }
    }
}