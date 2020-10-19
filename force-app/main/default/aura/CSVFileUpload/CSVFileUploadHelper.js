({
    MAX_FILE_SIZE: 4 500 000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 950 000, /* Use a multiple of 4 */
 
    save : function(component, event, helper) 
    {
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   		var SelPicVal= component.find("SelectObject").get("v.value");
    	
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
        
        var fr = new FileReader();

        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length; 
            fileContents = fileContents.substring(dataStart);
             window.setTimeout($A.getCallback(function() {
    	    self.upload(component, file, fileContents,SelPicVal, helper);
         	}), 200);
            
    	    
        };
 
        fr.readAsDataURL(file);
    },
        
    upload: function(component, file, fileContents,SelPicVal,helper) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        this.uploadChunk(component, file, fileContents,SelPicVal, fromPos, toPos, '',helper);   
    },
     
    uploadChunk : function(component, file, fileContents,SelPicVal, fromPos, toPos, attachId,helper) {
       	var action = component.get("c.getCSVfileSave");
        var picklistvalue;
        var chunk = fileContents.substring(fromPos, toPos);
        action.setParams({
            picklistvalue: SelPicVal,
            fileName: file.name,
            base64Data:chunk,// encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        var self = this;
       action.setCallback(this, function(a){            
            if(a.getState() == "ERROR"){
                var errors = a.getError();
                if (errors) {                    
                    
                    if(errors[0] && errors[0].message ){
                        var showToast = $A.get('e.force:showToast');
                        showToast.setParams({'title': "Error!",
                            				 'message': errors[0].message,
                                             'type' :'error'});
                        showToast.fire();
                    }else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        var showToast = $A.get('e.force:showToast');
                        showToast.setParams({'title': "Error!",
                            				 'message': errors[0].pageErrors[0].message,
                                             'type' :'error'});
                        showToast.fire();
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
                            }
                        }                       
                    }
                }
            }else{
                var strError = a.getReturnValue();
					var showToast = $A.get('e.force:showToast');
                
                if(strError == null || strError == ''){
					showToast.setParams({ 'message': 'Details uploaded successfully.' });
					showToast.fire();
                } else {
                    if(SelPicVal=='FARevenue' || SelPicVal=='ClientRevenue' ){
                        helper.showMyToast(component, event, helper); 
                    }else{
                        showToast.setParams({'message': strError,'type': 'error'});
                        showToast.fire();
                    }
                }
            }
        });
        
        $A.enqueueAction(action); 
    },
         
        showMyToast : function(component, event, helper) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'This is a required message',
                messageTemplate: 'Some records are failed to insert. For error details please click {0}',
                messageTemplateData: [{
                    url: component.get("v.reportURL"),
                    label: 'here',
                }]
            });
            toastEvent.fire();
    }
})