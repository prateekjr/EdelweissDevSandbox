public class InvestmentPolicyStatement {

    public Investment_Policy_Statement_IPS__c ips{get; private set;}
    //public Investment_Policy_Statement_IPS__c ipsPicklist{get; private set;}
    public Boolean isIndividual{get; private set;}
    private Id recordId{get; set;}
    public String birthDate{get; private set;}
    public String lastModifiedDate{get; private set;}
    public List<String> wealthManagementRequirements{get; private set;}
    public List<String> financialGoal{get; private set;}
    public List<String> investmentPattern{get; private set;}
    public List<String> sourcesOfInvestmentIdeas{get; private set;}
    public List<String> treasuryManagementNeeds{get; private set;}
    public List<String> investmentBanking{get; private set;}
    public List<String> realEstate{get; private set;}
    public List<String> businessRisks{get; private set;}
    
    public InvestmentPolicyStatement(ApexPages.StandardController stdController) {
        this.recordId = stdController.getId();
        //ipsPicklist = (Investment_Policy_Statement_IPS__c)stdController.getRecord();
        wealthManagementRequirements = new List<String>();
        financialGoal = new List<String>();
        investmentPattern = new List<String>();
        sourcesOfInvestmentIdeas = new List<String>();
        treasuryManagementNeeds = new List<String>();
        investmentBanking = new List<String>();
        realEstate = new List<String>();
        businessRisks = new List<String>();
        
        setIps();
        setRecordType();
        setWealthManagementRequirements();
        setFinancialGoal();
        setInvestmentPattern();
        setSourcesOfInvestmentIdeas();
        setTreasuryManagementNeeds();
        setInvestmentBanking();
        setRealEstate();
        setBusinessRisks();        
		setBirthDate();        
        setLastModifiedDate();
    }

    public void setIps(){
        ips = [SELECT toLabel(Age__c), toLabel(Financial_Goals__c), toLabel(Investment_philosophy__c), toLabel(Investment_goal__c), 
           toLabel(worst_and_best_one_year_return__c), toLabel(Amount_of_fluctuations__c), toLabel(Diversified_portfolio__c), 
           toLabel(Interest_in_leverage_borrowing_products__c), toLabel(Alternative_Investments__c), toLabel(Investment_portfolio__c), 
           toLabel(Equity_Markets__c), wealth_management_requirements__c, what_is_clients_financial_goal__c, client_s_present_investment_pattern__c, 
           current_sources_of_investment_ideas__c, treasury_management_needs__c, Investment_Banking_requirements__c, 
           What_are_real_estate_requirements__c, Am_I_protected_against_Business_Risks__c, DateOfBirth__c, LastModifiedDate, 
           RecordType.DeveloperName FROM Investment_Policy_Statement_IPS__c WHERE Id =: recordId];
    }
    
    public void setRecordType(){
        isIndividual = ips.RecordType.DeveloperName == 'Individual' ? true : false;
    }
    
    public void setWealthManagementRequirements(){
        if(ips.wealth_management_requirements__c != NULL)
            wealthManagementRequirements.addAll(ips.wealth_management_requirements__c.split(';'));
    }
    
    public void setFinancialGoal(){
        if(ips.what_is_clients_financial_goal__c != NULL)
            financialGoal.addAll(ips.what_is_clients_financial_goal__c.split(';'));
    }
    
    public void setInvestmentPattern(){
        if(ips.client_s_present_investment_pattern__c != NULL)
            investmentPattern.addAll(ips.client_s_present_investment_pattern__c.split(';'));
    }
    
    public void setSourcesOfInvestmentIdeas(){
        if(ips.current_sources_of_investment_ideas__c != NULL)
            sourcesOfInvestmentIdeas.addAll(ips.current_sources_of_investment_ideas__c.split(';'));
    }
    
    public void setTreasuryManagementNeeds(){
        if(ips.treasury_management_needs__c != NULL)
            treasuryManagementNeeds.addAll(ips.treasury_management_needs__c.split(';'));
    }
    
    public void setInvestmentBanking(){
        if(ips.Investment_Banking_requirements__c != NULL)
            investmentBanking.addAll(ips.Investment_Banking_requirements__c.split(';'));
    }
    
    public void setRealEstate(){
        if(ips.What_are_real_estate_requirements__c != NULL)
            realEstate.addAll(ips.What_are_real_estate_requirements__c.split(';'));
    }
    
    public void setBusinessRisks(){
        if(ips.Am_I_protected_against_Business_Risks__c != NULL)
            businessRisks.addAll(ips.Am_I_protected_against_Business_Risks__c.split(';'));
    }
    
    public void setBirthDate(){
        if(ips.DateOfBirth__c != null)
        birthDate = ips.DateOfBirth__c.format();
    }    
    
    public void setLastModifiedDate(){
        if(ips.LastModifiedDate != null)
        lastModifiedDate = ips.LastModifiedDate.format('dd/MM/yyyy');
    }
}