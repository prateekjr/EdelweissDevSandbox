/**
 * (c) Tony Scott. This code is provided as is and without warranty of any kind.
 *
 * This work by Tony Scott is licensed under a Creative Commons Attribution 3.0 Unported License.
 * http://creativecommons.org/licenses/by/3.0/deed.en_US
 */

 /**
 * Apex Controller for looking up an SObject via SOSL
 */
public with sharing class LookupSObjectController 
{
    
     @AuraEnabled
    public static String getObjectLabel(String objectName){
        String[] types = new String[]{objectName};
        Schema.DescribeSobjectResult[] describeSobjectsResult = Schema.describeSObjects(types);
        String ObjectLabel = describeSobjectsResult[0].getLabelPlural(); 
        return ObjectLabel;
    }
    
    @AuraEnabled
    public static Result[] getLoggedInUserDetails(){
        List<Result> results = new List<Result>();
        results.add(new Result(UserInfo.getName(), UserInfo.getUserId() , ''));
        return results;
    }
    
    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, string fieldAPIName, String ChildObject, String recordId, String filter)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String queryLimit = '100'; //[select value__c from MEDNAX_Config__mdt where DeveloperName = 'Max_Records_In_Lookup_Dropdown' limit 1].value__c;
        List<Result> results = new List<Result>();
        String searchQuery = '';
        String filterString = '';
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectAPIName);
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        
        /*List<Lookup_Filter__mdt> lkfList = new List<Lookup_Filter__mdt>();
        system.debug('ChildObject-----'+ChildObject+'--Parent_Object__c--'+sanitizedSObjectAPIName+'--Lookup_Field__c---'+fieldAPIName+'--sObjectAPIName---'+sObjectAPIName);
        lkfList = [select Child_Object__c,Lookup_Field__c,Parent_Object__c,Filter_String__c from Lookup_Filter__mdt where Child_Object__c =: ChildObject and Parent_Object__c =: sanitizedSObjectAPIName and Lookup_Field__c =: fieldAPIName limit 1];
        if(lkfList != null && lkfList.size() > 0){
            filterString = lkfList[0].Filter_String__c;
        }*/
        system.debug('filter=='+filter);
        system.debug('ChildObject=='+ChildObject);
        if(filter != null && filter != ''){
            //filterString += ' AND AccountId = \''+recordId+'\'';
            system.debug('filter=='+filter);
            if(filter == 'NewFamily'){
               filterString = 'RecordType.DeveloperName=\'Lead\' And Coverage__c=\'R2\'';   
            }else if(filter == 'NewClient'){
               filterString = 'RecordType.DeveloperName=\'Family\'';   
            }else{
               filterString = 'RecordType.DeveloperName=\'Client\'';   
            }
        }   
        Boolean hasRecType = false;
        if (infos != null && infos.size() > 1){
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable() && !i.isMaster()){
                    hasRecType = true;
                    break;
                }
            }
        } 
        if(filterString != ''){
            filterString = ' where '+filterString;
        }  

        if(sanitizedSObjectAPIName == 'Service_Line__c'){
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name, ServiceLocation_ID__r.Name'+filterString+' ) Limit '+queryLimit;    
        }else if(hasRecType){
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,RecordType.Name'+filterString+' ) Limit '+queryLimit; 
        }else{
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name'+filterString+' ) Limit '+queryLimit; 
        }

        System.debug('----------------------------------->>'+searchQuery);
        
        // Execute the Query
        List<List<SObject>> searchList = search.query(searchQuery);

        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
             String recTypeValue='';            
             if(fieldAPIName=='flagship_hospital__c'){
                recTypeValue = (string)so.get('City_State__c') != null? (string)so.get('City_State__c'):'';
             }else if(sanitizedSObjectAPIName == 'Service_Line__c'){
                recTypeValue = so.get('ServiceLocation_ID__c') != null ? (String)so.getSobject('ServiceLocation_ID__r').get('Name') : '';
             }else{         
                recTypeValue += (hasRecType && so.getSobject('RecordType')  != null ?  (String)so.getSobject('RecordType').get('Name') : '');
            }
            System.debug(recTypeValue);
            results.add(new Result((String)so.get('Name'), so.Id , recTypeValue));
        }
        
        return results;
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'CBSA__c' and Name='All'];
        return listviews;
    }
    
    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
        @AuraEnabled public String subHeaderText {get; set;}
        
        public Result(String sObjectLabel, Id sObjectId,String subHeaderText)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
            this.subHeaderText = subHeaderText;
        }
    }
}