({
	doInit : function(component, event, helper) {
		var action = component.get("c.getStageInfo");
        action.setParams({ CaseId : component.get("v.recordId")});         	
        action.setCallback(this, function(a){           
            var returnData = a.getReturnValue();
            if(returnData != null && returnData[0] != null && returnData[0].label != 'SellCase')
            	component.set("v.fieldList", a.getReturnValue());
            else
            	component.set("v.isNoData", true);
        });
        $A.enqueueAction(action);
	}
})