({
	skipMOUI : function(component, event, helper) {
		var flag = false;
        var action = component.get("c.skipMOUI"); 
        action.setParams({
            taskId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var msg = response.getReturnValue();
            var showToast = $A.get('e.force:showToast');
            if(msg === 'TaskClosed'){
                var action2 = component.get("c.updateSubStatus"); 
                action2.setParams({
                    taskId: component.get("v.recordId")
                });
                action2.setCallback(this, function(response1){
                    var msg = response1.getReturnValue();
                    if(msg === 'MOUI request skipped successfully'){
                        showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
                    }else{
                        showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
                    }
                    showToast.fire();
                  //  $A.get("e.force:closeQuickAction").fire();
                   // $A.get('e.force:refreshView').fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": window.location.href 
        });
        urlEvent.fire();
                    
                    
                    
                });
                $A.enqueueAction(action2);
            }else{
                showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
                showToast.fire();
                var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": window.location.href 
        });
        urlEvent.fire();
                    
               // $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
        
	},
    showToast : function(component, event, helper,msg,type){
        setTimeout(function(){ 
             component.set("v.isProcessing", false);
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    }, 2000);
        
    },
        showToast2 : function(component, event, helper,msg,type){
             component.set("v.isProcessing", false);
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    
        showToast1 : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
	}
})