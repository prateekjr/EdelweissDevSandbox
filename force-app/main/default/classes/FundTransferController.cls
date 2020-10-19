public class FundTransferController {
    
    @AuraEnabled
    public static void setIsFundTransfered(Id recordId){
     List<Order_Entry__c> orderEntry = [Select Id, isReviewed__c,Status__c , Product_Type_Order_Entry__c ,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount__c,Currency__c,isFundTransfered__c  from Order_Entry__c where Id =: recordId and isFundTransfered__c=false  LIMIT 1];     
         orderEntry[0].isFundTransfered__c = true;
        update orderEntry[0];
    } 

}