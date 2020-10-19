public class MOUIPojo {
    public string test;
    public String MAIN_LEAD;
    public String SUB_LEAD;
    public Integer ENTITY_TYPE;    
    public String PRODUCT_TYPE;    
    public String CONTACT_NUMBER;   
    public String EMAIL_ID; 
    public String PAN_NUMBER;  
    public String AADHAR_NUMBER;  
    public Date DOB_DOI;  
    public String CIN_NUMBER;
    public Double DELIVERY_SLAB_CASH;
    public Double DELIVERY_CASH_MIN;
    public String DELIVERY_SLAB_CASH_SIDES;
    
    public Double INTRADAY_SLAB_CASH;
    public Double INTRADAY_CASH_MIN;
    public String INTRADAY_SLAB_CASH_SIDES;
    
    public Double CURRENCY_FUTURES_SLAB;
    public Double CURRENY_FUTURES_MIN;
    public String CURRENCY_FUTURES_SIDES;
    
    public Double CURRENY_OPTIONS_SLAB;
    public Double CURRENCY_OPTIONS_MIN;
    public String CURRENCY_OPTIONS_SIDES;
    
    public Double DERIVATIVES_FUTURES_SLAB;
    public Double DERIVATIVES_FUTURES_MIN;
    public String DERIVATIVES_FUTURES_SIDES;    
    
    public Double DERIVATIVES_OPTIONS_SLAB;
    public Double DERIVATIVES_OPTIONS_MIN;
    public String DERIVATIVES_OPTIONS_SIDES;    
    
    public String JOINT_ACCT_HOLDER1_NAME;  
    public String JOINT_ACCT_HOLDER1_CONTACT;  
    public String JOINT_ACCT_HOLDER1_EMAIL;     
    public String JOINT_ACCT_HOLDER1_PAN;  
    public String JOINT_ACCT_HOLDER1_AADHAR;  
    public Date JOINT_ACCT_HOLDER1_DOB_DOI; 
    public String JOINT_ACCT_HOLDER2_NAME;  
    public String JOINT_ACCT_HOLDER2_CONTACT;  
    public String JOINT_ACCT_HOLDER2_EMAIL;     
    public String JOINT_ACCT_HOLDER2_PAN;  
    public String JOINT_ACCT_HOLDER2_AADHAR;  
    public Date JOINT_ACCT_HOLDER2_DOB_DOI;     
    
    public String SYSTEM_ID;     
    public String CASE_NO;
    public String CRM_CLIENT_CODE;
    public String CLIENT_NAME;
    public String INVESTOR_TYPE;
    public String ADDRESS_1;
    public String ADDRESS_2; 
    public String ADDRESS_3;     
    public String COUNTRY_NAME;
    public String STATE_NAME;
    public String CITY;
    public String COUNTRY_CODE;
    public String STATE_CODE;
    public String PINCODE;
    public String ACCOUNT_NAME;    
    public String SALES_RM_NAME;
    public Integer SALES_RM_CODE;
    public String SINGLE_JOINT_HOLDER;     
    public String FAMILY_NAME;
    public Integer FAMILY_CODE;
    public String REG_NUMBER;
    
    //Adding Family Head Details
    public String FAMILY_HEAD_ID;
    public String FAMILY_HEAD_NAME;
    public String FAMILY_HEAD_PAN;
    
    //Adding RiskProfiler Details
    public String Q_INVESTMENT_PHILOSOPHY ;
    public String Q_EQUITY_MARKETS ;
    public String Q_AGE ;
    public String Q_INVESTMENT_GOAL ;
    public String Q_FINANCIAL_GOALS ;
    public String Q_WORST_AND_BEST_ONE_YEAR_RETURN ;
    public String Q_AMOUNT_OF_FLUCTUATIONS ;
    public String Q_DIVERSIFIED_PORTFOLIO ;
    public String Q_INTEREST_IN_LEVERAGE_BORROWING_PRODUCTS ;
    public String Q_ALTERNATIVE_INVESTMENTS ;
    public String Q_INVESTMENT_PORTFOLIO ;
    public String Q_INVESTMENT_STYLE ;
    public String Q_TIME_LINE_FOR_TRADING ;
    public String Q_RISK_PROFILE_CATEGORIES ;
    
    public List<RiskProfilePojo> List_Risk_Profile = new List<RiskProfilePojo>();
    
    
}