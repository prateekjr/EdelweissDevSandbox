public class SummaryIPS {

    public Investment_Policy_Statement_IPS__c ips{get; private set;}
	public String lastModifiedDate{get; private set;}
    private Id recordId{get; set;}
    
    public SummaryIPS(ApexPages.StandardController stdController) {
		this.recordId = stdController.getId();
        
        setIps();
        setLastModifiedDate();
	}

    public void setIps(){
        ips = [SELECT toLabel(Financial_Goals__c), LastModifiedDate FROM Investment_Policy_Statement_IPS__c WHERE Id =: recordId];
	}
    
    public void setLastModifiedDate(){
        lastModifiedDate = ips.LastModifiedDate.format('dd/MM/yyyy');
    }

}