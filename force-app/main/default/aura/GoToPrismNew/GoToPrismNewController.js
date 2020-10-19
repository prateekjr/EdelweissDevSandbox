({
    GoToPrism : function(component, event, helper) {
        var action = component.get("c.getUrl");  
        action.setCallback(this, function(response) 
                           {
                               var strResponse = response.getReturnValue();
                               if (strResponse != null)
                               {
                                   var redirectionURL = strResponse;
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
                                       'message': strResponse,
                                       'type': 'error'
                                   });
                                   showToast.fire();
                               }
                           }); $A.enqueueAction(action);  
    }
})