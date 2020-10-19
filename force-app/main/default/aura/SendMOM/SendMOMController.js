({
	doInit : function(component, event, helper) {
		var action = component.get("c.sendEmail");
		action.setParams({ eventId : component.get("v.recordId") });
               
        
        action.setCallback(this, function(a){            
            
            if(a.getState() == "ERROR"){
                var errors = a.getError();
                if (errors) {                    
                    
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        var showToast = $A.get('e.force:showToast');
                        showToast.setParams({'title': "Error!",
                            				 'message': errors[0].pageErrors[0].message,
                                             'type' :'error'});
                        showToast.fire();
                    }else if(errors[0] && errors[0].fieldErrors){                        
                        for (var key in errors[0].fieldErrors){
                            if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0]){                               
                                var showToast = $A.get('e.force:showToast');
                                showToast.setParams({ 
                                    'title': "Error!",
                                    'message': errors[0].fieldErrors[key][0].message,
                                    'type': 'error'
                                });
                                showToast.fire();
                            }
                        }                       
                    }
                }
            }else{
              	var Urlstring = a.getReturnValue();
                if(Urlstring == 'Error'){
                    var showToast = $A.get('e.force:showToast');
                                showToast.setParams({ 
                                    'title': "Error!",
                                    'message': 'Please enter Meeting Notes(Minutes of meeting)',
                                    'type': 'error'
                                });
                                showToast.fire(); 
                }else{
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": Urlstring
                    });
                    urlEvent.fire();
                }
            }
            $A.get("e.force:closeQuickAction").fire();
        }); 
        $A.enqueueAction(action);  
	}
})