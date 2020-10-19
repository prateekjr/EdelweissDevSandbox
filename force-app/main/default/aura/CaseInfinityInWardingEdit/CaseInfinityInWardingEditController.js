({
    doInit : function(component, event, helper) {
        //component.set("v.selectedAMCName1",'');
       component.set("v.selectedClientLeadRecord",''); 
        var caserecord = component.get("v.case");
        caserecord.Status_of_Corpus__c='New';
        component.set("v.case",caserecord); 
        
  
        var recId = component.get("v.recordId");
        
        var action = component.get("c.getCaseRecord");
        action.setParams({
            "caseId" : recId
        });                   
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseObj = response.getReturnValue();
                console.log('Record Fetched Successfully');
                component.set("v.case" , caseObj); 
                component.set("v.selectedStatus" , caseObj.Status);
                console.log('selectedStatus value : '+component.get("v.selectedStatus"));
            }
            
        });$A.enqueueAction(action); 
       

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
    handleClientLeadChange : function(component, event, helper,name){

    },
       handleComponentEvent : function(component, event, helper) {
       console.log('Handled event');
    },
    saveRec : function(component, event, helper) {
       
        var isvalid =helper.validateScreen(component, event, helper);
        if(isvalid ==1)
        {
            var caseRecord = component.get("v.case");
            console.log('caseRecord :'+JSON.stringify(caseRecord));
            var action = component.get("c.saveRecord");
            action.setParams({
                "caseRecord" : caseRecord
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Record Inserted Successfully');
                     var savedRecId = response.getReturnValue();
                    if(savedRecId.includes('Error')){
                        var savedRecId = savedRecId.replace("Error", "");
                        helper.showToast(savedRecId,"Error");
                    }
                    else{
                        helper.showToast('Modified Successfully',"Success");
                        
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": savedRecId,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                        var delayInMilliseconds = 2000; //1 second
                        setTimeout(function() {
                            $A.get('e.force:refreshView').fire();
                        }, delayInMilliseconds); 
                        //location.reload(true);
                    }
                }
                
            });$A.enqueueAction(action);       
        
    }
    },
    
 /*   handleStatusChange : function(component, event, helper) {
        var  selectedStatus= component.get("v.selectedStatus");
        var caseRecord = component.get("v.case");
        caseRecord.Status = selectedStatus;
        component.set("v.case" , caseRecord); 
    } */
 })