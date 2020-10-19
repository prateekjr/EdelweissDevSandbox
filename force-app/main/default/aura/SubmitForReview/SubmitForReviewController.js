({
    doInit : function(component, event, helper) {      
        //$A.get("e.force:closeQuickAction").fire();
        // 
        var action1 = component.get("c.checkForProfile");
        action1.setCallback(this, function(response){
            var state = response.getState();             
            if(state === "SUCCESS"){
                var result = response.getReturnValue();  
                if(result == -1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Unauthorized_Access_is_denied :: Submit For Review',
                        'type': 'Error'
                    });
                    toastEvent.fire();
                    
                } else {
                     
                    	var recId = component.get("v.recordId");
                        var action = component.get("c.setIsSubmitForReviewed");
                        action.setParams({
                            recordId : recId
                        });       
                        action.setCallback(this, function(response){
                            var state = response.getState(); 
                           
                            if(state === "SUCCESS"){
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                    //helper.showToast("Record successfully submit for review","Success");
                                    //$A.get('e.force:refreshView').fire();
                                   	var result = response.getReturnValue();       
										if(result == 2){                    
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Success!",
                                                    "message": "Record successfully submitted for review",
                                                    'type': 'success'
                                                });
                                                toastEvent.fire();
                                                
                                                var delayInMilliseconds = 2000; //1 second
                                                setTimeout(function() {                                    
                                                    $A.get('e.force:refreshView').fire();
                                                }, delayInMilliseconds); 
                                            } else if(result == 1){                    
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Success!",
                                                    "message": "Record Reviewed successfully.",
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
                                            }else if(result == 3){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Error!",
                                                    "message": "Record is not eligible for submitted for review.",
                                                    'type': 'Error'
                                                });
                                                toastEvent.fire();
                                            }
                                }, delayInMilliseconds); 
                            } else {
                                helper.showToast("Record is already submitted for review or not eligible for submitted for review.","Warning");
                            }
                            $A.get("e.force:closeQuickAction").fire();
                        }); $A.enqueueAction(action);         
                       }
                
                //$A.get("e.force:closeQuickAction").fire();   
            } else{
                
            }
        });$A.enqueueAction(action1);            
    }, 
    
})