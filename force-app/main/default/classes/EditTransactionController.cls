public class EditTransactionController {
    
    public static Id attachId;
    public static String attachmentName;
    
    @AuraEnabled
    public static List<Account> getAllFamilies(){
        List<Account> allFamilies = [SELECT id , Name FROM Account where Recordtype.Name='Family'];            
        return allFamilies;
    }
    @AuraEnabled
    public static Order_Entry__c getOrderEntryRec(Id orderId){
        
        Integer profileFlag = checkCXOProfile();
        Order_Entry__c orderObj;
        if(profileFlag == 1)
        	orderObj = [SELECT Id, Redemption_Type__c,OwnerId, Current_Investment_Amount__c , Available_Quantity__c ,Market_Type__c,Counterparty_investment_id_if_avl__c,
Price_new__c,IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Application_Number__c,
 Family_Name__c, Origin__c, Folio_Number__c, Order_Type__c, SuppliedEmail__c, Contact__c, Subject__c, Priority__c, Priority1__c, Status__c, Scrip_Name__c, Script_Name__c, Trade_Date__c, 
Amount_INR_Lakhs__c, Fee_Structure__c, Financial_Transaction_Id__c, IPO_Name__c, Investment_Date__c, Lot__c, Dp_Id__c, Option__c, Client_Id__c, Existing_Folio__c, Bid_ID__c, 
Signed_forms_cheque_RTGS_received__c, Funds_Transferred__c, Time_Stamped__c, Funds_received_in_POA_Bank__c, Registration_done__c, ICCL_Registration_done__c, Remarks__c, Description__c, 
Points_to_Remember__c, AMC_Name__c, ClosedDate__c, Case_Age_Days__c, Owner_Change_Reason__c, CreatedDate__c, Account__c, Mode_of_Consent__c, Payment_Mode__c, 
Transaction_Amount_Financial_Transaction__c, Total_Amount_Payable__c, Order_Date__c, Face_Value__c, Gross_Amount__c, Premium__c, Payment_Type__c,
 Subtract_Accrued_Interest__c, Subtract_Accrued_Interest1__c, FX_Conversion_on_Payout__c, Apply_Type__c, Customer_Category__c, Price__c, Demat_Account_Number__c, LOB__c,
 Case_Type__c, Due_Date_Time__c, Due_Date__c, Contacted_By__c, Fund_Status__c, Contacted_By_Others__c, IsOrderInMiles__c, Buy_Sell__c, Owner_Zone__c, ISIN__c, Net_New_Money_flag__c,IPO_Application_Number__c,
 FA_wise_EUIN__c, Compensatory_Contribution_CC_Units__c, Compensatory_Contribution_CC_Value__c, Client_Risk_Profile__c, Payment_Type_FinancialT__c, Product_Type_Order_Entry__c, Order_Number__c,
 All_Client_Accounts__c, Transaction_Type__c, Transaction_Type_Copy__c, All_Products__c, Primary_FA_FinanceT__c, Product_Risk_Profile__c, Product_Risk_Profile_FinancialT__c, Reason_for_Override__c,
 Client_Consent_Received__c, Nature_of_Transaction__c, Value_Date__c, Rate__c, Quantity__c, Saleable_Quantity__c, Transaction_Amount__c, ContactPhone__c, Currency__c, UCC__c, Holding_Information__c, 
Transaction_Mode__c, Client_Holding_and_Type__c, isReviewed__c, Instrument_Name_Display__c,Product_Name_Display__c,Portfolio_Fee_Type__c, POA_Non_POA__c, scheme_code_export__c, isExported__c,of_Facevalue__c,
 AttachmentId__c, EUIN__c, Primary_FA__c, Scheme__c, From_Scheme__c, To_Scheme__c, Folio__c, Scheme_Name__c, Family_Name_Display__c, Client_Name__c, Client_Name_Display__c, Client_Account__c,No_of_units__c,Funding_ROI__c,
 Client_Account_Display__c, Product_lookup__c, Redemption_Units__c, Client_Concent__c, Payment_Mode_Bond__c, Minimum_Quantity__c, All_Units__c, CDSLCLTID__c, Client_Default_Dp__c, PURCHASE_REDEEM__c, Cut_Off_Price__c,
BUY_SELL_TYPE__c, Remarks_Blank__c, Sub_Broker_Code_Blank__c, EUIN_Declaration_Default__c, MIN_redemption_flag_default__c, DPC_Flag_default__c, All_Units_blank__c, Redemption_Units_Blank__c, Start_Date__c,End_Date__c,
                        PE_ID__c,Security_Name_Display__c,Commitment_Amount__c,
 Sub_broker_ARN_Blank__c, KYC_Flag_Default__c  FROM Order_Entry__c where Id=:orderId and isReviewed__c != true and status__c NOT IN ('Completed' ,'Rejected')];

        else if(profileFlag == -1)
            orderObj = [SELECT Id, Redemption_Type__c,OwnerId, Current_Investment_Amount__c ,Market_Type__c, PE_ID__c,Commitment_Amount__c,Security_Name_Display__c,Available_Quantity__c ,Counterparty_investment_id_if_avl__c,Price_new__c,IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Application_Number__c, Family_Name__c, Origin__c, Folio_Number__c, Order_Type__c, SuppliedEmail__c, Contact__c, Subject__c, Priority__c, Priority1__c, Status__c, Scrip_Name__c, Script_Name__c, Trade_Date__c, Amount_INR_Lakhs__c, Fee_Structure__c, Financial_Transaction_Id__c, IPO_Name__c, Investment_Date__c, Lot__c, Dp_Id__c, Option__c, Client_Id__c, Existing_Folio__c, Bid_ID__c, Signed_forms_cheque_RTGS_received__c, Funds_Transferred__c, Time_Stamped__c, Funds_received_in_POA_Bank__c, Registration_done__c, ICCL_Registration_done__c, Remarks__c, Description__c, Points_to_Remember__c, AMC_Name__c, ClosedDate__c, Case_Age_Days__c, Owner_Change_Reason__c, CreatedDate__c, Account__c, Mode_of_Consent__c, Payment_Mode__c, Transaction_Amount_Financial_Transaction__c, Total_Amount_Payable__c, Order_Date__c, Face_Value__c, Gross_Amount__c, Premium__c, Payment_Type__c, Subtract_Accrued_Interest__c, Subtract_Accrued_Interest1__c, FX_Conversion_on_Payout__c, Apply_Type__c, Customer_Category__c, Price__c, Demat_Account_Number__c, LOB__c, Case_Type__c, Due_Date_Time__c, Due_Date__c, Contacted_By__c, Fund_Status__c, Contacted_By_Others__c, IsOrderInMiles__c, Buy_Sell__c, Owner_Zone__c, ISIN__c, Net_New_Money_flag__c, FA_wise_EUIN__c, Compensatory_Contribution_CC_Units__c, Compensatory_Contribution_CC_Value__c, Client_Risk_Profile__c, Payment_Type_FinancialT__c, Product_Type_Order_Entry__c, Order_Number__c, All_Client_Accounts__c, Transaction_Type__c, Transaction_Type_Copy__c, All_Products__c, Primary_FA_FinanceT__c, Product_Risk_Profile__c, Product_Risk_Profile_FinancialT__c, Reason_for_Override__c, Client_Consent_Received__c, Nature_of_Transaction__c, Value_Date__c, Rate__c, Quantity__c, Saleable_Quantity__c, Transaction_Amount__c, ContactPhone__c, Currency__c, UCC__c, Holding_Information__c, Transaction_Mode__c, Client_Holding_and_Type__c, isReviewed__c, Instrument_Name_Display__c,Product_Name_Display__c,Portfolio_Fee_Type__c, POA_Non_POA__c, scheme_code_export__c, isExported__c, AttachmentId__c, EUIN__c, Primary_FA__c, Scheme__c, From_Scheme__c, To_Scheme__c, Folio__c, Scheme_Name__c, Family_Name_Display__c, Client_Name__c, Client_Name_Display__c, Client_Account__c, Client_Account_Display__c, Product_lookup__c, Redemption_Units__c, Client_Concent__c, Payment_Mode_Bond__c, Minimum_Quantity__c, All_Units__c, CDSLCLTID__c, Client_Default_Dp__c, PURCHASE_REDEEM__c, BUY_SELL_TYPE__c, Remarks_Blank__c, Sub_Broker_Code_Blank__c, EUIN_Declaration_Default__c, MIN_redemption_flag_default__c, DPC_Flag_default__c, All_Units_blank__c, Redemption_Units_Blank__c, Sub_broker_ARN_Blank__c, KYC_Flag_Default__c  FROM Order_Entry__c
                                       where Id=:orderId and isReviewed__c != true and status__c != 'Completed'];
        if(orderObj != null){
            return orderObj;
        }
        return null;
    }
    @AuraEnabled
    public static Order_Entry__c getOrderEntryRecTemp(Id orderId){
        Order_Entry__c orderObj = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Application_Number__c, Family_Name__c, Origin__c, Folio_Number__c, Order_Type__c, SuppliedEmail__c, Contact__c, Subject__c, Priority__c, Priority1__c, Status__c, Scrip_Name__c, Script_Name__c, Trade_Date__c, Amount_INR_Lakhs__c, Fee_Structure__c, Financial_Transaction_Id__c, IPO_Name__c, Investment_Date__c, Lot__c, Dp_Id__c, Option__c, Client_Id__c, Existing_Folio__c, Bid_ID__c, Signed_forms_cheque_RTGS_received__c, Funds_Transferred__c, Time_Stamped__c, Funds_received_in_POA_Bank__c, Registration_done__c, ICCL_Registration_done__c, Remarks__c, Description__c, Points_to_Remember__c, AMC_Name__c, ClosedDate__c, Case_Age_Days__c, Owner_Change_Reason__c, CreatedDate__c, Account__c, Mode_of_Consent__c, Payment_Mode__c, Transaction_Amount_Financial_Transaction__c, Total_Amount_Payable__c, Order_Date__c, Face_Value__c, Gross_Amount__c, Premium__c, Payment_Type__c, Subtract_Accrued_Interest__c, Subtract_Accrued_Interest1__c, FX_Conversion_on_Payout__c, Apply_Type__c, Customer_Category__c, Price__c, Demat_Account_Number__c, LOB__c, Case_Type__c, Due_Date_Time__c, Due_Date__c, Contacted_By__c, Fund_Status__c, Contacted_By_Others__c, IsOrderInMiles__c, Buy_Sell__c, Owner_Zone__c, ISIN__c, Net_New_Money_flag__c, FA_wise_EUIN__c, Compensatory_Contribution_CC_Units__c, Compensatory_Contribution_CC_Value__c, Client_Risk_Profile__c, Payment_Type_FinancialT__c, Product_Type_Order_Entry__c, Order_Number__c, All_Client_Accounts__c, Transaction_Type__c, Transaction_Type_Copy__c, All_Products__c, Primary_FA_FinanceT__c, Product_Risk_Profile__c, Product_Risk_Profile_FinancialT__c, Reason_for_Override__c, Client_Consent_Received__c, Nature_of_Transaction__c, Value_Date__c, Rate__c, Quantity__c, Saleable_Quantity__c, Transaction_Amount__c, ContactPhone__c, Currency__c, UCC__c, Holding_Information__c, Transaction_Mode__c, Client_Holding_and_Type__c, isReviewed__c, Instrument_Name_Display__c,Product_Name_Display__c,Portfolio_Fee_Type__c, POA_Non_POA__c, scheme_code_export__c, isExported__c, AttachmentId__c, EUIN__c, Primary_FA__c, Scheme__c, From_Scheme__c, To_Scheme__c, Folio__c, Scheme_Name__c, Family_Name_Display__c, Client_Name__c, Client_Name_Display__c, Client_Account__c, Client_Account_Display__c, Product_lookup__c, Redemption_Units__c, Client_Concent__c, Payment_Mode_Bond__c, Minimum_Quantity__c, All_Units__c, CDSLCLTID__c, Client_Default_Dp__c, PURCHASE_REDEEM__c, BUY_SELL_TYPE__c, Remarks_Blank__c, Sub_Broker_Code_Blank__c, EUIN_Declaration_Default__c, MIN_redemption_flag_default__c, DPC_Flag_default__c, All_Units_blank__c, Redemption_Units_Blank__c, Sub_broker_ARN_Blank__c, KYC_Flag_Default__c  FROM Order_Entry__c where Id ='a2D0k000000dg2bEAA'];        if(orderObj != null){
            return orderObj;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static List<Account> getClientInformation(Id familyId){
        if(familyId != null){ 
            List<Account> clientObj = [SELECT id ,owner.id,owner.name, Parent.id, Parent.Name , name , Risk_Profile_Based_on_IPS__c ,Primary_FA__c , Demat_Account_Number__c , Pan_Number__c FROM Account where Parent.id=:familyId];            
            return clientObj;
        }
        return null;
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
    public static List<Product2> getClientProducts(Id clienAccountId){
        if(clienAccountId != null){
            List<product2> listOfProducts = [SELECT id , name ,Risk_Profile_of_Product__c ,  Face_Value__c ,Source_Id__c,Sub_Asset_Class__c  FROM Product2 WHERE id IN (SELECT Product__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clienAccountId AND Annual_Record__c = false)];
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
                    List<BSE_STAR_UCC__c> bseObject =  [SELECT FIRST_APPLICANT_NAME__c  ,FIRST_APPLICANT_PAN__c , SECOND_APPLICANT_NAME__c , THIRD_APPLICANT_NAME__c , CDSLCLTID__c , CLIENT_CODE__c ,CLIENT_HOLDING__c, CLIENT_TYPE__c , CLIENT_DEFAULT_DP__c, CLIENT_NOMINEE__c, NSDLCLTID__C FROM BSE_STAR_UCC__c where FIRST_APPLICANT_PAN__c=:clientObj.Pan_Number__c ];
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
        //List<Schema_Master__c> schemaMaster = [SELECT id ,AMC_Code__c ,Scheme_Code__c FROM Schema_Master__c];
        Map<String , Schema_Master__c> mapOfSchema = new Map<String , Schema_Master__c>();
        Set<String> amcCode = new Set<String>();
        for(Schema_Master__c masterObj:[SELECT id ,AMC_Code__c ,Scheme_Code__c FROM Schema_Master__c]){
            if(masterObj.AMC_Code__c != null){
                mapOfSchema.put(masterObj.AMC_Code__c ,masterObj);
                amcCode.add(masterObj.AMC_Code__c);
            }
        }
        return mapOfSchema.values();
        //return new List<String>(amcCode);
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
    @AuraEnabled
    public static  EUIN_Master__c getEuinDetails(String faId){
        User userObj = [SELECT id , Edelweiss_Employee_Id__c FROM user where id=:faId limit 1];
        If(userObj != null){
            String employeeId = userObj.Edelweiss_Employee_Id__c;
            EUIN_Master__c euinObj =  [select id , EMP_Code__c , Emp_EUIN_Number__c FROM EUIN_Master__c where EMP_Code__c=:employeeId limit 1];
            return euinObj;
        }
        return null;
    }
    
    
    public static Id getRecordTypeId(String productType, String transactionType){
        Id recordTypeId;
        System.debug('productType'+productType+'transactionType :'+transactionType);
        String fetchRecordTypeId; 
        if(productType.equals('Bond') || productType.equals('SP') ||  productType.equals('CP') || productType.equals('CD') || productType.equals('FD') || productType.equals('ICD') ){
            fetchRecordTypeId = transactionType;		            
        }
	if(productType.equals('PE / AIF'))
        {           
            System.debug('Inside PE/AIF');
            fetchRecordTypeId = 'PE_AIF_' + transactionType;            
        } 
	else {
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
        }
         System.debug('fetchRecordTypeId :'+fetchRecordTypeId);
        return recordTypeId;
    }
    
    
    @AuraEnabled
    public static String saveObj(Order_Entry__c orderEntryObj , String orderEntryId){
        Boolean isDelete = false;
        orderEntryObj.RecordTypeId = EditTransactionController.getRecordTypeId(orderEntryObj.Product_Type_Order_Entry__c ,orderEntryObj.Transaction_Type__c );
        orderEntryObj.Family_Name__r=null;
        orderEntryObj.Order_Date__c = system.today();
        orderEntryObj.Value_Date__c = system.today();
	 orderEntryObj.Transaction_Amount_Financial_Transaction__c =string.valueof(orderEntryObj.Transaction_Amount_Financial_Transaction__c);
          orderEntryObj.Commitment_Amount__c= string.valueof(orderEntryObj.Commitment_Amount__c);      
	        if(orderEntryObj.Folio__c == null){
            orderEntryObj.Folio__c = 'New';            
        }        
        if(orderEntryObj.Folio__c == 'New'){
            orderEntryObj.Folio_Blank__c = '';
        } else {
            orderEntryObj.Folio_Blank__c = orderEntryObj.Folio__c;
        }
        if(orderEntryObj.Transaction_Type__c == 'Subscription (New)'){
          orderEntryObj.Folio__c = 'New';  
        }
        /*Below code will uncomment latter*/
        //orderEntryObj.Status__c='Preview Mode';
        // insert orderEntryObj;
        /*Below code Added :: CXO user can EDIT only Rejected Record Start */
        	Integer profileFlag = checkCXOProfile();
        	if(profileFlag == -1 && orderEntryObj.Status__c =='Rejected')
                orderEntryObj.Status__c='Preview Mode';
        /*Below code Added :: CXO user can EDIT only Rejected Record Ends */
        System.debug('orderEntryObj.Status__c==== '+orderEntryObj.Status__c);
        list<Order_Entry__c> listOfOrderEntry = new list<Order_Entry__c> ();
        list<Attachment> attachmentLst = new list<Attachment>();
        list<Attachment> deleatchtLst = new list<Attachment>();
        List<Attachment> deleteOldAttachment = new List<Attachment>();
               
        if(orderEntryObj.Transaction_Type__c == 'Purchase'){
           orderEntryObj.Transaction_Amount_Export__c = orderEntryObj.Transaction_Amount_Financial_Transaction__c; 
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
        listOfOrderEntry.add(orderEntryObj);
        
        if(orderEntryId != ''){
            List<Attachment> atch = [Select Id,ParentId,Name,Body,ContentType from Attachment where ParentId=:orderEntryId];
            for(Attachment atObj : atch){
                deleteOldAttachment.add(atObj);
            }
        }
        Database.SaveResult[] srList = Database.update(listOfOrderEntry, false);
        Integer statusFlag = 0;
        String saveId;
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
                    saveId = 'Error '+objErr.getMessage();
                }
                
            } 
        }
        if(statusFlag == 1){
            insert attachmentLst;
            delete deleatchtLst;
            isDelete = true;
            EditTransactionController.deleteOldAttachment(isDelete,orderEntryId, deleteOldAttachment);
            return saveId;
        }if(saveId.contains('Error')) {
            return saveId;
        }
        return '';
    }
    public static void deleteOldAttachment(Boolean isDelete,String orderEntryId , List<Attachment> deleteOldAttachment){
        if(isDelete){
            List<Attachment> atch = [Select Id,ParentId,Name,Body,ContentType from Attachment where ParentId=:orderEntryId];
            if(atch.size() > 1){
                Delete deleteOldAttachment;
            }
        }
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
    /*@AuraEnabled
    public static List<Client_Asset_Information__c> getFolioNumbers(Id clientAccountId , Id productId){
        if( clientAccountId != null && productId != null){
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false];
            System.debug('*** clientAssetList'+clientAssetList);
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
        if( clientAccountId != null && productId != null){
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Product__c =:productId AND Annual_Record__c = false  AND Sub_Asset_Class__c like '%Mutual%' AND Folio_Number__c != ''];
            List<String> folioList = new  List<String> ();
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
    
   /* @AuraEnabled
    public static List<Client_Asset_Information__c> getFolioNumbersPurchase(Id clientAccountId){
        if( clientAccountId != null ){
            list<Client_Asset_Information__c> clientAssetList = [SELECT id , Quantity__c ,Folio_Number__c, Product__c,Annual_Record__c,Client__c , Total_AUM__c FROM Client_Asset_Information__c WHERE Client_Account__c =:clientAccountId AND Annual_Record__c = false];
            return clientAssetList;
        }
        return null;
    }*/
    
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
    
   /*  @AuraEnabled
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
    } */
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
    @testvisible
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
    /*Code is added to get the attachemnet name of selected order entry */ 
     @AuraEnabled
    public static String getAttachName(Id parentId){
      Attachment atch = [SELECT Name from Attachment where ParentId =: parentId];
        if(atch.Name != null){
            return atch.Name;
        }
        return '';
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
    public static Id gerAttachementParentId(){
       List<Corporate_Action_Notification__c> notification = [SELECT Id FROM Corporate_Action_Notification__c Limit 1];
        return notification[0].Id;
        
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
            if(pName .containsIgnoreCase('Operations Head') || pName .containsIgnoreCase('Operations')){
                isValid  = 1;
                /* IMP*******************
                isValid  = -1; revert this when Edit is not allowed for Operation user.
                ********************IMP */
            }
        }   
        return isValid;
    }
    @AuraEnabled
    public static Integer checkCXOProfile(){
        Integer isValid = 1;
        string pName ;
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            pName =  currentUser.Profile.Name;
            if(pName .containsIgnoreCase('Client Experience Office (CXO)') || pName .containsIgnoreCase('CXO National Head') || pName .containsIgnoreCase('CXO Zonal Head')){
                isValid  = -1;
            }
        }   
        return isValid;
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
                    List<String> folioListReturn = EditTransactionController.folioEligibilityCheck(folioList,clientAccountId,bseStarAmcCode,holdingType,transactionType);
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
         String responsebodyStr = res.getBody();
        System.debug('responsebodyStr'+responsebodyStr);
         System.debug('res'+res);
        if(responsebodyStr == 'null'){
            system.debug('return');
            return null;
        }
        if(res!= null){
            if(res.getBody() != null){
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
                        if(folioByApi != null ||!(folioByApi.isEmpty())){
                            List<String> folioListReturn = EditTransactionController.folioEligibilityCheck(folioByApi,clientAccountId,bseStarAmcCode,holdingType,transactionType);
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
                }else {
                    return null;
                }
            }else {return null;}
        }else {return null;}
        
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
}