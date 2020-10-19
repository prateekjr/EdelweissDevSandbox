public class EmailBodyForClientBirthDay {
         
    @InvocableMethod
    public static List<List<string>> getUserRecords(List<List<string>> userIds){
        System.debug('userIds :'+userIds);
        List<user> userRecords = new List<user>();
        List<List<string>> userEmailIds = new List<List<string>>();
        List<string> userEmail= new List<string>();
        if(userIds.size() > 0)
        {
            userRecords = [select id, email from user where id in :userIds[0]];
            for(User us : userRecords)
            {
               userEmail.add(us.email); 
            }
            userEmailIds.add(userEmail);
        }
         System.debug('userEmailIds :'+userEmailIds);
        return userEmailIds;
       
    }
    
}