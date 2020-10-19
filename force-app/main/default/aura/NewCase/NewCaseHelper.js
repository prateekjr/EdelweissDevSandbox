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
    
    getRecordTypeSRId: function(component, event, helper) {
        var action = component.get("c.getRecordTypeSRId");
        action.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.serviceRequestId", infos); 
        });
        $A.enqueueAction(action);
    },
    
    getRecordTypeAOId: function(component, event, helper) {
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
    },
     getRecordTypeFinancialTransactionId: function(component, event, helper) {
        var action = component.get("c.getRecordTypeFinancialTransactionId");
        action.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.FinancialTransactionId", infos); 
        });
        $A.enqueueAction(action);
    }
    ,
     getRecordTypeWealthInWardingId: function(component, event, helper) {
        var action = component.get("c.getRecordTypeWealthInWardingId");
        action.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.WealthInWardingId", infos); 
        });
        $A.enqueueAction(action);
    }
    
})