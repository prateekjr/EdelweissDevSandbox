@istest
public class Edelweiss_batchUpdateClientDataTest {
  
    public static testmethod void testEdelweiss_batchUpdateClientData()
    {
     Testclassutils.InsertSysProperties();
     Account pa=TestClassUtils.createAccount();
     pa.RecordTypeId=Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();   
     pa.GWM_Online_Id__c='PQR123';
     insert pa;
        
     Account ca=TestClassutils.createAccount();
     ca.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
     ca.GWM_Online_Id__c='XYZ111';   
     insert ca;  
        
      Contact c=new Contact();
      c.AccountId=ca.Id;
      c.LastName='ABC';
      c.Office_Phone__c='098-764321';
      c.Mobile_2__c='9876542100';
      c.Residential_Phone__c='123-456788';
      c.Secondry_Email__c='ABC@persistent.com';
      c.Official_Email__c='ABC@persistent.com';
      c.Official_Address__c='PUne';
      c.Is_Primary_Contact__c=true;
      c.MobilePhone='9876543210';
      c.Email='ABC@persistent.com';
      insert c;
        
      Client_Account__c cac=new Client_Account__c();
       cac.Client__c=ca.id; 
      insert cac;  
        
        
     Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();   
     ecsc.Account_Name__c='Indi A N Khushwaha'; 
     ecsc.Client_First_Name__c='RAjesh';
     ecsc.Client_Last_Name__c='Pukale';
     ecsc.GWM_Online_Client_Id__c='XYZ111';
     ecsc.Official_Address__c='Hinjewadi';
     ecsc.Official_City__c='Pune';
     ecsc.Official_State__c='Maharashtra';
     ecsc.Official_Country__c='India';
     ecsc.Mailing_Address__c='Hinjewadi';
     ecsc.Mailing_City__c='Pune';
     ecsc.Mailing_State__c='Maharashtra';
     ecsc.Mailing_Country__c='India';
     ecsc.GWM_Online_Family_Id__c='PQR123';
     ecsc.Office_Number__c='022-123456';
     ecsc.Alternate_Number__c='9876543210';
     ecsc.Mobile_No__c = '8888888888';
     ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Client_Name__c = 'Test';
        ecsc.Family_Name__c = 'Test';
        ecsc.GWM_Online_Account_Id__c='1112';
        ecsc.GWM_Online_Client_Id__c = '1122';
        ecsc.GWM_Online_Family_Id__c = '1121';
        ecsc.PAN_Number__c = 'RRRRR7777R';
        ecsc.Primary_CXO_Employee_Id__c='1221';
        ecsc.Primary_CXO_Miles_Id__c = '212';
        ecsc.Primary_FA_Employee_Id__c = '1121';
        ecsc.Primary_FA_Miles_Id__c = '121';
        ecsc.Is_Client_Family_Head__c = 'No';
     insert ecsc;
        
     Edelweiss_batchUpdateClientData obj=new Edelweiss_batchUpdateClientData();
    
     Test.startTest();
     Database.executeBatch(obj);
     Test.stopTest();
    }
    
     public static testmethod void testEdelweiss_batchUpdateClientDataNewFamily()
    {
     Testclassutils.InsertSysProperties();
     Account pa=TestClassUtils.createAccount();
     pa.RecordTypeId=Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();   
     pa.GWM_Online_Id__c='PQR123';
     insert pa;
        
     Account ca=TestClassutils.createAccount();
     ca.parentId = pa.id;
     ca.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
     ca.GWM_Online_Id__c='XYZ111';   
     insert ca;  
        
      Contact c=new Contact();
      c.AccountId=ca.Id;
      c.LastName='ABC';
      c.Office_Phone__c='098-764321';
      c.Mobile_2__c='9876542100';
      c.Residential_Phone__c='123-456788';
      c.Secondry_Email__c='ABC@persistent.com';
      c.Official_Email__c='ABC@persistent.com';
      c.Official_Address__c='PUne';
      c.Is_Primary_Contact__c=true;
      c.MobilePhone='9876543210';
      c.Email='ABC@persistent.com';
      insert c;
        
      Client_Account__c cac=new Client_Account__c();
      cac.Client__c=ca.id; 
      insert cac;  
    ca=TestClassutils.createAccount();
     ca.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
     ca.ParentId = pa.id;
     ca.GWM_Online_Id__c='XYZ112';   
     insert ca;  
        
     Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();   
     ecsc.Account_Name__c='Indi A N Khushwaha'; 
     ecsc.Client_First_Name__c='RAjesh';
     ecsc.Client_Last_Name__c='Pukale';
     ecsc.GWM_Online_Client_Id__c='XYZ111';
     ecsc.Official_Address__c='Hinjewadi';
     ecsc.Official_City__c='Pune';
     ecsc.Official_State__c='Maharashtra';
     ecsc.Official_Country__c='India';
     ecsc.Mailing_Address__c='Hinjewadi';
     ecsc.Mailing_City__c='Pune';
     ecsc.Mailing_State__c='Maharashtra';
     ecsc.High_Priority_Client__c = '1';
     ecsc.Focus_30_Client__c ='1';
     ecsc.Mobile_No__c ='8888888888';
     ecsc.Salutation__c ='MR';
     ecsc.Mailing_Country__c='India';
     ecsc.GWM_Online_Family_Id__c='PQR1234';
     ecsc.Office_Number__c='022-123456';
     ecsc.Alternate_Number__c='9876543210';
     ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Client_Name__c = 'Test';
        ecsc.Family_Name__c = 'Test';
        ecsc.GWM_Online_Account_Id__c='1112';
        ecsc.GWM_Online_Client_Id__c = '1122';
        ecsc.GWM_Online_Family_Id__c = '1121';
        ecsc.PAN_Number__c = 'RRRRR7777R';
        ecsc.Primary_CXO_Employee_Id__c='1221';
        ecsc.Primary_CXO_Miles_Id__c = '212';
        ecsc.Primary_FA_Employee_Id__c = '1121';
        ecsc.Primary_FA_Miles_Id__c = '121';
        ecsc.Is_Client_Family_Head__c = 'No';

     insert ecsc;
      ecsc=new Edelweiss_Clients_Staging_Container__c();   
     ecsc.Account_Name__c='Indi A N Khushwaha'; 
     ecsc.Client_First_Name__c='RAjesh';
     ecsc.Client_Last_Name__c='Pukale';
     ecsc.GWM_Online_Client_Id__c='XYZ112';
     ecsc.Official_Address__c='Hinjewadi';
     ecsc.Official_City__c='Pune';
     ecsc.Official_State__c='Maharashtra';
     ecsc.Official_Country__c='India';
     ecsc.Mailing_Address__c='Hinjewadi';
     ecsc.Mailing_City__c='Pune';
     ecsc.Mailing_State__c='Maharashtra';
     ecsc.Mailing_Country__c='India';
     ecsc.GWM_Online_Family_Id__c='PQR1234';
     ecsc.Office_Number__c='022-123456';
     ecsc.Alternate_Number__c='9876543210';
        ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Client_Name__c = 'Test';
        ecsc.Family_Name__c = 'Test';
        ecsc.GWM_Online_Account_Id__c='1112';
        ecsc.GWM_Online_Client_Id__c = '1122';
        ecsc.GWM_Online_Family_Id__c = '1121';
        ecsc.PAN_Number__c = 'RRRRR7777R';
        ecsc.Primary_CXO_Employee_Id__c='1221';
        ecsc.Primary_CXO_Miles_Id__c = '212';
        ecsc.Primary_FA_Employee_Id__c = '1121';
        ecsc.Primary_FA_Miles_Id__c = '121';
        ecsc.Is_Client_Family_Head__c = 'No';
     insert ecsc;
        
     Edelweiss_batchUpdateClientData obj=new Edelweiss_batchUpdateClientData();
    
     Test.startTest();
     Database.executeBatch(obj);
     Test.stopTest();
    }
     
