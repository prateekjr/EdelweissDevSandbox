/**
 * (c) Tony Scott. This code is provided as is and without warranty of any kind.
 *
 * This work by Tony Scott is licensed under a Creative Commons Attribution 3.0 Unported License.
 * http://creativecommons.org/licenses/by/3.0/deed.en_US
 */
({

    doInitLkup : function(cmp, event, helper) {
		if(!cmp.get("v.isReadOnly"))
		helper.getObjectLabel(cmp, event, helper);
    },

    /**
     * Search an SObject for a match
     */
    
	search : function(cmp, event, helper) {
		helper.doSearch(cmp);        
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
    	helper.handleSelection(cmp, event);
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
    	helper.clearSelection(cmp);    
    },    
    hideErrDiv : function(cmp, event, helper) {
    	var errDiv = cmp.find('errorSearchDiv');
        $A.util.addClass(errDiv, 'slds-hide');
        $A.util.removeClass(errDiv, 'slds-show');
        if(cmp.get('v.fieldAPIName') == 'Relationship_Manager__c'){
            helper.getLoggedInUserDetails(cmp);
        }    
        helper.doSearch(cmp);        
	},
	hideDropDown : function(cmp, event, helper) {
        var lookupList = cmp.find('lookuplist');
        $A.util.addClass(lookupList, 'slds-hide');
        window.setTimeout($A.getCallback(function() {
		$A.util.removeClass(lookupList, 'slds-show');
            if(cmp.get("v.searchString") != '' && typeof(cmp.get("v.searchString")) != 'undefined' && cmp.get("v.selSearchString") == ''){
                
                 var errDiv = cmp.find('errorSearchDiv');
        		 $A.util.addClass(errDiv, 'slds-show');
                $A.util.removeClass(errDiv, 'slds-hide');
                var instanceId = cmp.get('v.fieldAPIName');
                 var updateEvent = $A.get("e.c:UpdateLookupId");
                     updateEvent.setParams({
                         "sObjectId" : cmp.get("v.searchString"), "instanceId" : instanceId , "fieldRefVal" : instanceId
                    });
            
                    // Fire the event
                    updateEvent.fire();
                
            }
        }), 500);
		
    },   	
    navigateToRecord:function(component, event, helper){
        var element = event.target.getAttribute("data-recordId");
        if(component.get("v.sObjectAPIName") != 'CBSA__c'){
        var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": element,
			"slideDevName": "detail"
         });
         navEvt.fire();
        }else{
         	var action = component.get("c.getListViews");
    		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews[0].Id,
                    "listViewName": null,
                    "scope": "CBSA__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);   
        }    
    }
})