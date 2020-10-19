({
    
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.callForApi");
        action.setParams({
            "orderId" : recId
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
                    
                }
                else if(responseString.includes("SUCCESS")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": responseString,
                        'type': 'success'
                    });
                    toastEvent.fire();
                    location.reload();
                }
                   else if(responseString.includes("Not Reviewed")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": responseString,
                        'type': 'error'
                    });
                    toastEvent.fire();
                    location.reload();
                } 
                  else if(responseString.includes("No Data Found")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": responseString,
                        'type': 'error'
                    });
                    toastEvent.fire();
                    location.reload();
                }
                
                
            }
            
        });$A.enqueueAction(action);
    }
})