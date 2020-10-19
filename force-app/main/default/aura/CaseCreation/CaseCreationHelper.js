({
	helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
    getParameterByName: function(component, event, name) {
      name = name.replace(/[\[\]]/g, "\\$&");
      var url = window.location.href;
      var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
      var results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    createRecord : function (component, event, helper,recordType) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId" : recordType
        });
        createRecordEvent.fire();
    },
    createAccountOpening : function (component, event, helper,caseObj,accObj,isLeadSelect) {
        var familyType = component.get("v.FamilyType");
        var lookupFilter = '';
        var homeTitle = '';
        if(familyType['NewFamily']){
            lookupFilter = 'NewFamily';
            homeTitle = "New Case: Account Opening [New Family New Client]";
        }else if(familyType['NewClient']){
            lookupFilter = 'NewClient';
            homeTitle = "New Case: Account Opening [Existing Family New Client]";
        }else{
            lookupFilter = 'ExistingClient';
            homeTitle = "New Case: Account Opening [Existing Family Existing Client]";
        }
        var ref = $A.createComponent(
        	("c:ObjectDetailsComp" ),
        	{
        		"isDefaultExpand": "true",
                "isReadOnly" : "true",
                "CompSource" : "PatientSupport",
                "objectType" : "Case",
                "fieldsetLabel":homeTitle,
                "fieldsetName" : "['Account_opening_Case_Detail','Account_opening_Joint_Holder_Section','Account_opening_Trading_Section','Account_opening_Funding_Section']",
                "isSubsection" : "true",
                "accountRef" : caseObj,
                "RecordTypeId" : component.get("v.recordTypeId"),
                "Cases" : component.get("v.Cases"),
                "selectedAccount" : accObj,
                "lookupFilter": lookupFilter,
                "FamilyType" : component.get("v.FamilyType"),
                "isLeadSelect" : isLeadSelect
                
            },
            function(newCmp){
                var divCmp = component.find("detailDiv");
                divCmp.set("v.body", []);
				var divBody = divCmp.get("v.body");                
                divBody.push(newCmp);
                divCmp.set("v.body", divBody);
            }
        );
    },
    showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    saveAllCases : function(component, event, helper){
        var selectedObj = component.get("v.Cases");
        var cases = [];
        var isNewFmaily = false;
        var isNewClient = false;
        var isFamilyHeadRequired = true;
        var familyType = component.get("v.FamilyType");
       	if(familyType['NewFamily']){
           isNewFmaily = true;
        }else if(familyType['NewClient']){
            isNewClient = true;
        }
        if(familyType['ExistingFamily']){
            isFamilyHeadRequired = false;
        }
       
        for(var i in selectedObj){
            var record = selectedObj[i]["Case"];
            record["sobjectType"] = "Case";
            record["IsNewFamily__c"] = isNewFmaily;
            record["IsNewClient__c"] = isNewClient;
            cases.push(record);
            
            if(record.Is_Family_Head__c){
				isFamilyHeadRequired = false;
			}
        }
        if(cases == null || cases.length <= 0 ){
            helper.showToast("Add atleast one client record to save","error");
        } /* else if(isFamilyHeadRequired){
            helper.showToast("Please mark atleast one client as a family head","error");
        } */else { 
            var action = component.get("c.SaveAllCases");  
            action.setParams({
                "Cases" : cases 
            });
            component.set("v.isProcessing",true);
            action.setCallback(this, function(response) {            
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS") {
                    var returnMap = response.getReturnValue(); 
                    var isSuccess = true;
                    var CaseId = '';
                    for(var i in returnMap){
                       var result =  returnMap[i];
                        if(result.includes("ERROR")){
                            isSuccess = false;
                            var ele = document.getElementById("tr"+i);
                            if(ele != null){
                               ele.classList.add("errorRow");
                              window.setTimeout($A.getCallback(function() {
                                  for(var i in returnMap){
                                      var errorEle = document.getElementById("tr"+i); 
                                      if(errorEle != null && errorEle.classList.contains("errorRow"))
                                     		errorEle.classList.remove("errorRow");
                                  }                                  
                              }), 5000); 
                            }                        
                            helper.showToast(result.replace("ERROR--",""),"error");
                        }
                        var CaseId = returnMap[0].replace("SUCCESS--","")
                    }
                    if(isSuccess){
                        helper.showToast("Case Created Successfully.","success");
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                          "url": "/"+CaseId
                        });
                        urlEvent.fire();
                    }
                }else{
                    
                }
                component.set("v.isProcessing",false);
            }); 
            $A.enqueueAction(action);
            
        }
    }
})