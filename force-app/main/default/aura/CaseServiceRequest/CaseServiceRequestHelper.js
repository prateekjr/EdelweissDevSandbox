({
    createRecord : function (component, event, helper, recordType) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId" : recordType
        });
        createRecordEvent.fire();
    },
    getProducts : function (component, event, helper, natureOfRequest) {
        var product=[];
        var action = component.get("c.prepareData");
        action.setParams({ nature : natureOfRequest });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                product=response.getReturnValue();
            }
            component.set("v.products",product);
        });
        $A.enqueueAction(action);
    },
    showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    getRequestType : function (component, event, helper, natureOfRequest) {
        var requestType=[];
        var action = component.get("c.getRequestTypeData");
        action.setParams({ natureAndProduct : natureOfRequest });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                requestType=response.getReturnValue();
            }
            component.set("v.requestType",requestType);
        });
        $A.enqueueAction(action);
    },
    
    getSubType : function (component, event, helper, natureproductrequest) {
        var subType=[];
        var action = component.get("c.getSubTypeData");
        action.setParams({ natureproductrequest : natureproductrequest });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                subType=response.getReturnValue();
                if(subType == ''){
                    component.set("v.hideSubType",false); 
                }else{
                    component.set("v.subType",subType);
                    component.set("v.hideSubType",true); 
                }
            }
        });
        $A.enqueueAction(action);
    },    
    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
})