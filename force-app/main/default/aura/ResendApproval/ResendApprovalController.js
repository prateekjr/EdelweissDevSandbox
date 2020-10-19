({
	doInit : function(component, event, helper) {
		var action = component.get("c.getResendDetail");
            action.setParams({
                recordId :component.get("v.recordId")
            });
            action.setCallback(this, function(response) 
            {
               	var state = response.getState();               
                if (component.isValid() && state === "SUCCESS")
                {                    
                   var msg = response.getReturnValue();
                    if(msg.indexOf('Successfully') != -1 && msg.indexOf('submitted') != -1){
                      component.set("v.isError",false);  
                    }else{
                      component.set("v.isError",true);    
                    }
                    component.set("v.message",msg);                  
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.history.back();
                        }), 3000
                    );
                     
                }
                else if (state === "ERROR")
                { 
                   	component.set("v.isError",true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.history.back();
                        }), 3000
                    );
            	}
            });
        	$A.enqueueAction(action); 
	}
})