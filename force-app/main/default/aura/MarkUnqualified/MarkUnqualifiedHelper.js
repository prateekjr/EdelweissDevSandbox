({
	showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
         closeModel: function(component, event, helper , recId) {
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": recId
        });
        urlEvent.fire();
    }
})