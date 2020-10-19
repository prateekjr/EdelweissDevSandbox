({
    doInit : function(component, event, helper) {
        //component.set("v.selectedAMCName1",'');
        component.set("v.selectedClientLeadRecord",''); 
        var caserecord = component.get("v.case");
        caserecord.Status_of_Corpus__c='New';
        component.set("v.case",caserecord); 
        
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
    setValuesToFieldName : function(component, event, helper,name){
        
        var caserecord = component.get("v.case");
        var selectedClientLeadRecord = component.get("v.selectedClientLeadRecord"); 
        console.log('selectedClientLeadRecord '+JSON.stringify(selectedClientLeadRecord.value));
        console.log('selectedClientLeadRecord label '+selectedClientLeadRecord.label);
        if(selectedClientLeadRecord.value != null){
            caserecord.Lead_Account__c = selectedClientLeadRecord.value;
            var action = component.get("c.getRelatedFieldValues");
            action.setParams({
                "accid" : selectedClientLeadRecord.value
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var orderEntryObj = response.getReturnValue();
                    if(orderEntryObj != null){
                        caserecord.PAN__c = orderEntryObj.PAN_Number__c;
                        caserecord.Email__c = orderEntryObj.Primary_Email__c;
                        component.set("v.case",caserecord); 
                        
                    }
                }
                
            });$A.enqueueAction(action);
        }
        else
        {
            caserecord.Lead_Account__c = '';
            caserecord.PAN__c = '';
            caserecord.Email__c = '';
            component.set("v.case",caserecord); 
        }
        helper.setClientNameValue(component, event, helper);
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
                    var wrapperResult = response.getReturnValue();
                    var saveId =wrapperResult.saveId;
                    var caseNumber =wrapperResult.caseNumber;
                    if(saveId.includes('Error') || caseNumber.includes('Error') ){
                        //var wrapperResult = wrapperResult.replace("Error", "");
                        helper.showToast(wrapperResult,"Error");
                    }
                    else{
                        helper.showToast('Record Inserted Successfully',"Success");
                        
                        var action1 = component.get("c.callApi");
                        action1.setParams({
                            "CaseId" : caseNumber,
                            "ClientName" : caseRecord.ClientLead_Name_Display__c,
                            "ClientPan" : caseRecord.PAN__c,
                            "ClientEmail" : caseRecord.Email__c,
                            "Mode" : '1',
                            
                        });  
                        action1.setCallback(this, function(response) {   
                            var state = response.getState();
                            if (component.isValid() && state === "SUCCESS"){
                                component.set("v.objcallBack",response.getReturnValue());
                                var objcallBack = response.getReturnValue();
                                if(objcallBack.isSuccess){
                                    var redirectionURL = objcallBack.returnBody;
                                    //var redirectionURL ='https://prismtest.edelweiss.in/QA1/Prism/?i='+ caseNumber+'&n='+leadcaseName +'&p='+ casePan+'&e='+caseEmail+'&m=1';
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": redirectionURL
                                    });
                                    urlEvent.fire();
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": saveId,
                                        "slideDevName": "related"
                                    });
                                    navEvt.fire();
                                    var delayInMilliseconds = 2000; //1 second
                                    setTimeout(function() {
                                        $A.get('e.force:refreshView').fire();
                                    }, delayInMilliseconds);
                                }
                                else{
                                    var showToast = $A.get('e.force:showToast');
                                    showToast.setParams({ 
                                        'title': "Error!",
                                        'message': objcallBack.errorMessage,
                                        'type': 'error'
                                    });
                                    showToast.fire();
                                    
                                     var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": saveId,
                                        "slideDevName": "related"
                                    });
                                    navEvt.fire();
                                    var delayInMilliseconds = 2000; //1 second
                                    setTimeout(function() {
                                        $A.get('e.force:refreshView').fire();
                                    }, delayInMilliseconds);
                                    
                                } 
                            }
                            else
                            {
                                var showToast = $A.get('e.force:showToast');
                                showToast.setParams({ 
                                    'title': "Error!",
                                    'message': objcallBack.errorMessage,
                                    'type': 'error'
                                });
                                showToast.fire();
                                
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": saveId,
                                    "slideDevName": "related"
                                });
                                navEvt.fire();
                                var delayInMilliseconds = 2000; //1 second
                                setTimeout(function() {
                                    $A.get('e.force:refreshView').fire();
                                }, delayInMilliseconds);
                            }
                        });
                        $A.enqueueAction(action1); 
                    }
                }
            });
            $A.enqueueAction(action);     
            
        }
    }
    
})