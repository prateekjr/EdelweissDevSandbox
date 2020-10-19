public class EdelweissConstants{
    /*Constants for Case Types*/
    public static String MILES_ACCOUNT_OPENING = 'Miles Account Opening';
    public static String TENTATIVE_MILES_ACCOUNT_OPENING = 'Tentative Miles Account Opening';
    public static String EXCHANGE_ACCOUNT_OPENING = 'Exchange Account Opening';
    public static String TRADING_DEMAT = 'Trading_Demat';
    public static String TRADING_DEMAT_OPENED = 'Trading & Demat Account Opened by Mid-office';
    public static String ONLY_TRADING_OPENED = 'Trading Account Opened by Mid-office';
    public static String ONLY_DEMAT_OPENED = 'Demat Account Opened by Mid-office';
    public static String FINANCIAL_TRANSACTION = 'Financial Transaction';
    public static String SERVICE_REQUEST = 'Service Request';
    public static String FUNDING_ACCOUNT_OPENING = 'Funding Account Opening';
    public static String NON_EXCHANGE_ACCOUNT_OPENING = 'Non-Exchange Account Opening';
    public static String OTHER_NON_EXCHANGE_PRODUCTS = 'Other Non-Exchange Products';
    public static String ACCOUNT_OPENING = 'Account Opening';
	public static String FUND_TRANSFER = 'Fund Transfer';
    public static String WEALTH_INFINITY_WF = 'Wealth And Infinity WorkFlow';
    
    
    /*Constants for Event Types*/
    public static String SERVICE_EVENT = 'Service_Event';
    public static String EVENT_COMMUNICATION_TYPE = 'In-Person'; 
    
    /*Constants for MAO Tasks*/ 
    public static String DOCUMENT_COLLECTION = 'Document Collection';
    public static String SEND_MEETING_REQUEST = 'Send Meeting Request';
    public static String MEETING_FIXED = 'Meeting Fixed';
    public static String SEND_WELCOME_EMAIL = 'Send Welcome Email';
    public static String DOCUMENT_VERIFICATION = 'Document Collection and Verification';
    public static String KRA_VERIFICATION = 'KRA Verification';
    public static String SENDING_CHECKLIST = 'Sending of Checklist';
    public static String SENDING_MoM = 'Send Minutes of Meeting';
    public static String MILES_ACCOUNT_OPENING_AUTO_CLOSURE = 'Miles Account Opening Auto Closure';
    public static String UPDATE_MANDATORY_DETAILS = 'Update Mandatory Details';
    public static String MOUI_AUTO_CLOSURE = 'MOUI Auto Closure';
    public static String MINI_IPS_RISK_PROFILE = 'Mini IPS Risk Profile';
    
    /*Constants for Infinity WF*/
    public static String SKIP_SEND_TO_MOUI = 'Skip or Send to MOUI';
    public static String ACCEPT_STEP = 'Accept';
    public static String STEP_TYPE_W = 'W';
    public static Integer SKIP_SEND_TO_MOUI_SEQUENCE = 2;
    public static String CASE_CLOSED_REMARKS = 'Case closed by integration';
    public static String CASE_SUB_STATUS_CLOSED_SUCCESS = 'Closed-Success';
    
    /*Constants for Task Types*/
    public static String SERVICE_TASK = 'Service_Task';
    public static String BANK_ACCOUNT_TASK_RECORD_TYPE = 'Bank_Account';
    public static String BANK_ACCOUNT_OPENING ='Bank Account Opening';
    
    
    /*Constants for Case status*/
    public static String CASE_ON_HOLD_STATUS = 'On Hold';
    public static String CASE_OPEN_STATUS = 'Open';
    public static String CASE_CLOSED_REJECTED_STATUS = 'Closed – Rejected';
    public static String CASE_CLOSED_SUCCESS_STATUS = 'Closed – Success';
    public static String CASE_ESCALATED_STATUS = 'Escalated';
    
    /*Constants for Opportunity status*/
    public static String OPP_WON_STATUS = 'Won';
    public static String OPP_LOST_STATUS = 'Lost';
    public static String OPP_ONGOING_STATUS = 'Ongoing';
    
    /*Constants for Task status*/
    public static String TASK_COMPLETED_STATUS = 'Completed';
    /*Constants for Event status*/
    public static String EVENT_COMPLETED_STATUS = 'Completed';
    /*Constants for Lead Status*/
    public static String LEAD_WARM_STATUS = 'Warm';
    public static String LEAD_COLD_STATUS = 'Cold';
    public static String LEAD_HOT_STATUS = 'Hot';
    public static String LEAD_R0_STATUS = 'R0';
    public static String LEAD_R1_STATUS = 'R1';
    public static String LEAD_R2_STATUS = 'R2'; 
    public static String LEAD_DATABASE_STATUS = 'Lead Database';
    /*Constants for Lead Category*/
    public static String LEAD_CORPORATE_CATEGORY = 'Corporate';
    public static String LEAD_INDIVIDUAL_CATEGORY  = 'Individual';
    public static String LEAD_HYBRID_CATEGORY  = 'Both';
    /*Constants for Lead Database Queue*/
    public static String LEAD_DATABASE_QUEUE_API_NAME = 'Lead_Database_Queue';
    public static String LEAD_DATABASE_QUEUE_LABEL = 'Lead Database Queue';
    /*Task Link meeting type field picklist values*/
    public static String TASK_INITIAL_MEETING  = 'Initial Meeting';
    public static String TASK_FOLLOWUP_MEETING  = 'Followup Meeting';
    
    /*BOT Case creation service default Lead*/
    public static String LEAD_NAME  = 'Prospect';
    
    
    /*RiskProfile Category*/
    public static String CATEGORY_A  = 'A - I agree & want RP to be basis of investment';
    public static String CATEGORY_B  = 'B - I agree but do not want RP to be basis of investment';
	
	/* Complaint Acknowledgement mail*/
	public static String COMPLAINT_ACK_ACCOUNT_NAME = '[ACNAME]';
    public static String COMPLAINT_ACK_CSO_NAME = 'CSONAME####';
    public static String COMPLAINT_ACK_EMAIL_TEMPLATE = 'Complaint Acknowledgement';
    public static String COMPLAINT_ACK_CASE_NUMBER= '[CASENUMBER]';
    
    /* NPS Email - Pertaining To field */
    public static String FA_RELATED_BUSINESS_HEAD = 'FA Related';

    /* Mobile Notification Queue */
    public static String MOBILE_NOTIFICATION = 'Mobile Notification';
    
    
    public static String FAProfileName = 'Financial Advisor';
    public static Map<String,String>LeadrecordTypeMap;
    public static Map<Id,String>CaseRecordTypeMap;
    public static Map<String,Id>ServiceTatRecordTypeMap;
    public static Map<String,Id>AccountRecordTypeMap;
    public static Map<String,Id>EventRecordTypeMap;
    public static Map<String,Id>TaskRecordTypeMap;
    public static Map<Id,Contact>IAGContactMap;
    public static MAP<ID , User> userList;
    public static Integer Working5BussinessDaysInHours;
    public static Map<Id,System_Constant__mdt> sysConstantMap;
    public static BusinessHours stdBusinessHours;
    public static Map<Id,Profile>  profileMap;
    public static Map<Id ,Group> groupMap;
    public static Map<Id,String>OrderEntryRecordTypeMap;
    static{
        LeadrecordTypeMap= new Map<String,Id>();
        CaseRecordTypeMap= new Map<Id, String>();
        OrderEntryRecordTypeMap = new Map<Id, String>();
        ServiceTatRecordTypeMap = new Map<String, Id>();
        AccountRecordTypeMap = new Map<String,Id>();
        EventRecordTypeMap = new Map<String,Id>();
        TaskRecordTypeMap = new Map<String,Id>();
        List<RecordType> recordTypeList = [Select r.Id, r.Name, r.SobjectType, r.DeveloperName 
                                         From RecordType r ];
        if(recordTypeList !=null && recordTypeList .size()>0){
            for(RecordType recordTypeObj:recordTypeList){
                if(recordTypeObj.SobjectType == 'Lead' ){
                    LeadrecordTypeMap.put(recordTypeObj.DeveloperName ,recordTypeObj.Id);
                }else if(recordTypeObj.SobjectType == 'Case'){
                    CaseRecordTypeMap.put(recordTypeObj.Id, recordTypeObj.Name);
                }else if(recordTypeObj.SobjectType == 'Service_Type_TAT_Mapping__c'){
                    ServiceTatRecordTypeMap.put(recordTypeObj.Name, recordTypeObj.Id);
                }else if(recordTypeObj.SobjectType == 'Account'){
                    AccountRecordTypeMap.put(recordTypeObj.Name, recordTypeObj.Id);
                }else if(recordTypeObj.SobjectType == 'Event'){
                    EventRecordTypeMap.put(recordTypeObj.DeveloperName ,recordTypeObj.Id);
                }else if(recordTypeObj.SobjectType == 'Task'){
                    TaskRecordTypeMap.put(recordTypeObj.DeveloperName ,recordTypeObj.Id);
                }else if(recordTypeObj.SobjectType == 'Order_Entry__c'){
                    OrderEntryRecordTypeMap.put(recordTypeObj.Id, recordTypeObj.Name);
                }                   
            }
        }
        
        /*IAG contact Set*/
        IAGContactMap = new Map<Id,Contact>();
        List<Contact> IAGContactList = [SELECT c.RecordType.DeveloperName, c.RecordTypeId, 
                                        c.Id FROM Contact c WHERE c.RecordType.DeveloperName = 'IAG_Contact' ];
        for(Contact contactObj : IAGContactList){
            IAGContactMap.put(contactObj.Id,contactObj);
        }
        
        /*Query Optimization*/
        
        userList = new Map<ID, user>([SELECT Id, Name,Edelweiss_Employee_Id__c , ManagerId, Manager.email, IsActive , Business_Head__c, Regional_Head__c , Profile.Name , Zone__c , manager.Name,manager.Id , Email FROM USER]);
        Working5BussinessDaysInHours = 5;  
        sysConstantMap = new Map<Id,System_Constant__mdt>([Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Working5BussinessDaysInHours']);
        stdBusinessHours = [select id from businesshours where isDefault = true];
        profileMap =  new Map<Id,Profile>([SELECT Name, Id FROM Profile]); 
        groupMap = new Map<Id ,Group>([SELECT DeveloperName, Id, Type FROM Group WHERE (DeveloperName LIKE '%Lead_Database_Queue%' AND Type != 'Queue')]);
        
        
        

    }
    //-------------------------------------------------
    /*Variables to be used for Sales*/
    //-------------------------------------------------
    //********Constants for communication rule**********
    public static string CALLED_FROM_INPERSON_MEETING = 'InPersonMeeting';
    public static string CALLED_FROM_PORTFOILIO_REVIEW= 'Portfoilio';
    public static string CALLED_FROM_INTERACTION= 'Interaction';
    public static string CALLED_FROM_RH_BH_MEETING= 'RH_BH_Meeting';
    public static string MoM_TASK_TYPE = 'MoM';
    public static string OPPORTUNITY_WARM_STAGE = 'Warm';
    public static string OPPORTUNITY_COLD_STAGE = 'Cold';
    public static string OPPORTUNITY_HOT_STAGE = 'Hot';
    public static string ACTIVITY_AGENDA_SALE_OPPORTUNITY = 'Sales Opportunity';
    //-------------------------------------------------
    /* Variables used for integration apex classes */
    //------------------------------------------------    
    //******** Record Type Variable *********
    public static string FAMILY_RECORD_TYPE = 'Family';
    public static string CLIENT_RECORD_TYPE = 'Client';
    public static string THIRD_PARTY_RECORD_TYPE = 'Third Party';
    public static string EDELWEISS_CONTACT_RECORD_TYPE = 'Edelweiss Contact';
    public static string LEAD_RECORD_TYPE = 'Lead';
    //-----------------------------
    //******** sObject API name used in integration *********
    public static string OBJECT_PRODUCT = 'Product2';
    public static string OBJECT_ACCOUNT = 'Account';
    public static string OBJECT_CLIENT_ACCOUNT = 'Client_Account__c';
    public static string OBJECT_LEAD = 'Lead';
    //********* Schedulers Variables ***************
    public static Integer SCHEDULER_FREQUENCY_IN_HOURS = 24;
    
    public static string FA_CXO_REST_API_NAME ='Http Post FA-CXO mapping';
    public static string REST_API_STATUS_SUCCESSFUL ='Successful';
    public static string REST_API_STATUS_FAILED ='Failed';
    public static String FAMILY_CLIENT_R3_STATUS = 'R3';
    public static string MILES_ACCOUNT_OPENING_RECORD_TYPE = 'Miles Account Opening';
    public static string MILES_ACCOUNT_OPENING_TASK_TYPE='Miles Account Opening';
    public static string MILES_ACCOUNT_OPENING_AUTO_CLOSURE_TASK_TYPE='Miles Account Opening Auto Closure';
    public static string IN_PROGRESS_STATUS='In Progress';
    
    public static string PRODUCT_NOT_AVAILABLE_FLAG='Product Not Available';
    public static string PRODUCT_NAME_MISMATCH_FLAG='Product Name Mismatch';
    public static string TENTATIVE_CLIENT_RECORD_TYPE = 'Tentative_Client';
    public static string TENTATIVE_FAMILY_RECORD_TYPE ='Tentative_Family';
    //------------------------------------------------
    
    // Miles Account Status Values
    public static string MILES_ACCOUNT_STATUS_ACTIVE='Active';
    public static string MILES_ACCOUNT_STATUS_CLOSED='Closed';
    public static string MILES_ACCOUNT_STATUS_CLOSE='Close';
    
    //PW2 value in Staging Backoffice Code 
    
   // public static List<String> BACK_OFFICE_CODE_NBFC_ClientValue=new List<String>{'PW2','PW5'};
      public static List<String> BACK_OFFICE_CODE_NBFC_ClientValue=new List<String>{'PW2'};
    //public static string BACK_OFFICE_CODE_NBFC_PW2='PW2';
    
    public static string APPROVAL_PROCESS_SPECIAL_BROKERAGE='Special_Brokerage_Approval_RA';
    
    public static string IS_CLIENT_HEAD_YES='Yes';

}