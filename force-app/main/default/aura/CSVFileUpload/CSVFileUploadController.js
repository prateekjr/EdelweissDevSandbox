({  
     save : function(component, event, helper) 
    {   
        var SelPicVal= component.find("SelectObject").get("v.value");
        var developerReportName = null;
        if(SelPicVal==='FARevenue'){
            developerReportName = 'FA_Revenue_Error_Report';
        }else if(SelPicVal==='ClientRevenue'){
            developerReportName = 'Client_Revenue_Error_Report';
        }
        
        if(developerReportName != null){
        	var action = component.get("c.generateReportURL");
            action.setParams({
                reportName: developerReportName
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                
                    component.set("v.reportURL", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        
        helper.save(component, event, helper); 
    }, 
    waiting: function(component, event, helper)
    { 
     	//$A.util.addClass(component.find("uploading").getElement(), "uploading"); 
     	//$A.util.removeClass(component.find("uploading").getElement(), "notUploading"); 
    }, 
    doneWaiting: function(component, event, helper) 
    { 
    	//$A.util.removeClass(component.find("uploading").getElement(), "uploading"); 
    	//$A.util.addClass(component.find("uploading").getElement(), "notUploading"); 
	 }
})