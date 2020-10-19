({
	createSections : function(component, event, helper) {
		var divCmp = component.find("sectionDiv");
        var result = component.get("v.fieldSetMap");
        var keyList = [];
        component.set("v.keyList", Object.keys(result));
	},
    toggleSection: function(component, event, helper) {
       	var param = event.currentTarget.dataset.param;
        helper.helperFun(component,event,param);
    }
})