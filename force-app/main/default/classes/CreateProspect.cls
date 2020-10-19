public class CreateProspect {

    public Lead newLeadObj{get;set;}
    public Boolean isCorporate{get;set;}
    public Boolean isIndividual{get;set;}
    public Boolean isHybrid{get;set;}
    public Boolean islistedAccount{get;set;}
    public Boolean isOrganization{get;set;}
    public String lastName{get;set;}
    public CreateProspect(ApexPages.StandardController controller) {
        islistedAccount = false;
        isOrganization = false;
        isCorporate = false;
        isIndividual = false;
        isHybrid = false;
        newLeadObj = new Lead();
        Id selectedRecordTypeId = apexpages.currentpage().getparameters().get('RecordType');
        Id indvProsRecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect');
        Id hybridProsRecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Both_Prospect');
        Id corpProsRecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect');
        newLeadObj.RecordTypeId = selectedRecordTypeId;
        system.debug('selectedRecordTypeId =========='+selectedRecordTypeId );
        if(selectedRecordTypeId == corpProsRecordTypeId ){
        system.debug('In Corporate record Type$$$$$$$$$$$$');
            isCorporate = true;
            newLeadObj.Category__c = EdelweissConstants.LEAD_CORPORATE_CATEGORY ; 
        }else{        
            isCorporate = false;
        }
        if(selectedRecordTypeId == indvProsRecordTypeId ){  
            isIndividual = true; 
            isOrganization = true;         
            newLeadObj.Category__c = EdelweissConstants.LEAD_INDIVIDUAL_CATEGORY  ; 
            system.debug('newLeadObj.Category__c=='+newLeadObj.Category__c);
        }else{
            isIndividual = false; 
        
        }
        if(selectedRecordTypeId == hybridProsRecordTypeId ){  
            isHybrid = true;          
            newLeadObj.Category__c = EdelweissConstants.LEAD_HYBRID_CATEGORY ; 
            system.debug('newLeadObj.Category__c=='+newLeadObj.Category__c);
        }else{
            isHybrid = false; 
        
        }
    }
    public PageReference saveProspects(){        
        List<ListedAccounts__c> selectedListedAccountList = [Select id,Name,Code__c FROM ListedAccounts__c WHERE id =:newLeadObj.ListedAccount__c Limit 1];
        
        
        if(newLeadObj.Sub_Source_Level_1__c == 'Database' && String.isBlank(newLeadObj.Database_Name__c)){
        
            newLeadObj.Database_Name__c.addError('Please enter Database Name.');
            return null;
        }
        
        
        if( newLeadObj.Sub_Source_Level_2__c =='Stake Sale' && String.isBlank(newLeadObj.Source_of_News__c) ){
        
            newLeadObj.Source_of_News__c.addError('Please enter source of News.');
            return null;
        
        }
        system.debug('newLeadObj.Date_of_News__c====='+newLeadObj.Date_of_News__c);
        if( newLeadObj.Sub_Source_Level_2__c =='Stake Sale' && newLeadObj.Date_of_News__c==null ){
        
            newLeadObj.Date_of_News__c.addError('Please enter Date of News.');
            return null;
        }
        if( newLeadObj.Sub_Source_Level_1__c =='Third Party Intelligence' && String.isBlank(newLeadObj.Name_of_Third_Party__c) ){
        
            newLeadObj.Name_of_Third_Party__c.addError('Please enter Name of Third Party.');
            return null;
        }
        if( newLeadObj.Sub_Source_Level_1__c   =='Third Party Intelligence' && String.isBlank(newLeadObj.Relationship_with_Third_Party__c) ){
        
            newLeadObj.Relationship_with_Third_Party__c.addError('Please enter Relationship with Third Party.');
            return null;
        }
        if( newLeadObj.Sub_Source_Level_2__c  =='Other Edelweiss Employee' && String.isBlank(newLeadObj.Employee_Name__c) ){
        
            newLeadObj.Employee_Name__c.addError('Please enter Employee Name.');
            return null;
        }
        if( newLeadObj.Sub_Source_Level_2__c  =='Other Edelweiss Employee' && String.isBlank(newLeadObj.SBU_Name__c ) ){
        
            newLeadObj.SBU_Name__c.addError('Please enter SBU Name.');
            return null;
        }
        if( newLeadObj.Sub_Source_Level_2__c  =='Sub-Broker' && String.isBlank(newLeadObj.Sub_Broker_Name__c ) ){
        
            newLeadObj.Sub_Broker_Name__c.addError('Please enter Sub-Broker Name.');
            return null;
        }
        if(newLeadObj.Sub_Source_Level_2__c == 'FA Referral' && String.isBlank(newLeadObj.Employee_Name__c)){
            
            newLeadObj.Employee_Name__c.addError('Please enter Employee Name.');
            return null;
        }
        
        if(newLeadObj.Organizations__c!= null){
            newLeadObj.Company = newLeadObj.Organizations__c;
        }else{
        
            newLeadObj.Company = selectedListedAccountList[0].Name;
        
        }
        if(newLeadObj.Category__c == EdelweissConstants.LEAD_INDIVIDUAL_CATEGORY && newLeadObj.Organization_Type__c == null){
        
        	newLeadObj.Organization_Type__c = 'Not Listed';
        
        }
        newLeadObj.LastName = lastName;
        newLeadObj.isInsert__c = true;
        try{
            insert newLeadObj ;
        }catch(Exception e){
            if(e.getMessage().contains(' We recommend you use an existing record instead')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Duplicate Detected'));
            
            }
            
        
        }
        if(newLeadObj.Id != null){
            PageReference pageRef = new PageReference('/' + newLeadObj.id);
            pageRef.setRedirect(true);
            return pageRef;
        }else{
        
            return null;
        }
    }
    public void toggleVisibility(){
        if(newLeadObj.Organization_Type__c == 'Listed'){
            system.debug('In Listed Category*************');
            islistedAccount = true;
            isOrganization = false;
        }else{
            system.debug('In Not Listed Category*************');
            isOrganization = true;
            islistedAccount = false;
        }
        
        
    }
}