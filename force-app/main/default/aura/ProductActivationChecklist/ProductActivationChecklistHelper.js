({
	getProduct : function(component, event, helper){    	
        var action = component.get("c.getProduct");
        var productId = component.get("v.recordId")
        action.setParams({ productId : productId });        
        action.setCallback(this, function(response){           
            if(response.getReturnValue() != null){               
                component.set("v.productRecord", response.getReturnValue());
				helper.getFieldSetNameList(component, event, helper);                 
            }          
        }); 
        $A.enqueueAction(action);
        
	},getFieldSetNameList : function (component, event, helper){
        var self = this;
        var action = component.get("c.getChecklistFieldSetList");
        action.setParams({ productId : component.get("v.recordId") });
        action.setCallback(this, function(a){          
            if(a.getReturnValue() != null){
                if(a.getReturnValue() == 'No Data'){
                    component.set("v.isNoData", true);
                }else{
                   	component.set("v.FieldSetNameList", a.getReturnValue());
            		component.set("v.isRerender", true);  
                }                               
            }            
        });
        $A.enqueueAction(action);
    },RefreshInterval : function(component, event, helper){         
        
    },expandLastStage : function(component){       
        window.setTimeout($A.getCallback(function() {
            var fieldSetNameList = component.get("v.FieldSetNameList");
            if(fieldSetNameList != null && fieldSetNameList.length > 0){
                component.set("v.stageCount", fieldSetNameList.length);                            
                var arrNamelabel = fieldSetNameList[fieldSetNameList.length-1];
				var elements = document.getElementById(component.getGlobalId()+arrNamelabel+'_ButtonDiv'); 
                if(elements != null )                                     
                    elements.click();
            }   
        }), 500);
    },
    RefreshFieldset : function(component, event, helper){
        var self = this;          
        var action = component.get("c.getProduct");
        action.setParams({ productId : component.get("v.recordId") });        
        action.setCallback(this, function(a){               
            if(a.getReturnValue() != null){
                component.set("v.productRecord", a.getReturnValue());
                component.set("v.isRerender", true);  
            }            
        }); 
        $A.enqueueAction(action);
                
        var action1 = component.get("c.getChecklistFieldSetList");
        action1.setParams({ productId : component.get("v.recordId") });
        action1.setCallback(this, function(a){            
            if(a.getReturnValue() != null){
                var stageCount = component.get("v.stageCount");
				var returnList = a.getReturnValue();
                if(stageCount != returnList.length){                    
                    if(stageCount > returnList.length){                        
                        var newReturnList = [];
                        newReturnList.push(returnList[0]);
                        component.set("v.FieldSetNameList", newReturnList);
                    }
					//component.set("v.FieldSetNameList", []);
                    component.set("v.FieldSetNameList", a.getReturnValue());                    
                     window.setTimeout($A.getCallback(function() {
                         self.expandLastStage(component);
                    }), 500);
                }
                if(component.get("v.isRefreshEventCall")){
                   if(stageCount == returnList.length){
                        component.set("v.isRerender",false);
                        component.set("v.isRerender",true); 
                    }                    
                    component.set("v.FieldSetNameList", a.getReturnValue()); 
                    component.set("v.isRefreshEventCall",false);
                }
            }                    
        });
        $A.enqueueAction(action1);                
    }
})