     public static testmethod void testEdelweiss_batchUpdateClientDataFamilyNameChanged()
    {
     Testclassutils.InsertSysProperties();
     Account pa=TestClassUtils.createAccount();
     pa.RecordTypeId=Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.FAMILY_RECORD_TYPE).getRecordTypeId();   
     pa.GWM_Online_Id__c='PQR123';
     insert pa;
        
     Account ca=TestClassutils.createAccount();
     ca.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
     ca.ParentId = pa.id;
     ca.GWM_Online_Id__c='XYZ111';   
     insert ca;  
        
      Contact c=new Contact();
      c.AccountId=ca.Id;
      c.LastName='ABC';
      c.Office_Phone__c='098-764321';
      c.Mobile_2__c='9876542100';
      c.Residential_Phone__c='123-456788';
      c.Secondry_Email__c='ABC@persistent.com';
      c.Official_Email__c='ABC@persistent.com';
      c.Official_Address__c='PUne';
      c.Is_Primary_Contact__c=true;
      c.MobilePhone='9876543210';
      c.Email='ABC@persistent.com';
      insert c;
        
      Client_Account__c cac=new Client_Account__c();
      cac.Client__c=ca.id; 
      insert cac;  
    
    List<Case> caselist=TestclassUtils.createTestCaseForFT();
    Case c1=caselist[0];  
    c1.accountId = pa.id;
    //insert c1;
    Opportunity o =  TestClassUtils.createOpportunity();
    o.AccountId = ca.id;
    o.stageName = 'Ongoing';
    insert o;
     Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();   
     ecsc.Account_Name__c='Indi A N Khushwaha'; 
     ecsc.Client_First_Name__c='RAjesh';
     ecsc.Client_Last_Name__c='Pukale';
     ecsc.GWM_Online_Client_Id__c='XYZ111';
     ecsc.Official_Address__c='Hinjewadi';
     ecsc.Official_City__c='Pune';
     ecsc.Official_State__c='Maharashtra';
     ecsc.Official_Country__c='India';
     ecsc.Mailing_Address__c='Hinjewadi';
     ecsc.Mailing_City__c='Pune';
     ecsc.Mailing_State__c='Maharashtra';
     ecsc.Mailing_Country__c='India';
     ecsc.GWM_Online_Family_Id__c='PQR123';
     ecsc.Alternate_Number__c='9876543210';
     ecsc.Family_Name__c = 'Family Name';
     ecsc.Office_Number__c='022-123456';
     ecsc.Mobile_No__c = '8888888888';
        ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Client_Name__c = 'Test';
        ecsc.Family_Name__c = 'Test';
        ecsc.GWM_Online_Account_Id__c='1112';
        ecsc.GWM_Online_Client_Id__c = '1122';
        ecsc.GWM_Online_Family_Id__c = '1121';
        ecsc.PAN_Number__c = 'RRRRR7777R';
        ecsc.Primary_CXO_Employee_Id__c='1221';
        ecsc.Primary_CXO_Miles_Id__c = '212';
        ecsc.Primary_FA_Employee_Id__c = '1121';
        ecsc.Primary_FA_Miles_Id__c = '121';
        ecsc.Is_Client_Family_Head__c = 'No';
     insert ecsc;
     Edelweiss_batchUpdateClientData obj=new Edelweiss_batchUpdateClientData();
    
     Test.startTest();
     Database.executeBatch(obj);
     Test.stopTest();
    }
}