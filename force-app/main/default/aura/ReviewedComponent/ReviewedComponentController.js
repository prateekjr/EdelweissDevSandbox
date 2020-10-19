({
    doInit : function(component, event, helper) {  
        // $A.get("e.force:closeQuickAction").fire(); 
        component.set("v.spinner",true);
        var result1;
        var action1 = component.get("c.checkForProfile");
        action1.setCallback(this, function(response){
            var state = response.getState(); 			            
            if(state === "SUCCESS"){                   
                if(response.getReturnValue() == -1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Unauthorized_Access_is_denied :: Review Order',
                        'type': 'Error'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); 
                }  else {  
                    
                    var recId = component.get("v.recordId");
                    
                    var action = component.get("c.getOrderEntryObj");
                    action.setParams({
                        recordId : recId
                    });                  
                    
                    action.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var orderEntryObj = response.getReturnValue();
                            if(orderEntryObj == null){
                                helper.showToast("Client not found for family","Error");
                            }else{  
                                 
                                var orderEntrymf = orderEntryObj.OrderEntryMF__c;
                                var recId = component.get("v.recordId");
                                if(orderEntryObj.Product_Type_Order_Entry__c == 'Bond'){
                                    var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                    
                                    
                                }else if (orderEntryObj.Product_Type_Order_Entry__c == 'MF' && !orderEntrymf){
                                    
                                    //helper.doInitHelper(component, event, helper); 
                                    var recId = component.get("v.recordId");
                                    var action = component.get("c.setIsReviewed");
                                    action.setParams({
                                        "recordId" : recId
                                    });       
                                    
                                    action.setCallback(this, function(response){
                                        var state = response.getState();             
                                        if(state === "SUCCESS"){                
                                            var result = response.getReturnValue();               
                                            if(result == 1){                    
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Success!",
                                                    "message": "Record reviewed successfully.",
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                
                                                var delayInMilliseconds = 2000; //1 second
                                                setTimeout(function() {                                    
                                                    $A.get('e.force:refreshView').fire();
                                                }, delayInMilliseconds); 
                                            } else if(result == 0 || result == null){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Warning!",
                                                    "message": "Record is already reviewed.",
                                                    'type': 'Warning'
                                                });
                                                toastEvent.fire();
                                                
                                            }else if(result == -1){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Error!",
                                                    "message": "Record is not submitted for review.",
                                                    'type': 'Error'
                                                });
                                                toastEvent.fire();
                                            }
                                            /*var action = component.get("c.callForApi");
                                action.setParams({
                                    recordId : recId
                                });       
                                action.setCallback(this, function(response){
                                    var state = response.getState();             
                                    if(state === "SUCCESS"){
                                    }
                                }); $A.enqueueAction(action); */
                                            
                                        } else {
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "title": "Warning!",
                                                "message": "Something went wrong!.",
                                                'type': 'Warning'
                                            });
                                            toastEvent.fire();
                                        }
                                        $A.get("e.force:closeQuickAction").fire(); 
                                    }); $A.enqueueAction(action); 
                                }
                                else if (orderEntryObj.Product_Type_Order_Entry__c == 'MF' && orderEntrymf){
                                    var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                }
                                    
                                    else if(orderEntryObj.Product_Type_Order_Entry__c == 'PMS'){
                                  var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                    
                                    
                                }else if(orderEntryObj.Product_Type_Order_Entry__c == 'SP' || orderEntryObj.Product_Type_Order_Entry__c == 'CP' || orderEntryObj.Product_Type_Order_Entry__c == 'CD' || orderEntryObj.Product_Type_Order_Entry__c == 'FD' ||orderEntryObj.Product_Type_Order_Entry__c == 'ICD'){
                                  var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                    
                                    
                                } else if(orderEntryObj.Product_Type_Order_Entry__c == 'PE / AIF'){
                                  var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                    
                                    
                                }else if(orderEntryObj.Product_Type_Order_Entry__c == 'IPO'){
                                  var action = component.get("c.callForApi");
                                    action.setParams({
                                        "recordId" : recId
                                    });                  
                                    action.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            component.set("v.spinner",false);
                                            var responseString = response.getReturnValue();  
                                            
                                            if(responseString.includes("FAILURE")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'error'
                                                });
                                                toastEvent.fire();
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                       location.reload();
                                                    }), 1000
                                                );
                                                
                                            }else if(responseString.includes("SUCCESS")){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "message": responseString,
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                location.reload();
                                            }
                                            
                                            
                                        }
                                        
                                    });$A.enqueueAction(action);
                                    
                                    
                                }
                                
                                
                            }
                        }
                        
                    });$A.enqueueAction(action);
                    
                }  
                
            }
        });$A.enqueueAction(action1);             
    }, 
    
})