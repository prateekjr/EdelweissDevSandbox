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
        if(orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Purchase'){
            if (typeof orderEntry.Client_Account__c === 'undefined') {
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
                    else if (typeof orderEntry.AMC_Name__c === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select AMC Name","Error");
                    }
                        else if (typeof orderEntry.Scheme__c === 'undefined') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme","Error");
                        }
            return isvalid;
        }if(orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Redemption'){
            if (typeof orderEntry.Client_Account__c === 'undefined') {
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
                    else if (typeof orderEntry.AMC_Name__c === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select AMC Name","Error");
                    }
                        else if (typeof orderEntry.Scheme__c === 'undefined') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme","Error");
                        } else if (typeof orderEntry.Product_lookup__c === 'undefined' || typeof orderEntry.Product_lookup__c == '') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme Name","Error");
                        }
            
            return isvalid;
            
        } if(orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Switch'){
            if (typeof orderEntry.Client_Account__c === 'undefined') {
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
                    else if (typeof orderEntry.AMC_Name__c === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select AMC Name","Error");
                    }
                        else if (typeof orderEntry.From_Scheme__c === 'undefined') {
                            isvalid = 0;
                            helper.showToast("Please Select From Scheme","Error");
                        }
                            else if (typeof orderEntry.To_Scheme__c === 'undefined') {
                                isvalid = 0;
                                helper.showToast("Please Select To Scheme","Error");
                            }
            return isvalid;
        }
        else{
            if (typeof orderEntry.Client_Account__c === 'undefined') {
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
                    else if (typeof orderEntry.AMC_Name__c === 'undefined') {
                        isvalid = 0;
                        helper.showToast("Please Select AMC Name","Error");
                    }
                        else if (typeof orderEntry.Scheme__c === 'undefined') {
                            isvalid = 0;
                            helper.showToast("Please Select Scheme","Error");
                        }
            return isvalid;
        }
        
    },
    validateSecondScreen : function(component, event, helper) {
        
        var isoderentryMF =component.get("v.isoderentryMF");
        var isvalid = 1;
        
        var orderEntry = component.get("v.orderEntry");  
        // console.log('orderEntry.Product_Type_Order_Entry__c :'+orderEntry.Product_Type_Order_Entry__c)
        
        
        
        //console.log('orderEntry.Transaction_Type__c :'+orderEntry.Transaction_Type__c);
        console.log('orderEntry.Transaction_Amount_Financial_Transaction__c :'+orderEntry.Transaction_Amount_Financial_Transaction__c);
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
            if(isvalid == 1 && orderEntry)
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
        }else if (orderEntry.Product_Type_Order_Entry__c == 'MF' && orderEntry.Transaction_Type__c == 'Redemption'){
            isvalid = helper.validateSecondScreenCommon(component, event, helper);
            if(isvalid == 1 && !isoderentryMF){
                if (typeof orderEntry.Product_lookup__c  === 'undefined' || typeof orderEntry.Product_lookup__c == '') {
                    isvalid = 0;
                    helper.showToast("Please Select Scheme Name","Error");
                }else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                    isvalid = 0;
                    helper.showToast("Please Select Redemption Type ","Error");
                }else if ((orderEntry.Redemption_Type__c == 'Partial Amount') && (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c === '')) {
                    isvalid = 0;
                    helper.showToast("Please Select Transaction Amount for Partial Amount Redemption","Error");
                }else if ((orderEntry.Redemption_Type__c == 'Partial Unit') && (typeof orderEntry.Redemption_Units__c  === 'undefined' || typeof orderEntry.Redemption_Units__c === '')) {
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
         
                    else if(orderEntry.Product_Type_Order_Entry__c == 'Bond'){
                        
                        if (typeof orderEntry.Face_Value__c  === 'undefined' || typeof orderEntry.Face_Value__c == '' || orderEntry.Face_Value__c == null) {
                            isvalid = 0;
                            helper.showToast("Please enter Face Value ","Error");
                        }            
                        if(orderEntry.Transaction_Type__c == 'Sell'){ 
                            
                            if (typeof orderEntry.Face_Value__c  === 'undefined' || typeof orderEntry.Face_Value__c == '' || orderEntry.Face_Value__c == null) {
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
                                   }else if (orderEntry.Product_Type_Order_Entry__c == 'PMS'){
                                       
                                       if (typeof orderEntry.Portfolio_Fee_Type__c  === 'undefined' || typeof orderEntry.Portfolio_Fee_Type__c == '') {
                                           isvalid = 0;
                                           helper.showToast("Please Select Portfolio Fee Type ","Error");
                                       }else if ((typeof orderEntry.Folio__c  === 'undefined' ||   orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '--None--') && (orderEntry.Transaction_Type__c != 'Subscription (New)')) {
                                           isvalid = 0;
                                           helper.showToast("Please Select Folio","Error");
                                       }else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == null) {
                                           isvalid = 0;
                                           helper.showToast("Please Select Transaction Amount","Error");
                                       } 
                                       
                                       return isvalid;
                                   }
                                       else if (orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){
                                       isvalid = helper.validateSecondScreenCommon(component, event, helper);
                                       if(isvalid == 1){                  
                                           if(orderEntry.Transaction_Type__c == 'Log Commitment' ){
                                               if (typeof orderEntry.Commitment_Amount__c  === 'undefined' || orderEntry.Commitment_Amount__c == '' || typeof orderEntry.Commitment_Amount__c == ''|| orderEntry.Commitment_Amount__c == null ) {
                                                   helper.showToast("Please Enter Commitment Amount","Error");
                                                   isvalid = 0;
                                                   
                                               } 
                                           }
                                           /*if(orderEntry.Transaction_Type__c == 'Log Drawdown' || orderEntry.Transaction_Type__c == 'Withdrawal' || orderEntry.Transaction_Type__c == 'Close Out'){
                    if (typeof orderEntry.PE_ID__c  === 'undefined' || orderEntry.PE_ID__c == '' || typeof orderEntry.PE_ID__c == '') {
                        helper.showToast("Please Enter PE ID","Error");
                        return isvalid = 0;
                        
                    } 
                }*/
                if(orderEntry.Transaction_Type__c == 'Log Drawdown' || orderEntry.Transaction_Type__c == 'Withdrawal' ){
                    /*var letters = /^[A-Za-z]+$/;*/
                    if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == null) {
                        helper.showToast("Please Enter Transaction Amount","Error");
                        return isvalid = 0;                        
                    } 
                    
                    /*if(orderEntry.Transaction_Amount_Financial_Transaction__c.match(letters))
                    {
                        
                        helper.showToast("Please Enter valid Transaction Amount PE/AIF","Error");
                        return isvalid = 0;
                    }*/
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
           
            return isvalid;
        } else{       
            
            isvalid = 0;
            helper.showToast("Please Select All Values To Proceed","Error");
        }
         return isvalid;;
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
}
return isvalid;;
},
    
    validateSecondScreenCommon : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
        var isoderentryMF =component.get("v.isoderentryMF");
        
        if (orderEntry.Product_Type_Order_Entry__c != 'PMS' && orderEntry.Product_Type_Order_Entry__c != 'PE / AIF' && !isoderentryMF){
            if (typeof orderEntry.UCC__c  === 'undefined' ||  orderEntry.UCC__c == '' || typeof orderEntry.UCC__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select UCC","Error");
            }//else if (typeof orderEntry.Holding_Information__c  === 'undefined' || typeof orderEntry.Holding_Information__c == '') {
            //  isvalid = 0;
            // helper.showToast("Please Select Holding Information","Error");
            //}//else if (typeof orderEntry.Client_Holding_and_Type__c  === 'undefined' || typeof orderEntry.Client_Holding_and_Type__c == '') {
            /// isvalid = 0;
            // helper.showToast("Please Select Client Holding and Type","Error");
            //}
            else if (typeof orderEntry.Folio__c  === 'undefined' ||  orderEntry.Folio__c == '' ||  orderEntry.Folio__c == '-- None --') {
                isvalid = 0;
                helper.showToast("Please Select Folio","Error");
            }/*else if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Transaction Amount","Error");
            }*/else if (typeof orderEntry.POA_Non_POA__c  === 'undefined' ||  orderEntry.POA_Non_POA__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Execution Channel","Error");
            }else if (typeof orderEntry.Origin__c  === 'undefined' || typeof orderEntry.Origin__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Communication Mode","Error");
            }/*else if (typeof orderEntry.Transaction_Mode__c  === 'undefined' || typeof orderEntry.Transaction_Mode__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Transaction Mode","Error");
            }else if (typeof orderEntry.Payment_Mode__c  === 'undefined' || typeof orderEntry.Payment_Mode__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Payment Mode","Error");
            }*/else if (typeof orderEntry.Client_Concent__c  === 'undefined' || typeof orderEntry.Client_Concent__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Client Concent","Error");
            } /*else if (typeof orderEntry.AttachmentId__c  === 'undefined' || typeof orderEntry.AttachmentId__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Attachement","Error");
            }  */  
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
                    else if (typeof orderEntry.End_Date__c  === 'undefined' || typeof orderEntry.End_Date__c == '') {
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
                                             component.set("v.accountNameDisplay", tmp[0] + " " + tmp[tmp.length-1]);
                                             //orderEntryObj = tmp[0] + " " + tmp[tmp.length-1];
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
                                         } else if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
                                                   orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD'){            
                                             var fileInput = component.find("fileBond").get("v.files");
                                             if (fileInput.length > 0) {
                                                 helper.uploadHelper(component, event,fileInput);
                                             } else {
                                                 alert('Please Select a Valid File');
                                             }
                                         }else if (orderEntry.Product_Type_Order_Entry__c == 'PMS'){            
                                             var fileInput = component.find("filePMS").get("v.files");
                                             if (fileInput.length > 0) {
                                                 helper.uploadHelper(component, event,fileInput);
                                             } else {
                                                 alert('Please Select a Valid File');
                                             }
                                         }
                                             else if (orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){            
                                                 var fileInput = component.find("filePE").get("v.files");
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
                                                     // var fileInput = component.find("fileId").get("v.files");
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
                                                             setFolioRedemption : function(component, event, helper) {
                                                                 
                                                                 var orderEntry = component.get("v.orderEntry"); 
                                                                 var selectedPicklistValue = component.get("v.selectedFolioOnSave");
                                                                 orderEntry.Folio__c = selectedPicklistValue;	
                                                                 
                                                                 var action = component.get("c.getFolioNumbers");
                                                                 action.setParams({
                                                                     "clientAccountId" : orderEntry.Client_Account__c,
                                                                     "productId" : orderEntry.Product_lookup__c,
                                                                     "holdingType" : orderEntry.Client_Holding_and_Type__c
                                                                 });                  
                                                                 action.setCallback(this, function(response) {    
                                                                     var state = response.getState();
                                                                     if (state === "SUCCESS") {
                                                                         var clientAssetList = response.getReturnValue();
                                                                         if(clientAssetList == null){
                                                                         }else{
                                                                             component.set("v.clientAssetListRedemption",clientAssetList); 
                                                                             if(orderEntry.Folio__c != ''){
                                                                                 for(var m=0 ; m < clientAssetList.length; m++){
                                                                                     if(clientAssetList[m].Folio_Number__c == orderEntry.Folio__c){
                                                                                         var quantity = clientAssetList[m].Quantity__c;
                                                                                         //orderEntry.Redemption_Units__c = quantity.toString();;
                                                                                     }
                                                                                 }
                                                                             }
                                                                             component.set("v.orderEntry",orderEntry); 
                                                                         }
                                                                     }
                                                                 });$A.enqueueAction(action); 
                                                                 
                                                                 
                                                                 
                                                             },    
                                                                 
                                                                 /* Code for file attachment ends*/
                                                                 
                                                                 getAttachmentName : function(component, event, helper){    
                                                                     
                                                                     /* Code to get Attachment Name Start */
                                                                     var orderEntry = component.get("v.orderEntry");           
                                                                     var action1 = component.get("c.getAttachName");
                                                                     action1.setParams({
                                                                         "parentId" : orderEntry.Id 
                                                                     });       
                                                                     action1.setCallback(this, function(response){
                                                                         var state = response.getState();           
                                                                         if(state === "SUCCESS"){
                                                                             var name = response.getReturnValue();                
                                                                             if(name == ''){
                                                                                 component.set('v.fileName','No File was selected');
                                                                             }else{ 
                                                                                 component.set('v.fileName',name); 
                                                                             }  
                                                                         }
                                                                     });$A.enqueueAction(action1);
                                                                     /* Code to get Attachment Name Ends */
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
                                                                                         component.set("v.folioList",foList); 
                                                                                         helper.showToast("Folio List Fetched","Success");
                                                                                     }else{
                                                                                         helper.showToast("No Data Found  !!!","Error");
                                                                                     }
                                                                                     
                                                                                 }else if(orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch'){
                                                                                     component.set("v.HoldingInformationAPI",folioListReceived); 
                                                                                     folioByAPIList.push('-- None --');
                                                                                     if(folioListReceived != null){
                                                                                         for(var m=0 ; m < folioListReceived.length; m++){
                                                                                             folioByAPIList.push(folioListReceived[m].folio);
                                                                                         }
                                                                                         component.set("v.folioList",folioByAPIList); 
                                                                                         component.set("v.folioByAPI",true); 
                                                                                         helper.showToast("Holding Information Fetched","Success");
                                                                                     }else{
                                                                                         helper.showToast("No Data Found  !!!","Error");
                                                                                     }
                                                                                 }
                                                                             }
                                                                         });$A.enqueueAction(action);
                                                                         
                                                                     }
})