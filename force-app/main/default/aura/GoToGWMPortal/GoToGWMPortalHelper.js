({
	getRedirectURLCall : function(component, event, helper) {
		
        var action = component.get("c.redirectURLCall"); 
        var recordId = component.get("v.recordId");
        action.setParams({
                accId: component.get("v.recordId")
         });
        action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    component.set("v.objcallBack",response.getReturnValue());
                    var objcallBack = response.getReturnValue();
                    if(objcallBack.isSuccess){
                        var redirectionURL = objcallBack.returnBody;
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": redirectionURL
                        });
                        urlEvent.fire();
                    }else{
                       	var showToast = $A.get('e.force:showToast');
                        showToast.setParams({ 
                            'title': "Error!",
                            'message': objcallBack.errorMessage,
                            'type': 'error'
                        });
                        showToast.fire();
                    } 
                } 
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
        $A.enqueueAction(action); 
	}
})