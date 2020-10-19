({
	openSingleFile : function (component,event){           
        var action = component.get("c.getFilecontent");
        
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.fileString", 'data:application/pdf;base64,'+response.getReturnValue());
                var fireEvent = $A.get("e.lightning:openFiles");
                fireEvent.fire({
                    recordIds: [response.getReturnValue()]
                }); 
            }
 
        });
        $A.enqueueAction(action);        
          
    }
})