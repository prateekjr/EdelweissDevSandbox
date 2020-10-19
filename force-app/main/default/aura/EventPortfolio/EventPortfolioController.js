({
     doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
       	var eventRec = component.get("v.EventRec");
       	var today = new Date();
        var newDate = new Date();
       	var h = newDate.getHours();
        newDate.setHours(h+1);
        eventRec.StartDateTime = today.toISOString(); 
        eventRec.EndDateTime = newDate.toISOString();
        eventRec.WhatId = recId;
        eventRec.sobjectType = "Event";
        component.set("v.EventRec",eventRec);        
         var action = component.get("c.getAccount");  
            action.setParams({
                "recId" : recId
            });
         action.setCallback(this, function(response) { 
              var state = response.getState();
 				 if (state === "SUCCESS") {
            		 var accountRec = response.getReturnValue();
                     if(accountRec.How_Often_Does_Client_Monitor_Portfolio__c == '' || accountRec.How_Often_Does_Client_Monitor_Portfolio__c == null){
                         component.set("v.How_Often_Does_Client_Monitor_Portfolio__c",'Quarterly');
                     }else{
                      component.set("v.How_Often_Does_Client_Monitor_Portfolio__c",accountRec.How_Often_Does_Client_Monitor_Portfolio__c);
                     }
                 }
         });$A.enqueueAction(action);

    },
     HandleInputChange : function(component, event, helper) {     
       var eventRec = component.get("v.EventRec");
         /*if(eventRec.Agenda__c == 'Portfolio Review'){
               component.set("v.ShowQuestionnaire",true);
         }*/
         if(eventRec.Primary_Purpose_Of_Portfolio__c == 'Others'){
               component.set("v.Others",true);
         }else if(eventRec.Primary_Purpose_Of_Portfolio__c != 'Others'){
              component.set("v.Others",false);
         }
		if(eventRec.Is_portfolio_In_Sync__c == 'No'){
             component.set("v.Is_portfolio_In_Sync__c",true);
        }else if(eventRec.Is_portfolio_In_Sync__c == 'Yes'){
            component.set("v.Is_portfolio_In_Sync__c",false);
        }
          if(eventRec.Is_Client_Satisfied_On_Portfolio_Review__c == 'No'){
             component.set("v.Is_Client_Satisfied_On_Portfolio_Review__c",true);
          }else if(eventRec.Is_Client_Satisfied_On_Portfolio_Review__c == 'Yes'){
              component.set("v.Is_Client_Satisfied_On_Portfolio_Review__c",false);
          }
         if(eventRec.scrutiny__c == 'Yes'){
            component.set("v.scrutiny__c",true);
         }else if(eventRec.scrutiny__c == 'No'){
             component.set("v.scrutiny__c",false);
         }
         if(eventRec.Is_Requested_Tochange_Portfolio_Review__c == 'Yes'){
            component.set("v.Client_Monitor_Portfolio__c",true);
         }else if(eventRec.Is_Requested_Tochange_Portfolio_Review__c == 'No'){
             component.set("v.Client_Monitor_Portfolio__c",false);
         }
    },
    cancelAnswer : function(component, event, helper) {
          component.set("v.ShowQuestionnaire",false);
          var eventRec = component.get("v.EventRec");
		  //eventRec.Agenda__c = 'General';
          eventRec.Primary_Purpose_Of_Portfolio__c = '';
          eventRec.Others__c = '';
      	  eventRec.Expectation_From_Portfolio__c = '';
       	  eventRec.Is_portfolio_In_Sync__c = '';
          eventRec.Concerns__c = '';
          eventRec.scrutiny__c = '';
          eventRec.Investments_And_Alternates_Provided__c = '';
          eventRec.Is_Client_Satisfied_On_Portfolio_Review__c = '';
          eventRec.Reason_For_Dissatisfaction__c = '';
          eventRec.Is_Requested_Tochange_Portfolio_Review__c = '';
          eventRec.How_Often_Does_Client_Monitor_Portfolio__c = '';
          component.set("v.EventRec",eventRec);
    },
     saveAnswer : function(component, event, helper) {
        var eventRec = component.get("v.EventRec");
        var isValid = component.get('v.isValid');
        isValid = helper.ValidateAnswer(component, event, helper,eventRec,isValid);
        var errorField = component.get('v.errorField');
        var n = errorField.endsWith(",");
        if(n){
                errorField = errorField.substring(0,(errorField.length-1));
            } 
        if(!isValid){
            helper.showToast('Please fill these fields : '+errorField,'error');    
            component.set('v.errorField','');
        }else{
            component.set("v.isValidAnswer",true);
            component.set("v.ShowQuestionnaire",false);
            var showToast = $A.get('e.force:showToast');
                            showToast.setParams({ 
                                'title': "Success",
                                'message': 'Questions saved successfully ',
                                'type': 'success'
                            });
							showToast.fire();
        }
    
    } ,
      saveRecord : function(component, event, helper) {
        var eventRec = component.get("v.EventRec");
        var isValid = component.get('v.isValid');
        var isValidAnswer = component.get("v.isValidAnswer");
         if(eventRec.Agenda__c == 'Portfolio Review' && !isValidAnswer){
               component.set("v.ShowQuestionnaire",true);
             	//helper.saveAnswer(component, event, helper);
         }
         var ShowQuestionnaire = component.get("v.ShowQuestionnaire");
          if(!ShowQuestionnaire) {
        isValid = helper.ValidateInput(component, event, helper,eventRec,isValid);
        //var isValid = component.get('v.isValid');
        var errorField = component.get('v.errorField');
        var n = errorField.endsWith(",");
         if(n){
                errorField = errorField.substring(0,(errorField.length-1));
            }    
        if(!isValid){
            helper.showToast('Please fill these fields : '+errorField,'error');    
            component.set('v.errorField','');
        }else{
            component.set("v.isProcessing",true);
            //save method call 
            if(eventRec['Owner'] != null){
                delete eventRec['Owner'];
            }
            if(eventRec['Who'] != null){
                delete eventRec['Who'];
            }
            var whoIdstr = '';
            if(eventRec.WhoId != null){
                if(eventRec.WhoId.includes('id')){
                    var WhoObj = JSON.parse(eventRec.WhoId);                
                    if(WhoObj.length > 0){
                        var whoId = WhoObj[0].id;
                        eventRec.WhoId = whoId; 
                        for(var i in WhoObj){
                            if(i != 0 )
                                whoIdstr += WhoObj[i].id+',';
                        }
                        if(whoIdstr.endsWith(",")){
                             whoIdstr = whoIdstr.substring(0,(whoIdstr.length-1));
                        }
                    }
                }
                                               
            }
            var action = component.get("c.saveEvent");  
            action.setParams({
                "eventRec" : eventRec,
                "WhoIds" : whoIdstr
            });
            action.setCallback(this, function(response) {            
                component.set("v.isProcessing",false);
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS")
                {
                    
                    helper.showToast('Event '+eventRec.Subject+' was created','success');
                    $A.get('e.force:refreshView').fire();
                    eventRec = {};
                    var recId = component.get("v.recordId");
                    eventRec.sobjectType = "Event";
                    eventRec.Subject = '';
                    eventRec.WhatId = recId;
                   	component.set("v.EventRec",eventRec); 
                }
                else if (state === "ERROR")
                {
                	var errors = response.getError();
                	if (errors) {  
                    	if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
							var errorMessage = errors[0].pageErrors[0].message;
							var showToast = $A.get('e.force:showToast');
                            showToast.setParams({ 
                                'title': "Error!",
                                'message': errorMessage,
                                'type': 'error'
                            });
							showToast.fire();
                    	}
                        else if(errors[0] && errors[0].fieldErrors)
                        {
                        	for (var key in errors[0].fieldErrors)
                            {
                            	if(errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0])
                                {                               
                                	var showToast = $A.get('e.force:showToast');
                                    showToast.setParams({ 
                                        'title': "Error!",
                                        'message': errors[0].fieldErrors[key][0].message,
                                        'type': 'error'
                                    });
                                    showToast.fire();
                            	}
                        	}                       
                    	}
                	} 
            	}
            }); 
            $A.enqueueAction(action);
            
            }   
        } 
    }
})