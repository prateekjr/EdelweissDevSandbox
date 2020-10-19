({
	markComplete : function(component, event, helper){        
       	var fieldList = component.get("v.fieldList");
        var completeChecklist = true; 
        if(fieldList != null){
            for(var i=0; i < fieldList.length; i++){                        
                if(fieldList[i] != null && !fieldList[i].value){
                    completeChecklist = false; 
                }                                       
            }
        } 
        component.set("v.completeChecklist", completeChecklist);        
    },
    getFieldValue : function(component, event, helper){
    	
        var action = component.get("c.getChecklistFieldData");
        action.setParams({ObjectType : 'Product2',
                          Record : component.get("v.productRecord"),
                          fieldsetName : component.get("v.fieldsetName")}); 
         	
        action.setCallback(this, function(a){           
            component.set("v.fieldList", a.getReturnValue());
			setTimeout( $A.getCallback(function() {
                helper.markComplete(component, event, helper);
            }) ,500);            
        });
        $A.enqueueAction(action);
	}
    
})