({
	createCmp : function(component, event, helper) {		
        var index = window.navigator.userAgent.indexOf("MSIE");
        if (index > 0 || navigator.userAgent.match(/Trident\/7\./))
            component.set("v.isIE",true);
        else
             component.set("v.isIE",false);	
		helper.createCmp(component, event, helper);
	},
    handleValueChange : function(component, event, helper) {
        var element = event.getSource();
        var selectionEvent = $A.get("e.c:changeInputValEvent");
        selectionEvent.setParams({
            fieldName: element.getLocalId(),
            fieldVal : element.get("v.value")
        });
        selectionEvent.fire();
    },
    handleStatusValueChange : function(component, event, helper) {
        var element = event.getSource();
        helper.setColorCode(component,element.get("v.value"));
        var selectionEvent = $A.get("e.c:changeInputValEvent");
        selectionEvent.setParams({
            fieldName: element.getLocalId(),
            fieldVal : element.get("v.value")
        });
        selectionEvent.fire();
    },
    handleCheckBxValueChange : function(component, event, helper) {
        var element = event.getSource();
        var selectionEvent = $A.get("e.c:changeInputValEvent");
        selectionEvent.setParams({
            fieldName: element.get("v.name"),
            fieldVal : element.get("v.value")
        });
        selectionEvent.fire();

        if('Special_Brokerage_RM_Approval_Required__c' === element.get("v.name")){
            var tradingEvent = $A.get("e.c:TradingDefault");
            tradingEvent.setParams({
                fieldName: element.get("v.name"),
                fieldVal : element.get("v.value")
            });
            tradingEvent.fire();
        }
    },
    CallInlineEdit : function(component, event, helper) {
		var CompSrc = component.get("v.CompSource");
        var cmpEvent;
        if(CompSrc == 'PatientSupport')	
            cmpEvent = component.getEvent("inlineEditEvent"); 
        cmpEvent.fire(); 
    },
    handleAccountIdUpdate : function(cmp, event, helper) {
        // Get the Id from the Event
        var accountId = event.getParam("sObjectId");
        // Get the Instance Id from the Event
        var instanceId = event.getParam("instanceId");
        
		if (instanceId == cmp.get("v.fieldName"))
        {
            var selectionEvent = $A.get("e.c:changeInputValEvent");
            selectionEvent.setParams({
                fieldName: instanceId,
                fieldVal : accountId,
                fieldRefVal : event.getParam("fieldRefVal"),
                isLookUp : true
            });
            selectionEvent.fire();
        }
        else
        {
           
        }        
       
    },

    /**
     * Handler for receiving the clearLookupIdEvent event
     */
	handleAccountIdClear : function(cmp, event, helper) {
        // Get the Instance Id from the Event
        var instanceId = event.getParam("instanceId");

        // Determine the instance Id of the component that fired the event
       if (instanceId == cmp.get("v.fieldName"))
        {
            var selectionEvent = $A.get("e.c:changeInputValEvent");
            selectionEvent.setParams({
                fieldName: instanceId,
                fieldVal : null,
                fieldRefVal : event.getParam("fieldRefVal"),
                isLookUp : true
                
            });
            selectionEvent.fire();
            
        }
        else
        {
            
        }
	},
    
    handleTradingEvent : function(cmp, event, helper){
        
        var map = new Object(); 
        map["Delivery_Slab__c"] = 0.50;
        map["Intraday_Slab__c"] = 0.05;
        map["Delivery_Minimum_P__c"] = 0.03;
        map["Intraday_Minimum_P__c"] = 0.01;
        map["Currency_Futures_Slab__c"] = 10.00;
        map["Currency_Options_Slab__c"] = 10.00;
        map["Currency_Futures_Minimum_P__c"] = 0.01;
        map["Currency_Options_Minimum_P__c"] = 0.01;
        map["Derivatives_Futures_Slab__c"] = 0.50;
        map["Derivatives_Options_Slab__c"] = 50.00;
        map["Derivatives_Futures_Minimum_P__c"] = 0.03;
        map["Derivatives_Options_Minimum_P__c"] = 0.01;
        
        console.log(event.getParam("fieldVal"));
        if(event.getParam("fieldVal") && cmp.get("v.fieldName") in map){
            var nameField = cmp.find(cmp.get("v.fieldName"));
            nameField.set("v.disabled", false);
        } else if(cmp.get("v.fieldName") in map) {
            var nameField = cmp.find(cmp.get("v.fieldName"));
            nameField.set("v.disabled", true);
            nameField.set("v.value", map[cmp.get("v.fieldName")]);
        }
    }

})