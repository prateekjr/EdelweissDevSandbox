public class CustomListSearchController {
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
    
    
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value , String selectedRecordAMC , String criteriaField , String selectedFromSchemeObj ,
                                                 Order_Entry__c orderEntry,String SchemeSelect,string ipoType, string selectedClientLead) {
        
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
        
        if(filterField == 'productISIN__c') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    
                    if(orderEntry.Product_Type_Order_Entry__c.equals('Bond')){
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  IN (\'Bonds (Others)\',\'Bonds (Tax Free)\', \'Debt - Others\',\'Warrants - Direct Debt\') LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){    
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  IN (\'Bonds (Others)\',\'Bonds (Tax Free)\', \'Debt - Others\',\'Warrants - Direct Debt\') AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';                                                         
                        }
                     
                    }else if(orderEntry.Product_Type_Order_Entry__c.equals('SP')){
                        
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  LIKE \'%Structured Products%\' LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  IN(\'Structured Products - Equity\',\'Structured Products - Debt\') AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';  
                            
                            
                        }
                      
                    }else if(orderEntry.Product_Type_Order_Entry__c.equals('CP')){
                        
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  =\'CP\' LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c = \'CP\' AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';  
                            
                            
                        }
                       
                    }else if(orderEntry.Product_Type_Order_Entry__c.equals('CD')){
                       
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  =\'CD\' LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c = \'CD\' AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';  
                            
                            
                        }
                        
                    }else if(orderEntry.Product_Type_Order_Entry__c.equals('FD')){
                       
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  = \'FDs\' LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  = \'FDs\' AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';  
                            
                            
                        }
                     
                    }else if(orderEntry.Product_Type_Order_Entry__c.equals('ICD')){
                       
                        if(orderEntry.Transaction_Type__c.equals('Buy')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  = \'ICDs\' LIMIT 49999';    
                        }else if(orderEntry.Transaction_Type__c.equals('Sell')){
                            query += ' WHERE '+filterField+
                                ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  = \'ICDs\' AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                                +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';  
                            
                            
                        }
                        System.debug('SP QUERY=== '+query);  
                    }
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
        if(filterField == 'productCodeName__c') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    
                    if(orderEntry.Transaction_Type__c.equals('Subscription (New)')){
                        query += ' WHERE '+filterField+
                            ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  LIKE \'%PMS%\' LIMIT 49999';    
                    }else if(! orderEntry.Transaction_Type__c.equals('Subscription')){
                        
                        query += ' WHERE '+filterField+
                            ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  LIKE \'%PMS%\' AND Id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c=\''
                            +orderEntry.Client_Account__c +'\' AND Annual_Record__c = false) LIMIT 49999';                                                      
                    }    
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
        
        if(filterField == 'Name' && objectName != 'Account') { 
            
            System.debug('Inside alretnative== value '+value);
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    System.debug('Inside else part');
                    if(orderEntry.Transaction_Type__c.equals('Log Commitment') ){
                        query += ' WHERE '+filterField+
                            ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  LIKE \'%Alternatives %\' LIMIT 49999';    
                    }
                    
                    else if(orderEntry.Transaction_Type__c.equals('Close Out') || orderEntry.Transaction_Type__c.equals('Log Drawdown') || orderEntry.Transaction_Type__c.equals('Withdrawal')){
						
                        List<Order_Entry__c> orderEntryList = [Select Id, InternalPEID__c,Product_lookup__c, Security_Name_Display__c from  Order_Entry__c  WHERE Client_Account__c=:orderEntry.Client_Account__c
                                                           AND Transaction_Type__c ='Log Commitment' AND InternalPEID__c != NULL AND 	Plutus_Order_Id__c != null ];
                        System.debug('orderEntryList :'+orderEntryList);
                         System.debug('orderEntryList :'+orderEntryList.size());
                        set<id> securityList = new set<id>();							
                        for(Order_Entry__c ord : orderEntryList)
                        {
                            securityList.add(ord.Product_lookup__c);
                        }
            			System.debug('securityList :'+securityList);
                                                                         
                        query += ' WHERE '+filterField+
                            ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c  LIKE \'%Alternatives %\' AND Id IN :securityList LIMIT 49999';                                                      
                    } else{
                        query += ' LIMIT 49999';
                    }                     
                    
                }
                System.debug('query == '+query);
                for(SObject s : Database.query(query)) {
                    mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                }
                for(String key : mapOfString.keySet()){
                    recordsDataList.add(new RecordsData(key,mapOfString.get(key)));
                }  
                System.debug('recordsDataList Size== '+recordsDataList.size());
                
                return recordsDataList;
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
        }
        
        if(filterField == 'BSEStarSchemeName__c' & criteriaField == '' && SchemeSelect=='All'){
            System.debug('**** Insideee All' );
                String transactionFilter;
                List<Id> productList = new List<Id> ();
                    if(orderEntry.Transaction_Type__c == 'Redemption'){
                        transactionFilter = 'BSEStarRedemptionAllowed__c';
                   }else if(orderEntry.Transaction_Type__c == 'Switch'){
                       transactionFilter = 'BSEStarSwitchFLAG__c';
                    }
                     
                try{
                    map<String , String > mapOfString = new  map<String , String >();
                    String Allowed = 'Y';
                    set<RecordsData> recordsDataset = new set<RecordsData>();
                    String query = 'SELECT Id, MilesSchemeCode__c , BSEStarRedemptionTransactionMode__c, ' + filterField + ' FROM '+objectName;
                    if(String.isNotBlank(value)) {
                        query += ' WHERE '+transactionFilter+'=\'' + Allowed + '\' AND  Id = \''+ value + '\' AND BSEStarAMCCode__c =\'' + selectedRecordAMC + '\' AND BSEStarRedemptionTransactionMode__c IN (\'DP\',\'P\') LIMIT 49999';
                    } else {
                        query += ' WHERE '+filterField+
                            ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+transactionFilter+'=\'' + Allowed + '\' AND BSEStarAMCCode__c = \'' + selectedRecordAMC + '\' AND BSEStarRedemptionTransactionMode__c IN (\'DP\',\'P\') LIMIT 49999';
                    }
                    System.debug('************** 12 query'+query);
                    
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

}//Main If close
        
        if(filterField == 'BSEStarSchemeName__c' & criteriaField == '' && SchemeSelect !='All'){
            if(orderEntry.Transaction_Type__c == 'Purchase'){
                String transactionFilter;
                List<Id> productList = new List<Id> ();
                try{
                    transactionFilter = 'BSEStarPurchaseAllowed__c';
                    map<String , String > mapOfString = new  map<String , String >();
                    String Allowed = 'Y';
                    set<RecordsData> recordsDataset = new set<RecordsData>();
                    String query = 'SELECT Id, MilesSchemeCode__c , BSEStarPurchaseTransactionmode__c, ' + filterField + ' FROM '+objectName;
                    if(String.isNotBlank(value)) {
                        query += ' WHERE '+transactionFilter+'=\'' + Allowed + '\' AND  Id = \''+ value + '\' AND BSEStarAMCCode__c =\'' + selectedRecordAMC + '\' AND BSEStarPurchaseTransactionmode__c IN (\'DP\',\'P\') LIMIT 49999';
                    } else {
                        query += ' WHERE '+filterField+
                            ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+transactionFilter+'=\'' + Allowed + '\' AND BSEStarAMCCode__c = \'' + selectedRecordAMC + '\' AND BSEStarPurchaseTransactionmode__c IN (\'DP\',\'P\') LIMIT 49999';
                    }
                    System.debug('*** query'+query);
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
                
            }else{
                String transactionFilter;
                List<Id> productList = new List<Id> ();
                Map<String,String> scripkeyMap = new Map<String,String>();
                if(orderEntry.Client_Account__c != null){
                    for(Client_Asset_Information__c caObj : [SELECT id , Client_Account__c , Product__c ,Scrip_Key__c FROM Client_Asset_Information__c where Client_Account__c =: orderEntry.Client_Account__c AND Sub_Asset_Class__c Like '%Mutual Fund%' limit 49999]){
                        productList.add(caObj.Product__c);
                        scripkeyMap.put(caObj.Scrip_Key__c,caObj.Scrip_Key__c);
                    }
                    if(orderEntry.Transaction_Type__c == 'Redemption'){
                        transactionFilter = 'BSEStarRedemptionAllowed__c';
                    }else if(orderEntry.Transaction_Type__c == 'Switch'){
                        transactionFilter = 'BSEStarSwitchFLAG__c';
                    }
                }  
                try{
                    map<String , String > mapOfString = new  map<String , String >();
                    String Allowed = 'Y';
                    set<RecordsData> recordsDataset = new set<RecordsData>();
                    String query = 'SELECT Id, MilesSchemeCode__c , BSEStarRedemptionTransactionMode__c ,' + filterField + ' FROM '+objectName;
                    if(String.isNotBlank(value)) {
                        query += ' WHERE '+transactionFilter+'=\'' + Allowed + '\' AND  Id = \''+ value + '\' AND BSEStarAMCCode__c =\'' + selectedRecordAMC + '\' AND BSEStarRedemptionTransactionMode__c IN (\'DP\',\'P\') LIMIT 49999';
                    } else {
                        query += ' WHERE '+filterField+
                            ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+transactionFilter+'=\'' + Allowed + '\' AND BSEStarAMCCode__c = \'' + selectedRecordAMC + '\' AND BSEStarRedemptionTransactionMode__c IN (\'DP\',\'P\') LIMIT 49999';
                    }
                    System.debug(' ** redumption query '+query);
                    
                    for(SObject s : Database.query(query)) {
                        if(scripkeyMap.get(((String)s.get('MilesSchemeCode__c'))) != null){
                            mapOfString.put(((String)s.get(filterField)),((String)s.get('id')));
                        }
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
        }
        
        if(filterField == 'BSEStarSchemeName__c' & criteriaField == 'ToScheme' && SchemeSelect!='All'){
            String transactionFilter;
            List<Id> productList = new List<Id> ();
            //List<String> scripkeyList = new List<String>();
            Map<String,String> scripkeyMap = new Map<String,String>();
            String BSESchemePlan = '';
            List<Scheme_Mapping__c> schemeListObj = [SELECT id , BSESchemePlan__c , BSEStarSchemeName__c FROM Scheme_Mapping__c WHERE BSEStarSchemeName__c=:selectedFromSchemeObj AND BSEStarSwitchFLAG__c = 'Y' AND BSEStarRedemptionTransactionMode__c IN ('DP','P')	 LIMIT 1];
            if(schemeListObj!=null && !schemeListObj.isEmpty()) {
                if(schemeListObj[0].BSESchemePlan__c != null){
                    BSESchemePlan = schemeListObj[0].BSESchemePlan__c;
                }
            }
            
            if(orderEntry.Client_Account__c != null){
                for(Client_Asset_Information__c caObj : [SELECT id , Client_Account__c , Product__c ,Scrip_Key__c FROM Client_Asset_Information__c where Client_Account__c =: orderEntry.Client_Account__c AND Sub_Asset_Class__c Like '%Mutual Fund%' limit 49999]){
                    productList.add(caObj.Product__c);
                    scripkeyMap.put(caObj.Scrip_Key__c,caObj.Scrip_Key__c);
                }
                
                if(orderEntry.Transaction_Type__c == 'Purchase'){
                    transactionFilter = 'BSEStarPurchaseAllowed__c';
                }else if(orderEntry.Transaction_Type__c == 'Redemption'){
                    transactionFilter = 'BSEStarRedemptionAllowed__c';
                }else if(orderEntry.Transaction_Type__c == 'Switch'){
                    transactionFilter = 'BSEStarSwitchFLAG__c';
                }
            }  
            try{
                map<String , String > mapOfString = new  map<String , String >();
                String Allowed = 'Y';
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, BSESchemePlan__c  , MilesSchemeCode__c , BSEStarPurchaseTransactionmode__c, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE '+transactionFilter+'=\'' + Allowed + '\' AND  Id = \''+ value + '\' AND BSEStarAMCCode__c =\'' + selectedRecordAMC + '\' AND BSEStarPurchaseTransactionmode__c IN (\'DP\',\'P\')  LIMIT 49999';
                } else {
                    if(BSESchemePlan == ''){
                        query += ' WHERE '+filterField+
                            ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+transactionFilter+'=\'' + Allowed + '\' AND BSEStarAMCCode__c = \'' + selectedRecordAMC + '\' AND BSEStarSchemeName__c  != \'' + selectedFromSchemeObj + '\' AND BSEStarPurchaseTransactionmode__c IN (\'DP\',\'P\')  LIMIT 49999';
                        
                    }else{
                        query += ' WHERE '+filterField+
                            ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND '+transactionFilter+'=\'' + Allowed + '\' AND BSEStarAMCCode__c = \'' + selectedRecordAMC + '\' AND BSEStarSchemeName__c  != \'' + selectedFromSchemeObj + '\' AND BSESchemePlan__c  = \'' + BSESchemePlan + '\' AND BSEStarPurchaseTransactionmode__c IN (\'DP\',\'P\') LIMIT 49999';
                    }
                }
                System.debug('*** *** $$squery'+query);
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


			if(filterField == 'Manufacturer_Name__c' && objectName == 'product2') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String subAssetClassValue = 'Mutual';
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Sub_Asset_Class__c LIKE \'%'+subAssetClassValue+'%\' LIMIT 49999';
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
        
        if(filterField == 'Name__c') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                    ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND Type__c LIKE \'%'+ipoType+'%\' LIMIT 49999';
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
                if(filterField == 'Name' && objectName == 'Account') { 
            try {
                map<String , String > mapOfString = new  map<String , String >();
                set<RecordsData> recordsDataset = new set<RecordsData>();
                String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                    ' LIKE' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND RecordTypeId  IN (SELECT id FROM RecordType WHERE Name =\'' +selectedClientLead +'\') LIMIT 49999';  
                }
                System.debug('query :'+query);
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
        return null;   
    }
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}