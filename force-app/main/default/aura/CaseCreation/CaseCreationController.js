({
	doInit : function(component, event, helper) {
		var value = '0120K000001DjbV';//helper.getParameterByName(component , event, 'recordTypeId');
        component.set("v.recordTypeId", value);
        
        var familyType = component.get("v.FamilyType");
        familyType = {};
        familyType['NewFamily'] = true;
        familyType['ExistingFamily'] = false;
        familyType['NewClient'] = true;
        familyType['ExistingClient'] = false;
        component.set("v.FamilyType",familyType);
        
        var action = component.get("c.getRecordTypeInfo");       
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var recMap = response.getReturnValue();
                component.set("v.RecordTypeMap",recMap);      
                if(recMap[value] != 'Financial Transaction' && recMap[value] != 'Service Request'){
                    component.set("v.isAccountOpeningDetail",true);
                }                   
                else if(recMap[value] == 'Financial Transaction'){
                    component.set("v.isAccountOpening",false);
                    component.set("v.isAccountOpeningDetail",false);
                    helper.createRecord(component, event, helper,value);
                }else if(recMap[value] == 'Service Request'){
                    component.set("v.isAccountOpening",false);
                    component.set("v.isAccountOpeningDetail",false);
                    component.set("v.isServiceRequestDetail",true);
                    helper.createRecord(component, event, helper,value);
                }
            }
        }); 
        $A.enqueueAction(action);
  	},
   	saveAllCases: function(component, event, helper) {        
        helper.saveAllCases(component, event, helper);
   	},
   	cancelAll: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
   	},
    handleComponentEvent : function(component,event,helper) {
        var self=this;
        var isEdit = component.get("v.isEdit"); 
        var index = component.get("v.Index");
        var caseobj = event.getParam("caseobj");
        var accobj = event.getParam("accobj");
        var caseList = component.get("v.Cases");
        if(caseList == null) caseList = [];
        if(caseList.length >= 5){
            helper.showToast("Can not add this record. Please save all case details before adding more cases.","error");
        } else {
            if(caseobj.Is_Family_Head__c){
                for(var recIndex in caseList){
                    var rec = caseList[recIndex];
                    rec["Case"].Is_Family_Head__c =false;
                    caseList[recIndex] = rec;
                }
            }
            //after add additionational lead aSSIGN SAME ACCCOUNT TO AlL record 
            for(var recIndex in caseList){
                var rec = caseList[recIndex];
                rec["Case"].AccountId = accobj.Account.Id;
                caseobj.AccountId = accobj.Account.Id;
                rec["Case"].MainLead__c = accobj.Account.Id;
                rec["Account"] = accobj;
                caseList[recIndex] = rec;
            }
            var selctedData = {};
            selctedData["Case"] = caseobj;
            selctedData["Account"] = accobj;
            var familyType = component.get("v.FamilyType");
            if(familyType['ExistingClient']){
                caseList = []; 
            }
            if(isEdit){
                caseList[index] = JSON.parse(JSON.stringify(selctedData));
            }else{
                caseList.push(JSON.parse(JSON.stringify(selctedData)));		
            }
            
            component.set("v.Cases",[]);
            component.set("v.Cases",caseList);  
            component.set("v.Index",0);
            component.set("v.isEdit",false);
            
            if(familyType['ExistingClient']){
                helper.saveAllCases(component, event, helper); 
            }
            if(caseList.length >= 5){
                helper.showToast("Maximum 5 case can be created at once. Please save all case details before adding more cases.","error");
            }
        }
    },
    editRecord : function(component,event,helper) {
        var index = event.currentTarget.getAttribute('data-Index');
        var caseList = component.get("v.Cases");
        var selctedData = caseList[index];
        var caseObj = selctedData['Case'];
        var accObj = selctedData['Account'];
       	component.set("v.caseObj",caseObj);
        component.set("v.Index",index);
        component.set("v.isEdit",true);
        helper.createAccountOpening(component, event, helper,caseObj,accObj,true);
    },
    DeleteCancel : function(component,event,helper){
        component.set("v.Confirmation",false);
    },
    DeleteNav : function(component,event,helper){
        var index = event.currentTarget.getAttribute('data-Index');
        var caseList = component.get("v.Cases");
        var isFamilyHead = false;
        if(caseList != null && index != null){
            var rec = caseList[index];
            if(rec["Case"].Is_Family_Head__c){
                isFamilyHead = true;
            }
        }
        if(isFamilyHead){
            helper.showToast("As Family Head checkbox is checked by default, cannot delete the record.","error");
        }else{
            component.set("v.Confirmation",true);
            component.set("v.indexDelete",event.currentTarget.getAttribute('data-Index'));
        }
    },
    DeleteConfirm : function(component,event,helper){
      component.set("v.Confirmation",false);
      var index = component.get("v.indexDelete");
      var caseList = component.get("v.Cases");
        if(index != null){
            caseList.splice(index, 1);
        }
        component.set("v.Cases",[]);
        component.set("v.Cases",caseList);  
        component.set("v.Index",0);
        component.set("v.isEdit",false);
        if(caseList.length == 0){
            var caseObj = {};
            var accObj = {};
            helper.createAccountOpening(component, event, helper,caseObj,accObj,false);
        }
    },
   closeModel: function(component, event, helper) {
      	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
   }, 
   nextModel: function(component, event, helper) {
       if(!component.get("v.isAccountOpeningDetailSub")){
           var familyType = component.get("v.FamilyType");
           familyType['NewFamily'] = document.getElementById("NewFamily").checked;
           familyType['ExistingFamily'] = document.getElementById("ExistingFamily").checked;
           component.set("v.FamilyType",familyType);
           
           if(familyType['NewFamily'] == true){
               component.set("v.isAccountOpeningDetail",false);
               component.set("v.isAccountOpening",true);
               var caseObj = component.get("v.caseObj");
               var accObj = {};
               helper.createAccountOpening(component, event, helper,caseObj,accObj,false);
           }else{
              component.set("v.isAccountOpeningDetail",true);
    		  component.set("v.isAccountOpeningDetailSub",true); 
           }           	
       }else if(component.get("v.isAccountOpeningDetailSub")){
           var familyType = component.get("v.FamilyType");           
           familyType['NewClient'] = document.getElementById("NewClient").checked;
           familyType['ExistingClient'] = document.getElementById("ExistingClient").checked;           
           component.set("v.FamilyType",familyType);           
           component.set("v.isAccountOpeningDetail",false);
           component.set("v.isAccountOpening",true);
           var caseObj = component.get("v.caseObj");
           component.set("v.isProcessing",true);
           helper.createAccountOpening(component, event, helper,caseObj);
           component.set("v.isProcessing",false);
	  }
   }
})