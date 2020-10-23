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
                    component.set("v.selectedIPOName",'');
                    
                    // get the fields API name and pass it to helper function  
                    var controllingFieldAPI = component.get("v.controllingFieldAPI");
                    var dependingFieldAPI = component.get("v.dependingFieldAPI");
                    var objDetails = component.get("v.objDetail");
                    // call the helper function
                    helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);   
                    helper.getFilteredFamilyRecords(component, event, helper);
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
        var ipoNameLookup =component.find("ipoNameLookup");
        ipoNameLookup.clearMethod();
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
                 if(orderEntry.Product_Type_Order_Entry__c === 'IPO'){
                    component.set("v.isIPO", true);
                    component.set("v.isPMS", false);
                    component.set("v.isProuctTypeMF" , false);
                    component.set("v.isBond" , false);  
                    component.set("v.isFirstScreen" , false);
                     var orderEntryObj = component.get("v.orderEntry");
                    if(orderEntry.Transaction_Type__c == 'Equity IPO')
                    {
                        component.set("v.isIPOBondPriceDisable",true);
                    }
                    
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

        if(orderEntry.Product_Type_Order_Entry__c == 'IPO') {
            component.set("v.isProuctTypeMF" , false);
            component.set("v.isBond" , false);      
            component.set("v.isIPO" , true); 
             component.set("v.isPMS" , false); 
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
         component.set("v.isIPO" , false);
        
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
             component.set("v.isIPO" , false);

            if(orderEntry.Product_Type_Order_Entry__c == 'IPO')
            {
                component.set("v.isIPOShow" , true);  
                component.set("v.isPurchaseAmount" , false);
                component.set("v.isPartialUnit" , false);
                component.set("v.isPartialAmount" , false);
                component.set("v.isRedemAllUnit" , false);
                component.set("v.isBondSell",false); 
                component.set("v.isBondBuy",false);
            }
            
            
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
    
    setValueToIPOName : function(component, event, helper) {
        
        var orderEntry = component.get("v.orderEntry");
        var selectedIPOName = component.get("v.selectedIPOName");             
        if(selectedIPOName.label != null){
           orderEntry.IPO_Name__c = selectedIPOName.label;
        var action = component.get("c.setIPOCode");
        action.setParams({
            "IPOName" : selectedIPOName.label
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    orderEntry.IPO_Code__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                }
            }
            
        });$A.enqueueAction(action);
        } else {
            orderEntry.IPO_Name__c = '';
        }  
    },

    /* PMS Ends */
    HideToolTip1 : function(component, event, helper){
        
        component.set("v.tooltip1" , false);
    },
    handleFaveValueChange: function(component, event, helper){        
        var orderEntry = component.get("v.orderEntry");  
        orderEntry.Price_new__c = '';
        component.set("v.orderEntry",orderEntry); 
        component.set("v.isIPOBondPriceDisable",true);
         component.set("v.isIPOBondFaceValueDisable",false);
        if(orderEntry.of_Facevalue__c == '')
        {
            component.set("v.isIPOBondPriceDisable",false);
            component.set("v.isIPOBondFaceValueDisable",false); 
        }
    },
    
      handlePriceChange: function(component, event, helper){          
          var orderEntry = component.get("v.orderEntry");  
          orderEntry.of_Facevalue__c = '';
          component.set("v.orderEntry",orderEntry); 
          component.set("v.isIPOBondPriceDisable",false);
          component.set("v.isIPOBondFaceValueDisable",true);
          if(orderEntry.Price_new__c == '')
          {
              component.set("v.isIPOBondPriceDisable",false);
              component.set("v.isIPOBondFaceValueDisable",false); 
          }
    }, 
    handleAmountChange: function(component, event, helper){
        var orderEntry = component.get("v.orderEntry");  
        orderEntry.No_of_units__c == '';
        component.set("v.orderEntry",orderEntry); 
        component.set("v.isIPOBondAmountDisable",false);
         component.set("v.isIPOBondUnitDisable",true);
        if(orderEntry.Transaction_Amount_Financial_Transaction__c == '')
        {
            component.set("v.isIPOBondAmountDisable",false);
            component.set("v.isIPOBondUnitDisable",false); 
        }
    },
    
      handleUnitChange: function(component, event, helper){
          var orderEntry = component.get("v.orderEntry");  
          orderEntry.Transaction_Amount_Financial_Transaction__c == '';
          component.set("v.orderEntry",orderEntry); 
          component.set("v.isIPOBondAmountDisable",true);
          component.set("v.isIPOBondUnitDisable",false);
          if(orderEntry.No_of_units__c == '')
          {
              component.set("v.isIPOBondAmountDisable",false);
              component.set("v.isIPOBondUnitDisable",false); 
          }
    },
    
 handleCutOffChange: function(component, event, helper){
     debugger;   
     var orderEntry = component.get("v.orderEntry");  
        if(orderEntry.Cut_Off_Price__c == 'Yes')
        {			            
            orderEntry.of_Facevalue__c = '';
            orderEntry.Price_new__c = '';
            component.set("v.isIPOBondPriceDisable",true);
            component.set("v.isIPOBondFaceValueDisable",true);  
            component.set("v.orderEntry",orderEntry);            
            
        }
        else if(orderEntry.Cut_Off_Price__c == 'No')
        {
            component.set("v.isIPOBondPriceDisable",false);
            component.set("v.isIPOBondFaceValueDisable",false);  
        }
         
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