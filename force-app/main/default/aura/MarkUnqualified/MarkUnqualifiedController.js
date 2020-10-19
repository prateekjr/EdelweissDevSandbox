({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var AccountRec = component.get("v.AccountRec");
        
    },
    saveRecordDetails : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var AccountRec = component.get("v.AccountRec");
        var flag = 1;
        if(AccountRec.Reason_For_Disqualification__c != null){
            flag = 0;
        }if(AccountRec.Reason_For_Disqualification__c == ''){
            flag = 1;
            component.set("v.showError",true);
        }
        if(flag == 0){
            var action = component.get("c.saveDetails");
            action.setParams({ "recId" : recId , 
                              "AccountRec" : AccountRec
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (res === "Success") {
                     helper.showToast('Changes Successfully Saved','success');    
                     helper.closeModel(component, event, helper, recId);
                }else{
                    helper.showToast('Failed to Save changes','Error');  
                    helper.closeModel(component, event, helper, recId);
                }
            });
            $A.enqueueAction(action);
            
        }
    }    
})