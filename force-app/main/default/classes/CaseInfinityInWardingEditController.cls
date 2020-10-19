public class CaseInfinityInWardingEditController {
    
    
    @AuraEnabled
    public static Case getCaseRecord(string caseId) {
        Case caseRecord;
        if(caseId != null)
        {
            caseRecord =[select id,Client_Lead__c,Lead_Account__c, PAN__c,ClientLead_Name_Display__c, Email__c, Status_of_Corpus__c,Status , Expected_Corpus_Amount__c from case where id= :caseId];  
        }
        if(caseRecord != null)
        {
            return caseRecord;
        }
        return null;
    }
    
    @AuraEnabled
    public static string saveRecord(Case caseRecord) {
        String saveId;
        
        if(caseRecord != null)
        {
            caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Wealth Inwarding').getRecordTypeId();
            Database.SaveResult saveResult = Database.update(caseRecord, false);
            System.debug('Case Record :'+caseRecord);
            
            if (saveResult.isSuccess()) {
                saveId =  saveResult.getId();
            }
            else {
                saveId = 'Error '+saveResult.getErrors();
                
            }
        }
        
        if(saveId!= null){
            return saveId;
        }
        
        return '';
        
    }
    
        
   /* @AuraEnabled
    public static List<String> getPicklistValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    } */
}