({
	doInit : function(component, event, helper) {		
              
        helper.getFieldValue(component, event, helper);    
        
	},
    ToggleCollapse : function(component, event, helper) { 		
          
        var divId = component.get("v.compId")+component.get("v.fieldsetName")+'_ButtonDiv';
		var divEle = document.getElementById(divId);       
        var curElement = divEle; 
        var parElement = curElement.parentNode.parentNode; 			
        for (var i = 0; i < parElement.childNodes.length; i++) {
            if (parElement.childNodes[i].className && parElement.childNodes[i].className.indexOf("container") > -1) {
                                
                var ButtonArr = curElement.childNodes;
                if(ButtonArr[0].className.indexOf("show") > -1)
                {                    
                    parElement.childNodes[i].classList.remove("hide");
                    parElement.childNodes[i].classList.add("show");
               		ButtonArr[0].classList.add("hide");
                    ButtonArr[0].classList.remove("show");
                    ButtonArr[1].classList.add("show");
                    ButtonArr[1].classList.remove("hide");
                    divEle.classList.add("expandbtn");
                    divEle.classList.remove("collapsbtn");
                }else
                {                   
                    parElement.childNodes[i].classList.remove("show");
                    parElement.childNodes[i].classList.add("hide");
               		ButtonArr[1].classList.add("hide");
                    ButtonArr[1].classList.remove("show");
                    ButtonArr[0].classList.add("show");
                    ButtonArr[0].classList.remove("hide");
                    divEle.classList.add("collapsbtn");
                    divEle.classList.remove("expandbtn");
                }
                
              break;
            }
        }
	},
    Savechanges :function(component, event, helper){
        var checkbox = event.target;  
        var checkBoxOldVal = checkbox.checked == true ? false : true;
		var productRecord = component.get("v.productRecord");
		productRecord = {};
		productRecord["Id"] = component.get("v.productId");
		productRecord[checkbox.getAttribute('name')] = checkbox.checked;
		checkbox.setAttribute('disabled','disabled');
		var action = component.get("c.SaveChecklist");
		action.setParams({ productRecord : productRecord });

        action.setCallback(this, function(a){            
            
            if(a.getState() == "ERROR"){
                var errors = a.getError();
                if (errors) {                    
                    
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        var showToast = $A.get('e.force:showToast');
                        showToast.setParams({'title': "Error!",
                            				 'message': errors[0].pageErrors[0].message,
                                             'type' :'error'});
                        showToast.fire();
                        checkbox.checked = checkBoxOldVal; 
                        checkbox.removeAttribute('disabled');
						productRecord[checkbox.getAttribute('name')] = checkBoxOldVal;
                    }else if(errors[0] && errors[0].fieldErrors){                        
                        for (var key in errors[0].fieldErrors){
                            if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0]){                               
                                var showToast = $A.get('e.force:showToast');
                                showToast.setParams({ 
                                    'title': "Error!",
                                    'message': errors[0].fieldErrors[key][0].message,
                                    'type': 'error'
                                });
                                showToast.fire();
                                checkbox.checked = false; 
                                checkbox.removeAttribute('disabled');
                                productRecord[checkbox.getAttribute('name')] = checkBoxOldVal;
                            }
                        }                       
                    }
                }
            }else{
                var strError = a.getReturnValue();
				
				if(strError == 'Success' ){
					//$A.get('e.force:refreshView').fire(); 
					var showToast = $A.get('e.force:showToast');
					showToast.setParams({ 'message': 'Your changes have been saved.' });
					showToast.fire();
					debugger;
					//call CheckBoxSelect event 
					var cmpEvent = component.getEvent("CheckBoxSelect");
					cmpEvent.fire(); 
					var fieldList = component.get("v.fieldList");                
					if(fieldList != null){
						for(var i=0; i < fieldList.length; i++){                        
							if(fieldList[i] != null ){
								if(fieldList[i].apiName == checkbox.getAttribute('name')){
								   
									fieldList[i].value = checkbox.checked; 
								}
							}                                       
						}
					}
				}else{
					var showToast = $A.get('e.force:showToast');
					showToast.setParams({ 
                                    'title': "Error!",
                                    'message': strError,
                                    'type': 'error'
                                });
					showToast.fire();
					checkbox.checked = false; 
					checkbox.removeAttribute('disabled');
				}
				
				             
            }      
            helper.markComplete(component, event, helper);
        }); 
        $A.enqueueAction(action);       
              
    }
})