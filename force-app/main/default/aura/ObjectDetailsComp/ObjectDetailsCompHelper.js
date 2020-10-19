({
    createFormCmp:function(cmp,divCmp,flag,record,isExpand){       
        var self=this;
        var fieldSet = JSON.parse(JSON.stringify(cmp.get("v.selectedFieldSetMap")));
        fieldSet = self.refreshFieldSetData(cmp,fieldSet,record);
        $A.createComponent(
            "c:CreateSections",
            {
                "fieldSetMap":fieldSet ,
                "isReadOnly" : flag,
                "record" : record,
                "isSubsection" : cmp.get("v.isSubsection"),
                "CompSource" : cmp.get("v.CompSource"),
                "isObjUpdateable" : cmp.get("v.isObjUpdateable"),
                "isSingleColumnSection" : cmp.get("v.isSingleColumnSection"),
                "parentAccountId" : cmp.get("v.parentAccountId"),
                "expand" : cmp.get("v.expand"),
                "lookupFilter" : cmp.get("v.lookupFilter"),
                "FamilyType" : cmp.get("v.FamilyType"),
                "isCaseCreated": cmp.get("v.isCaseCreated"),
                "isEnabledTradingFeilds": cmp.get('v.isEnabledTradingFeilds')
            },
            function(newCmp){
                self.insertNewCmp(divCmp,newCmp);
            }
        );
    },
    insertNewCmp:function(divCmp,newCmp){
        var divBody = divCmp.get("v.body");
        divBody.push(newCmp);
        divCmp.set("v.body", divBody); 
    },
    cancelfn: function(cmp,event,helper){
        cmp.set("v.iscalledFromCancel",true);
        cmp.set("v.isReadOnly",true);
        var EditBtn = cmp.find('DetailEditBtnSection');
        $A.util.addClass(EditBtn ,'slds-hide');
        $A.util.removeClass(EditBtn ,'slds-show');
        helper.renderDiv(cmp, event, helper);
    },
    renderDiv: function(component,event,helper){
        var divCmp = component.find("formDiv");
        divCmp.set("v.body", []);
        if(component.get("v.iscalledFromCancel") == true){
            helper.createFormCmp(component,divCmp ,component.get("v.isReadOnly"),component.get("v.oldAccountRef")); 	
            component.set("v.iscalledFromCancel",false);	
        }    
        else {
            helper.createFormCmp(component , divCmp ,component.get("v.isReadOnly"),component.get("v.accountRef"));
        }
    },
    editAccountDetails: function(component,event,helper){  
        component.set("v.isReadOnly",false);
        var EditBtn = component.find('DetailEditBtnSection');
        $A.util.addClass(EditBtn,'slds-show');
        $A.util.removeClass(EditBtn,'slds-hide');
        var outerPanel = component.find('DetailOuterPanel');
        $A.util.addClass(outerPanel, 'box-shadow');
        helper.renderDiv(component, event, helper);
    },
    clearAllProductType : function(component,event,helper) {    
        var checkCmp = component.find("Trading");
        checkCmp.set("v.value",false);
        checkCmp = component.find("Demat");
        checkCmp.set("v.value",false);
        checkCmp = component.find("POA");
        checkCmp.set("v.value",false);
        /*checkCmp = component.find("Miles");
        checkCmp.set("v.value",false);*/
        checkCmp = component.find("Advisory");
        checkCmp.set("v.value",false);
        checkCmp = component.find("Funding");
        checkCmp.set("v.value",false);
        checkCmp = component.find("ComodityTrad");
        checkCmp.set("v.value",false);
        checkCmp = component.find("ComodityTrack");
        checkCmp.set("v.value",false);
    },
    refreshRecord : function(component,event,helper) {
        var accInfo = component.get("v.accountRef");
        var rec = {};
        var caseRecord = component.get("v.caseRecord");
        debugger;
        var familyType = component.get("v.FamilyType");
        var isMainLead = component.get("v.isMainLead"); 
        var mainLeadCaseRecord = component.get("v.mainLeadCaseRecord"); 
        if((familyType['NewFamily']) && (familyType['NewClient'])){
            
            if(accInfo.Is_Family_Head__c){
                mainLeadCaseRecord.Investment_philosophy__c = accInfo.Investment_philosophy__c;
                mainLeadCaseRecord.Equity_Markets__c = accInfo.Equity_Markets__c;
                mainLeadCaseRecord.Age_RiskProfile__c = accInfo.Age_RiskProfile__c;
                mainLeadCaseRecord.Financial_Goals__c  = accInfo.Financial_Goals__c;
                mainLeadCaseRecord.Investment_goal__c  = accInfo.Investment_goal__c;
                mainLeadCaseRecord.Amount_of_fluctuations__c = accInfo.Amount_of_fluctuations__c;
                mainLeadCaseRecord.Amount_of_fluctuations_Non_Ind__c = accInfo.Amount_of_fluctuations_Non_Ind__c;
                mainLeadCaseRecord.worst_and_best_one_year_return__c  = accInfo.worst_and_best_one_year_return__c;
                mainLeadCaseRecord.worst_and_best_one_year_return_Non_Ind__c  = accInfo.worst_and_best_one_year_return_Non_Ind__c;
                mainLeadCaseRecord.Interest_in_leverage_borrowing_products__c  = accInfo.Interest_in_leverage_borrowing_products__c;
                mainLeadCaseRecord.Interest_leverage_products_Non_Ind__c  = accInfo.Interest_leverage_products_Non_Ind__c;

                mainLeadCaseRecord.Diversified_portfolio__c  = accInfo.Diversified_portfolio__c;
                mainLeadCaseRecord.Investment_portfolio__c  = accInfo.Investment_portfolio__c;
                mainLeadCaseRecord.Alternative_Investments__c = accInfo.Alternative_Investments__c;
                 mainLeadCaseRecord.Alternative_Investments_Non_Ind__c = accInfo.Alternative_Investments_Non_Ind__c;
                mainLeadCaseRecord.Time_line_for_Trading__c  = accInfo.Time_line_for_Trading__c;
                mainLeadCaseRecord.Investment_Style__c  = accInfo.Investment_Style__c;
                mainLeadCaseRecord.Stop_Loss__c = accInfo.Stop_Loss__c;
                mainLeadCaseRecord.Direct_Equity__c = accInfo.Direct_Equity__c;
                mainLeadCaseRecord.Derivative__c = accInfo.Derivative__c;
                mainLeadCaseRecord.Mutual_Funds__c = accInfo.Mutual_Funds__c;	
                mainLeadCaseRecord.Risk_Profile_same_as_Family_Head__c = true;
                mainLeadCaseRecord.Risk_Profile_Categories__c = accInfo.Risk_Profile_Categories__c;
                component.set("v.mainLeadCaseRecord",mainLeadCaseRecord);         
            }
            
            if (typeof mainLeadCaseRecord.Investment_philosophy__c != 'undefined'){
                rec["Investment_philosophy__c"] = mainLeadCaseRecord.Investment_philosophy__c;
                rec["Equity_Markets__c"] = mainLeadCaseRecord.Equity_Markets__c;
                rec["Age_RiskProfile__c"] = mainLeadCaseRecord.Age_RiskProfile__c;
                rec["Financial_Goals__c"] = mainLeadCaseRecord.Financial_Goals__c;
                rec["Investment_goal__c"] = mainLeadCaseRecord.Investment_goal__c;
                rec["Amount_of_fluctuations__c"] = mainLeadCaseRecord.Amount_of_fluctuations__c;
                 rec["Amount_of_fluctuations_Non_Ind__c"] = mainLeadCaseRecord.Amount_of_fluctuations_Non_Ind__c;
                rec["worst_and_best_one_year_return__c"] = mainLeadCaseRecord.worst_and_best_one_year_return__c;
                rec["worst_and_best_one_year_return_Non_Ind__c"] = mainLeadCaseRecord.worst_and_best_one_year_return_Non_Ind__c;
                rec["Interest_in_leverage_borrowing_products__c"] = mainLeadCaseRecord.Interest_in_leverage_borrowing_products__c;
                rec["Interest_leverage_products_Non_Ind__c"] = mainLeadCaseRecord.Interest_leverage_products_Non_Ind__c;
                rec["Diversified_portfolio__c"] = mainLeadCaseRecord.Diversified_portfolio__c;
                rec["Investment_portfolio__c"] = mainLeadCaseRecord.Investment_portfolio__c;
                rec["Alternative_Investments__c"] = mainLeadCaseRecord.Alternative_Investments__c;
                rec["Alternative_Investments_Non_Ind__c"] = mainLeadCaseRecord.Alternative_Investments_Non_Ind__c;
                rec["Time_line_for_Trading__c"] = mainLeadCaseRecord.Time_line_for_Trading__c;
                rec["Investment_Style__c"] = mainLeadCaseRecord.Investment_Style__c;
                rec["Stop_Loss__c"] = mainLeadCaseRecord.Stop_Loss__c;
                rec["Direct_Equity__c"] = mainLeadCaseRecord.Direct_Equity__c;
                rec["Derivative__c"] = mainLeadCaseRecord.Derivative__c;
                rec["Mutual_Funds__c"] = mainLeadCaseRecord.Mutual_Funds__c;	
                rec["Risk_Profile_same_as_Family_Head__c"] = true;
                rec["Risk_Profile_Categories__c"] = mainLeadCaseRecord.Risk_Profile_Categories__c; 	
            }else if(typeof caseRecord.Investment_philosophy__c != 'undefined'){
                rec["Investment_philosophy__c"] = caseRecord.Investment_philosophy__c;
                rec["Equity_Markets__c"] = caseRecord.Equity_Markets__c;
                rec["Age_RiskProfile__c"] = caseRecord.Age_RiskProfile__c;
                rec["Financial_Goals__c"] = caseRecord.Financial_Goals__c;
                rec["Investment_goal__c"] = caseRecord.Investment_goal__c;
                rec["Amount_of_fluctuations__c"] = caseRecord.Amount_of_fluctuations__c;
                rec["Amount_of_fluctuations_Non_Ind__c"] = caseRecord.Amount_of_fluctuations_Non_Ind__c;
                rec["worst_and_best_one_year_return__c"] = caseRecord.worst_and_best_one_year_return__c;
                 rec["worst_and_best_one_year_return_Non_Ind__c"] = caseRecord.worst_and_best_one_year_return_Non_Ind__c;
                rec["Interest_in_leverage_borrowing_products__c"] = caseRecord.Interest_in_leverage_borrowing_products__c;
                rec["Interest_leverage_products_Non_Ind__c"] = caseRecord.Interest_leverage_products_Non_Ind__c;
                rec["Diversified_portfolio__c"] = caseRecord.Diversified_portfolio__c;
                rec["Investment_portfolio__c"] = caseRecord.Investment_portfolio__c;
                rec["Alternative_Investments__c"] = caseRecord.Alternative_Investments__c;
                rec["Alternative_Investments_Non_Ind__c"] = caseRecord.Alternative_Investments_Non_Ind__c;
                rec["Time_line_for_Trading__c"] = caseRecord.Time_line_for_Trading__c;
                rec["Investment_Style__c"] = caseRecord.Investment_Style__c;
                rec["Stop_Loss__c"] = caseRecord.Stop_Loss__c;
                rec["Direct_Equity__c"] = caseRecord.Direct_Equity__c;
                rec["Derivative__c"] = caseRecord.Derivative__c;
                rec["Mutual_Funds__c"] = caseRecord.Mutual_Funds__c;	
                rec["Risk_Profile_same_as_Family_Head__c"] = true;
                rec["Risk_Profile_Categories__c"] = caseRecord.Risk_Profile_Categories__c;     
            }
        }
        rec['AccountId'] =accInfo.AccountId; 
        rec['Account'] =accInfo.Account; 
        rec['Family__c'] = accInfo.Family__c;
        
        if(!(familyType['NewFamily']) && (familyType['NewClient'])){
            if(caseRecord.Investment_philosophy__c == ' '){
                rec["Risk_Profile_same_as_Family_Head__c"] = false;
                rec["Risk_Profile_Categories__c"] = 'A - I agree & want RP to be basis of investment';
            }else{
                rec["Investment_philosophy__c"] = caseRecord.Investment_philosophy__c;
                rec["Equity_Markets__c"] = caseRecord.Equity_Markets__c;
                rec["Age_RiskProfile__c"] = caseRecord.Age_RiskProfile__c;
                rec["Financial_Goals__c"] = caseRecord.Financial_Goals__c;
                rec["Investment_goal__c"] = caseRecord.Investment_goal__c;
                rec["Amount_of_fluctuations__c"] = caseRecord.Amount_of_fluctuations__c;
                rec["Amount_of_fluctuations_Non_Ind__c"] = caseRecord.Amount_of_fluctuations_Non_Ind__c;
                rec["worst_and_best_one_year_return__c"] = caseRecord.worst_and_best_one_year_return__c;
                rec["worst_and_best_one_year_return_Non_Ind__c"] = caseRecord.worst_and_best_one_year_return_Non_Ind__c;
                rec["Interest_in_leverage_borrowing_products__c"] = caseRecord.Interest_in_leverage_borrowing_products__c;
                rec["Interest_leverage_products_Non_Ind__c"] = caseRecord.Interest_leverage_products_Non_Ind__c;
                rec["Diversified_portfolio__c"] = caseRecord.Diversified_portfolio__c;
                rec["Investment_portfolio__c"] = caseRecord.Investment_portfolio__c;
                rec["Alternative_Investments__c"] = caseRecord.Alternative_Investments__c;
                rec["Alternative_Investments_Non_Ind__c"] = caseRecord.Alternative_Investments_Non_Ind__c;
                rec["Time_line_for_Trading__c"] = caseRecord.Time_line_for_Trading__c;
                rec["Investment_Style__c"] = caseRecord.Investment_Style__c;
                rec["Stop_Loss__c"] = caseRecord.Stop_Loss__c;
                rec["Direct_Equity__c"] = caseRecord.Direct_Equity__c;
                rec["Derivative__c"] = caseRecord.Derivative__c;
                rec["Mutual_Funds__c"] = caseRecord.Mutual_Funds__c;	
                rec["Risk_Profile_same_as_Family_Head__c"] = true;
                rec["Risk_Profile_Categories__c"] = caseRecord.Risk_Profile_Categories__c;    
            }
        }
        component.set("v.account",JSON.parse(JSON.stringify(rec)));
        component.set("v.accountRef",JSON.parse(JSON.stringify(rec)));
        component.set("v.oldAccount",JSON.parse(JSON.stringify(rec)));
        component.set("v.oldAccountRef",JSON.parse(JSON.stringify(rec)));
        helper.clearAllProductType(component, event, helper);
        var fieldMap = component.get("v.fieldSetMap");
        var selectedMap = {};
        for(var f in fieldMap){
            if(!f.includes("Funding") && !f.includes("Trading") && !f.includes("Joint"))
                selectedMap[f] = fieldMap[f]
                }                
        component.set("v.selectedFieldSetMap",selectedMap);
        component.set("v.isDemat", false); 
        var familyType = component.get("v.FamilyType");
        if(!familyType.ExistingClient){
            component.set("v.ProductType",'Miles');                   
        }else{
            component.set("v.ProductType",'');
        }
        
        var record =  component.get("v.accountRef");
        if(record.Risk_Profile_same_as_Family_Head__c == true){
            helper.refreshRiskProfile(component, event, helper, 'false'); 
        }else if(record.Risk_Profile_same_as_Family_Head__c == false){
            helper.refreshRiskProfile(component, event, helper, 'true'); 
        }
        
        helper.renderDiv(component, event, helper);
    },
    refreshFieldSetData : function(component,fieldSet,record){
        if(record.Number_of_Joint_Holders_Max_2__c == "1" && fieldSet['Joint Holder Section'] != null){
            var index = 0;
            var artlnght = fieldSet['Joint Holder Section'].Col2.length
            for(var i=0; i < artlnght; i++){
                var f = fieldSet['Joint Holder Section'].Col2[index];
                if(f != null && f.fieldPath.includes('Joint_Holder_Client2')){
                    fieldSet['Joint Holder Section'].Col2.splice(index, 1); 
                }else{
                    index++; 
                }                
            }            
        }
        
        var familyType = component.get("v.FamilyType");
        var isCaseCreated = component.get("v.isCaseCreated");
        var isRecordAdded = component.get("v.isRecordAdded");
        var isCorporate = component.get("v.isCorporate");
        for(var i in fieldSet['Case Detail'].Col2){
            var f = fieldSet['Case Detail'].Col2[i];
            if(f != null && f.fieldPath.includes('Is_Family_Head__c') && !isCaseCreated && !isRecordAdded){
                fieldSet['Case Detail'].Col2[i].isEditable = true;
                //record.Is_Family_Head__c = true;
                component.set("v.isMainLead", true); 
                break;
            } else if(f != null && f.fieldPath.includes('Is_Family_Head__c') && (isCaseCreated || isRecordAdded)){
                fieldSet['Case Detail'].Col2.splice(i, 1);
                record.isAdditionalLead = true;
                component.set("v.isAdditionalLead", true); 
                break;
            }
        }
        
        if(familyType['NewFamily']){
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Section__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2[i].label = '            ';
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2[i].label = '   ';
                    break;
                }
            } 
             for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_3__c')){
                    fieldSet['Case Detail'].Col2[i].label = '   ';
                    break;
                }
            } 
             for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_3__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
               for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_4__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                var fApi = '';
                if(!isRecordAdded && !isCaseCreated) {
                    fApi = 'Client_Name__c' ;
                }
                
                if(f != null && fApi != '' && f.fieldPath.includes(fApi)){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
                
                if(f != null && f.fieldPath.includes('Family__c') && isRecordAdded){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
                
            }
            if(record.isCorporate__c == true){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                
 					for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }                 
                
                
                
            }else if(record.isCorporate__c == false){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }

                
            }
            // If Its a main Lead
            var isMainLead = component.get("v.isMainLead"); 
            if( record.Is_Family_Head__c == true){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Risk_Profile_same_as_Family_Head__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
            }
            
            
            // If Its a Additional Lead
            var isAdditionalLead =  component.get("v.isAdditionalLead");
            if(record.isAdditionalLead__c && record.Risk_Profile_same_as_Family_Head__c == true){
                // Gryed out additional lead scenario
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                    }
                    
                    if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }  
                    
                    if(f != null && f.fieldPath.includes('Investment_philosophy__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Risk_Profile_Categories__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }  
                     if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }
                    if(f != null && f.fieldPath.includes('Diversified_portfolio__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }  
                    if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }
                    if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }
                    if(f != null && f.fieldPath.includes('Investment_portfolio__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }         
                    if(f != null && f.fieldPath.includes('Investment_Style__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Time_line_for_Trading__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Stop_Loss__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }      
                    if(f != null && f.fieldPath.includes('Direct_Equity__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Derivative__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Mutual_Funds__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                     if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Financial_Goals__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }         
                    if(f != null && f.fieldPath.includes('Investment_goal__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }       
                } 
                
                
                
            }
        }else if(familyType['NewClient']){
             if (record.Risk_Profile_same_as_Family_Head__c != true){
       
                  for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Risk_Profile_same_as_Family_Head__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
            }
            
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Section__c')){
                    fieldSet['Case Detail'].Col2[i].label = 'Risk Profile Section';
                    break;
                }
            } 
                for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Section__c')){
                   fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2[i].label = '            ';
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2[i].label = '   ';
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            
              for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_3__c')){
                    fieldSet['Case Detail'].Col2[i].label = '            ';
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_4__c')){
                    fieldSet['Case Detail'].Col2[i].label = '   ';
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_3__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_4__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
            } 
            
            
            
            
            if(record.isCorporate__c == true){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                
				
 					for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }                 
                
                
            }else if(record.isCorporate__c == false){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                } 
                
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                 for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                  for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }
                }
                
                
                
                
                
                
                
            }
            
            if(record.Risk_Profile_same_as_Family_Head__c == true){
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                    }
                    if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }  
                    
                    if(f != null && f.fieldPath.includes('Investment_philosophy__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Risk_Profile_Categories__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }  
                    if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Diversified_portfolio__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }
                    if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }    
                    if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Investment_portfolio__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }         
                    if(f != null && f.fieldPath.includes('Investment_Style__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Time_line_for_Trading__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }     
                    if(f != null && f.fieldPath.includes('Stop_Loss__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }      
                    if(f != null && f.fieldPath.includes('Direct_Equity__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Derivative__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('Mutual_Funds__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }   
                    if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    } 
                    if(f != null && f.fieldPath.includes('Financial_Goals__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }         
                    if(f != null && f.fieldPath.includes('Investment_goal__c')){
                        fieldSet['Case Detail'].Col2[i].isEditable = true;
                        
                    }
                    
                    
                    
                }
            }       
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                var fApi = 'Client_Name__c' ;
                //var fApi = 'AccountId' ;
                if(f != null && f.fieldPath.includes(fApi) && isRecordAdded){
                    //fieldSet['Case Detail'].Col2.splice(i, 1); //commented to add Additional Client Name filed for Existing Family New Client
                    break;
                }   
                /* if(f != null && f.fieldPath.includes('PAN_Number__c')){
                   record.PAN_Number__c = '';
                    break;
                }*/
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Family__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }         
                }
                
                for(var i in fieldSet['Case Detail'].Col2){
                    var f = fieldSet['Case Detail'].Col2[i];
                    if(f != null && f.fieldPath.includes('Is_Family_Head__c')){
                        fieldSet['Case Detail'].Col2.splice(i, 1);
                        break;
                    }         
                }
                
                
            }
        }else{
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('PAN_Number__c')){
                    //fieldSet['Case Detail'].Col2[i].isEditable = true;
                    break;
                }
                
            }  
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Client_Name__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Is_Family_Head__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Family__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_same_as_Family_Head__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Section__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blanck_label__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('RiskProfile_Blank_label_2__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
                        for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_3__c')){
                     fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
               for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Blank_label_4__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }
            } 
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Investment_philosophy__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Risk_Profile_Categories__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Diversified_portfolio__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }				
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Investment_portfolio__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Investment_Style__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Time_line_for_Trading__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Stop_Loss__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }			
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Direct_Equity__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }		
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Derivative__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }				
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Mutual_Funds__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }				
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Financial_Goals__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }		
            
            
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Investment_goal__c')){
                    fieldSet['Case Detail'].Col2.splice(i, 1);
                    break;
                }         
            }	
            
            
        }
        return fieldSet;
    },
    validatePAN : function(component,event,helper,panNumber,isValid,toastmsg){
        if(panNumber !=null && panNumber !=''){
            var panVal = panNumber;
            var regpan = /^([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}?$/;
            if(!regpan.test(panVal)){
                isValid =  false;
                helper.showToast(toastmsg); 
                component.set("v.isValid",isValid);  
            }   
        }        
        return isValid;
    },
    validateAadhar : function(component,event,helper,aadharNumber,isValid,toastmsg){
        if( aadharNumber != null && aadharNumber != ''){           
            if(isNaN(aadharNumber)){
                isValid =  false;
                helper.showToast(toastmsg);  
            }
            else{
                var Clength = (aadharNumber).toString().length;
                if(Clength != 12){
                    isValid =  false;
                    helper.showToast(toastmsg);  
                }
            }
            component.set("v.isValid",isValid);  
        }
        return isValid;
    },
    validatePhone : function(component,event,helper,number,isValid,toastmsg){
        if( number != null && number != ''){
            number = number.replace(/\s/g,'');
            if(isNaN(number)){
                isValid =  false;
                helper.showToast(toastmsg);  
            }
            else{
                var Clength = (number).length;
                if(Clength != 10){
                    isValid =  false;
                    helper.showToast(toastmsg);  
                }
            }
            component.set("v.isValid",isValid);  
        }
        return isValid;
    },
    validateEmail : function(component,event,helper,email,isValid,toastmsg){
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if(email !=null && email != ''){
            if (!filter.test(email)) {
                isValid = false;
                helper.showToast(toastmsg);  
            }
            component.set("v.isValid",isValid);
        } 
        return isValid;
    },    
    validateDOB : function(component,event,helper,isValid,toastmsg,date){
        var today = new Date();
        if(date != null && date != ''){
            var myDate = new Date(date);        
            if(myDate != null && date.match(/^(\d{4})-(\d{2})-(\d{2})$/) != null){
                if(myDate>today){
                    isValid = false;   
                    component.set("v.isValid",false);
                    helper.showToast(toastmsg);
                }
            }else{
                isValid = false;   
                component.set("v.isValid",false);
                helper.showToast(toastmsg);
            } 
        }
        
        return isValid;
    },
      validateStatus : function(component,event,helper,status,isValid,toastmsg){
        if( status != null && status != ''){ 
            if(status == 'Closed – Success' || status == 'Closed – Rejected'){
                isValid =  false;
                helper.showToast(toastmsg);  
            }
            component.set("v.isValid",isValid);  
        }
        return isValid;
    },
    validateData : function(component,event,helper,accRec,isValid){
        if(isValid){      
            isValid = helper.validatePhone(component,event,helper,accRec.Phone__c,isValid,'Error In Case Detail Section : Invalid Contact Number');
            if(isValid) isValid = helper.validatePhone(component,event,helper,accRec.Joint_Holder_Client1_Contact_Number__c,isValid,'Error In Joint Holder : Invalid client 1 Contact Number') ;      
            if(isValid) isValid = helper.validatePhone(component,event,helper,accRec.Joint_Holder_Client2_Contact_Number__c,isValid,'Error In Joint Holder : Invalid client 2 Contact Number');
            if(isValid) isValid = helper.validateEmail(component,event,helper,accRec.Email_Id__c,isValid,'Case Detail Section : Invalid Email');
            if(isValid) isValid = helper.validateEmail(component,event,helper,accRec.Joint_Holder_Client1_Email_ID__c,isValid,'Error In Joint Holder : Invalid Email for client 1');
            if(isValid) isValid = helper.validateEmail(component,event,helper,accRec.Joint_Holder_Client2_Email_ID__c,isValid,'Error In Joint Holder : Invalid Email for client 2');
            if(isValid) isValid = helper.validateDOB(component,event,helper,isValid,'Error In Case Details : Invalid DOB/DOI',accRec.DOB_DOI__c);
            if(isValid) isValid = helper.validateDOB(component,event,helper,isValid,'Error In Joint Holder : Invalid DOB/DOI for client 1',accRec.Joint_Holder_Client1_DOB_DOI__c );
            if(isValid) isValid = helper.validateDOB(component,event,helper,isValid,'Error In Joint Holder : Invalid DOB/DOI for client 2',accRec.Joint_Holder_Client2_DOB_DOI__c );
            if(isValid) isValid = helper.validatePAN(component,event,helper,accRec.PAN_Number__c,isValid,'Invalid PAN Number') ;
            if(isValid) isValid = helper.validateAadhar(component,event,helper,accRec.Aadhar_number__c,isValid,'Invalid Aadhar Number') ;
            if(isValid) isValid = helper.validateAadhar(component,event,helper,accRec.Joint_Holder_Client1_Aadhar_Number__c,isValid,'Invalid Aadhar Number in Joint holder section for client 1') ;
            if(isValid) isValid = helper.validateAadhar(component,event,helper,accRec.Joint_Holder_Client1_Aadhar_Number__c,isValid,'Invalid Aadhar Number in Joint holder section for client 2') ;
            if(isValid) isValid = helper.validateStatus(component,event,helper,component.get("v.status"),isValid,'Status cannot be Closed – Success or Closed – Rejected') ;
        } 
        return isValid;
    },
    validateRecord : function(component,event,helper,accRec){
        var selectedMap = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap"))); 
        selectedMap = helper.refreshFieldSetData(component,selectedMap,accRec);
        var fieldSetMap = JSON.parse(JSON.stringify(selectedMap));
        var msgs = '';
        var fill = 'Please fill below mandatory details : ';
        var isValid =  true;
        var pType = component.get("v.ProductType");        
        if(pType == null || pType == ''){
            isValid = false;
            component.set("v.isValid",false);
            helper.showToast('Please Select Prodcut Type');
        }
        
        if(isValid){
            for(var f in fieldSetMap){
                var fieldArr = fieldSetMap[f].Col2;
                for(var fIndex in fieldArr){
                    var field = fieldArr[fIndex];
                    if(field.required && (accRec[field.fieldPath] == null ||accRec[field.fieldPath] == '' )){
                        msgs = msgs+ field.label + ', ';
                        isValid =  false; 
                    }
                }
            }
            msgs = msgs.trim();
            msgs = msgs.replace('"', ' ');
            var n = msgs.endsWith(",");
            if(n){
                msgs = msgs.substring(0,(msgs.length-1));
            }            
            if(!isValid){
                helper.showToast(fill + msgs);
                component.set("v.isValid",isValid);
            }else{
                isValid = helper.validateData(component,event,helper,accRec,isValid);
                component.set("v.isValid",isValid);
            }
        }
        
        if(pType != null && pType.includes('Demat')){
            if(accRec.Entity_Type__c == 'Company' || accRec.Entity_Type__c == 'LLP' || accRec.Entity_Type__c == 'HUF'){
                if(accRec.Joint_Holder_Client1_Aadhar_Number__c != null ||
                   accRec.Joint_Holder_Client1_Contact_Number__c != null ||
                   accRec.Joint_Holder_Client1_DOB_DOI__c != null ||
                   accRec.Joint_Holder_Client1_Email_ID__c != null ||
                   accRec.Joint_Holder_Client1_Entity_Type__c != null ||
                   accRec.Joint_Holder_Client1_Name__c != null ||
                   accRec.Joint_Holder_Client1_PAN_Number__c != null ||
                   accRec.Joint_Holder_Client2_Aadhar_Number__c != null ||
                   accRec.Joint_Holder_Client2_Contact_Number__c != null ||
                   accRec.Joint_Holder_Client2_DOB_DOI__c != null ||
                   accRec.Joint_Holder_Client2_Email_ID__c != null ||
                   accRec.Joint_Holder_Client2_Entity_Type__c != null ||
                   accRec.Joint_Holder_Client2_Name__c != null ||
                   accRec.Joint_Holder_Client2_PAN_Number__c != null){
                    isValid = false;
                    component.set("v.isValid",false);
                    helper.showToast('Joint holder section should not have any value as Entity Type is selected as Componey, LLP OR HUF');
                }               
            } 
            
        }
        
    },
    showToast : function(msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "message": msg
        });
        toastEvent.fire();
    },
    renderSection : function(component,event,helper){
        var fieldMap = component.get("v.fieldSetMap");
        var pType = component.get("v.ProductType");
        var ele = component.find("SingleJoint");
        var SingleJoint = '';
        if(ele != null){
            SingleJoint = ele.get("v.value");
        } 
        
        var selectedMap = {};
        if(pType != null && pType != ''){
            for(var f in fieldMap){
                if(f.includes("Funding") && pType.includes("Funding") ){                
                    selectedMap[f] = fieldMap[f];
                }
                if(f.includes("Trading")  && pType.includes("Trading")){
                    selectedMap[f] = fieldMap[f];
                }
                if(f.includes("Joint")  && pType.includes("Demat") && SingleJoint == 'Joint'){
                    selectedMap[f] = fieldMap[f];
                }
                if(!f.includes("Trading") && !f.includes("Funding") && !f.includes("Joint")){
                    selectedMap[f] = fieldMap[f];    
                }           
            }  
        }else{
            for(var f in fieldMap){
                if(!f.includes("Funding") && !f.includes("Trading") && !f.includes("Joint"))
                    selectedMap[f] = fieldMap[f]
                    } 
        }
        
        component.set("v.selectedFieldSetMap",selectedMap); 
        helper.renderDiv(component, event, helper); 
    },
    refreshRiskProfileForMainLead : function(component,event,helper,isEditable){
        var fieldMap = component.get("v.fieldSetMap");
        var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));    
        var temp = component.get("v.riskProfileEditable");
        component.set("v.expand",'Case Detail');
        component.set("v.selectedFieldSetMap",fieldSet);         
        helper.renderDiv(component, event, helper); 
        
    },
    refreshRiskProfile : function(component,event,helper,isEditable){
        debugger;
        var fieldMap = component.get("v.fieldSetMap");
        var fieldSet = JSON.parse(JSON.stringify(component.get("v.selectedFieldSetMap")));    
        var temp = component.get("v.riskProfileEditable");
        var riskProfileEditable;
        if (typeof temp != 'undefined'){
            var riskProfileEditable = temp;
        } else{
            riskProfileEditable = true;
        }        
        
        if(isEditable == 'true'){
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                }
                if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }  
                
                if(f != null && f.fieldPath.includes('Investment_philosophy__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }    
                if(f != null && f.fieldPath.includes('Risk_Profile_Categories__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                } 
                
                if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }  
                 if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }
                if(f != null && f.fieldPath.includes('Diversified_portfolio__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }   
                if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }      
                if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }
                if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }  
                if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                } 
                if(f != null && f.fieldPath.includes('Investment_portfolio__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }         
                if(f != null && f.fieldPath.includes('Investment_Style__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }     
                if(f != null && f.fieldPath.includes('Time_line_for_Trading__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }     
                if(f != null && f.fieldPath.includes('Stop_Loss__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }      
                if(f != null && f.fieldPath.includes('Direct_Equity__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }   
                if(f != null && f.fieldPath.includes('Derivative__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }   
                if(f != null && f.fieldPath.includes('Mutual_Funds__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }   
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }   
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                } 
                if(f != null && f.fieldPath.includes('Financial_Goals__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }         
                if(f != null && f.fieldPath.includes('Investment_goal__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = false;
                    
                }       
            }
        }if(isEditable == 'false'){
       
            for(var i in fieldSet['Case Detail'].Col2){
                var f = fieldSet['Case Detail'].Col2[i];
                if(f != null && f.fieldPath.includes('Age_RiskProfile__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                }
                if(f != null && f.fieldPath.includes('Equity_Markets__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }  
                
                if(f != null && f.fieldPath.includes('Investment_philosophy__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }  
                if(f != null && f.fieldPath.includes('Risk_Profile_Categories__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }
                if(f != null && f.fieldPath.includes('Amount_of_fluctuations__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }  
                if(f != null && f.fieldPath.includes('Amount_of_fluctuations_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                } 
                if(f != null && f.fieldPath.includes('Diversified_portfolio__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }   
                if(f != null && f.fieldPath.includes('Interest_in_leverage_borrowing_products__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }         
                if(f != null && f.fieldPath.includes('Interest_leverage_products_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }
                if(f != null && f.fieldPath.includes('Alternative_Investments__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }     
                if(f != null && f.fieldPath.includes('Alternative_Investments_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }
                if(f != null && f.fieldPath.includes('Investment_portfolio__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }         
                if(f != null && f.fieldPath.includes('Investment_Style__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }     
                if(f != null && f.fieldPath.includes('Time_line_for_Trading__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }     
                if(f != null && f.fieldPath.includes('Stop_Loss__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }      
                if(f != null && f.fieldPath.includes('Direct_Equity__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }   
                if(f != null && f.fieldPath.includes('Derivative__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }   
                if(f != null && f.fieldPath.includes('Mutual_Funds__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }   
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }   
                if(f != null && f.fieldPath.includes('worst_and_best_one_year_return_Non_Ind__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }  
                if(f != null && f.fieldPath.includes('Financial_Goals__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }         
                if(f != null && f.fieldPath.includes('Investment_goal__c')){
                    fieldSet['Case Detail'].Col2[i].isEditable = true;
                    
                }     
            }
            
        }
      
        component.set("v.expand",'Case Detail');
        component.set("v.selectedFieldSetMap",fieldSet);
       helper.renderDiv(component, event, helper); 
    },
    
    fillSelectedFieldSetMap : function(component,event,helper,record){
        var fieldMap = component.get("v.fieldSetMap");
        var pType = component.get("v.ProductType");
        var SingleJoint = '';
        if(pType != null && pType.includes("Demat") && record != null){
            component.set("v.isDemat", true);
            component.find("SingleJoint").set("v.value",record['Single_Joint__c']); 
            SingleJoint = record['Single_Joint__c'];
        }
        var selectedMap = {};
        if(pType != null){
            for(var f in fieldMap){
                if(f.includes("Funding") && pType.includes("Funding") ){                
                    selectedMap[f] = fieldMap[f];
                }
                if(f.includes("Trading")  && pType.includes("Trading")){
                    selectedMap[f] = fieldMap[f];
                }
                if(f.includes("Joint")  && pType.includes("Demat") && SingleJoint == 'Joint'){
                    selectedMap[f] = fieldMap[f];
                }
                if(!f.includes("Trading") && !f.includes("Funding") && !f.includes("Joint")){
                    selectedMap[f] = fieldMap[f];    
                }           
            } 
        }    	
        component.set("v.selectedFieldSetMap",selectedMap);
        
        var checkCmp = component.find("Trading");        
        if(pType.includes("Trading")) checkCmp.set("v.value",true);
        checkCmp = component.find("Demat");
        if(pType.includes("Demat")) checkCmp.set("v.value",true);
        checkCmp = component.find("POA");
        if(pType.includes("POA")) checkCmp.set("v.value",true);
        /*checkCmp = component.find("Miles");
        if(pType.includes("Miles")) checkCmp.set("v.value",true);*/
        checkCmp = component.find("Advisory");
        if(pType.includes("Advisory")) checkCmp.set("v.value",true);
        checkCmp = component.find("Funding");
        if(pType.includes("Funding")) checkCmp.set("v.value",true);
        checkCmp = component.find("ComodityTrad");
        if(pType.includes("ComodityTrad")) checkCmp.set("v.value",true);
        checkCmp = component.find("ComodityTrack");
        if(pType.includes("ComodityTrack")) checkCmp.set("v.value",true);       
    },
    isFamilyHead : function(component,event,helper,record){
        var isFamilyHead = component.get("v.isFamilyHead");        
        if(isFamilyHead){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "message": "Making this Client as a Family Head"
            });
            toastEvent.fire();
        } 
    }
})