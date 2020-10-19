({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getName");  
        action.setParams({
            "recId" : recId
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var name = response.getReturnValue();
               	var v1 ='https://news.google.com/search?q=';
                var v2 = name;
                var v3 = '&hl=en-IN&gl=IN&ceid=IN%3Aen';
                var f = v1+v2+v3;
                 $A.get("e.force:closeQuickAction").fire() 
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": f
                });
                eUrl.fire();
                /*window.open(f,"_self");*/
            }
                           });$A.enqueueAction(action);
    }
    
    
    
})