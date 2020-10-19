public class ContactTriggerHandler{
 
  //Sync Contact Information in Client
     public static void updateAccount(List<Contact> contactList, Map<Id,Contact> OldMapContact){               
        
         system.debug('contactList: '+contactList);
         system.debug('OldMapContact: '+OldMapContact);

        List<Account> listAccountForUpdate = new List<Account>();
         List<Id> ContactIds = New List<Id>();
         for (Contact con : contactList){
             ContactIds.add(con.AccountID);
         } 
         
         List<Account> lstAccount = [Select Id, Primary_Email__c, Secondary_Email__c, Gender__c, Date_of_Birth__c, Phone, Mobile_1__c, Mobile_2__c, Mobile_3__c, Office_Phone_Number__c, Official_Email__c, Official_Address__c, Residence_Address__c, Anniversary_Date__c, Nationality__c From Account Where ID IN : ContactIds ];
         
         system.debug('lstAccount : '+ lstAccount);
         
         Map<Id,Account> accountContactMap =  new Map<Id,Account>();     
         for(Account acc : lstAccount){
            accountContactMap.put(acc.Id,acc); 
         }
         
         for(Contact con : contactList){
             if(accountContactMap.get(con.AccountID) != null){
                 Account acc = accountContactMap.get(con.AccountID);
                 if(OldMapContact.get(con.Id) != null){
                 
                 if(OldMapContact.get(con.Id).Primary_Email__c != con.Primary_Email__c){
                    acc.Primary_Email__c = con.Primary_Email__c ;
                 }
                 if(OldMapContact.get(con.Id).Secondry_Email__c  != con.Secondry_Email__c  ){
                    acc.Secondary_Email__c = con.Secondry_Email__c  ;
                 } 
                 if(OldMapContact.get(con.Id).Gender__c != con.Gender__c){
                    acc.Gender__c = con.Gender__c ;
                 } 
                 if(OldMapContact.get(con.Id).Birth_Date__c != con.Birth_Date__c ){
                    acc.Date_of_Birth__c = con.Birth_Date__c ;
                 } 
                 if(OldMapContact.get(con.Id).MobilePhone!= con.MobilePhone){
                    acc.Phone = con.MobilePhone  ;
                 } 
                 if(OldMapContact.get(con.Id).Mobile_1__c != con.Mobile_1__c){
                    acc.Mobile_1__c = con.Mobile_1__c ;
                 }
                 if(OldMapContact.get(con.Id).Mobile_2__c != con.Mobile_2__c){
                    acc.Mobile_2__c  = con.Mobile_2__c  ;
                 }
                 if(OldMapContact.get(con.ID).Mobile_3__c != con.Mobile_3__c){
                     acc.Mobile_3__c = con.Mobile_3__c;
                 }
                 if(OldMapContact.get(con.Id).Office_Phone__c != con.Office_Phone__c){
                    acc.Office_Phone_Number__c = con.Office_Phone__c;
                 } 
                 if(OldMapContact.get(con.Id).Official_Email__c != con.Official_Email__c){
                    acc.Official_Email__c = con.Official_Email__c ;
                 } 
                 if(OldMapContact.get(con.Id).Official_Address__c != con.Official_Address__c){
                    acc.Official_Address__c = con.Official_Address__c ;
                 }
                 if(OldMapContact.get(con.Id).Residence_Address__c != con.Residence_Address__c){
                    acc.Residence_Address__c = con.Residence_Address__c  ;
                 }
                 if(OldMapContact.get(con.Id).Wedding_Anniversary__c != con.Wedding_Anniversary__c ){
                    acc.Anniversary_Date__c = con.Wedding_Anniversary__c ;
                 } 
                 if(OldMapContact.get(con.Id).Nationality__c != con.Nationality__c){
                    acc.Nationality__c = con.Nationality__c  ;
                 }
                }
                 acc.Contact_Creation_DateTime__c = datetime.now().getTime();
               listAccountForUpdate.add(acc);
             }
         }
        
         AccountTriggerhandler.stopAccountTrigger = true;
         AccountTriggerhandler.stopUpdatefamily = true;
         AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
        system.debug('listAccountForUpdate----: '+listAccountForUpdate);
        try{
        update listAccountForUpdate; 
        }catch(Exception e)
        {
           system.debug('e.getMessage()----: '+e.getMessage());
           if(e.getMessage().contains('DUPLICATES_DETECTED'))
            {                
                for (Contact con : contactList){
                     con.addError('It looks like you are creating a duplicate Account. We recommend you use an existing Account instead.');
                 } 
                //e.setMessage('It looks like you are creating a duplicate Account. We recommend you use an existing Account instead.');
            }
        }
    }
}