({
    createRecord : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        var recordTypes = component.get("v.recordTypes");
        var serviceRequestrecordTypeId =''; 
        var serviceRequestId =  component.get("v.serviceRequestId");  
        var accountOpeningId =  component.get("v.accountOpeningId"); 
        var FundTransferId =   component.get("v.FundTransferId"); 
         var FinancialTransactionId =   component.get("v.FinancialTransactionId"); 
        var WealthInWardingId =   component.get("v.WealthInWardingId"); 
        
        if(rtDet  != null) {
            if(rtDet.id == serviceRequestId){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:CaseServiceRequest",
                });
                evt.fire();
            }else if(rtDet.id == accountOpeningId){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:CaseCreation",
                });
                evt.fire();
            }else if(rtDet.id == FinancialTransactionId){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:FinancialTransaction",
                });
                evt.fire();
            }else if(rtDet.id == FundTransferId){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:FundTransfer",
                });
                evt.fire();
            }
                else if(rtDet.id == WealthInWardingId)
                {
                    var evt = $A.get("e.force:navigateToComponent");
                    console.log('evt'+evt);
                    evt.setParams({
                        componentDef: "c:CaseInfinityInWarding",
                    });
                    evt.fire();
                }
                    else{
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Case",
                            "recordTypeId": rtDet.id
                        });
                        createRecordEvent.fire();
                    }
            
        }    
    },
    
    doInit : function(component, event, helper) { 
        helper.getRecordTypeSRId(component, event, helper);
        helper.getRecordTypeFTId(component, event, helper);
        helper.getRecordTypeAOId(component, event, helper);
        helper.getRecordTypeFinancialTransactionId(component, event, helper); 
        helper.getRecordTypeWealthInWardingId(component, event, helper);
        helper.RecordTypeSelectorController(component);   
    } ,
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
    }, 
    showModal: function(component, event, helper) {   
        helper.RecordTypeSelectorController(component);   
    } 
})