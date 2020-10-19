({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateUser");            
        action.setCallback(this, function(response) 
            {
                var strError = response.getReturnValue();
                if (strError=== "Success")
                {
                    helper.getRedirectURLCall(component, event, helper);
                }
                else{
                    var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'message': strError,
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
            });
        $A.enqueueAction(action); 
	}
})