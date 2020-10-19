({
    searchRecordsHelper : function(component, event, helper, value) {        
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
        var searchString = component.get('v.searchString');
        var SchemeSelect = component.get('v.SchemeSelect');
        var len = searchString.length;
        if(len >= 4 ){
                    $A.util.removeClass(component.find("Spinner"), "slds-hide");

             component.set('v.message', '');
        component.set('v.recordsList', []);
        var fieldName = component.get('v.fieldName');
        var criteriaField = component.get('v.criteriaField');
        
        
        if(fieldName == 'BSEStarSchemeName__c'){            
            var selectedRecordAMC1 = component.get('v.selectedRecordAMC1');
            var selectedFromSchemeObj = component.get('v.selectedFromSchemeObj');
            var orderEntry = component.get('v.orderEntry');

            var labelToDisplay = selectedRecordAMC1.label;
            var selectedSchemeObj;
            if(selectedRecordAMC1 != null){
                if(selectedRecordAMC1.label != null){
                    labelToDisplay = selectedRecordAMC1.label
                }
            } 
             if(selectedFromSchemeObj != null){
                if(selectedFromSchemeObj.label != null){
                    selectedSchemeObj = selectedFromSchemeObj.label
                }
            } 
            
        }
        if(fieldName == 'CLIENT_CODE__c'){
            var PanNumber = component.get('v.selectedPAN');
            if(PanNumber != null){
                labelToDisplay = PanNumber
            }
        }
        
        if(fieldName == 'Folio_Number__c'){
             var accountId = component.get('v.selectedClientAccountId');
            if(accountId != null){
                labelToDisplay = accountId
            }
            
        }        
        var ipoType = component.get('v.selectedIPOType'); 
        var selectedClientLead = component.get('v.selectedClientLead');
            console.log('selectedClientLead :'+selectedClientLead);
            /*if(fieldName =='productISIN__c'){
                
            }*/
        // Calling Apex Method        
            
            var action = component.get('c.fetchRecords');
            var orderEntry = component.get('v.orderEntry')
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : searchString,
            'value' : value,
            'selectedRecordAMC' : labelToDisplay,
            'criteriaField' : criteriaField,
            'selectedFromSchemeObj' : selectedSchemeObj,
            'orderEntry' : orderEntry,
            'SchemeSelect':SchemeSelect,
            'ipoType':ipoType,
            'selectedClientLead':selectedClientLead
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
                    } else {
                        component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
            
       }
       
    }
})