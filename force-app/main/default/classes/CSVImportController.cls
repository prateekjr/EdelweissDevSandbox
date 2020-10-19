public class CSVImportController 
{
    public String[] csvFileLines{get;set;}
    public Blob csvFileBody{get;set;}
    
    public CSVImportController()
    {
        csvFileLines = new String[]{};
    }
    @AuraEnabled    
    public static void getCSVfileSaveDummy(){
        
    }
    
    @AuraEnabled    
    public static String getCSVfileSave(String picklistvalue, String fileName, String base64Data, String contentType, String fileId)//
    {
        string errorMessage;
        string csvAsString;
        String[] csvFileLines;
        
        //System.debug(base64Data + 'is now decoded as: ');
        Blob afterblob = EncodingUtil.base64Decode(base64Data);
        //System.debug(base64Data + 'is now decoded as: ' + afterblob.toString());
        csvAsString = afterblob.toString();
        csvFileLines = csvAsString.split('\n');
        //system.debug('csvFileLines File Data ----'+csvFileLines);
        //System.debug('picklistvalue is......' +picklistvalue);
        
        List<account> acclist;
        Account a;
        
        String strMappingObj;
        if(picklistvalue.containsIgnoreCase('NPS')){
            strMappingObj = 'NPS';
        } else if(picklistvalue.containsIgnoreCase('MonthlyTargetAuA')){
            strMappingObj = 'MonthlyTargetAuA';
        }else if(picklistvalue.containsIgnoreCase('R5TargetCount')){
            strMappingObj = 'R5TargetCount';
        }else if(picklistvalue.containsIgnoreCase('FARevenue')){
            strMappingObj = 'FARevenue';
        }else if(picklistvalue.containsIgnoreCase('ClientRevenue')){
            strMappingObj = 'ClientRevenue';
        }
        
        List<String> sequenceFields = new List<String>();
        List<System_Constant__mdt> lstFieldMapping = [
            SELECT DeveloperName,Mapping_Fields1__c,Mapping_Fields2__c,Mapping_Fields3__c,Value__c 
            FROM System_Constant__mdt 
            WHERE DeveloperName = :strMappingObj
        ];
        
        System.debug('lstFieldMapping=='+lstFieldMapping);    
        
        if(lstFieldMapping != null && lstFieldMapping.size()>0) {
            for(System_Constant__mdt fieldmap : lstFieldMapping){
                if(!String.isBlank(fieldmap.Mapping_Fields1__c))
                    sequenceFields.addAll(fieldmap.Mapping_Fields1__c.split(','));
                if(!String.isBlank(fieldmap.Mapping_Fields2__c))
                    sequenceFields.addAll(fieldmap.Mapping_Fields2__c.split(','));
                if(!String.isBlank(fieldmap.Mapping_Fields3__c))
                    sequenceFields.addAll(fieldmap.Mapping_Fields3__c.split(','));
            }
        }
        
        if(picklistvalue == 'NPS')
        {
            
            Set<Id> accountRecordTypeIdSet = new Set<Id>();
            accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId());
            accountRecordTypeIdSet.add(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId());
        
            Set<String> setOfClientCoad = new Set<String>();
            for(String strLine : csvFileLines){
                setOfClientCoad.add(strLine.split(',')[0]);
            }
            
            List<Account> lstAcounts = [
                SELECT Id, Name, GWM_Online_Id__c
                FROM Account 
                WHERE GWM_Online_Id__c IN :setOfClientCoad AND RecordTypeId IN :accountRecordTypeIdSet
            ];
            
            //System.debug('lstAcounts=='+lstAcounts);
            
            Map<String, Account> mapGWMAccounts = new Map<String, Account>();
            for(Account acc : lstAcounts){
                mapGWMAccounts.put(acc.GWM_Online_Id__c, acc);
            }
            
            List<Client_Satisfaction_Measurement__c> lstCSM = new List<Client_Satisfaction_Measurement__c>();
            Client_Satisfaction_Measurement__c objCSM;
            for(Integer i=1;i<csvFileLines.size();i++)
            {                       
                string[] csvRecordData = csvFileLines[i].split(',');
                Account accRecord = mapGWMAccounts.get(csvRecordData[0]);
                
                if(accRecord != null){
                    objCSM = new Client_Satisfaction_Measurement__c() ;
                    objCSM.Client_Name__c = accRecord.Id;
                    integer j = 0;
                    
                    for(string fieldAPI : sequenceFields){
                        
                        String strvalue = csvRecordData[j++];
                        strvalue = CSVImportController.getPlainString(strvalue);
                        if(fieldAPI == 'Client_Name__c' || strvalue == ''){
                            continue;
                        }
                        //System.debug(fieldAPI +' == '+ strvalue);
                        if(fieldAPI == 'Date_of_Call__c' )
                           objCSM.put(fieldAPI , Date.Parse(strvalue));
                        else
                            objCSM.put(fieldAPI , strvalue);
                    }
                    lstCSM.add(objCSM);
                }           
            }
            System.debug('lstCSM=='+lstCSM);
            if(!lstCSM.isEmpty()){
                insert lstCSM;
            }               
        }
        else if(picklistvalue == 'MonthlyTargetAuA' || picklistvalue == 'R5TargetCount')
        {
            Set<Id> setFaCxoId = new Set<Id>();
            Sys_Properties__c custSettFaProfileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
            Sys_Properties__c custSettFaFOIGProfileId = Sys_Properties__c.getValues('Profile Financial Advisor FOIG Id');
            Sys_Properties__c custSettTLAdvoisoryProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory Id');
            Sys_Properties__c custSettTLAdvoisoryFOIGProfileId = Sys_Properties__c.getValues('Profile Team Leader Advisory FOIG Id');
            Sys_Properties__c custSettRegionalHeadProfileId = Sys_Properties__c.getValues('Profile Regional Head Id');
            
            setFaCxoId.add(custSettFaProfileId.Value__c);
            setFaCxoId.add(custSettFaFOIGProfileId.Value__c);
            setFaCxoId.add(custSettTLAdvoisoryProfileId.Value__c);
            setFaCxoId.add(custSettTLAdvoisoryFOIGProfileId.Value__c);
            setFaCxoId.add(custSettRegionalHeadProfileId.Value__c);

            // collect all FA Profile Users
            List<User> lstUsers = new List<User>();
            Map<String, User> mapFaUser = new Map<String, User>();
            For(User objUserFA : [Select Id, Name, Edelweiss_Employee_Id__c, Miles_Id__c From User where ProfileId =:setFaCxoId AND Edelweiss_Employee_Id__c!=null AND Miles_Id__c!=null])
            {
                mapFaUser.put(objUserFA.Edelweiss_Employee_Id__c+objUserFA.Miles_Id__c, objUserFA);
            }
            
            for(Integer i=1;i<csvFileLines.size();i++)
            {                       
                String[] csvRecordData = csvFileLines[i].split(',');
                
                User objUser = mapFaUser.get(csvRecordData[0] + csvRecordData[2]);
                
                if(objUser != null){
                    integer j = 0;
                    for(string fieldAPI : sequenceFields){
                        
                        String strvalue = csvRecordData[j++];
                        strvalue = CSVImportController.getPlainString(strvalue);
                        //System.debug(fieldAPI +' == '+ strvalue);
                        
                        if(fieldAPI == 'Name' || fieldAPI == 'Edelweiss_Employee_Id__c' || fieldAPI == 'Miles_Id__c' || strvalue == ''){
                            continue;
                        }
                        
                        if(fieldAPI == 'Monthly_Target_Upload_Date__c'){
                            objUser.put(fieldAPI , date.parse( strvalue));
                        }else if(strvalue.isNumeric()){
                            objUser.put(fieldAPI , decimal.valueOf( strvalue));
                        }else{
                            objUser.put(fieldAPI , strvalue);
                        } 
                    }
                    lstUsers.add(objUser);
                }           
            }
            
            if(!lstUsers.isEmpty()){
                update lstUsers;
            }               
        }
        else if(picklistvalue == 'FARevenue')
        {
            //Delete old error records
            List<Edelweiss_Error_Log__c> lstErrorDelete = [SELECT ID FROM Edelweiss_Error_Log__c WHERE Related_Object_Name__c = 'FA_Revenue__c' LIMIT 10000];
            if(!lstErrorDelete.isEmpty()){
                delete lstErrorDelete;
            }
            User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
            Map<String, FA_Revenue__c> mapFaRevenue = new Map<String, FA_Revenue__c>();
            Set<Date> dates = new Set<Date>();
            List<Edelweiss_Error_Log__c> lstError = new List<Edelweiss_Error_Log__c>();
            
            Map<String, User> mapFaUser = new Map<String, User>();
            For(User objUserFA : [SELECT Id, Name, Edelweiss_Employee_Id__c FROM User WHERE Edelweiss_Employee_Id__c!=null])
            {
                mapFaUser.put(objUserFA.Edelweiss_Employee_Id__c, objUserFA);
            }
            
            for(Integer i=1;i<csvFileLines.size();i++)
            {                       
                String[] csvRecordData = csvFileLines[i].split(',');                
                FA_Revenue__c  newRecord = New FA_Revenue__c();
                String error = '';
                String employeeId = csvRecordData[0];
                if(String.isNotBlank(employeeId)){
                    newRecord.put('Edelweiss_Employee_Id__c', employeeId);
                    User objUser = mapFaUser.get(employeeId);
                    if(objUser != null){
                        newRecord.put('Financial_Adviser__c' , objUser.Id);
                        newRecord.put('OwnerId' , objUser.Id);
                    } else {
                        newRecord.put('OwnerId' , defaultOwner.Id);
                    }
                }else{
                    error = 'FA Employee Id is required   ';                    
                }
                integer j = 0;
                for(string fieldAPI : sequenceFields){                  
                    String strvalue = null;
                    try{
                        strvalue = csvRecordData[j++];
                    }catch(Exception e){
                        
                    }
                    strvalue = CSVImportController.getPlainString(strvalue);
                    if(fieldAPI == 'Edelweiss_Employee_Id__c'){
                        continue;
                    }                        
                    if(fieldAPI == 'Name'){
                        newRecord.put('CSV_FA_Name__c', strvalue);
                    } else if(fieldAPI == 'Revenue_Date__c'){
                        if(String.isNotBlank(strvalue)){
                            try {
                                Date dt = date.parse(strvalue.replace('-', '/'));
                                dates.add(dt);
                                newRecord.put(fieldAPI , dt);
                            } catch (Exception e){
                                error += 'Invalid Revenue Date - ' + strvalue  + '   ';
                            }
                        }else{
                             error += 'Invalid Revenue Date - ' + strvalue  + '   ';
                        }
                    }else if(fieldAPI == 'Revenue_Amount__c'){
                        if(String.isNotBlank(strvalue)){
                            try{
                                newRecord.put(fieldAPI, decimal.valueOf(strvalue));
                            }catch(Exception e) {
                                error += 'Invalid Revenue Amount - ' + strvalue  + '   ';
                            }
                        }else{
                             error += 'Invalid Revenue Amount - ' + strvalue  + '   ';
                        }
                    }                   
                }
                    
                if(newRecord.Revenue_Date__c != null && newRecord.Edelweiss_Employee_Id__c != null && String.isBlank(error)){
                    mapFaRevenue.put(newRecord.Revenue_Date__c+'_'+newRecord.Edelweiss_Employee_Id__c, newRecord);
                }
                if(String.isNotBlank(error)){
                    Edelweiss_Error_Log__c errLog = new Edelweiss_Error_Log__c();
                    errLog.Error_Details__c = error;
                    errLog.Error_Source__c = String.valueOf(csvRecordData);
                    errLog.Error_Occurred_In__c = 'FA Revenue Upload';
                    errLog.Related_Object_Name__c = 'FA_Revenue__c';
                    lstError.add(errLog);
                }
            }
            
            Map<String, Fa_Revenue__c> existingRevenueRecords = new Map<String, Fa_Revenue__c>();
            for(Fa_Revenue__c rev : [SELECT Id, Edelweiss_Employee_Id__c, Revenue_Date__c FROM Fa_Revenue__c WHERE Revenue_Date__c IN :dates]){
                existingRevenueRecords.put(rev.Revenue_Date__c+'_'+rev.Edelweiss_Employee_Id__c, rev);
            }
            
            for(String key : mapFaRevenue.keySet()){
                Fa_Revenue__c existingRecord = existingRevenueRecords.get(key);
                if(existingRecord != null){
                    mapFaRevenue.get(key).Id = existingRecord.Id;
                }
            }
            if(!mapFaRevenue.isEmpty()){
                Database.UpsertResult [] urList = database.upsert(mapFaRevenue.values(),false);
                if(urList.size() > 0 ){
                    Integer index = 0; 
                    for (Database.UpsertResult ur : urList){
                        if(!ur.isSuccess()){
                            for(Database.Error err : ur.getErrors()) {
                                Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
                                exceptionRec.Error_Details__c = err.getMessage();
                                exceptionRec.Error_Source__c = String.valueOf(mapFaRevenue.values()[index]);
                                exceptionRec.Error_Occurred_In__c = 'FA Revenue Upload';
                                exceptionRec.Related_Object_Name__c = 'FA_Revenue__c';                            
                                lstError.add(exceptionRec);
                            }
                        }
                        index++;
                    }
                }
            }
            if(!lstError.isEmpty()){
                errorMessage = 'Some records are failed, for detais please check FA Revenue Error Report.';
                insert lstError;
            }
        }
        else if(picklistvalue == 'ClientRevenue')
        {
            //Delete old error records
            List<Edelweiss_Error_Log__c> lstErrorDelete = [SELECT ID FROM Edelweiss_Error_Log__c WHERE Related_Object_Name__c = 'Client_Revenue__c' LIMIT 10000];
            if(!lstErrorDelete.isEmpty()){
                delete lstErrorDelete;
            }
            User defaultOwner = [SELECT Id FROM User WHERE Name = 'PWM SalesForceUpdate' LIMIT 1 ];
            Map<String, Client_Revenue__c> mapClientRevenue = new Map<String, Client_Revenue__c>();
            Set<Date> dates = new Set<Date>();
            List<Edelweiss_Error_Log__c> lstError = new List<Edelweiss_Error_Log__c>();
            
            Map<String, Account> mapClient = new Map<String, Account>();
            For(Account acc : [SELECT Id, ParentId, Pan_Number__c, OwnerId FROM Account WHERE RecordType.Name = 'Client'])
            {
                mapClient.put(acc.Pan_Number__c, acc);
            }
            
            for(Integer i=1;i<csvFileLines.size();i++)
            {                       
                String[] csvRecordData = csvFileLines[i].split(',');                
                Client_Revenue__c  newRecord = New Client_Revenue__c();
                String error = '';
                String strPan = csvRecordData[0];
                
                if(String.isNotBlank(strPan)){
                    newRecord.put('PAN__c', strPan);
                    Account client = mapClient.get(strPan);
                    if(client != null){
                        newRecord.put('Client__c', client.Id);
                        newRecord.put('Family__c', client.ParentId);
                        newRecord.put('OwnerId' , client.OwnerId);
                    } else {
                        newRecord.put('OwnerId' , defaultOwner.Id);
                    }
                }else {
                    error = 'PAN is required   ';
                }
                
                integer j = 0;
                for(string fieldAPI : sequenceFields){                  
                    String strvalue = null;
                    try{
                        strvalue = csvRecordData[j++];
                    }catch(Exception e){
                        
                    }
                    strvalue = CSVImportController.getPlainString(strvalue);
                    if(fieldAPI == 'PAN__c'){
                        continue;
                    } 
                    if(fieldAPI == 'Client__c' && String.isNotBlank(strvalue)){
                        newRecord.put('CSV_Client_Name__c' , strvalue);
                    } else if(fieldAPI == 'Revenue_Date__c'){
                        if(String.isNotBlank(strvalue)){
                            try {
                                Date dt = date.parse(strvalue.replace('-', '/'));
                                dates.add(dt);
                                newRecord.put(fieldAPI , dt);
                            } catch (Exception e){
                                error += 'Invalid Revenue Date - ' + strvalue  + '   ';
                            }
                        }else{
                             error += 'Invalid Revenue Date - ' + strvalue  + '   ';
                        }
                    }else if(fieldAPI == 'Revenue_Amount__c'){
                        if(String.isNotBlank(strvalue)){
                            try{
                        newRecord.put(fieldAPI , decimal.valueOf( strvalue));
                            }catch(Exception e) {
                                error += 'Invalid Revenue Amount - ' + strvalue  + '   ';
                            }
                    }else{
                             error += 'Invalid Revenue Amount - ' + strvalue  + '   ';
                    }
                    }                  
                }                   
                
                if(newRecord.Revenue_Date__c != null && newRecord.PAN__c != null && String.isBlank(error)){
                    mapClientRevenue.put(newRecord.Revenue_Date__c+'_'+newRecord.PAN__c, newRecord);
                }                   
                if(String.isNotBlank(error)){
                    Edelweiss_Error_Log__c errLog = new Edelweiss_Error_Log__c();
                    errLog.Error_Details__c = error;
                    errLog.Error_Source__c = String.valueOf(csvRecordData);
                    errLog.Error_Occurred_In__c = 'Client Revenue Upload';
                    errLog.Related_Object_Name__c = 'Client_Revenue__c';
                    lstError.add(errLog);
                }
            }
            
            Map<String, Client_Revenue__c> existingRevenueRecords = new Map<String, Client_Revenue__c>();
            for(Client_Revenue__c rev : [SELECT Id, Revenue_Date__c, PAN__c FROM Client_Revenue__c WHERE Revenue_Date__c IN :dates]){
                existingRevenueRecords.put(rev.Revenue_Date__c+'_'+rev.PAN__c, rev);
            }               
        
            for(String key : mapClientRevenue.keySet()){
                Client_Revenue__c existingRecord = existingRevenueRecords.get(key);
                if(existingRecord != null){
                    mapClientRevenue.get(key).Id = existingRecord.Id;
        }
            }
            System.debug('existingRevenueRecords.size() 111: '+existingRevenueRecords.size());
            System.debug('mapClientRevenue.size() 111: '+mapClientRevenue.size());
        
            if(!mapClientRevenue.isEmpty()){
                Database.UpsertResult [] urList = database.upsert(mapClientRevenue.values(),false);
                if(urList.size() > 0 ){
                    Integer index = 0; 
                    for (Database.UpsertResult ur : urList){
                        if(!ur.isSuccess()){
                            for(Database.Error err : ur.getErrors()) {
                                Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
                                exceptionRec.Error_Details__c = err.getMessage();
                                exceptionRec.Error_Source__c = String.valueOf(mapClientRevenue.values()[index]);
                                exceptionRec.Error_Occurred_In__c = 'Client Revenue Upload';
                                exceptionRec.Related_Object_Name__c = 'Client_Revenue__c';                            
                                lstError.add(exceptionRec);
                            }
                        }
                        index++;
                    }
                }
            }
            if(!lstError.isEmpty()){
                errorMessage = 'Some records are failed, for detais please check Client Revenue Error Report.';
                insert lstError;
            }
            System.debug('error ><>< '+lstError.size());
        }
        return errorMessage;
    } 
    
    public static string getPlainString(String strToken){
        if(!string.isBlank(strToken)){
            strToken = strToken.replace('\\n\\r', ' ');     // remove CRLF
            strToken = strToken.replace('\\n', ' ');        // remove LF    
            strToken = strToken.replace('\\r', ' ');        // remove CR
            strToken = strToken.replace('\\', ' ');         // remove slashes       
            strToken = strToken.normalizeSpace();           // Remove all repeating white space 
        }else{
            strToken = '';
        }           
        
        return strToken;
    }
    
    @AuraEnabled
    public static String generateReportURL(String reportName){
        string baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        List<Report> reports  = [SELECT Id FROM Report WHERE DeveloperName =: reportName LIMIT 1];
        if(!reports.isEmpty()){
            return baseURL+reports[0].Id;
        }
        return '';
    }
    @AuraEnabled
    public static String faRevenueErrorReportId(){
        List<Report> reports  = [SELECT Id FROM Report WHERE DeveloperName = 'FA_Revenue_Error_Report' LIMIT 1];
        if(!reports.isEmpty()){
            return reports[0].Id;
        }
        return '';
    }
    
}