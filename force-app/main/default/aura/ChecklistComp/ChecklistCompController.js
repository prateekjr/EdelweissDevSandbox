({
    doInit : function(component, event, helper){       
        
        helper.getAccount(component, event, helper);      
        
        window.setTimeout($A.getCallback(function() {
             helper.expandLastStage(component);   
        }), 2000);
        
    },handleValueChange : function(component, event, helper){        
        helper.RefreshInterval(component, event, helper);
    },showSystemError : function(component, event) {
        // Handle system error
        $A.log(component);
        $A.log(event);        
    },
    Refresh: function(component, event, helper) {
		//alert('Cheklist refresh');
        component.set("v.isRefreshEventCall",true);
		helper.RefreshFieldset(component, event, helper);
	},handleCheckBoxSelect: function(component, event, helper) {
		helper.RefreshFieldset(component, event, helper);
    }
})