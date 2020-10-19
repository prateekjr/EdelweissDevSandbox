({
    doInit: function(component, event, helper) {  
        var index = window.navigator.userAgent.indexOf("MSIE");
        if (index > 0 || navigator.userAgent.match(/Trident\/7\./)){
            component.set("v.isIE",true);
        } 
        else
            component.set("v.isIE",false);
        var fieldSetName = component.get("v.fieldsetName");
        var recordId = component.get("v.recordId");//"5005D000000qJ3c"; 
        var lkpFieldID = component.get("v.lkpFieldID");
        var action = component.get("c.getFieldList");
        action.setParams({
            fldSetNameLst: fieldSetName,
            RecordID: recordId,
            objectAPI: component.get("v.objectType"),
            lookupFieldID: lkpFieldID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.fieldSetMap",response.getReturnValue()['Result']);
                component.set("v.isObjUpdateable",response.getReturnValue()['isObjectUpdateable']);
                component.set("v.profileName",response.getReturnValue()['ProfileName']);
                var record = response.getReturnValue()['Record'];
                if(component.get("v.recordId") == undefined || component.get("v.recordId") == '') {
                    var lkpFieldName = component.get("v.lkpFieldName");
                    if(lkpFieldID != ''){
                        record[lkpFieldName] = new Object();
                        record[lkpFieldName].Name = response.getReturnValue()['lkpFieldNameValue'];
                        record[lkpFieldName].Id = lkpFieldID;
                    }    
                }
                
                var accRef = component.get("v.accountRef");                
                record.sobjectType = component.get("v.objectType");
                if(accRef.RecordTypeId == component.get("v.RecordTypeId"))
                    record = accRef;                
                //Edit Record 
                var selectedAccount = component.get("v.selectedAccount");
                if(selectedAccount != null && selectedAccount["Account"] != null)
                {
                    record["Account"] = new Object();
                    record["Account"].Name = selectedAccount["Account"].Name;
                    record["Account"].Id = selectedAccount["Account"].Id;
                    record["AccountId"] = selectedAccount["Account"].Id; 
                } 
                var jointNum = record["Number_of_Joint_Holders_Max_2__c"];
                record["Number_of_Joint_Holders_Max_2__c"] = (jointNum != null) ? jointNum : '1';
                
                var proName = component.get("v.profileName").toLowerCase();
                if(!proName == 'system administrator'){
                    component.set("v.isObjUpdateable",false);
                }
                if(record['Product_Type__c'] != null && record['Product_Type__c'] != ''){
                    component.set("v.ProductType",record['Product_Type__c']);
                    helper.fillSelectedFieldSetMap(component, event, helper,record); 
                }else{
                    record['Product_Type__c'] = '';
                    var fieldMap = component.get("v.fieldSetMap");
                    var selectedMap = {};
                    for(var f in fieldMap){
                        if(!f.includes("Funding") && !f.includes("Trading") && !f.includes("Joint"))
                            selectedMap[f] = fieldMap[f]
                            }                
                    component.set("v.selectedFieldSetMap",selectedMap);                    
                }
                var familyType = component.get("v.FamilyType");
                if(record['Client_Name__c'] != null && record['Client_Name__c'] != '' && familyType['NewFamily']){
                    component.set("v.isRecordAdded",true);
                }
                if(!familyType.ExistingClient && (record['Product_Type__c'] == null || record['Product_Type__c'] == '')){
                    record['Product_Type__c'] = 'Miles';                    
                }
                //Enable/Disable trading fields
                if(! $A.util.isEmpty(record["Special_Brokerage_RM_Approval_Required__c"])){
                    component.set("v.isEnabledTradingFeilds", record["Special_Brokerage_RM_Approval_Required__c"]);
                }
                
                component.set("v.ProductType",record['Product_Type__c']);
                component.set("v.account",record);
                component.set("v.accountRef",JSON.parse(JSON.stringify(record)));
                component.set("v.oldAccount",JSON.parse(JSON.stringify(record)));
                component.set("v.oldAccountRef",JSON.parse(JSON.stringify(record)));
                
                helper.editAccountDetails(component, event, helper);
                var DivTarget = component.find("DetailBtnDiv");
                $A.util.addClass(DivTarget ,'slds-show');
                $A.util.removeClass(DivTarget ,'slds-hide');
                
            }
        }); 
        $A.enqueueAction(action); 
    },
    
    handleChangeInputValue : function(component, event, helper) {
        var accRec = component.get("v.account") ;
        var accountRef = component.get("v.accountRef");
         if(event.getParam("fieldName") == 'Status'){
            component.set("v.status",event.getParam("fieldVal"));
        }
        if(accRec != null && accountRef != null && event.getParam("fieldName") != null){
            accRec [ event.getParam("fieldName")] = event.getParam("fieldVal");  
            accountRef [ event.getParam("fieldName")] = event.getParam("fieldVal");           
            if(event.getParam("isLookUp")){
                var qId = event.getParam("fieldName");
                var apiName = event.getParam("fieldName");
                if(qId.indexOf('__c') != -1)
                    apiName = apiName.replace('__c','__r');
                else
                    apiName = apiName.replace('Id','');	     
                accountRef[apiName] = new Object();
                accountRef[apiName].Name = event.getParam("fieldRefVal");
                accountRef[apiName].Id = event.getParam("fieldVal");
                var selectedAccount =  component.get("v.selectedAccount");
                
                selectedAccount = new Object();
                selectedAccount[apiName] = new Object();
                selectedAccount[apiName].Name = event.getParam("fieldRefVal");
                selectedAccount[apiName].Id = event.getParam("fieldVal");
                component.set("v.selectedAccount",JSON.parse(JSON.stringify(selectedAccount)));  
                var familyType = component.get("v.FamilyType");
                if(apiName == "Account" && event.getParam("fieldVal") != null){
                    var action = component.get("c.getAccountDetail");
                    action.setParams({
                        "accountId": event.getParam("fieldVal")
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if(component.isValid() && state === "SUCCESS") { 
                            var returnVal =  response.getReturnValue();
                            var updateRecord = component.get("v.accountRef");
                            var updateRec = component.get("v.account");
                            /*if(returnVal.Category__c == 'Corporate'){
                                component.set("v.isCorporate",true);
                            }*/
                            updateRecord["Email_Id__c"] = returnVal.Primary_Email__c;
                            updateRecord["Phone__c"] = returnVal.Phone;
                            updateRecord["Address__c"] = returnVal.Address__c;
                            if(!(familyType['NewFamily']) && !(familyType['NewClient'])){
                                updateRecord["PAN_Number__c"] = returnVal.PAN_Number__c;
                                updateRecord["DOB_DOI__c"] = returnVal.Date_of_Birth__c;
                            }
                            updateRecord["Cases"] = returnVal.Cases;
                            var cases = returnVal.Cases;
                            var caseRecord = component.get("v.caseRecord");
                            if(cases != null){
                                caseRecord.Investment_philosophy__c = returnVal.Cases[0].Investment_philosophy__c;
                                caseRecord.Equity_Markets__c = returnVal.Cases[0].Equity_Markets__c;
                                caseRecord.Age_RiskProfile__c = returnVal.Cases[0].Age_RiskProfile__c;
                                caseRecord.Financial_Goals__c = returnVal.Cases[0].Financial_Goals__c;
                                caseRecord.Investment_goal__c = returnVal.Cases[0].Investment_goal__c;
                                caseRecord.Amount_of_fluctuations__c = returnVal.Cases[0].Amount_of_fluctuations__c;
                                caseRecord.Amount_of_fluctuations_Non_Ind__c = returnVal.Cases[0].Amount_of_fluctuations_Non_Ind__c;
                                caseRecord.worst_and_best_one_year_return__c = returnVal.Cases[0].worst_and_best_one_year_return__c;
                                caseRecord.worst_and_best_one_year_return_Non_Ind__c = returnVal.Cases[0].worst_and_best_one_year_return_Non_Ind__c;
                                caseRecord.Interest_in_leverage_borrowing_products__c = returnVal.Cases[0].Interest_in_leverage_borrowing_products__c;
                                caseRecord.Interest_leverage_products_Non_Ind__c = returnVal.Cases[0].Interest_leverage_products_Non_Ind__c;
                                
                                caseRecord.Diversified_portfolio__c = returnVal.Cases[0].Diversified_portfolio__c;
                                caseRecord.Investment_portfolio__c = returnVal.Cases[0].Investment_portfolio__c;
                                caseRecord.Alternative_Investments__c = returnVal.Cases[0].Alternative_Investments__c;
                                caseRecord.Alternative_Investments_Non_Ind__c = returnVal.Cases[0].Alternative_Investments_Non_Ind__c;
                                caseRecord.Time_line_for_Trading__c = returnVal.Cases[0].Time_line_for_Trading__c;
                                caseRecord.Investment_Style__c = returnVal.Cases[0].Investment_Style__c;
                                caseRecord.Stop_Loss__c = returnVal.Cases[0].Stop_Loss__c;
                                caseRecord.Direct_Equity__c = returnVal.Cases[0].Direct_Equity__c;
                                caseRecord.Derivative__c = returnVal.Cases[0].Derivative__c;
                                caseRecord.Mutual_Funds__c = returnVal.Cases[0].Mutual_Funds__c;
                                caseRecord.Risk_Profile_Categories__c = returnVal.Cases[0].Risk_Profile_Categories__c;
                                component.set("v.caseRecord",caseRecord);
                                updateRecord["Investment_philosophy__c"] = returnVal.Cases[0].Investment_philosophy__c;
                                updateRecord["Equity_Markets__c"] = returnVal.Cases[0].Equity_Markets__c;
                                updateRecord["Age_RiskProfile__c"] = returnVal.Cases[0].Age_RiskProfile__c;
                                updateRecord["Financial_Goals__c"] = returnVal.Cases[0].Financial_Goals__c;
                                updateRecord["Investment_goal__c"] = returnVal.Cases[0].Investment_goal__c;
                                updateRecord["Amount_of_fluctuations__c"] = returnVal.Cases[0].Amount_of_fluctuations__c;
                                updateRecord["Amount_of_fluctuations_Non_Ind__c"] = returnVal.Cases[0].Amount_of_fluctuations_Non_Ind__c;
                                updateRecord["worst_and_best_one_year_return__c"] = returnVal.Cases[0].worst_and_best_one_year_return__c;
                                updateRecord["worst_and_best_one_year_return_Non_Ind__c"] = returnVal.Cases[0].worst_and_best_one_year_return_Non_Ind__c;  
                                updateRecord["Interest_in_leverage_borrowing_products__c"] = returnVal.Cases[0].Interest_in_leverage_borrowing_products__c;
                                updateRecord["Interest_leverage_products_Non_Ind__c"] = returnVal.Cases[0].Interest_leverage_products_Non_Ind__c;
                                
                                updateRecord["Diversified_portfolio__c"] = returnVal.Cases[0].Diversified_portfolio__c;
                                updateRecord["Investment_portfolio__c"] = returnVal.Cases[0].Investment_portfolio__c;
                                updateRecord["Alternative_Investments__c"] = returnVal.Cases[0].Alternative_Investments__c;
                              updateRecord["Alternative_Investments_Non_Ind__c"] = returnVal.Cases[0].Alternative_Investments_Non_Ind__c;
                                updateRecord["Time_line_for_Trading__c"] = returnVal.Cases[0].Time_line_for_Trading__c;
                                updateRecord["Investment_Style__c"] = returnVal.Cases[0].Investment_Style__c;
                                updateRecord["Stop_Loss__c"] = returnVal.Cases[0].Stop_Loss__c;
                                updateRecord["Direct_Equity__c"] = returnVal.Cases[0].Direct_Equity__c;
                                updateRecord["Derivative__c"] = returnVal.Cases[0].Derivative__c;
                                updateRecord["Mutual_Funds__c"] = returnVal.Cases[0].Mutual_Funds__c;
                                updateRecord["Risk_Profile_Categories__c"] = returnVal.Cases[0].Risk_Profile_Categories__c;
                                
                                updateRec["Investment_philosophy__c"] = returnVal.Cases[0].Investment_philosophy__c;
                                updateRec["Equity_Markets__c"] = returnVal.Cases[0].Equity_Markets__c;
                                updateRec["Age_RiskProfile__c"] = returnVal.Cases[0].Age_RiskProfile__c;
                                updateRec["Financial_Goals__c"] = returnVal.Cases[0].Financial_Goals__c;
                                updateRec["Investment_goal__c"] = returnVal.Cases[0].Investment_goal__c;
                                updateRec["Amount_of_fluctuations__c"] = returnVal.Cases[0].Amount_of_fluctuations__c;
                                updateRec["Amount_of_fluctuations_Non_Ind__c"] = returnVal.Cases[0].Amount_of_fluctuations_Non_Ind__c;
                                updateRec["worst_and_best_one_year_return__c"] = returnVal.Cases[0].worst_and_best_one_year_return__c;
                                updateRec["worst_and_best_one_year_return_Non_Ind__c"] = returnVal.Cases[0].worst_and_best_one_year_return_Non_Ind__c;
                                updateRec["Interest_in_leverage_borrowing_products__c"] = returnVal.Cases[0].Interest_in_leverage_borrowing_products__c;
                                updateRec["Interest_leverage_products_Non_Ind__c"] = returnVal.Cases[0].Interest_leverage_products_Non_Ind__c;
                                updateRec["Diversified_portfolio__c"] = returnVal.Cases[0].Diversified_portfolio__c;
                                updateRec["Investment_portfolio__c"] = returnVal.Cases[0].Investment_portfolio__c;
                                updateRec["Alternative_Investments__c"] = returnVal.Cases[0].Alternative_Investments__c;
                                updateRec["Alternative_Investments_Non_Ind__c"] = returnVal.Cases[0].Alternative_Investments_Non_Ind__c;
                                updateRec["Time_line_for_Trading__c"] = returnVal.Cases[0].Time_line_for_Trading__c;
                                updateRec["Investment_Style__c"] = returnVal.Cases[0].Investment_Style__c;
                                updateRec["Stop_Loss__c"] = returnVal.Cases[0].Stop_Loss__c;
                                updateRec["Direct_Equity__c"] = returnVal.Cases[0].Direct_Equity__c;
                                updateRec["Derivative__c"] = returnVal.Cases[0].Derivative__c;
                                updateRec["Mutual_Funds__c"] = returnVal.Cases[0].Mutual_Funds__c;
                                updateRec["Risk_Profile_Categories__c"] = returnVal.Cases[0].Risk_Profile_Categories__c;
                                
                                if (typeof returnVal.Cases[0].Investment_philosophy__c != 'undefined'){
                                    updateRec["Risk_Profile_same_as_Family_Head__c"]  = true;
                                    updateRecord["Risk_Profile_same_as_Family_Head__c"]  = true;
                                }else{
                                    updateRec["Risk_Profile_same_as_Family_Head__c"]  = false;
                                    updateRecord["Risk_Profile_same_as_Family_Head__c"]  = false;
                                }
                            }else{
                                
                                //Through error
                            }
                            
                            updateRec["Email_Id__c"] = returnVal.Primary_Email__c;
                            updateRec["Phone__c"] = returnVal.Phone;
                            updateRec["Address__c"] = returnVal.Address__c;
                            
                            if(!(familyType['NewFamily']) && !(familyType['NewClient'])){
                                updateRec["PAN_Number__c"] = returnVal.PAN_Number__c;
                                updateRec["DOB_DOI__c"] = returnVal.Date_of_Birth__c;
                            }
                            if(!(familyType['NewFamily']) && (familyType['NewClient'])){
                                // updateRec["Risk_Profile_same_as_Family_Head__c"]  = true;
                                //  updateRecord["Risk_Profile_same_as_Family_Head__c"]  = true;
                                if( updateRec["Risk_Profile_Categories__c"] != ' '){
                                    updateRec["Risk_Profile_Categories__c"]  = 'A - I agree & want RP to be basis of investment';
                                    updateRecord["Risk_Profile_Categories__c"]  = 'A - I agree & want RP to be basis of investment';
                                }
                            }
                            if((familyType['NewFamily']) && (familyType['NewClient'])){
                                if( updateRec["Risk_Profile_Categories__c"] != ' '){
                                    updateRec["Risk_Profile_Categories__c"]  = 'A - I agree & want RP to be basis of investment';
                                    updateRecord["Risk_Profile_Categories__c"]  = 'A - I agree & want RP to be basis of investment';
                                }
                            }
                            
                            
                            var cases = returnVal.Cases;
                            if(cases != null && cases.length > 0 && returnVal.RecordType.Name == "Lead"){
                                component.set("v.isCaseCreated",true);
                                for(var c in cases){
                                    if(cases[c].Family__c != null){
                                        updateRec["Family__c"] = cases[c].Family__c;
                                        updateRecord["Family__c"] = cases[c].Family__c;
                                        updateRec["isAdditionalLead__c"] = true;
                                        updateRecord["isAdditionalLead__c"]  = true;
                                    }
                                }
                            } else if(cases == null){
                                updateRec["Is_Family_Head__c"] = true;
                                updateRecord["Is_Family_Head__c"]  = true;
                            }
                            component.set("v.accountRef",JSON.parse(JSON.stringify(updateRecord)));
                            component.set("v.account",JSON.parse(JSON.stringify(updateRec)));
                            component.set("v.expand","Case Detail");
                            helper.renderSection(component, event, helper);
                            component.set("v.expand","false");
                            component.set("v.isLeadSelect",true)
                        }
                    });
                    $A.enqueueAction(action);    
                    
                    var caseRecord = component.get("v.caseRecord");
                    var updateRecord = component.get("v.accountRef");
                    var updateRec = component.get("v.account");
                    if(!(familyType['NewFamily']) && (familyType['NewClient'])){
                        var action1 = component.get("c.getIPSDetails");
                        action1.setParams({
                            "accountId": event.getParam("fieldVal")
                        });                  
                        action1.setCallback(this, function(response) {
                            var state = response.getState();
                            var returnVal =  response.getReturnValue();
                            if(component.isValid() && state === "SUCCESS") { 
                                var returnVal =  response.getReturnValue();
                               // if(returnVal != null ){
                                       if (typeof returnVal.Investment_philosophy__c != 'undefined'){
                                    caseRecord.Investment_philosophy__c = returnVal.Investment_philosophy__c;
                                    caseRecord.Equity_Markets__c = returnVal.Equity_Markets__c;
                                    caseRecord.Age_RiskProfile__c = returnVal.Age_RiskProfile__c;
                                    caseRecord.Financial_Goals__c = returnVal.Financial_Goals__c;
                                    caseRecord.Investment_goal__c = returnVal.Investment_goal__c;
                                    caseRecord.Amount_of_fluctuations__c = returnVal.Amount_of_fluctuations__c;
                                    caseRecord.Amount_of_fluctuations_Non_Ind__c = returnVal.Amount_of_fluctuations_Non_Ind__c;
                                    caseRecord.worst_and_best_one_year_return__c = returnVal.worst_and_best_one_year_return__c;
                                    caseRecord.worst_and_best_one_year_return_Non_Ind__c = returnVal.worst_and_best_one_year_return_Non_Ind__c;
                                    caseRecord.Interest_in_leverage_borrowing_products__c = returnVal.Interest_in_leverage_borrowing_products__c;
                                    caseRecord.Interest_leverage_products_Non_Ind__c = returnVal.Interest_leverage_products_Non_Ind__c;
                                    caseRecord.Diversified_portfolio__c = returnVal.Diversified_portfolio__c;
                                    caseRecord.Investment_portfolio__c = returnVal.Investment_portfolio__c;
                                    caseRecord.Alternative_Investments__c = returnVal.Alternative_Investments__c;
                                    caseRecord.Alternative_Investments_Non_Ind__c = returnVal.Alternative_Investments_Non_Ind__c;
                                    caseRecord.Time_line_for_Trading__c = returnVal.Time_line_for_Trading__c;
                                    caseRecord.Investment_Style__c = returnVal.Investment_Style__c;
                                    caseRecord.Stop_Loss__c = returnVal.Stop_Loss__c;
                                    caseRecord.Direct_Equity__c = returnVal.Direct_Equity__c;
                                    caseRecord.Derivative__c = returnVal.Derivative__c;
                                    caseRecord.Mutual_Funds__c = returnVal.Mutual_Funds__c;
                                    caseRecord.Risk_Profile_Categories__c = returnVal.Risk_Profile_Categories__c;
                                    
                                    component.set("v.caseRecord",caseRecord);
                                    updateRecord["Investment_philosophy__c"] = returnVal.Investment_philosophy__c;
                                    updateRecord["Equity_Markets__c"] = returnVal.Equity_Markets__c;
                                    updateRecord["Age_RiskProfile__c"] = returnVal.Age_RiskProfile__c;
                                    updateRecord["Financial_Goals__c"] = returnVal.Financial_Goals__c;
                                    updateRecord["Investment_goal__c"] = returnVal.Investment_goal__c;
                                    updateRecord["Amount_of_fluctuations__c"] = returnVal.Amount_of_fluctuations__c;
                                    updateRecord["Amount_of_fluctuations_Non_Ind__c"] = returnVal.Amount_of_fluctuations_Non_Ind__c;
                                    updateRecord["worst_and_best_one_year_return__c"] = returnVal.worst_and_best_one_year_return__c;
                                    updateRecord["worst_and_best_one_year_return_Non_Ind__c"] = returnVal.worst_and_best_one_year_return_Non_Ind__c; 
                                    updateRecord["Interest_in_leverage_borrowing_products__c"] = returnVal.Interest_in_leverage_borrowing_products__c;
                                    updateRecord["Interest_leverage_products_Non_Ind__c"] = returnVal.Interest_leverage_products_Non_Ind__c;
                                    updateRecord["Diversified_portfolio__c"] = returnVal.Diversified_portfolio__c;
                                    updateRecord["Investment_portfolio__c"] = returnVal.Investment_portfolio__c;
                                    updateRecord["Alternative_Investments__c"] = returnVal.Alternative_Investments__c;
                                    updateRecord["Alternative_Investments_Non_Ind__c"] = returnVal.Alternative_Investments_Non_Ind__c;
                                    updateRecord["Time_line_for_Trading__c"] = returnVal.Time_line_for_Trading__c;
                                    updateRecord["Investment_Style__c"] = returnVal.Investment_Style__c;
                                    updateRecord["Stop_Loss__c"] = returnVal.Stop_Loss__c;
                                    updateRecord["Direct_Equity__c"] = returnVal.Direct_Equity__c;
                                    updateRecord["Derivative__c"] = returnVal.Derivative__c;
                                    updateRecord["Mutual_Funds__c"] = returnVal.Mutual_Funds__c;
                                    updateRecord["Risk_Profile_same_as_Family_Head__c"] = true;
                                    updateRecord["Risk_Profile_Categories__c"] = returnVal.Risk_Profile_Categories__c;
                                    
                                    updateRec["Investment_philosophy__c"] = returnVal.Investment_philosophy__c;
                                    updateRec["Equity_Markets__c"] = returnVal.Equity_Markets__c;
                                    updateRec["Age_RiskProfile__c"] = returnVal.Age_RiskProfile__c;
                                    updateRec["Financial_Goals__c"] = returnVal.Financial_Goals__c;
                                    updateRec["Investment_goal__c"] = returnVal.Investment_goal__c;
                                    updateRec["Amount_of_fluctuations__c"] = returnVal.Amount_of_fluctuations__c;
                                    updateRec["Amount_of_fluctuations_Non_Ind__c"] = returnVal.Amount_of_fluctuations_Non_Ind__c;
                                    updateRec["worst_and_best_one_year_return__c"] = returnVal.worst_and_best_one_year_return__c;
                                    updateRec["worst_and_best_one_year_return_Non_Ind__c"] = returnVal.worst_and_best_one_year_return_Non_Ind__c;
                                    updateRec["Interest_in_leverage_borrowing_products__c"] = returnVal.Interest_in_leverage_borrowing_products__c;
                                    updateRec["Interest_leverage_products_Non_Ind__c"] = returnVal.Interest_leverage_products_Non_Ind__c;               
                                    updateRec["Diversified_portfolio__c"] = returnVal.Diversified_portfolio__c;
                                    updateRec["Investment_portfolio__c"] = returnVal.Investment_portfolio__c;
                                    updateRec["Alternative_Investments__c"] = returnVal.Alternative_Investments__c;
                                     updateRec["Alternative_Investments_Non_Ind__c"] = returnVal.Alternative_Investments_Non_Ind__c;
                                    updateRec["Time_line_for_Trading__c"] = returnVal.Time_line_for_Trading__c;
                                    updateRec["Investment_Style__c"] = returnVal.Investment_Style__c;
                                    updateRec["Stop_Loss__c"] = returnVal.Stop_Loss__c;
                                    updateRec["Direct_Equity__c"] = returnVal.Direct_Equity__c;
                                    updateRec["Derivative__c"] = returnVal.Derivative__c;
                                    updateRec["Mutual_Funds__c"] = returnVal.Mutual_Funds__c;
                                    updateRec["Risk_Profile_Categories__c"] = returnVal.Risk_Profile_Categories__c;
                                    
                                    if (typeof returnVal.Investment_philosophy__c != 'undefined'){
                                        updateRec["Risk_Profile_same_as_Family_Head__c"]  = true;
                                        updateRecord["Risk_Profile_same_as_Family_Head__c"]  = true;
                                    }else{
                                        updateRec["Risk_Profile_same_as_Family_Head__c"]  = false;
                                        updateRecord["Risk_Profile_same_as_Family_Head__c"]  = false;
                                    }
                                    
                                }else if( returnVal == null) {
                                    var divCmp = component.find("formDiv");
                                    divCmp.set("v.body", []);
                                    var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));
                                    var record =  component.get("v.accountRef");
                                    helper.refreshRiskProfile(component, event, helper, true); 
                                }	
                                
                             if (typeof returnVal.Investment_philosophy__c == 'undefined'){
                                        updateRec["Risk_Profile_same_as_Family_Head__c"]  = false;
                                        updateRecord["Risk_Profile_same_as_Family_Head__c"]  = false;
                                 		 updateRecord["Risk_Profile_Categories__c"] = 'A - I agree & want RP to be basis of investment';
                                    }   
                            }if(state === "ERROR"){
                                 debugger;
                                caseRecord.Investment_philosophy__c = ' ';
                               /* caseRecord.Equity_Markets__c = ' ';
                                caseRecord.Age_RiskProfile__c = ' ';
                                caseRecord.Financial_Goals__c = ' ';
                                caseRecord.Investment_goal__c = ' ';
                                caseRecord.Amount_of_fluctuations__c = ' ';
                                caseRecord.Amount_of_fluctuations_Non_Ind__c = ' ';
                                caseRecord.worst_and_best_one_year_return__c = ' ';
                                caseRecord.worst_and_best_one_year_return_Non_Ind__c = ' ';
                                caseRecord.Interest_in_leverage_borrowing_products__c = ' ';
                                caseRecord.Interest_leverage_products_Non_Ind__c = ' ';
                                caseRecord.Diversified_portfolio__c = ' ';
                                caseRecord.Investment_portfolio__c = ' ';
                                caseRecord.Alternative_Investments__c = ' ';
                                 caseRecord.Alternative_Investments_Non_Ind__c = ' ';
                                caseRecord.Time_line_for_Trading__c = ' ';
                                caseRecord.Investment_Style__c = ' ';
                                caseRecord.Stop_Loss__c = '';
                                caseRecord.Direct_Equity__c = '';
                                caseRecord.Derivative__c = '';
                                caseRecord.Mutual_Funds__c = '';*/
                                caseRecord.Risk_Profile_Categories__c = 'A - I agree & want RP to be basis of investment';
                                component.set("v.caseRecord",caseRecord);
                                updateRecord["Investment_philosophy__c"] = ' ';
                               /* updateRecord["Equity_Markets__c"] = ' ';
                                updateRecord["Age_RiskProfile__c"] = ' ';
                                updateRecord["Financial_Goals__c"] = ' ';
                                updateRecord["Investment_goal__c"] = ' ';
                                updateRecord["Amount_of_fluctuations__c"] = ' ';
                                updateRecord["Amount_of_fluctuations_Non_Ind__c"] = ' ';
                                updateRecord["worst_and_best_one_year_return__c"] = ' ';
                                updateRecord["worst_and_best_one_year_return_Non_Ind__c"] = ' ';
                                updateRecord["Interest_in_leverage_borrowing_products__c"] = ' ';
                                updateRecord["Interest_leverage_products_Non_Ind__c"] = ' ';
                                updateRecord["Diversified_portfolio__c"] = ' ';
                                updateRecord["Investment_portfolio__c"] = ' ';
                                updateRecord["Alternative_Investments__c"] = ' ';
                                updateRecord["Alternative_Investments_Non_Ind__c"] = ' ';
                                updateRecord["Time_line_for_Trading__c"] = ' ';
                                updateRecord["Investment_Style__c"] = ' ';
                                updateRecord["Stop_Loss__c"] = ' ';
                                updateRecord["Direct_Equity__c"] = ' ';
                                updateRecord["Derivative__c"] = ' ';
                                updateRecord["Mutual_Funds__c"] = ' ';*/
                                updateRecord["Risk_Profile_Categories__c"] = 'A - I agree & want RP to be basis of investment';
                                updateRec["Investment_philosophy__c"] = ' ';
                               /* updateRec["Equity_Markets__c"] = ' ';
                                updateRec["Age_RiskProfile__c"] = ' ';
                                updateRec["Financial_Goals__c"] = ' ';
                                updateRec["Investment_goal__c"] = ' ';
                                updateRec["Amount_of_fluctuations__c"] = ' ';
                                updateRec["Amount_of_fluctuations_Non_Ind__c"] = ' ';
                                updateRec["worst_and_best_one_year_return__c"] = ' ';
                                updateRec["worst_and_best_one_year_return_Non_Ind__c"] = ' ';
                                updateRec["Interest_in_leverage_borrowing_products__c"] = ' ';
                                updateRec["Interest_leverage_products_Non_Ind__c"] = ' ';
                                updateRec["Diversified_portfolio__c"] = ' ';
                                updateRec["Investment_portfolio__c"] = ' ';
                                updateRec["Alternative_Investments__c"] = ' ';
                                 updateRec["Alternative_Investments_Non_Ind__c"] = ' ';
                                updateRec["Time_line_for_Trading__c"] = ' ';
                                updateRec["Investment_Style__c"] = ' ';
                                updateRec["Stop_Loss__c"] = '';
                                updateRec["Direct_Equity__c"] = '';
                                updateRec["Derivative__c"] = '';
                                updateRec["Mutual_Funds__c"] = '';*/
                                updateRec["Risk_Profile_Categories__c"] = 'A - I agree & want RP to be basis of investment';
                                
                            }
                            component.set("v.accountRef",JSON.parse(JSON.stringify(updateRecord)));
                            component.set("v.account",JSON.parse(JSON.stringify(updateRec)));
                            component.set("v.expand","Case Detail");
                            helper.renderSection(component, event, helper);
                            component.set("v.expand","false");
                        });
                        $A.enqueueAction(action1);    
                    } 
                    
                }
                
            }
            var familyType = component.get("v.FamilyType");
            var caseRecord = component.get("v.caseRecord");
            var updateRecord = component.get("v.accountRef");
            var updateRec = component.get("v.account");
            if(!(familyType['NewFamily']) && !(familyType['NewClient'])){
                caseRecord.Investment_philosophy__c = ' ';
                caseRecord.Equity_Markets__c = ' ';
                caseRecord.Age_RiskProfile__c = ' ';
                caseRecord.Financial_Goals__c = ' ';
                caseRecord.Investment_goal__c = ' ';
                caseRecord.Amount_of_fluctuations__c = ' ';
                caseRecord.Amount_of_fluctuations_Non_Ind__c = ' ';
                caseRecord.worst_and_best_one_year_return__c = ' ';
                caseRecord.worst_and_best_one_year_return_Non_Ind__c = ' ';
                caseRecord.Interest_in_leverage_borrowing_products__c = ' ';
                caseRecord.Interest_leverage_products_Non_Ind__c = ' ';
                caseRecord.Diversified_portfolio__c = ' ';
                caseRecord.Investment_portfolio__c = ' ';
                caseRecord.Alternative_Investments__c = ' ';
                caseRecord.Alternative_Investments_Non_Ind__c = ' ';
                caseRecord.Time_line_for_Trading__c = ' ';
                caseRecord.Investment_Style__c = ' ';
                caseRecord.Stop_Loss__c = '';
                caseRecord.Direct_Equity__c = '';
                caseRecord.Derivative__c = '';
                caseRecord.Mutual_Funds__c = '';
                component.set("v.caseRecord",caseRecord);
                updateRecord["Investment_philosophy__c"] = ' ';
                updateRecord["Equity_Markets__c"] = ' ';
                updateRecord["Age_RiskProfile__c"] = ' ';
                updateRecord["Financial_Goals__c"] = ' ';
                updateRecord["Investment_goal__c"] = ' ';
                updateRecord["Amount_of_fluctuations__c"] = ' ';
                updateRecord["Amount_of_fluctuations_Non_Ind__c"] = ' ';
                updateRecord["worst_and_best_one_year_return__c"] = ' ';
                updateRecord["worst_and_best_one_year_return_Non_Ind__c"] = ' ';
                updateRecord["Interest_in_leverage_borrowing_products__c"] = ' ';
                updateRecord["Interest_leverage_products_Non_Ind__c"] = ' ';
                updateRecord["Diversified_portfolio__c"] = ' ';
                updateRecord["Investment_portfolio__c"] = ' ';
                updateRecord["Alternative_Investments__c"] = ' ';
                updateRecord["Alternative_Investments_Non_Ind__c"] = ' ';
                updateRecord["Time_line_for_Trading__c"] = ' ';
                updateRecord["Investment_Style__c"] = ' ';
                updateRecord["Stop_Loss__c"] = ' ';
                updateRecord["Direct_Equity__c"] = ' ';
                updateRecord["Derivative__c"] = ' ';
                updateRecord["Mutual_Funds__c"] = ' ';
                updateRec["Investment_philosophy__c"] = ' ';
                updateRec["Equity_Markets__c"] = ' ';
                updateRec["Age_RiskProfile__c"] = ' ';
                updateRec["Financial_Goals__c"] = ' ';
                updateRec["Investment_goal__c"] = ' ';
                updateRec["Amount_of_fluctuations__c"] = ' ';
                updateRec["Amount_of_fluctuations_Non_Ind__c"] = ' ';
                updateRec["worst_and_best_one_year_return__c"] = ' ';
                updateRec["worst_and_best_one_year_return_Non_Ind__c"] = ' ';
                updateRec["Interest_in_leverage_borrowing_products__c"] = ' ';
                updateRec["Interest_leverage_products_Non_Ind__c"] = ' ';
                updateRec["Diversified_portfolio__c"] = ' ';
                updateRec["Investment_portfolio__c"] = ' ';
                updateRec["Alternative_Investments__c"] = ' ';
                 updateRec["Alternative_Investments_Non_Ind__c"] = ' ';
                updateRec["Time_line_for_Trading__c"] = ' ';
                updateRec["Investment_Style__c"] = ' ';
                updateRec["Stop_Loss__c"] = '';
                updateRec["Direct_Equity__c"] = '';
                updateRec["Derivative__c"] = '';
                updateRec["Mutual_Funds__c"] = '';
                
                
                component.set("v.accountRef",JSON.parse(JSON.stringify(updateRecord)));
                component.set("v.account",JSON.parse(JSON.stringify(updateRec)));
                helper.renderSection(component, event, helper);
            } 
            
            
            
            
            
            var account = component.get("v.account");
            if(event.getParam("fieldVal") != null && event.getParam("fieldName") == "Entity_Type__c"){
                if(accRec.Entity_Type__c == 'Individual'){
                    accRec.isCorporate__c = false;
                    accountRef.isCorporate__c = false;
                    account.isCorporate__c = false;
                    helper.refreshRiskProfile(component, event, helper, 'none'); 
                }else if(accRec.Entity_Type__c == 'HUF' || accRec.Entity_Type__c == 'Company' || accRec.Entity_Type__c == 'LLP' || accRec.Entity_Type__c == 'Partnership' || accRec.Entity_Type__c == 'Society'|| accRec.Entity_Type__c == 'Trust'||accRec.Entity_Type__c == 'AOP'){
                    accRec.isCorporate__c = true;
                    accountRef.isCorporate__c = true;
                    account.isCorporate__c = true;
                    helper.refreshRiskProfile(component, event, helper, 'none'); 
                }
                
            }
            component.set("v.account",account);
            if(accRec.Is_Family_Head__c && event.getParam("fieldName") == 'Is_Family_Head__c'){
                helper.isHead(component, event, helper);
            }
            if(event.getParam("fieldName") == 'Number_of_Joint_Holders_Max_2__c'){
                component.set("v.expand","Joint Holder Section");
                helper.renderSection(component, event, helper);
                component.set("v.expand","false");
            }
            
            if(accRec.Risk_Profile_same_as_Family_Head__c && !accRec.Is_Family_Head__c){
                
                var divCmp = component.find("formDiv");
                divCmp.set("v.body", []);
                var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));
                var record =  component.get("v.accountRef");
                helper.refreshRiskProfile(component, event, helper, 'false'); 
            }else if(!accRec.Risk_Profile_same_as_Family_Head__c && !accRec.Is_Family_Head__c){
                var divCmp = component.find("formDiv");
                divCmp.set("v.body", []);
                var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));
                var record =  component.get("v.accountRef");
                helper.refreshRiskProfile(component, event, helper, 'true'); 
                
            }
            /* var riskProfileEditable;
            var temp = accRec.Risk_Profile_same_as_Family_Head__c;
            var riskProfileforMainLead= component.get("v.riskProfileforMainLead");
            
            if (typeof temp != 'undefined'){
                component.set("v.riskProfileEditable",accRec.Risk_Profile_same_as_Family_Head__c);
                riskProfileEditable = accRec.Risk_Profile_same_as_Family_Head__c;
            }else{
                riskProfileEditable = true;
            }
		
            
            if(!riskProfileEditable && !riskProfileforMainLead){
                var divCmp = component.find("formDiv");
                divCmp.set("v.body", []);
                var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));
                var record =  component.get("v.accountRef");
                helper.refreshRiskProfile(component, event, helper, true);
            }if(riskProfileEditable && !riskProfileforMainLead){
                helper.refreshRiskProfile(component, event, helper, false);
            }
            if(riskProfileforMainLead){
                 helper.refreshRiskProfileForMainLead(component, event, helper, false);
            }*/
            
            
        }    
        
        component.set("v.account",JSON.parse(JSON.stringify(accRec)));
        component.set("v.accountRef",JSON.parse(JSON.stringify(accountRef)));
        
    },
    
    saveAccount : function(component, event, helper) {
        var ProcessingContainer = component.find('DetailProcessingContainer');
        $A.util.addClass(ProcessingContainer ,'slds-show');          
        $A.util.removeClass(ProcessingContainer ,'slds-hide');
        var accRec = component.get("v.account");
        accRec['RecordTypeId'] = component.get("v.RecordTypeId");
        accRec['Product_Type__c'] = component.get("v.ProductType"); 
        accRec['MainLead__c'] = accRec.AccountId;
        var sA = component.get("v.selectedAccount");
        helper.validateRecord(component,event,helper,accRec);
        var isValid = component.get("v.isValid");
        if(isValid){ 
            var cmpEvent = component.getEvent("cmpEvent");
            cmpEvent.setParams({ "caseobj" : accRec,
                                "accobj" : component.get("v.selectedAccount")
                               });
            cmpEvent.fire();
            if(accRec.Is_Family_Head__c){ 
                component.set("v.isFamilyHead",true);
            }
            component.set("v.isRecordAdded",true);
            var fType = component.get("v.FamilyType");
            if(!fType.ExistingClient)
                helper.refreshRecord(component, event, helper); 
            
        }
        $A.util.removeClass(ProcessingContainer ,'slds-show');
        $A.util.addClass(ProcessingContainer ,'slds-hide');
        
    },    
    editAccount: function(component, event, helper) {
        if(component.get("v.CompSource") == 'PatientSupport'){
            helper.editAccountDetails(component, event, helper);
        }
    },
    editAccountAHA: function(component, event, helper) {
        if(component.get("v.CompSource") == 'AccountAHA'){
            helper.editAccountDetails(component, event, helper);
        }
    },
    editAccountDHC: function(component, event, helper) {
        if(component.get("v.CompSource") == 'AccountDHC'){
            helper.editAccountDetails(component, event, helper);
        }
    },
    editAccountHIS: function(component, event, helper) {
        if(component.get("v.CompSource") == 'AccountHIS'){
            helper.editAccountDetails(component, event, helper);
        }
    }, 
    cancelfn: function(component, event, helper) {
        var fType = component.get("v.FamilyType");
        if(!fType.ExistingClient)
            helper.refreshRecord(component, event, helper);
        else{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
            });
            urlEvent.fire();
        }
    },
    updateProduct: function(component, event, helper) { 
        var whichOne = event.getSource().getLocalId();        
        var checkCmp = component.find(whichOne)
        var SingleJoint = '';
        if(whichOne == "Demat"){
            component.set("v.isDemat",(checkCmp.get("v.value")) ? true : false); 
            SingleJoint = component.find("SingleJoint").get("v.value");
            var accRec = component.get("v.account");
            accRec['Single_Joint__c'] = SingleJoint;
            component.set("v.account",JSON.parse(JSON.stringify(accRec)));
        }
        var pType = component.get("v.ProductType");
        if(checkCmp.get("v.value")){          
            pType = (pType == null || pType == '')? whichOne : pType +';'+whichOne  
        }        	
        else {
            pType = pType.replace(';'+whichOne,'');  
            pType = pType.replace(whichOne,'');
        } 
        pType = pType.replace(/(^\;+|\;+$)/mg, '');
        component.set("v.ProductType",pType);
        if(whichOne == 'Trading' || whichOne == 'Funding' || whichOne == 'Demat'){
            
            //Set default values for Trading Section fields
            if(whichOne == 'Trading' && checkCmp.get("v.value")){
                console.log('Account Ref data : ', component.get("v.accountRef"));
                var accRecTemp = component.get("v.accountRef");
                accRecTemp["Delivery_Slab__c"] = 0.50;
                accRecTemp["Intraday_Slab__c"] = 0.05;
                accRecTemp["Delivery_Minimum_P__c"] = 0.03;
                accRecTemp["Intraday_Minimum_P__c"] = 0.01;
                accRecTemp["Currency_Futures_Slab__c"] = 10.00;
                accRecTemp["Currency_Options_Slab__c"] = 10.00;
                accRecTemp["Currency_Futures_Minimum_P__c"] = 0.01;
                accRecTemp["Currency_Options_Minimum_P__c"] = 0.01;
                accRecTemp["Derivatives_Futures_Slab__c"] = 0.50;
                accRecTemp["Derivatives_Options_Slab__c"] = 50.00;
                accRecTemp["Derivatives_Futures_Minimum_P__c"] = 0.03;
                accRecTemp["Derivatives_Options_Minimum_P__c"] = 0.01;
                accRecTemp["Delivery_Sides__c"] = 'One';
                accRecTemp["Intraday_Sides__c"] = 'One';
                accRecTemp["Derivatives_Futures_Sides__c"] = 'One';
                accRecTemp["Derivatives_Options_Sides__c"] = 'One';
                accRecTemp["Currency_Options_Sides__c"] = 'One';
                accRecTemp["Currency_Futures_Sides__c"] = 'One';
                component.set("v.account",accRecTemp);
                component.set("v.accountRef",JSON.parse(JSON.stringify(accRecTemp)));
            }
            helper.renderSection(component, event, helper);
        }
    },
    onSelectDemat : function(component, event, helper) { 
        var SingleJoint = component.find("SingleJoint").get("v.value");
        var accRec = component.get("v.account");
        accRec['Single_Joint__c'] = SingleJoint;
        component.set("v.account",JSON.parse(JSON.stringify(accRec)));
        helper.renderSection(component, event, helper);        
    },
    
})