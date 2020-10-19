({
    getRecordTypeFTId: function(component, event, helper) {
        var action = component.get("c.getRecordTypeFTId");
        action.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.FundTransferId", infos); 
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper,msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": 'Error',
            "message": msg
        });
        toastEvent.fire();
    }
})