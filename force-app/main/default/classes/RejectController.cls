public class RejectController {
    //public string xmlstring { get; set;}
    public static Map<String, String> mapOfFields = new Map<String, String>();
    public static Id orderId;
    public static Order_ENTRY__c orderEntryRec = new Order_Entry__c();
	@AuraEnabled
    public static Integer setIsRejected(Id recordId){
     Integer flag;
        //added isFundTransfered__c in the Query :- BY RAJVARDHAN
	 //List<Order_Entry__c> orderEntry = [Select Id, isReviewed__c,Status__c , Product_Type_Order_Entry__c ,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount__c,Currency__c  from Order_Entry__c where Id =: recordId AND isReviewed__c = true LIMIT 1];     
	 List<Order_Entry__c> orderEntry = [Select Id, isReviewed__c,Status__c , Product_Type_Order_Entry__c ,isFundTransfered__c,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount__c,Currency__c  from Order_Entry__c where Id =: recordId AND status__c !='Rejected' LIMIT 1];     
         if(orderEntry.size() == 0){
            flag = 0;
        } else if(!orderEntry[0].Status__c.equals('Pending For Review')){
            flag = -1;
            //ADDED BY RAJVARDHAN
        } else if(orderEntry[0].isFundTransfered__c == true ){
            flag = 2;
        }else {
            flag = 1;
            orderEntry[0].Status__c ='Rejected';
            
            update orderEntry;      
        }
        return flag;
    } 
     @AuraEnabled
    public static Integer checkForProfile(){
    	Integer isValid = 1;
        string pName ;
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            pName =  currentUser.Profile.Name;
            system.debug('pName--'+pName);              
            if(pName .containsIgnoreCase('Client Experience Office (CXO)')){
                 isValid  = -1;
            }
        }        
        return isValid;
    }
}