({
        doInit: function(component, event, helper) { 
		if(component.get("v.recordId") != '' && component.get("v.recordId") != null)
        {
            component.set("v.isProcessing",true);
            var action1 = component.get("c.getIPSData");
            action1.setParams({
                IpsrecordId :component.get("v.recordId")
            });
            action1.setCallback(this, function(response) 
            {
                component.set("v.isProcessing",false);
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS")
                {
                    var returnValue = response.getReturnValue();
                    component.set("v.IPSRecord",returnValue['IPSRecord']);

                    var caseRec = returnValue['CaseRecord'];
                    var subject = returnValue['subject'];
                    if(subject != 'Mini IPS Risk Profile'){

                        $A.get("e.force:closeQuickAction").fire();
                        var showToast = $A.get('e.force:showToast');
                                    showToast.setParams({ 
                                        'title': "Error!",
                                        'message': "Available only for Mini IPS Risk profile Task",
                                        'type': 'error'
                                    });
                                    showToast.fire();	
                    }
                    if(caseRec != null && caseRec.Account != null){
                        if(caseRec.Account.Category__c == 'Corporate')
                        {
                             component.set("v.isCorporate",true); 
                        }
                        else
                        {
                            component.set("v.isCorporate",false); 
                        } 
                    }
                    var record = response.getReturnValue();
                    if(record.Id == null){
                        component.set("v.isNewIPS",true)
                    }
                }
                else if (state === "ERROR") 
                {
                	var errors = response.getError();
                	if (errors) {  
                    	if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
							var errorMessage = errors[0].pageErrors[0].message;
							var showToast = $A.get('e.force:showToast');
                            showToast.setParams({ 
                                'title': "Error!",
                                'message': errorMessage,
                                'type': 'error'
                            });
							showToast.fire();
                    	}
                        else if(errors[0] && errors[0].fieldErrors)
                        {
                        	for (var key in errors[0].fieldErrors)
                            {
                            	if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0])
                                {                               
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
            	}                
            });
            	$A.enqueueAction(action1); 
        	}
        },
    save: function(component, event, helper){
        var recordId = component.get("v.recordId");  
        helper.ValidateData(component,event,helper,recordId);
	},
    cancel: function(component, event, helper){
        var deleteCommentAction = component.get("c.getAccount");
       /* deleteCommentAction.setCallback(this, function(Response) {
            Console.log("Begin callback");
            var state1 = Response.getState();
            window.alert(Response.getReturnValue());
            console.log(response.getReturnValue());
            console.log("callback response: "+state1);
            if (state1 === "SUCCESS") {

                alert("delete Successful!");
            } else {
                alert("Save failed due to the following error: " + Response.getError()[0].message);
            }
        });*/
        $A.enqueueAction(action);
	}
})