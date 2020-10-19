({
    doInit: function(component, event, helper) 
    { 
		var recordId = component.get("v.recordId");        
        
        if(component.get("v.recordId") != '' && component.get("v.recordId") != null)
        {
            var action = component.get("c.preValidation");  //component.get("c.getAccount");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) 
            {
                var strError = response.getReturnValue();
                if (strError=== "Success")
                {
                    helper.getAccount(component, event, helper);
                }
                else{
                    var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'message': strError,
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action); 
        }
        if(component.get("v.recordId") != '' && component.get("v.recordId") != null)
        {
            var action1 = component.get("c.getIPSData");
            action1.setParams({
                IpsrecordId :component.get("v.recordId")
            });
            action1.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS")
                {
                    component.set("v.IPSRecord",response.getReturnValue());
                    var record = response.getReturnValue();
                    if(record.Id == null){
                        component.set("v.isNewIPS",true)
                    }
                }
                else if (state === "ERROR") 
                {
                	var errors = response.getError();
                	if (errors) {  
                    	if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
							var errorMessage = errors[0].pageErrors[0].message;
							var showToast = $A.get('e.force:showToast');
                            showToast.setParams({ 
                                'title': "Error!",
                                'message': errorMessage,
                                'type': 'error'
                            });
							showToast.fire();
                    	}
                        else if(errors[0] && errors[0].fieldErrors)
                        {
                        	for (var key in errors[0].fieldErrors)
                            {
                            	if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0])
                                {                               
                                	var showToast = $A.get('e.force:showToast');
                                    showToast.setParams({ 
                                        'title': "Error!",
                                        'message': errors[0].fieldErrors[key][0].message,
                                        'type': 'error'
                                    });
                                    showToast.fire();									
                            	}
                        	}                       
                    	}
                	} 
            	}
            });
                $A.enqueueAction(action1); 
        }
	},
    save: function(component, event, helper)
    {
        var editedPSRecord = component.get("v.IPSRecord");
        var accRecord = component.get("v.account");
        editedPSRecord.Client_Name__c = accRecord.Id;
        editedPSRecord.DateOfBirth__c = component.find("birthdate").get("v.value");
        editedPSRecord.Name = component.find("IPSNumber").get("v.value");
        editedPSRecord.LastModifiedDate = component.find("LastModifieddate").get("v.value");
        editedPSRecord.entity__c = component.find("entity").get("v.value");
        
        editedPSRecord.ResidentialStatus__c = component.find("Status").get("v.value");
        editedPSRecord.TaxStatusforInvestments__c = component.find("TaxStatus").get("v.value");
        
        //editedPSRecord.CurrentInvestableAssets__c = component.find("InvestableAssets").get("v.value");
        //editedPSRecord.Current_Liabilities__c = component.find("CurrentLiabilities").get("v.value");
        editedPSRecord.Direct_equities__c = component.find("DirectEquity").get("v.value");
        editedPSRecord.current_Net_worth__c = component.find("currentNetworth").get("v.value");
        //editedPSRecord.Direct_Equity__c = component.find("Direct_Equity").get("v.value");
        editedPSRecord.Balanced__c = component.find("Balanced").get("v.value");
        editedPSRecord.Alternates__c = component.find("Alternates").get("v.value");
        editedPSRecord.Real_Estate_Physical__c = component.find("RealEstatePhysical").get("v.value");
        editedPSRecord.Other_Investments_Details__c = component.find("OtherInvestments").get("v.value");
        editedPSRecord.Liabilities__c = component.find("Liabilities").get("v.value");
        editedPSRecord.Housing_Loan__c = component.find("HousingLoan").get("v.value");
        editedPSRecord.Auto_loan__c = component.find("AutoLoan").get("v.value");
        editedPSRecord.Business_Loan__c = component.find("BusinessLoan").get("v.value");
        editedPSRecord.Other_loan__c = component.find("Otherloan").get("v.value");
        
        editedPSRecord.wealth_management_requirements__c = component.find("Selectwealth").get("v.value");
        editedPSRecord.Time_horizon_for_clients_financial_goal__c = component.find("Selecttimehorizon").get("v.value");
         
        editedPSRecord.treasury_management_needs__c = component.find("Selecttreasury").get("v.value");
        editedPSRecord.Investment_Banking_requirements__c = component.find("investBank").get("v.value");
        editedPSRecord.Am_I_protected_against_Business_Risks__c = component.find("BusinessRisks").get("v.value");
        
       //editedPSRecord.Equity_Markets__c = component.find("EquityMarkets").get("v.value");
		//editedPSRecord.Age__c = component.find("Age").get("v.value");
        //editedPSRecord.Investment_philosophy__c = component.find("investmentphilosophy").get("v.value");
        //editedPSRecord.Financial_Goals__c = component.find("FinancialGoals").get("v.value");
       // editedPSRecord.worst_and_best_one_year_return__c = component.find("worstbestreturn").get("v.value");
       // editedPSRecord.Amount_of_fluctuations__c = component.find("amountoffluctuations").get("v.value");

       // editedPSRecord.Diversified_portfolio__c = component.find("diversifiedportfolio").get("v.value");
        //editedPSRecord.Interest_in_leverage_borrowing_products__c = component.find("leverageborrowingproducts").get("v.value");
        //editedPSRecord.Alternative_Investments__c = component.find("AlternativeInvestments").get("v.value");
       // editedPSRecord.Investment_portfolio__c = component.find("investmentportfolio").get("v.value");
       // editedPSRecord.Investment_Style__c = component.find("InvestmentStyle").get("v.value");
        //editedPSRecord.Time_line_for_Trading__c = component.find("Trading").get("v.value");
        
        editedPSRecord.GOI_Dated_Securities__c = component.find("ChkGOIDatedSecurities").get("v.value");
        editedPSRecord.Treasury_Bills__c = component.find("ChkTreasuryBills").get("v.value");
        editedPSRecord.GOI_Special_Bonds__c = component.find("ChkGOISpecialBonds").get("v.value");
        editedPSRecord.Gilt_Mutual_Funds__c = component.find("ChkGiltMutualFund").get("v.value");
        editedPSRecord.State_Development_Loans__c = component.find("ChkStateDevelopmentLoans").get("v.value");
        editedPSRecord.State_Guaranteed_Papers__c = component.find("ChkStateGuaranteedPapers").get("v.value");
        
        editedPSRecord.PSU_Bonds__c = component.find("ChkPSUBonds").get("v.value");
        editedPSRecord.PFI_Bonds__c = component.find("ChkPFIBonds").get("v.value");
        editedPSRecord.Private_Sector_Bonds__c = component.find("ChkPrivateSectorBonds").get("v.value");
        editedPSRecord.BASEL_III_Bonds__c = component.find("ChkBASELIIIBonds").get("v.value");
        editedPSRecord.Term_Deposits_of_more_than_1_year__c = component.find("ChkTermDeposits").get("v.value");
        
        editedPSRecord.Certificate_of_Deposits__c = component.find("ChkCertificateDeposits").get("v.value");
        editedPSRecord.Commercial_Papers__c = component.find("ChkCommercialPapers").get("v.value");
        editedPSRecord.Units_of_Liquid_Mutual_Funds__c = component.find("ChkLiquidMutualFunds").get("v.value");
        editedPSRecord.Term_Deposit_in_scheduled_commrcial_bank__c = component.find("ChkTermDepositsbank").get("v.value");
        
        editedPSRecord.Equity_Shares__c = component.find("ChkEquitShares").get("v.value");
        editedPSRecord.Equity_Linked_Mutual_Fund__c = component.find("ChkEquityLinkedMutualFund").get("v.value");
        editedPSRecord.Exchange_Traded_Funds__c = component.find("ChkExchangeTradedFunds").get("v.value");
        editedPSRecord.Index_Funds__c = component.find("ChkIndexFunds").get("v.value");
        
        editedPSRecord.CMBS_RMBS__c = component.find("ChkCMBSRMBS").get("v.value");
        editedPSRecord.Units_of_REITs__c = component.find("ChkUnitsofREITs").get("v.value");
        editedPSRecord.Asset_Backed_Securities_chk__c = component.find("ChkAssetBackedSecurities").get("v.value");
        editedPSRecord.Units_of_Infra_Inv_Trusts__c = component.find("ChkInfraindex").get("v.value");
		       
        //editedPSRecord.Debt_Mutual_Funds_Per__c = component.find("DebtMutualFunds").get("v.value");
        editedPSRecord.Term_Deposits_of_more_than_1_year_per__c = component.find("TermDepositsone").get("v.value");
        editedPSRecord.Certificate_of_Deposits_Per__c = component.find("CertificateDeposits").get("v.value");
        editedPSRecord.Commercial_Papers_per__c = component.find("CommercialPapers").get("v.value");
        editedPSRecord.Units_of_Liquid_Mutual_Funds_Per__c = component.find("LiquidMutualFunds").get("v.value");
        
        editedPSRecord.Term_Deposits_in_scheduled_commercial_ba__c = component.find("Term_Deposits_in_scheduledBank").get("v.value");
        editedPSRecord.Equity_Shares_per__c = component.find("EquityShares").get("v.value");
        
        editedPSRecord.Equity_Linked_Mutual_Fund_per__c = component.find("EquityLinkedMutualFund").get("v.value");
        editedPSRecord.Exchange_Traded_Funds_per__c = component.find("ExchangeTradedFunds").get("v.value");
        editedPSRecord.Index_Funds_per__c = component.find("IndexFunds").get("v.value");
        
        
        //editedPSRecord.Family_Tree__c = component.find("familytree").get("v.value"); //As per Client Requirement
        editedPSRecord.Current_Investment_Advisors__c = component.find("InvestmentAdvisor").get("v.value");
        editedPSRecord.Other_specific_information__c = component.find("otherspecificinformation").get("v.value");
        editedPSRecord.Investible_asset__c = component.find("totalinvestibleasset").get("v.value");
        editedPSRecord.family_s_annual_income__c = component.find("familyannualincome").get("v.value");
        editedPSRecord.Fixed_Income__c = component.find("FixeIncome").get("v.value");
        
        editedPSRecord.Event__c = component.find("Event").get("v.value");
        editedPSRecord.Amount_1__c = component.find("Amount1").get("v.value");
        editedPSRecord.Event1__c = component.find("Event1").get("v.value");
        editedPSRecord.Amount_2__c = component.find("Amount2").get("v.value");
        editedPSRecord.Event2__c = component.find("Event2").get("v.value");
        editedPSRecord.Amount_3__c = component.find("Amount3").get("v.value");
        editedPSRecord.what_is_clients_financial_goal__c = component.find("curfingoal").get("v.value");
        editedPSRecord.client_s_present_investment_pattern__c = component.find("presentinvest").get("v.value");
        
        editedPSRecord.current_sources_of_investment_ideas__c = component.find("sourceidea").get("v.value");
       // editedPSRecord.Investment_goal__c = component.find("investmentgoal").get("v.value");
       	editedPSRecord.How_often_does_client_monitor_po__c = component.find("monitorportfolio").get("v.value");
        editedPSRecord.performancebenchmarks__c = component.find("benchmarks").get("v.value");
       // editedPSRecord.Stop_Loss__c = component.find("stopLoss").get("v.value");
        
       // editedPSRecord.Derivative__c = component.find("Derivative").get("v.value");
       // editedPSRecord.Mutual_Funds__c = component.find("MutualFunds").get("v.value");
       // editedPSRecord.Stop_Loss__c = component.find("stopLoss").get("v.value");
        editedPSRecord.Central_and_State_Gov__c = component.find("GOIone").get("v.value");
        editedPSRecord.PSU_and_Private__c = component.find("PSUtwo").get("v.value");
        editedPSRecord.Money_Market__c = component.find("PSUthree").get("v.value");
        editedPSRecord.Equity_and_Equity_Linked_Mutual_Fund__c = component.find("PSUfour").get("v.value");
        editedPSRecord.Asset_Backed_Securities__c = component.find("PSUfive").get("v.value");
        
        editedPSRecord.GOI_Dated_Securities_Per__c = component.find("GOIDatedSecurities").get("v.value");
        editedPSRecord.Treasury_Bills_per__c = component.find("TreasuryBills").get("v.value");
        editedPSRecord.GOI_Special_Bonds_per__c = component.find("GOISpecialBonds").get("v.value");
        editedPSRecord.State_Development_Loans_per__c = component.find("StateDevelopmentLoans").get("v.value");
        editedPSRecord.Gilt_Mutual_Fund_Per__c = component.find("GiltMutualFund").get("v.value");
        editedPSRecord.State_Guaranteed_Papers_Per__c = component.find("StateGuaranteedPapers").get("v.value");
        editedPSRecord.PSU_Bonds_Per__c = component.find("PSUBonds").get("v.value");
        editedPSRecord.PFI_Bonds_Per__c = component.find("PFIBonds").get("v.value");
        editedPSRecord.Private_Sector_Bonds_per__c = component.find("PrivateSectorBonds").get("v.value");
        editedPSRecord.BASEL_III_Bonds_Per__c = component.find("BASELIIIBonds").get("v.value");
        
        //editedPSRecord.Debt_Mutual_Funds_Per__c = component.find("DebtMutualFunds").get("v.value");
        editedPSRecord.Term_Deposits_of_more_than_1_year_per__c = component.find("TermDepositsone").get("v.value");
        editedPSRecord.Certificate_of_Deposits_Per__c = component.find("CertificateDeposits").get("v.value");
        editedPSRecord.Commercial_Papers_per__c = component.find("CommercialPapers").get("v.value");
        editedPSRecord.Units_of_Liquid_Mutual_Funds_Per__c = component.find("LiquidMutualFunds").get("v.value");
        editedPSRecord.Equity_Shares_per__c = component.find("EquityShares").get("v.value");
        editedPSRecord.Exchange_Traded_Funds_per__c = component.find("ExchangeTradedFunds").get("v.value");
        editedPSRecord.Index_Funds_per__c = component.find("IndexFunds").get("v.value");
        editedPSRecord.What_are_real_estate_requirements__c = component.find("realestate").get("v.value");
        editedPSRecord.Financial_Advisor__c = component.find("FinancialAdvisor1").get("v.value");
        editedPSRecord.CMBS_RMBS_per__c = component.find("CMBSRMBS").get("v.value");
        editedPSRecord.Units_of_REITs_per__c = component.find("UnitsREITs").get("v.value");
        editedPSRecord.Asset_Backed_Securities_per__c = component.find("AssetBackedSecurities").get("v.value");
        editedPSRecord.Units_of_Infra_Inv_Trusts_Per__c = component.find("UnitInfraInvst").get("v.value");
        editedPSRecord.AAA_per__c = component.find("AAA").get("v.value");
        editedPSRecord.AA_Plus_per__c = component.find("AAplus").get("v.value");
        editedPSRecord.AA_Per__c = component.find("AA").get("v.value");
        editedPSRecord.AA_Below_Per__c = component.find("AABelow").get("v.value");
        editedPSRecord.Banking_per__c = component.find("Banking").get("v.value");
        editedPSRecord.Finance_Per__c = component.find("Finance").get("v.value");
        editedPSRecord.Power_per__c = component.find("Power").get("v.value");
        editedPSRecord.Housing_per__c = component.find("Housing").get("v.value");
        editedPSRecord.Manufacturing_Per__c = component.find("Manufacturing").get("v.value");
        editedPSRecord.Others_Per__c = component.find("Others").get("v.value");
        editedPSRecord.GOI_Dated_Securities_Issue_Per__c = component.find("IssueGOIDatedSecurities").get("v.value");
        editedPSRecord.Treasury_Bills_issue_per__c = component.find("IssueTreasuryBills").get("v.value");
        
        editedPSRecord.GOI_Special_Bonds_issue_per__c = component.find("issueGOISpecialBonds").get("v.value");
        editedPSRecord.State_Development_Loans_issue_per__c = component.find("issueStateDevelopmentLoans").get("v.value");
        editedPSRecord.State_Guaranteed_Papers_issue_Per__c = component.find("issueStateGuaranteedPapers").get("v.value");
        editedPSRecord.AAA_Rated_Each_Issuer__c = component.find("issueAAA").get("v.value");
        editedPSRecord.AA_Plus_Rated_Each_Issuer__c = component.find("issueAA+").get("v.value");
        editedPSRecord.AA_Rated_Each_Issuer__c = component.find("issueAA").get("v.value");
        editedPSRecord.Notes_Remarks__c = component.find("NotesRemarks").get("v.value");
        editedPSRecord.sobjectType = 'Investment_Policy_Statement_IPS__c';
        component.set("v.IPSRecord",editedPSRecord);
        var setisCorporate = component.get("v.isCorporate");
        
        //Validation
        /*if($A.util.isEmpty(editedPSRecord.DateOfBirth__c) || $A.util.isUndefined(editedPSRecord.DateOfBirth__c))
        {
            component.set("v.messageBody",'Date of Birth is Required');
            return;
        } */           
        if(($A.util.isEmpty(editedPSRecord.entity__c) || $A.util.isUndefined(editedPSRecord.entity__c)) && setisCorporate)
        {
            component.set("v.messageBody",'Entity is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.ResidentialStatus__c) || $A.util.isUndefined(editedPSRecord.ResidentialStatus__c) || editedPSRecord.ResidentialStatus__c == '---None---') && !setisCorporate) 
        {
            component.set("v.messageBody",'Residential Status is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.TaxStatusforInvestments__c) || $A.util.isUndefined(editedPSRecord.TaxStatusforInvestments__c) || editedPSRecord.TaxStatusforInvestments__c == '---None---' && setisCorporate)
        {
            component.set("v.messageBody",'Tax Status for Investments is Required');
            return;
        }
         if($A.util.isEmpty(editedPSRecord.Current_Investment_Advisors__c) || $A.util.isUndefined(editedPSRecord.Current_Investment_Advisors__c))
        {
            component.set("v.messageBody",'Current Investment Advisor is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.current_Net_worth__c) || $A.util.isUndefined(editedPSRecord.current_Net_worth__c) || editedPSRecord.current_Net_worth__c == '---None---') && !setisCorporate)
        {
            component.set("v.messageBody",'current Net worth is Required');
            return;
        }            
        if(($A.util.isEmpty(editedPSRecord.family_s_annual_income__c) || $A.util.isUndefined(editedPSRecord.family_s_annual_income__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'familys annual income is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Direct_equities__c) || $A.util.isUndefined(editedPSRecord.Direct_equities__c))
        {
            component.set("v.messageBody",'Direct Equity is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Fixed_Income__c) || $A.util.isUndefined(editedPSRecord.Fixed_Income__c))
        {
            component.set("v.messageBody",'Fixed Income is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Balanced__c) || $A.util.isUndefined(editedPSRecord.Balanced__c))
        {
            component.set("v.messageBody",'Balanced is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Alternates__c) || $A.util.isUndefined(editedPSRecord.Alternates__c))
        {
            component.set("v.messageBody",'Alternates is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Real_Estate_Physical__c) || $A.util.isUndefined(editedPSRecord.Real_Estate_Physical__c))
        {
            component.set("v.messageBody",'Real Estate Physical is Required');
            return;
        } 
        if($A.util.isEmpty(editedPSRecord.Other_Investments_Details__c) || $A.util.isUndefined(editedPSRecord.Other_Investments_Details__c))
        {
            component.set("v.messageBody",'Other Investments is Required');
            return;
        }            
        if(($A.util.isEmpty(editedPSRecord.Liabilities__c) || $A.util.isUndefined(editedPSRecord.Liabilities__c)) && setisCorporate)
        {
            component.set("v.messageBody",'Liabilities is Required');
            return;
        } 
        if(($A.util.isEmpty(editedPSRecord.Housing_Loan__c) || $A.util.isUndefined(editedPSRecord.Housing_Loan__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'Housing Loan is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Auto_loan__c) || $A.util.isUndefined(editedPSRecord.Auto_loan__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'Auto loan is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Business_Loan__c) || $A.util.isUndefined(editedPSRecord.Business_Loan__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'Business Loan is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Other_loan__c) || $A.util.isUndefined(editedPSRecord.Other_loan__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'Other loan is Required');
            return;
        }            
        if(($A.util.isEmpty(editedPSRecord.wealth_management_requirements__c) || $A.util.isUndefined(editedPSRecord.wealth_management_requirements__c)) && !setisCorporate)
        {
            component.set("v.messageBody",'wealth management requirements is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Time_horizon_for_clients_financial_goal__c) || $A.util.isUndefined(editedPSRecord.Time_horizon_for_clients_financial_goal__c)  || editedPSRecord.Time_horizon_for_clients_financial_goal__c == '---None---'))
        {
            component.set("v.messageBody",'Time horizon for clients financial goal is Required');
            return;
        }            
        if(($A.util.isEmpty(editedPSRecord.treasury_management_needs__c) || $A.util.isUndefined(editedPSRecord.treasury_management_needs__c)))
        {
            component.set("v.messageBody",'treasury management needs is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Investment_Banking_requirements__c) || $A.util.isUndefined(editedPSRecord.Investment_Banking_requirements__c)) )
        {
            component.set("v.messageBody",'Investment Banking requirements is Required');
            return;
        }
        if(($A.util.isEmpty(editedPSRecord.Am_I_protected_against_Business_Risks__c) || $A.util.isUndefined(editedPSRecord.Am_I_protected_against_Business_Risks__c)))
        {
            component.set("v.messageBody",'Business Risks is Required');
            return;
        }
        /*if(($A.util.isEmpty(editedPSRecord.Equity_Markets__c) || $A.util.isUndefined(editedPSRecord.Equity_Markets__c) || editedPSRecord.Equity_Markets__c == '---None---' ) && setisCorporate)
        {
            component.set("v.messageBody",'Equity Markets is Required');
            return;
        }
		if(($A.util.isEmpty(editedPSRecord.Age__c) || $A.util.isUndefined(editedPSRecord.Age__c) || editedPSRecord.Age__c == '---None---' ) && !setisCorporate)
        {
            component.set("v.messageBody",'Age is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Investment_philosophy__c) || $A.util.isUndefined(editedPSRecord.Investment_philosophy__c)  || editedPSRecord.Investment_philosophy__c == '---None---')
        {
            component.set("v.messageBody",'Investment philosophy is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Investment_goal__c) || $A.util.isUndefined(editedPSRecord.Investment_goal__c) || editedPSRecord.Investment_goal__c == '---None---')
        {
            component.set("v.messageBody",'Investment goal is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Financial_Goals__c) || $A.util.isUndefined(editedPSRecord.Financial_Goals__c) || editedPSRecord.Financial_Goals__c == '---None---')
        {
            component.set("v.messageBody",'Financial Goals is Required');
            return;
        } 
        if($A.util.isEmpty(editedPSRecord.worst_and_best_one_year_return__c) || $A.util.isUndefined(editedPSRecord.worst_and_best_one_year_return__c) || editedPSRecord.worst_and_best_one_year_return__c == '---None---')
        {
            component.set("v.messageBody",'worst and best one year return is Required');
            return;
        } 
        if($A.util.isEmpty(editedPSRecord.Amount_of_fluctuations__c) || $A.util.isUndefined(editedPSRecord.Amount_of_fluctuations__c) || editedPSRecord.Amount_of_fluctuations__c == '---None---')
        {
            component.set("v.messageBody",'Amount of fluctuations is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Diversified_portfolio__c) || $A.util.isUndefined(editedPSRecord.Diversified_portfolio__c) || editedPSRecord.Diversified_portfolio__c == '---None---')
        {
            component.set("v.messageBody",'Diversified portfolio is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Interest_in_leverage_borrowing_products__c) || $A.util.isUndefined(editedPSRecord.Interest_in_leverage_borrowing_products__c) || editedPSRecord.Interest_in_leverage_borrowing_products__c == '---None---')
        {
            component.set("v.messageBody",'leverage borrowing products is Required');
            return;
        }
         if($A.util.isEmpty(editedPSRecord.Alternative_Investments__c) || $A.util.isUndefined(editedPSRecord.Alternative_Investments__c) || editedPSRecord.Alternative_Investments__c == '---None---')
        {
            component.set("v.messageBody",'Alternative Investments is Required');
            return;
        }
        if($A.util.isEmpty(editedPSRecord.Investment_portfolio__c) || $A.util.isUndefined(editedPSRecord.Investment_portfolio__c) || editedPSRecord.Investment_portfolio__c == '---None---')
        {
            component.set("v.messageBody",'Investment portfolio is Required');
            return;
        } 
        if($A.util.isEmpty(editedPSRecord.Investment_Style__c) || $A.util.isUndefined(editedPSRecord.Investment_Style__c) || editedPSRecord.Investment_Style__c == '---None---')
        {
            component.set("v.messageBody",'Investment Style is Required');
            return;
        }   */         
        /*if($A.util.isEmpty(editedPSRecord.Time_line_for_Trading__c) || $A.util.isUndefined(editedPSRecord.Time_line_for_Trading__c) || editedPSRecord.Time_line_for_Trading__c == '---None---')
        {
            component.set("v.messageBody",'Time Line For Trading is Required');
            return;
        }*/
        // End validation
        
        //var IPSRecords = component.get("v.IPSRecord");
		for (var key in editedPSRecord) 
        {
            if($A.util.isUndefined(editedPSRecord[key]) || editedPSRecord[key] == '---None---')
            {
				delete editedPSRecord[key];
			}
            if($A.util.isUndefined(editedPSRecord[key]) || editedPSRecord[key] == '---Not Applicable---')
            {
				//delete editedPSRecord[key];
                //editedPSRecord[key] = '';
			}
            if( typeof editedPSRecord[key] === 'string' && editedPSRecord[key].indexOf('---Not Applicable---;') != -1 )
            {
				//editedPSRecord[key] = editedPSRecord[key].replace("---Not Applicable---;", "");
			}
            
            if (editedPSRecord.hasOwnProperty(key)) 
            {
                if(Number.isInteger(editedPSRecord[key])){
                    editedPSRecord[key] = ''+ editedPSRecord[key];
                }
            }
		}
        //Calling the Apex Function
        var action = component.get("c.createRecord");
        //Setting the Apex Parameter
        //
        
        action.setParams({
            UpdatedIPSRecord : JSON.parse(JSON.stringify(editedPSRecord)),
            isCorporate : component.get("v.isCorporate"),
            accId : accRecord.Id
        });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            //check if result is successfull
          if(state == "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({            
                    "message": "IPS has been successfully saved."
                });
                resultsToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
                if(component.get("v.isNewIPS")){
                   	window.setTimeout(
                        $A.getCallback(function() {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                              "url": "/"+component.get("v.recordId")
                            });
                            urlEvent.fire();
                        }), 200
                    );
                }
            } 
            else if(state == "ERROR")
            {
                var errors = a.getError();
                if (errors) {                    
                    
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        component.set("v.messageBody",errors[0].pageErrors[0].message);
                        
                    }else if(errors[0] && errors[0].fieldErrors){                        
                        for (var key in errors[0].fieldErrors){
                            if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0]){                               
                                component.set("v.messageBody",errors[0].fieldErrors[key][0].message);
                             }
                        }                       
                    }else if (errors[0] && errors[0].message != null){
                        component.set("v.messageBody",errors[0].message);                        
                    }
                }
            }
        });
		//adds the server-side action to the queue        
        $A.enqueueAction(action);
	},
    
    review : function(component, event, helper)
    {
        var editedPSRecord;
        editedPSRecord = component.get("v.IPSRecord");
        var accRecord = component.get("v.account");
        editedPSRecord.Client_Name__c = accRecord.Id;
        editedPSRecord.sobjectType = 'Investment_Policy_Statement_IPS__c';
        component.set("v.IPSRecord",editedPSRecord);
       
        var action = component.get("c.updateReviewData");
        action.setParams({
            IpsrecordId : JSON.parse(JSON.stringify(component.get("v.IPSRecord")))
        });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var strError = a.getReturnValue();
                if (strError=== "Success")
                {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({            
                    "message": "Review update successfully"
                });
                resultsToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
                if(component.get("v.isNewIPS")){
                   	window.setTimeout(
                        $A.getCallback(function() {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                              "url": "/"+component.get("v.recordId")
                            });
                            urlEvent.fire();
                        }), 200
                    );  
					}
                }
                else{
                    component.set("v.messageBody",strError);					
                }
            } 
            else if(state == "ERROR")
            {
                var errors = a.getError();
                if (errors) {                    
                    
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        component.set("v.messageBody",errors[0].pageErrors[0].message);
                        
                    }else if(errors[0] && errors[0].fieldErrors){                        
                        for (var key in errors[0].fieldErrors){
                            if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0]){                               
                                component.set("v.messageBody",errors[0].fieldErrors[key][0].message);
                             }
                        }                       
                    }else if (errors[0] && errors[0].message != null){
                        component.set("v.messageBody",errors[0].message);                        
                    }
                }
            }
        });       
        $A.enqueueAction(action);
	},
    
    ToggleCollapse : function(component, event, helper) { 
        var divId = event.currentTarget.id;
		var divEle = document.getElementById(divId);       
        var curElement = divEle; 
        var parElement = curElement.parentNode.parentNode; 			
        for (var i = 0; i < parElement.childNodes.length; i++) {
            if (parElement.childNodes[i].className && parElement.childNodes[i].className.indexOf("container") > -1) {
                                
                var ButtonArr = curElement.childNodes;
                if(ButtonArr[0].className.indexOf("show") > -1)
                {                    
                    parElement.childNodes[i].classList.remove("hide");
                    parElement.childNodes[i].classList.add("show");
               		ButtonArr[0].classList.add("hide");
                    ButtonArr[0].classList.remove("show");
                    ButtonArr[1].classList.add("show");
                    ButtonArr[1].classList.remove("hide");
                    divEle.classList.add("expandbtn");
                    divEle.classList.remove("collapsbtn");
                }else
                {                   
                    parElement.childNodes[i].classList.remove("show");
                    parElement.childNodes[i].classList.add("hide");
               		ButtonArr[1].classList.add("hide");
                    ButtonArr[1].classList.remove("show");
                    ButtonArr[0].classList.add("show");
                    ButtonArr[0].classList.remove("hide");
                    divEle.classList.add("collapsbtn");
                    divEle.classList.remove("expandbtn");
                }
                
              break;
            }
        }
	},
    cancel : function(component, event, helper) 
    {
    	var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
    }
})