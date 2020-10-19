public class DocumentCheckListController{
    public Id caseId{get;set;}
    
    public List<String> getRequiredDocuments(){
        Document_Checklist__c dcl = [SELECT Required_Documents__c FROM Document_Checklist__c where case__c =:caseId limit 1];
        List<String> requiredDocuments = dcl.Required_Documents__c.split(';');
        return requiredDocuments;
    }
}