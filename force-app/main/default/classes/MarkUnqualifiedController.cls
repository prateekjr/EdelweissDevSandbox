public class MarkUnqualifiedController {
    @AuraEnabled
    public static account getAccount(Id recId) {
        return [select Id , How_Often_Does_Client_Monitor_Portfolio__c from Account where id =:recId];
    }
    
    @AuraEnabled
    public static String saveDetails(String recId , Account AccountRec) {
        Account Acc =  [select Id , Reason_For_Disqualification__c , OwnerId , Coverage__c from Account where id =:recId limit 1];
        user pwmUser = [Select Id , Name  FROM User where name like '%PWM SalesForceUpdate%' limit 1];
        if(acc != null && pwmUser != null){
            Acc.Reason_For_Disqualification__c = AccountRec.Reason_For_Disqualification__c;
            Acc.OwnerId = pwmUser.Id;
            acc.Coverage__c = 'Lead Database';
            Database.SaveResult srList = Database.update(acc, false);
            if (srList.isSuccess()) {
                return 'Success';
            }
            else {
                return 'Error';
            }
        }
        return '';
    } 
    
}