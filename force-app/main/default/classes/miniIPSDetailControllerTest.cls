@istest
public Class miniIPSDetailControllerTest
{

private static testmethod void TestAllMethod()
{
    Account acc= new Account();
    acc.Name ='Sample Test Account';
    acc.Category__c='Individual'; 
	acc.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family'); 
    test.starttest();
    insert acc;
    
    Id getid ;
    getid = acc.Id;
    miniIPSDetailController miniIps= new miniIPSDetailController();
    
    List<Investment_Policy_Statement_IPS__c> lstIPS = [select Id,DateOfBirth__c,entity__c,ResidentialStatus__c,TaxStatusforInvestments__c,
                                                       CurrentInvestableAssets__c,Current_Liabilities__c,Family_Tree__c,Current_Investment_Advisor_s__c,Other_specific_information__c,current_Net_worth__c,
                                                       Direct_equities__c,Fixed_Income__c,Balanced__c,Alternates__c,Real_Estate_Physical__c,Other_Investments_Details__c,
                                                       Housing_Loan__c,Auto_loan__c,Business_Loan__c,Other_loan__c,family_s_annual_income__c,Amount_1__c,Event1__c,Amount_2__c,
                                                       Event2__c,Amount_3__c,what_is_clients_financial_goal__c,client_s_present_investment_pattern__c,current_sources_of_investment_ideas__c,
                                                       wealth_management_requirements__c,Time_horizon_for_clients_financial_goal__c,Equity_Markets__c,Investible_asset__c,
                                                       treasury_management_needs__c,Investment_Banking_requirements__c,Am_I_protected_against_Business_Risks__c,How_often_does_client_monitor_po__c,
                                                       Age__c,Investment_philosophy__c,Investment_goal__c,Financial_Goals__c,worst_and_best_one_year_return__c,performancebenchmarks__c,
                                                       Amount_of_fluctuations__c,Diversified_portfolio__c,Interest_in_leverage_borrowing_products__c,Alternative_Investments__c,
                                                       Investment_portfolio__c,Investment_Style__c,Time_line_for_Trading__c,Stop_Loss__c,Derivative__c,Mutual_Funds__c,GOI_Dated_Securities__c,Treasury_Bills__c,
                                                       GOI_Special_Bonds__c,Gilt_Mutual_Funds__c,State_Development_Loans__c,State_Guaranteed_Papers__c,
                                                       Central_and_State_Gov__c,PSU_and_Private__c,PSU_Bonds__c,Private_Sector_Bonds__c,BASEL_III_Bonds__c,
                                                       Equity_and_Equity_Linked_Mutual_Fund__c,Equity_Shares__c,Equity_Linked_Mutual_Fund__c,Exchange_Traded_Funds__c,Index_Funds__c,
                                                       Asset_Backed_Securities__c,CMBS_RMBS__c,Units_of_REITs__c,Asset_Backed_Securities_chk__c,Units_of_Infra_Inv_Trusts__c,
                                                       other_inputs__c,GOI_Dated_Securities_Per__c,Treasury_Bills_per__c,GOI_Special_Bonds_per__c,State_Development_Loans_per__c,Gilt_Mutual_Fund_Per__c,
                                                       State_Guaranteed_Papers_Per__c,PSU_Bonds_Per__c,PFI_Bonds_Per__c,Private_Sector_Bonds_per__c,BASEL_III_Bonds_Per__c,Debt_Mutual_Funds_Per__c,
                                                       Term_Deposits_of_more_than_1_year_per__c,
                                                       Equity_Shares_per__c,
                                                       Exchange_Traded_Funds_per__c,Index_Funds_per__c,Certificate_of_Deposits_Per__c,Commercial_Papers_per__c,Units_of_Liquid_Mutual_Funds_Per__c,
                                                       Term_Deposits_in_scheduled_commercial_ba__c,CMBS_RMBS_per__c,Units_of_REITs_per__c,Asset_Backed_Securities_per__c,Units_of_Infrastructure_Investment_Trust__c,
                                                       AAA_per__c,AA_Plus_per__c,AA_Per__c,AA_Below_Per__c,Banking_per__c,Finance_Per__c,Power_per__c,Housing_per__c,Manufacturing_Per__c,
                                                       Others_Per__c,GOI_Dated_Securities_Issue_Per__c,Treasury_Bills_issue_per__c,GOI_Special_Bonds_issue_per__c,State_Development_Loans_issue_per__c,
                                                       State_Guaranteed_Papers_issue_Per__c,AAA_Rated_Each_Issuer__c,AA_Plus_Rated_Each_Issuer__c,AA_Rated_Each_Issuer__c,
                                                       Notes_Remarks__c, Term_Deposits_of_more_than_1_year__c,Money_Market__c,Certificate_of_Deposits__c,Commercial_Papers__c,Units_of_Liquid_Mutual_Funds__c
                                                       from Investment_Policy_Statement_IPS__c 
                                                       where Client_Name__c=: acc.Id Limit 1];

    
    Investment_Policy_Statement_IPS__c ipsData = new Investment_Policy_Statement_IPS__c
    (Client_Name__c = acc.Id,entity__c='',ResidentialStatus__c='',TaxStatusforInvestments__c='');
    insert ipsData;
    
    miniIPSDetailController.createRecord(ipsData,false,acc.id);
     
    miniIPSDetailController.updateReviewData(ipsData);
   
    miniIPSDetailController.preValidation(acc.id);
    
    test.stoptest();
} 
}