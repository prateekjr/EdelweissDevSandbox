({
   onLoad: function(component, event) {
      //call apex class method
      var action = component.get('c.fetchScheMaster');
      action.setCallback(this, function(response){
         //store state of response
         var state = response.getState();
         if (state === "SUCCESS") {
            //set response value in ListOfSchema attribute on component.
            component.set('v.ListOfSchema', response.getReturnValue());
         }
      });
      $A.enqueueAction(action);
   },
    
   convertArrayOfObjectsToTXT : function(component,objectRecords,selectedVal){    
        // declare variables       
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = '|';
        lineDivider =  '\r\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
       // keys = ['Age__c','First_Name__c'];
        //keys = ['Additional_Purchase_Amount__c','AMC_IND__c','AMC_Active_Flag__c','AMC_Code__c','AMC_Scheme_Code__c','Channel_Partner_Code__c','Dividend_Reinvestment_Flag__c','End_Date__c','Exit_Load__c','Exit_Load_Flag__c','Face_Value__c','ISIN__c','Lock_in_Period__c','Lock_in_Period_Flag__c','Maximum_Purchase_Amount__c','Maximum_Redemption_Qty__c','Minimum_Purchase_Amount__c','Minimum_Redemption_Qty__c','Purchase_Allowed__c','Purchase_Amount_Multiplier__c','Purchase_Cutoff_Time__c','Purchase_Transaction_mode__c','Redemption_Allowed__c','Redemption_Amount_Maximum__c','Redemption_Amount_Minimum__c','Redemption_Amount_Multiple__c','Redemption_Cut_off_Time__c','Redemption_Qty_Multiplier__c','Redemption_Transaction_Mode__c','RTA_Agent_Code__c','RTA_Scheme_Code__c','Scheme_Code__c','Scheme_Name__c','Scheme_Plan__c','Scheme_Type__c','SETTLEMENT_TYPE__c','SIP_FLAG__c','Start_Date__c','STP_FLAG__c','Switch_FLAG__c','SWP_Flag__c','Unique_No__c'];
       //keys = ['Status','Reason','AccountId','Age__c','Amount__c','Case_Type__c','Client_Name__c','Comments','Comments__c','Due_Date_Time__c','Due_Date__c','EventId__c','Current_On_Hold_Duration__c','Due_Date_Notification_Sent__c','Fund_Status__c','Financial_Transaction_Id__c','Exchange_Account_Type__c','Lead__c','Nature__c','Next_Follow_up__c','PAN_Number__c','POA__c','Buy_Sell__c','Salutation__c','Remarks__c','Subtype__c','TAT__c','Account_No__c','Branch_Name__c','Bank_Name__c','Amount_FundTransfer__c']; 
       if(selectedVal == 'Purchase/Redemption Direct' || selectedVal == 'Purchase/Redemption Normal'){
       	keys = ['scheme_code_export__c','PURCHASE_REDEEM__c','BUY_SELL_TYPE__c','UCC__c','dematPhysicalCNP__c','Transaction_Amount_Export__c','Folio_Blank__c','Remarks__c','KYC_Flag_Default__c','Sub_Broker_Code_Blank__c','EUIN__c','EUIN_Declaration_Default__c','MIN_redemption_flag_default__c','DPC_Flag_default__c','All_Units_blank__c','Redemption_Units_Blank__c','Sub_broker_ARN_Blank__c']; 
            
       } else if(selectedVal == 'Switch Direct' || selectedVal == 'Switch Normal'){
       	keys = ['scheme_code_export__c','to_scheme_code_export__c','BUY_SELL_TYPE__c','UCC__c','dematPhysicalCNP__c','Transaction_Amount_Export__c','Redemption_Units_Blank__c','All_Units_blank__c','Folio_Blank__c','Remarks__c','KYC_Flag_Default__c','Sub_Broker_Code_Blank__c','EUIN__c','EUIN_Declaration_Default__c','Sub_broker_ARN_Blank__c'];
       }          
       csvStringResult = '';
        /*csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;*/
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                 if(counter > 0){ 
                     csvStringResult += columnDivider; 
                 }                      
                 if( objectRecords[i][skey]== undefined){                   
                     csvStringResult += ' '; 
                 }
                 else {
                     csvStringResult += objectRecords[i][skey];                                           
                 }
                 counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String        
        return csvStringResult;        
    },
    
    downloadFile : function(component, event, helper,fileName,txt){
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(txt);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = fileName;  // txt file Name* you can change it.[only name not .txt] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download txt file  
    },
    
    showError : function(component, event, helper){
        var showErrorForPurRedN = component.get('v.showErrorForPurRedN');  
        var showErrorForSwitchN = component.get('v.showErrorForSwitchN');  
        var showErrorForPurRedD = component.get('v.showErrorForPurRedD');  
        var showErrorForSwitchD = component.get('v.showErrorForSwitchD');  
        
        if(showErrorForPurRedN && showErrorForSwitchN && showErrorForPurRedD && showErrorForSwitchD ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning !",
                "message": "No data available for export.",
                'type': 'Warning'
            });
            toastEvent.fire();
        }
    }
})