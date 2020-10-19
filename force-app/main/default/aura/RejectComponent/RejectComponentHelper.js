({
	doInitHelper : function(component, event, helper) {
        //alert('inside reject helper');		        
	},
    showToast : function(msg,type){
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
})