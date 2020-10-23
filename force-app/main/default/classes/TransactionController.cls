public with sharing class TransactionController {
    public static Id attachId;
    public static  Integer popUpCounter= 0;
    public static String attachmentName;
    public static Map<String, String> mapOfFields = new Map<String, String>();
    public static Id orderId;
    public static String drawDownDueDateField;
    public static String adjustedDrawDownDueDateField;
    public static String productCcyField;
    public static String drawDownAmtStrField;
    public static String drawDownAmtPaidTillDateStrField;
    public static String drawDownAmtDueStrField;  
    public static String InvestIdRefreshApi;  
    public static String schemeCodeRefreshApi; 
    public static String refreshApiError='';

    public static List<refreshApiWrapper>  wrapList= new List<refreshApiWrapper>();
    
    @AuraEnabled
    public static List<Account> getClientInformation(Id familyId){
        if(familyId != null){ 
            List<Account> clientObj = [SELECT id ,owner.id,owner.name, Parent.id, Parent.Name , name , Risk_Profile_Based_on_IPS__c ,Primary_FA__c , Demat_Account_Number__c , Pan_Number__c FROM Account where Parent.id=:familyId];            
            return clientObj;
        }
        return null;
    }    
    
    @AuraEnabled
    public static List<Account> getFilteredFamilyRecords(){
            set<string> plutusFamilyCode = new set<string>();
            for(Plutus_Family_Details__c plutusFamily : [SELECT id ,Family_Code__c,Family_Name__c  FROM Plutus_Family_Details__c] )
            {
                plutusFamilyCode.add(plutusFamily.Family_Code__c);
                System.debug('plutusFamilyCode :'+plutusFamilyCode);
            }
            if(plutusFamilyCode.size() > 0)
            {
             List<Account> clientObj = [SELECT id ,owner.id,owner.name, Parent.id,GWM_Online_Id__c, Parent.Name , name , Risk_Profile_Based_on_IPS__c ,Primary_FA__c , Demat_Account_Number__c , Pan_Number__c FROM Account where GWM_Online_Id__c in :plutusFamilyCode];            
            System.debug('clientObj :'+clientObj);
                return clientObj;
            }                                                                                                   
        return null;
    }   

    @AuraEnabled
    public static List<Account> getFilteredFamilyRecordsMF(){
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
            List<Account> clientObj = [SELECT id ,owner.id,owner.name, Parent.id,GWM_Online_Id__c, Parent.Name , name , Risk_Profile_Based_on_IPS__c ,Primary_FA__c , Demat_Account_Number__c , Pan_Number__c FROM Account where recordTypeId=:devRecordTypeId];            
            return clientObj;                                                                                              
    }
    
    
    
    @AuraEnabled
    public static Boolean getClientInformationorderentery(Id familyId){
        Boolean isfound=false;
        if(familyId != null){
            Account acc = [SELECT id ,owner.id,owner.name, GWM_Online_Id__c FROM Account where id=:familyId limit 1];
            List<Plutus_Family_Details__c> oderentryformf = [SELECT id ,Family_Code__c,Family_Name__c  FROM Plutus_Family_Details__c where Family_Code__c = :acc.GWM_Online_Id__c];    
            if(oderentryformf.size() > 0){
                isfound= true;
                
            }
            
            
            
            return isfound;
        }
        return isfound;
    }   
    
    @AuraEnabled
    public static String getStringsDate(){        
        String dateFormatString = 'dd-MMM-yyyy';
        Date todayDate = Date.today();
        Datetime formatDate = Datetime.newInstance(todayDate.year(), todayDate.month(),todayDate.day());
        String dateString = formatDate.format(dateFormatString);
        return dateString;
    }
    @AuraEnabled
    public static Date getTodaysDate(){
        
        Date dt = system.today();
        return dt;
    }
    
    @AuraEnabled
    public static List<Client_Account__c> getClientAccountInformation(Id clientId){
        if(clientId != null){ 
            List<Client_Account__c> clientAccountObj = [SELECT id , Client__c FROM Client_Account__c where Client__r.id=:clientId];
            return clientAccountObj;
        } 
        return null;
    }
    
    
    @AuraEnabled
    public static Product2 getProductDetailsFromMappings(String schemeName){
        
        
        Scheme_Mapping__c smObj = [SELECT id , BSEStarSchemeName__c,BSEStarSchemeCode__c, MilesSchemeCode__c , MilesSchemeName__c from Scheme_Mapping__c where BSEStarSchemeName__c=:schemeName limit 1];        
        if(smObj != null){
            Product2 prodObj = [SELECT id , Name ,ProductCode , Risk_Profile_of_Product__c from Product2 WHERE ProductCode=:smObj.MilesSchemeCode__c AND Sub_Asset_Class__c like '%Mutual%' limit 1];		
            return prodObj;
        }
        return null;
    }
    
    @AuraEnabled
    public static Product2 getProductDetailsFromMappingsOE(id productid){
        
        
        if(productid != null){
            Product2 prodObj = [SELECT id , Name ,ProductCode ,SchemeType__c, Risk_Profile_of_Product__c from Product2 WHERE id=:productid AND Sub_Asset_Class__c like '%Mutual%' limit 1];		
            return prodObj;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Product2> getClientProducts(Id clienAccountId){
        if(clienAccountId != null){
            List<product2> listOfProducts = [SELECT id , name ,Risk_Profile_of_Product__c ,  Face_Value__c ,Source_Id__c,Sub_Asset_Class__c	 FROM Product2 WHERE id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clienAccountId AND Annual_Record__c = false)];
            return listOfProducts;
        }
        return null;
    } 
    
    
    /**************************************************************
// Method Name: getDependentMap
// Purpose: To get dependent values of particular picklist value
***************************************************************/
    //-----------START_OF_CODE-------------//
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    @AuraEnabled
    public static List<BSE_STAR_UCC__c> getUCCMasterData(Id clientId){
        if(clientId != null){ 
            Account  clientObj = [SELECT id , Pan_Number__c FROM Account where id=:clientId];
            if(clientObj != null){
                if(clientObj.Pan_Number__c != null){
                    List<BSE_STAR_UCC__c> bseObject =  [SELECT FIRST_APPLICANT_NAME__c	,FIRST_APPLICANT_PAN__c , SECOND_APPLICANT_NAME__c , THIRD_APPLICANT_NAME__c , CDSLCLTID__c , CLIENT_CODE__c ,CLIENT_HOLDING__c, CLIENT_TYPE__c , CLIENT_DEFAULT_DP__c, CLIENT_NOMINEE__c, NSDLCLTID__C FROM BSE_STAR_UCC__c where FIRST_APPLICANT_PAN__c=:clientObj.Pan_Number__c ];
                    return bseObject;
                }else{
                    return null;
                }
            }else{
                return null;
            }
        } 
        return null;
    }
    
    @AuraEnabled
    public static Client_Asset_Information__c getClientAssetInfo(Id clientAccountId , Id productId){
        if(clientAccountId != null && productId != null){
            Client_Asset_Information__c clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false];
            return clientAssetList;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static List<Schema_Master__c> getAmcCode(){
        Map<String , Schema_Master__c> mapOfSchema = new Map<String , Schema_Master__c>();
        Set<String> amcCode = new Set<String>();
        for(Schema_Master__c masterObj:[SELECT id ,AMC_Code__c ,Scheme_Code__c FROM Schema_Master__c]){
            if(masterObj.AMC_Code__c != null){
                mapOfSchema.put(masterObj.AMC_Code__c ,masterObj);
                amcCode.add(masterObj.AMC_Code__c);
            }
        }
        return mapOfSchema.values();
    }
    
    @AuraEnabled
    public static List<Schema_Master__c> getSchemeController(String amcCode){
        List<Schema_Master__c> schemaMaster =[SELECT id ,AMC_Code__c ,Scheme_Code__c , Scheme_Name__c FROM Schema_Master__c where AMC_Code__c =:amcCode AND Purchase_Allowed__c = 'Y'];
        return schemaMaster;
    }
    
    @AuraEnabled
    public static BSE_STAR_UCC__c getClientHoldingInfo(String clientCode){
        BSE_STAR_UCC__c bseObject =  [SELECT FIRST_APPLICANT_PAN__c , SECOND_APPLICANT_NAME__c , THIRD_APPLICANT_NAME__c , CDSLCLTID__c , CLIENT_CODE__c ,CLIENT_HOLDING__c, CLIENT_TYPE__c , CLIENT_DEFAULT_DP__c, CLIENT_NOMINEE__c, NSDLCLTID__C, CLIENT_EMAIL__c FROM BSE_STAR_UCC__c where CLIENT_CODE__c=:clientCode ];
        
        return bseObject;
    }
    
    @AuraEnabled
    public static  List<product2> getSchemeName(String FolioNumber){
        list<Id> productList = new  list<Id>();
        List<Client_Asset_Information__c> clientAssetList =  [SELECT id , Folio_Number__c ,Product__c From Client_Asset_Information__c where Folio_Number__c =:FolioNumber AND Sub_Asset_Class__c Like '%Mutual Fund%'];
        for(Client_Asset_Information__c cObj : clientAssetList){
            if(cObj.Product__c != null)
                productList.add(cObj.Product__c);
        }	
        List<product2> prodList = [select id , name , Risk_Profile_of_Product__c  FROM product2 where id in:productList];
        return prodList;
    }
    @AuraEnabled
    public static  List<product2> getSchemeNameRedemption(String selectedClientAcc){
        list<Id> productList = new  list<Id>();
        List<Client_Asset_Information__c> clientAssetList =  [SELECT id , Client_Account__c ,Product__c From Client_Asset_Information__c where Client_Account__c =:selectedClientAcc AND Sub_Asset_Class__c Like '%Mutual Fund%' ];
        for(Client_Asset_Information__c cObj : clientAssetList){
            if(cObj.Product__c != null)
                productList.add(cObj.Product__c);
        }	
        List<product2> prodList = [select id , name , Risk_Profile_of_Product__c  FROM product2 where id in:productList];
        return prodList;
    }
    /* @AuraEnabled
public static  String getEuinDetails(String faId ,Order_Entry__c orderEntry ){
User userObj = [SELECT id , Edelweiss_Employee_Id__c FROM user where id=:faId limit 1];
Map<String, Integer> monthMap = new Map<String, Integer>();
monthMap.put('Jan',01);monthMap.put('Feb',02);monthMap.put('Mar',03);monthMap.put('Apr',04);monthMap.put('May',05);monthMap.put('Jun',06);
monthMap.put('Jul',07);monthMap.put('Aug',08);monthMap.put('Sep',09);monthMap.put('Oct',10);monthMap.put('Nov',11);monthMap.put('Dec',12);
If(userObj != null){
String employeeId = userObj.Edelweiss_Employee_Id__c;
EUIN_Master__c euinObj =  [select id , EMP_Code__c ,Emp_EUIN_Number__c ,Valid_From__c , Valid_To__c FROM EUIN_Master__c where EMP_Code__c=:employeeId limit 1];
//System.debug(s1.substringBetween('-'));
//System.debug(s1.substringBefore('-')
//
if(euinObj != null){
if(euinObj.Valid_From__c != '' && euinObj.Valid_To__c != ''){
Date valueDate = system.today();
String ValidFrom = euinObj.Valid_From__c;
String ValidTo = euinObj.Valid_To__c;

Date Valid_From = date.newInstance(Integer.valueOf('20'+ValidFrom.substringAfterLast('-')), Integer.valueOf(monthMap.get(ValidFrom.substringBetween('-'))),Integer.valueOf(ValidFrom.substringBefore('-')));
Date Valid_To = date.newInstance(Integer.valueOf('20'+ValidTo.substringAfterLast('-')), Integer.valueOf(monthMap.get(ValidTo.substringBetween('-'))),Integer.valueOf(ValidTo.substringBefore('-')));

System.debug('Valid_From'+Valid_From);
System.debug('Valid_To'+Valid_To);

if(valueDate > Valid_From && valueDate < Valid_To){
return euinObj.Emp_EUIN_Number__c;
}else{
return '77777';
}
}
}
return '';
}
return null;
}
*/
    
    /*@AuraEnabled
public static  EUIN_Master__c getEuinDetails(String faId){
User userObj = [SELECT id , Edelweiss_Employee_Id__c FROM user where id=:faId limit 1];
If(userObj != null){
String employeeId = userObj.Edelweiss_Employee_Id__c;
EUIN_Master__c euinObj =  [select id , EMP_Code__c , Emp_EUIN_Number__c FROM EUIN_Master__c where EMP_Code__c=:employeeId limit 1];
return euinObj;
}
return null;
}*/
    
    @AuraEnabled
    public static  String getEuinDetails(String faId ,Order_Entry__c orderEntry ){
        User userObj = [SELECT id , Edelweiss_Employee_Id__c FROM user where id=:faId limit 1];
        Map<String, Integer> monthMap = new Map<String, Integer>();
        monthMap.put('Jan',01);monthMap.put('Feb',02);monthMap.put('Mar',03);monthMap.put('Apr',04);monthMap.put('May',05);monthMap.put('Jun',06);
        monthMap.put('Jul',07);monthMap.put('Aug',08);monthMap.put('Sep',09);monthMap.put('Oct',10);monthMap.put('Nov',11);monthMap.put('Dec',12);
        OrderEntrySchem__c defaultEUIN = OrderEntrySchem__c.getInstance('Euindefault');
        String defaultEUINObj = defaultEUIN.value__c;
        
        If(userObj != null){
            String employeeId = userObj.Edelweiss_Employee_Id__c;
            EUIN_Master__c euinObj =  [select id , EMP_Code__c ,Emp_EUIN_Number__c ,Valid_From__c , Valid_To__c FROM EUIN_Master__c where EMP_Code__c=:employeeId limit 1];
            //System.debug(s1.substringBetween('-'));
            //System.debug(s1.substringBefore('-')
            //
            if(euinObj != null){
                if(euinObj.Valid_From__c != '' && euinObj.Valid_To__c != ''){
                    Date valueDate = system.today();
                    String ValidFrom = euinObj.Valid_From__c;
                    String ValidTo = euinObj.Valid_To__c;
                    
                    Date Valid_From = date.newInstance(Integer.valueOf('20'+ValidFrom.substringAfterLast('-')), Integer.valueOf(monthMap.get(ValidFrom.substringBetween('-'))),Integer.valueOf(ValidFrom.substringBefore('-')));
                    Date Valid_To = date.newInstance(Integer.valueOf('20'+ValidTo.substringAfterLast('-')), Integer.valueOf(monthMap.get(ValidTo.substringBetween('-'))),Integer.valueOf(ValidTo.substringBefore('-')));
                    
                    
                    if(valueDate > Valid_From && valueDate < Valid_To){
                        
                        return euinObj.Emp_EUIN_Number__c;
                    }else{
                        
                        return defaultEUINObj;
                    }
                }
            }
            return '';
        }
        return '';
    }
    
    public static Id getRecordTypeId(String productType, String transactionType,Boolean isoderentryMF){
        Id recordTypeId;
        String fetchRecordTypeId; 
        if(productType.equals('Bond') || productType.equals('SP') ||  productType.equals('CP') || productType.equals('CD') || productType.equals('FD') || productType.equals('ICD') ){
            fetchRecordTypeId = transactionType;		            
        }
        /* else if(transactionType.equals('SIP') || transactionType.equals('SWP') ||  transactionType.equals('STP')){
fetchRecordTypeId = 'MF_OrderEntry';		            
} */
        
        else if(isoderentryMF && !(transactionType.equals('SIP') || transactionType.equals('SWP') ||  transactionType.equals('STP')))
        {
            if(transactionType.equals('Purchase') || transactionType.equals('Redemption') ||  transactionType.equals('Switch'))
            {
                fetchRecordTypeId = productType + '_' + transactionType +'_OE';
            }
        }else if(productType.equals('PE / AIF'))
        {           
            System.debug('Inside PE/AIF');
            fetchRecordTypeId = 'PE_AIF_' + transactionType;            
        }
        else 
        {
            System.debug('Inside Else');
            fetchRecordTypeId = productType + '_' + transactionType;
        }
        System.debug('fetchRecordTypeId=== '+fetchRecordTypeId);	
        if(fetchRecordTypeId != ''){
            if(fetchRecordTypeId.equals('PMS_Subscription (New)')){
                fetchRecordTypeId = 'PMS_Subscription_New';
            }else if(fetchRecordTypeId.equals('PMS_Top Up') || fetchRecordTypeId.equals('PMS_Withdrawal') || fetchRecordTypeId.equals('PMS_Close Out')){
                fetchRecordTypeId = 'PMS_Other';
            }
            recordTypeId = Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get(fetchRecordTypeId).getRecordTypeId();
            System.debug('recordTypeId :'+recordTypeId);
        }
        return recordTypeId;
    }
    
    
    @AuraEnabled
    public static String saveObj(Order_Entry__c orderEntryObj, Boolean isoderentryMF){
        
        System.debug('isoderentryMF :'+isoderentryMF);
        System.debug('orderEntryObj.Product_Type_Order_Entry__c :'+orderEntryObj.Product_Type_Order_Entry__c);
        System.debug('orderEntryObj.Transaction_Type__c :'+orderEntryObj.Transaction_Type__c);
        orderEntryObj.RecordTypeId = TransactionController.getRecordTypeId(orderEntryObj.Product_Type_Order_Entry__c ,orderEntryObj.Transaction_Type__c,isoderentryMF );
        
        
        orderEntryObj.Transaction_Amount_Financial_Transaction__c = string.valueof(orderEntryObj.Transaction_Amount_Financial_Transaction__c);
        orderEntryObj.Commitment_Amount__c = string.valueof(orderEntryObj.Commitment_Amount__c);
        
        orderEntryObj.Family_Name__r=null;
        orderEntryObj.Order_Date__c = system.today();
        orderEntryObj.Value_Date__c = system.today();
        orderEntryObj.Value_Date_API__c = DateTime.Now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        if(orderEntryObj.Order_Date__c != null){
            Integer d = orderEntryObj.Order_Date__c.day();
            Integer mo = orderEntryObj.Order_Date__c.month();
            Integer yr = orderEntryObj.Order_Date__c.year();
            DateTime DT = DateTime.newInstance(yr, mo, d);
            orderEntryObj.Order_Date_API__c = DT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        }
        
        if(orderEntryObj.End_Date__c != null){
            Integer d = orderEntryObj.End_Date__c.day();
            Integer mo = orderEntryObj.End_Date__c.month();
            Integer yr = orderEntryObj.End_Date__c.year();
            DateTime DT = DateTime.newInstance(yr, mo, d);
            orderEntryObj.End_Date_API__c = DT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        }
        if(orderEntryObj.Start_Date__c != null){
            Integer d = orderEntryObj.Start_Date__c.day();
            orderEntryObj.Start_Date_Day_API__c=string.valueof(d);
            Integer mo = orderEntryObj.Start_Date__c.month();
            Integer yr = orderEntryObj.Start_Date__c.year();
            DateTime DT = DateTime.newInstance(yr, mo, d);
            orderEntryObj.Start_Date_API__c = DT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        }
        
        
        orderEntryObj.Status__c='Preview Mode'; //'Pending For Review';
        
        /*Logic for soft/hard cutoff Time Start*/
        /*DateTime now = DateTime.now();
//Double currentTime = Double.valueOf(now.hour()+'.'+now.minute());
Double currentTime = 14.40;
OrderEntrySchem__c settingVal = OrderEntrySchem__c.getInstance('SoftCuttOffTime');
Double softCuttoffTime = decimal.valueOf(settingVal.value__c);

OrderEntrySchem__c settingVal1 = OrderEntrySchem__c.getInstance('HardCuttOffTime');
Double hardCuttoffTime = decimal.valueOf(settingVal1.value__c);*/
        
        
        if(orderEntryObj.Folio__c == null){
            System.debug('Folio Null 1');
            orderEntryObj.Folio__c = 'New';            
        }        
        if(orderEntryObj.Folio__c == 'New'){
            System.debug('Folio New 2');
            orderEntryObj.Folio_Blank__c = '';
        } else {
            System.debug('Folio Blank');
            orderEntryObj.Folio_Blank__c = orderEntryObj.Folio__c;
        }
        
        if(!isoderentryMF)
        {
            
            if(orderEntryObj.Transaction_Type__c == 'Purchase' || orderEntryObj.Transaction_Type__c =='Redemption'){
                List<Scheme_Mapping__c> schemeMappingList = [SELECT MilesSchemeName__c , BSEStarSchemeName__c	FROM Scheme_Mapping__c WHERE BSEStarSchemeName__c  =:orderEntryObj.Scheme__c LIMIT 1];
                
                if(schemeMappingList!=null && !schemeMappingList.isEmpty()) {
                    if(schemeMappingList[0].MilesSchemeName__c != ''){
                        orderEntryObj.Miles_Scheme_Name__c = schemeMappingList[0].MilesSchemeName__c;
                    }
                }
            }else if(orderEntryObj.Transaction_Type__c == 'Switch'){
                List<Scheme_Mapping__c> fromSchemeMappingList = [SELECT MilesSchemeName__c , BSEStarSchemeName__c	FROM Scheme_Mapping__c WHERE BSEStarSchemeName__c  =:orderEntryObj.From_Scheme__c LIMIT 1];
                if(fromSchemeMappingList!=null && !fromSchemeMappingList.isEmpty()) {
                    if(fromSchemeMappingList[0].MilesSchemeName__c != ''){
                        orderEntryObj.From_Miles_Scheme_Name__c = fromSchemeMappingList[0].MilesSchemeName__c;
                    }
                }
                
                List<Scheme_Mapping__c> toSchemeMappingList = [SELECT MilesSchemeName__c , BSEStarSchemeName__c	FROM Scheme_Mapping__c WHERE BSEStarSchemeName__c  =:orderEntryObj.To_Scheme__c LIMIT 1];
                if(toSchemeMappingList!=null && !toSchemeMappingList.isEmpty()) {
                    if(toSchemeMappingList[0].MilesSchemeName__c != ''){
                        orderEntryObj.To_Miles_Scheme_Name__c = toSchemeMappingList[0].MilesSchemeName__c;
                    }
                }
                
                
                
            }
        }
        
        
        // insert orderEntryObj;
        list<Order_Entry__c> listOfOrderEntry = new list<Order_Entry__c> ();
        list<Attachment> attachmentLst = new list<Attachment>();
        list<Attachment> deleatchtLst = new list<Attachment>();
        
        
        /*Code to fetch the schemecode for export ends*/
        if(orderEntryObj.Transaction_Type__c == 'Purchase'){
            orderEntryObj.Transaction_Amount_Export__c = orderEntryObj.Transaction_Amount_Financial_Transaction__c; 
            //orderEntryObj.MIN_redemption_flag_default__c = 'N';
        }
        /*Code for Redemption Starts*/
        if(orderEntryObj.Transaction_Type__c == 'Switch' || orderEntryObj.Transaction_Type__c =='Redemption'){
            if(orderEntryObj.Redemption_Type__c =='All Unit'){
                orderEntryObj.All_Units_blank__c ='Y';
                orderEntryObj.All_Units__c='Y';
                orderEntryObj.Redemption_Units_Blank__c = '';
                orderEntryObj.Transaction_Amount_Export__c = '';
                /*orderEntryObj.Redemption_Units__c='';
orderEntryObj.Transaction_Amount_Financial_Transaction__c = '';*/
            } else if(orderEntryObj.Redemption_Type__c == 'Partial Amount'){
                orderEntryObj.All_Units_blank__c ='N'; // Need To Ask it should be blank
                orderEntryObj.All_Units__c='N';
                orderEntryObj.Redemption_Units__c='';// Need To Ask should be blank
                orderEntryObj.Redemption_Units_Blank__c = '';
                orderEntryObj.Transaction_Amount_Export__c = orderEntryObj.Transaction_Amount_Financial_Transaction__c;
                //orderEntryObj.Transaction_Amount_Financial_Transaction__c = ''; // Need To Ask it should be selected
            }else if(orderEntryObj.Redemption_Type__c == 'Partial Unit'){
                orderEntryObj.All_Units_blank__c ='N';  
                orderEntryObj.All_Units__c='N';
                orderEntryObj.Redemption_Units_Blank__c = orderEntryObj.Redemption_Units__c;
                orderEntryObj.Transaction_Amount_Financial_Transaction__c = ''; // Need To Ask it should be selected
                orderEntryObj.Transaction_Amount_Export__c='';
            }
        }
        /*Code for Redemption Ends*/
        
        /*Code for CreationPEID Starts */
        if(orderEntryObj.Product_Type_Order_Entry__c == 'PE / AIF' && (orderEntryObj.Transaction_Type__c == 'Log Drawdown' || orderEntryObj.Transaction_Type__c == 'Withdrawal' || orderEntryObj.Transaction_Type__c == 'Close Out')){           
            List<product2>  prodCodeList = [Select ProductCode from product2 where id =: orderEntryObj.Product_lookup__c];            
            List<Client_Account__c>  clientAccountList = [Select Name from Client_Account__c where id =: orderEntryObj.Client_Account__c];            
            List<Order_Entry__c> oeCreationList = [Select Id, InternalPEID__c from  Order_Entry__c 
                                                   WHERE
                                                   Client_Account_Display__c =: clientAccountList[0].Name
                                                   AND 
                                                   ProductCode__c =: prodCodeList[0].ProductCode
                                                   AND 
                                                   Transaction_Type__c =: 'Log Commitment' AND InternalPEID__c <> null Limit 1];
            orderEntryObj.CreationPEID__c = oeCreationList[0].InternalPEID__c;                
        }
        
        /*Code for CreationPEID Ends */
        listOfOrderEntry.add(orderEntryObj);
        
        Database.SaveResult[] srList = Database.insert(listOfOrderEntry, false);
        Integer statusFlag = 0;
        Id saveId;
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                List<Attachment> atch = [Select Id,ParentId,Name,Body,ContentType from Attachment where Id=:listOfOrderEntry[0].AttachmentId__c];
                
                for(Attachment attachObj: atch){
                    Attachment oAttachment = new Attachment();       
                    oAttachment.ParentId = sr.getId();
                    oAttachment.Name = attachObj.Name;
                    oAttachment.Body = attachObj.Body;
                    oAttachment.ContentType = attachObj.ContentType;
                    attachmentLst.add(oAttachment);
                    deleatchtLst.add(attachObj);
                }
                
                statusFlag = 1;
                saveId =  sr.getId();
            }else {
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('objErr.getMessage()'+objErr.getMessage());
                    return 'Error # '+objErr.getMessage();
                    // Printing error message in Debug log                    
                }
            } 
        }
        
        if(statusFlag == 1){
            insert attachmentLst;
            delete deleatchtLst;
            return saveId;
            /*if((currentTime >= softCuttoffTime && currentTime<hardCuttoffTime) && popUpCounter == 0){
System.debug('Inside Nav Popup Message');
popUpCounter++;
return 'softCuttOff';
}else if(currentTime > hardCuttoffTime && currentTime< 15.0){
System.debug('Inside No Order Place....');
return 'hardCuttOff';
}else{
System.debug('Inside Save Successfully');
return saveId;
}*/
        }
        return '';
        
    }
    @AuraEnabled
    public static Order_Entry__c setDisplayValues(Order_Entry__c orderEntryObj){
        
        /* if(orderEntryObj != null){
orderEntryObj.RecordTypeId = TransactionController.getRecordTypeId(orderEntryObj.Product_Type_Order_Entry__c ,orderEntryObj.Transaction_Type__c );
if( orderEntryObj.Family_Name__c != null){
Account family = [Select id , Name from Account where id =:orderEntryObj.Family_Name__c ];
orderEntryObj.Family_Name_Display__c = family.Name;
}
if( orderEntryObj.Client_Name__c != null){
Account client = [Select id , Name from Account where id =:orderEntryObj.Client_Name__c];
orderEntryObj.Client_Name_Display__c = client.Name;
}

if( orderEntryObj.Client_Account__c != null){
Client_Account__c clientAccount = [Select id , Name from Client_Account__c where id =:orderEntryObj.Client_Account__c];
orderEntryObj.Client_Account_Display__c = clientAccount.Name;
}
if( orderEntryObj.Client_Account_Lookup__c != null){
product2 productItem = [Select id , Name from product2 where id =:orderEntryObj.Client_Account_Lookup__c];
orderEntryObj.Scheme_Name__c = productItem.Name;
}

return orderEntryObj;


}*/
        return null;
    }
    
    @AuraEnabled
    public static String setFamilyName(Order_Entry__c orderEntryObj){
        if( orderEntryObj.Family_Name__c != null){
            Account family = [Select id , Name from Account where id =:orderEntryObj.Family_Name__c ];
            return family.Name;
            //orderEntryObj.Family_Name_Display__c = family.Name;
        }
        return '';
    }
    
    @AuraEnabled
    public static String setClientName(Order_Entry__c orderEntryObj){
        if( orderEntryObj.Client_Name__c != null){
            Account client = [Select id , Name from Account where id =:orderEntryObj.Client_Name__c];
            return client.Name;
            //orderEntryObj.Client_Name_Display__c = client.Name;
        }
        return '';
        
    } 
    @AuraEnabled
    public static String setIPOCode(string  IPOName){
        if( IPOName != null){
            IPO_Master__c ipoMaster = [Select id ,code__c  from IPO_Master__c where name__c=:IPOName];
            return ipoMaster.code__c; 
            //orderEntryObj.Client_Name_Display__c = client.Name;
        }
        return '';
        
    }
    @AuraEnabled
    public static String setClientAccountName(Order_Entry__c orderEntryObj){
        if( orderEntryObj.Client_Account__c != null){
            Client_Account__c clientAccount = [Select id , Name from Client_Account__c where id =:orderEntryObj.Client_Account__c];
            return clientAccount.Name;
            // orderEntryObj.Client_Account_Display__c = clientAccount.Name;
        }
        return '';
    }
    @AuraEnabled
    public static String setProductName(Order_Entry__c orderEntryObj){
        if( orderEntryObj.Product_lookup__c != null){
            product2 productItem = [Select id , Name from product2 where id =:orderEntryObj.Product_lookup__c];
            return productItem.Name;
            //orderEntryObj.Scheme_Name__c = productItem.Name;
        }
        return '';
    }
    /*  @AuraEnabled
public static List<Client_Asset_Information__c> getFolioNumbers(Id clientAccountId , Id productId){
if( clientAccountId != null && productId != null){
list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
return clientAssetList;
}
return null;
}*/
    
    @AuraEnabled
    public static List<Client_Asset_Information__c> getAssetDetailsByFolio(Id clientAccountId , Id productId, String holdingType,String folioNumber){
        if( clientAccountId != null && productId != null){
            List<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c=:folioNumber];
            if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                return clientAssetList;
            }
        }
        return null;
    }
    @AuraEnabled
    public static List<Client_Asset_Information__c> getFolioNumbers(Id clientAccountId , Id productId, String holdingType){
        
        System.debug('clientAccountId'+ clientAccountId);
        System.debug('productId'+ productId);
        System.debug('holdingType'+ holdingType);
        if( clientAccountId != null && productId != null){
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
            List<String> folioList = new  List<String> ();
            Map<String,FolioType__c> folioTypeMap = new  Map<String,FolioType__c> ();
            List<Client_Asset_Information__c> folioListReturn = new  List<Client_Asset_Information__c> ();
            Map<String,Client_Asset_Information__c> folioListReturnMap = new  Map<String,Client_Asset_Information__c> ();
            
            System.debug('clientAssetList :'+clientAssetList);
            if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                for(Client_Asset_Information__c cObj :clientAssetList){
                    folioList.add(cObj.Folio_Number__c);
                }
                System.debug('folioList :'+folioList);
                if(holdingType == 'Demat'){
                    if(folioList!=null && !folioList.isEmpty()){
                        List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                        for(FolioType__c fObj : folioType){
                            folioTypeMap.put(fObj.Folio__c , fObj);
                        }
                        for(Client_Asset_Information__c assetObj : clientAssetList){
                            if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                                folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);
                            }
                        }
                    }
                    return folioListReturnMap.values();
                }else if(holdingType == 'Physical'){
                    if(folioList!=null && !folioList.isEmpty()){
                        List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                        for(FolioType__c fObj : folioType){
                            folioTypeMap.put(fObj.Folio__c , fObj);
                        }
                        for(Client_Asset_Information__c assetObj : clientAssetList){
                            if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                            }else{
                                folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);                            }
                        }
                    }
                    return folioListReturnMap.values();
                }
            }
            return null;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Client_Asset_Information__c> getFolioNumbersPurchase(Id clientAccountId , String bseStarAmcCode , String holdingType){
        
        List<FolioToBlock__c> listOfBlackListedFolio = [SELECT id , Folio__c FROM FolioToBlock__c];
        Map<String , FolioToBlock__c> mapOfBlackListedFolio =new Map<String , FolioToBlock__c>();
        for(FolioToBlock__c fObj : listOfBlackListedFolio){
            if(fObj.Folio__c != null){
                mapOfBlackListedFolio.put(fObj.Folio__c  ,fObj );
            }
        }
        
        
        
        Set<String> listOfMilesAmc = new Set<String> ();
        List<Scheme_Mapping__c> smObjList = [SELECT id ,BSEStarAMCCode__c,BSEStarAMCName__c ,BSEStarSchemeName__c,BSEStarSchemeCode__c, MilesAMCCode__c , MilesSchemeName__c from Scheme_Mapping__c where BSEStarAMCCode__c =:bseStarAmcCode];        
        if(smObjList!=null && !smObjList.isEmpty()) {
            for(Scheme_Mapping__c smObj : smObjList){
                if(smObj.MilesAMCCode__c != null){
                    listOfMilesAmc.add(smObj.MilesAMCCode__c);
                }
            }
        }
        if(listOfMilesAmc!=null && !listOfMilesAmc.isEmpty()) {
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Amc_Code__c=:listOfMilesAmc AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
            if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                Set<String> folioList = new  Set<String> ();
                Map<String,FolioType__c> folioTypeMap = new  Map<String,FolioType__c> ();
                List<Client_Asset_Information__c> folioListReturn = new  List<Client_Asset_Information__c> ();
                Map<String,Client_Asset_Information__c> folioListReturnMap = new  Map<String,Client_Asset_Information__c> ();
                
                if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                    for(Client_Asset_Information__c cObj :clientAssetList){
                        folioList.add(cObj.Folio_Number__c);
                    }
                    
                    if(holdingType == 'Demat'){
                        if(folioList!=null && !folioList.isEmpty()){
                            List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                            for(FolioType__c fObj : folioType){
                                folioTypeMap.put(fObj.Folio__c , fObj);
                            }
                            for(Client_Asset_Information__c assetObj : clientAssetList){
                                if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                                    if(mapOfBlackListedFolio.get(assetObj.Folio_Number__c) == null){
                                        folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);
                                    }
                                }
                            }
                        }
                        return folioListReturnMap.values();
                    }else if(holdingType == 'Physical'){
                        if(folioList!=null && !folioList.isEmpty()){
                            List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                            for(FolioType__c fObj : folioType){
                                folioTypeMap.put(fObj.Folio__c , fObj);
                            }
                            for(Client_Asset_Information__c assetObj : clientAssetList){
                                if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                                }else{
                                    if(mapOfBlackListedFolio.get(assetObj.Folio_Number__c) == null){
                                        folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);
                                        folioListReturn.add(assetObj);
                                    }
                                    
                                }
                            }
                        }
                        
                        return folioListReturnMap.values();
                    }
                }
                return null;
            }
        }
        return null; 
    }
    
    /* @AuraEnabled
public static List<Client_Asset_Information__c> getFolioNumbersPurchase1(Id clientAccountId , String holdingType){
if( clientAccountId != null ){
List<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
List<String> folioList = new  List<String> ();
Map<String,FolioType__c> folioTypeMap = new  Map<String,FolioType__c> ();
List<Client_Asset_Information__c> folioListReturn = new  List<Client_Asset_Information__c> ();
if(clientAssetList!=null && !clientAssetList.isEmpty()) {
for(Client_Asset_Information__c cObj :clientAssetList){
folioList.add(cObj.Folio_Number__c);
}
if(holdingType == 'Demat'){
if(folioList!=null && !folioList.isEmpty()){
List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
for(FolioType__c fObj : folioType){
folioTypeMap.put(fObj.Folio__c , fObj);
}
for(Client_Asset_Information__c assetObj : clientAssetList){
if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
folioListReturn.add(assetObj);
}
}
}
return folioListReturn;
}else if(holdingType == 'Physical'){
if(folioList!=null && !folioList.isEmpty()){
List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
for(FolioType__c fObj : folioType){
folioTypeMap.put(fObj.Folio__c , fObj);
}
for(Client_Asset_Information__c assetObj : clientAssetList){
if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
}else{
folioListReturn.add(assetObj);
}
}
}
return folioListReturn;
}
}
return null;
}
return null;
}
*/
    @AuraEnabled
    public static List<Client_Asset_Information__c> getFoliosPurchaseForMFOE(Id clientAccountId , String bseStarAmcName , String holdingType){
        
        System.debug('bseStarAmcCode :'+bseStarAmcName);
        System.debug('clientAccountId :'+clientAccountId);
        System.debug('holdingType :'+holdingType);
        List<FolioToBlock__c> listOfBlackListedFolio = [SELECT id , Folio__c FROM FolioToBlock__c];
        Map<String , FolioToBlock__c> mapOfBlackListedFolio =new Map<String , FolioToBlock__c>();
        for(FolioToBlock__c fObj : listOfBlackListedFolio){
            if(fObj.Folio__c != null){
                mapOfBlackListedFolio.put(fObj.Folio__c  ,fObj );
            }
        }
        
        if(bseStarAmcName!= null && clientAccountId != null) {
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c ,Amc_Name__c, Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Amc_Name__c=:bseStarAmcName AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
            if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                Set<String> folioList = new  Set<String> ();
                Map<String,FolioType__c> folioTypeMap = new  Map<String,FolioType__c> ();
                List<Client_Asset_Information__c> folioListReturn = new  List<Client_Asset_Information__c> ();
                Map<String,Client_Asset_Information__c> folioListReturnMap = new  Map<String,Client_Asset_Information__c> ();
                
                if(clientAssetList!=null && !clientAssetList.isEmpty()) {
                    for(Client_Asset_Information__c cObj :clientAssetList){
                        folioList.add(cObj.Folio_Number__c);
                    }
                    if(holdingType != null)
                    {
                        if(holdingType == 'Demat'){
                            if(folioList!=null && !folioList.isEmpty()){
                                List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                                for(FolioType__c fObj : folioType){
                                    folioTypeMap.put(fObj.Folio__c , fObj);
                                }
                                for(Client_Asset_Information__c assetObj : clientAssetList){
                                    if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                                        if(mapOfBlackListedFolio.get(assetObj.Folio_Number__c) == null){
                                            folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);
                                        }
                                    }
                                }
                            }
                            return folioListReturnMap.values();
                        }else if(holdingType == 'Physical'){
                            if(folioList!=null && !folioList.isEmpty()){
                                List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
                                for(FolioType__c fObj : folioType){
                                    folioTypeMap.put(fObj.Folio__c , fObj);
                                }
                                for(Client_Asset_Information__c assetObj : clientAssetList){
                                    if(folioTypeMap.get(assetObj.Folio_Number__c) != null){
                                    }else{
                                        if(mapOfBlackListedFolio.get(assetObj.Folio_Number__c) == null){
                                            folioListReturnMap.put(assetObj.Folio_Number__c , assetObj);
                                            folioListReturn.add(assetObj);
                                        }
                                        
                                    }
                                }
                            }
                            
                            return folioListReturnMap.values();
                        }
                    }
                }
                return null;
            }
        }
        return null; 
    }
    /*Added code for  File Attachemnet */    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        attachId = oAttachment.id;
        
        return oAttachment.Id;
    }
    @TestVisible
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
    
    @AuraEnabled
    public static String getCurrentTime(){
        /* Datetime now = Datetime.now();
Integer offset = UserInfo.getTimezone().getOffset(now);
Datetime local = now.addSeconds(offset/1000);


System.debug('local== '+local.getTime());
return local.getTime();*/
        
        /*DateTime currentTime = System.now();
System.debug('Current Time === '+currentTime);
Time localTime = Time.newInstance(currentTime.hour(), currentTime.minute(), currentTime.second(), currentTime.millisecond());
return localTime;*/
        DateTime currentTime = System.now();
        String[] parts = currentTime.format().split(' ');
        return (parts.size() == 3) ? (parts[1] + ' ' + parts[2]) : parts[1]; 
    }
    
    @AuraEnabled
    public static  List<product2> getInstrumentName(String typeOfTxn, Id clienAccountId){
        
        //getClientProducts(clientAccountId)
        //getClientProducts
        //System.debug('clientAccountName=== '+clientAccountName);
        list<Id> productList = new  list<Id>();
        List<Client_Asset_Information__c> clientAssetList ;
        /*for(Client_Asset_Information__c cObj : clientAssetList){
if(cObj.Product__c != null)
productList.add(cObj.Product__c);
}	
//List<product2> prodList = [select id , name  FROM product2 where id in:productList];
*/
        
        List<product2> prodList;
        if(typeOfTxn.equals('Buy')){
            prodList = [select id , name  FROM product2 WHERE Sub_Asset_Class__c  like '%bonds%'];
        }else if(typeOfTxn.equals('Sell')){
            /*clientAssetList =  [SELECT product__c FROM client_asset_information__c WHERE Sub_Asset_Class__c  like '%bonds%' 
AND Client_Account__r.Name =: clientAccountName];
for(Client_Asset_Information__c cObj : clientAssetList){
if(cObj.Product__c != null){
productList.add(cObj.Product__c); 
}              
}*/
            prodList = getClientProducts(clienAccountId); //[select id , name  FROM product2 where id in:productList];
        }
        
        return prodList;
    }
    
    @AuraEnabled
    public static String fetchInstrumentName(Id selectedName){
        system.debug('===selectedName==== '+selectedName);
        return selectedName;
    }
    
    @AuraEnabled
    public static Client_Asset_Information__c fetchSellAUAQty(Id clientActID, String prodName){
        List<Client_Asset_Information__c> clientAsset = [SELECT Total_AUM__c,Quantity__c FROM Client_Asset_Information__c
                                                         WHERE Client_Account__c =: clientActID 
                                                         AND product__r.Name =: prodName];
        return clientAsset[0];
    }
    
    @AuraEnabled
    public static Product2 fetchProductRiskonISIN(String ISIN){
        List<product2> listOfProducts = [SELECT id , Risk_Profile_of_Product__c 
                                         FROM Product2 WHERE productISIN__c =:ISIN];
        return listOfProducts[0];
    }
    
    @AuraEnabled
    public static Id gerAttachementParentId(){
        List<Corporate_Action_Notification__c> notification = [SELECT Id FROM Corporate_Action_Notification__c Limit 1];
        return notification[0].Id;
        
    }
    @AuraEnabled
    public static List<Client_Asset_Information__c> getFolioPMS(Id clientAccountId , String prodCode){
        List<Client_Asset_Information__c> clientRiskList = [SELECT Folio_Number__c FROM Client_Asset_Information__c 
                                                            WHERE Client_Account__c =: clientAccountId
                                                            AND Product__r.ProductCode =:prodCode
                                                            AND Folio_Number__c != ''];
        return clientRiskList;    
    }
    
    @AuraEnabled
    public static String getPMSAccountTYpe(Id clientAccountId){
        List<Client_Account__c> clientAccount = [select Id,Name,Account_Type__c from Client_Account__c where Id=:clientAccountId];
        return clientAccount[0].Account_Type__c;
    }
    
    @AuraEnabled
    public static Product2 fetchProductRiskonProductCode(String prdCode){
        List<product2> listOfProducts = [SELECT id , Risk_Profile_of_Product__c 
                                         FROM Product2 WHERE ProductCode =:prdCode];
        return listOfProducts[0];
    }
    
    @AuraEnabled
    public static Integer checkForProfile(){
        Integer isValid = 1;
        string pName ;
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            pName =  currentUser.Profile.Name;
            system.debug('pName--'+pName);              
            if(pName .containsIgnoreCase('Operations Head') || pName .containsIgnoreCase('Operations')){
                isValid  = -1;
            }
        }   
        return isValid;
    }
    
    public class cutoffTimeWrapper{
        @AuraEnabled
        public integer cuttOffFlag{get;set;}
        @AuraEnabled
        public string Nav{get;set;}
    }
    
    @AuraEnabled
    public static cutoffTimeWrapper checkCuttOffTime(String schemeName, Boolean isoderentryMF, Integer transactionAmount){
        cutoffTimeWrapper wrapper = new cutoffTimeWrapper();
        System.debug('schemeName :'+schemeName);
        System.debug('isoderentryMF :'+isoderentryMF);
        System.debug('transactionAmount :'+transactionAmount);
        if(isoderentryMF)
        {
            DateTime now = DateTime.now();
            //Double currentTime = Double.valueOf(now.hour()+'.'+now.minute());
            Double currentTime = 14.25;
            
            OrderEntrySchem__c code = OrderEntrySchem__c.getInstance('LiquidCuttoffTime');
            Double LiquidCuttoffTime = decimal.valueOf(code.value__c);
            
            OrderEntrySchem__c codeLess2L = OrderEntrySchem__c.getInstance('NonLiquidCuttoffTime < 2L');
            Double nonLiquidctOffLess2L = decimal.valueOf(codeLess2L.value__c);
            
            OrderEntrySchem__c codeGreater2L = OrderEntrySchem__c.getInstance('NonLiquidCuttoffTime > 2L');
            Double nonLiquidctOffGret2L = decimal.valueOf(codeGreater2L.value__c);  
            
            List<Product2> schemeList = [SELECT id,  Liquid_NonLiquid__c FROM  Product2 WHERE Name =: schemeName ] ;
            
            OrderEntrySchem__c settingVal = OrderEntrySchem__c.getInstance('SoftCuttOffTime');
            Double softCuttoffTime = decimal.valueOf(settingVal.value__c);        
            OrderEntrySchem__c settingVal1 = OrderEntrySchem__c.getInstance('HardCuttOffTime');
            Double hardCuttoffTime = decimal.valueOf(settingVal1.value__c); 
            
            if(currentTime >= softCuttoffTime && currentTime<hardCuttoffTime){
                
                popUpCounter++;
                if(schemeList[0].Liquid_NonLiquid__c.contains('NonLiquid'))
                {
                    if((currentTime > 9.0 && currentTime < nonLiquidctOffGret2L)&& (Decimal.valueof(transactionAmount) > 200000) )
                    {	
                        wrapper.Nav  = 'Nav will be applicable of T';
                    }
                    else if((currentTime > 9.0 && currentTime < nonLiquidctOffLess2L)&& (Decimal.valueof(transactionAmount) < 200000) )
                    {	
                        wrapper.Nav   = 'Nav will be applicable of T';
                    }
                    else
                    {
                        wrapper.Nav  = 'Nav will be applicable of T+1';
                    }
                }
                else if(schemeList[0].Liquid_NonLiquid__c.contains('Liquid'))
                {
                    if(currentTime > 9.0 && currentTime < LiquidCuttoffTime)
                    {	
                        wrapper.Nav   = 'Nav will be applicable of T-1';
                    }
                    else
                    {
                        wrapper.Nav   = 'Nav will be applicable of T';
                    }
                }
                
                wrapper.cuttOffFlag =0;
                return wrapper;
            }
            else if(currentTime > hardCuttoffTime && currentTime< 15.0){       //to check for hardCutoFF Time 
                wrapper.cuttOffFlag =-1;
                //return -1;
                return wrapper;
            }
            else{ 
                if(schemeList[0].Liquid_NonLiquid__c.contains('NonLiquid'))
                {
                    if((currentTime > 9.0 && currentTime < nonLiquidctOffGret2L)&& (Decimal.valueof(transactionAmount) > 200000) )
                    {	
                        wrapper.Nav  = 'Nav will be applicable of T';
                    }
                    else if((currentTime > 9.0 && currentTime < nonLiquidctOffLess2L)&& (Decimal.valueof(transactionAmount) < 200000) )
                    {	
                        wrapper.Nav   = 'Nav will be applicable of T';
                    }
                    else
                    {
                        wrapper.Nav  = 'Nav will be applicable of T+1';
                    }
                }
                else if(schemeList[0].Liquid_NonLiquid__c.contains('Liquid'))
                {
                    if(currentTime > 9.0 && currentTime < LiquidCuttoffTime)
                    {	
                        wrapper.Nav   = 'Nav will be applicable of T-1';
                    }
                    else
                    {
                        wrapper.Nav   = 'Nav will be applicable of T';
                    }
                }
                
                wrapper.cuttOffFlag =1; 
                return wrapper;
            } 
            
        } 
        else
        {
            //System.debug('Scheme in cuttoff == '+schemeName);
            List<Schema_Master__c> schemeMasterList = [SELECT scheme_Type__c FROM  Schema_Master__c WHERE scheme_name__c =: schemeName ] ;
            //System.debug('schemeMasterList === '+schemeMasterList);
            /*Logic for soft/hard cutoff Time Start*/
            DateTime now = DateTime.now();
            Double currentTime = Double.valueOf(now.hour()+'.'+now.minute());
            //Double currentTime = 13.50;
            OrderEntrySchem__c settingVal = OrderEntrySchem__c.getInstance('SoftCuttOffTime');
            Double softCuttoffTime = decimal.valueOf(settingVal.value__c);        
            OrderEntrySchem__c settingVal1 = OrderEntrySchem__c.getInstance('HardCuttOffTime');
            Double hardCuttoffTime = decimal.valueOf(settingVal1.value__c);        
            if((currentTime >= softCuttoffTime && currentTime<hardCuttoffTime) && (schemeMasterList[0].scheme_Type__c.equals('LIQUID'))){// && popUpCounter == 0){  
                //System.debug('schemeMasterList[0].scheme_Type__c=== '+schemeMasterList[0].scheme_Type__c);
                popUpCounter++;
                wrapper.cuttOffFlag =0;   
                //return 0;
                return wrapper;
            }else if(currentTime > hardCuttoffTime && currentTime< 15.0){           
                // return -1;
                wrapper.cuttOffFlag =-1;   
                return wrapper;
            }else{            
                //return 1;
                wrapper.cuttOffFlag =1;   
                return wrapper;
            }
        }
        
    }
    
    @AuraEnabled
    public static List<String> getFolioFromAPI(Id clientAccountId , String bseStarAmcCode , String holdingType,String transactionType,String schemeName , String fromSchemeName){
        String apiUrl = '';
        String  apiUser = '';
        String  apiPass = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'MFHoldingAPIEndPoint')
                apiUrl = setting.Value__c;
            if(setting.DeveloperName == 'MFHoldingAPIUserName')
                apiUser = setting.Value__c;
            if(setting.DeveloperName == 'MFHoldingAPIPassword')
                apiPass = setting.Value__c;
        }
        String accountCode;
        String amcCode;
        String schemeCode;
        Boolean flagGetHolding;
        if(clientAccountId != null){
            Client_Account__c clientAccountObj = [SELECT id ,  GWM_Client_Account_Id__c FROM Client_Account__c where id=:clientAccountId LIMIT 1];
            if(clientAccountObj != null){
                if(clientAccountObj.GWM_Client_Account_Id__c != null){
                    accountCode = clientAccountObj.GWM_Client_Account_Id__c;
                }
            }
        }
        if(bseStarAmcCode != null && schemeName!= null){
            Scheme_Mapping__c schemeMappingObj = [SELECT id ,MilesAMCCode__c, MilesAMCName__c , MilesSchemeCode__c , BSEStarAMCCode__c , BSEStarSchemeName__c FROM Scheme_Mapping__c WHERE BSEStarAMCCode__c =:bseStarAmcCode AND BSEStarSchemeName__c	=:schemeName LIMIT 1];
            if(schemeMappingObj != null){
                if(schemeMappingObj.MilesAMCCode__c != null){
                    amcCode = schemeMappingObj.MilesAMCCode__c;
                }
                if(schemeMappingObj.MilesSchemeCode__c != null){
                    schemeCode = schemeMappingObj.MilesSchemeCode__c;
                }
            }
        }
        flagGetHolding = false;
        
        
        String parameterStr = 'amcCode=##&accountCode=##&schemeCode=##&flagGetHolding=##';
        parameterStr = parameterStr.replace('amcCode=##' , 'amcCode='+amcCode);
        parameterStr = parameterStr.replace('accountCode=##' , 'accountCode='+accountCode);
        parameterStr = parameterStr.replace('schemeCode=##' , 'schemeCode='+schemeCode);
        parameterStr = parameterStr.replace('flagGetHolding=##' , 'flagGetHolding='+flagGetHolding);
        
        apiUrl = apiUrl + parameterStr;
        System.debug('** apiUrl'+apiUrl);
        HTTPRequest req = new HTTPRequest();
        Http http = new Http();
        req.setMethod('GET'); 
        req.setEndpoint(apiUrl);
        Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);   
        req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        System.debug('List Response'+res.getBody());
        
        String responsebodyStr = res.getBody();
        System.debug('responsebodyStr'+responsebodyStr);
        System.debug('res'+res);
        if(responsebodyStr == 'null'){
            system.debug('return');
            return null;
        }
        
        if(res!= null){
            if(res.getBody() != null){
                JSONParser parser = JSON.createParser(res.getBody());
                List<String> folioList = new List<String>();
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                        parser.nextValue();
                        if(parser.getCurrentName() == 'acount_No') {
                            if(parser.getText() != null) {
                                folioList.add(parser.getText());
                            }
                        }
                    }
                }
                if (res.getStatusCode() == 200) {
                    List<String> folioListReturn = TransactionController.folioEligibilityCheck(folioList,clientAccountId,bseStarAmcCode,holdingType,transactionType);
                    if(transactionType.equals('Purchase')){
                        if(folioListReturn != null || !(folioListReturn.isEmpty())){
                            return folioListReturn;
                        }
                    }
                }else {
                    return null;
                } 
                return null;
            }else{return null;}
        }else{return null;}
        
    }
    
    
    
    
    @AuraEnabled
    public static List<HoldingData> getHoldingFromAPI(Id clientAccountId , String bseStarAmcCode , String holdingType,String transactionType,String schemeName , String fromSchemeName){
        String apiUrl = '';
        String  apiUser = '';
        String  apiPass = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'MFHoldingAPIEndPoint')
                apiUrl = setting.Value__c;
            if(setting.DeveloperName == 'MFHoldingAPIUserName')
                apiUser = setting.Value__c;
            if(setting.DeveloperName == 'MFHoldingAPIPassword')
                apiPass = setting.Value__c;
        }
        
        List<String> folioList = new List<String>();
        List<HoldingData> HoldingDataListReturn = new List<HoldingData>();
        String accountCode;
        String amcCode;
        String schemeCode;
        Boolean flagGetHolding;
        String schemeNameStr;
        if(clientAccountId != null){
            Client_Account__c clientAccountObj = [SELECT id ,  GWM_Client_Account_Id__c FROM Client_Account__c where id=:clientAccountId LIMIT 1];
            if(clientAccountObj != null){
                if(clientAccountObj.GWM_Client_Account_Id__c != null){
                    accountCode = clientAccountObj.GWM_Client_Account_Id__c;
                }
            }
        }
        
        if(transactionType.equals('Redemption')){
            schemeNameStr = schemeName;
        }else if (transactionType.equals('Switch')){
            schemeNameStr = fromSchemeName;
        }
        
        if(bseStarAmcCode != null && schemeNameStr!= null){
            Scheme_Mapping__c schemeMappingObj = [SELECT id , MilesAMCCode__c , MilesAMCName__c , MilesSchemeCode__c , BSEStarAMCCode__c , BSEStarSchemeName__c FROM Scheme_Mapping__c WHERE BSEStarAMCCode__c =:bseStarAmcCode AND BSEStarSchemeName__c	=:schemeNameStr LIMIT 1];
            if(schemeMappingObj != null){
                if(schemeMappingObj.MilesAMCCode__c != null){
                    amcCode = schemeMappingObj.MilesAMCCode__c;
                }
                if(schemeMappingObj.MilesSchemeCode__c != null){
                    schemeCode = schemeMappingObj.MilesSchemeCode__c;
                }
            }
        }
        flagGetHolding = true;
        String parameterStr = 'amcCode=##&accountCode=##&schemeCode=##&flagGetHolding=##';
        parameterStr = parameterStr.replace('amcCode=##' , 'amcCode='+amcCode);
        parameterStr = parameterStr.replace('accountCode=##' , 'accountCode='+accountCode);
        parameterStr = parameterStr.replace('schemeCode=##' , 'schemeCode='+schemeCode);
        parameterStr = parameterStr.replace('flagGetHolding=##' , 'flagGetHolding='+flagGetHolding);
        
        apiUrl = apiUrl + parameterStr;
        System.debug('*** API'+apiUrl);
        HTTPRequest req = new HTTPRequest();
        Http http = new Http();
        req.setMethod('GET'); 
        req.setEndpoint(apiUrl);
        Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);   
        req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        System.debug('res.getBody() :::  '+res.getBody());
        String responsebodyStr = res.getBody();
        System.debug('responsebodyStr ::  '+responsebodyStr);
        System.debug('res'+res);
        if(responsebodyStr == 'null'){
            system.debug('return');
            return null;
        }
        System.debug('Response blank'+String.isBlank(responsebodyStr));
        if(res!= null){
            if(responsebodyStr != null){
                String jsonString = res.getBody();
                
                if(jsonString.startsWith('{')){
                    jsonString = '['+jsonString+']';
                }
                
                JSONParser parser = JSON.createParser(jsonString);
                if (res.getStatusCode() == 200) {
                    if(transactionType.equals('Redemption') || transactionType.equals('Switch')){
                        HoldingDataList hData = new HoldingDataList();
                        
                        List<HoldingData> dataList = new List<HoldingData>();   
                        while(parser.nextToken() != JSONToken.END_ARRAY){
                            HoldingData data = new HoldingData();
                            while(parser.nextToken() != JSONToken.END_OBJECT){
                                
                                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                                    parser.nextToken();
                                    if(parser.getCurrentName() == 'acount_No') {
                                        String folio = parser.getText();
                                        if(folio != null) {
                                            data.folio = folio;
                                        }
                                    }else if(parser.getCurrentName() == 'amount') {
                                        Decimal amount = decimal.valueOf(parser.getText());
                                        if(amount != null) {
                                            data.amount = amount;
                                        }
                                    }else if(parser.getCurrentName() == 'qty') {
                                        Decimal qty = decimal.valueOf(parser.getText());
                                        if(qty != null) {
                                            data.quantity = qty;
                                        }
                                    }
                                }
                                
                            }
                            dataList.add(data);
                        }
                        
                        hData.HoldingDataList = dataList;
                        List<String> folioByApi = new List<String>();
                        for(HoldingData hObj : dataList){
                            if(hObj.folio != null){
                                folioByApi.add(hObj.folio);
                            }
                        }
                        System.debug('folioByApi'+folioByApi);
                        if(folioByApi != null ||!(folioByApi.isEmpty())){
                            List<String> folioListReturn = TransactionController.folioEligibilityCheck(folioByApi,clientAccountId,bseStarAmcCode,holdingType,transactionType);
                            Map<String,String> tempFolio = new Map<String,String>();
                            for(String folio1 : folioByApi) {
                                for(String folio2 : folioListReturn) {
                                    if(folio1 == folio2) {
                                        tempFolio.put(folio1,folio1);
                                    }
                                }
                            }
                            for(HoldingData hObj : dataList){
                                if(tempFolio.get(hObj.folio) != null){
                                    HoldingDataListReturn.add(hObj);
                                }
                            }
                        }         
                    }
                    return HoldingDataListReturn;
                }else{
                    return null;
                }
            }else{return null;}
        }else{return null;}
        
    }
    
    @AuraEnabled
    public static List<String> folioEligibilityCheck(List<String> folioListFetched , Id clientAccountId , String bseStarAmcCode , String holdingType,String transactionType){   
        List<String> folioList = folioListFetched;
        List<String> folioListReturn = new list<String>();
        Map<String,FolioType__c> folioTypeMap = new  Map<String,FolioType__c> ();
        List<FolioToBlock__c> listOfBlackListedFolio = [SELECT id , Folio__c FROM FolioToBlock__c];
        Map<String , FolioToBlock__c> mapOfBlackListedFolio =new Map<String , FolioToBlock__c>();
        for(FolioToBlock__c fObj : listOfBlackListedFolio){
            if(fObj.Folio__c != null){
                mapOfBlackListedFolio.put(fObj.Folio__c  ,fObj );
            }
        }
        List<FolioType__c> folioType = [SELECT id ,Folio__c , Type__c from FolioType__c where Folio__c =:folioList AND Type__c = 'D'];
        for(FolioType__c fObj : folioType){
            folioTypeMap.put(fObj.Folio__c , fObj);
        }
        if(transactionType == 'Purchase'){
            if(holdingType == 'Demat'){
                if(folioList!=null && !folioList.isEmpty()){
                    for(String folio : folioList){
                        if(folioTypeMap.get(folio) != null){
                            if(mapOfBlackListedFolio.get(folio) == null){
                                folioListReturn.add(folio);
                            }
                        }
                    }
                    return folioListReturn;
                }
            }else if(holdingType == 'Physical'){
                if(folioList!=null && !folioList.isEmpty()){
                    for(String folio : folioList){
                        if(folioTypeMap.get(folio) != null){
                        }else{
                            if(folioTypeMap.get(folio) == null){
                                if(mapOfBlackListedFolio.get(folio) == null){
                                    folioListReturn.add(folio);
                                }
                            }
                        }
                    }
                }
                
                return folioListReturn;
            }
        }else if(transactionType.equals('Redemption') || transactionType.equals('Switch')){
            if(holdingType == 'Demat'){
                if(folioList!=null && !folioList.isEmpty()){
                    for(String folio : folioList){
                        if(folioTypeMap.get(folio) != null){
                            folioListReturn.add(folio);
                        }
                    }
                    return folioListReturn;
                }
            }else if(holdingType == 'Physical'){
                if(folioList!=null && !folioList.isEmpty()){
                    for(String folio : folioList){
                        if(folioTypeMap.get(folio) != null){
                        }else{
                            if(folioTypeMap.get(folio) == null){
                                folioListReturn.add(folio);
                            }
                        }
                    }
                }
                
                return folioListReturn;
            }	
            
        }
        return null;  
    }
    
    public class HoldingDataList
    {
        public List<HoldingData> HoldingDataList;
    }
    
    public class HoldingData {
        @AuraEnabled
        public string folio { get; set; }
        @AuraEnabled
        public double amount { get; set; }
        @AuraEnabled
        public double quantity { get; set; }
        
    }
    /*Fetching product risk profile on the basis of Product Name*/
    @AuraEnabled
    public static Product2 fetchProductRiskonProductName(String prodName){
        List<product2> listOfProducts = [SELECT id , Risk_Profile_of_Product__c 
                                         FROM Product2 WHERE Name =:prodName];
        System.debug('listOfProducts=== '+listOfProducts[0]);
        return listOfProducts[0];
    }
    
    @AuraEnabled
    public static List<Product2> getProductListMFOrderEntry(String selectedAMC){
        system.debug('inside getProductListMFOrderEntry and selectedAMC is :: '+selectedAMC);
        if(selectedAMC != null){ 
            List<Product2> productList = [SELECT id,name FROM product2 WHERE Manufacturer_Name__c =:selectedAMC AND Sub_Asset_Class__c LIKE '%Mutual%'];            
            return productList;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Product2> getProductListMFOrderEntryRedemptionSwitch(String selectedAMC, Id selectedClientAccount){
        system.debug('inside getProductListMFOrderEntryRedemptionSwitch and selectedAMC is :: '+selectedAMC);
        if(selectedAMC != null && selectedClientAccount != null){ 
            List<Product2> productList = [SELECT id,name FROM product2 WHERE Manufacturer_Name__c =:selectedAMC AND Sub_Asset_Class__c LIKE '%Mutual%' and id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c =:selectedClientAccount AND Annual_Record__c = false AND Sub_Asset_Class__c LIKE '%Mutual%')];            
            return productList;
        }
        return null;
    } 
    
    @AuraEnabled
    public static List<Product2> getProductListToSchemeSwitch(String selectedAMC, Id selectedFromScheme){
        system.debug('inside getProductListToSchemeSwitch and selectedAMC is :: '+selectedAMC);
        if(selectedAMC != null && selectedFromScheme != null){ 
            List<Product2> productList = [SELECT id,name FROM product2 WHERE Manufacturer_Name__c =:selectedAMC AND Sub_Asset_Class__c LIKE '%Mutual%' and Id !=:selectedFromScheme];            
            return productList;
        }
        return null;
    }
    @AuraEnabled
    public static DrawdownData getDrawdownData(Order_Entry__c orderEntryObj){
        
        List<product2>  prodCodeList = [Select ProductCode from product2 where id =: orderEntryObj.Product_lookup__c];            
        List<Client_Account__c>  clientAccountList = [Select Name from Client_Account__c where id =: orderEntryObj.Client_Account__c];            
        List<Order_Entry__c> oeCreationList = [Select Id, InternalPEID__c from  Order_Entry__c 
                                               WHERE
                                               Client_Account_Display__c =: clientAccountList[0].Name
                                               AND 
                                               ProductCode__c =: prodCodeList[0].ProductCode
                                               AND 
                                               Transaction_Type__c =: 'Log Commitment' AND InternalPEID__c <> null Limit 1];
        orderEntryObj.CreationPEID__c = oeCreationList[0].InternalPEID__c;    
        system.debug('record id PE_ID__c' +orderEntryObj.CreationPEID__c);
        system.debug('product id ' +prodCodeList);
        List<String> folioList = new List<String>();
        DrawdownData DrawdownDataReturn = new DrawdownData();
        
        
        //Order_Entry__c orderObj = [Select Id,Product_Type_Order_Entry__c, Transaction_Type__c,CreationPEID__c,PE_ID__c from Order_Entry__c where Transaction_Type__c  =: orderEntryObj.Transaction_Type__c  LIMIT 1];
        
        System.debug('Order Entry Data :'+orderEntryObj);
        String requestXML = generateRequestXml1(orderEntryObj);
        DrawdownDataReturn.drawDownDueDate = TransactionController.drawDownDueDateField;
        DrawdownDataReturn.drawDownAmtDueStr = TransactionController.drawDownAmtDueStrField;
        DrawdownDataReturn.drawDownAmtStr = TransactionController.drawDownAmtStrField;
        DrawdownDataReturn.drawDownAmtPaidTillDateStr = TransactionController.drawDownAmtPaidTillDateStrField;
        
        
        System.debug('requestXML :'+requestXML);
        System.debug('DrawdownDataReturn :'+DrawdownDataReturn);
        return DrawdownDataReturn;
        
    }
    
    @AuraEnabled
    public static List<refreshApiWrapper> callRefreshApi(Order_Entry__c orderEntryObj){
        
        List<refreshApiWrapper> wrapperLines= new List<refreshApiWrapper>();
        try{
            if(orderEntryObj != null)
            {
                Client_Account__c clientAcc = [select id, GWM_Client_Account_Id__c from Client_Account__c where id =:orderEntryObj.Client_Account__c];
                InvestIdRefreshApi = clientAcc.GWM_Client_Account_Id__c;
                
                Product2 prod =[select id, ProductCode from product2 where id =:orderEntryObj.Product_lookup__c ];
                schemeCodeRefreshApi =prod.ProductCode;
                String response = generateRequestXml1(orderEntryObj);  
            }
            
            System.debug('TransactionController.wrapList '+TransactionController.wrapList);
            List<refreshApiWrapper> wrapList = new List<refreshApiWrapper>();
            refreshApiWrapper wrapnew = new refreshApiWrapper();
            string jsonString='[{';
            if(TransactionController.wrapList.size() > 0)
            {
                for(refreshApiWrapper wrap :TransactionController.wrapList)
                {
                    if(wrap.ARN != null)
                    {
                        jsonString += '"ARN" :"'+ wrap.ARN +'",';
                        wrapnew.ARN =wrap.ARN;
                    }
                    if(wrap.FolioNum != null)
                    {
                        jsonString += '"FolioNum" :"'+ wrap.FolioNum +'",';
                        wrapnew.FolioNum =wrap.FolioNum;
                    }
                    if(wrap.HoldingMode != null)
                    {
                        jsonString += '"HoldingMode" :"'+ wrap.HoldingMode +'",';
                        wrapnew.HoldingMode =wrap.HoldingMode;
                    }
                    if(wrap.AvailableHoldings != null)
                    {
                        jsonString += '"AvailableHoldings" :"'+ wrap.AvailableHoldings +'"},{';
                        wrapnew.AvailableHoldings =wrap.AvailableHoldings;
                    }
                    wrapList.add(wrapnew);
                }
                jsonString += '}]'; 
            }

         wrapperLines= (List<refreshApiWrapper>)JSON.deserialize(jsonString, List<refreshApiWrapper>.class);
        System.debug('wrapperLines :'+wrapperLines);
        }
        
        catch(Exception e)
        {
            
            //get exception message
            throw new AuraHandledException(TransactionController.refreshApiError+'  '+ e.getMessage());            
        }

        
        return wrapperLines;

    }
    
    
    public static String generateRequestXml1(Order_Entry__C orderEntryRec){
        //ddapi
        String productTypeSearch;
        if(orderEntryRec.Transaction_Type__c.equals('Log Drawdown')){
            productTypeSearch = 'ddapi';
        }
        else
        {
            productTypeSearch = 'refapi';
        }
        System.debug('productTypeSearch === '+productTypeSearch);
        List<OrderEntryXML_New__c> fieldandApiList = [SELECT id , FieldName__c , value__c FROM OrderEntryXML_New__c where RecordTypeName__c like :productTypeSearch];
        System.debug('fldlist '+fieldandApiList);
        for(OrderEntryXML_New__c orderEntry : fieldandApiList){
            mapOfFields.put(orderEntry.FieldName__c , orderEntry.value__c);
        }
        
        orderId = orderEntryRec.id;
        DrawdownData drdta = new DrawdownData() ;
        String response = generateRequestXml(orderEntryRec);
        
        return response;
    }
    public static String generateRequestXml(Order_Entry__c orderEntryRec1){ 
        
        //orderEntryRec.id = orderEntryRec1.id;
        
        DOM.Document doc = new DOM.Document();
        String xml = getXML(orderEntryRec1.Transaction_Type__c,orderEntryRec1);
        System.debug('Resquest xml :'+xml);
        if(xml != null){
            doc.load(xml);            
            dom.XmlNode orderEntryAddRequest = doc.getRootElement();    
            //System.debug('RD :: orderEntryAddRequest = '+orderEntryAddRequest);
            parseXml(orderEntryAddRequest,orderEntryRec1);            
            System.debug('doc.toXmlString() :'+doc.toXmlString());
            String response = processXmlResponse(doc.toXmlString(),orderEntryRec1.Id);
            System.debug('generateRequestXml processXmlResponse :'+response);
            return '';
            //Database.update(orderEntryRec);
        } else{
            
        }
        return '';
    }
    public static String getXML(String TransactionType,Order_Entry__c orderEntryRec){ 
        String masterLable;
        if(orderEntryRec.Transaction_Type__c=='Log Drawdown'){                
            masterLable ='PE_DrawdownScheduleAPI';
        }
        else
        {
            masterLable ='RefreshAPI';
        }
        System.debug('masterLable==== '+masterLable);
        
        List<OrderEntry_XML__mdt> xmlList = [Select Value__c from OrderEntry_XML__mdt where MasterLabel=:masterLable];
        
        return xmlList[0].value__c;
    }
    
    private static void parseXml(DOM.XMLNode node, Order_Entry__c orderEntryRec) { 
        if(mapOfFields.get(node.getName()) != null){
            
            String fieldName = mapOfFields.get(node.getName());  
            if(fieldName != null){
                //remove
                System.debug('fieldName==== '+fieldName);
                String fieldvalue = String.valueOf(orderEntryRec.get(fieldName));            
                if(fieldvalue != null){
                    node.addTextNode(fieldvalue);
                    //remove
                    System.debug('fieldvalue==== '+fieldvalue); 
                }
                
            }
        }
        for (Dom.XMLNode child: node.getChildElements()){
            parseXml(child,orderEntryRec);
        }        
    } 
    
    public static String processXmlResponse(String requestXml,Id orderEntryRecid){ 
        String apiUrl = '';
        String  apiUser = '';
        String  apiPass = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'OrderEntryEndPointURL')
                apiUrl = setting.Value__c;
            if(setting.DeveloperName == 'OrderEntryUsername')
                apiUser = setting.Value__c;
            if(setting.DeveloperName == 'OrderEntryPassword')
                apiPass = setting.Value__c;
        }
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST'); 
        
        req.setEndpoint(apiUrl);
        Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);   
        req.setHeader('Content-Type', 'application/xml');
        req.setTimeout(120000);
        
        String randomNumber = String.ValueOf(Integer.valueof((Math.random() * 10000000)));
        Boolean isRefreshApi = false;
        if(requestXML.contains('#RandomNumber#')){
            requestXML = requestXML.replace('#RandomNumber#',randomNumber);
        }
        if(requestXML.contains('#InvestId#'))
        {
            isRefreshApi=true;
            requestXML = requestXML.replace('#InvestId#',InvestIdRefreshApi);
        }
        if(requestXML.contains('#SchemeCode#'))
        {
            requestXML = requestXML.replace('#SchemeCode#',schemeCodeRefreshApi);
        }
        System.debug('requestXml Final### :'+requestXml);
        req.setBody(requestXML);
        
        Http http = new Http();
        System.debug('API Reuest Done Time '+ System.now());
        
        Order_Entry_XMLs__c xmlObj = new Order_Entry_XMLs__c();
        xmlObj.Request_XML__c = requestXML;
        HTTPResponse res = http.send(req);
        System.debug('res=== '+res);
        System.debug('Response Received Time '+System.now());
        String xml = res.getBody();
        
        //DOM.Document doc = new DOM.Document();
        DOM.Document doc = new DOM.Document();
        //doc = res.getBodyDocument();
        if(xml != ''){
            xml = xml.replace('&lt;','<');
            xml = xml.replace('&gt;','>');}
        System.debug('Final Responase XML :'+xml);
        doc.load(xml); 
        xmlObj.Response_XML__c = xml;
        insert xmlObj;
        System.debug('XML ==== '+xml);        
        dom.XmlNode orderEntryAddRequest = doc.getRootElement(); 
        System.debug('RD=== orderEntryAddRequest = '+orderEntryAddRequest);
        // parseXmlString(orderEntryAddRequest, orderEntryRecid);
        parseXmlString(orderEntryAddRequest, orderEntryRecid);
        //parseXmlStringNew(orderEntryAddRequest);
       
        return '';
        
        
    }
    
    
    
    public class DrawdownDataList{
        @AuraEnabled
        public List<DrawdownData> DrawdownAllDataList{get;set;}
    }
    
    public class DrawdownData {
        @AuraEnabled
        public  string drawDownDueDate { get; set; }
        @AuraEnabled
        public  string drawDownAmtDueStr { get; set; }
        @AuraEnabled
        public string drawDownAmtPaidTillDateStr { get; set; }
        @AuraEnabled
        public  string drawDownAmtStr { get; set; }
        
        
        
    }
    
    public class refreshApiWrapperClass{
        @AuraEnabled
        public List<refreshApiWrapper> refreshApiWrapperList{get;set;}
        
        refreshApiWrapperClass()
        {
            refreshApiWrapperList = new List<refreshApiWrapper>();
        }
    }
    
    public class refreshApiWrapper
    {
        @AuraEnabled
        public  string HoldingMode { get; set; }
        @AuraEnabled
        public  string ARN { get; set; }
        @AuraEnabled
        public string FolioNum { get; set; }
        @AuraEnabled
        public  string AvailableHoldings { get; set; }
    }
    public static void parseXmlString(DOM.XMLNode node, Id orderEntryRecid) {      
        System.debug('node result :'+node.getText());
        System.debug('node.getName() RD :: '+node.getName()); 
        List<DrawdownData> DrawdownDataReturn = new List<DrawdownData>();
        
        //refreshApiWrapperClass wrapList = new refreshApiWrapperClass();
        //List<refreshApiWrapper>  wrapList= new List<refreshApiWrapper>();
        refreshApiWrapper wrap = new refreshApiWrapper();
        if(node.getName()== 'drawDownDueDate'){
            TransactionController.drawDownDueDateField = node.getText();
            System.debug('drawDownDueDate :'+node.getText());
            
        }
        if(node.getName()=='adjustedDrawDownDueDate'){
            TransactionController.adjustedDrawDownDueDateField = node.getText();
            System.debug('adjustedDrawDownDueDateField :'+adjustedDrawDownDueDateField);
        }
        
        if(node.getName()=='productCcy'){
            TransactionController.productCcyField = node.getText();
            System.debug('productCcyField :'+productCcyField);
        }
        
        if(node.getName()=='drawDownAmtStr'){
            TransactionController.drawDownAmtStrField = node.getText();
            System.debug('drawDownAmtStrField :'+drawDownAmtStrField);
        }
        if(node.getName()=='drawDownAmtPaidTillDateStr'){
            TransactionController.drawDownAmtPaidTillDateStrField = node.getText();
            System.debug('drawDownAmtPaidTillDateStrField :'+drawDownAmtPaidTillDateStrField);
        }
        
        if(node.getName()=='drawDownAmtDueStr'){
            TransactionController.drawDownAmtDueStrField = node.getText();
        }
        if(node.getName()=='FolioNum'){
            wrap.FolioNum =node.getText();
            System.debug('FolioNum :'+wrap.FolioNum);
        }
        if(node.getName()=='HoldingMode'){
            wrap.HoldingMode =node.getText();
            System.debug('HoldingMode :'+wrap.HoldingMode);
        }
        if(node.getName()=='ARN'){
            wrap.ARN =node.getText();
            System.debug('ARN :'+wrap.ARN);
        }
        if(node.getName()=='AvailableHoldings'){
            wrap.AvailableHoldings =node.getText();
            System.debug('AvailableHoldings :'+wrap.AvailableHoldings);
        }
        if(node.getName()=='ErrorMessage')
        {
            TransactionController.refreshApiError = node.getText();
            System.debug('refreshApiError'+TransactionController.refreshApiError);
        }
        if(wrap.ARN != null || wrap.FolioNum != null || wrap.AvailableHoldings != null || wrap.HoldingMode != null)
        {
            //System.debug('wrap record :'+wrap);
            TransactionController.wrapList.add(wrap);  
            System.debug('wrap wrapList :'+wrapList);
        }
        
        
        for (Dom.XMLNode child: node.getChildElements()){
            parseXmlString(child,orderEntryRecid);

        }   

    } 

}