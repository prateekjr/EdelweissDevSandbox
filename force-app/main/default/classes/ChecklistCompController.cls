public class ChecklistCompController {
    public class StageCheckboxInfo{
        @AuraEnabled public String label { get;set; }
        @AuraEnabled public Boolean value { get;set; }
        @AuraEnabled public String apiName { get;set; }
        @AuraEnabled public Boolean isrequire{ get;set; }
        @AuraEnabled public Boolean isReadOnly{ get;set; }
        Public StageCheckboxInfo(String strlabel, Boolean isvalue,String strApiName, Boolean isRequirevalue, Boolean isFieldReadOnly){
            label = strlabel;
            value = isvalue;
            apiName = strApiName;
            isrequire = isRequirevalue;
            isReadOnly = isFieldReadOnly;
        }
    }  
    
    @AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        system.debug('fsMap ==>'+fsMap );
        Schema.FieldSet fs = fsMap.get(fsName);
        system.debug('fsName::'+fsName);
        system.debug('fs::'+fs);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f,'', null,null, false,null,null,null,null,null,null));
        }
        return fset;
    } 
    
    @AuraEnabled   
    public static List<String> getChecklistFieldSetList(String accountId)
    {
        // write logic to get fieldset list. 
        Id leadRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Lead');
        List<String> FieldSetNames = new list<String>{ 'R0','R1','R2','R3'};
        if(accountId != null){
            List<Account> lstAccount = [Select Coverage__c, RecordTypeId, Id From Account Where Id =: accountId];
            if(lstAccount != null && lstAccount.size() > 0){
                Account accRecord = lstAccount[0];
                if(accRecord.RecordTypeId != leadRecordTypeId || accRecord.Coverage__c == 'Lead Database')
                     FieldSetNames = new list<String>{ 'No Data'};
                else if(accRecord.Coverage__c == 'R0')
                    FieldSetNames = new list<String>{ 'R0'};
                else if(accRecord.Coverage__c == 'R1')
                    FieldSetNames = new list<String>{ 'R0','R1'};
                else if(accRecord.Coverage__c == 'R2')
                    FieldSetNames = new list<String>{ 'R0','R1','R2'};  
                else if(accRecord.Coverage__c == 'R3')
                    FieldSetNames = new list<String>{ 'R0','R1','R2','R3'}; 
            }
            
        }  
        Return FieldSetNames; 
    }
    
    @AuraEnabled   
    public static List<StageCheckboxInfo> getChecklistFieldData(String ObjectType, sobject Record,String fieldsetName)
    {   
        system.debug('Record==>'+Record);   
        system.debug('fieldsetName==>'+fieldsetName);      
        List<FieldSetMember> FieldSetData =  ChecklistCompController.getFields(ObjectType, fieldsetName);
        system.debug('FieldSetData ==>'+FieldSetData ); 
        List<StageCheckboxInfo> lstStagecheckboxInfo = new List<StageCheckboxInfo>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectType);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.SObjectField> mapDescribeFields = describe.fields.getMap();
        if(Record != null){
            if(FieldSetData != null && FieldSetData.size() > 0){            
                for(FieldSetMember fielddata :  FieldSetData){  
                    Boolean isReadOnly = false;
                    if(!mapDescribeFields.get(fielddata.fieldPath).getDescribe().isUpdateable()) {isReadOnly = true;}
                    lstStagecheckboxInfo.add(new StageCheckboxInfo(fielddata.label, (Boolean)Record.get(fielddata.fieldPath), fielddata.fieldPath, fielddata.required, isReadOnly )); 
                }
            }
        }        
        return lstStagecheckboxInfo;
    }
    
     @AuraEnabled   
    public static String SaveChecklist(Account accountRecord)
    {
        String strError = 'Success';
        Id genericEventRecordTypeId =  EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        List<Id> caseRecordType = new List<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId()); 
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.ACCOUNT_OPENING).getRecordTypeId());  
                   
        if(accountRecord != null){
            if(accountRecord.In_Person_Meeting_Done__c){
                List<Event> lstEvent = [Select Id From Event Where RecordTypeId =: genericEventRecordTypeId And Status__c = 'Completed' And WhatId = : accountRecord.Id And Type_of_Communication__c = 'In-Person' And OwnerId =: UserInfo.getUserId()];
                if(!(lstEvent != null && lstEvent.size() > 0)){
                    strError = Label.Please_Complete_In_Person_meeting;
                }
            }
            if(accountRecord.Basic_Details_of_Mini_IPS_filled__c){
                List<Investment_Policy_Statement_IPS__c> lstIPS = [Select Id From Investment_Policy_Statement_IPS__c Where Client_Name__c =: accountRecord.Id ];
                if(!(lstIPS != null && lstIPS.size() > 0)){
                    strError = Label.Please_fill_Mini_IPS;
                }
            }
            if(accountRecord.Open_an_account_opening_Case__c){
                List<Case> lstCase = [Select Id From Case Where AccountId =: accountRecord.Id And RecordTypeId IN : caseRecordType And Status = 'Closed – Success'];
                if(!(lstCase != null && lstCase.size() > 0)){
                    strError = Label.Please_close_account_opening_case;
                }
            }
            
        }
        if(strError == 'Success')
            database.Update(accountRecord);
        return strError;        
    }
    
    @AuraEnabled   
    public static Account getAccount(String accountId)
    {
        Account accRecord = null;
        if(accountId != null && accountId != ''){
            
            List<String> FieldSetNames = new list<String>{ 'R0','R1','R2','R3'};                    
                      
            String accQuery = 'Select Id,RecordType.DeveloperName,';
            for(String FieldSetName : FieldSetNames){
                List<FieldSetMember> FieldSetData =  ChecklistCompController.getFields('Account', fieldsetName);
                for(FieldSetMember fielddata : FieldSetData){
                    accQuery += fielddata.fieldPath+',';
                }
            }
            accQuery = accQuery.removeEnd(',');
            accQuery += ' FROM Account WHERE Id = :accountId Limit 1 ';   
            system.debug('accQuery==>'+accQuery);   
            List<sObject> sobjList =  database.query(accQuery);        
            if(sobjList != null && sobjList.size() > 0)
                accRecord = (Account)sobjList[0];
        } 
        system.debug('accRecord==>'+accRecord);
        Return accRecord; 
    }
    
    
}