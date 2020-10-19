public without sharing class MaskDND {
    
    @AuraEnabled
    public static String maskDNDByCXO(Id recId) {
        String Msg = '';
        Account Acc = [SELECT Id , DND__c , RecordType.Name, DNDNotificationFlag__c FROM Account WHERE id =: recId];
        User userObj = [SELECT Id , Profile.Name FROM USER WHERE id =: UserInfo.getUserId()];
        System.debug('userObj.Profile.Name'+userObj.Profile.Name);
        if(Acc != null && userObj != null && Acc.RecordType.Name == 'Client'){
            if(userObj.Profile.Name.contains('Client Experience Office')){
                if(Acc.DND__c){
                    Acc.DND__c = false;
                    Acc.DNDNotificationFlag__c = 'False';
                }else{
                    Acc.DND__c = true;
                    Acc.DNDNotificationFlag__c = 'True';
                }
                Database.SaveResult sr = Database.update(Acc, false);
                if (sr.isSuccess()) {
                    Msg = 'Record Successfully updated !!';
                    return Msg;
                }
                else {
                    Msg = 'Error Occured while updating record . Please Contact Administrator !!';
                     return Msg;
                }
            }else{
                Msg = 'Error Occurred while updating record. Only CXO have Access for Marking DND.';
                 return Msg;
            }
        }
        return Msg;
    }
}