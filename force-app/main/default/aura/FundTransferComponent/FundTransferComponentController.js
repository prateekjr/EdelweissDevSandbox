({
    doInit : function(component, event, helper) {      
        
        var recId = component.get("v.recordId");
        var action = component.get("c.setIsFundTransfered");
        action.setParams({
            recordId : recId
        });       
        action.setCallback(this, function(response){
            var state = response.getState(); 
            
            if(state === "SUCCESS"){
                var delayInMilliseconds = 2000; 
                setTimeout(function() {
                    helper.showToast("Fund Transfer done successfully","Success");
                    $A.get('e.force:refreshView').fire();
                }, delayInMilliseconds); 
            } else {
                helper.showToast("Fund Transfer already done","Warning");
			}
            $A.get("e.force:closeQuickAction").fire();
        }); $A.enqueueAction(action);         
    },
    
})