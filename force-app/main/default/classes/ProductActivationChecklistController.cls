public class ProductActivationChecklistController {
    
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
        Schema.FieldSet fs = fsMap.get(fsName.replaceAll(' ', '_'));
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f,'', null,null, false,null,null,null,null,null));
        }
        return fset;
    } 
    
    @AuraEnabled   
    public static List<String> getChecklistFieldSetList(String productId)
    {
        // write logic to get fieldset list. 
        List<String> FieldSetNames = new list<String>{'Product Initiated','Product Note','Requirement Completion Approval','Product Live Approval','Pending Product Creation In Miles'};
        if(productId != null){
            List<Product2> lstProduct = [SELECT Id, Product_Stage__c FROM Product2 WHERE Id =: productId];
            if(lstProduct != null && lstProduct.size() > 0){
                Product2 productRecord = lstProduct[0];
                
                /*if(productRecord.Product_Stage__c == 'Initiated')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note'};
                else if(productRecord.Product_Stage__c == 'Product Note Submitted')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note','Requirement Completion Approval'};  
                else if(productRecord.Product_Stage__c == 'Requirement Completion Approval Received')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note','Requirement Completion Approval','Product Live Approval'}; 
                else if(productRecord.Product_Stage__c == 'Product Live Approval Received')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note','Requirement Completion Approval','Product Live Approval','Pending Product Creation In Miles'}; Commented for Change : Club Sumbit for approval and Product Live Approval*/
                 if(productRecord.Product_Stage__c == 'Initiated')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note'};
                else if(productRecord.Product_Stage__c == 'Product Note Submitted')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note','Product Live Approval'};  
                else if(productRecord.Product_Stage__c == 'Product Live Approval Received')
                    FieldSetNames = new list<String>{'Product Initiated','Product Note','Product Live Approval','Pending Product Creation In Miles'}; 
            
            
            }
        }  
        Return FieldSetNames; 
    }
    
    @AuraEnabled   
    public static List<StageCheckboxInfo> getChecklistFieldData(String ObjectType, sobject Record, String fieldsetName)
    {   
        system.debug('Record==>'+Record);   
        system.debug('fieldsetName==>'+fieldsetName);      
        List<FieldSetMember> FieldSetData =  ProductActivationChecklistController.getFields(ObjectType, fieldsetName);
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
    public static String SaveChecklist(Product2 productRecord)
    {
        String strError = 'Success';
        
        /*
        Id genericEventRecordTypeId =  EdelweissConstants.EventRecordTypeMap.get('Generic_Event_Record_Type');
        List<Id> caseRecordType = new List<Id>();
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.EXCHANGE_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.FUNDING_ACCOUNT_OPENING).getRecordTypeId());
        caseRecordType.add(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(EdelweissConstants.NON_EXCHANGE_ACCOUNT_OPENING).getRecordTypeId()); 
        
        
        if(productRecord != null){
            if(productRecord.Product_Note_Submitted__c){
                Integer count= database.countQuery('SELECT COUNT() FROM Attachment WHERE ParentId=:productRecord.Id AND Name Like \'Product Note_%\'');
                if(count == 0){
                    strError = Label.Attach_Product_Note;
                }
            }
            if(productRecord.Basic_Details_of_Mini_IPS_filled__c){
                List<Investment_Policy_Statement_IPS__c> lstIPS = [Select Id From Investment_Policy_Statement_IPS__c Where Client_Name__c =: accountRecord.Id ];
                if(!(lstIPS != null && lstIPS.size() > 0)){
                    strError = Label.Please_fill_Mini_IPS;
                }
            }
            if(productRecord.Open_an_account_opening_Case__c){
                List<Case> lstCase = [Select Id From Case Where AccountId =: productRecord.Id And RecordTypeId IN : caseRecordType And Status = 'Closed – Success'];
                if(!(lstCase != null && lstCase.size() > 0)){
                    strError = Label.Please_close_account_opening_case;
                }
            }
        }
        */
        
        if(strError == 'Success')
            database.Update(productRecord);
        return strError;        
    }
    
    @AuraEnabled   
    public static Product2 getProduct(String productId)
    {
        Product2 productRecord = null;
        if(productId != null && productId != ''){
            
            List<String> FieldSetNames = new list<String>{'Product_Initiated','Product_Note','Requirement_Completion_Approval','Product_Live_Approval','Pending_Product_Creation_in_Miles'};                    
                      
            String accQuery = 'SELECT Id ,';
            for(String FieldSetName : FieldSetNames){
                List<FieldSetMember> FieldSetData =  ProductActivationChecklistController.getFields('Product2', fieldsetName);
                for(FieldSetMember fielddata : FieldSetData){
                    accQuery += fielddata.fieldPath+',';
                }
            }
            accQuery = accQuery.removeEnd(',');
            accQuery += ' FROM Product2 WHERE Id = :productId Limit 1 ';   
            system.debug('accQuery==>'+accQuery);   
            List<sObject> sobjList =  database.query(accQuery);        
            if(sobjList != null && sobjList.size() > 0)
                productRecord = (Product2)sobjList[0];
        } 
        system.debug('productRecord==>'+productRecord);
        return productRecord; 
    }
}