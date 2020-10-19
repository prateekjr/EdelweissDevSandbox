({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var CaseRec = component.get("v.CaseRec");
        helper.getRecordTypeFTId(component, event, helper);
    },
    backShowClientAccount: function(component, event, helper) {  
    	component.set("v.showClientAccount",true);
        component.set("v.showTransferTo",false);
        $A.get('e.force:refreshView').fire();
    },
     backShowTransferTo: function(component, event, helper) {  
    	component.set("v.showRemitterAccounts",false);
        component.set("v.showTransferTo",true);
    },
    backShowRemitterAccounts: function(component, event, helper) { 
    	component.set("v.showBenificiaryDetails",false);
        component.set("v.showRemitterAccounts",true);
    },
    showRemitterAccounts: function(component, event, helper) { 
      	var CaseRec = component.get("v.CaseRec");
        
        
		 var action = component.get("c.getAllRemitterInfo");
        action.setParams({
            "clientAccount" : CaseRec.Client_Account__c
        });
        action.setCallback(this, function(actionResult) {
            var remitterAccountDetails = actionResult.getReturnValue();
            var listOfRemitterAccounts =  new Array();
             if(remitterAccountDetails.length == 0){
                   helper.showToast(component, event, helper,'Remitter Account Details Not Found','Error');   
                }else{
                    component.set("v.showTransferTo",false);
                    component.set("v.showRemitterAccounts",true);
                    for (var i = 0; i < remitterAccountDetails.length; i++) { 
                        if(typeof remitterAccountDetails[i].Remitter_Account_No__c != 'undefined'){
                             listOfRemitterAccounts.push(remitterAccountDetails[i].Remitter_Account_No__c);
                        }
                }
                  if(listOfRemitterAccounts != null){
                      component.set("v.listOfRemitterAccounts",listOfRemitterAccounts);
                    }  
                }
        });
        $A.enqueueAction(action);        
    },
    showTransferTo: function(component, event, helper) {  
		var CaseRec = component.get("v.CaseRec");        
        if(CaseRec.Client_Account__c == ''){
            helper.showToast(component, event, helper,'Please Select Client Account','Error');
        }else{
        var action = component.get("c.getRemitterInfo");
        action.setParams({
            "clientAccount" : CaseRec.Client_Account__c
        });
        action.setCallback(this, function(actionResult) {
            var clientAccount = actionResult.getReturnValue();
                //var paddedRemitter = clientAccount.Remitter_Account_No__c.padStart(15,"0");
                //component.set("v.Remitter_Account_No__c",paddedRemitter);
                //component.set("v.remitterWithoutPadding",clientAccount.Remitter_Account_No__c);
                component.set("v.Backoffice_Code_Equity__c",clientAccount.Backoffice_Code_Equity__c);
                component.set("v.Client__c",clientAccount.Client__r.Name);
                component.set("v.showClientAccount",false);
                component.set("v.GWM_Client_Account_Id__c",clientAccount.GWM_Client_Account_Id__c);
       			 component.set("v.showTransferTo",true);
            
        });
        $A.enqueueAction(action);
        }
    } ,
    
    showBenificiaryDetails: function(component, event, helper) {   
        var remitterAccount = component.find("remitterId").get("v.value");	
       if(remitterAccount != ' '){
       	var paddedRemitter = remitterAccount.padStart(15,"0");
        component.set("v.Remitter_Account_No__c",paddedRemitter);
        component.set("v.remitterWithoutPadding",remitterAccount);
       }else{
        helper.showToast(component, event, helper,'Please Update Remitter Account','Error'); 
       }
        var FundTransferId = component.get("v.FundTransferId"); 
        var listOfbenificary =  new Array();
        var CaseRec = component.get("v.CaseRec");
        var Remitter_Account_No__c =  component.get("v.Remitter_Account_No__c");
        var remitterWithoutPadding =  component.get("v.remitterWithoutPadding");
        var Backoffice_Code_Equity__c =  component.get("v.Backoffice_Code_Equity__c");
        var Client__c = component.get("v.Client__c");
        if(CaseRec.Transfer_To__c != 'Personal'){
            var action = component.get("c.fetchBeneficiaryDetailsFromSetting");
            action.setParams({
            "TransferTo" : CaseRec.Transfer_To__c
        });
            action.setCallback(this, function(actionResult) {
                var beneficiaryDetails = actionResult.getReturnValue();
                var createFundtransferCase = $A.get("e.force:createRecord");
                createFundtransferCase.setParams({
                    "entityApiName": "Case",
                    "defaultFieldValues": {
                        'Transfer_To__c' : CaseRec.Transfer_To__c,
                        'Client_Account__c' : CaseRec.Client_Account__c,
                        'Beneficiary_Name__c' : beneficiaryDetails.Beneficiary_Name__c,
                        'Beneficiary_Account_Number__c' : beneficiaryDetails.Beneficiary_Account_Number__c,
                        'Beneficiary_bank_IFSC_code__c' : beneficiaryDetails.Beneficiary_Bank_IFSC_Code__c,
                        'OwnerId' : '00G28000001mZgK',
                        'Remitter_Account_No_Debit_Account_No__c' : remitterWithoutPadding,
                        'Remitter_Name__c' : Client__c,
                        'Client_Name__c' : Client__c,
                        'Backoffice_Code_Equity__c' : Backoffice_Code_Equity__c
                    },
                    "recordTypeId": FundTransferId
                });
                createFundtransferCase.fire();
            });
            $A.enqueueAction(action);
        }else if(CaseRec.Transfer_To__c == 'Personal'){
           var GWM_Client_Account_Id =  component.get("v.GWM_Client_Account_Id__c");
            var action = component.get("c.getBeneficiaryDetails");
            action.setParams({
                "GWM_Client_Account_Id" : GWM_Client_Account_Id
            });
            action.setCallback(this, function(actionResult) {
                var beneficiaryDetails = actionResult.getReturnValue();
                if(beneficiaryDetails == null){
                   helper.showToast(component, event, helper,'Benificiary Details not found','Error');   
                }else{
                    for (var i = 0; i < beneficiaryDetails.length; i++) { 
                        if(typeof beneficiaryDetails[i].Bank_Details__c != 'undefined'){
                             listOfbenificary.push(beneficiaryDetails[i].Bank_Details__c);
                        }
                }
                component.set("v.showRemitterAccounts",false);
                component.set("v.showTransferTo",false);
                component.set("v.showBenificiaryDetails",true);
                    if(listOfbenificary != null){
                      component.set("v.listOfBeneficiaryDetails",listOfbenificary);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    createCase: function(component, event, helper) { 
        var FundTransferId = component.get("v.FundTransferId"); 
        var Remitter_Account_No__c =  component.get("v.Remitter_Account_No__c");
        var remitterWithoutPadding =  component.get("v.remitterWithoutPadding");
        var Backoffice_Code_Equity__c =  component.get("v.Backoffice_Code_Equity__c");
         var Client__c = component.get("v.Client__c");
        component.set("v.showBenificiaryDetails",false);
        var v = component.find("BeneficiaryDetails").get("v.value");
        var CaseRec = component.get("v.CaseRec");
        var Beneficiary_Name__c,Beneficiary_Account_Number__c,Beneficiary_Bank_IFSC_code__c ;
        var action = component.get("c.fetchBeneficiaryDetails");
        action.setParams({
            "Bank_Details" : v
        });
        action.setCallback(this, function(actionResult) {
            var beneficiaryDetails = actionResult.getReturnValue();
            if((component.find("BeneficiaryDetails").get("v.value")) == 'New'){
                var createFundtransferCase = $A.get("e.force:createRecord");
                createFundtransferCase.setParams({
                    "entityApiName": "Case",
                    "defaultFieldValues": {
                        'Transfer_To__c' : CaseRec.Transfer_To__c,
                        'Client_Account__c' : CaseRec.Client_Account__c,
                        'Remitter_Account_No_Debit_Account_No__c' : remitterWithoutPadding,
                        'OwnerId' : '00G28000001mZgK',
                        'Remitter_Name__c' : Client__c,
                        'Beneficiary_Name__c' : Client__c,
                         'Client_Name__c' : Client__c,
                        'Backoffice_Code_Equity__c' : Backoffice_Code_Equity__c
                    },
                    "recordTypeId": FundTransferId
                });
                createFundtransferCase.fire();
                
            }else{
                for (var i = 0; i < beneficiaryDetails.length; i++) { 
                    if(beneficiaryDetails[i].Bank_Details__c == component.find("BeneficiaryDetails").get("v.value")){
                        Beneficiary_Name__c =  Client__c;
                        Beneficiary_Account_Number__c = beneficiaryDetails[i].Beneficiary_Account_Number__c;
                        Beneficiary_Bank_IFSC_code__c =  beneficiaryDetails[i].Beneficiary_Bank_IFSC_Code__c;
                    }
                }
                
                var createFundtransferCase = $A.get("e.force:createRecord");
                createFundtransferCase.setParams({
                    "entityApiName": "Case",
                    "defaultFieldValues": {
                        'Transfer_To__c' : CaseRec.Transfer_To__c,
                        'Client_Account__c' : CaseRec.Client_Account__c,
                        'Beneficiary_Name__c' : Beneficiary_Name__c,
                        'Beneficiary_Account_Number__c' : Beneficiary_Account_Number__c,
                        'Beneficiary_bank_IFSC_code__c' : Beneficiary_Bank_IFSC_code__c,
                        'Remitter_Account_No_Debit_Account_No__c' : remitterWithoutPadding,
                        'OwnerId' : '00G28000001mZgK',
                        'Remitter_Name__c' : Client__c,
                         'Client_Name__c' : Client__c,
                        'Backoffice_Code_Equity__c' : Backoffice_Code_Equity__c
                    },
                    "recordTypeId": FundTransferId
                });
                createFundtransferCase.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/sObject/Case/list?filterName=Recent"
        });
        urlEvent.fire();
    }, 
})