({
    doInit : function(component, event, helper) {
        var action1 = component.get("c.checkForProfile");
        action1.setCallback(this, function(response){
            var state = response.getState();             
            if(state === "SUCCESS"){
                var result = response.getReturnValue();  
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
                    component.set("v.isProfileAccess",true);
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
                    // get the fields API name and pass it to helper function  
                    var controllingFieldAPI = component.get("v.controllingFieldAPI");
                    var dependingFieldAPI = component.get("v.dependingFieldAPI");
                    var objDetails = component.get("v.objDetail");
                    // call the helper function
                    helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);      
                    helper.currentTime(component, event, helper);
                }
            } else{
                
            }
        });$A.enqueueAction(action1);
        
    },
    familySelection : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Family_Name__c != ''){
            component.set("v.familySelected",true);
        }else if(orderEntry.Family_Name__c == '') {
            component.set("v.familySelected",false);
        }
        
        //var myText = component.find('familyName').get('v.value');
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
        component.set("v.orderEntry",orderEntry);  
    },
    
    clientAccountSelection : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");  
        var listOfAllClients = component.get("v.filteredClientList");
        var selectedClientRecord = component.get("v.selectedClientRecord");
        var selectedClientId = selectedClientRecord.Id;
        
        orderEntry.Client_Name__c =selectedClientId;
        component.set("v.orderEntry", orderEntry);

        var action = component.get("c.getClientAccountInformation");
        action.setParams({
            "clientId" : selectedClientId
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfAllClientAccounts = response.getReturnValue();
                if(listOfAllClientAccounts == null){
                    helper.showToast("Client Account not found for family","Error");
                }else{                   
                    component.set("v.filteredClientAccountList",listOfAllClientAccounts);
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    getProducts : function(component, event, helper) {
        var selectedClientAccountRecord = component.get("v.selectedClientAccountRecord");
        var selectedClientAccountId =   selectedClientAccountRecord.Id;
        component.set("v.selectedClientAccountIdAttr",selectedClientAccountId);
        var orderEntry = component.get("v.orderEntry");  
        orderEntry.Client_Account__c = selectedClientAccountId;
        component.set("v.orderEntry", orderEntry); 
        
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");

        component.set("v.selectedAMCName1",'');
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];

            if(controllerValueKey === 'PMS'){
                    component.set("v.showProductName",true);
                    component.set("v.showInstrument",false);
                    component.set("v.showAmc" , false);
					component.set("v.showAllScheme" , false);
                    
                }
            
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);
                
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
        }
        else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        
        var orderEntry = component.get("v.orderEntry");
        
    },
    /* De-merger comment Starts */
    /*
    getFolioOnHolding : function(component, event, helper){
        
        var orderEntry = component.get("v.orderEntry");  
        // Folio Number set Final for purchase
        if(orderEntry.Transaction_Type__c == 'Purchase' ){
            //orderEntry.Folio__c = 'New';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
            var action = component.get("c.getFolioNumbersPurchase");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                "bseStarAmcCode" : orderEntry.AMC_Name__c,
                "holdingType" : orderEntry.Client_Holding_and_Type__c
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var clientAssetList = response.getReturnValue();
                    if(clientAssetList == null){
                        folioList.push('New');  
                        component.set("v.folioListPurchase",folioList); 
                    }else{
                        folioList.push('New');                    
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c); 
                        }
                        component.set("v.clientAssetListPurchase",clientAssetList); 
                        component.set("v.folioListPurchase",folioList); 
                    }
                }
            });$A.enqueueAction(action);
            
        }
        if(orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch' ){
            var folioListOther = new Array();
            var action = component.get("c.getFolioNumbers");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                "productId" : orderEntry.Product_lookup__c,
                "holdingType" : orderEntry.Client_Holding_and_Type__c
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var clientAssetList = response.getReturnValue();
                    if(clientAssetList == null){
                        folioListOther.push('-- None --');
						component.set("v.folioListPurchase",folioListOther);
                    }else{
                        folioListOther.push('-- None --');
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioListOther.push(clientAssetList[m].Folio_Number__c); 
                        }
                        component.set("v.clientAssetListPurchase",clientAssetList); 
                        component.set("v.folioListPurchase",folioListOther); 
                    }
                }
            });$A.enqueueAction(action);         
        }
    },*/
    /* De-merger comment Ends */
    
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

            if(orderEntry.Product_Type_Order_Entry__c === 'PMS'){
                
                component.set("v.isPMS", true);
                component.set("v.isProuctTypeMF" , false);
                component.set("v.isBond" , false);  
                component.set("v.isFirstScreen" , false);  
                
                /*Common Functionality*/
                var selectedClientRecord = component.get("v.selectedClientRecord");
                var listOfAllClients = component.get("v.filteredClientList");
                for(var m=0 ; m < listOfAllClients.length; m++){
                    if(selectedClientRecord.Id == listOfAllClients[m].Id){
                        component.set("v.selectedClientPAN",listOfAllClients[m].PAN_Number__c);
                    }
                }
                var selectedClientId = selectedClientRecord.Id;
                var action = component.get("c.getUCCMasterData");
                action.setParams({
                    "clientId": selectedClientId
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var bseObjectList = response.getReturnValue();
                        if(bseObjectList == null){
                            helper.showToast("UCC Details Not Found","Error");
                        }else{
                            uccList.push('-- None --');
                            for(var m=0 ; m < bseObjectList.length; m++){
                                uccList.push(bseObjectList[m].CLIENT_CODE__c);
                            }
                            component.set("v.uccList",uccList); 
                        }
                    }
                    
                });$A.enqueueAction(action);
                
                var listOfAllClients = component.get("v.filteredClientList");
                var selectedClientRecord = component.get("v.selectedClientRecord");
                
                for(var m=0 ; m < listOfAllClients.length; m++){
                    if(selectedClientRecord.Id == listOfAllClients[m].Id){
                        orderEntry.Client_Risk_Profile__c = listOfAllClients[m].Risk_Profile_Based_on_IPS__c;
                        orderEntry.Primary_FA_FinanceT__c = listOfAllClients[m].Owner.Id;
                        component.set("v.primaryFA",listOfAllClients[m].Owner.Id);
                        orderEntry.Primary_FA__c = listOfAllClients[m].Owner.Name;
                    }
                }
                var selectedPicklistValue = component.get("v.selectedFolioPMS"); 
               
                orderEntry.Folio__c = selectedPicklistValue;
                component.set("v.orderEntry" , orderEntry);  
                var orderEntryObj = component.get("v.orderEntry");  
                
                
                var action = component.get("c.setClientName");
                action.setParams({
                    orderEntryObj : orderEntryObj 
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var clientName = response.getReturnValue();
                        if(clientName != null){
                            component.set("v.orderEntry.Client_Name_Display__c", clientName);
                            
                        }
                    }
                }); $A.enqueueAction(action);    
                
                var action = component.get("c.setClientAccountName");
                action.setParams({
                    orderEntryObj : orderEntryObj 
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var accountName = response.getReturnValue();
                        if(accountName != null){
                            component.set("v.orderEntry.Client_Account_Display__c", accountName);
                            
                        }
                    }
                }); $A.enqueueAction(action); 
                component.set("v.orderEntry",orderEntry); 
                
                var productName = orderEntry.Product_Name_Display__c;                
                var productCode = productName.split('-').pop();
                
                var orderEntry = component.get("v.orderEntry"); 
                var clientAccountId = orderEntry.Client_Account__c;
                var action1 = component.get("c.fetchProductRiskonProductCode");
                action1.setParams({
                    "prdCode" : productCode                        
                });
                action1.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var prodRiskVal = response.getReturnValue();
                        if(prodRiskVal != null){
                            orderEntry.Product_Risk_Profile_FinancialT__c = prodRiskVal.Risk_Profile_of_Product__c;
                            orderEntry.Product_lookup__c  = prodRiskVal.Id;                                
                        }
                    }
                }); $A.enqueueAction(action1);
                
                /*Common functionality end*/
                orderEntry.Portfolio_Fee_Type__c = 'Fixed';
                
                /*Folio should be blank on Subscription New*/
                if(orderEntry.Transaction_Type__c == 'Subscription (New)'){
                    component.set("v.disablePMSFolio",true);  
                    component.set("v.folioListPMS",'New');
                    orderEntry.Folio__c='New';
                }else{
                    component.set("v.disablePMSFolio",false);
                    var productName = orderEntry.Product_Name_Display__c;
                    
                    var productCode = productName.split('-').pop();
                    
                    var folioListPMSOther = new Array();
                    var action = component.get("c.getFolioPMS");
                    action.setParams({
                        "clientAccountId" : orderEntry.Client_Account__c,
                        "prodCode" : productCode               
                    });                  
                    action.setCallback(this, function(response) {
                        
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var clientAssetList = response.getReturnValue();
                            if(clientAssetList == null){
                                helper.showToast("Client Asset not available","Error");
                            }else{  
                                folioListPMSOther.push("--None--");
                                for(var m=0 ; m < clientAssetList.length; m++){
                                    
                                    folioListPMSOther.push(clientAssetList[m].Folio_Number__c);                                     
                                }                                
                                component.set("v.folioListPMS",folioListPMSOther);
                            }
                        }
                    });$A.enqueueAction(action); 
                    
                    
                }
                
                /*Payment Type display on bases IAS POA*/
                var action = component.get("c.getPMSAccountTYpe");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    
                });                  
                action.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var clientAccountType = response.getReturnValue();
                        if(clientAccountType == null){
                            helper.showToast("Client Account not available","Error");
                        }else{     
                            
                            if(clientAccountType =='IAS' || clientAccountType == 'POA'){ 
                                
                                component.set("v.isPOADisplay",true);
                                component.set("v.isExternalDisplay",false);
                            }else{
                                orderEntry.Payment_Mode__c = 'External Bank';
                                component.set("v.isPaymentModeDisable",true);
                                component.set("v.isPOADisplay",false);
                                component.set("v.isExternalDisplay",true);
                                
                            }
                            
                            
                        }
                    }
                });$A.enqueueAction(action); 
                
                
                
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

        if(orderEntry.Product_Type_Order_Entry__c == 'PMS') {
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isBond" , false);      
            component.set("v.isPMS" , true); 
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
        component.set("v.isFirstScreen" , true); 
        component.set("v.isPreviewScreen" , false); 
        component.set("v.tooltip" , false);
        component.set("v.tooltip1" , false);
        component.set("v.isPMS" , false);
        
    },
  
    
    SaveRecord : function(component, event, helper) {        
        var orderEntry = component.get("v.orderEntry"); 
        //Added for Compliance Screen validation MF reford Type   
        var isValid = helper.validateThirdScreen(component, event, helper);
    
        if(isValid == 1){             
        
                            helper.saveObjRecord(component, event, helper);
            
        }
    },   
    
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
    setValueToProductName : function(component, event, helper) {        
        var orderEntry = component.get("v.orderEntry");        
        var selectedProductName = component.get("v.selectedProductName");             
        if(selectedProductName.label != null){
            orderEntry.Product_Name_Display__c = selectedProductName.label;                        
        }else {
            orderEntry.Product_Name_Display__c = '';
        }         
        component.set("v.orderEntry",orderEntry);
    },
    /* PMS Ends */
    HideToolTip1 : function(component, event, helper){
        
        component.set("v.tooltip1" , false);
    },
    loadBondPreviewScreen : function(component, event, helper){
        component.set("v.isBond" , false);
        component.set("v.isBondPreviewScreen" , true); 
        component.set("v.isDisabled" , true);
    },
    loadBondFirstScreen : function(component, event, helper){
        component.set("v.isDisabled" , true);
        component.set("v.isBond" , false);
        component.set("v.isFirstScreen" , true); 
        component.set("v.isBondPreviewScreen" , false); 
        
    },
    setValuesToPMSField : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");
        var isValid = helper.validateSecondScreen(component, event, helper);
        if(isValid == 1){
            helper.setFamilyNameController(component, event, helper);
            helper.setClientNameController(component, event, helper);
            helper.setClientAccountNameController(component, event, helper);
            // helper.setProductNameController(component, event, helper);
            if(orderEntry.Transaction_Type__c == 'Subscription (New)'){
                component.set("v.isSubscription" , true);
                component.set("v.isOther" , false);
            } else if(orderEntry.Transaction_Type__c != 'Subscription (New)'){
                component.set("v.isSubscription" , false);
                component.set("v.isOther" , true);
            }
            component.set("v.isFirstScreen" , false);
            component.set("v.isBondBuy" , false);
            component.set("v.isBondSell" , false);
            component.set("v.isPMSCompliance" , true);     
            component.set("v.isBond" , false);
            component.set("v.isPMS" , false); 
            component.set("v.isPreviewScreen" , true); 
            component.set("v.isDisabled" , true);
        }
    }, 
    
    setFolioPMS : function(component, event, helper){
        var orderEntry = component.get("v.orderEntry");        
        var selectedPicklistValue = component.get("v.selectedFolioPMS");        
        orderEntry.Folio__c = selectedPicklistValue;
        /*orderEntry.Folio_Number__c = selectedPicklistValue;*/
        component.set("v.orderEntry",orderEntry); 
    },
})