({
    getAccount: function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) 
        {                
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.account",response.getReturnValue());
                var acc = response.getReturnValue();
                if(acc.Category__c == 'Corporate')
                {
                     component.set("v.isCorporate",true); 
                }
                else
                {
                    component.set("v.isCorporate",false); 
                } 
            }                
        });
        $A.enqueueAction(action); 
    }
})