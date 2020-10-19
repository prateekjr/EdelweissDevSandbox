({
    // ## function call on component load  
    loadDummyList: function(component, event, helper){
        helper.onLoad(component, event);
    },
    
    // ## function call on Click on the "Download As TXT" Button. 
    downloadTxt : function(component,event,helper){   
        // File 1      
        var selectedValPRNormal = 'Purchase/Redemption Normal';  
        component.set("v.isProcessing",true);
        var action = component.get('c.fetchTransactionToExport');
        action.setParams({
            transactionType : selectedValPRNormal
        });
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isProcessing", false);
                component.set('v.ListOfSchema', response.getReturnValue());
                var stockData = component.get("v.ListOfSchema");        
                if(stockData == ''){
                    component.set('v.showErrorForPurRedN', true);
                    helper.showError(component, event, helper);
                }
                // call the helper function which "return" the TXT data as a String   
                if(stockData != ''){
                    var txt = helper.convertArrayOfObjectsToTXT(component,stockData,selectedValPRNormal);   
                    if (txt == null){return;} 
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = (today.getMonth()+1);
                    var hh =  today.getHours();   
                    var min = today.getMinutes();
                    var sec = today.getSeconds();
                    var yy = today.getFullYear().toString().substr(-2);
                    
                    if(dd<10){ dd='0'+dd;	
                             }if(mm<10) {mm='0'+mm;
                                        } if(hh<10){hh='0'+hh;
                                                   } if(min<10){min='0'+min;
                                                               } if(sec<10){sec='0'+sec;
                                                                           } 
                    var date = dd+''+mm+''+yy;
                    var time =  hh +''+ min + '' + sec;
                    var dateTime = date+''+time; 
                    var fileName = '';       
                    fileName = 'ARN_Pur_Red_'+dateTime+'.csv'
                    helper.downloadFile(component, event, helper,fileName,txt);    
                    helper.showError(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
        // get the Records [contact] list from 'ListOfSchema' attribute 
        
        // File 2  
        
        var selectedValSNormal = 'Switch Normal';  
        component.set("v.isProcessing",true);
        var action = component.get('c.fetchTransactionToExport');
        action.setParams({
            transactionType : selectedValSNormal
        });
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfSchema attribute on component.
                component.set("v.isProcessing", false);
                component.set('v.ListOfSchema', response.getReturnValue());
                var stockData = component.get("v.ListOfSchema");        
                if(stockData == ''){
                    component.set('v.showErrorForSwitchN', true);
                    helper.showError(component, event, helper);
                } 
                // call the helper function which "return" the TXT data as a String  
                if(stockData != ''){ 
                    var txt = helper.convertArrayOfObjectsToTXT(component,stockData,selectedValSNormal);   
                    if (txt == null){return;} 
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = (today.getMonth()+1);
                    var hh =  today.getHours();   
                    var min = today.getMinutes();
                    var sec = today.getSeconds();
                    var yy = today.getFullYear().toString().substr(-2);
                    
                    if(dd<10){ dd='0'+dd;	
                             }if(mm<10) {mm='0'+mm;
                                        } if(hh<10){hh='0'+hh;
                                                   } if(min<10){min='0'+min;
                                                               } if(sec<10){sec='0'+sec;
                                                                           } 
                    var date = dd+''+mm+''+yy;
                    var time =  hh +''+ min + '' + sec;
                    var dateTime = date+''+time; 
                    var fileName = '';       
                    fileName = 'ARN_Switch_'+dateTime+'.csv'
                    helper.downloadFile(component, event, helper,fileName,txt);  
                    helper.showError(component, event, helper);
                }      
            }
        });
        $A.enqueueAction(action);
        // get the Records [contact] list from 'ListOfSchema' attribute 
        
        
        // File 3
        var selectedValPRDirect = 'Purchase/Redemption Direct';  
        component.set("v.isProcessing",true);
        var action = component.get('c.fetchTransactionToExport');
        action.setParams({
            transactionType : selectedValPRDirect
        });
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfSchema attribute on component.
                component.set("v.isProcessing", false);
                component.set('v.ListOfSchema', response.getReturnValue());
                var stockData = component.get("v.ListOfSchema");        
                if(stockData == ''){
                    component.set('v.showErrorForPurRedD', true);
                    helper.showError(component, event, helper);
                } 
                // call the helper function which "return" the TXT data as a String   
                // 
                
                if(stockData != ''){
                    var txt = helper.convertArrayOfObjectsToTXT(component,stockData,selectedValPRDirect);   
                    if (txt == null){return;} 
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = (today.getMonth()+1);
                    var hh =  today.getHours();   
                    var min = today.getMinutes();
                    var sec = today.getSeconds();
                    var yy = today.getFullYear().toString().substr(-2);
                    
                    if(dd<10){ dd='0'+dd;	
                             }if(mm<10) {mm='0'+mm;
                                        } if(hh<10){hh='0'+hh;
                                                   } if(min<10){min='0'+min;
                                                               } if(sec<10){sec='0'+sec;
                                                                           } 
                    var date = dd+''+mm+''+yy;
                    var time =  hh +''+ min + '' + sec;
                    var dateTime = date+''+time; 
                    var fileName = '';       
                    
                    fileName = 'RIA_Pur_Red_'+dateTime+'.csv'
                    helper.downloadFile(component, event, helper,fileName,txt);  
                    helper.showError(component, event, helper);
                }     
            }
        });
        $A.enqueueAction(action);
        // get the Records [contact] list from 'ListOfSchema' attribute 
        
        
        // File 4
        var selectedValSDirect = 'Switch Direct';  
        component.set("v.isProcessing",true);
        var action = component.get('c.fetchTransactionToExport');
        action.setParams({
            transactionType : selectedValSDirect
        });
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfSchema attribute on component.
                component.set("v.isProcessing", false);
                component.set('v.ListOfSchema', response.getReturnValue());
                var stockData = component.get("v.ListOfSchema");        
                if(stockData == ''){
                    component.set('v.showErrorForSwitchD', true);
                    helper.showError(component, event, helper);
                } 
                // call the helper function which "return" the TXT data as a String   
                if(stockData != ''){
                    var txt = helper.convertArrayOfObjectsToTXT(component,stockData,selectedValSDirect);   
                    if (txt == null){return;} 
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = (today.getMonth()+1);
                    var hh =  today.getHours();   
                    var min = today.getMinutes();
                    var sec = today.getSeconds();
                    var yy = today.getFullYear().toString().substr(-2);
                    
                    if(dd<10){ dd='0'+dd;	
                             }if(mm<10) {mm='0'+mm;
                                        } if(hh<10){hh='0'+hh;
                                                   } if(min<10){min='0'+min;
                                                               } if(sec<10){sec='0'+sec;
                                                                           } 
                    var date = dd+''+mm+''+yy;
                    var time =  hh +''+ min + '' + sec;
                    var dateTime = date+''+time; 
                    var fileName = '';       
                    fileName = 'RIA_Switch_'+dateTime+'.csv'
                    helper.downloadFile(component, event, helper,fileName,txt); 
                    helper.showError(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
        
        
        
        
        // get the Records [contact] list from 'ListOfSchema' attribute v
    }, 
})