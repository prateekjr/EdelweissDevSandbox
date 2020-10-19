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
                        "title": "Warning!",
                        "message": 'access to edit order is denied',
                        'type': 'Warning'
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
                    
                    var recId = component.get("v.recordId");
                    component.set("v.orderRecID");       
                    var action = component.get("c.getOrderEntryRec");
                    action.setParams({
                        "orderId" : recId
                    });                  
                    
                    action.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set("v.isProfileAccess",true);
                            var OrderObj = response.getReturnValue();
                            
                            if(OrderObj == null){
                                
                                helper.showToast("Order not found","Error");
                                
                            }else{  
                                
                                if(OrderObj.status__c == 'Rejected'){
                                    component.set("v.isProfileAccess",true);
                                } else {
                                    /*Code for CXO Profile should not edit if order is submitted for review */
                                    component.set("v.isProfileAccess",false);
                                    var actionX = component.get("c.checkCXOProfile");
                                    actionX.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {                                           
                                            var cxoFlag = response.getReturnValue();                           
                                            if(cxoFlag == -1 && OrderObj.Status__c == 'Pending For Review'){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "Warning!",
                                                    "message": 'CXO cannot edit order after submit for review.',
                                                    'type': 'Warning'
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
                                            }
                                        }                        
                                    });$A.enqueueAction(actionX); 
                                }
                                // component.set("v.isProfileAccess",true);
                                console.log('Record Data :'+JSON.stringify(OrderObj));
                                component.set("v.orderEntry" , OrderObj); 
                                
                               /* if(OrderObj.Product_Type_Order_Entry__c == 'Bond' || OrderObj.Product_Type_Order_Entry__c == 'CP' || OrderObj.Product_Type_Order_Entry__c == 'FD' || 
                                   OrderObj.Product_Type_Order_Entry__c == 'SP' || OrderObj.Product_Type_Order_Entry__c == 'CD' || OrderObj.Product_Type_Order_Entry__c == 'ICD'){
                                    component.set("v.showInstrument" , true); 
                                }
                                if(OrderObj.Product_Type_Order_Entry__c == 'PMS'){
                                    component.set("v.showPMSProductName" , true); 
                                }*/
                                if(OrderObj.Product_Type_Order_Entry__c == 'MF'){
                                    debugger;
                                    component.set("v.selectedUccOnSave" , OrderObj.UCC__c);
                                    component.set("v.selectedFolioOnSave" , OrderObj.Folio__c);
                                    component.set("v.selectedValueToFolio" , OrderObj.To_Folio__c);
                                    component.set("v.showAmc" , true); 
                                    
                                
                                /*    var actionmf = component.get("c.getClientInformationOrderEntry");
                                    actionmf.setParams({
                                        "familyId" : OrderObj.Family_Name__c,
                                        
                                    });  
                                    
                                    actionmf.setCallback(this, function(response) {    
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            var isfound = response.getReturnValue();
                                            if(isfound){
                                                component.set("v.isoderentryMF",true);                           
                                                console.log("isoderentryMF onchange :"+component.get("v.isoderentryMF"));
                                                
                                            }
                                            helper.showToast("Enter MF Order Entry","success");
                                        }
                                        
                                    });$A.enqueueAction(actionmf); */
                                }
                                if(OrderObj.Transaction_Type__c == 'Redemption'){
                                    
                                    component.set("v.isSwitch",false);  
                                    component.set("v.isRedemption",true);  
                                    component.set("v.isPurchase",false);  
                                    helper.setFolioRedemption(component, event, helper);
                                    
                                }else if(OrderObj.Transaction_Type__c == 'Switch'){
                                    component.set("v.isSwitch",true);  
                                    component.set("v.isRedemption",false);  
                                    component.set("v.isPurchase",false);  
                                    helper.setFolioRedemption(component, event, helper);
                                    
                                }else if(OrderObj.Transaction_Type__c == 'Purchase'){
                                    component.set("v.isSwitch",false);  
                                    component.set("v.isRedemption",false);  
                                    component.set("v.isPurchase",true);  
                                }
                                if(OrderObj.Transaction_Type__c == 'SWP'){
                                    
                                    component.set("v.isSwitch",false);  
                                    component.set("v.isRedemption",true);  
                                    component.set("v.isPurchase",false);  
                                    component.set("v.isSWP",true);  
                                    helper.setFolioRedemption(component, event, helper);
                                    
                                }else if(OrderObj.Transaction_Type__c == 'STP'){
                                    component.set("v.isSwitch",false);  
                                    component.set("v.isRedemption",false);  
                                    component.set("v.isPurchase",false);  
                                    component.set("v.isSTP",true);  
                                    helper.setFolioRedemption(component, event, helper);
                                    
                                }else if(OrderObj.Transaction_Type__c == 'SIP'){
                                    component.set("v.isSwitch",false);  
                                    component.set("v.isRedemption",false);  
                                    component.set("v.isPurchase",false);  
                                    component.set("v.isSIP",true);  
                                }
                                
                                if(OrderObj.Redemption_Type__c == 'Partial Unit'){
                                    component.set("v.isDisableTxnAmount",true); 
                                    component.set("v.isDisableRedemptionUnit",false);
                                }else if(OrderObj.Redemption_Type__c == 'Partial Amount'){
                                    component.set("v.isDisableTxnAmount",false); 
                                    component.set("v.isDisableRedemptionUnit",true);
                                }
                                debugger;
                                if(OrderObj.OrderEntryMF__c==true){
                                    component.set("v.isoderentryMF",true); 
                                }
                            }
                        } else{
                            component.set("v.isProfileAccess",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Warning!",
                                "message": 'cannot edit order after review/reject/export.',
                                'type': 'Warning'
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
                        }
                        
                    });$A.enqueueAction(action);
                    
                    
                    
                    var action1 = component.get("c.gerAttachementParentId");
                    action1.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {                
                            component.set("v.parentId",response.getReturnValue());
                        }                        
                    });$A.enqueueAction(action1); 
                }
                
                //$A.get("e.force:closeQuickAction").fire();   
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
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Transaction_Type__c == 'Redemption'){
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",true);  
            component.set("v.isPurchase",false);  
        }else if(orderEntry.Transaction_Type__c == 'Switch'){
            component.set("v.isSwitch",true);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",false);  
            
        }else if(orderEntry.Transaction_Type__c == 'Purchase'){
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",true);  
        }
    },
    
    clientAccountSelection : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");  
        var listOfAllClients = component.get("v.filteredClientList");
        var selectedClientRecord = component.get("v.selectedClientRecord");
        var selectedClientId = selectedClientRecord.Id;
        
        orderEntry.Client_Name__c =selectedClientId;
        component.set("v.orderEntry", orderEntry);
        /* 
            for(var m=0 ; m < listOfAllClients.length; m++){
                if(selectedClientId == listOfAllClients[m].Id){
                    orderEntry.Client_Risk_Profile__c  =  listOfAllClients[m].Risk_Profile_Based_on_IPS__c;
                }
            }
        	component.set("v.orderEntry", orderEntry); */
        
        
        
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
        /*var action = component.get("c.getClientProducts");
        action.setParams({
            "clienAccountId": selectedClientAccountId
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfProducts = response.getReturnValue();
                if(listOfProducts == null){
                    helper.showToast("Client Asset Details Not Found","Error");
                }else{
                    component.set("v.productList",listOfProducts);  
                }
            }
            
        });$A.enqueueAction(action);
        
        
        var folioList = new Array();
        
        var action = component.get("c.getFolioNumbersPurchase");
        action.setParams({
            "clientAccountId" : selectedClientAccountId,
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var clientAssetList = response.getReturnValue();
                if(clientAssetList == null){
                    helper.showToast("Client Asset not available","Error");
                }else{
                    folioList.push('-- None --');
                    for(var m=0 ; m < clientAssetList.length; m++){
                        folioList.push(clientAssetList[m].Folio_Number__c);
                    }
                    component.set("v.clientAssetListPurchase",clientAssetList); 
                    component.set("v.folioListPurchase",folioList); 
                }
            }
        });$A.enqueueAction(action);
        
        */
        
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        /*var CaseRec = component.get("v.CaseRec");
    
        //Initialize
        component.set('v.CaseRec.Transaction_Type__c', ['--- None ---']);
        component.set("v.listDependingValues", ['--- None ---']);
        component.set('v.filteredProductList',['--- None ---']);
        component.set('v.filteredAllProductList',['--- None ---']);
        component.set("v.folioNumber",'');
	
        component.set("v.selectedLookUpRecord",{});
        component.set("v.selectedLookUpRecord1",{});*/
        component.set("v.selectedAMCName1",'');
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(controllerValueKey === 'MF'){
                component.set("v.showAmc" , true); 
                component.set("v.showInstrument",false);
                component.set("v.showPMSProductName",false);
                
            } else if(controllerValueKey === 'Bond'){
                component.set("v.showInstrument",true);
                component.set("v.showPMSProductName",false);
                component.set("v.showAmc" , false); 
                
            }else if(controllerValueKey === 'PMS'){
                component.set("v.showInstrument",false);
                component.set("v.showPMSProductName",true);
                component.set("v.showAmc" , false); 
                
            }
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);
                
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        
        var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
            var action = component.get("c.getAmcCode");
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var amcNameList = response.getReturnValue();
                    if(amcNameList == null){
                        helper.showToast("AMC Name Not Found","Error");
                    }else{
                        component.set("v.amcList",amcNameList);  
                    }
                }
                
            });$A.enqueueAction(action);
            
        }
        
        
        
    },
   /* getFolioOnHolding : function(component, event, helper){
        
        var orderEntry = component.get("v.orderEntry");  
        var isorderentrymf = component.get("v.isoderentryMF");  
        if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
            console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
            console.log('orderEntry.AMC_Name__c :'+orderEntry.AMC_Name__c);
            console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
            //component.set("v.selectedFolioOnSave",'New'); 
            orderEntry.Folio__c = 'New';
            component.set("v.orderEntry", orderEntry );
            
            
            
            var folioList = new Array();
            var action = component.get("c.getFoliosPurchaseForMFOE");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                "bseStarAmcName" : orderEntry.AMC_Name__c,
                "holdingType" : orderEntry.Client_Holding_and_Type__c	
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                console.log("state response :"+state);
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
               
                                                
                                                component.set("v.orderEntry",orderEntry); 
                                                component.set("v.clientAssetListPurchase",clientAssetList); 
                                                component.set("v.folioListPurchase",folioList); 
                                            }
                                            console.log("folioList :"+folioList);
                                        }
                                    });$A.enqueueAction(action);
            
        }
            
            if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'SWP' || orderEntry.Transaction_Type__c == 'STP') && isorderentrymf){
                console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
                console.log('orderEntry.Product_lookup__c :'+orderEntry.Product_lookup__c);
                console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
               // component.set("v.selectedFolioOnSave",''); 
                orderEntry.Folio__c = '';
                component.set("v.orderEntry", orderEntry );
                var folioListOther = new Array();
                var action = component.get("c.getFolioNumbers");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "productId" : orderEntry.Product_lookup__c,
                    "holdingType" : orderEntry.Client_Holding_and_Type__c
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    console.log("state response :"+state);
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
                            //component.set("v.clientAssetListPurchase",clientAssetList);  clientAssetListRedemption
                            component.set("v.clientAssetListPurchase",clientAssetList);  
                            component.set("v.folioList",folioListOther); 
                        }
                        console.log("folioListOther :"+folioListOther); 
                    }
                });$A.enqueueAction(action);         
                
            }
            
            
            
            // Folio Number set Final for purchase
            if(orderEntry.Transaction_Type__c == 'Purchase' && !isorderentrymf){
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
                            component.set("v.folioList",folioList); 
                        }
                    }
                });$A.enqueueAction(action);
                
            }
            if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch') && !isorderentrymf ){
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
        }, */
    getFolioOnHolding : function(component, event, helper){
         
        var orderEntry = component.get("v.orderEntry");  
        var isorderentrymf = component.get("v.isoderentryMF");  
        
        if(orderEntry.Transaction_Type__c == 'Purchase' && !isorderentrymf){
            component.set("v.selectedFolioOnSave",'New'); 
            orderEntry.Folio__c = 'New';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
             var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                        component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('New');                    
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                          if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action);
            
        }     
        debugger;
            if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
            component.set("v.selectedFolioOnSave",'New'); 
            orderEntry.Folio__c = 'New';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
             var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
            var action = component.get("c.getFoliosPurchaseForMFOE");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                "bseStarAmcName" : orderEntry.AMC_Name__c,
                "holdingType" : orderEntry.Client_Holding_and_Type__c
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var clientAssetList = response.getReturnValue();
                    if(clientAssetList == null){
                        folioList.push('New');  
                        component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('New');                    
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                          if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action);
            
        }
        
        if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch') && !isorderentrymf){
             
            component.set("v.selectedFolioOnSave",''); 
            orderEntry.Folio__c = '';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
             var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                       folioList.push('-- None --');
                        
                          if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                            component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('-- None --');
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                           if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action); 
            
        } 
        
        if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'SWP' || orderEntry.Transaction_Type__c == 'STP') && isorderentrymf){
            
            component.set("v.selectedFolioOnSave",''); 
            orderEntry.Folio__c = '';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
            var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                        folioList.push('-- None --');
                        
                        if(!(folioList.includes(selectedFolioOnSave))) {
                            folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('-- None --');
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                        if(!(folioList.includes(selectedFolioOnSave))) {
                            folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action); 
            
            //Added By Prateek To Folio
     
            if(orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'STP')
            {
                component.set("v.selectedValueToFolio",''); 
                orderEntry.To_Folio__c = '';
                component.set("v.orderEntry", orderEntry );
                
                //alert('To Folio selectedToSchemeObjId :'+orderEntry.To_Scheme__c);
                var folioListnew = new Array();
                var selectedValueToFolio = component.get("v.selectedValueToFolio");
                var action = component.get("c.getFolioNumbers");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "productId" : orderEntry.Product_Lookup_ToScheme__c,
                   // "productId" : '01t0k000005X8g6AAC',
                    "holdingType" : orderEntry.Client_Holding_and_Type__c
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var clientAssetList = response.getReturnValue();
                        if(clientAssetList == null){
                            folioListnew.push('-- None --');
                            
                            if(!(folioListnew.includes(selectedValueToFolio))) {
                                folioListnew.push(selectedValueToFolio); 
                            }
                            component.set("v.folioList",folioList); 
                        }else{
                            folioListnew.push('-- None --');
                            for(var m=0 ; m < clientAssetList.length; m++){
                                folioListnew.push(clientAssetList[m].Folio_Number__c);
                            }
                            if(!(folioListnew.includes(selectedValueToFolio))) {
                                folioListnew.push(selectedValueToFolio); 
                            }
                            component.set("v.clientAssetListRedemption",clientAssetList); 
                            component.set("v.selectedToFoliolist",folioListnew); 
                        }
                    }
                });$A.enqueueAction(action); 
            } 
        }
    },
    loadMainScreen: function(component, event, helper){
        
        var orderEntry = component.get("v.orderEntry");  
        var uccList = new Array();
        
        //validate 
        // var isValid = helper.validateFirstScreen(component, event, helper);
        // if(isValid == 1){
        // Main Screen Loading
        if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
            var selectedClientRecord = component.get("v.selectedClientRecord");
            var listOfAllClients = component.get("v.filteredClientList");
            var selectedUccOnSave = component.get("v.selectedUccOnSave")
            
            
            for(var m=0 ; m < listOfAllClients.length; m++){
                if(selectedClientRecord.Id == listOfAllClients[m].Id){
                    component.set("v.selectedClientPAN",listOfAllClients[m].PAN_Number__c);
                }
            }
            var selectedClientId =orderEntry.Client_Name__c;
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
                        //uccList.push('-- None --');
                        for(var m=0 ; m < bseObjectList.length; m++){
                            var listVal ;
                            //Change                               
                            if(bseObjectList[m].CLIENT_CODE__c != 'undefined'){
                                listVal = bseObjectList[m].CLIENT_CODE__c;
                            }
                            if(typeof bseObjectList[m].FIRST_APPLICANT_NAME__c != 'undefined'){
                                listVal = listVal + ' - '+ 'JH1: '+ bseObjectList[m].FIRST_APPLICANT_NAME__c;
                            }
                            if(typeof bseObjectList[m].SECOND_APPLICANT_NAME__c != 'undefined'){
                                listVal = listVal + ' - '+ 'JH2: '+ bseObjectList[m].SECOND_APPLICANT_NAME__c;
                            }
                            if(typeof bseObjectList[m].THIRD_APPLICANT_NAME__c != 'undefined'){
                                listVal = listVal + ' - '+ 'JH3: '+ bseObjectList[m].THIRD_APPLICANT_NAME__c;
                            }if(typeof bseObjectList[m].CLIENT_NOMINEE__c != 'undefined'){
                                listVal = listVal + ' - '+ 'NM: '+ bseObjectList[m].CLIENT_NOMINEE__c;
                            }
                            
                            
                            if(listVal.includes(selectedUccOnSave)){
                                component.set("v.newlyselectedUccCompare",listVal);     
                            }
                            uccList.push(listVal);
                        }
                        component.set("v.uccList",uccList); 
                    }
                }
                
            });$A.enqueueAction(action);
            
            var action = component.get("c.getPMSAccountTYpe");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                
            });                  
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var clientAccountType = response.getReturnValue();
                    if(clientAccountType == null){
                        orderEntry.POA_Non_POA__c = 'Non POA – Online';
                    }else{     
                        if(clientAccountType =='IAS' || clientAccountType == 'POA'){ 
                            orderEntry.POA_Non_POA__c = 'POA – Online';
                            component.set("v.isPOA",true);    
                            component.set("v.isNonPOA",false); 
                        }else{
                            orderEntry.POA_Non_POA__c = 'Non POA – Online';
                            component.set("v.isNonPOA",true);  
                            component.set("v.isPOA",false);  
                            
                        }
                    }
                }
            });$A.enqueueAction(action); 
            
            var isorderentrymf = component.get("v.isoderentryMF");
            
             if(orderEntry.Transaction_Type__c == 'Purchase' && !isorderentrymf){
                 var selectedFolioOnSave = component.get("v.selectedFolioOnSave"); 
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
                            component.set("v.folioList",folioList); 
                        }else{
                            folioList.push('New');        
                            for(var m=0 ; m < clientAssetList.length; m++){
                                folioList.push(clientAssetList[m].Folio_Number__c);
                            }
                              if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                            component.set("v.clientAssetListRedemption",clientAssetList); 
                            component.set("v.folioList",folioList); 
                        }
                    }
                });$A.enqueueAction(action);
                
            }      
            
            if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch') && !isorderentrymf){
                var folioList = new Array();
                  var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                             folioList.push('-- None --');
                            if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                            component.set("v.folioList",folioList); 
                        }else{
                            folioList.push('-- None --');
                            for(var m=0 ; m < clientAssetList.length; m++){
                                folioList.push(clientAssetList[m].Folio_Number__c);
                            }
                             if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                            component.set("v.clientAssetListRedemption",clientAssetList); 
                            component.set("v.folioList",folioList); 
                        }
                    }
                });$A.enqueueAction(action);
                
                
            }    
            debugger;
		 if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
           // component.set("v.selectedFolioOnSave",'New'); 
           // orderEntry.Folio__c = 'New';
           // component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
             var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
            var action = component.get("c.getFoliosPurchaseForMFOE");
            action.setParams({
                "clientAccountId" : orderEntry.Client_Account__c,
                "bseStarAmcName" : orderEntry.AMC_Name__c,
                "holdingType" : orderEntry.Client_Holding_and_Type__c
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var clientAssetList = response.getReturnValue();
                    if(clientAssetList == null){
                        folioList.push('New');  
                        component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('New');                    
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                          if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action);
            
        }
        
        if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch') && !isorderentrymf){
             
            component.set("v.selectedFolioOnSave",''); 
            orderEntry.Folio__c = '';
            component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
             var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                       folioList.push('-- None --');
                        
                          if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                            component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('-- None --');
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                           if(!(folioList.includes(selectedFolioOnSave))) {
                             folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action); 
            
        } 
        
        if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'SWP' || orderEntry.Transaction_Type__c == 'STP') && isorderentrymf){
            
            //component.set("v.selectedFolioOnSave",''); 
           // orderEntry.Folio__c = '';
           // component.set("v.orderEntry", orderEntry );
            var folioList = new Array();
            var selectedFolioOnSave = component.get("v.selectedFolioOnSave");
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
                        folioList.push('-- None --');
                        
                        if(!(folioList.includes(selectedFolioOnSave))) {
                            folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.folioList",folioList); 
                    }else{
                        folioList.push('-- None --');
                        for(var m=0 ; m < clientAssetList.length; m++){
                            folioList.push(clientAssetList[m].Folio_Number__c);
                        }
                        if(!(folioList.includes(selectedFolioOnSave))) {
                            folioList.push(selectedFolioOnSave); 
                        }
                        component.set("v.clientAssetListRedemption",clientAssetList); 
                        component.set("v.folioList",folioList); 
                    }
                }
            });$A.enqueueAction(action);  
            
            //Added By Prateek For To Folio 
            debugger;
            if(orderEntry.Transaction_Type__c == 'Switch'|| orderEntry.Transaction_Type__c == 'STP')
            {
               
                var folioListnew = new Array();
                var selectedValueToFolio = component.get("v.selectedValueToFolio");
                var action = component.get("c.getFolioNumbers");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                   	 "productId" : orderEntry.Product_Lookup_ToScheme__c, 
                   //	"productId" : '01t0k000005X8g6AAC',
                    "holdingType" : orderEntry.Client_Holding_and_Type__c
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var clientAssetList = response.getReturnValue();
                        if(clientAssetList == null){
                            folioListnew.push('-- None --');
                            
                            if(!(folioListnew.includes(selectedValueToFolio))) {
                                folioListnew.push(selectedValueToFolio); 
                            }
                            component.set("v.folioList",folioListnew); 
                        }else{
                            folioListnew.push('-- None --');
                            for(var m=0 ; m < clientAssetList.length; m++){
                                folioListnew.push(clientAssetList[m].Folio_Number__c);
                            }
                            if(!(folioListnew.includes(selectedValueToFolio))) {
                                folioListnew.push(selectedValueToFolio); 
                            }
                            component.set("v.clientAssetListRedemption",clientAssetList); 
                            component.set("v.selectedToFoliolist",folioListnew); 
                            console.log("folioList New :"+folioListnew)
                        }
                    }
                });$A.enqueueAction(action); 
            } 
            
        }
            //Added By Parteek
    
         /*   if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
                debugger;
                console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
                console.log('orderEntry.AMC_Name__c :'+orderEntry.AMC_Name__c);
                console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
                var selectedFolioOnSave = component.get("v.selectedFolioOnSave"); 
                
                
                var folioList = new Array();
                var action = component.get("c.getFoliosPurchaseForMFOE");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "bseStarAmcName" : orderEntry.AMC_Name__c,
                    "holdingType" : orderEntry.Client_Holding_and_Type__c	
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    console.log("state response :"+state);
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
            
                                                if(!(folioList.includes(selectedFolioOnSave))) {
                                                    folioList.push(selectedFolioOnSave); 
                                                }
                                                component.set("v.orderEntry",orderEntry); 
                                                component.set("v.clientAssetListPurchase",clientAssetList); 
                                                component.set("v.folioListPurchase",folioList); 
                                            }
                                            console.log("folioList :"+folioList);
                                        }
                                    });$A.enqueueAction(action);
                 
             }
            
            if((orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'SWP' || orderEntry.Transaction_Type__c == 'STP') && isorderentrymf){
                var selectedFolioOnSave = component.get("v.selectedFolioOnSave"); 
                console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
                console.log('orderEntry.Product_lookup__c :'+orderEntry.Product_lookup__c);
                console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
                var folioListOther = new Array();
                var action = component.get("c.getFolioNumbers");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "productId" : orderEntry.Product_lookup__c,
                    "holdingType" : orderEntry.Client_Holding_and_Type__c
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    console.log("state response :"+state);
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
                            if(!(folioListOther.includes(selectedFolioOnSave))) {
                                folioListOther.push(selectedFolioOnSave); 
                            }
                            
                            component.set("v.clientAssetListPurchase",clientAssetList); 
                            component.set("v.folioListPurchase",folioListOther); 
                        }
                        console.log("folioListOther :"+folioListOther); 
                    }
                });$A.enqueueAction(action);         
                
            }
             */
            
            component.set("v.isFirstScreen" , false); 
            component.set("v.isBond", false);
            component.set("v.loadPreviewScreen" , false); 
            component.set("v.isProuctTypeMF" , true);                
            component.set("v.isPreviewScreen" , false); 
            component.set("v.isDisabled" , true);
            
            helper.setClientAccountNameController(component, event, helper);
            helper.setFamilyNameController(component, event, helper);
            
        }
       /* else  if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
                 orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD'){
            component.set("v.isFirstScreen" , false); 
            component.set("v.isBond", true);
            component.set("v.isProuctTypeMF" , false);     
            component.set("v.isDisabled" , true);
            component.set("v.isBondPreviewScreen",false);
            if(orderEntry.Product_Type_Order_Entry__c === 'SP')
            {
                component.set("v.isSP", true);
            }
            if(orderEntry.Transaction_Type__c == 'Buy'){
                component.set("v.isBondBuy", true); 
                component.set("v.isBondSell", false); 
            } else if(orderEntry.Transaction_Type__c == 'Sell'){
                
                component.set("v.isBondSell", true); 
                component.set("v.isBondBuy", false); 
                
            }  */
            
            /*Payment Type display on bases IAS POA*/
         /*   var action = component.get("c.getPMSAccountTYpe");
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
            
            helper.setClientAccountNameController(component, event, helper);
            helper.setFamilyNameController(component, event, helper);
        }
            else  if(orderEntry.Product_Type_Order_Entry__c === 'PMS'){
                component.set("v.isFirstScreen" , false); 
                component.set("v.isBond", false);
                component.set("v.isPMS", true);
                component.set("v.isProuctTypeMF" , false);     
                component.set("v.isDisabled" , true);
                component.set("v.isBondPreviewScreen",false);
                if(orderEntry.Transaction_Type__c == 'Subscription (New)'){
                    component.set("v.disablePMSFolio",true);  
                    component.set("v.folioListPMS",'');
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
                                for(var m=0 ; m < clientAssetList.length; m++){
                                    
                                    folioListPMSOther.push(clientAssetList[m].Folio_Number__c);                                     
                                }
                                
                                component.set("v.folioListPMS",folioListPMSOther);
                            }
                        }
                    });$A.enqueueAction(action); 
                }*/
                
                /*Payment Type display on bases IAS POA*/
              /*  var action = component.get("c.getPMSAccountTYpe");
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
                
                helper.setClientAccountNameController(component, event, helper);
                helper.setFamilyNameController(component, event, helper);
            }*/
        //helper.setClientAccountNameController(component, event, helper);
        // helper.setFamilyNameController(component, event, helper);
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
    },
    
    getToMain : function(component, event, helper) {
        //component.set("v.orderEntry",orderEntry);  
        var orderEntry = component.get("v.orderEntry"); 
        component.set("v.isFirstScreen" , false); 
        component.set("v.loadPreviewScreen" , false); 
       /* if(orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'CP' || orderEntry.Product_Type_Order_Entry__c == 'FD' || 
           orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c == 'CD' || orderEntry.Product_Type_Order_Entry__c == 'ICD'){
            component.set("v.isProuctTypeMF" , false);                
            component.set("v.isBond" , true);      
            component.set("v.isPMS" , false); 
        }*/ if(orderEntry.Product_Type_Order_Entry__c == 'MF') {
            component.set("v.isProuctTypeMF" , true);
            component.set("v.isBond" , false);      
            component.set("v.isPMS" , false); 
        } /*else if(orderEntry.Product_Type_Order_Entry__c == 'PMS') {
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isBond" , false);      
            component.set("v.isPMS" , true); 
        }  */     
        component.set("v.isPreviewScreen" , false); 
        component.set("v.isDisabled" , true);
        
        
    },
    
    /*getScheme : function(component, event, helper) {
        var selectedAMCName = component.get("v.selectedAMCName");  
        var schemeList;
        var action = component.get("c.getSchemeController");
        action.setParams({
            "amcCode" : selectedAMCName.AMC_Code__c
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var schemeList = response.getReturnValue();
                if(schemeList == null){
                    helper.showToast("Client Account not found for family","Error");
                }else{
                    component.set("v.schemeList",schemeList);
                }
            }
            
        });$A.enqueueAction(action);
        
        
        /*var amcNameList = component.get("v.amcList");  
          var selectedAMCName = component.get("v.selectedAMCName");  
          var schemeList = component.get("v.schemeList"); 
            
            for(var m=0 ; m < amcNameList.length; m++){
                if(selectedAMCName.AMC_Code__c == amcNameList[m].AMC_Code__c){
                    schemeList.add(amcNameList[m].Scheme_Name__c);
                }
            }
        component.set("v.schemeList",schemeList); 
        
    },*/
    
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
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
        component.set("v.isDisabled" , true);
        component.set("v.isProuctTypeMF" , false);
        component.set("v.isBond" , false);
        component.set("v.isPMS" , false);
        component.set("v.isFirstScreen" , true); 
        component.set("v.isPreviewScreen" , false); 
        component.set("v.tooltip" , false);
        
    },
    
    setvalues: function(component, event, helper) {
        /*  
        var orderEntry = component.get("v.orderEntry"); 
        
        var selectedAMCName1 = component.get("v.selectedAMCName1"); 
        orderEntry.AMC_Name__c = selectedAMCName1.label;
        
        var selectedSchemeObj = component.get("v.selectedSchemeObj"); 
        orderEntry.Scheme__c = selectedSchemeObj.label;
        
        var selectedFromSchemeObj = component.get("v.selectedFromSchemeObj"); 
        orderEntry.From_Scheme__c = selectedFromSchemeObj.label;
        
        var selectedToSchemeObj = component.get("v.selectedToSchemeObj"); 
        orderEntry.To_Scheme__c = selectedToSchemeObj.label;
        
        var selectedClientPAN = component.get("v.selectedClientPAN"); 
        orderEntry.UCC__c = selectedClientPAN;
        
        
        component.set("v.orderEntry",orderEntry); */
        
    },
    fetchClientHolding: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedUcc = component.get("v.newlyselectedUccCompare"); 
        orderEntry.UCC_Holdings__c =  selectedUcc;
        if(selectedUcc.includes("-")){
            var indOf = selectedUcc.indexOf("-");
            var res = selectedUcc.substring(0, indOf);
            res = res.trim();
            selectedUcc = res;
        }
        
        /*var selectedFolio = component.get("v.selectedFolio"); 
        orderEntry.Folio__c = selectedFolio.label;*/
        
        var selectedClientCode = component.get("v.selectedClientCode"); 
        orderEntry.UCC__c = selectedUcc;
        // orderEntry.UCC__c = selectedClientCode.label;
        
        component.set("v.orderEntry",orderEntry); 
        var orderEntryObj = component.get("v.orderEntry"); 
        
        if(selectedClientCode != null){
            var action = component.get("c.getClientHoldingInfo");
            action.setParams({
                "clientCode" : selectedUcc
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var bseobj = response.getReturnValue();
                    if(bseobj == null){
                        helper.showToast("Client holing not available","Error");
                    }else{
                        if(bseobj.CLIENT_HOLDING__c != null){
                            //orderEntryObj.Holding_Information__c = bseobj.CLIENT_HOLDING__c;
                            var tooltip = 'Second  Applicant Name : '+bseobj.SECOND_APPLICANT_NAME__c + ' ,  ' +'Third Applicant Name : '+ bseobj.THIRD_APPLICANT_NAME__c + ' , '+'Client Nominee : '+bseobj.CLIENT_NOMINEE__c;
                            orderEntryObj.CDSLCLTID__c = bseobj.CDSLCLTID__c;
                            //orderEntryObj.Client_Holding_and_Type__c = bseobj.CLIENT_TYPE__c;
                            orderEntryObj.Client_Default_Dp__c = bseobj.CLIENT_DEFAULT_DP__c;
                            if(bseobj.CLIENT_TYPE__c == 'DEMAT'){
                                if(bseobj.CLIENT_DEFAULT_DP__c != null){
                                    if(bseobj.CLIENT_DEFAULT_DP__c == 'CDSL'){
                                        var cdslString = 'CDSL : '+ bseobj.CDSLCLTID__c	;
                                        component.set("v.clientHoldingType",cdslString);
                                    }else if(bseobj.CLIENT_DEFAULT_DP__c == 'NSDL'){
                                        var nsdlString = 'NSDL : '+ bseobj.NSDLCLTID__c	;
                                        component.set("v.clientHoldingType",bseobj.NSDLCLTID__c);
                                    }
                                }
                            }
                            if(bseobj.CLIENT_EMAIL__c != null){
                                orderEntryObj.Client_Email__c = bseobj.CLIENT_EMAIL__c;
                            }
                            component.set("v.holdingInformation",tooltip);
                            component.set("v.orderEntry",orderEntryObj); 
                        }
                    }
                }
                
            });$A.enqueueAction(action);
        }
    },
    /* setFolioPurchase: function(component, event, helper) {
        
    },
    getSchemeNameController: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedFolio = component.get("v.selectedFolio");
        if(selectedFolio != null){
            orderEntry.Folio__c = selectedFolio.label;
        }
        component.set("v.orderEntry",orderEntry);
        if(selectedFolio != null){
            var action = component.get("c.getSchemeName");
            action.setParams({
                "FolioNumber" : selectedFolio.label
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listOfAsset = response.getReturnValue();
                    if(listOfAsset == null){
                        helper.showToast("Client Asset not available","Error");
                    }else{
                        component.set("v.filteredClientAssetList",listOfAsset); 
                    }
                }
                
            });$A.enqueueAction(action);
        }
    },
    
    setSelectedScheme: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedProduct = component.get("v.selectedClientAssetRecord"); 
        if(selectedProduct != null){
            orderEntry.Product_lookup__c = selectedProduct.Id;
        }
        component.set("v.orderEntry",orderEntry); 
        var productList = component.get("v.filteredClientAssetList"); 
        var orderEntryObj = component.get("v.orderEntry"); 
        
        for(var m=0 ; m < productList.length; m++){
            if(selectedProduct.Id == productList[m].Id){
                orderEntryObj.Product_Risk_Profile_FinancialT__c = productList[m].Risk_Profile_of_Product__c;
            }
        }
        component.set("v.orderEntry",orderEntryObj); 
    },
    
    setRedemptionValues: function(component, event, helper) {
         
        var orderEntry = component.get("v.orderEntry"); 
        var selectedProduct = component.get("v.selectedClientAssetRecordRedemption"); 
        if(selectedProduct != null){
            orderEntry.Product_lookup__c = selectedProduct.Id;
        }
        component.set("v.orderEntry",orderEntry); 
        var productList = component.get("v.filteredClientAssetListRedemption"); 
        var orderEntryObj = component.get("v.orderEntry"); 
        
        for(var m=0 ; m < productList.length; m++){
            if(selectedProduct.Id == productList[m].Id){
                orderEntryObj.Product_Risk_Profile_FinancialT__c = productList[m].Risk_Profile_of_Product__c;
                orderEntryObj.Folio__c = productList[m].Folio_Number__c;
            }
        }
        component.set("v.orderEntry",orderEntryObj); 
        helper.setProductNameController(component, event, helper);
        
        var selectedClientAccountRecord = component.get("v.selectedClientAccountRecord");
        var selectedClientAccountId =   selectedClientAccountRecord.Id;
        var prodId = selectedProduct.Id;
        var folioList = new Array();
        
        var action = component.get("c.getFolioNumbers");
        action.setParams({
            "clientAccountId" : selectedClientAccountId,
            "productId" : prodId
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var clientAssetList = response.getReturnValue();
                if(clientAssetList == null){
                    helper.showToast("Client Asset not available","Error");
                }else{
                    folioList.push('-- None --');
                    for(var m=0 ; m < clientAssetList.length; m++){
                        folioList.push(clientAssetList[m].Folio_Number__c);
                    }
                    component.set("v.clientAssetListRedemption",clientAssetList); 
                    component.set("v.folioList",folioList); 
                }
            }
        });$A.enqueueAction(action);
    },
    */
    setFolioRedemption : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedPicklistValue = component.get("v.selectedFolioOnSave");
        orderEntry.Folio__c = selectedPicklistValue;	
        orderEntry.Redemption_Type__c = 'None';
        orderEntry.Transaction_Amount_Financial_Transaction__c = '';
        orderEntry.Redemption_Units__c = '';
        /*var action = component.get("c.getFolioNumbers");
        action.setParams({
            "clientAccountId" : orderEntry.Client_Account__c,
            "productId" : orderEntry.Product_lookup__c
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var clientAssetList = response.getReturnValue();
                if(clientAssetList == null){
                    helper.showToast("Client Asset not available","Error");
                }else{
                    component.set("v.clientAssetListRedemption",clientAssetList); 
                }
            }
        });$A.enqueueAction(action); */
        
        var clientAssetList = component.get("v.clientAssetListRedemption"); 
        
        if(orderEntry.Folio__c != ''){
            for(var m=0 ; m < clientAssetList.length; m++){
                if(clientAssetList[m].Folio_Number__c == orderEntry.Folio__c){
                    
                }
            }
        }
        component.set("v.orderEntry",orderEntry); 
    },  
        setFolioToRedemption : function(component, event, helper) {
           
                var orderEntry = component.get("v.orderEntry"); 
        var clientAssetList = component.get("v.clientAssetListPurchase"); 
        // var selectedPicklistValue = component.get("v.selectedFolioPurchase");
        var selectedPicklistValue = component.get("v.selectedValueToFolio");
        
        orderEntry.To_Folio__c = selectedPicklistValue;	

        component.set("v.orderEntry",orderEntry); 
    },
    
    setUCC : function(component, event, helper) {
        var selectedUcc = component.get("v.selectedUcc");
    },
    setFolioPurchase : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var clientAssetList = component.get("v.clientAssetListPurchase"); 
        // var selectedPicklistValue = component.get("v.selectedFolioPurchase");
        var selectedPicklistValue = component.get("v.selectedFolioOnSave");
        
        orderEntry.Folio__c = selectedPicklistValue;	
        
        // component.set("v.selectedFolioOnSave",''); 
        component.set("v.orderEntry",orderEntry); 
    },
    /*etSelectedSchemeRedemption: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        if(orderEntry.Transaction_Type__c == 'Redemption')
        {
            var selectedClientAccountRecord = component.get("v.selectedClientAccountRecord");
            var selectedClientAccountId =   selectedClientAccountRecord.Id;
            component.set("v.orderEntry",orderEntry);
            if(selectedClientAccountId != null){
                var action = component.get("c.getSchemeNameRedemption");
                action.setParams({
                    "selectedClientAcc" : selectedClientAccountId
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listOfAsset = response.getReturnValue();
                        if(listOfAsset == null){
                            helper.showToast("Client Asset not available","Error");
                        }else{
                            component.set("v.filteredClientAssetListRedemption",listOfAsset); 
                        }
                    }
                });$A.enqueueAction(action);
            }
        }
    },*/
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 
        var orderEntry = component.get("v.orderEntry"); 
        if(orderEntry.Transaction_Type__c != 'Redemption' && orderEntry.Transaction_Type__c != 'Switch' && orderEntry.Transaction_Type__c != 'Purchase')
        {
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            component.set("v.selectedAMCName1" , selectedAccountGetFromEvent); 
        }
    },
    SaveRecord : function(component, event, helper) {
        
        var isValid = helper.validateSecondScreen(component, event, helper);
       // var isValid =1;
        var isoderentryMF = component.get("v.isoderentryMF");
        //var isValid = 1;
        if(isValid == 1){
            
            var orderEntry = component.get("v.orderEntry"); 
            orderEntry.sobjectType='Order_Entry__c';
            var recId = component.get("v.recordId");
            var action = component.get("c.saveObj");
            action.setParams({
                "orderEntryObj" : orderEntry,
                "orderEntryId" : recId,
                "isoderentryMF" : isoderentryMF
            });                  
            action.setCallback(this, function(response) {    
                var state = response.getState();
                if (state === "SUCCESS") {
                    var savedRecId = response.getReturnValue();
                    if(savedRecId.includes('Error')){
                        var savedRecId = savedRecId.replace("Error", "");
                        helper.showToast(savedRecId,"Error");
                    }else{
                        helper.showToast('Modified Successfully',"Success");
                        
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": savedRecId,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                        var delayInMilliseconds = 2000; //1 second
                        setTimeout(function() {
                            $A.get('e.force:refreshView').fire();
                        }, delayInMilliseconds); 
                        //location.reload(true);
                    }
                    
                    //var orderEntryObj = response.getReturnValue();
                    //if(orderEntryObj != null){
                    // component.set("v.orderEntry",orderEntryObj); 
                    
                }
                else{
                    alert('error'+state);
                    
                }
                
            });$A.enqueueAction(action);
        }
    },
    
    setValuesToFieldAmc : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedAMCName1 = component.get("v.selectedAMCName1"); 
        if(selectedAMCName1.label != null){
            orderEntry.AMC_Name__c = selectedAMCName1.label;
            component.set("v.orderEntry",orderEntry);
        }
        
    },
    
    setValuesToFieldScheme : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var selectedSchemeObj = component.get("v.selectedSchemeObj"); 
        if(selectedSchemeObj.label != null){
            orderEntry.Scheme__c = selectedSchemeObj.label;
            component.set("v.orderEntry",orderEntry);
        }
        /*ar orderEntry = component.get("v.orderEntry"); 
        if(orderEntry.Transaction_Type__c == 'Redemption')
        {
            var selectedClientAccountRecord = component.get("v.selectedClientAccountRecord");
            var selectedClientAccountId =   selectedClientAccountRecord.Id;
            if(selectedClientAccountId != null){
                var action = component.get("c.getSchemeNameRedemption");
                action.setParams({
                    "selectedClientAcc" : selectedClientAccountId
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listOfAsset = response.getReturnValue();
                        if(listOfAsset == null){
                            helper.showToast("Client Asset not available","Error");
                        }else{
                            component.set("v.filteredClientAssetListRedemption",listOfAsset); 
                        }
                    }
                });$A.enqueueAction(action);
            }
        }*/
    },
    setValuesToFieldFromScheme : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry"); 
        var selectedFromSchemeObj = component.get("v.selectedFromSchemeObj"); 
        if(selectedFromSchemeObj.label != null){
            orderEntry.From_Scheme__c = selectedFromSchemeObj.label;
            component.set("v.orderEntry",orderEntry);
            
        }
        
    },
    setValuesToFieldToScheme : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry"); 
        var selectedToSchemeObj = component.get("v.selectedToSchemeObj"); 
        if(selectedToSchemeObj.label != null){
            orderEntry.To_Scheme__c = selectedToSchemeObj.label;
            component.set("v.orderEntry",orderEntry);
        }
        
    },
    /*etValuesToFieldUCC : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");         
        var selectedClientPAN = component.get("v.selectedClientPAN"); 
        if(selectedClientPAN != null){
            // orderEntry.UCC__c = selectedClientPAN;
            component.set("v.orderEntry",orderEntry);
            
        }
        
    },*/
    setValuesToField : function(component, event, helper) {      
        var orderEntry = component.get("v.orderEntry");   
        var isValid = helper.validateSecondScreen(component, event, helper);
       //var isValid =1;
        if(isValid == 1){
            helper.setFamilyNameController(component, event, helper);
            helper.setClientNameController(component, event, helper);
            helper.setClientAccountNameController(component, event, helper);
            helper.setProductNameController(component, event, helper);
            helper.getAttachmentName(component, event, helper);
            
            component.set("v.isFirstScreen" , false);
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isPreviewScreen" , true); 
            component.set("v.isDisabled" , true);
            component.set("v.tooltip" , false);
            
            
            if(orderEntry.Redemption_Type__c == 'All Unit'&& orderEntry.Transaction_Type__c != 'Purchase'){
                component.set("v.isRedemAllUnit" , true);
                component.set("v.isPartialAmount" , false);
                component.set("v.isPartialUnit" , false);
                component.set("v.isPurchaseAmount" , false);
            }else if(orderEntry.Redemption_Type__c == 'Partial Amount' && orderEntry.Transaction_Type__c != 'Purchase'){
                component.set("v.isPartialAmount" , true);
                component.set("v.isPartialUnit" , false);
                component.set("v.isRedemAllUnit" , false);
                component.set("v.isPurchaseAmount" , false);
            }else if(orderEntry.Redemption_Type__c == 'Partial Unit' && orderEntry.Transaction_Type__c != 'Purchase'){
                component.set("v.isPartialUnit" , true);
                component.set("v.isPartialAmount" , false);
                component.set("v.isRedemAllUnit" , false);
                component.set("v.isPurchaseAmount" , false);
            }else if(orderEntry.Transaction_Type__c == 'Purchase'){
                component.set("v.isPurchaseAmount" , true);
                component.set("v.isPartialUnit" , false);
                component.set("v.isPartialAmount" , false);
                component.set("v.isRedemAllUnit" , false);
            }
                /*else if(orderEntry.Transaction_Type__c == 'Buy'){
                component.set("v.isBondBuy",true); 
                component.set("v.isBondSell",false);
            }else if(orderEntry.Transaction_Type__c == 'Sell'){
                component.set("v.isBondSell",true); 
                component.set("v.isBondBuy",false);
            } else if(orderEntry.Product_Type_Order_Entry__c == 'PMS'){
                component.set("v.isPMS",true);
                component.set("v.isPreviewScreen" , false); 
                component.set("v.isBondBuy",false);
            }   */ 
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
    handleMouseLeave : function(component, event, helper) {
        $A.util.addClass(component.find("divHelp"), 'slds-hide');
    },
    handleMouseEnter : function(component, event, helper) {
        
        $A.util.removeClass(component.find("divHelp"), 'slds-hide');
    },
    showToolTip1 : function(component, event, helper) {
        
        component.set("v.tooltip1" , true);
        
    },
    HideToolTip1 : function(component, event, helper){
        
        component.set("v.tooltip1" , false);
    },
   /* setValuesToBondField : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");
        var isValid = helper.validateSecondScreen(component, event, helper);
        if(isValid == 1){
            helper.setFamilyNameController(component, event, helper);
            helper.setClientNameController(component, event, helper);
            helper.setClientAccountNameController(component, event, helper);
            helper.setProductNameController(component, event, helper);
            
            helper.getAttachmentName(component, event, helper);
            if(orderEntry.Transaction_Type__c == 'Buy'){
                component.set("v.isBondBuy" , true);
                component.set("v.isBondSell" , false);
            } else if(orderEntry.Transaction_Type__c == 'Sell'){
                component.set("v.isBondBuy" , false);
                component.set("v.isBondSell" , true);
            }
            component.set("v.isBond" , false);
            //component.set("v.isBondPreviewScreen" , true); 
            component.set("v.isPreviewScreen" , true); 
            component.set("v.isDisabled" , true);
            // }
        }
    },*/
    handleRedemptionChange : function(component, event, helper){   
        var orderEntry = component.get("v.orderEntry");
        var isorderentrymf = component.get("v.isoderentryMF");
        var quantity;
        var totalAUA;
        var clientAssetList = component.get("v.clientAssetListPurchase");           
        var selectedPicklistValue = component.get("v.selectedFolioPurchase");  
        if(orderEntry.Folio__c == '-- None --' || orderEntry.Folio__c == ''){          
            helper.showToast("Please Select Folio ","Error");     
        } else {
            var folioByAPI =  component.get("v.folioByAPI"); 
            var HoldingInformationAPI =  component.get("v.HoldingInformationAPI"); 
            if(folioByAPI){
                var len = HoldingInformationAPI.length;
                quantity = 0;
                totalAUA = 0;
                for(var m=0 ; m < HoldingInformationAPI.length; m++){
                    if(HoldingInformationAPI[m].folio == orderEntry.Folio__c){
                        quantity = quantity + parseFloat(HoldingInformationAPI[m].quantity);                           
                        totalAUA = totalAUA + parseFloat(HoldingInformationAPI[m].amount);
                    }
                }
                
                if(orderEntry.Redemption_Type__c == 'All Unit'&& orderEntry.Transaction_Type__c != 'Purchase'){
                    if(quantity == 'undefined' || quantity == null){
                        orderEntry.Redemption_Units__c ='';
                    }else {
                        orderEntry.Redemption_Units__c = quantity.toString(); 
                    }
                    if(totalAUA == 'undefined' || totalAUA == null){
                        orderEntry.Transaction_Amount_Financial_Transaction__c ='';
                    }else{
                        orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                    component.set("v.isDisableTxnAmount",true);
                    component.set("v.isDisableRedemptionUnit",true);
                    
                }else if(orderEntry.Redemption_Type__c == 'Partial Amount' && orderEntry.Transaction_Type__c != 'Purchase'){
                    orderEntry.Redemption_Units__c = ''; 
                    if(totalAUA == 'undefined' || totalAUA == null){
                        orderEntry.Transaction_Amount_Financial_Transaction__c= '';                    
                    }else {
                        orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                    component.set("v.isDisableTxnAmount",false);
                    component.set("v.isDisableRedemptionUnit",true);
                    
                }else if(orderEntry.Redemption_Type__c == 'Partial Unit' && orderEntry.Transaction_Type__c != 'Purchase'){
                    if(quantity == 'undefined' || quantity == null){
                        orderEntry.Redemption_Units__c = '';
                    }else{
                        orderEntry.Redemption_Units__c = quantity.toString(); }
                    orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                    component.set("v.isDisableTxnAmount",true);
                    component.set("v.isDisableRedemptionUnit",false);
                    
                } else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                    
                    orderEntry.Redemption_Units__c = ''; 
                    orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                    component.set("v.isDisableTxnAmount",true);
                    component.set("v.isDisableRedemptionUnit",true);
                }
                component.set("v.orderEntry",orderEntry); 
            }
            else{
                var action = component.get("c.getAssetDetailsByFolio");
                action.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "productId" : orderEntry.Product_lookup__c,
                    "holdingType" : orderEntry.Client_Holding_and_Type__c,
                    "folioNumber" : orderEntry.Folio__c
                });                       
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var clientAssetList = response.getReturnValue();
                        if(clientAssetList == null){
                            helper.showToast("Client Asset not available","Error");
                        }else{ 
                            
                            var len = clientAssetList.length;
                            if(len > 1){
                                quantity = 0;
                                totalAUA = 0;
                                for(var m=0 ; m < clientAssetList.length; m++){
                                    if(clientAssetList[m].Folio_Number__c == orderEntry.Folio__c){
                                        quantity = quantity + clientAssetList[m].Quantity__c;                           
                                        totalAUA = totalAUA + clientAssetList[m].Total_AUM__c;
                                    }
                                }
                            }else {
                                for(var m=0 ; m < clientAssetList.length; m++){
                                    if(clientAssetList[m].Folio_Number__c == orderEntry.Folio__c){
                                        quantity = clientAssetList[m].Quantity__c;                           
                                        totalAUA = clientAssetList[m].Total_AUM__c;
                                    }
                                }
                            }
                            
                        }
                        if(!isorderentrymf)
                        {
                            if(orderEntry.Redemption_Type__c == 'All Unit'&& orderEntry.Transaction_Type__c != 'Purchase'){
                                if(quantity == 'undefined' || quantity == null){
                                    orderEntry.Redemption_Units__c ='';
                                }else {
                                    orderEntry.Redemption_Units__c = quantity.toString(); 
                                }
                                if(totalAUA == 'undefined' || totalAUA == null){
                                    orderEntry.Transaction_Amount_Financial_Transaction__c ='';
                                }else{
                                    orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }else if(orderEntry.Redemption_Type__c == 'Partial Amount' && orderEntry.Transaction_Type__c != 'Purchase'){
                                
                                orderEntry.Redemption_Units__c = ''; 
                                if(totalAUA == 'undefined' || totalAUA == null){
                                    orderEntry.Transaction_Amount_Financial_Transaction__c= '';                    
                                }else {
                                    orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                                component.set("v.isDisableTxnAmount",false);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }else if(orderEntry.Redemption_Type__c == 'Partial Unit' && orderEntry.Transaction_Type__c != 'Purchase'){
                                if(quantity == 'undefined' || quantity == null){
                                    orderEntry.Redemption_Units__c = '';
                                }else{
                                    orderEntry.Redemption_Units__c = quantity.toString(); }
                                orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",false);
                                
                            } else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                                
                                orderEntry.Redemption_Units__c = ''; 
                                orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }
                        }     
                    
                        if(isorderentrymf)
                        {
                            if(orderEntry.Redemption_Type__c == 'All Unit'&& orderEntry.Transaction_Type__c != 'Purchase'){
                                if(quantity == 'undefined' || quantity == null){
                                    orderEntry.Transaction_Unit__c ='';
                                }else {
                                    orderEntry.Transaction_Unit__c = quantity.toString(); 
                                }
                                if(totalAUA == 'undefined' || totalAUA == null){
                                    orderEntry.Transaction_Amount_Financial_Transaction__c ='';
                                }else{
                                    orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }else if(orderEntry.Redemption_Type__c == 'Partial Amount' && orderEntry.Transaction_Type__c != 'Purchase'){
                                
                                orderEntry.Transaction_Unit__c = ''; 
                                if(totalAUA == 'undefined' || totalAUA == null){
                                    orderEntry.Transaction_Amount_Financial_Transaction__c= '';                    
                                }else {
                                    orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();}
                                component.set("v.isDisableTxnAmount",false);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }else if(orderEntry.Redemption_Type__c == 'Partial Unit' && orderEntry.Transaction_Type__c != 'Purchase'){
                                if(quantity == 'undefined' || quantity == null){
                                    orderEntry.Transaction_Unit__c = '';
                                }else{
                                    orderEntry.Transaction_Unit__c = quantity.toString(); }
                                orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",false);
                                
                            } else if(orderEntry.Redemption_Type__c == 'None' || typeof orderEntry.Redemption_Type__c === 'undefined'){
                                
                                orderEntry.Transaction_Unit__c = ''; 
                                orderEntry.Transaction_Amount_Financial_Transaction__c = '';
                                component.set("v.isDisableTxnAmount",true);
                                component.set("v.isDisableRedemptionUnit",true);
                                
                            }
                        }
                    
                    
                    
                    
                    }

                    component.set("v.orderEntry",orderEntry); 
                    
                });$A.enqueueAction(action); 
            }  
        }    
    },    
    
  /*  setValuesToPMSField : function(component, event, helper) {
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
    }, */
   /* setFolioPMS : function(component, event, helper){
        var orderEntry = component.get("v.orderEntry");
        
        var selectedPicklistValue = component.get("v.selectedFolioPMS");               
        orderEntry.Folio__c = selectedPicklistValue;
        
        component.set("v.orderEntry",orderEntry); 
    },*/
    callApi : function(component, event, helper){
        helper.callAPiHelper(component, event, helper);
        
    },
    
      setTransactionMode : function(component, event, helper){
        var orderEntry = component.get("v.orderEntry"); 
        console.log("transaction mode :"+orderEntry.Transaction_Mode_new__c);
        
        if(orderEntry.Redemption_Type__c == 'All Unit')
        {
            component.set("v.isDisableTransactionUnit",true);  
            component.set("v.isDisableTransactionAmount",true); 
            
        }
        else if(orderEntry.Redemption_Type__c == 'Partial Unit') 
        {
            component.set("v.isDisableTransactionUnit",false);
            component.set("v.isDisableTransactionAmount",true); 
        }
        else if(orderEntry.Redemption_Type__c == 'Partial Amount') 	
        {
            component.set("v.isDisableTransactionUnit",true);
            component.set("v.isDisableTransactionAmount",false); 
        }
        
        console.log(component.get("v.isDisableTransactionUnit"));
        console.log(orderEntry.Redemption_Type__c);
    }
    
})