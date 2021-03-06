({
    showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    
    validateFirstScreen : function(component, event, helper) {
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Product_Type_Order_Entry__c == 'MF' && (orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP')){
            if (orderEntry.Family_Name__c == '' || typeof orderEntry.Family_Name__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Family Name","Error");
            } else if (orderEntry.Client_Name__c == '' || typeof  orderEntry.Client_Name__c === 'undefined') {                
                isvalid = 0;
                helper.showToast("Please Select Client Name","Error");
            } else if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
                else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                    isvalid = 0;
                    helper.showToast("Please Select Product Type","Error");
                }
                    else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Type","Error");
                    }
                        else if (typeof orderEntry.AMC_Name__c === 'undefined'|| orderEntry.AMC_Name__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select AMC Name","Error");
                        }
                            else if (typeof orderEntry.Scheme__c === 'undefined' || orderEntry.Scheme__c == '') {
                                isvalid = 0;
                                helper.showToast("Please Select Scheme","Error");
                            }
            return isvalid;
        }if(orderEntry.Product_Type_Order_Entry__c == 'MF' && (orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'SWP') ){
            if (orderEntry.Family_Name__c == '' || typeof orderEntry.Family_Name__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Family Name","Error");
            } else if (orderEntry.Client_Name__c == '' || typeof  orderEntry.Client_Name__c === 'undefined') {                
                isvalid = 0;
                helper.showToast("Please Select Client Name","Error");
            } else if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
                else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                    isvalid = 0;
                    helper.showToast("Please Select Product Type","Error");
                }
                    else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Type","Error");
                    }
                        else if (typeof orderEntry.AMC_Name__c === 'undefined'|| orderEntry.AMC_Name__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select AMC Name","Error");
                        }
                            else if (typeof orderEntry.Scheme__c === 'undefined'|| orderEntry.Scheme__c == '') {
                                isvalid = 0;
                                helper.showToast("Please Select Scheme","Error");
                            } 
            //Change Start
            /* else if (typeof orderEntry.Product_lookup__c === 'undefined' || typeof orderEntry.Product_lookup__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme Name","Error");
                        }*/
            //Change End
            
            return isvalid;
            
        } 
        if(orderEntry.Product_Type_Order_Entry__c == 'MF' && (orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'STP')){
            if (orderEntry.Family_Name__c == '' || typeof orderEntry.Family_Name__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Family Name","Error");
            } else if (orderEntry.Client_Name__c == '' || typeof  orderEntry.Client_Name__c === 'undefined') {                
                isvalid = 0;
                helper.showToast("Please Select Client Name","Error");
            } else if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
                else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                    isvalid = 0;
                    helper.showToast("Please Select Product Type","Error");
                }
                    else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Type","Error");
                    }
                        else if (typeof orderEntry.AMC_Name__c === 'undefined'|| orderEntry.AMC_Name__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select AMC Name","Error");
                        }
                            else if (typeof orderEntry.From_Scheme__c === 'undefined'|| orderEntry.From_Scheme__c == '') {
                                isvalid = 0;
                                helper.showToast("Please Select From Scheme","Error");
                            }
                                else if (typeof orderEntry.To_Scheme__c === 'undefined'|| orderEntry.To_Scheme__c == '') {
                                    isvalid = 0;
                                    helper.showToast("Please Select To Scheme","Error");
                                }
            return isvalid;
        }if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
           orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD' && (orderEntry.Transaction_Type__c == 'Buy' || orderEntry.Transaction_Type__c == 'Sell')){
            /*isvalid = 0;
            helper.showToast("Please select Instrument","Error");*/
            if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
            else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                isvalid = 0;
                
                helper.showToast("Please Select Product Type","Error");
            }else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){            
                isvalid = 0;
                helper.showToast("Please Select Transaction Type","Error");
            }else if(orderEntry.Instrument_Name_Display__c == '' || typeof orderEntry.Instrument_Name_Display__c === 'undefined' || orderEntry.Instrument_Name_Display__c == '--- None ---'){              
                isvalid = 0;
                helper.showToast("Please Select Instrument Name","Error");
            }
            return isvalid;
        } if(orderEntry.Product_Type_Order_Entry__c == 'PMS'){
           
            if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
            else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                isvalid = 0;
                
                helper.showToast("Please Select Product Type","Error");
            }else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){            
                isvalid = 0;
                helper.showToast("Please Select Transaction Type","Error");
            }else if(orderEntry.Product_Name_Display__c == '' || typeof orderEntry.Product_Name_Display__c === 'undefined' || orderEntry.Product_Name_Display__c == '--- None ---'){              
                isvalid = 0;
                helper.showToast("Please Select Product Name","Error");
            }
            return isvalid;
        } if(orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){            
            if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
            else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                isvalid = 0;
                
                helper.showToast("Please Select Product Type","Error");
            }else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){            
                isvalid = 0;
                helper.showToast("Please Select Transaction Type","Error");
            }else if(orderEntry.Security_Name_Display__c == '' || typeof orderEntry.Security_Name_Display__c === 'undefined' || orderEntry.Security_Name_Display__c == '--- None ---'){              
                isvalid = 0;
                helper.showToast("Please Select Security Name","Error");
            }
            return isvalid;
        }
        else{
            if (orderEntry.Family_Name__c == '' || typeof orderEntry.Family_Name__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Family Name","Error");
            } else if (orderEntry.Client_Name__c == '' || typeof  orderEntry.Client_Name__c === 'undefined') {                
                isvalid = 0;
                helper.showToast("Please Select Client Name","Error");
            } else if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
                else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                    isvalid = 0;
                    helper.showToast("Please Select Product Type","Error");
                }
                    else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Type","Error");
                    }
                        else if(orderEntry.Product_Type_Order_Entry__c == 'IPO' && (orderEntry.IPO_Name__c == '' || typeof orderEntry.IPO_Name__c === 'undefined')){
                            isvalid = 0;
                            helper.showToast("Please Select IPO Name","Error");
                        }
            /* else if (typeof orderEntry.AMC_Name__c === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select AMC Name","Error");
                    }
                        else if (typeof orderEntry.Scheme__c === 'undefined') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme","Error");
                        }*/
            return isvalid;
        }
        
    },
    validateSecondScreen : function(component, event, helper) {
        
        var isoderentryMF =component.get("v.isoderentryMF");
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry");         
        if(orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Purchase'){
            isvalid = helper.validateSecondScreenCommon(component, event, helper);
            if(isvalid == 1)
            {
              /*  if(!isoderentryMF)
                {
                    if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Amount","Error");
                    }
                } */
                     if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Amount","Error");
                    }
			}
          if(isvalid == 1 && isoderentryMF)
          {
              if (typeof orderEntry.Transaction_Type_new__c  === 'undefined' || typeof orderEntry.Transaction_Type_new__c == '' || orderEntry.Transaction_Type_new__c == '') {
                  isvalid = 0;
                  helper.showToast("Please Select Transaction Type","Error");
              }                     
              else if (typeof orderEntry.Client_Holding_and_Type__c  === 'undefined' ||  orderEntry.Client_Holding_and_Type__c == '' ||  orderEntry.Client_Holding_and_Type__c == '-- None --' || typeof orderEntry.Client_Holding_and_Type__c == '' ) {
                  isvalid = 0;
                  helper.showToast("Please Select Holidng Mode","Error");
              }
              
          }
            return isvalid;
        }

        else if (orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Redemption'){
            isvalid = helper.validateSecondScreenCommon(component, event, helper);
            if(isvalid == 1 && !isoderentryMF){
                if (typeof orderEntry.Product_lookup__c  === 'undefined' || typeof orderEntry.Product_lookup__c == '') {
                    isvalid = 0;
                    helper.showToast("Please Select Scheme Name","Error");
                }else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                    isvalid = 0;
                    helper.showToast("Please Select Redemption Type ","Error");
                }else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                    isvalid = 0;
                    helper.showToast("Please Select Transaction Amount for Partial Amount Redemption","Error");
                }else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Redemption_Units__c  === 'undefined' || typeof orderEntry.Redemption_Units__c == '')) {
                    isvalid = 0;
                    helper.showToast("Please Select Redemption Units for Partial Unit Redemption","Error");
                } /*else if (typeof orderEntry.All_Units__c  === 'undefined' || typeof orderEntry.All_Units__c == '') {
                isvalid = 0;
                helper.showToast("Please Select All Units","Error");
            }*/
                            
                        }
            if(isvalid == 1 && isoderentryMF){
                if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                    isvalid = 0;
                    helper.showToast("Please Select Transaction Mode","Error");
                }
                else if (orderEntry.POA_Non_POA__c == '' || typeof orderEntry.POA_Non_POA__c === 'undefined') {
                    isvalid = 0;
                    helper.showToast("Please Select Execution Channel","Error");
                }
                    else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Amount","Error");
                    }
                        else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Transaction_Unit__c  === 'undefined' || typeof orderEntry.Transaction_Unit__c == '' || orderEntry.Transaction_Unit__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Units","Error");
                        }
            }
                    }
            else if (orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Switch'){
                isvalid = helper.validateSecondScreenCommon(component, event, helper);
                if(isvalid == 1 && !isoderentryMF){
                    if (typeof orderEntry.Product_lookup__c  === 'undefined' || typeof orderEntry.Product_lookup__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Select Scheme Name","Error");
                    }else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                        isvalid = 0;
                        helper.showToast("Please Select Redemption Type ","Error");
                    }else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Redemption_Units__c  === 'undefined' || typeof orderEntry.Redemption_Units__c == '')) {
                        isvalid = 0;
                        helper.showToast("Please Select Redemption Units for Partial Unit Redemption","Error");
                        if (typeof orderEntry.Transaction_Mode_new__c  === 'undefined' || typeof orderEntry.Transaction_Mode_new__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Mode","Error");
                        }else if(orderEntry.POA_Non_POA__c == '' || typeof orderEntry.POA_Non_POA__c === 'undefined'){
                            isvalid = 0;
                            helper.showToast("Please Select Execution Channel","Error");
                        } 
                    }
                    /*else if (typeof orderEntry.All_Units__c  === 'undefined' || typeof orderEntry.All_Units__c == '') {
                isvalid = 0;
                helper.showToast("Please Select All Units","Error");
            }*/
                        else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Amount for Partial Amount Redemption","Error");
                        }else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Redemption_Units__c  === 'undefined' || typeof orderEntry.Redemption_Units__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Select Redemption Units for Partial Unit Redemption","Error");
                        }
                }
                
                if(isvalid == 1 && isoderentryMF){
                    if (typeof orderEntry.To_Folio__c  === 'undefined' || orderEntry.To_Folio__c == '' ||  orderEntry.To_Folio__c == '-- None --') {
                        isvalid = 0;
                        helper.showToast("Please Select To Folio","Error");
                    }
                    else  if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Mode ","Error");
                    }
                 
                    /*    else if (orderEntry.To_Scheme_new__c == 'None' || typeof orderEntry.To_Scheme_new__c  === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select To Scheme","Error");
                    } */
                    
                   else if (orderEntry.POA_Non_POA__c == '' || typeof orderEntry.POA_Non_POA__c === 'undefined') {
                       isvalid = 0;
                       helper.showToast("Please Select Execution Channel","Error");
                   }
                       else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                           isvalid = 0;
                           helper.showToast("Please Select Transaction Amount","Error");
                       }
                    else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Transaction_Unit__c  === 'undefined' || typeof orderEntry.Transaction_Unit__c == '' || orderEntry.Transaction_Unit__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Units","Error");
                        }
                    
                }
                
                return isvalid;
            }
        
                //chnage for new order entry Prateek
        
        else if(orderEntry.Product_Type_Order_Entry__c == 'MF' &&  orderEntry.Transaction_Type__c == 'SIP'){
            isvalid = helper.validateSecondScreenCommonOrderEntryNew(component, event, helper);
            
             if(isvalid==1)
             {
                 if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                     isvalid = 0;
                     helper.showToast("Please Select Transaction Amount","Error");
                 }
             }
           
            return isvalid;
        }
        
            else if(orderEntry.Product_Type_Order_Entry__c == 'MF' &&  orderEntry.Transaction_Type__c == 'SWP'){
                console.log('orderEntry.Dividend_Option__c :'+orderEntry.Dividend_Option__c);
                debugger;
                isvalid = helper.validateSecondScreenCommonOrderEntryNew(component, event, helper);
                if(isvalid==1)
                {
                    if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Mode ","Error");
                    }
                    else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Amount","Error");
                    }
                        else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Transaction_Unit__c  === 'undefined' || typeof orderEntry.Transaction_Unit__c == '' || orderEntry.Transaction_Unit__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Unit","Error");
                        }
                            else if (typeof orderEntry.Dividend_Option__c  === 'undefined' || typeof orderEntry.Dividend_Option__c == '' || orderEntry.Dividend_Option__c == '') {
                                isvalid = 0;
                                helper.showToast("Please Select Diviend Option","Error");
                            }  
                }
                
                return isvalid;
            }
                else if(orderEntry.Product_Type_Order_Entry__c == 'MF' &&  orderEntry.Transaction_Type__c == 'STP'){
                    isvalid = helper.validateSecondScreenCommonOrderEntryNew(component, event, helper);
                    if(isvalid==1)
                    {
                        if (typeof orderEntry.To_Folio__c  === 'undefined' || orderEntry.To_Folio__c == '' ||  orderEntry.To_Folio__c == '-- None --') {
                            isvalid = 0;
                            helper.showToast("Please Select To Folio","Error");
                        }
                        else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                            isvalid = 0;
                            helper.showToast("Please Select Transaction Mode ","Error");
                        }
                   
                        /*  else if (typeof orderEntry.To_Scheme_new__c  === 'undefined' || typeof orderEntry.To_Scheme_new__c == '') {/*
                                isvalid = 0;
                                helper.showToast("Please Select To Scheme","Error");
                            } */
                        
                                else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                                    isvalid = 0;
                                    helper.showToast("Please Select Transaction Amount","Error");
                                }
                                    else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Transaction_Unit__c  === 'undefined' || typeof orderEntry.Transaction_Unit__c == '' || orderEntry.Transaction_Unit__c == '')) {
                                        isvalid = 0;
                                        helper.showToast("Please Select Transaction Units for Partial Unit","Error");
                                    }
                                        else if (typeof orderEntry.Dividend_Option__c  === 'undefined' || typeof orderEntry.Dividend_Option__c == '' || orderEntry.Dividend_Option__c == '') {
                                            isvalid = 0;
                                            helper.showToast("Please Select Diviend Option","Error");
                                        }
                    }
                    
                    return isvalid;
                }
        
        if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
           orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD'){
       
            if (typeof orderEntry.Face_Value__c  === 'undefined' || typeof orderEntry.Face_Value__c == '' ||  orderEntry.Face_Value__c == null) {
                isvalid = 0;
                helper.showToast("Please enter Face Value ","Error");
            }            
            if(orderEntry.Transaction_Type__c == 'Sell'){ 
                
                if (typeof orderEntry.Face_Value__c  === 'undefined' || typeof orderEntry.Face_Value__c == '' ||  orderEntry.Face_Value__c == null) {
                    isvalid = 0;
                    helper.showToast("Please enter Face Value ","Error");
                } /*else if (typeof orderEntry.Current_Investment_Amount__c  === 'undefined' || typeof orderEntry.Current_Investment_Amount__c == '') {
                    isvalid = 0;
                    helper.showToast("Please enter Investment Amount ","Error");
                } else if (typeof orderEntry.Available_Quantity__c  === 'undefined' || typeof orderEntry.Available_Quantity__c == '') {
                    isvalid = 0;
                    helper.showToast("Please enter Available Quantity","Error");
                } */           
            }
        }
                    else if (orderEntry.Product_Type_Order_Entry__c == 'PMS'){
            isvalid = helper.validateSecondScreenCommon(component, event, helper);            
            if(isvalid == 1){               
                if (typeof orderEntry.Portfolio_Fee_Type__c  === 'undefined' || typeof orderEntry.Portfolio_Fee_Type__c == '') {
                    isvalid = 0;
                    helper.showToast("Please Select Portfolio Fee Type ","Error");
                }else if ((typeof orderEntry.Folio__c  === 'undefined' ||   orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '--None--') && (orderEntry.Transaction_Type__c != 'Subscription (New)')) {
                    isvalid = 0;
                    helper.showToast("Please Select Folio","Error");
                } else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == null ) {
                    isvalid = 0;
                    helper.showToast("Please Select Transaction Amount","Error");
                } 
            }
            return isvalid;
        } 
           else if (orderEntry.Product_Type_Order_Entry__c == 'IPO'){
                    
                    if (typeof orderEntry.IPO_Application_Number__c  === 'undefined' ||   orderEntry.IPO_Application_Number__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Enter Application Number","Error");
                    }
                    else if (typeof orderEntry.Cut_Off_Price__c  === 'undefined' ||   orderEntry.Cut_Off_Price__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Select Cut Off Price","Error");
                    }
                        else if (orderEntry.Transaction_Type__c == 'Equity IPO' && orderEntry.Cut_Off_Price__c  === 'No' && (typeof orderEntry.Price_new__c  === 'undefined' ||   orderEntry.Price_new__c == '')) {
                            isvalid = 0;
                            helper.showToast("Please Enter Price","Error");
                        }
                            else if ( orderEntry.Transaction_Type__c == 'Equity IPO' && (typeof orderEntry.No_of_units__c  === 'undefined' || orderEntry.No_of_units__c	 == '' || orderEntry.No_of_units__c	 == null)) {
                                isvalid = 0;
                                helper.showToast("Please Enter No Of Unit","Error");
                            } 
                                else  if(orderEntry.Transaction_Type__c == 'Bond IPO')
                                {
                                    if (orderEntry.Cut_Off_Price__c  === 'No' && ( (typeof orderEntry.Price_new__c  === 'undefined' ||   orderEntry.Price_new__c == '') &&  ( orderEntry.of_Facevalue__c == '' || typeof orderEntry.of_Facevalue__c  === 'undefined') )) {
                                        isvalid = 0;
                                        helper.showToast("Please Enter Price or Face Value","Error");
                                    }
                                    else if ((typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' ||   orderEntry.Transaction_Amount_Financial_Transaction__c == '') &&  ( orderEntry.No_of_units__c == '' || typeof orderEntry.No_of_units__c  === 'undefined')) {
                                        isvalid = 0;
                                        helper.showToast("Please Enter Amount or Unit","Error");
                                    }
                                }
                                    else if (typeof orderEntry.Payment_Mode__c  === 'undefined' ||  orderEntry.Payment_Mode__c == ''){
                                        isvalid = 0;
                                        helper.showToast("Please Select Execution Channel","Error");
                                    }
                    
                    
                    return isvalid;
                }else if (orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){
            debugger;
            isvalid = helper.validateSecondScreenCommon(component, event, helper);
            if(isvalid == 1){                  
                if(orderEntry.Transaction_Type__c == 'Log Commitment' ){
                    if (typeof orderEntry.Commitment_Amount__c  === 'undefined' || orderEntry.Commitment_Amount__c == '' || orderEntry.Commitment_Amount__c == null) {
                        helper.showToast("Please Enter Commitment Amount","Error");
                        isvalid = 0;
                        
                    } 
                }
                if(orderEntry.Transaction_Type__c == 'Log Drawdown' || orderEntry.Transaction_Type__c == 'Withdrawal' || orderEntry.Transaction_Type__c == 'Close Out'){
                    if (typeof orderEntry.PE_ID__c  === 'undefined' || orderEntry.PE_ID__c == '') {
                        helper.showToast("Please Enter PE ID","Error");
                        return isvalid = 0;
                        
                    } 
                }
                if(orderEntry.Transaction_Type__c == 'Log Drawdown' || orderEntry.Transaction_Type__c == 'Withdrawal' ){
                    if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == null) {
                        helper.showToast("Please Enter Transaction Amount","Error");
                        return isvalid = 0;                        
                    } 
                }
                /*if(orderEntry.Transaction_Type__c == 'Creation and Drawdown'){
                    if (typeof orderEntry.Commitment_Amount__c  === 'undefined' || typeof orderEntry.Commitment_Amount__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Enter Commitment Amount","Error");
                    } else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Enter Transaction Amount","Error");
                    } else if (typeof orderEntry.Drawdown_Amount_allocation__c  === 'undefined' || typeof orderEntry.Drawdown_Amount_allocation__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Enter Drawdown Amount allocation","Error");
                    } else if (typeof orderEntry.Drawdown_due_date__c  === 'undefined' || typeof orderEntry.Drawdown_due_date__c == '') {
                        isvalid = 1;
                        helper.showToast("Please Enter Drawdown due date ","Error");
                    } 
                }*/
            }
            return isvalid;
        } 
            
            else{       
           
            isvalid = 0;
            helper.showToast("Please Select All Values To Proceed","Error");
        }
        return isvalid;
    },
    
    validateThirdScreen : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
            var isoderentryMF =component.get("v.isoderentryMF");
        
        if (typeof orderEntry.AttachmentId__c  === 'undefined' || typeof orderEntry.AttachmentId__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Attachement","Error");
        }/* else if (typeof orderEntry.Client_Risk_Profile__c  === 'undefined' || typeof orderEntry.Client_Risk_Profile__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Client Risk Profile","Error");
        }else if (typeof orderEntry.Product_Risk_Profile_FinancialT__c  === 'undefined' || typeof orderEntry.Product_Risk_Profile_FinancialT__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Product Risk Profile","Error");
        }*/
        else if (typeof orderEntry.Primary_FA__c  === 'undefined' || typeof orderEntry.Primary_FA__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Primary FA","Error");
        }else if ((orderEntry.Product_Type_Order_Entry__c == 'MF') && (typeof orderEntry.EUIN__c  === 'undefined' || typeof orderEntry.EUIN__c == '' ||  orderEntry.EUIN__c == null) && (!isoderentryMF)) {            
            //((orderEntry.Product_Type_Order_Entry__c != 'Bond' && orderEntry.Product_Type_Order_Entry__c != 'PMS') && (typeof orderEntry.EUIN__c  === 'undefined' || typeof orderEntry.EUIN__c == '')) {
            isvalid = 0;
            helper.showToast("Please Select EUIN","Error");
        }
        return isvalid;        
    },
    
    validateSecondScreenCommon : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
	 var isoderentryMF =component.get("v.isoderentryMF");
        if (orderEntry.Product_Type_Order_Entry__c != 'PMS' && orderEntry.Product_Type_Order_Entry__c != 'PE / AIF' && !isoderentryMF){
            if (typeof orderEntry.UCC__c  === 'undefined' ||  orderEntry.UCC__c == '' || typeof orderEntry.UCC__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select UCC","Error");
            }
            else if (typeof orderEntry.Folio__c  === 'undefined' ||  orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select Folio","Error");
            }
                else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' ||orderEntry.Transaction_Amount_Financial_Transaction__c == '' ) {
                isvalid = 0;
                helper.showToast("Please Select Transaction Amount","Error");
            }
                else if (typeof orderEntry.POA_Non_POA__c  === 'undefined' ||  orderEntry.POA_Non_POA__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Execution Channel","Error");
            }else if (typeof orderEntry.Origin__c  === 'undefined' || typeof orderEntry.Origin__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Communication Mode","Error");
            }
        	 return isvalid;
        }  
	
	 if (orderEntry.Product_Type_Order_Entry__c == 'MF' && isoderentryMF){
            if (typeof orderEntry.Folio__c  === 'undefined' ||  orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select Folio","Error");
            }
         /*   else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Transaction Amount","Error");
            } */
              else if (typeof orderEntry.POA_Non_POA__c  === 'undefined' ||  orderEntry.POA_Non_POA__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Execution Channel","Error");
            }
            return isvalid;
        }                 
        return isvalid;
        
    },
        validateSecondScreenCommonOrderEntryNew : function(component, event, helper) {
        debugger;
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
        var isoderentryMF =component.get("v.isoderentryMF");
        console.log('orderEntry.Dividend_Option__c :'+orderEntry.Dividend_Option__c);
        // changes for new oderentrymf prateek
        if (orderEntry.Product_Type_Order_Entry__c == 'MF'&& isoderentryMF ){
            
            if (typeof orderEntry.Folio__c  === 'undefined' ||  orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select Folio","Error");
            }
         /*   else if ((orderEntry.Transaction_Mode_new__c == 'Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '')) {
                isvalid = 0;
                helper.showToast("Please Select Transaction Amount","Error");
            } */
            
                else if (typeof orderEntry.Frequency__c === 'undefined' || typeof orderEntry.Frequency__c == '' ||  orderEntry.Frequency__c == '-- None --' || orderEntry.Frequency__c == '') {
                    isvalid = 0;
                    helper.showToast("Please Select Frequency","Error");
                }
                    else if (typeof orderEntry.Start_Date__c  === 'undefined' ||  orderEntry.Start_Date__c == '') {
                        isvalid = 0;
                        helper.showToast("Please Select Start Date","Error");
                    }
                        else if (typeof orderEntry.End_Date__c  === 'undefined' || orderEntry.End_Date__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select End Date","Error");
                        }
            
            /*   else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                    isvalid = 0;
                    helper.showToast("Please Select Transaction Amount","Error");
                } */
            
            
            
                else if (typeof orderEntry.POA_Non_POA__c  === 'undefined' ||  orderEntry.POA_Non_POA__c == '' ||  orderEntry.POA_Non_POA__c == '-- None --') {
                    isvalid = 0;
                    helper.showToast("Please Select Execution Channel","Error");
                }
                       
             
             
             
             /*else if (typeof orderEntry.Transaction_Mode__c  === 'undefined' || typeof orderEntry.Transaction_Mode__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Transaction Mode","Error");
            }else if (typeof orderEntry.Payment_Mode__c  === 'undefined' || typeof orderEntry.Payment_Mode__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Payment Mode","Error");
            }*/
              /*else if (typeof orderEntry.Client_Concent__c  === 'undefined' || typeof orderEntry.Client_Concent__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Client Concent","Error");
            }*//*else if (typeof orderEntry.AttachmentId__c  === 'undefined' || typeof orderEntry.AttachmentId__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Attachement","Error");
            }  */  
        	 return isvalid;
        }                  
        return isvalid;
        
    },
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
        //Added By Prateek 
     
        var listDependingValuesTemp = new Array();
        listDependingValuesTemp = component.get("v.listDependingValues");  
        console.log('Before Remove listDependingValuesTemp :'+listDependingValuesTemp);                    
        for(var i =listDependingValuesTemp.length; i--;)
        {
            if(listDependingValuesTemp[i]=='SIP' || listDependingValuesTemp[i]=='SWP' || listDependingValuesTemp[i]=='STP' )
            {
                listDependingValuesTemp.splice(i, 1);
            }
        }
        console.log('After Remove listDependingValuesTemp :'+listDependingValuesTemp); 
        component.set("v.listDependingValues",listDependingValuesTemp);  
        console.log('After Remove listDependingValues :'+component.get("v.listDependingValues"));  
        
    },
    
    
    setFamilyNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setFamilyName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    orderEntry.Family_Name_Display__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
    },
    setClientNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setClientName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){ 
                     orderEntry.Client_Name_Display__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    setClientAccountNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setClientAccountName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {               
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    var tmp = orderEntryObj.split(" ");
					//orderEntryObj = tmp[0] + " " + tmp[tmp.length-1]; 
                    component.set("v.accountNameDisplay", tmp[0] + " " + tmp[tmp.length-1]);
                    orderEntry.Client_Account_Display__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    
    setProductNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setProductName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    orderEntry.Scheme_Name__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    doSave: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");
        var isoderentryMF =component.get("v.isoderentryMF");
	 if(orderEntry.Product_Type_Order_Entry__c == 'MF' && isoderentryMF){
            console.log("Inside Helper Method fileOrderEntry");
            var fileInput = component.find("fileOrderEntry").get("v.files");
            if (fileInput.length > 0) {
                console.log("Inside IF consition");
                helper.uploadHelper(component, event,fileInput);
            } else {
                alert('Please Select a Valid File');
            }
        }
       else if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
        
            var fileInput = component.find("fileMF").get("v.files");
            if (fileInput.length > 0) {
                helper.uploadHelper(component, event,fileInput);
            } else {
                alert('Please Select a Valid File');
            }
        }  else if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
           orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD'){            
            var fileInput = component.find("fileBond").get("v.files");
            if (fileInput.length > 0) {
                helper.uploadHelper(component, event,fileInput);
            } else {
                alert('Please Select a Valid File');
            }
        }
            else if (orderEntry.Product_Type_Order_Entry__c == 'PMS' || orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){            
                var fileInput = component.find("fileUpload").get("v.files");
                if (fileInput.length > 0) {
                    helper.uploadHelper(component, event,fileInput);
                } else {
                    alert('Please Select a Valid File');
                }
            }
                else if (orderEntry.Product_Type_Order_Entry__c == 'IPO'){            
                    var fileInput = component.find("fileIPO").get("v.files");
                    if (fileInput.length > 0) {
                        helper.uploadHelper(component, event,fileInput);
                    } else {
                        alert('Please Select a Valid File');
                    }
                }
    },
    /*Code for file attachment start */
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event,fileInput) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var orderEntry = component.get("v.orderEntry"); 
        component.set("v.attachmentName",file.name);
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            orderEntry.AttachmentId__c = attachId;           
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "File uploaded successfully.",
                        'type': 'success'
                    });
                    toastEvent.fire();
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    /* Code for file attachment ends*/
    
    saveObjRecord: function(component, event, helper){
    	var orderEntry = component.get("v.orderEntry");
        var isoderentryMF = component.get("v.isoderentryMF");
        
        if(isoderentryMF)
        {
           		orderEntry.OrderEntryMF__c=true;
             component.set("v.orderEntry",orderEntry);
            console.log('orderEntry.OrderEntryMF__c :'+orderEntry.OrderEntryMF__c);
        }
        console.log('isoderentryMF before save :'+isoderentryMF);
    	orderEntry.sobjectType='Order_Entry__c';
        var action = component.get("c.saveObj");
        action.setParams({
            "orderEntryObj" : orderEntry,
            "isoderentryMF" : isoderentryMF
        });                  
        action.setCallback(this, function(response) { 
            var state = response.getState();       		
            if (state === "SUCCESS") {
                var savedRecId = response.getReturnValue();
                if(savedRecId.includes('Error')){
                    helper.showToast(savedRecId,"Error");
                } else {                   
                        helper.showToast("Order Saved Successfully","Success");

                        var delayInMilliseconds = 2000; //1 second
                        setTimeout(function() {
                            $A.get('e.force:refreshView').fire();
                        }, delayInMilliseconds); 
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                    	component.set("v.isPreviewScreen",false);
                        navEvt.setParams({
                            "recordId": savedRecId,
                            "slideDevName": "related"
                        });
                        navEvt.fire();                   
                }
            }
            else{
                alert('error'+state);
            }
            
        });$A.enqueueAction(action);
	},
    currentTime: function(component, event, helper){      
        var action = component.get("c.getCurrentTime");
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var time = response.getReturnValue();
            }
        });$A.enqueueAction(action);
    },
    callAPiHelper: function(component, event, helper){              
        var orderEntry = component.get("v.orderEntry" );
        var foList = new Array();
        var folioByAPIList = new Array();
        if(orderEntry.Transaction_Type__c == 'Purchase'){
            var action = component.get("c.getFolioFromAPI");  
        }else if(orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch'){
            var action = component.get("c.getHoldingFromAPI");
        }
        action.setParams({
            "clientAccountId" : orderEntry.Client_Account__c,
            "bseStarAmcCode" : orderEntry.AMC_Name__c,
            "holdingType" : orderEntry.Client_Holding_and_Type__c,
            "transactionType" : orderEntry.Transaction_Type__c,
            "schemeName" : orderEntry.Scheme__c,
            "fromSchemeName" : orderEntry.From_Scheme__c
        });   
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var folioListReceived = new Array();
                folioListReceived = response.getReturnValue();
                if(orderEntry.Transaction_Type__c == 'Purchase'){
                    foList.push('New');  
                    if(folioListReceived != null){
                        for(var m=0 ; m < folioListReceived.length; m++){
                            foList.push(folioListReceived[m]); 
                        }
                        component.set("v.folioListPurchase",foList); 
                        helper.showToast("Folio List Fetched","Success");
                    }else{
                        helper.showToast("No Data Found !!! !!!","Error");
                    }
                    
                }else if(orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch'){
                    component.set("v.HoldingInformationAPI",folioListReceived); 
                    folioByAPIList.push('-- None --');
                    if(folioListReceived != null){
                        for(var m=0 ; m < folioListReceived.length; m++){
                            folioByAPIList.push(folioListReceived[m].folio);
                        }
                        component.set("v.folioListPurchase",folioByAPIList); 
                        component.set("v.folioByAPI",true); 
                        helper.showToast("Holding Information Fetched","Success");
                    }else{
                        helper.showToast("No Data Found !!!","Error");
                    }
                }
            }
        });$A.enqueueAction(action);
        
    },
	loadPE: function(component, event, helper){       
        var orderEntry = component.get("v.orderEntry");  
        var uccList = new Array();
        var selectedClientRecord = component.get("v.selectedClientRecord");
        var listOfAllClients = component.get("v.filteredClientList");
        for(var m=0 ; m < listOfAllClients.length; m++){
            if(selectedClientRecord.Id == listOfAllClients[m].Id){
                component.set("v.selectedClientPAN",listOfAllClients[m].PAN_Number__c);
            }
        }

        var selectedClientId = selectedClientRecord.Id;
        var action = component.get("c.getUCCMasterData");
        action.setParams({
            "clientId": selectedClientId
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var bseObjectList = response.getReturnValue();
                if(bseObjectList == null){
                    helper.showToast("UCC Details Not Found","Error");
                }else{
                    uccList.push('-- None --');
                    for(var m=0 ; m < bseObjectList.length; m++){
                        uccList.push(bseObjectList[m].CLIENT_CODE__c);
                    }
                    component.set("v.uccList",uccList); 
                }
            }
            
        });$A.enqueueAction(action);
        
        /*var listOfAllClients = component.get("v.filteredClientList");
                var selectedClientRecord = component.get("v.selectedClientRecord");*/
        
        for(var m=0 ; m < listOfAllClients.length; m++){
            if(selectedClientRecord.Id == listOfAllClients[m].Id){
                orderEntry.Client_Risk_Profile__c = listOfAllClients[m].Risk_Profile_Based_on_IPS__c;
                orderEntry.Primary_FA_FinanceT__c = listOfAllClients[m].Owner.Id;
                component.set("v.primaryFA",listOfAllClients[m].Owner.Id);
                orderEntry.Primary_FA__c = listOfAllClients[m].Owner.Name;
            }
        }
        
        component.set("v.orderEntry" , orderEntry);  
        var orderEntryObj = component.get("v.orderEntry");  
        var primaryFa = component.get("v.primaryFA");
        var action = component.get("c.getEuinDetails");
        action.setParams({
            "faId": primaryFa
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var euinObject = response.getReturnValue();
                if(euinObject == null){
                    //helper.showToast("UCC Not Found","Error");
                }else{
                    orderEntryObj.EUIN__c = euinObject.EMP_Code__c;
                    component.set("v.orderEntry" , orderEntryObj);  
                }
            }
            
        });$A.enqueueAction(action);
        
        var action = component.get("c.setClientName");
        action.setParams({
            orderEntryObj : orderEntryObj 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var clientName = response.getReturnValue();
                if(clientName != null){
                    component.set("v.orderEntry.Client_Name_Display__c", clientName);
                    
                }
            }
        }); $A.enqueueAction(action);    
        
        var action = component.get("c.setClientAccountName");
        action.setParams({
            orderEntryObj : orderEntryObj 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var accountName = response.getReturnValue();
                if(accountName != null){
                    component.set("v.orderEntry.Client_Account_Display__c", accountName);
                    
                }
            }
        }); $A.enqueueAction(action); 
        component.set("v.orderEntry",orderEntry);  
        component.set("v.isFirstScreen" , false); 
        
        /*if(orderEntry.Product_Type_Order_Entry__c === 'Bond'){
            component.set("v.isBond", true);
            component.set("v.isSP", false);
        }
        if(orderEntry.Product_Type_Order_Entry__c === 'SP'){
            component.set("v.isBond", false);
            component.set("v.isSP", true);
        }*/
        component.set("v.isProuctTypeMF" , false);     
        component.set("v.isDisabled" , true);
        component.set("v.isBondPreviewScreen",false);
        component.set("v.isPE",true);
        
        var productName = orderEntry.Security_Name_Display__c;                
        //var productCode = productName.split('-').pop();        
        var orderEntry = component.get("v.orderEntry"); 
        //var clientAccountId = orderEntry.Client_Account__c;
        var action1 = component.get("c.fetchProductRiskonProductName");
        action1.setParams({
            "prodName" : productName                        
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var prodRiskVal = response.getReturnValue();
                if(prodRiskVal != null){
                    orderEntry.Product_Risk_Profile_FinancialT__c = prodRiskVal.Risk_Profile_of_Product__c;                  
                    orderEntry.Product_lookup__c  = prodRiskVal.Id;                                                   
                }
            }
        }); $A.enqueueAction(action1);        
    },
      callApiforoderentryMFHelper : function(component, event, helper){      
        debugger;
        var orderEntry = component.get("v.orderEntry" );
        var action = component.get("c.callAPiHelper");         
                action.setCallback(this, function(response) {    
                    var state = response.getState();            
                    if (state === "SUCCESS") {              
                        var todaysDate = response.getReturnValue();                 
                        if(todaysDate == null){
                            helper.showToast("Client not found for family","Error");
                        }
                    } 
                    
                });$A.enqueueAction(action); 

}
})