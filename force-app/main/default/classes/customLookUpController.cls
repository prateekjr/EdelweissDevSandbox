public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord,List<sObject> listOfFilteredRecords,String ObjectName) {
        
        
        Set<ID> filteredIDs = new Set<ID>();
        
        if(listOfFilteredRecords.size() != 0){
            for(sObject rec : listOfFilteredRecords){
                filteredIDs.add(rec.Id);
            }            
        }
        
        
        
        String searchKey = '%' + searchKeyWord + '%';
        
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery = '';
        if(listOfFilteredRecords.size() != 0){
            if(filteredIDs.size() != 0){
                sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND id IN : filteredIDs LIMIT 5';
            }else{
                sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey LIMIT 5';
            }
        }
        
        if(sQuery != ''){
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        
        return returnList;
    }
    
    
   
   /* @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value , String selectedRecordAMC , String criteriaField , String selectedFromSchemeObj) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        List<RecordsData> recordsDataList1 = new List<RecordsData>();
        
        if(filterField == 'AMC_Code__c') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                }
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
        }
        
        
        if(filterField == 'Scheme_Name__c' & criteriaField == ''){
            try {
                                map<String , String > mapOfString = new  map<String , String >();
                String Purchase_Allowed = 'Y';
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Purchase_Allowed__c =\'' + Purchase_Allowed + '\' AND  Id = \''+ value + '\' AND AMC_Code__c =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Purchase_Allowed__c =\'' + Purchase_Allowed + '\' AND AMC_Code__c = \'' + selectedRecordAMC + '\'  LIMIT 49999';
                }
                for(SObject s : Database.query(query)) {
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
        }
        
        if(filterField == 'Scheme_Name__c' & criteriaField == 'ToScheme'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' AND Scheme_Name__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND AMC_Code__c = \'' + selectedRecordAMC + '\' AND Scheme_Name__c  != \'' + selectedFromSchemeObj + '\'  LIMIT 49999';
                }
                
               for(SObject s : Database.query(query)) {
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
            
        }
        
        if(filterField == 'CLIENT_CODE__c'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id , ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '%\' AND FIRST_APPLICANT_PAN__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND FIRST_APPLICANT_PAN__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                }
                
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }            
            
        }
        
        if(filterField == 'Folio_Number__c'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id , ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '%\' AND  Client_Account__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND  Client_Account__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                }
                
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }      
            
        }
        
        
        
        return null;   
    }
    
    
    
     @AuraEnabled
    public static List<RecordsData> fetchRecordsDeleteMethod(String objectName, String filterField, String searchString, String value , String selectedRecordAMC , String criteriaField , String selectedFromSchemeObj) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        List<RecordsData> recordsDataList1 = new List<RecordsData>();
        
        if(filterField == 'AMC_Code__c') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                }
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
        }
        
        
        if(filterField == 'Scheme_Name__c' & criteriaField == ''){
            try {
                
                
                
                
                
                
                
                 map<String , String > mapOfString = new  map<String , String >();
                String Purchase_Allowed = 'Y';
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Purchase_Allowed__c =\'' + Purchase_Allowed + '\' AND  Id = \''+ value + '\' AND AMC_Code__c =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Purchase_Allowed__c =\'' + Purchase_Allowed + '\' AND AMC_Code__c = \'' + selectedRecordAMC + '\'  LIMIT 49999';
                }
                for(SObject s : Database.query(query)) {
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
        }
        
        if(filterField == 'Scheme_Name__c' & criteriaField == 'ToScheme'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' AND Scheme_Name__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND AMC_Code__c = \'' + selectedRecordAMC + '\' AND Scheme_Name__c  != \'' + selectedFromSchemeObj + '\'  LIMIT 49999';
                }
                
               for(SObject s : Database.query(query)) {
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
            
        }
        
        if(filterField == 'CLIENT_CODE__c'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id , ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '%\' AND FIRST_APPLICANT_PAN__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND FIRST_APPLICANT_PAN__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                }
                
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }            
            
        }
        
        if(filterField == 'Folio_Number__c'){
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id , ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '%\' AND  Client_Account__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND  Client_Account__c  =\'' + selectedRecordAMC + '\' LIMIT 49999';
                }
                
                for(SObject s : Database.query(query)) {
                    // recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }          
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }      
            
        }
        
        
        
        return null;   
    }*/
    
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}