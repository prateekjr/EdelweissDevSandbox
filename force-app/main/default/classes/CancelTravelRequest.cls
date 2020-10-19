public class CancelTravelRequest {
    
    @AuraEnabled
    public static String cancelTravelRequest(Id recId) {
        String Msg='';
        Travel_Request__c trObj = [SELECT id,Travel_Request_Status__c, From_Date__c FROM Travel_Request__c WHERE id=: recId];
        
        if(trObj!= null){
            Date FromDate = date.newinstance(trObj.From_Date__c.year(), trObj.From_Date__c.month(), trObj.From_Date__c.day());
            if(trObj.Travel_Request_Status__c == 'Initiated'){
                Msg = 'Record is locked. Your Request has been sent for Approval. Ask the Approver to action on the Travel Request.';
                return Msg;
            }else if(FromDate > System.today() && trObj.Travel_Request_Status__c == 'Approved'){
                trObj.Travel_Request_Status__c = 'Cancelled';
                Database.SaveResult sr = Database.update(trObj, false);
                if (sr.isSuccess()) {
                    Msg = 'Your Travel Request has been Cancelled Successfully !!';
                    return Msg;
                }
                else {
                    Msg = 'Error Occured while updating record . Please Contact Administrator !!';
                    return Msg;
                }
            }else if(FromDate <= System.today() && trObj.Travel_Request_Status__c == 'Approved'){
                Msg = 'Travel Request cannot be Cancelled as Date is within the range of Travel Request From Date and To Date.';
                return Msg;
            }else if(trObj.Travel_Request_Status__c=='Rejected'){
                Msg = 'Travel Request cannot be Cancelled as your Travel Request has been Rejected.';
                return Msg;
            }else if(trObj.Travel_Request_Status__c=='Cancelled'){
                Msg = 'Travel Request is already cancelled.';
                return Msg;
            }
            
        }
        return Msg;
    }
}