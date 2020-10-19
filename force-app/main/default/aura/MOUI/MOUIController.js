({
    doInit : function(component, event, helper) {
         var recId = component.get("v.recordId");
        var action = component.get("c.validateCaseMandatoryDetails");    
        action.setParams({
            taskId: component.get("v.recordId")
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
                var strError = response.getReturnValue();
                if (strError === "Success"){
                    //helper.sendRequestToMOUI(component, event, helper);
                }
                else{
                    var showToast = $A.get('e.force:showToast');
                    showToast.setParams({'title': "Error!",'message': strError,'type': 'error'});
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
            });
        $A.enqueueAction(action);
        
        var action = component.get("c.isIntroductoryMailSent");    
        action.setParams({
            taskId: component.get("v.recordId")
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            var isMailSent = response.getReturnValue();
            if (isMailSent === "true"){
				component.set("v.isMailSent", isMailSent);
            }else{
				component.set("v.isMailSent", isMailSent);
			}
            
        });
        $A.enqueueAction(action);
        
         var action = component.get("c.getClientDetails");    
        action.setParams({
            taskId: component.get("v.recordId")
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            var caseObj = response.getReturnValue();
            component.set("v.salutations",caseObj["Salutation__c"]);
             component.set("v.clientName",caseObj.Account["Name"]);
             component.set("v.emailAddress",caseObj["Email_Id__c"]);
        });
        $A.enqueueAction(action);
    },
    sendRequest : function(component, event, helper) {
		//helper.sendRequestToMOUI(component, event, helper);
	},
    cancelRequest : function(component,event,helper){
        component.set("v.Confirmation", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    sendMailAndMOUI : function(component, event, helper) {
        var showToast = $A.get('e.force:showToast');
         component.set("v.isProcessing", true);
        component.set("v.MOUIPopup", false);
        component.set("v.mailPopup", false);
       var action = component.get("c.sendIntroductionMail"); 
        action.setParams({
            taskId: component.get("v.recordId"),
            Val : 'Yes'
        });
        action.setCallback(this, function(response) {
            component.set("v.MOUIPopup", false);
       		 component.set("v.mailPopup", false);
             component.set("v.isProcessing", false);
            var msg = response.getReturnValue();
             component.set("v.MOUIPopup", false);
            if(msg === 'Error'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                showToast.setParams({'title': "Error!",'message': 'Email template Not Found for CXO Please update','type': 'error'});        
            }
            if(msg === 'Error1'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                showToast.setParams({'title': "Error!",'message': 'FA CXO Mapping Not Found ','type': 'error'});        
            }
            if(msg === 'Error2'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                showToast.setParams({'title': "Error!",'message': 'Please Contact Admin , CXO Email address is not registered with salesforce ','type': 'error'});        
            }
            if(msg === 'none'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
             showToast.setParams({'title': "Error!",'message': 'Please Select Client Introduction Mail field first','type': 'error'});        
            }
            if(msg.includes('Success Mail')){
                component.set("v.Confirmation", false);
                  $A.get('e.force:refreshView').fire();
                if(msg === 'Success Mail already sent'){
                      showToast.setParams({'title': "Success!",'message': 'Mail Already sent !!!','type': 'success'});   
                }else if(msg === 'Success Mail Sent'){
                    showToast.setParams({'title': "Success!",'message': 'Introductory mail Sent !!!! ','type': 'success'});   
                }
        var action = component.get("c.sendReq"); 
        action.setParams({
            taskId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
           	var state = response.getState();
            console.log('state : ',state);
            var msg = response.getReturnValue();
            
            var showToast = $A.get('e.force:showToast');
            if(msg === 'Case details updated successfully at MOUI'){
                showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
            }else{
                showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
            }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                    showToast.fire();
                });
                $A.enqueueAction(action); 
            }
            
            setTimeout(function(){ 
             showToast.fire(); 
    }, 1000);       
        });$A.enqueueAction(action);
        
    },
    sendMOUIOnly : function(component, event, helper) {
        		    var action = component.get("c.sendReq"); 
                action.setParams({
                    taskId: component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state : ',state);
                    var msg = response.getReturnValue();
                    
                    var showToast = $A.get('e.force:showToast');
                    if(msg === 'Case details updated successfully at MOUI'){
                        showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
                    }else{
                        showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
                    }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                    showToast.fire();
                });
                $A.enqueueAction(action); 
       
    },
    sendOneReq : function(component, event, helper) {
        var Flag = 0;
         var showToast = $A.get('e.force:showToast');
        component.set("v.MOUIPopup", false);
        component.set("v.mailPopup", false);
        var isMailSent = component.get("v.isMailSent");
        if(!isMailSent){
            component.set("v.mailPopup", true);
        }else{
                    component.set("v.isProcessing", true);
            	var action = component.get("c.sendReq"); 
                action.setParams({
                    taskId: component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state : ',state);
                    var msg = response.getReturnValue();
                    component.set("v.isProcessing", false);
                    if(msg === 'Case details updated successfully at MOUI'){
                        showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
                    }else{
                        showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
                    }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
            showToast.fire();
                });
                $A.enqueueAction(action); 
        }
        /*var action = component.get("c.sendIntroductionMail"); 
        action.setParams({
            taskId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var msg = response.getReturnValue();
            
            var showToast = $A.get('e.force:showToast');
            if(msg === 'Error'){
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
                showToast.setParams({'title': "Error!",'message': 'Email template Not Found for CXO Please update','type': 'error'});        
            }
            if(msg === 'Error1'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                showToast.setParams({'title': "Error!",'message': 'FA CXO Mapping Not Found ','type': 'error'});        
            }
            if(msg === 'none'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
             showToast.setParams({'title': "Error!",'message': 'Please Select Client Introduction Mail field first','type': 'error'});        
            }
            if(msg.includes('Success Mail')){
                component.set("v.Confirmation", false);
                  $A.get('e.force:refreshView').fire();
                if(msg === 'Success Mail already sent'){
                      showToast.setParams({'title': "Success!",'message': 'Mail Already sent !!!','type': 'success'});   
                }else if(msg === 'Success Mail Sent'){
                    showToast.setParams({'title': "Success!",'message': 'Introductory mail Sent !!!! ','type': 'success'});   
                }
                var action = component.get("c.sendReq"); 
                action.setParams({
                    taskId: component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state : ',state);
                    var msg = response.getReturnValue();
                    
                    var showToast = $A.get('e.force:showToast');
                    if(msg === 'Case details updated successfully at MOUI'){
                        showToast.setParams({'title': "Success!",'message': msg,'type': 'success'});
                    }else{
                        showToast.setParams({'title': "Error!",'message': msg,'type': 'error'});
                    }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                    showToast.fire();
        });
        $A.enqueueAction(action); 
	}
            showToast.fire();
            
        });$A.enqueueAction(action);
        
        if(Flag == 0){
            
        }*/
    }
})