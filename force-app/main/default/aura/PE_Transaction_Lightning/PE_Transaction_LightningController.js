({
    doInit : function(component, event, helper) {

		component.set("v.isProfileAccess",false);
        var eventParams = event.getParams();
		
        component.set("v.isProfileAccess",false);
        var profileAction = component.get("c.checkForProfile");
        profileAction.setCallback(this, function(response){
            var state = response.getState();
					
            if(state === "SUCCESS"){
			
                var result = response.getReturnValue();  
				component.set("v.isProfileAccess",false);
                if(result == -1){
				
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'access to new order is denied',
                        'type': 'Error'
                    });
                    toastEvent.fire();
                    window.setTimeout(
                        $A.getCallback(function() {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/one/one.app#/sObject/Order_Entry__c/list?filterName=Recent"
                            });
                            urlEvent.fire();	
                        }), 1000
                    );
                    
                } else {                  	
                    var orderEntry = component.get("v.orderEntry");  
                    orderEntry.Client_Concent__c = 'Yes';
                    if(orderEntry.Family_Name__c == ''){
                        component.set("v.familySelected",false);
                    }
                    
                    var action1 = component.get("c.gerAttachementParentId");
                    action1.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {                
                            component.set("v.parentId",response.getReturnValue());
                        }                        
                    });$A.enqueueAction(action1);
                    
                    component.get("v.orderEntry",orderEntry);         
                    component.set("v.selectedAMCName1",'');
                    component.set("v.selectedSchemeObj",'');
                    component.set("v.selectedFromSchemeObj",'');
                    component.set("v.selectedToSchemeObj",'');
                    component.set("v.selectedClientCode",'');
                    component.set("v.selectedFolio",'');
                    component.set("v.selectedInstrument",'');
                    component.set("v.selectedProductName",'');
                    component.set("v.selectedInstrumentSP",'');
                    component.set("v.selectedSecurityName",'');
                    
                    // get the fields API name and pass it to helper function  
                    var controllingFieldAPI = component.get("v.controllingFieldAPI");
                    var dependingFieldAPI = component.get("v.dependingFieldAPI");
                    var objDetails = component.get("v.objDetail");
                    // call the helper function
                    helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);      
                    helper.currentTime(component, event, helper);
                   helper.getFilteredFamilyRecords(component, event, helper);
                    component.set("v.isProfileAccess",true);
                }
            } else{
                
            }
        });$A.enqueueAction(profileAction);
        
         component.set('v.columns', [
            {label: 'DrawDown Due Date', fieldName: 'drawDownDueDate', type: 'text'},
            {label: 'DrawDown Amount', fieldName: 'drawDownAmtStr', type: 'text'},
            {label: 'DrawDown Amount Paid Till Date', fieldName: 'drawDownAmtPaidTillDateStr', type: 'text'},
            {label: 'DrawDown Amount Due', fieldName: 'drawDownAmtDueStr', type: 'text'}]);
           
        
    },
    familySelection : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Family_Name__c != ''){
            component.set("v.familySelected",true);
        }else if(orderEntry.Family_Name__c == '') {
            component.set("v.familySelected",false);
        }

        var myText = component.find('familyName').get('v.value');
        
        var orderEntry = component.get("v.orderEntry");  
        var action = component.get("c.getClientInformation");
        action.setParams({
            "familyId" : orderEntry.Family_Name__c
        });                  
        
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfAllClients = response.getReturnValue();
                if(listOfAllClients == null){
                    helper.showToast("Client not found for family","Error");
                }else{                    
                    component.set("v.filteredClientList",listOfAllClients);
                    
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    transactionSelection : function(component, event, helper) {
        component.set("v.showAllScheme",false);
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Transaction_Type__c == 'Redemption'){
            orderEntry.Folio__c = '-- None --';
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",true);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
        }else if(orderEntry.Transaction_Type__c == 'Switch'){
            orderEntry.Folio__c = '-- None --';
            component.set("v.isSwitch",true);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
            
        }else if(orderEntry.Transaction_Type__c == 'Purchase'){
            orderEntry.Folio__c = 'New';
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",true);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
        } else if(orderEntry.Transaction_Type__c == 'Buy'){           
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",true);
            component.set("v.isBondSell",false);
            
        } else if(orderEntry.Transaction_Type__c == 'Sell'){
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",true);
        }
        component.set("v.orderEntry",orderEntry);  
    },
    
    setValueToFamily : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Family_Name__c != ''){
            component.set("v.familySelected",true);
        }else if(orderEntry.Family_Name__c == '') {
            component.set("v.familySelected",false);
        }
        var selectedFamilyRecord = component.get("v.selectedFamilyRecord");
        console.log('selectedFamilyRecord :'+JSON.stringify(component.get("v.filteredFamilyList")));
        var selectedFamilyId = selectedFamilyRecord.Id;
        
        orderEntry.Family_Name__c =selectedFamilyId;
        component.set("v.orderEntry", orderEntry);

        //Check for related client and Display Error only if Family is selected
        if(orderEntry.Family_Name__c != undefined)
        {
            var orderEntry = component.get("v.orderEntry");  
            var orderEntry = component.get("v.orderEntry");  
            var action = component.get("c.getClientInformation");
            action.setParams({
                "familyId" : orderEntry.Family_Name__c
            });                  
            
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listOfAllClients = response.getReturnValue();
                    console.log('listOfAllClients:'+listOfAllClients);
                    //Checking returned list is not null and length should be geater than 0
                    if(listOfAllClients == null || listOfAllClients.length == 0){
                        helper.showToast("Client not found for family","Error");
                        component.set("v.filteredClientList",listOfAllClients);
                    }else{                    
                        component.set("v.filteredClientList",listOfAllClients);
                        helper.setValueToProductType(component, event, helper);
                    }
                }
                
            });$A.enqueueAction(action);
        }    

    //Clear Selected Client and Client Account only when family is cleared
    if(orderEntry.Family_Name__c == undefined)
    {
        var clientNameLookup = component.find("clientNameLookup");
        clientNameLookup.clearMethod();
        component.set("v.filteredClientList",[]);
        var clientAccountLookup =component.find("clientAccountLookup");
        clientAccountLookup.clearMethod();
        component.set("v.filteredClientAccountList",[]);
    }
},
clientAccountSelection : function(component, event, helper) {
    var orderEntry = component.get("v.orderEntry");  
    var listOfAllClients = component.get("v.filteredClientList");
    var selectedClientRecord = component.get("v.selectedClientRecord");
    var selectedClientId = selectedClientRecord.Id;
    

    orderEntry.Client_Name__c =selectedClientId;
    component.set("v.orderEntry", orderEntry);
    //Check for related client and Display Error only if Family is selected
    if(orderEntry.Family_Name__c != undefined && orderEntry.Client_Name__c != undefined)
    {
        var action = component.get("c.getClientAccountInformation");
        action.setParams({
            "clientId" : selectedClientId
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfAllClientAccounts = response.getReturnValue();
                //Checking returned list is not null and length should be geater than 0
                if(listOfAllClientAccounts == null || listOfAllClientAccounts.length == 0){ 
                    helper.showToast("Client Account not found for family","Error");
                    component.set("v.filteredClientAccountList",listOfAllClientAccounts);
                }else{                   
                    component.set("v.filteredClientAccountList",listOfAllClientAccounts);
                }
            }
            
        });$A.enqueueAction(action);
    }

    //Clear Selected Client Account only when Client is cleared
    if(orderEntry.Client_Name__c == undefined)
    {
        var clientAccountLookup =component.find("clientAccountLookup");
        clientAccountLookup.clearMethod();
        component.set("v.filteredClientAccountList",[]);
    }

    
},
    
    getProducts : function(component, event, helper) {
        var selectedClientAccountRecord = component.get("v.selectedClientAccountRecord");
        var selectedClientAccountId =   selectedClientAccountRecord.Id;
        component.set("v.selectedClientAccountIdAttr",selectedClientAccountId);
        var orderEntry = component.get("v.orderEntry");  
        orderEntry.Client_Account__c = selectedClientAccountId;
        component.set("v.orderEntry", orderEntry); 
       
    },
    
    loadMainScreen: function(component, event, helper){
        component.set("v.folioByAPI",false); 
        var orderEntry = component.get("v.orderEntry");  
        var uccList = new Array();
        
        //validate 
        var isValid = helper.validateFirstScreen(component, event, helper);
        if(isValid == 1){
            var action = component.get("c.getStringsDate");         
            action.setCallback(this, function(response) {    
                var state = response.getState();            
                if (state === "SUCCESS") {              
                    var todaysDate = response.getReturnValue();                 
                    if(todaysDate == null){
                        helper.showToast("Client not found for family","Error");
                    }else{                       
                        component.set("v.orderDateStr",todaysDate);
                        component.set("v.valueDateStr",todaysDate);                                        
                    }
                } 
                
            });$A.enqueueAction(action); 
            // Main Screen Loading
           
             if(orderEntry.Product_Type_Order_Entry__c === 'PE / AIF'){              
                helper.loadPE(component, event, helper);
            }
        }
        helper.setClientAccountNameController(component, event, helper);
        helper.setFamilyNameController(component, event, helper);
        
    },
    
    getToMain : function(component, event, helper) {
        //component.set("v.orderEntry",orderEntry);  
        var orderEntry = component.get("v.orderEntry"); 
        component.set("v.isFirstScreen" , false); 
        component.set("v.loadPreviewScreen" , false); 
        
        if(orderEntry.Product_Type_Order_Entry__c == 'PE / AIF' ) {
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isBond" , false);      
            component.set("v.isPMS" , false); 
            component.set("v.isSP" , false);
            component.set("v.isPE" , true);
        }     
        component.set("v.isPreviewScreen" , false); 
        component.set("v.isDisabled" , true);
        
    },
    
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        component.set("v.isProfileAccess",false);
        urlEvent.setParams({
            "url": "/one/one.app#/sObject/Order_Entry__c/list?filterName=Recent"
        });
        urlEvent.fire();
    },
    
    loadPreviewScreen : function(component, event, helper){
        component.set("v.isProuctTypeMF" , false);
        component.set("v.isPreviewScreen" , true); 
        component.set("v.isDisabled" , true);
    },
    loadFirstScreen : function(component, event, helper){
        var orderEntry = component.get("v.orderEntry"); 
        //if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
        component.set("v.isProuctTypeMF" , false);
        //}
        component.set("v.isDisabled" , true);
        component.set("v.isProuctTypeMF" , false);
        component.set("v.isBond" , false);
        component.set("v.isSP" , false);
        component.set("v.isFirstScreen" , true); 
        component.set("v.isPreviewScreen" , false); 
        component.set("v.tooltip" , false);
        component.set("v.tooltip1" , false);
        component.set("v.isPMS" , false);
        component.set("v.isPE" , false);
        
    },
    SaveRecord : function(component, event, helper) {        
        var orderEntry = component.get("v.orderEntry"); 
        /*Added for Compliance Screen validation MF reford Type*/   
        var isValid = helper.validateThirdScreen(component, event, helper);
        if(isValid == 1){ 
             helper.saveObjRecord(component, event, helper);
        }
    },

    setValuesToField : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");   
        
        var isValid = helper.validateSecondScreen(component, event, helper);
        if(isValid == 1){
            helper.setFamilyNameController(component, event, helper);
            helper.setClientNameController(component, event, helper);
            helper.setClientAccountNameController(component, event, helper);
            helper.setProductNameController(component, event, helper);
            
            component.set("v.isFirstScreen" , false);
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isPreviewScreen" , true); 
            component.set("v.isDisabled" , true);
            component.set("v.tooltip" , false);
        }
    }, 
    
    /* Methods for file attachemnet start */
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        helper.doSave(component, event, helper);
    },
    /* Methods for file attachemnet end */
    showToolTip : function(component, event, helper) {
        
        component.set("v.tooltip" , true);
        
    },
    HideToolTip : function(component, event, helper){
        
        component.set("v.tooltip" , false);
    },
    /* Methods for file attachemnet end */
    showToolTip1 : function(component, event, helper) {
        
        component.set("v.tooltip1" , true);
        
    },
    /* PE Start */
    setValueToSecurityName : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry");
        var selectedSecurityName = component.get("v.selectedSecurityName");             
        if(selectedSecurityName.label != null){
            orderEntry.Security_Name_Display__c = selectedSecurityName.label;            
        } else {
            orderEntry.Security_Name_Display__c = '';
        }   
        component.set("v.orderEntry",orderEntry);
    },
    /* PE Ends */
    HideToolTip1 : function(component, event, helper){
        
        component.set("v.tooltip1" , false);
    },
     setValuesToPEField : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");
        var isValid = helper.validateSecondScreen(component, event, helper);
        if(isValid == 1){
            helper.setFamilyNameController(component, event, helper);
            helper.setClientNameController(component, event, helper);
            helper.setClientAccountNameController(component, event, helper);
            
            component.set("v.isFirstScreen" , false);
            component.set("v.isBondBuy" , false);
            component.set("v.isBondSell" , false);
            component.set("v.isPMSCompliance" , false);     
            component.set("v.isBond" , false);
            component.set("v.isPMS" , false); 
            component.set("v.isPE" , false); 
            component.set("v.isPreviewScreen" , true); 
            component.set("v.isDisabled" , true);
            component.set("v.isPECompliance" , true); 
        }
    }, 
    fetchDrawdownDetails : function(component, event, helper){
        alert('Fetching Drawdown Details');
          
        helper.callAPiDrawdownData(component, event, helper);
      
        
    }
})