({
	ValidateData : function(component, event, helper,recordId) {
      var IPSRecord = component.get("v.IPSRecord"); 
      var validateList = [];
      var isCoperate = component.get("v.isCorporate"); 

        if(isCoperate){
            validateList.push(IPSRecord.Equity_Markets__c);
        }
        else{
            validateList.push(IPSRecord.Age__c);
        }        
        validateList.push(IPSRecord.Investment_philosophy__c);
        validateList.push(IPSRecord.Investment_goal__c);
        validateList.push(IPSRecord.Financial_Goals__c);
        validateList.push(IPSRecord.worst_and_best_one_year_return__c);
        validateList.push(IPSRecord.Amount_of_fluctuations__c);
        validateList.push(IPSRecord.Diversified_portfolio__c);
        validateList.push(IPSRecord.Interest_in_leverage_borrowing_products__c);
        validateList.push(IPSRecord.Alternative_Investments__c);
        validateList.push(IPSRecord.Investment_portfolio__c);
        validateList.push(IPSRecord.Investment_Style__c);
 		helper.showError(component, event, helper,validateList,recordId);
    },
    showError : function (component, event, helper,Inputs,recordId){
        var IPSRecord = component.get("v.IPSRecord");
        var isCoperate = component.get("v.isCorporate");
        if(IPSRecord.Time_line_for_Trading__c == '---None---'){
            IPSRecord.Time_line_for_Trading__c = null;
        }
        if(isCoperate){
         if(IPSRecord.Age__c == '---None---'){
       	     IPSRecord.Age__c = null;
       	 }
        }
        var isValid = true;
        for(var i in Inputs){
           var d = Inputs[i];
            if(d == '---None---'){
				isValid = false;
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Please Enter mandatory Details"
                });
                toastEvent.fire();    */
                component.set("v.messageBody",'Please Enter mandatory Details'); 
                break;
            }
        }
        if(isValid){           
			component.set("v.isProcessing",true);
       		var action = component.get("c.saveDetails");
       		action.setParams({ recordId : recordId , IPSRecordObj : IPSRecord});
   			action.setCallback(this, function(response){
                component.set("v.isProcessing",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "IPS Successfully Saved"
                    });
                    toastEvent.fire();

                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                    "url": "/"+recordId
                   });
                   urlEvent.fire();
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
    		$A.enqueueAction(action);
		}

    }
})