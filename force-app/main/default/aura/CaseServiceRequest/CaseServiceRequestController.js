({
    doInit : function(component, event, helper) {
        component.set("v.IsServiceRequest",true);
        /*var value = helper.getParameterByName(component , event, 'recordTypeId');
        component.set("v.recordTypeId", value);
        var action = component.get("c.getRecordTypeInfo");       
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var recMap = response.getReturnValue(); 
                component.set("v.RecordTypeMap",recMap);   
                
                if(recMap[value] == 'Service Request'){
                    console.log('In SR');
                     component.set("v.IsServiceRequest",true);
                    alert('SR');
                    //helper.createRecord(component, event, helper, value);
                }                   
                else {
                    
                     alert('NO SR');
                    console.log('NO SR');
                    helper.createRecord(component, event, helper, value);
                }
            }
        }); 
        $A.enqueueAction(action);*/
        
    },
    closeModel: function(component, event, helper) {
         component.set("v.selectedNatureOfRequest","");
       	component.set("v.selectedProduct","");
        component.set("v.selectedRequestType","");
        component.set("v.selectedSubType","");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
    }, 
    showProduct : function(component, event, helper) {
        	component.set("v.selectedProduct","");
        var natureOfRequest = component.get("v.selectedNatureOfRequest");
        if(natureOfRequest == ''){
            helper.showToast("Please Select Nature","Error");
        }else{
            component.set("v.IsServiceRequest",false);
            component.set("v.showProduct",true);
            component.set("v.showRequestType",false);
            component.set("v.showSubType",false);
            component.set("v.hideSubType",true);            
        }
        
    },
    showNature : function(component, event, helper) {
        component.set("v.selectedNatureOfRequest","");
       	component.set("v.selectedProduct","");
        component.set("v.selectedRequestType","");
        component.set("v.selectedSubType","");
        component.set("v.IsServiceRequest",true);
        component.set("v.showProduct",false);
        component.set("v.showRequestType",false);
        component.set("v.showSubType",false);
    },
    
    showRequestType : function(component, event, helper) {
        component.set("v.selectedRequestType","");
        var product = component.get("v.selectedProduct");
        if(product == ''){
            helper.showToast("Please Select Product","Error");
        }else{
            component.set("v.showRequestType",true);
            component.set("v.IsServiceRequest",false);
            component.set("v.showProduct",false);
            component.set("v.showSubType",false);
            
        }
    },
    showSubType : function(component, event, helper) {
        component.set("v.selectedSubType","");
         var requestType = component.get("v.selectedRequestType");
        if(requestType == ''){
            helper.showToast("Please Select Request Type","Error");
        }else{
        component.set("v.IsServiceRequest",false);
        component.set("v.showProduct",false);
        component.set("v.showRequestType",false);
        component.set("v.showSubType",true);
        }
    },
    doSomething : function(component, event, helper) {
        var natureOfRequest = component.get("v.selectedNatureOfRequest");
        var product = component.get("v.selectedProduct");
        var requestType = component.get("v.selectedRequestType");
        var subType = component.get("v.selectedSubType");
        var p1 = helper.getProducts(component, event, helper,natureOfRequest);
    },
    getRequestType : function(component, event, helper) {
        var natureOfRequest = component.get("v.selectedNatureOfRequest");
        var product = component.get("v.selectedProduct");
        var requestType = component.get("v.selectedRequestType");
        var subType = component.get("v.selectedSubType");
        helper.getRequestType(component, event, helper,natureOfRequest+'$'+product);
    },
    getSubType  : function(component, event, helper) {
        var natureOfRequest = component.get("v.selectedNatureOfRequest");
        var product = component.get("v.selectedProduct");
        var requestType = component.get("v.selectedRequestType");
        var subType = component.get("v.selectedSubType");
        helper.getSubType(component, event, helper,natureOfRequest+'$'+product+'$'+requestType);
    },
    newCase : function(component, event, helper,name){
        var natureOfRequest = component.get("v.selectedNatureOfRequest");
        var product = component.get("v.selectedProduct");
        var requestType = component.get("v.selectedRequestType");
        var subType = component.get("v.selectedSubType");
        var hideSubType= component.get("v.hideSubType");
      if(hideSubType){
            if(subType == ''){
            helper.showToast("Please Select Subtype","Error");
        }
        else{
            
        var createServiceRequestCase = $A.get("e.force:createRecord");
        createServiceRequestCase.setParams({
            "entityApiName": "Case",
            "defaultFieldValues": {
                'Nature__c' : natureOfRequest,
                'Service_Request_Product_Type__c' : product,
                'Service_Request_Type__c' : requestType,
                'Service_Request_Sub_Type__c' : subType,
                'Priority' : 'High' ,
                'LOB__c' : 'GWM',
                 'Origin' : ''
            },
            "recordTypeId": "01228000000m0gk"
        });
        createServiceRequestCase.fire();
        }
          
      }else{
           var createServiceRequestCase = $A.get("e.force:createRecord");
        createServiceRequestCase.setParams({
            "entityApiName": "Case",
            "defaultFieldValues": {
                'Nature__c' : natureOfRequest,
                'Service_Request_Product_Type__c' : product,
                'Service_Request_Type__c' : requestType,
                'Service_Request_Sub_Type__c' : '',
                'Priority' : 'High' ,
                'LOB__c' : 'GWM',
                'Origin' : ''
            },
            "recordTypeId": "01228000000m0gk"
        });
        createServiceRequestCase.fire();
          
          
      }
     
       
    }
})