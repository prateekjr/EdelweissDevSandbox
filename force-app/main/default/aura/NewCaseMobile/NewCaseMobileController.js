({
    createRecord : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        var recordTypes = component.get("v.recordTypes");
        var FundTransferId =   component.get("v.FundTransferId"); 
        if(rtDet  != null) {
            var serviceRequestId = component.get("v.serviceRequestId");
            if(Name == serviceRequestId){
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef: "c:CaseServiceRequest",
                    //componentAttributes :{ //your attribute}
                });
                evt.fire();
            }else{
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
        helper.getRecordTypeAOId(component);
        helper.getRecordTypeSRId(component);
        helper.getRecordTypeFTId(component, event, helper);
        helper.RecordTypeSelectorController(component);   
    } ,
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
    }, 
    buttonClick: function(component, event, helper) {
        var  selectedRecordType = component.get("v.selectedrecordType");
        var Name = event.getSource().get("v.name");
        var serviceRequestId = component.get("v.serviceRequestId");
        var accountOpeningId = component.get("v.accountOpeningId");
        var FundTransferId =   component.get("v.FundTransferId"); 
        if(Name == serviceRequestId){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:CaseServiceRequest",
            });
            evt.fire();
        }else if(Name == FundTransferId){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:FundTransfer",
                });
                evt.fire();
            }
        
        else if(Name == accountOpeningId){ 
            /*var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:CaseCreation",
            });
            evt.fire();
            
            
            */
            
           $A.createComponent(
                "c:CaseCreation",
                {
                    
                },
                function(newCmp){
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newCmp);
                        component.set("v.body", body);
                        var body = component.get("v.body");
                        if(body != null){
                          component.set("v.showCaseCreation", true);
                        }
                    }
                }
            );	
        }else{
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": Name
            });
            createRecordEvent.fire();
            
        }
    },
    showModal: function(component, event, helper) {   
        helper.RecordTypeSelectorController(component);   
    } 
})