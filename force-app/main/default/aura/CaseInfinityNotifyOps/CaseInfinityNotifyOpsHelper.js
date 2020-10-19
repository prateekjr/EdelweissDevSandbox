({
    getRedirectURLCall : function(component, event, helper) {
        
        var action = component.get("c.callApi"); 
        var recordId = component.get("v.recordId");
        action.setParams({
            caseRecordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (component.isValid() && state === "SUCCESS"){
                                   component.set("v.objcallBack",response.getReturnValue());
                                   var objcallBack = response.getReturnValue();
                                   if(objcallBack.isSuccess){
                                       var redirectionURL = objcallBack.returnBody;
                                       //var redirectionURL ='https://prismtest.edelweiss.in/QA1/Prism/?i='+ caseNumber+'&n='+leadcaseName +'&p='+ casePan+'&e='+caseEmail+'&m=1';
                                       var urlEvent = $A.get("e.force:navigateToURL");
                                       urlEvent.setParams({
                                           "url": redirectionURL
                                       });
                                       urlEvent.fire();
                                   }
                                   else{
                                       var showToast = $A.get('e.force:showToast');
                                       showToast.setParams({ 
                                           'title': "Error!",
                                           'message': objcallBack.errorMessage,
                                           'type': 'error'
                                       });
                                       showToast.fire();  
                                   } 
                               }
                               else
                               {
                                   var showToast = $A.get('e.force:showToast');
                                   showToast.setParams({ 
                                       'title': "Error!",
                                       'message': objcallBack.errorMessage,
                                       'type': 'error'
                                   });
                                   showToast.fire();

                               }
                               var dismissActionPanel = $A.get("e.force:closeQuickAction");
                               dismissActionPanel.fire();
                           });
        $A.enqueueAction(action); 
    }
})