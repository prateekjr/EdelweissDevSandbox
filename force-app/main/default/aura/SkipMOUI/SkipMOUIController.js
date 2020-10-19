({
    doInit : function(component, event, helper) {
        var action = component.get("c.validateDetailsForSkipMOUI");    
        action.setParams({
            taskId: component.get("v.recordId")
        });       
        action.setCallback(this, function(response) {
            var strError = response.getReturnValue();
            if (strError === "Success") {
            }
            else {
                var showToast = $A.get('e.force:showToast');
                showToast.setParams({'title': "Error!",'message': strError,'type': 'error'});
                showToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action); 
        var recId = component.get("v.recordId");
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
    sendSkipMOUI : function(component, event, helper) {
        var action = component.get("c.validateDetailsForSkipMOUI");    
        action.setParams({
            taskId: component.get("v.recordId")
        });       
        action.setCallback(this, function(response) {
            var strError = response.getReturnValue();
            if (strError === "Success") {
                helper.skipMOUI(component, event, helper);
            }
            else {
                var showToast = $A.get('e.force:showToast');
                showToast.setParams({'title': "Error!",'message': strError,'type': 'error'});
                showToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    sendMailAndSkipMOUI : function(component, event, helper) {
        var emessage = '';
        var smessage = '';
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
            var msg = response.getReturnValue();
            component.set("v.MOUIPopup", false);
            if(msg === 'Error'){
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                emessage = 'Email template Not Found for CXO Please update';
               helper.showToast2(component, event, helper,'Email template Not Found for CXO Please update','error');        
            }
            if(msg === 'Error1'){
                  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
                 emessage = 'FA CXO Mapping Not Found';
              helper.showToast2(component, event, helper,'FA CXO Mapping Not Found','error');  
            }if(msg === 'Error2'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
helper.showToast2(component, event, helper,'Please Contact Admin , CXO Email address is not registered with salesforce ','error');               }
            if(msg === 'none'){
                 emessage = 'Please Select Client Introduction Mail field first';
                helper.showToast(component, event, helper,'Please Select Client Introduction Mail field first','error'); 
            }
            if(msg.includes('Success Mail')){  
                
                component.set("v.MOUIPopup", false);
                component.set("v.mailPopup", false);
                
                if(msg === 'Success Mail already sent'){
                    smessage = 'Mail Already sent !!!';
                    helper.showToast(component, event, helper,'Mail Already sent !!!','success'); 
                }else if(msg === 'Success Mail Sent'){
                    smessage = 'Introductory mail Sent !!!!';
                   helper.showToast(component, event, helper,'Introductory mail Sent !!!! ','success'); 
                }
                var action = component.get("c.validateDetailsForSkipMOUI");    
                action.setParams({
                    taskId: component.get("v.recordId")
                });       
                action.setCallback(this, function(response) {
                    
                    var strError = response.getReturnValue();
                    if (strError === "Success") {
                        helper.skipMOUI(component, event, helper);
                    }
                    else {
                         helper.showToast(component, event, helper,strError,'error'); 
                    }
                });
                $A.enqueueAction(action); 
            }
        });$A.enqueueAction(action);
        
    },
    sendRequest : function(component, event, helper) {
        component.set("v.MOUIPopup", false);
        component.set("v.mailPopup", false);
        var isMailSent = component.get("v.isMailSent");
        if(!isMailSent){
            component.set("v.mailPopup", true);
        }else{
            component.set("v.isProcessing", true);
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
                showToast.setParams({'title': "Error!",'message': 'FA CXO Mapping Not Found','type': 'error'});        
            }
             if(msg === 'none'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
             showToast.setParams({'title': "Error!",'message': 'Please Select Client Introduction Mail field first','type': 'error'});        
            }
            if(msg.includes('Success Mail')){
                if(msg === 'Success Mail already sent'){
                      showToast.setParams({'title': "Success!",'message': 'Mail sent Already sent !!!','type': 'success'});   
                }else if(msg === 'Success Mail Sent'){
                    showToast.setParams({'title': "Success!",'message': 'Introductory mail Sent !!!! ','type': 'success'});   
                }*/
            var action = component.get("c.validateDetailsForSkipMOUI");    
            action.setParams({
                taskId: component.get("v.recordId")
            });       
            action.setCallback(this, function(response) {
                var strError = response.getReturnValue();
                if (strError === "Success") {
                    helper.skipMOUI(component, event, helper);
                }
                else {
                    showToast.setParams({'title': "Error!",'message': strError,'type': 'error'});
                    showToast.fire();
                }
            });
            $A.enqueueAction(action); 
        }
    }
    ,
    cancelRequest : function(component,event,helper){
        component.set("v.Confirmation", false);
        $A.get("e.force:closeQuickAction").fire();
    }
})