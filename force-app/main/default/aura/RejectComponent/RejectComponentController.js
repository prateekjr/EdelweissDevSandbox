({
    doInit : function(component, event, helper) {              
        var action1 = component.get("c.checkForProfile");
        action1.setCallback(this, function(response){
            var state = response.getState();             
            if(state === "SUCCESS"){
                var result = response.getReturnValue();  
                if(result == -1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Unauthorized_Access_is_denied :: Reject Order',
                        'type': 'Error'
                    });
                    toastEvent.fire();
                    
                } else {                     
                    var recId = component.get("v.recordId");
                    var action = component.get("c.setIsRejected");
                    action.setParams({
                        recordId : recId
                    });       
                    action.setCallback(this, function(response){
                        var state = response.getState();             
                        if(state === "SUCCESS"){
                            var result = response.getReturnValue();               
                            if(result == 1){
                               /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Rejected!",
                                    "message": "Record is rejected.",
                                    'type': 'Error'
                                });
                                toastEvent.fire();*/
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                     helper.showToast("Record is rejected..","Error");
                                    $A.get('e.force:refreshView').fire();
                                }, delayInMilliseconds); 
                            } else if(result == 0 || result == null){
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                     helper.showToast("Record is already rejected.","Warning");
                                    $A.get('e.force:refreshView').fire();
                                }, delayInMilliseconds); 
                                /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Warning!",
                                    "message": "Record is already rejected.",
                                    'type': 'Warning'
                                });
                                toastEvent.fire();*/
                                
                            }else if(result == -1){
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                     helper.showToast("Record is not submitted for review or not eligible for Reject","Error");
                                    $A.get('e.force:refreshView').fire();
                                }, delayInMilliseconds); 
                                /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "message": "Record is not submitted for review.",
                                    'type': 'Error'
                                });
                                toastEvent.fire();*/
                            }
                            
                            /*Added by Raj */
                                else if(result == 2){
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                     helper.showToast("Rejection for order is not allowed since Fund Transfer is completed","Error");
                                    $A.get('e.force:refreshView').fire();
                                }, delayInMilliseconds); 
                                /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "message": "Record is not submitted for review.",
                                    'type': 'Error'
                                });
                                toastEvent.fire();*/
                            
                        }   
                            
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Warning!",
                                "message": "Something went wrong!",
                                'type': 'Warning'
                            });
                            toastEvent.fire();
                        }
                        $A.get("e.force:closeQuickAction").fire();   
                    }); $A.enqueueAction(action);  
                }
               /* var delayInMilliseconds = 2000; //1 second
                setTimeout(function() {
                    $A.get('e.force:refreshView').fire();
                }, delayInMilliseconds);
              $A.get("e.force:closeQuickAction").fire();  */ 
            } else{
                
            }
        });$A.enqueueAction(action1);         
    }, 
    
})