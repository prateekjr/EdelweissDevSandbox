({
	createCmp : function(cmp, event, helper) {
		var familyType = cmp.get("v.FamilyType");
        var fieldName = cmp.get("v.fieldName");
        var inputType = cmp.get("v.inputType");
        var testValue = cmp.get("v.value");
        if(fieldName == "AccountId" && inputType =='REFERENCE'){
            if(familyType['NewFamily']){
                cmp.set("v.label","Select Lead");
            }else if(familyType['NewClient']){
                cmp.set("v.label","Select Family");
            }else{
                cmp.set("v.label","Select Client");
            }
        }
        if(fieldName == "Client_Name__c"){
            if(familyType['NewFamily']){
                cmp.set("v.label","Additional Lead Name");
            }else if(familyType['NewClient']){
                cmp.set("v.label","Additional Client Name");
            }
        }
        var fieldName = cmp.get("v.fieldName");
        var isReadOnly = cmp.get("v.isReadOnly");
		var objectType = cmp.get("v.record").sobjectType;
        if(cmp.get("v.isFormula") || cmp.get("v.isEditable")){
            isReadOnly = true;
        }
        cmp.set("v.ReadOnlyAtPageLayout",false);
        var isRTF = cmp.get("v.isRTF");
		var maxLength = cmp.get("v.maxLength");

        if(inputType !='BOOLEAN'){ 
                var divCmp = cmp.find("elementDiv");
                var self=this;
                if(divCmp.isValid()){
                    if(inputType){
                        if(cmp.get("v.isFormula")){
                            self.createUnescapedHTML(cmp,divCmp,fieldName);
                        }else if(inputType =='STRING'){
                            self.createInputTextCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly);
                        }else if(inputType =='DECIMAL' || inputType =='DOUBLE' || inputType =='PERCENT'){
                            self.createNumberCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly , inputType);
                        }else if(inputType =='DATE'){
                           self.createDateCmp(cmp,divCmp,fieldName,'',isReadOnly);
                        }else if(inputType =='DATETIME'){
                            self.createDateTimeCmp(cmp,divCmp,fieldName,'',isReadOnly);
                        }else if(inputType =='CURRENCY'){
                            self.createCurrencyCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly);
                        }else if(inputType =='TEXTAREA'){
                            if(isRTF)
                            	self.createRichTextAreaCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly);
                            else
                            	self.createTextAreaCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly); 
                        }else if(inputType == 'PHONE'){
                       		self.createPhoneCmp(cmp,divCmp,fieldName,'',isReadOnly);		
                        }else if(inputType =='REFERENCE'){  
                            var lookupType = cmp.get("v.referenceObjName");
                   			self.createLookupCmp(cmp,divCmp,fieldName,'',lookupType,isReadOnly);
                        }else if(inputType =='PICKLIST'){
                            var optValues = cmp.get("v.pickListValues");
                            var isMultiSelect = false;	
                            self.createPickListCmp(cmp,divCmp,fieldName,'',optValues,isMultiSelect,isReadOnly);
                        }else if(inputType =='MULTIPICKLIST'){
                            var optValues = cmp.get("v.pickListValues");
                            var isMultiSelect = true;
                            self.createPickListCmp(cmp,divCmp,fieldName,'',optValues,isMultiSelect,isReadOnly);
                        }else if(inputType =='URL'){
                            self.createInputURLCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly);
                        }else if(inputType =='EMAIL'){                            
                            self.createInputEmailCmp(cmp,divCmp,fieldName,'',maxLength,isReadOnly);
                        }
                    }    
                }  
        }else{
            cmp.set("v.BooleanValue",cmp.get("v.record")[fieldName]); 
        }
		if(fieldName == 'DummyText__c'){
			var DummyComp = cmp.find("CreateFieldDiv");
			$A.util.addClass(DummyComp,'DummyClass');
		}
        if(isReadOnly){
            var cmpTarget = cmp.find("InputCreateFieldDiv");
            $A.util.addClass(cmpTarget,'MinHtCls');
            $A.util.addClass(cmpTarget,'slds-input-has-icon slds-input-has-icon--right');
            var elementDiv = cmp.find("elementDiv");
            $A.util.addClass(elementDiv,'InlineBlockDiv');
            $A.util.addClass(elementDiv,'rowPadding');
            var OtherInlineDiv = cmp.find("OtherInlineDiv");
            $A.util.addClass(OtherInlineDiv,'InlineBlockDiv');
            var BooleanInlineDiv = cmp.find("BooleanInlineDiv");
            $A.util.addClass(BooleanInlineDiv,'InlineBlockDiv');
         }
	},
     createInputURLCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        else{ 
			if(value.indexOf('http://') != 0 && value.indexOf('https://') != 0)
				value = 'http://'+value;
        }
        var ref = $A.createComponent(
            (isReadOnly ? "ui:outputURL" : "ui:inputURL"),
        	{   
        		"aura:id": qId,
        		"label": (isReadOnly ? value : ""),
                "maxlength":maxLen,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "required" : cmp.get("v.isRequired"),
                "target" : "_blank",
                "change":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createInputEmailCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
            (isReadOnly ? "ui:outputEmail" : "ui:inputEmail"),
        	{   
        		"aura:id": qId,
                "maxlength":maxLen,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "required" : cmp.get("v.isRequired"),
                "change":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createInputTextCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
            (isReadOnly ? "ui:outputText" : "ui:inputText"),
        	{   
        		"aura:id": qId,
                "maxlength":maxLen,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "required" : cmp.get("v.isRequired"),
                "change":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createUnescapedHTML: function(cmp,divCmp,qId){
       	var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
            "aura:unescapedHTML",
              {
                  "value" : value
              },
              function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
    },
    createPhoneCmp: function(cmp,divCmp,qId,qLabel,isReadOnly){
	  	var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
        	(isReadOnly ? "ui:outputPhone" : "ui:inputPhone"),
        	{
        		"aura:id": qId,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "required" : cmp.get("v.isRequired"),
                "change":cmp.getReference("c.handleValueChange")
                
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );    	
    },
    createCurrencyCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
        	(isReadOnly ? "ui:outputCurrency" : "ui:inputCurrency"),
        	{
        		"aura:id": qId,
                "maxlength":maxLen,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "format" :  '₹#,###',
                "required" : cmp.get("v.isRequired"),
                "blur":cmp.getReference("c.handleValueChange")
                
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createTextAreaCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
		(isReadOnly ? "ui:outputText" : "ui:inputTextArea"),
        	{
        		"aura:id": qId,
				"maxlength":maxLen,
                "rows":3,
                "class" : (isReadOnly ? "" : "slds-input"),
                "required" : cmp.get("v.isRequired"),
                "value" : value,
                "change":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createRichTextAreaCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var ref = $A.createComponent(
        	(isReadOnly ? "ui:outputRichText" : "ui:inputRichText"),
        	{
        		"aura:id": qId,
				"maxlength":maxLen,
                "rows":3,
                "value" : value,
                "class" : (isReadOnly ? "" : "slds-input"),
				"required" : cmp.get("v.isRequired"),
                "blur":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
                //$A.util.addClass(newCmp, 'form-control');
				self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
        
    },
    createNumberCmp: function(cmp,divCmp,qId,qLabel,maxLen,isReadOnly , inputType){
        var self=this;
        var value = cmp.get("v.record")[qId];
		if(cmp.get("v.DecimalDigits") == 0 && value != undefined && value != null){
        	value = Math.round(value);
        }
        
        if(value != undefined && value != null && isReadOnly && inputType == 'PERCENT'){
            value = value+'%';
        }
                
        if(value == undefined || value == null) value='';
        
        var tMap = self.tradingFieldMap();
        var isDisabled = false;
        
        console.log('Shailesh 2 --- ', cmp.get("v.isEnabledTradingFeilds"));
        
        if(qId in tMap && !cmp.get("v.isEnabledTradingFeilds")){
            isDisabled = true;
        }
        
        $A.createComponent(
			(isReadOnly ? "ui:outputNumber" : "ui:inputNumber"),
            {
                "aura:id": qId,
                "maxlength":maxLen,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
                "format" :  (cmp.get("v.DecimalDigits") == 0 ? '############' : '.00'),
				"required" : cmp.get("v.isRequired"),
                "blur":cmp.getReference("c.handleValueChange"),
                "disabled" : isDisabled
            },
            function(newCmp){
                //$A.util.addClass(newCmp, 'form-control');
                self.insertNewCmp(cmp,divCmp,newCmp);
                cmp.addEventHandler("c:TradingDefault", cmp.getReference("c.handleTradingEvent"));
            }
        );
    },
    createDateTimeCmp:function(cmp,divCmp,qId,qLabel,isReadOnly){
        var self=this;
		var today = new Date();
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        $A.createComponent(
        	(isReadOnly ? "ui:outputDateTime" : "ui:inputDateTime"),
        	{
        		"aura:id": qId,
                "displayDatePicker":true,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
				"required" : cmp.get("v.isRequired"),
                "blur":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
                //$A.util.addClass(newCmp, 'form-control');
                self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
    },
    createDateCmp:function(cmp,divCmp,qId,qLabel,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        $A.createComponent(
        	(isReadOnly ? "ui:outputDate" : "ui:inputDate"),
        	{
        		"aura:id": qId,
                "displayDatePicker":true,
                "class" : (isReadOnly ? "" : "slds-input"),
                "value" : value,
				"required" : cmp.get("v.isRequired"),
                "blur":cmp.getReference("c.handleValueChange")
            },
            function(newCmp){
                self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
    },
    createLookupCmp:function(cmp,divCmp,qId,qLabel,lookupType,isReadOnly){
        var isNewFamily = cmp.get("v.FamilyType");
        isReadOnly = (isNewFamily.NewFamily) ? true : false;
        var apiName = qId;
        var svgIconUrl = "/assets/icons/utility-sprite/svg/symbols.svg#"+lookupType.toLowerCase();
        if(lookupType.indexOf('__c') != -1){
            svgIconUrl = "/assets/icons/utility-sprite/svg/symbols.svg#custom37";
        }
        if(qId.indexOf('__c') != -1){
			apiName = apiName.replace('__c','__r');
        }
		else
			apiName = apiName.replace('Id','');	
        var fieldRef = cmp.get("v.record")[apiName];
        var value;
        if(lookupType == 'RecordType')
            isReadOnly = true;
        var RefId; 
        if(typeof(fieldRef) != 'undefined' || fieldRef != undefined) {            
            RefId = cmp.get("v.record")[apiName].Id;            
			value = cmp.get("v.record")[apiName].Name;
        }
        if(value == null) value='';
        var self=this;
        $A.createComponent(
           "c:LookupSObject",
        	{
                "fieldAPIName": qId,
        		"label": value,
                "pluralLabel" : qLabel,
                "sObjectAPIName":lookupType,	
                "instanceId" : qId,
                "selSearchString" : value,
                "value" : value,
				"required" : cmp.get("v.isRequired"),
                "listIconSVGPath" : svgIconUrl,
                "listIconClass" : "slds-icon-standard-account",
                "className" : (isReadOnly ? "" : "slds-input"),
				"RefId" : RefId,
				"isReadOnly": isReadOnly,
                "ChildObject":  cmp.get("v.record").sobjectType,
				"parentAccountId": cmp.get("v.parentAccountId"),
                "filter": cmp.get("v.lookupFilter")
            },
            function(newCmp){
                self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
    },
	createPickListCmp:function(cmp,divCmp,qId,qLabel,optValues,isMultiSelect,isReadOnly){
        var self=this;
        var value = cmp.get("v.record")[qId];
        if(value == null) value='';
        var opts;
        var optsCmpList = [];
        
        if(qId == 'Status' && (value == null || value == '')){
            value = 'Open';
        }
        
        if(optValues){
            if(optValues.indexOf('\n') != -1){
                opts = optValues.split('\n');
            }else{
                opts = optValues;
            }
            if(opts){
                optsCmpList.push({ label: '-None-', value: ''});
                opts.forEach(function(entry){
                    optsCmpList.push({ label: entry, value: entry});
                });
            }
        }
        $A.createComponent(
            (isReadOnly ? "ui:outputText" : "ui:inputSelect"),
        	{
                "aura:id": qId,
                "change":cmp.getReference("c.handleValueChange"),
                "multiple":isMultiSelect,
                "value" : value,
				"required" : cmp.get("v.isRequired"),
                "class" : (isReadOnly ? "" : isMultiSelect ? "slds-input MultiSelCls" : "slds-input")
            },
            function(newCmp){
				if(!isReadOnly)
					newCmp.set("v.options",optsCmpList);
                self.insertNewCmp(cmp,divCmp,newCmp);
            }
        );
    },
	
    insertNewCmp:function(cmp,divCmp,newCmp){
        var divBody = divCmp.get("v.body");
        divBody.push(newCmp);
        divCmp.set("v.body", divBody);
    },
    
    tradingFieldMap : function(){
        var map = new Object(); 
        map["Delivery_Slab__c"] = 0.50;
        map["Intraday_Slab__c"] = 0.05;
        map["Delivery_Minimum_P__c"] = 0.03;
        map["Intraday_Minimum_P__c"] = 0.01;
        map["Currency_Futures_Slab__c"] = 10.00;
        map["Currency_Options_Slab__c"] = 10.00;
        map["Currency_Futures_Minimum_P__c"] = 0.01;
        map["Currency_Options_Minimum_P__c"] = 0.01;
        map["Derivatives_Futures_Slab__c"] = 0.50;
        map["Derivatives_Options_Slab__c"] = 50.00;
        map["Derivatives_Futures_Minimum_P__c"] = 0.03;
        map["Derivatives_Options_Minimum_P__c"] = 0.01;
        return map;
    }    
    
})