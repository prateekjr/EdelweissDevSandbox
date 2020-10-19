({
    // ## function call on component load  
    loadDummyList: function(component, event, helper){
        helper.onLoad(component, event);
    },
    
    // ## function call on Click on the "Download As TXT" Button. 
    downloadTxt : function(component,event,helper){   
        var selectedVal = component.find("SelectedValue").get("v.value");        
        component.set("v.isProcessing",true);
        var action = component.get('c.fetchTransactionToExport');
        action.setParams({
            transactionType : selectedVal
        });
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfSchema attribute on component.
                component.set("v.isProcessing", false);
                component.set('v.ListOfSchema', response.getReturnValue());
                 var stockData = component.get("v.ListOfSchema");        
        if(stockData == ''){
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "No data available for export.",
                    'type': 'Warning'
                });
                toastEvent.fire();
        }
        // call the helper function which "return" the TXT data as a String   
        var txt = helper.convertArrayOfObjectsToTXT(component,stockData);   
        if (txt == null){return;} 
        
        
        
        //component.set('v.successMsg', 'File Downloaded Successfully!!');
        // ####--code for create a temp. <a> html tag [link tag] for download the TEXT file--####    
        debugger;
        var today = new Date();
        var dd = today.getDate();
        var mm = (today.getMonth()+1);
		var hh =  today.getHours();   
        var min = today.getMinutes();
        var sec = today.getSeconds();
        var yy = today.getFullYear().toString().substr(-2);


         if(dd<10) 
		{   dd='0'+dd;	
		} 
		if(mm<10) 
		{mm='0'+mm;
		}  
        if(hh<10) 
		{hh='0'+hh;
		} 
         if(min<10) 
		{min='0'+min;
		} 
        if(sec<10) 
		{sec='0'+sec;
		} 
        var date = dd+''+mm+''+yy;
		var time =  hh +''+ min + '' + sec;
		var dateTime = date+''+time; 
         var fileName = '';       
                if(selectedVal == 'Purchase/Redemption Normal'){
                    fileName = 'ARN_Pur_Red_'+dateTime+'.csv'
                }else if(selectedVal == 'Switch Normal'){
                    fileName = 'ARN_Switch_'+dateTime+'.csv'
                }else if(selectedVal == 'Purchase/Redemption Direct'){
                     fileName = 'RIA_Pur_Red_'+dateTime+'.csv'
                }else if(selectedVal == 'Switch Direct'){
                     fileName = 'RIA_Switch_'+dateTime+'.csv'
                }       
                
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(txt);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = fileName;  // txt file Name* you can change it.[only name not .txt] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download txt file  
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "File Exported Successfully.",
                    'type': 'success'
                });
                toastEvent.fire();
          }
        });
          $A.enqueueAction(action);
        // get the Records [contact] list from 'ListOfSchema' attribute 
                    
    }, 
    })