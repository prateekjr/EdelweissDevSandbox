public without sharing class riskProfileMiniIPS1{
    @AuraEnabled
    public static String saveDetails(Id recordId , Investment_Policy_Statement_IPS__c IPSRecordObj) {
        System.debug('######recordId'+recordId);
        System.debug('######IPSRecordObj'+IPSRecordObj);
        List<Task> caseId = [select whatid from Task where Id=:recordId Limit 1];
        Id caseRecordId = caseId[0].whatId;
        list<case> caselist =  [select Id,Account.id,Account.Category__c from case where Id=:caseRecordId Limit 1];
       	if(IPSRecordObj != null && caselist != null && caselist.size() > 0){
            IPSRecordObj.Client_Name__c = caselist[0].Account.id;          
            
            if(IPSRecordObj.Id == null){
                Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Investment_Policy_Statement_IPS__c').getDescribe();
                List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
                Map<String,Id> mapofIPSRecordTypeNameandId = new Map<String,Id>();
                for(Schema.RecordTypeInfo info : recordTypeInfo){
                    mapofIPSRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
                }
                if(caselist[0].Account.Category__c == 'Corporate')
                {
                    IPSRecordObj.RecordTypeId = mapofIPSRecordTypeNameandId.get('Corporate');
                }else{
                    IPSRecordObj.RecordTypeId = mapofIPSRecordTypeNameandId.get('Individual'); 
                }                
            }            
            database.upsert(IPSRecordObj);
        }
        List<Id> lstAccIds=  new List<Id>();
        List<DateTime> lstCreatedDate = new List<DateTime>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        
        lstAccIds.add(IPSRecordObj.Client_Name__c);
        lstCreatedDate.add(IPSRecordObj.CreatedDate);
        accountMap = new map<Id,Account>([Select Id,IPS_Creation_DateTime__c, IsFilled_MINIIPS__c,MINIIPS_Creation_Date__c From Account Where Id In : lstAccIds]);
        
        Account acc = accountMap.get(IPSRecordObj.Client_Name__c);
        if(!(lstCreatedDate.isEmpty()) && IPSRecordObj != null)
        {
            //acc.IsFilled_MINIIPS__c = True;
            acc.MINIIPS_Creation_Date__c = date.today();//datetime.now();
            acc.IsFilled_MINIIPS__c = True;
            acc.IPS_Creation_DateTime__c = datetime.now().getTime();
            accountMap.put(acc.id, acc);
            
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            if(accountMap.values().size() > 0)
        	{
                 database.upsert(accountMap.values());
            }
        	}
        
        return 's';
    }
    
    @AuraEnabled
    public static Map<string,Object> getIPSData(Id IpsrecordId) 
    {
        System.debug('Inside Get IPS id = '+ IpsrecordId);
        List<Task> taskId = [select whatid ,subject from Task where Id=:IpsrecordId Limit 1];
        Id caseRecordId = taskId[0].whatId;
        System.debug('Case Id'+ caseRecordId);
        Map<string,Object> returnMap = new Map<string,Object>();
        list<case> caselist =  [select Id,Account.id,Account.Category__c from case where Id=:caseRecordId Limit 1];
        Id accId = caselist[0].Account.id;
         System.debug('Account ID'+ caseRecordId);
        List<Investment_Policy_Statement_IPS__c> lstIPS = [select Id,Name,Current_Investment_Advisors__c,LastModifiedDate,DateOfBirth__c,entity__c,ResidentialStatus__c,TaxStatusforInvestments__c,
                                                       CurrentInvestableAssets__c,Current_Liabilities__c,Family_Tree__c,Current_Investment_Advisor_s__c,Other_specific_information__c,current_Net_worth__c,
                                                       Direct_equities__c,Direct_Equity__c,Fixed_Income__c,Balanced__c,Alternates__c,Real_Estate_Physical__c,Other_Investments_Details__c,Liabilities__c,
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
                                                       where Client_Name__c=: accId Limit 1];
        System.debug('######'+lstIPS);
        if(caselist != null && taskId !=null){
           returnMap.put('CaseRecord',caselist[0]);  
           returnMap.put('subject',taskId[0].subject);
          }
        if(lstIPS != null && lstIPS.size() >0)
        {        
            returnMap.put('IPSRecord',lstIPS[0]);
        }
         System.debug('###### returnMap'+returnMap);
        return returnMap;
    }
 
    
}