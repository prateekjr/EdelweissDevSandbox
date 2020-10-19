({
	sendRequestToMOUI : function(component, event, helper) {
        	component.set("v.MOUIPopup", false);
        	component.set("v.mailPopup", false);
		    var action = component.get("c.sendReq"); 
        action.setParams({
            taskId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
           	var state = response.getState();
            console.log('state : ',state);
            var msg = response.getReturnValue();
            
            var showToast = $A.get('e.force:showToast');
            if(msg === 'Case details updated successfully at MOUI'){
                showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
            }else{
                showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
                    showToast.fire();
        });
        $A.enqueueAction(action); 
	}
})