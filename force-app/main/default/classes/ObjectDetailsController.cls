public class ObjectDetailsController {   
    public static SObject getRecord(String accId, Set<String> fldSet, String objectAPI) {
       	SObject record = Schema.getGlobalDescribe().get(objectAPI).newSObject();
            
        if(accId != null && !String.isBlank(accId)) {
        	List<String> fieldsList = new List<string>();
            if(!fldSet.contains('RecordType.Name') && objectAPI != 'Agreement_Info__c')
            	fldSet.add('RecordType.Name');
        	fieldsList.addAll(fldSet);
            String query = 'Select Id ,'+String.join(fieldsList , ',')+' From '+ objectAPI +' where Id = \''+accId+'\' limit 1';
            System.debug('query --- ' + query);
            record = Database.query(query);
        }
        return record;
    }
    
	// This method is used to insert a record having some more field values in addition to form field values
    public static String createRecord(SObject record, String objectAPI, Map<String, Object> mapRelatedObjData,String lkpFieldID,String lkpFieldName) {
        String recordId = '';
        String relatedObjId = '', relatedObjAPI = 'Opportunity', agreementType = '';
        
		if(lkpFieldID != '' && lkpFieldID != null && lkpFieldName != ''){
			if(lkpFieldName.endsWith('__r'))
				lkpFieldName = lkpFieldName.replace('__r','__c');
			record.put(lkpFieldName,lkpFieldID);
		}
			insert record;
			recordId = record.Id;
		system.debug('############ Record'+record);
        return recordId;
    }        
    
    @AuraEnabled 
    public static Map<String , Object> getFieldList(List<String> fldSetNameLst, String RecordID, String objectAPI, String lookupFieldID) {
        Map<String,Map<String,List<FieldSetMember>>> fieldSetMap = new Map<String,Map<String,List<FieldSetMember>>>();
        Map<String,Object> fieldSetResultMap = new Map<String,Object>();
        
        if(objectAPI == null || objectAPI == '') {
            objectAPI = 'Account';
        }
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPI);  // sObject token 
        DescribeSObjectResult sObjdesc = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjdesc.fields.getMap();
        Map<String, Schema.FieldSet> FsMap =  sObjdesc.fieldSets.getMap();
        List<FieldSetMember> fieldSetLst = new List<FieldSetMember>();
        Set<String> fieldsList = new Set<String>();
        system.debug('FsMap.keySet():::::::'+FsMap.keySet());
        for(String fieldSetName: fldSetNameLst){
            system.debug('fieldSetName----'+fieldSetName);
            if(FsMap.keySet().contains(fieldSetName.toLowerCase())){
                fieldSetLst = new List<FieldSetMember>();
                List<Schema.FieldSetMember> fieldSetMemberList = FsMap.get(fieldSetName).getFields();
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                    Schema.DescribeFieldResult dfr1 = fieldMap.get(fieldSetMemberObj.getFieldPath()).getDescribe();
                    boolean isEdit = dfr1.isUpdateable();
                    if(objectAPI.equalsIgnoreCase('Agreement_Info__c') && !isEdit)
                    	isEdit = dfr1.isCreateable();
                    Integer maxLength = dfr1.getLength();
					 if(fieldSetMemberObj.getType()+''=='INTEGER')
                        maxLength = dfr1.getDigits();
                    else if(fieldSetMemberObj.getType()+''=='DOUBLE')
                        maxLength = dfr1.getPrecision();    
                    Integer decimalDigits = dfr1.getScale();
                    Boolean isFormula = dfr1.isCalculated();
                    String helpText = dfr1.getInlineHelpText();
                    if(String.valueOf(fieldSetMemberObj.getType()).equalsIgnoreCase('REFERENCE')){
                            String RelatedObjNameChild = String.valueOf(dfr1.getReferenceTo()).substringBetween('(',')'); 
                            system.debug('RelatedObjNameChild-------------'+RelatedObjNameChild);
                            system.debug('fieldSetMemberObj.getFieldPath()----'+fieldSetMemberObj.getFieldPath());
                            if(fieldSetMemberObj.getFieldPath().containsIgnoreCase('__c'))
                                fieldsList.add(fieldSetMemberObj.getFieldPath().replace('__c','__r')+'.Name');
                            else{    
                                fieldsList.add(fieldSetMemberObj.getFieldPath().replace('Id','')+'.Name');
                            }
                            fieldSetLst.add( new FieldSetMember(fieldSetMemberObj , RelatedObjNameChild , new String[]{} ,null, false,maxLength, isFormula, !isEdit, decimalDigits, helpText, dfr1.isAccessible()));
                    }
                    else if(fieldSetMemberObj.getType()+'' == 'PICKLIST' || fieldSetMemberObj.getType()+'' == 'MULTIPICKLIST'){
                        fieldSetLst.add( new FieldSetMember(fieldSetMemberObj ,'',getPickListValues(fieldMap , fieldSetMemberObj.getFieldPath()) , null , false,maxLength,isFormula,!isEdit,decimalDigits,helpText, dfr1.isAccessible()));
                        fieldsList.add(fieldSetMemberObj.getFieldPath());
                    }
                    else if(String.valueOf(fieldSetMemberObj.getType()).equalsIgnoreCase('TEXTAREA')){ 
                        Boolean isHtmlFormatted = dfr1.isHtmlFormatted();
                        fieldsList.add(fieldSetMemberObj.getFieldPath());
                        fieldSetLst.add( new FieldSetMember(fieldSetMemberObj , '' , new String[]{} ,null, isHtmlFormatted,maxLength,isFormula,!isEdit,decimalDigits,helpText, dfr1.isAccessible()));
                    }
                    else{
                        fieldSetLst.add( new FieldSetMember(fieldSetMemberObj , '' , new String[]{} ,null, false,maxLength,isFormula,!isEdit,decimalDigits,helpText, dfr1.isAccessible()));
                        fieldsList.add(fieldSetMemberObj.getFieldPath());
                    }   
                }
                
                if(fieldSetMap.get(FsMap.get(fieldSetName).getLabel()) == null){
                    fieldSetMap.put(FsMap.get(fieldSetName).getLabel() , new Map<String,List<FieldSetMember>>());
                }
                if(fieldSetName.containsIgnoreCase('Col1')){
                    fieldSetMap.get(FsMap.get(fieldSetName).getLabel()).put( 'Col1', fieldSetLst);
                }else{
                    fieldSetMap.get(FsMap.get(fieldSetName).getLabel()).put( 'Col2', fieldSetLst);
                }
            }

        }
         List<Profile> proList = [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1];
		 System.debug('lkpFieldID----'+lookupFieldID);
         if(lookupFieldID != '' && lookupFieldID != null){
			String Name = '';
			if(lookupFieldID.startsWith('001'))
				Name = [SELECT Id, Name FROM Account WHERE Id=:lookupFieldID LIMIT 1].Name;
			fieldSetResultMap.put('lkpFieldNameValue',Name);
		}	
         system.debug('fieldSetMap-------'+fieldSetMap);    
         fieldSetResultMap.put('Result',fieldSetMap);
         fieldSetResultMap.put('Record', getRecord(RecordID, fieldsList, objectAPI));
         Boolean isObjectUpdate =  sObjdesc.isUpdateable();
        if(objectAPI.equalsIgnoreCase('Agreement_Info__c') && !isObjectUpdate){
              isObjectUpdate =  sObjdesc.isCreateable();  
        }
         fieldSetResultMap.put('isObjectUpdateable',isObjectUpdate);
		 if(proList != null && proList.size() > 0)
			fieldSetResultMap.put('ProfileName',proList[0].Name);
         return fieldSetResultMap;
    }
    
    private static List<String>  getPickListValues(Map<String, Schema.SObjectField> field_map , String fieldName ){
        List<String> lstPickvals=new List<String>();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(a.getValue());//add the value  to our final list
       }
         return lstPickvals;
    }
    
    @AuraEnabled 
    public static String save(SObject accRec, String objectAPI, String recordId, String relatedObjData,String lkpFieldID, String lkpFieldName) {
        System.debug('accRec ---- ' + accRec);

		String returnID = recordId;
        Map<String, Object> mapRelatedObjData = new Map<String, Object>();
        String relatedObjAPI = '';
        
        if(relatedObjData != null && !String.isBlank(relatedObjData)) {
            mapRelatedObjData = (Map<String, Object>)JSON.deserializeUntyped(relatedObjData);
            if(mapRelatedObjData != null)
                relatedObjAPI = (String) mapRelatedObjData.get('relatedObjAPI');
        }
		
		if( (accRec.Id == null && (recordId == null || String.isBlank(recordId))) || (!String.isBlank(recordId) && relatedObjAPI == 'Agreement_Info__c') ) {
            if(!String.isBlank(recordId)) {
                accRec.Id = null;
            }                
			String createRecordId = createRecord(accRec, objectAPI, mapRelatedObjData, lkpFieldID, lkpFieldName);
			if(createRecordId != null && !String.isBlank(createRecordId))
				returnID = createRecordId;
        }
        else {
        	update accRec;
    	}
    
		return returnID;
    } 
    @AuraEnabled
    public static String getRecordTypeName(String RecordID){
        List<Account> AccountList = [select id, name, RecordType.DeveloperName, RecordType.name from Account where id =:RecordID limit 1];
        if(AccountList != null && AccountList.size() > 0)
            return AccountList[0].RecordType.DeveloperName;
        else
            return '';
    }
	
     @AuraEnabled     
    public static boolean getObjAccess(String objectName){
      	Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);        
        DescribeSObjectResult  SobjResult = objectType.getDescribe();
        Boolean objAccess = SobjResult.isAccessible();       
        return objAccess;
    }
    
    
    
     @AuraEnabled     
    public static Case getIPSDetails(String accountId){
        System.debug('accountId'+accountId);
        Account accObj = [SELECT id, Family_Head_Name__c,(SELECT Id, worst_and_best_one_year_return_Non_Ind__c ,Alternative_Investments_Non_Ind__c, Amount_of_fluctuations_Non_Ind__c , Interest_leverage_products_Non_Ind__c ,Risk_Profile_Categories__c , recordtype.name , Family__c , isMainLead__c , Risk_Profile_same_as_Family_Head__c,Investment_philosophy__c,Equity_Markets__c,Age_RiskProfile__c,Financial_Goals__c,Investment_goal__c,Amount_of_fluctuations__c,worst_and_best_one_year_return__c,Interest_in_leverage_borrowing_products__c,Diversified_portfolio__c, Investment_portfolio__c,Alternative_Investments__c,Time_line_for_Trading__c,Investment_Style__c,Stop_Loss__c,Direct_Equity__c,Derivative__c,Mutual_Funds__c FROM Cases WHERE recordtype.name = 'Account Opening' LIMIT 1) FROM Account WHERE id=:accountId];
      	 System.debug('*****familyHead1'+accObj.Family_Head_Name__c);
        Account familyHead = [SELECT id  FROM ACCOUNT WHERE id=:accObj.Family_Head_Name__c];     
        System.debug('*****familyHead'+accObj.Family_Head_Name__c);
        if(familyHead != null){
                   Case cObj = [SELECT Id, worst_and_best_one_year_return_Non_Ind__c , Alternative_Investments_Non_Ind__c, Amount_of_fluctuations_Non_Ind__c , Interest_leverage_products_Non_Ind__c , recordtype.name , Risk_Profile_Categories__c , Family__c , isMainLead__c , Risk_Profile_same_as_Family_Head__c,Investment_philosophy__c,Equity_Markets__c,Age_RiskProfile__c,Financial_Goals__c,Investment_goal__c,Amount_of_fluctuations__c,worst_and_best_one_year_return__c,Interest_in_leverage_borrowing_products__c,Diversified_portfolio__c, Investment_portfolio__c,Alternative_Investments__c,Time_line_for_Trading__c,Investment_Style__c,Stop_Loss__c,Direct_Equity__c,Derivative__c,Mutual_Funds__c FROM Case WHERE recordtype.name = 'Account Opening' AND AccountId=:familyHead.id LIMIT 1];      
			System.debug('&******** case'+cObj);	
            return cObj;
        }
        return null;
    }
    @AuraEnabled     
    public static Account getAccountDetail(String accountId){
      	Account acc = new Account();
        
        List<Account> accList = [Select Id,(SELECT Id,worst_and_best_one_year_return_Non_Ind__c , Alternative_Investments_Non_Ind__c , Amount_of_fluctuations_Non_Ind__c , Interest_leverage_products_Non_Ind__c , Risk_Profile_Categories__c , recordtype.name , Family__c , isMainLead__c , Risk_Profile_same_as_Family_Head__c,Investment_philosophy__c,Equity_Markets__c,Age_RiskProfile__c,Financial_Goals__c,Investment_goal__c,Amount_of_fluctuations__c,worst_and_best_one_year_return__c,Interest_in_leverage_borrowing_products__c,Diversified_portfolio__c, Investment_portfolio__c,Alternative_Investments__c,Time_line_for_Trading__c,Investment_Style__c,Stop_Loss__c,Direct_Equity__c,Derivative__c,Mutual_Funds__c FROM Cases ),Primary_Email__c,PAN_Number__c,Phone,Address__c,Date_of_Birth__c , Client_Representative_Mobile_Number__c, RecordType.Name,Category__c  From Account Where Id =: accountId];
        if(accList != null && accList.size() > 0){
            acc = accList[0];
        }
        System.debug('@@@acc'+acc);
        return acc;
    }

}