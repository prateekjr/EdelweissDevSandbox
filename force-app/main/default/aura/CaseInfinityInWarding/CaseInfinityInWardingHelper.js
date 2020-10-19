({
	showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    validateScreen : function(component, event, helper) {
        var isvalid = 1;
        var caseRecord = component.get("v.case");  
        
        if (caseRecord.Client_Lead__c == '' || typeof caseRecord.Client_Lead__c === 'undefined' || caseRecord.Client_Lead__c === 'None' ) {
            isvalid = 0;
            helper.showToast("Please Select Client/Lead","Error");
        } 
        else if (caseRecord.Lead_Account__c == '' || typeof caseRecord.Lead_Account__c === 'undefined' ) {               
            isvalid = 0;
            helper.showToast("Please Select Name","Error");
        } 
            else if (caseRecord.PAN__c == '' || typeof caseRecord.PAN__c === 'undefined' ) {   
                isvalid = 0;
                helper.showToast("Please Enter PAN","Error");
            }
        return isvalid;
        
    },
    
    setClientNameValue : function(component, event, helper) {
        var caseRecord = component.get("v.case"); 
        var action = component.get("c.getClientLeadAccount");
        action.setParams({
            "caseRecordObj" : caseRecord
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseRecordObj = response.getReturnValue();
                console.log('caseRecordObj :'+caseRecordObj);
                if(caseRecordObj != null){
                    caseRecord.ClientLead_Name_Display__c = caseRecordObj;
                    component.set("v.case",caseRecord); 
                    console.log('Case Record :'+JSON.stringify(component.get("v.case")));
                     
                }
            }
            
        });$A.enqueueAction(action);
   
    },

})