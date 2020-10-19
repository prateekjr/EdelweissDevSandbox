public class SubmitForReviewedController {
    public string xmlstring { get; set;}
    public static Map<String, String> mapOfFields = new Map<String, String>();
    public static Id orderId;
    public static Order_ENTRY__c orderEntryRec = new Order_Entry__c();
	@AuraEnabled
    public static Integer setIsSubmitForReviewed(Id recordId){
	 List<Order_Entry__c> orderEntry = [Select Id, Client_Account__c , isReviewed__c,Status__c , Product_Type_Order_Entry__c ,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount__c,Currency__c  from Order_Entry__c where Id =: recordId AND isReviewed__c = false and Status__c='Preview Mode' LIMIT 1];     
        Order_Entry__c orderEntryObj = orderEntry[0];
        if(orderEntryObj != null){
           orderEntry[0].Status__c ='Pending for Review';
        	update orderEntry; 
        } else if(orderEntryObj == null){
            return 3;
        }
		/*if(orderEntryObj.Client_Account__c != null){
			List<Client_Account__c> clientAccountList = [SELECT id  ,Account_Type__c FROM Client_Account__c WHERE id =:orderEntryObj.Client_Account__c LIMIT 1];
			System.debug('Inside Account type' );
			if(clientAccountList!=null && !clientAccountList.isEmpty()) {
				if(clientAccountList[0].Account_Type__c != null){
						if(clientAccountList[0].Account_Type__c.equals('Executionary')){
							Integer responseRec = ReviewedController.setIsReviewed(orderEntryObj.Id);
                            return responseRec;
						}
				}
			
			}
		}*/
        return 2;
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
                         
            if(pName .containsIgnoreCase('Operations')){
                 isValid  = -1;
            }
        }   
        
        return isValid;
    }
}