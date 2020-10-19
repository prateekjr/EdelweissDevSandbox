trigger DocumentChecklist on Document_Checklist__c (after insert, before update) {
	public Id caseId {get;set;}
	public String documentString = '';
	public List<String> requiredDocuments{get;set;}
	for(Document_Checklist__c dc: Trigger.New){
		caseId = dc.Case__c;
		requiredDocuments = dc.Required_Documents__c.split(';');
		break;
	}
	if(caseId != null && requiredDocuments.size() > 0){
		Case cs = [SELECT Id, Document_Checklist__c FROM Case where Id =:caseId limit 1];
    	Integer index = 1;
    	for(String str: requiredDocuments){
    		documentString = documentString + index + '. ' + str + '\r\n';
    		index++;  
    	}
    	cs.Document_Checklist__c = documentString;
    	update cs; 
	}
}