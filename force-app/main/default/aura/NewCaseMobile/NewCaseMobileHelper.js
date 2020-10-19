({
   RecordTypeSelectorController: function(component) {
    var action = component.get("c.getListOfRecordType");
    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue();
        //component.set("v.recordTypes", infos);  
        component.set("v.myrRecordTypes", infos); 
    });
    $A.enqueueAction(action);
  },
    getRecordTypeSRId: function(component) {
    var action = component.get("c.getRecordTypeSRId");
    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue();
        component.set("v.serviceRequestId", infos); 
    });
    $A.enqueueAction(action);
  },
    getRecordTypeAOId: function(component) {
    var action = component.get("c.getRecordTypeAOId");
    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue();
        component.set("v.accountOpeningId", infos); 
    });
    $A.enqueueAction(action);
  },
        getRecordTypeFTId: function(component, event, helper) {
        var action = component.get("c.getRecordTypeFTId");
        action.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.FundTransferId", infos); 
        });
        $A.enqueueAction(action);
  }
})