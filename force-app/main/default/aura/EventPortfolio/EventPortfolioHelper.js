({
	showToast : function(msg,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },

    ValidateInput : function(component, event, helper,eventRec,isValid){
        var ShowQuestionnaire = component.get("v.ShowQuestionnaire");
        if(ShowQuestionnaire){
            helper.ValidateAnswer(component, event, helper,eventRec,isValid);
        }
        if(isValid){   
       	isValid = helper.ValidateRecord(component, event, helper,eventRec.Subject,'Subject',isValid);    
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Agenda__c,'Agenda',isValid);
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.StartDateTime,'Start',isValid);
		if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.EndDateTime,'End',isValid);
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Status__c,'Activity Status',isValid);
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Type_of_Communication__c,'Type of Communication',isValid);   
        }     
         return isValid;
    },
    ValidateAnswer : function(component, event, helper,eventRec,isValid){
        var Client_Monitor_Portfolio__c = component.get('v.Client_Monitor_Portfolio__c');
        var Others = component.get('v.Others');
        var scrutiny__c = component.get('v.scrutiny__c');
        var Is_portfolio_In_Sync__c = component.get('v.Is_portfolio_In_Sync__c'); 
        var Is_Client_Satisfied_On_Portfolio_Review__c = component.get('v.Is_Client_Satisfied_On_Portfolio_Review__c');  
        if(isValid){   
       	isValid = helper.ValidateRecord(component, event, helper,eventRec.Primary_Purpose_Of_Portfolio__c,'Primary Purpose Of Portfolio',isValid);   
            if(isValid){
                if(Others){
           				 isValid = helper.ValidateRecord(component, event, helper,eventRec.Others__c,'Others',isValid);
                }       
            }
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Expectation_From_Portfolio__c,'Expectation From Portfolio',isValid);
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Is_portfolio_In_Sync__c,'Is portfolio In Sync',isValid);
            if(isValid){
                if(Is_portfolio_In_Sync__c){
                isValid = helper.ValidateRecord(component, event, helper,eventRec.Concerns__c,'If No , what are the concerns?',isValid);
                }
          }
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.scrutiny__c,'Is there any portfolio allocation which requires further scrutiny?',isValid);
            if(isValid){
            if(scrutiny__c){
                 isValid = helper.ValidateRecord(component, event, helper,eventRec.Investments_And_Alternates_Provided__c,'What Investments And Alternates Provided',isValid);
            }
            }      
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Is_Client_Satisfied_On_Portfolio_Review__c,'Is Client Satisfied On Portfolio Review',isValid);
           
         if(isValid){
             if(Is_Client_Satisfied_On_Portfolio_Review__c){
                   isValid = helper.ValidateRecord(component, event, helper,eventRec.Reason_For_Dissatisfaction__c,'Reason For Dissatisfaction',isValid);
             }
         }
        if(isValid) isValid = helper.ValidateRecord(component, event, helper,eventRec.Is_Requested_Tochange_Portfolio_Review__c,'Has the client requested to change Portfolio Review?',isValid);
            if(isValid){
                if(Client_Monitor_Portfolio__c){
                    isValid = helper.ValidateRecord(component, event, helper,eventRec.How_Often_Does_Client_Monitor_Portfolio__c,'How often does client monitor portfolio?',isValid);
                   
                }
            }
        }     
         return isValid;
    },
    
    ValidateRecord : function(component, event, helper,data , msg ,isValid){
       if(data == null || data == ''){
           var errorField = '';
           errorField = component.get('v.errorField');
           errorField = errorField + msg + ',';
           component.set('v.errorField',errorField);
           isValid = false;
        }
        return isValid;
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
        }
    
    } 
    
})