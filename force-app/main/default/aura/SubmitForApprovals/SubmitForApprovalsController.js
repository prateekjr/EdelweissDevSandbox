({
	doInit: function(component, event, helper) { 
		var recordId = component.get("v.recordId"); 
        if(component.get("v.recordId") != '' && component.get("v.recordId") != null)
        {
            var action = component.get("c.getAccountRecord");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) 
            {
                var strError = response.getReturnValue();
                var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.account",response.getReturnValue());
            }
                else{
                    var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'message': strError,
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    display : function(component, event, helper) 
    {
    	helper.toggleHelper(component, event);
  	},
        
   displayOut : function(component, event, helper) 
   {
       helper.toggleHelper(component, event);
	},
    
    save: function(component, event, helper)
    {
        var accRecord = component.get("v.account");
        
        
        if(($A.util.isEmpty(accRecord.Acquisiton_Approval_For_FY__c) || 
             $A.util.isUndefinedOrNull(accRecord.Acquisiton_Approval_For_FY__c)) && 
            ($A.util.isEmpty(accRecord.Request_Approval_for_R5__c) || 
             $A.util.isUndefinedOrNull(accRecord.Request_Approval_for_R5__c)))
        {
            component.set("v.messageBody",'Please select atleast one approval type');
            return;
        }
       else if(!($A.util.isEmpty(accRecord.Acquisiton_Approval_For_FY__c)) && 
           ! ($A.util.isEmpty(accRecord.Request_Approval_for_R5__c)))
        {
            component.set("v.messageBody",'Please select only one approval type');
            return;
        }
        
        
        if((accRecord.Request_Approval_for_R5__c=='R4+ Approval') && (accRecord.IsR4_Plus_Approved__c))
        {
            component.set("v.messageBody",'Family is already approved for R4+');
            return;
        }
        
        if(!($A.util.isEmpty(accRecord.Acquisiton_Approval_For_FY__c)) && 
            !($A.util.isEmpty(accRecord.Approved_Acquistion_Year__c)))
        {
            component.set("v.messageBody",'Family is already approved for Acquisition Year  '+accRecord.Approved_Acquistion_Year__c);
            return;
        }
       
        var action = component.get("c.UpdateAccRecord");
        action.setParams({
            updateAccRecord : JSON.parse(JSON.stringify(accRecord)),
        });
        
        action.setCallback(this, function(response) 
            {
                var strError = response.getReturnValue();
                if (strError=== "Success")
                {
                   var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'message': 'Family Sent For Approval'
                    });
                    showToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
                else{
                    var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'message': strError,
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
                }
            });
        
         $A.enqueueAction(action);
    },
    
   
    cancel : function(component, event, helper) 
    {
    	var showToast = $A.get('e.force:showToast');
                    showToast.setParams({ 
                        'title': "Error!",
                        'type': 'error'
                    });
                    showToast.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
    },
    
    
})