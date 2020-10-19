({
	doInit: function(component, event, helper) { 
		var recordId = component.get("v.recordId"); 
        //component.set("v.messageBody",recordId);        
        
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
    
    display : function(component, event, helper) 
    {
    	helper.toggleHelper(component, event);
  	},
        
   displayOut : function(component, event, helper) 
   {
       helper.toggleHelper(component, event);
	},
    
    save: function(component, event, helper)
    {
        var editedPSRecord;
        editedPSRecord = component.get("v.IPSRecord");
        var accRecord = component.get("v.account");
        editedPSRecord.Client_Name__c = accRecord.Id;
        editedPSRecord.Name = component.find("IPSNumber").get("v.value");
        editedPSRecord.LastModifiedDate = component.find("LastModifieddate").get("v.value");
        //editedPSRecord.DateOfBirth__c = component.find("birthdate").get("v.value");
        editedPSRecord.entity__c = component.find("entity").get("v.value");
        
        editedPSRecord.ResidentialStatus__c = component.find("Status").get("v.value");
        editedPSRecord.TaxStatusforInvestments__c = component.find("TaxStatus").get("v.value");
        //editedPSRecord.Current_Liabilities__c = component.find("CurrentLiabilities").get("v.value");
        
        editedPSRecord.current_Net_worth__c = component.find("currentNetworth").get("v.value");
        editedPSRecord.Direct_equities__c = component.find("DirectEquity").get("v.value");
        
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
        
       /* editedPSRecord.Equity_Markets__c = component.find("EquityMarkets").get("v.value");
        
        editedPSRecord.Age__c = component.find("Age").get("v.value");
        editedPSRecord.Investment_philosophy__c = component.find("investmentphilosophy").get("v.value");
        editedPSRecord.Investment_goal__c = component.find("investmentgoal").get("v.value");
        
        editedPSRecord.Financial_Goals__c = component.find("FinancialGoals").get("v.value");
        editedPSRecord.worst_and_best_one_year_return__c = component.find("worstbestreturn").get("v.value");
        editedPSRecord.Amount_of_fluctuations__c = component.find("amountoffluctuations").get("v.value");

        editedPSRecord.Diversified_portfolio__c = component.find("diversifiedportfolio").get("v.value");
        editedPSRecord.Interest_in_leverage_borrowing_products__c = component.find("leverageborrowingproducts").get("v.value");
        editedPSRecord.Alternative_Investments__c = component.find("AlternativeInvestments").get("v.value");
        editedPSRecord.Investment_portfolio__c = component.find("investmentportfolio").get("v.value");
        editedPSRecord.Investment_Style__c = component.find("InvestmentStyle").get("v.value");
        editedPSRecord.Time_line_for_Trading__c = component.find("Trading").get("v.value");
        
        editedPSRecord.Direct_Equity__c = component.find("Direct_Equity").get("v.value");
        editedPSRecord.Derivative__c = component.find("Derivative").get("v.value");
        editedPSRecord.Mutual_Funds__c = component.find("MutualFunds").get("v.value");
        editedPSRecord.Stop_Loss__c = component.find("stopLoss").get("v.value");
        */
		
		//editedPSRecord.Current_Investable_Assets__c = component.find("InvestableAssets").get("v.value");
        editedPSRecord.Current_Investment_Advisors__c = component.find("InvestmentAdvisor").get("v.value");
        //editedPSRecord.Investible_asset__c = component.find("totalinvestibleasset").get("v.value"); // As client Requirement
        editedPSRecord.family_s_annual_income__c = component.find("familyannualincome").get("v.value");
        editedPSRecord.Fixed_Income__c = component.find("FixeIncome").get("v.value");

        
        editedPSRecord.sobjectType = 'Investment_Policy_Statement_IPS__c';
        component.set("v.IPSRecord",editedPSRecord);
        var setisCorporate = component.get("v.isCorporate");
		
		
         //Validation
        /*if($A.util.isEmpty(editedPSRecord.DateOfBirth__c) || $A.util.isUndefined(editedPSRecord.DateOfBirth__c))
        {
            component.set("v.messageBody",'Date of Birth is Required');
            return;
        }    */        
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
            component.set("v.messageBody",'Other Investments Details is Required');
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
       /* if(($A.util.isEmpty(editedPSRecord.Equity_Markets__c) || $A.util.isUndefined(editedPSRecord.Equity_Markets__c) || editedPSRecord.Equity_Markets__c == '---None---' ) && setisCorporate)
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
        }            
        if($A.util.isEmpty(editedPSRecord.Time_line_for_Trading__c) || $A.util.isUndefined(editedPSRecord.Time_line_for_Trading__c) || editedPSRecord.Time_line_for_Trading__c == '---None---')
        {
            component.set("v.messageBody",'Time Line For Trading is Required');
            return;
        }*/
        //Calling the Apex Function
        var IPSRecords = component.get("v.IPSRecord");
		for (var key in IPSRecords) {
		  if (IPSRecords.hasOwnProperty(key)) 
          {
			if($A.util.isUndefined(IPSRecords[key]) || IPSRecords[key] == '---None---')
            {
				delete IPSRecords[key];
			}
            if($A.util.isUndefined(IPSRecords[key]) || IPSRecords[key] == '---Not Applicable---')
            {
				//delete IPSRecords[key];
                //IPSRecords[key] = '';
			}
            if(Number.isInteger(IPSRecords[key])){
				IPSRecords[key] = ''+ IPSRecords[key];
			}
		  }
		}
		
        var action = component.get("c.createRecord");
        action.setParams({
            UpdatedIPSRecord : JSON.parse(JSON.stringify(IPSRecords)),
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
    },
    
    PrintIPS: function(component, event, helper) 
    {    	 
        var IPSRecord = component.get("v.IPSRecord");
        if(IPSRecord != null && IPSRecord.Id != null){
            var RecordId = IPSRecord.Id;  
            var url = '/apex/Mini_IPS?id=' + RecordId;
            /*var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": '/apex/InvestmentPolicyStatement?id=' + RecordId
            });
            urlEvent.fire();*/
            window.open(url);
        }   
    },
    
    PrintRiskProfileOfClient: function(component, event, helper) 
    {    	 
        var IPSRecord = component.get("v.IPSRecord");
        if(IPSRecord != null && IPSRecord.Id != null){
            var RecordId = IPSRecord.Id;  
            var url = '/apex/RiskProfileOfClient?id=' + RecordId;
            window.open(url);
        }
    },
 
 	PrintSummaryIPS: function(component, event, helper) 
    {    	 
        var IPSRecord = component.get("v.IPSRecord");
        if(IPSRecord != null && IPSRecord.Id != null){
            var RecordId = IPSRecord.Id;  
            var url = '/apex/SummaryIPS?id=' + RecordId;
            window.open(url);
        }
        
    }
})