public class RiskProfileOfClient {

    public Investment_Policy_Statement_IPS__c ips{get; private set;}
    public Boolean isIndividual{get; private set;}
    public String birthDate{get; private set;}
    public String lastModifiedDate{get; private set;}
    private Id recordId{get; set;}
    
    public RiskProfileOfClient(ApexPages.StandardController stdController) {
		this.recordId = stdController.getId();
        
        setIps();
        setRecordType();
        setBirthDate();
        setLastModifiedDate();
	}

    public void setIps(){
        ips = [SELECT toLabel(Age__c), toLabel(Equity_Markets__c), toLabel(Financial_Goals__c), toLabel(Investment_philosophy__c), 
               toLabel(Investment_goal__c), toLabel(worst_and_best_one_year_return__c), toLabel(Amount_of_fluctuations__c), 
               toLabel(Diversified_portfolio__c), toLabel(Interest_in_leverage_borrowing_products__c), toLabel(Alternative_Investments__c),
               toLabel(Investment_portfolio__c), DateOfBirth__c, LastModifiedDate, RecordType.DeveloperName 
               FROM Investment_Policy_Statement_IPS__c WHERE Id =: recordId];
	}
    
    public void setRecordType(){
        isIndividual = ips.RecordType.DeveloperName == 'Individual' ? true : false;
    }
    
    public void setBirthDate(){
        birthDate = ips.DateOfBirth__c.format();
    }
    
    public void setLastModifiedDate(){
        lastModifiedDate = ips.LastModifiedDate.format('dd/MM/yyyy');
    }
}