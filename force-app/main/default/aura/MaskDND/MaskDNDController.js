({
    doInit: function(component, event, helper) { 
     var recId = component.get("v.recordId");
    var action = component.get("c.maskDNDByCXO");
           action.setParams({
                "recId" : recId
            });
            action.setCallback(this, function(response) 
            {
                var strError = response.getReturnValue();
                if(strError.includes('Success')){
                   component.set("v.isSuccess",true);
                }
                else{
                    component.set("v.isSuccess",false);
                   component.set("v.ErrorMsg",strError);
                }
            });
            $A.enqueueAction(action); 
    }
})