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
                    component.set('v.columns', [
                        {label: 'ARN Number', fieldName: 'ARN', type: 'text'},
                        {label: 'Folio Number', fieldName: 'FolioNumber', type: 'text'},
                        {label: 'AvailableHoldings/Units', fieldName: 'AvailableHoldings', type: 'text'},
                        {label: 'Holding Mode', fieldName: 'HoldingMode', type: 'text'}]);
                    
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
		    helper.getFilteredFamilyRecords(component, event, helper);
                    console.log("transaction mode :"+orderEntry.Transaction_Mode_new__c);
                }
                
                //$A.get("e.force:closeQuickAction").fire();   
            } else{
                
            }
        });$A.enqueueAction(action1);        
    },
    /*familySelection : function(component, event, helper) {
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
        
    }, */
    transactionSelection : function(component, event, helper) {
        component.set("v.showAllScheme",false);
        var orderEntry = component.get("v.orderEntry");  
        console.log("orderEntry.Transaction_Type__c :"+orderEntry.Transaction_Type__c);
        console.log("isoderentryMF :"+component.get("v.isoderentryMF"));
        var isoderentryMF=component.get("v.isoderentryMF");

        if(orderEntry.Transaction_Type__c == 'Redemption'){
            orderEntry.Folio__c = '-- None --'; 
            orderEntry.To_Folio__c = '-- None --';
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",true);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
            component.set("v.isSIP",false);
            component.set("v.isSWP",false);
            component.set("v.isSTP",false);
        }else if(orderEntry.Transaction_Type__c == 'Switch'){
            orderEntry.Folio__c = '-- None --';
            orderEntry.To_Folio__c = '-- None --';
            component.set("v.isSwitch",true);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",false);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
            component.set("v.isSIP",false);
            component.set("v.isSWP",false);
            component.set("v.isSTP",false);
            
        }else if(orderEntry.Transaction_Type__c == 'Purchase'){
            orderEntry.Folio__c = 'New';
            orderEntry.To_Folio__c ='New';
            component.set("v.isSwitch",false);  
            component.set("v.isRedemption",false);  
            component.set("v.isPurchase",true);  
            component.set("v.isBondBuy",false);
            component.set("v.isBondSell",false);
            component.set("v.isSIP",false);
            component.set("v.isSWP",false);
            component.set("v.isSTP",false);
            
        }
            else if(orderEntry.Transaction_Type__c == 'SIP'){
                orderEntry.Folio__c = 'New';
                orderEntry.To_Folio__c ='New';
                component.set("v.isSwitch",false);  
                component.set("v.isRedemption",false);  
                component.set("v.isPurchase",false);  
                component.set("v.isBondBuy",false);
                component.set("v.isBondSell",false);
                component.set("v.isSIP",true);
                component.set("v.isSWP",false);
                component.set("v.isSTP",false);
            }
                else if(orderEntry.Transaction_Type__c == 'SWP'){
                    orderEntry.Folio__c = '-- None --';
                     orderEntry.To_Folio__c = '-- None --';
                    component.set("v.isSwitch",false);  
                    component.set("v.isRedemption",false);  
                    component.set("v.isPurchase",false);  
                    component.set("v.isBondBuy",false);
                    component.set("v.isBondSell",false);
                    component.set("v.isSIP",false);
                    component.set("v.isSWP",true);
                    component.set("v.isSTP",false);
                }
                    else if(orderEntry.Transaction_Type__c == 'STP'){
                        orderEntry.Folio__c = '-- None --';
                        orderEntry.To_Folio__c = '-- None --';
                        component.set("v.isSwitch",false);  
                        component.set("v.isRedemption",false);  
                        component.set("v.isPurchase",false);  
                        component.set("v.isBondBuy",false);
                        component.set("v.isBondSell",false);
                        component.set("v.isSIP",false);
                        component.set("v.isSWP",false);
                        component.set("v.isSTP",true);
                    }
        component.set("v.orderEntry",orderEntry); 
        
        if(isoderentryMF)
        {
            var amcLookupOrderEntry =component.find("amcLookupOrderEntry");
            amcLookupOrderEntry.clearMethod();
            if(orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP')
            {
                var schemeLookupOrderEntryPS =component.find("schemeLookupOrderEntryPS");
                schemeLookupOrderEntryPS.clearMethod();
            }
            else if(orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'SWP')
            {
                var schemeLookupOrderEntryRS =component.find("schemeLookupOrderEntryRS");
                schemeLookupOrderEntryRS.clearMethod();
            }
            else if(orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'STP')
            {
                var fromschemeLookupOrderEntrySS =component.find("fromschemeLookupOrderEntrySS");
                fromschemeLookupOrderEntrySS.clearMethod();
                var toschemeLookupOrderEntrySS =component.find("toschemeLookupOrderEntrySS");
                toschemeLookupOrderEntrySS.clearMethod();
            }
            
        }
        else{
            var amcLookupBSEStar =component.find("amcLookupBSEStar");
            amcLookupBSEStar.clearMethod();
            if(orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'Redemption')
            {
                var schemeLookupBSEStarPR =component.find("schemeLookupBSEStarPR");
                schemeLookupBSEStarPR.clearMethod();
            }
            else if(orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'Redemption')
            {
                var schemeLookupBSEStarPRe =component.find("schemeLookupBSEStarPRe");
                schemeLookupBSEStarPRe.clearMethod();
            }
            else if(orderEntry.Transaction_Type__c == 'Switch')
            {
                var fromschemeLookupSS =component.find("fromschemeLookupSS");
                fromschemeLookupSS.clearMethod();
                var toschemeLookupBSEStar =component.find("toschemeLookupBSEStar");
                toschemeLookupBSEStar.clearMethod(); 
                var fromschemeLookupBSEStarSS =component.find("fromschemeLookupBSEStarSS");
                fromschemeLookupBSEStarSS.clearMethod();
                
            }
        
        }
   
        component.set("v.selectedToSchemeObj",'');
        component.set("v.selectedFromSchemeObj",'');
        component.set("v.selectedSchemeObj",'');
        //component.set("v.selectedAMCName1",'');
    },
    
    clientAccountSelection : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");  
        var listOfAllClients = component.get("v.filteredClientList");
        var selectedClientRecord = component.get("v.selectedClientRecord");
        var selectedClientId = selectedClientRecord.Id;
        
        orderEntry.Client_Name__c =selectedClientId;
        component.set("v.orderEntry", orderEntry);
        //component.set("v.selectedAMCName1",'');
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
    
    onControllerFieldChange: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var  isoderentryMF = component.get("v.isoderentryMF"); 
        component.set("v.selectedAMCName1",'');
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            var orderEntry = component.get("v.orderEntry"); 
            if(controllerValueKey === 'MF'){
                component.set("v.showAmc" , true);                
                console.log('orderEntry.Family_Name__'+orderEntry.Family_Name__c);
                
                var actionmf = component.get("c.getClientInformationorderentery");
                actionmf.setParams({
                    "familyId" : orderEntry.Family_Name__c,
                    
                });                  
                
                actionmf.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        var isfound = response.getReturnValue();
                        
                        if(isfound){
                            component.set("v.isoderentryMF",true);
                     
                            console.log("isoderentryMF onchange :"+component.get("v.isoderentryMF"));
                            var listDependingValuesTemp = new Array();
                            var isorderentry = component.get("v.isoderentryMF");
                            listDependingValuesTemp = component.get("v.listDependingValues");  
                            console.log('listDependingValuesTemp :'+listDependingValuesTemp);
                            console.log('isoderentryMF New :'+isorderentry);
                            if(isorderentry){
                                
                                listDependingValuesTemp.push("SIP");  
                                listDependingValuesTemp.push('SWP'); 
                                listDependingValuesTemp.push('STP');
                                component.set("v.listDependingValues",listDependingValuesTemp);  
                            } 
               
                        } 
                        
                    }
                    
                });$A.enqueueAction(actionmf);
                
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
                        helper
                        .showToast("AMC Name Not Found","Error");
                    }else{
                        component.set("v.amcList",amcNameList);  
                    }
                }
                
            });$A.enqueueAction(action);
            
        }        
    },
    
    getFolioOnHolding : function(component, event, helper){
        
        var orderEntry = component.get("v.orderEntry");  
        var isorderentrymf = component.get("v.isoderentryMF");  
        if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
                         console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
                         console.log('orderEntry.AMC_Name__c :'+orderEntry.AMC_Name__c);
                         console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
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
                                                /* if(orderEntry.Folio__c == ''){
                                                     orderEntry.Folio__c = 'New';
                                                }*/
                                                
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
									console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Redemption_Type__c);
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
                                                component.set("v.clientAssetListPurchase",clientAssetList); 
                                                component.set("v.folioListPurchase",folioListOther); 
                                            }
                                           console.log("folioListOther :"+folioListOther); 
                                        }
                                    });$A.enqueueAction(action);         
                                    
            if(orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'STP')
            {
                var selectedToSchemeObjId = component.get("v.selectedToSchemeObj");
               // alert('To Folio selectedToSchemeObjId :'+JSON.stringify(selectedToSchemeObjId));
                console.log("clientAccountId OE :"+orderEntry.Client_Account__c); 
                console.log("productId OE :"+selectedToSchemeObjId.Id); 
                console.log("holdingType OE :"+orderEntry.Client_Holding_and_Type__c); 
                var folioListOtherToFolio = new Array();
                var actionToFolio = component.get("c.getFolioNumbers");
                actionToFolio.setParams({
                    "clientAccountId" : orderEntry.Client_Account__c,
                    "productId" : selectedToSchemeObjId.Id,
                    "holdingType" : orderEntry.Client_Holding_and_Type__c
                });                  
                actionToFolio.setCallback(this, function(response) {    
                    var state = response.getState();
                    console.log("state response :"+state);
                    if (state === "SUCCESS") {
                        var clientAssetList = response.getReturnValue();
                        if(clientAssetList == null){
                            folioListOtherToFolio.push('-- None --');
                            component.set("v.folioListToPurchase",folioListOther); 
                        }else{
                            folioListOtherToFolio.push('-- None --');
                            for(var m=0 ; m < clientAssetList.length; m++){
                                folioListOtherToFolio.push(clientAssetList[m].Folio_Number__c); 
                            }
                            component.set("v.clientAssetListPurchase",clientAssetList); 
                            component.set("v.folioListToPurchase",folioListOtherToFolio); 
                        }
                        console.log("folioListOtherToFolio :"+JSON.stringify(folioListOtherToFolio)); 
                    }
                });$A.enqueueAction(actionToFolio); 
            }
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
                        component.set("v.folioListPurchase",folioList); 
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
    },
    
    
    loadMainScreen: function(component, event, helper){
        component.set("v.folioByAPI",false); 
        var orderEntry = component.get("v.orderEntry");  
        var uccList = new Array();
        
        //validate 
        var isValid = helper.validateFirstScreen(component, event, helper);
        //var isValid=1;
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
            if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
                var isorderentrymf = component.get("v.isoderentryMF");
                if(isorderentrymf){
                    
                    
                    console.log('amc name value' + orderEntry.AMC_Name__c);
                    console.log('scheme name value' + orderEntry.Scheme__c);
                    console.log('from scheme value' + orderEntry.From_Scheme__c);
                    console.log('TO scheme value' + orderEntry.To_Scheme__c);
                }
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
                                uccList.push(listVal);
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
                component.set("v.orderEntry" , orderEntry);  
                var orderEntryObj = component.get("v.orderEntry");  
                var primaryFa = component.get("v.primaryFA");
                var action = component.get("c.getEuinDetails");
                action.setParams({
                    "faId": primaryFa,
                    "orderEntry" : orderEntry
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var euinObject = response.getReturnValue();
                        if(euinObject == ''){
                            //helper.showToast("UCC Not Found","Error");
                        }else{
                            orderEntryObj.EUIN__c = euinObject;
                            component.set("v.orderEntry" , orderEntryObj);  
                        }
                    }
                    
                });$A.enqueueAction(action);
                
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
                
                if(orderEntry.Transaction_Type__c == 'Switch'){
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
                                    helper.showToast("Client Asset not available 5","Error");
                                }else{
                                    component.set("v.filteredClientAssetListRedemption",listOfAsset); 
                                }
                            }
                        });$A.enqueueAction(action);
                    }     
                }         
                
                if(isorderentrymf)
                {
                    if(orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP' ||  orderEntry.Transaction_Type__c == 'SWP' || orderEntry.Transaction_Type__c == 'Redemption'  )
                    {
                        var selectedSchemeObj = component.get("v.selectedSchemeObj"); 
                       
                        orderEntry.Product_lookup__c= selectedSchemeObj.Id;
                         component.set("v.orderEntry",orderEntry);  
                        console.log("orderEntry.Product_lookup__c inside if :"+orderEntry.Product_lookup__c);
                    }
                    else if(orderEntry.Transaction_Type__c == 'Switch' || orderEntry.Transaction_Type__c == 'STP')
                    {
                        var selectedFromSchemeObj = component.get("v.selectedFromSchemeObj"); 
                         var selectedToSchemeObj = component.get("v.selectedToSchemeObj");  
                        orderEntry.Product_lookup__c= selectedFromSchemeObj.Id;
                        orderEntry.Product_Lookup_ToScheme__c= selectedToSchemeObj.Id;
                         component.set("v.orderEntry",orderEntry);  
                        
                        console.log("orderEntry.Product_lookup__c inside Else if :"+orderEntry.Product_lookup__c);
                        console.log("orderEntry.Product_Lookup_ToScheme__c inside Else if :"+orderEntry.Product_Lookup_ToScheme__c);
 					 
                    }
                    
                }
                
                
                   //Added By Prateek
                 	debugger;
                     if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'SIP') &&  isorderentrymf ){
                          var schemeSelected;
                         console.log('orderEntry.Client_Account__c :'+orderEntry.Client_Account__c);
                         console.log('orderEntry.AMC_Name__c :'+orderEntry.AMC_Name__c);
                         console.log('orderEntry.Client_Holding_and_Type__c :'+orderEntry.Client_Holding_and_Type__c);
                         
                         schemeSelected = orderEntry.Product_lookup__c;

                         console.log('schemeSelected :'+schemeSelected);
                         //get value for product risk profile prateek
                         var action1 = component.get("c.getProductDetailsFromMappingsOE");
                         action1.setParams({
                             "productid" : schemeSelected
                         });                  
                         action1.setCallback(this, function(response) {    
                             var state = response.getState();
                             if (state === "SUCCESS") {
                                 var productObj = response.getReturnValue();
                                 if(productObj == null){
                                     helper.showToast("Product Details not Found","Error");
                                 }else{
                                     orderEntry.Product_Risk_Profile_FinancialT__c = productObj.Risk_Profile_of_Product__c;
                                     //orderEntry.Product_lookup__c  = productObj.Id;
                                     component.set("v.orderEntry",orderEntry); 
                                     console.log('productObj record'+productObj);
                                     var arnList=[];
                                     if(productObj.SchemeType__c == 'Regular')
                                     {
                                         arnList.push('ARN-70892'); 
                                         orderEntry.ARN_Number__c = 'ARN-70892';
                                     }
                                     else if(productObj.SchemeType__c == 'Direct')
                                     {
                                         arnList.push('INA200014140'); 
                                         orderEntry.ARN_Number__c = 'INA200014140';
                                     }
                                     console.log('arnList :'+arnList);
                                     
                                     component.set("v.orderEntry",orderEntry);  
                                     component.set("v.ARNListToPurchase", arnList);
                                 }
                             }
                        });$A.enqueueAction(action1); 
                         
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
                                                /* if(orderEntry.Folio__c == ''){
                                                     orderEntry.Folio__c = 'New';
                                                }*/
                                                
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
                                     console.log('orderEntry.Redemption_Type__c :'+orderEntry.Redemption_Type__c);
                                      var schemeSelected;

                                     schemeSelected = orderEntry.Product_lookup__c;
                                     
                                     console.log('schemeSelected :'+schemeSelected);
                                     //get value for product risk profile prateek
                                     debugger;
                                     var action1 = component.get("c.getProductDetailsFromMappingsOE");
                                     action1.setParams({
                                         "productid" : schemeSelected
                                     });                  
                                     action1.setCallback(this, function(response) {    
                                         var state = response.getState();
                                         if (state === "SUCCESS") {
                                             var productObj = response.getReturnValue();
                                             if(productObj == null){
                                                 helper.showToast("Product Details not Found","Error");
                                             }else{
                                                 orderEntry.Product_Risk_Profile_FinancialT__c = productObj.Risk_Profile_of_Product__c;
                                                 //orderEntry.Product_lookup__c  = productObj.Id;
                                                 component.set("v.orderEntry",orderEntry);  
                                                 //component.get("productObj.Risk_Profile_of_Product__c"+productObj.Risk_Profile_of_Product__c);
                                                 var arnList=[];
                                                 if(productObj.SchemeType__c == 'Regular')
                                                 {
                                                     arnList.push('ARN-70892'); 
                                                     orderEntry.ARN_Number__c = 'ARN-70892';
                                                 }
                                                 else if(productObj.SchemeType__c == 'Direct')
                                                 {
                                                     arnList.push('INA200014140'); 
                                                     orderEntry.ARN_Number__c = 'INA200014140';
                                                 }
                                                 console.log('arnList :'+arnList);
                                                 
                                                 component.set("v.orderEntry",orderEntry);  
                                                 component.set("v.ARNListToPurchase", arnList);
                                             }
                                         }
                                     });$A.enqueueAction(action1); 
                                     
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
                                                component.set("v.clientAssetListPurchase",clientAssetList); 
                                                component.set("v.folioListPurchase",folioListOther); 
                                            }
                                           console.log("folioListOther :"+folioListOther); 
                                        }
                                    });$A.enqueueAction(action);      
                                     
                                     //Added By Prateek For To Folio 
                                     if(orderEntry.Transaction_Type__c == 'Switch'|| orderEntry.Transaction_Type__c == 'STP')
                                     {
                                         var selectedToSchemeObjId = component.get("v.selectedToSchemeObj");
                                        // alert('To Folio selectedToSchemeObjId :'+JSON.stringify(selectedToSchemeObjId));
                                         console.log("clientAccountId OE :"+orderEntry.Client_Account__c); 
                                         console.log("productId OE :"+selectedToSchemeObjId.Id); 
                                         console.log("holdingType OE :"+orderEntry.Client_Holding_and_Type__c); 
                                         var folioListOtherToFolio = new Array();
                                         var actionToFolio = component.get("c.getFolioNumbers");
                                         actionToFolio.setParams({
                                             "clientAccountId" : orderEntry.Client_Account__c,
                                             "productId" : selectedToSchemeObjId.Id,
                                             "holdingType" : orderEntry.Client_Holding_and_Type__c
                                         });                  
                                         actionToFolio.setCallback(this, function(response) {    
                                             var state = response.getState();
                                             console.log("state response :"+state);
                                             if (state === "SUCCESS") {
                                                 var clientAssetList = response.getReturnValue();
                                                 if(clientAssetList == null){
                                                     folioListOtherToFolio.push('-- None --');
                                                     component.set("v.folioListToPurchase",folioListOther); 
                                                 }else{
                                                     folioListOtherToFolio.push('-- None --');
                                                     for(var m=0 ; m < clientAssetList.length; m++){
                                                         folioListOtherToFolio.push(clientAssetList[m].Folio_Number__c); 
                                                     }
                                                     component.set("v.clientAssetListPurchase",clientAssetList); 
                                                     component.set("v.folioListToPurchase",folioListOtherToFolio); 
                                                 }
                                                 console.log("folioListOtherToFolio :"+JSON.stringify(folioListOtherToFolio)); 
                                             }
                                         });$A.enqueueAction(actionToFolio); 
                                     }  
                                    
                                }
                //Change start
                if((orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'Redemption' || orderEntry.Transaction_Type__c == 'Switch') && !isorderentrymf){
                    var schemeSelected;
                    /*Payment Type display on bases IAS POA*/
                    var action = component.get("c.getPMSAccountTYpe");
                    action.setParams({
                        "clientAccountId" : orderEntry.Client_Account__c,
                        
                    });                  
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.log("state response :"+state);
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
                    
                    
                    
                    if(orderEntry.Transaction_Type__c == 'Switch'){
                        schemeSelected = orderEntry.From_Scheme__c;
                    }else if (orderEntry.Transaction_Type__c == 'Purchase' || orderEntry.Transaction_Type__c == 'Redemption'){
                        schemeSelected = orderEntry.Scheme__c;
                    }
                    

                    debugger;
                    var action1 = component.get("c.getProductDetailsFromMappings");
                    action1.setParams({
                        "schemeName" : schemeSelected
                    });                  
                    action1.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var productObj = response.getReturnValue();
                            if(productObj == null){
                                helper.showToast("Product Details not Found","Error");
                            }else{
                                orderEntry.Product_Risk_Profile_FinancialT__c = productObj.Risk_Profile_of_Product__c;
                                orderEntry.Product_lookup__c  = productObj.Id;
                                component.set("v.orderEntry",orderEntry);  
                                
                                // Folio Number set Final for purchase
                                if(orderEntry.Transaction_Type__c == 'Purchase' ){
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
                                                /* if(orderEntry.Folio__c == ''){
                                                     orderEntry.Folio__c = 'New';
                                                }*/
                                                component.set("v.orderEntry",orderEntry); 
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
                            }
                        }else {
                            if(orderEntry.Transaction_Type__c == 'Purchase' ){
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
                                                component.set("v.orderEntry",orderEntry); 
                                                component.set("v.clientAssetListPurchase",clientAssetList); 
                                                component.set("v.folioListPurchase",folioList); 
                                            }
                                        }
                                    });$A.enqueueAction(action);
                                                
                                            }
                        }
                    });$A.enqueueAction(action1);
                }
                
                //Change start
                //Change End
                
                component.set("v.orderEntry",orderEntry);  
                component.set("v.isFirstScreen" , false); 
                component.set("v.isBond", false);
                component.set("v.loadPreviewScreen" , false); 
                component.set("v.isProuctTypeMF" , true);                
                component.set("v.isPreviewScreen" , false); 
                component.set("v.isDisabled" , true);
                component.set("v.isBondPreviewScreen",false);
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

         if(orderEntry.Product_Type_Order_Entry__c == 'MF') {
            component.set("v.isProuctTypeMF" , true);
            component.set("v.isBond" , false);      
            component.set("v.isPMS" , false); 
        } 

        component.set("v.isPreviewScreen" , false); 
        component.set("v.isDisabled" , true);
        
    },
        
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

    fetchClientHolding: function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry"); 
        var selectedUcc = component.get("v.selectedUcc"); 
        orderEntry.UCC_Holdings__c =  selectedUcc;
        if(selectedUcc.includes("-")){
            var indOf = selectedUcc.indexOf("-");
            var res = selectedUcc.substring(0, indOf);
            res = res.trim();
            selectedUcc = res;
        }
        
        var selectedFolio = component.get("v.selectedFolio"); 
        
        var selectedClientCode = component.get("v.selectedClientCode"); 
        orderEntry.UCC__c = selectedUcc;
        
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

                            var tooltip = 'Second  Applicant Name : '+bseobj.SECOND_APPLICANT_NAME__c + ' ,  ' +'Third Applicant Name : '+ bseobj.THIRD_APPLICANT_NAME__c + ' , '+'Client Nominee : '+bseobj.CLIENT_NOMINEE__c;
                            
                            orderEntryObj.CDSLCLTID__c = bseobj.CDSLCLTID__c;

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
        //Change End
    },
    setFolioPurchase : function(component, event, helper) {
        debugger;
        var orderEntry = component.get("v.orderEntry"); 
        //orderEntry.Folio__c = '';
        orderEntry.Redemption_Type__c = 'None';
        orderEntry.Transaction_Amount_Financial_Transaction__c = '';
        orderEntry.Redemption_Units__c = ''; 
        orderEntry.Transaction_Unit__c = '';
        var clientAssetList = component.get("v.clientAssetListPurchase"); 
        var selectedPicklistValue = component.get("v.selectedFolioPurchase");               
        orderEntry.Folio__c = selectedPicklistValue;	
        if((orderEntry.Folio__c != '') || (orderEntry.Folio__c != '-- None --')){
            for(var m=0 ; m < clientAssetList.length; m++){
                if(clientAssetList[m].Folio_Number__c == orderEntry.Folio__c){
                    var quantity = clientAssetList[m].Quantity__c;
                    //orderEntry.Redemption_Units__c = quantity.toString();
                    /*var totalAUA = clientAssetList[m].Total_AUM__c;
                    orderEntry.Transaction_Amount_Financial_Transaction__c = totalAUA.toString();*/
                }
            }
        }
        component.set("v.orderEntry",orderEntry); 
        
    },
    
        setARNPurchase : function(component, event, helper) {
        debugger;
        var orderEntry = component.get("v.orderEntry"); 
        var selectedPicklistValue = component.get("v.selectedARNPurchase");               
        orderEntry.ARN_Number__c = selectedPicklistValue;	

        component.set("v.orderEntry",orderEntry); 
        
    },
       setFolioToPurchase : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry"); 
        //orderEntry.Folio__c = '';
        orderEntry.Redemption_Type__c = 'None';
        orderEntry.Transaction_Amount_Financial_Transaction__c = '';
        orderEntry.Transaction_Unit__c = '';
        var clientAssetList = component.get("v.clientAssetListPurchase"); 
        var selectedPicklistValue = component.get("v.selectedFolioToPurchase");               
        orderEntry.To_Folio__c = selectedPicklistValue;	
        if((orderEntry.To_Folio__c != '') || (orderEntry.To_Folio__c != '-- None --')){
            for(var m=0 ; m < clientAssetList.length; m++){
                if(clientAssetList[m].Folio_Number__c == orderEntry.To_Folio__c){
                    var quantity = clientAssetList[m].Quantity__c;
                }
            }
        }
        component.set("v.orderEntry",orderEntry); 
           console.log('To_Folio__c :'+orderEntry.To_Folio__c);
    },
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 
        var orderEntry = component.get("v.orderEntry"); 
        if(orderEntry.Transaction_Type__c != 'Redemption' && orderEntry.Transaction_Type__c != 'Switch' &&
           orderEntry.Transaction_Type__c != 'Purchase' && orderEntry.Transaction_Type__c != 'SIP' &&  orderEntry.Transaction_Type__c != 'SWP' && orderEntry.Transaction_Type__c != 'STP')
        {
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            console.log('selectedAccountGetFromEvent :'+selectedAccountGetFromEvent);
            //component.set("v.selectedAMCName1" , selectedAccountGetFromEvent); 
        }
    },
    SaveRecord : function(component, event, helper) {        
        var orderEntry = component.get("v.orderEntry"); 
        /*Added for Compliance Screen validation MF reford Type*/   
        var isValid = helper.validateThirdScreen(component, event, helper);
        //var isValid=1;	
        if(isValid == 1){ 
            //debugger;
            var counter = component.get("v.cutoffCounter");
            var schemeNamecutoff;
            if(orderEntry.Transaction_Type__c == 'Switch'){
                
                schemeNamecutoff = orderEntry.From_Scheme__c
            }else{                
                schemeNamecutoff = orderEntry.Scheme__c
            }            
            var action = component.get("c.checkCuttOffTime");
            action.setParams({
                "schemeName" : schemeNamecutoff
            });                     
            action.setCallback(this, function(response) {    
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var cuttOffFlag = response.getReturnValue();
                    if(cuttOffFlag === 1){
                        helper.saveObjRecord(component, event, helper);
                    }else if(cuttOffFlag === 0){
                        
                        var msg ='Your order will not be eligible for previous day NAV';
                        
                        if(counter === 0 ){
                            
                            component.set("v.cutoffCounter", 1);
                            component.set("v.isPreviewScreen",false);
                            component.set("v.ShowModule",true);
                            
                        }else if(counter === 1){
                            helper.saveObjRecord(component, event, helper);
                        }                        
                    }if(cuttOffFlag === -1){                        
                        helper.showToast("You cannot place order during hard cutOff time","Error");
                        var delayInMilliseconds = 2000; //1 second
                        setTimeout(function() {
                            //$A.get('e.force:refreshView').fire();
                        }, delayInMilliseconds); 
                    }
                }
            });$A.enqueueAction(action);
            
            
        }
    },
    // MF Order Entry Changes
    setValuesToFieldAmc : function(component, event, helper) {
        debugger;
        var orderEntry = component.get("v.orderEntry"); 
        var selectedAMCName1 = component.get("v.selectedAMCName1"); 
        var isorderentryMF = component.get("v.isoderentryMF");
        if(selectedAMCName1.label != ''){
            orderEntry.AMC_Name__c = selectedAMCName1.label;
            //component.set("v.orderEntry",orderEntry);
        }
         else
        {
            orderEntry.AMC_Name__c = selectedAMCName1.label;
        }
        component.set("v.orderEntry",orderEntry);
        
        
        
        if(typeof selectedAMCName1.label != 'undefined'){
            if((orderEntry.Transaction_Type__c == 'SIP' || orderEntry.Transaction_Type__c == 'Purchase') && isorderentryMF){
                var action = component.get("c.getProductListMFOrderEntry");
                action.setParams({
                    "selectedAMC" : selectedAMCName1.label
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listOfProduct = response.getReturnValue();
                        if(listOfProduct == null){
                            alert('error');
                        }else{
                            component.set("v.filteredProductMfOrderEntry",listOfProduct); 
                        }
                    }
                });$A.enqueueAction(action); 
            }else if((orderEntry.Transaction_Type__c == 'SWP'|| orderEntry.Transaction_Type__c == 'STP' || orderEntry.Transaction_Type__c == 'Redemption' ||  orderEntry.Transaction_Type__c == 'Switch') && isorderentryMF){
                var action = component.get("c.getProductListMFOrderEntryRedemptionSwitch");
                action.setParams({
                    "selectedAMC" : selectedAMCName1.label,
                    "selectedClientAccount" : orderEntry.Client_Account__c
                });                  
                action.setCallback(this, function(response) {    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listOfProduct = response.getReturnValue();
                        if(listOfProduct == null){
                            alert('error');
                        }else{
                            component.set("v.filteredProductMFOrderEntryRedemptionSwitch",listOfProduct); 
                        }             
                    }
                });$A.enqueueAction(action);  
            }
            
        }
    },
    
    // MF Order Entry Changes
    setValuesToFieldScheme : function(component, event, helper) {
        debugger;
        var orderEntry = component.get("v.orderEntry"); 
        var selectedSchemeObj = component.get("v.selectedSchemeObj"); 
        var isoderentryMF = component.get("v.isoderentryMF"); 
        if(isoderentryMF){
            if(selectedSchemeObj.Name != null){
                orderEntry.Scheme__c = selectedSchemeObj.Name;
                // component.set("v.orderEntry",orderEntry);
            }else{
                orderEntry.Scheme__c = '';
            }
            component.set("v.orderEntry",orderEntry);
        }
        else {
            if(selectedSchemeObj.label != ''){
                orderEntry.Scheme__c = selectedSchemeObj.label;
                // component.set("v.orderEntry",orderEntry);
            }else{
                orderEntry.Scheme__c = '';
            }
            component.set("v.orderEntry",orderEntry);
            
        }
    },
    // MF Order Entry Changes
    setValuesToFieldFromScheme : function(component, event, helper) {
        debugger;
        var orderEntry = component.get("v.orderEntry"); 
        var selectedFromSchemeObj = component.get("v.selectedFromSchemeObj"); 
        var isoderentryMF = component.get("v.isoderentryMF"); 
        if(isoderentryMF){
            if(selectedFromSchemeObj.Name != null){
                orderEntry.From_Scheme__c = selectedFromSchemeObj.Name;
                component.set("v.orderEntry",orderEntry);
                
                
                var orderEntry = component.get("v.orderEntry"); 
                var selectedAMCName1 = component.get("v.selectedAMCName1"); 
                if(orderEntry.Transaction_Type__c == 'STP' || orderEntry.Transaction_Type__c == 'Switch' ) {
                    var action = component.get("c.getProductListToSchemeSwitch");
                    action.setParams({
                        "selectedAMC" : selectedAMCName1.label,
                        "selectedFromScheme" : selectedFromSchemeObj.Id
                    });                  
                    action.setCallback(this, function(response) {    
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var listOfProduct = response.getReturnValue();
                            if(listOfProduct == ''){
                                alert('error');
                            }else{
                                component.set("v.filteredProductToSchemeSwitch",listOfProduct); 
                            }             
                        }
                        console.log('listOfProduct from scheme:'+JSON.stringify(listOfProduct));
                    });$A.enqueueAction(action);
                }
                
            }
        }else{
            if(selectedFromSchemeObj.label != null){
                orderEntry.From_Scheme__c = selectedFromSchemeObj.label;
            }   
             else
            {
                orderEntry.From_Scheme__c = selectedFromSchemeObj.Name;
            }
                            component.set("v.orderEntry",orderEntry);

        }
        
    },
    // MF Order Entry Changes
    setValuesToFieldToScheme : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry"); 
        var selectedToSchemeObj = component.get("v.selectedToSchemeObj"); 
        var isoderentryMF = component.get("v.isoderentryMF"); 
        if(isoderentryMF){
            if(selectedToSchemeObj.Name != null){
                orderEntry.To_Scheme__c = selectedToSchemeObj.Name;
                // alert(orderEntry.To_Scheme__c);
                component.set("v.orderEntry",orderEntry);
                
            }
        } else {
            if(selectedToSchemeObj.label != ''){
                orderEntry.To_Scheme__c = selectedToSchemeObj.label;
            }
            else
            {
                orderEntry.To_Scheme__c = selectedToSchemeObj.Name;
            }
             component.set("v.orderEntry",orderEntry);
        }
        
    },
    setValuesToField : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");   
        console.log('orderEntry.Product_Type_Order_Entry__c setValuesToField:'+orderEntry.Product_Type_Order_Entry__c);
        console.log('orderEntry.Transaction_Type__c setValuesToField:'+orderEntry.Transaction_Type__c);
        var isValid = helper.validateSecondScreen(component, event, helper);
        //var isValid=1;
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
            
            if(orderEntry.Redemption_Type__c == 'All Unit'&& orderEntry.Transaction_Type__c != 'Purchase'){
                component.set("v.isRedemAllUnit" , true);
                component.set("v.isPartialAmount" , false);
                component.set("v.isPartialUnit" , false);
                component.set("v.isPurchaseAmount" , false);
                
                //orderEntry.Folio__c = '';                
                
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
            
        }
    },
    
    /* Methods for file attachemnet start */
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        console.log("File Name :"+fileName);
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
    setValueToInstrument : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry");
        var selectedInstrumentName = component.get("v.selectedInstrument");             
        if(selectedInstrumentName.label != null){
            orderEntry.Instrument_Name_Display__c = selectedInstrumentName.label;
            
            component.set("v.orderEntry",orderEntry);
        }       
    },
    HideToolTip1 : function(component, event, helper){
        
        component.set("v.tooltip1" , false);
    },
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
    okClick : function(component, event, helper){        
        component.set("v.ShowModule",false);
        component.set("v.isPreviewScreen",true);
        
    },
    callApi : function(component, event, helper){
        helper.callAPiHelper(component, event, helper);
        
    },
    callApiforoderentryMF : function(component, event, helper){
        helper.callApiforoderentryMFHelper(component, event, helper);
        
    },
    
    getAllScheme : function(component, event, helper){
        component.set("v.showAllScheme",true);
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
    },
    callApirefresh: function(component, event, helper){
        alert('Fetching Drawdown Details');
          
        helper.callAPirefreshHELPER(component, event, helper);
      
        
    },
    
         showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
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
    
})