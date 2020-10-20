({
    showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    
    validateFirstScreen : function(component, event, helper) {
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry");  

        if(orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){            
            if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
            else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                isvalid = 0;
                
                helper.showToast("Please Select Product Type","Error");
            }else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){            
                isvalid = 0;
                helper.showToast("Please Select Transaction Type","Error");
            }else if(orderEntry.Security_Name_Display__c == '' || typeof orderEntry.Security_Name_Display__c === 'undefined' || orderEntry.Security_Name_Display__c == '--- None ---'){              
                isvalid = 0;
                helper.showToast("Please Select Security Name","Error");
            }
            return isvalid;
        }
        else{
            if (orderEntry.Family_Name__c == '' || typeof orderEntry.Family_Name__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Family Name","Error");
            } else if (orderEntry.Client_Name__c == '' || typeof  orderEntry.Client_Name__c === 'undefined') {                
                isvalid = 0;
                helper.showToast("Please Select Client Name","Error");
            } else if (typeof orderEntry.Client_Account__c === 'undefined') {
                isvalid = 0;
                helper.showToast("Please Select Account Name","Error");
            }
                else if(orderEntry.Product_Type_Order_Entry__c == '' || orderEntry.Product_Type_Order_Entry__c == '--- None ---'){
                    isvalid = 0;
                    helper.showToast("Please Select Product Type","Error");
                }
                    else if(orderEntry.Transaction_Type__c == '' || orderEntry.Transaction_Type__c == '--- None ---'){
                        isvalid = 0;
                        helper.showToast("Please Select Transaction Type","Error");
                    }
            return isvalid;
        }
        
    },
    validateSecondScreen : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry");

        if (orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){
            debugger;
            isvalid = helper.validateSecondScreenCommon(component, event, helper);
            if(isvalid == 1){                  
                if(orderEntry.Transaction_Type__c == 'Log Commitment' ){
                    if (typeof orderEntry.Commitment_Amount__c  === 'undefined' || orderEntry.Commitment_Amount__c == '' || orderEntry.Commitment_Amount__c == null) {
                        helper.showToast("Please Enter Commitment Amount","Error");
                        isvalid = 0;
                        
                    } 
                }
                if(orderEntry.Transaction_Type__c == 'Log Drawdown' || orderEntry.Transaction_Type__c == 'Withdrawal' ){
                    if (typeof orderEntry.Transaction_Amount_Financial_Transaction__c  === 'undefined' || typeof orderEntry.Transaction_Amount_Financial_Transaction__c == '' || orderEntry.Transaction_Amount_Financial_Transaction__c == null) {
                        helper.showToast("Please Enter Transaction Amount","Error");
                        return isvalid = 0;                        
                    } 
                }
            }
            return isvalid;
        } else{       
           
            isvalid = 0;
            helper.showToast("Please Select All Values To Proceed","Error");
        }
        return isvalid;
    },
    
    validateThirdScreen : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
        
        if (typeof orderEntry.AttachmentId__c  === 'undefined' || typeof orderEntry.AttachmentId__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Attachement","Error");
        }
        else if (typeof orderEntry.Primary_FA__c  === 'undefined' || typeof orderEntry.Primary_FA__c == '') {
            isvalid = 0;
            helper.showToast("Please Select Primary FA","Error");
        }
        return isvalid;        
    },
    
    validateSecondScreenCommon : function(component, event, helper) {
        
        var isvalid = 1;
        var orderEntry = component.get("v.orderEntry"); 
        if (orderEntry.Product_Type_Order_Entry__c != 'PMS' && orderEntry.Product_Type_Order_Entry__c != 'PE / AIF'){
                 if (typeof orderEntry.POA_Non_POA__c  === 'undefined' ||  orderEntry.POA_Non_POA__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Execution Channel","Error");
            }else if (typeof orderEntry.Origin__c  === 'undefined' || typeof orderEntry.Origin__c == '') {
                isvalid = 0;
                helper.showToast("Please Select Communication Mode","Error");
            }
        	 return isvalid;
        }                  
        return isvalid;
        
    },
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
    
    
    setFamilyNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setFamilyName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    orderEntry.Family_Name_Display__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
    },
    setClientNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setClientName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){                    
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    setClientAccountNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setClientAccountName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {               
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    var tmp = orderEntryObj.split(" ");
					//orderEntryObj = tmp[0] + " " + tmp[tmp.length-1]; 
                    component.set("v.accountNameDisplay", tmp[0] + " " + tmp[tmp.length-1]);
                    orderEntry.Client_Account_Display__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    
    setProductNameController : function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry"); 
        var action = component.get("c.setProductName");
        action.setParams({
            "orderEntryObj" : orderEntry
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderEntryObj = response.getReturnValue();
                if(orderEntryObj != null){
                    orderEntry.Scheme_Name__c = orderEntryObj;
                    component.set("v.orderEntry",orderEntry); 
                    
                }
            }
            
        });$A.enqueueAction(action);
        
    },
    
    doSave: function(component, event, helper) {
        var orderEntry = component.get("v.orderEntry");
        
        if(orderEntry.Product_Type_Order_Entry__c == 'MF'){
        
            var fileInput = component.find("fileMF").get("v.files");
            if (fileInput.length > 0) {
                helper.uploadHelper(component, event,fileInput);
            } else {
                alert('Please Select a Valid File');
            }
        } else if (orderEntry.Product_Type_Order_Entry__c == 'Bond' || orderEntry.Product_Type_Order_Entry__c == 'SP' || orderEntry.Product_Type_Order_Entry__c === 'CP' || orderEntry.Product_Type_Order_Entry__c === 'CD' || orderEntry.Product_Type_Order_Entry__c === 'FD' || orderEntry.Product_Type_Order_Entry__c === 'ICD' ){            
            var fileInput = component.find("fileBond").get("v.files");
            if (fileInput.length > 0) {
                helper.uploadHelper(component, event,fileInput);
        } else {
            alert('Please Select a Valid File');
        }
        }else if (orderEntry.Product_Type_Order_Entry__c == 'PMS' || orderEntry.Product_Type_Order_Entry__c == 'PE / AIF'){            
            var fileInput = component.find("fileUpload").get("v.files");
            if (fileInput.length > 0) {
                helper.uploadHelper(component, event,fileInput);
        } else {
            alert('Please Select a Valid File');
        }
        }
    },
    /*Code for file attachment start */
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event,fileInput) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var orderEntry = component.get("v.orderEntry"); 
        component.set("v.attachmentName",file.name);
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            orderEntry.AttachmentId__c = attachId;           
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "File uploaded successfully.",
                        'type': 'success'
                    });
                    toastEvent.fire();
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    /* Code for file attachment ends*/
    
    saveObjRecord: function(component, event, helper){
    	var orderEntry = component.get("v.orderEntry");      
    	orderEntry.sobjectType='Order_Entry__c';
        var action = component.get("c.saveObj");
        action.setParams({
            "orderEntryObj" : orderEntry,
            "isoderentryMF" : false 
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();       		
            if (state === "SUCCESS") {
                var savedRecId = response.getReturnValue();
                if(savedRecId.includes('Error')){
                    helper.showToast(savedRecId,"Error");
                } else {
                helper.showToast("Order Saved Successfully","Success");
                var delayInMilliseconds = 2000; //1 second
                setTimeout(function() {
                    $A.get('e.force:refreshView').fire();
                }, delayInMilliseconds); 
                
                var navEvt = $A.get("e.force:navigateToSObject");
                //Added Rasika To need to uncomment
                component.set("v.isPreviewScreen",false);
                navEvt.setParams({
                    "recordId": savedRecId,
                    "slideDevName": "related"
                });
                navEvt.fire();    
                }
            }
            else{
                alert('error'+state);
            }
            
        });$A.enqueueAction(action);
	},
    currentTime: function(component, event, helper){      
        var action = component.get("c.getCurrentTime");
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var time = response.getReturnValue();
            }
        });$A.enqueueAction(action);
    },
   getFilteredFamilyRecords: function(component, event, helper){      
        var action = component.get("c.getFilteredFamilyRecords");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var listOfAllFamilies = response.getReturnValue();
                if(listOfAllFamilies == null){
                    helper.showToast("Family not Found","Error");
                }else{                    
                    component.set("v.filteredFamilyList",listOfAllFamilies);
                    console.log('filteredFamilyList :'+JSON.stringify(component.get("v.filteredFamilyList")));
                }
            }
        });$A.enqueueAction(action);
    },
    loadPE: function(component, event, helper){       
        var orderEntry = component.get("v.orderEntry");  
        var uccList = new Array();
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
            "faId": primaryFa
        });                  
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {
                var euinObject = response.getReturnValue();
                if(euinObject == null){
                    //helper.showToast("UCC Not Found","Error");
                }else{
                    orderEntryObj.EUIN__c = euinObject.EMP_Code__c;
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
        component.set("v.orderEntry",orderEntry);  
        component.set("v.isFirstScreen" , false); 
        component.set("v.isProuctTypeMF" , false);     
        component.set("v.isDisabled" , true);
        component.set("v.isBondPreviewScreen",false);
        component.set("v.isPE",true);
        
        var productName = orderEntry.Security_Name_Display__c;                
        //var productCode = productName.split('-').pop();        
        var orderEntry = component.get("v.orderEntry"); 
        //var clientAccountId = orderEntry.Client_Account__c;
        var action1 = component.get("c.fetchProductRiskonProductName");
        action1.setParams({
            "prodName" : productName                        
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
    },
    
    callAPiDrawdownData: function(component, event, helper){      
        debugger;
        var orderEntry = component.get("v.orderEntry" );
        
        var drawdownList = new Array();
       
        console.log('order transection type :'+orderEntry);
        
        var action = component.get("c.getDrawdownData");
        action.setParams({
            "orderEntryObj": orderEntry
            
        });
       
        // Add Parameter for Order Id
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.isFetchDetails" , true);
                console.log('isFetchDetails :'+component.get("v.isFetchDetails" ));
                
                console.log('response.getReturnValue().DrawdownDataList :'+ response.getReturnValue());
                component.set("v.showTable", true);
                var returnstring = response.getReturnValue();
                component.set("v.mydata", returnstring);
                
                console.log('Table Data :'+component.get("v.mydata" ));
                console.log('response.getReturnValue(). stringify :'+JSON.stringify(returnstring)); 
            }
            else
            {
                component.set("v.isFetchDetails" , true);
                  helper.showToast("No Data Found !!!","Error");
            }
        });$A.enqueueAction(action);
        
    },
    setValueToProductType: function(component, event, helper){     
        var orderEntry = component.get("v.orderEntry");
        orderEntry.Product_Type_Order_Entry__c = 'PE / AIF';
        component.set("v.orderEntry",orderEntry);
        var controllerValueKey = 'PE / AIF';
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        component.set("v.selectedAMCName1",'');
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            component.set("v.showSecurityName",true);       

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
        
    }, 
})