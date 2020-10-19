@istest
public class Edelweiss_batchCreateClientTest {
    public testmethod static void testEdelweiss_batchCreateClient()
    {
        Account aa=TestClassutils.createAccount();
        aa.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
        insert aa;
        
     List<Lead> leadlist=TestClassUtils.createLead();
     Lead l=leadlist[0];
     l.Lead_1st_Milestone_Complete__c=true;
     l.Lead_2nd_Milestone_Complete__c=true;
     l.Lead_3rd_Milestone_Complete__c=true;
     l.Status='R2';
     l.FA_had_open_a_ticket_case__c = True;
     l.Reply_received_from_client__c = true;
     l.Next_Follow_Up_Established__c = true;
     l.Entered_Meeting_Notes_For_R1__c = true;
     l.IsConverted = false;
     l.All_Product_details_filled__c = True;
     l.Allocation_Fields_duly_completed__c = True; 
     l.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
     l.Asset_Allocation_Across_Wealth_Managers__c=200;
     l.Entity_Type__c='Individual';
     l.Products_Client_is_Interested_in__c='Mutual Funds - Debt';
     l.Products_Proposed_to_Client__c='Mutual Funds - Liquid';
     l.All_Product_details_filled__c=true;
     l.PAN_Number__c='CXBPP2043Q';
     insert leadlist;   
       
        
     List<Edelweiss_Clients_Staging_Container__c> listBatchRecords=new List<Edelweiss_Clients_Staging_Container__c>();
     Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();
     ecsc.PAN_Number__c='CXBPP2043Q';
     ecsc.GWM_Online_Account_Id__c = 'AA0101';
     ecsc.GWM_Online_Client_Id__c = 'AC0101';
     ecsc.GWM_Online_Family_Id__c = 'AF0101';
     ecsc.Is_Converted_Lead__c=true;
     ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Client_Name__c = 'Test';
     ecsc.Family_Name__c = 'Test';
     ecsc.Primary_CXO_Employee_Id__c='1221';
     ecsc.Primary_CXO_Miles_Id__c = '212';
     ecsc.Primary_FA_Employee_Id__c = '1121';
     ecsc.Primary_FA_Miles_Id__c = '121';
     ecsc.Is_Client_Family_Head__c = 'No';
     listBatchRecords.add(ecsc);
     insert listBatchRecords;
     
      Account a=TestClassutils.createAccount();
      a.Name='XYZ';
      a.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
      insert a;  
        
     TestClassutils.InsertSysProperties();
     Edelweiss_batchCreateClient obj=new Edelweiss_batchCreateClient();
     Test.startTest();
        
     Database.executeBatch(obj);
     Test.stopTest(); 
    }
    
    
     public testmethod static void testEdelweiss_batchCreateClientSuccess()
    {
        Account aa=TestClassutils.createAccount();
        aa.RecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
        insert aa;
        
     List<Lead> leadlist=TestClassUtils.createLead();
     Lead l=leadlist[0];
     l.Lead_1st_Milestone_Complete__c=true;
     l.Lead_2nd_Milestone_Complete__c=true;
     l.Lead_3rd_Milestone_Complete__c=true;
     l.Status='R2';
     l.FA_had_open_a_ticket_case__c = True;
     l.Reply_received_from_client__c = true;
     l.Next_Follow_Up_Established__c = true;
     l.Entered_Meeting_Notes_For_R1__c = true;
     l.IsConverted = false;
     l.All_Product_details_filled__c = True;
     l.Allocation_Fields_duly_completed__c = True; 
     l.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get(EdelweissConstants.LEAD_RECORD_TYPE).getRecordTypeId();
     l.Asset_Allocation_Across_Wealth_Managers__c=200;
     l.Entity_Type__c='Individual';
     l.Products_Client_is_Interested_in__c='Mutual Funds - Debt';
     l.Products_Proposed_to_Client__c='Mutual Funds - Liquid';
     l.All_Product_details_filled__c=true;
     l.PAN_Number__c='CXBPP2043Q';
     insert leadlist;   
       
        
     List<Edelweiss_Clients_Staging_Container__c> listBatchRecords=new List<Edelweiss_Clients_Staging_Container__c>();
     Edelweiss_Clients_Staging_Container__c ecsc=new Edelweiss_Clients_Staging_Container__c();
     ecsc.PAN_Number__c='CXBPP2043Q';
     ecsc.GWM_Online_Account_Id__c = 'AA0101';
     ecsc.GWM_Online_Client_Id__c = 'AC0101';
     ecsc.GWM_Online_Family_Id__c = 'AF0101';
     ecsc.Family_Name__c = 'FamName';
     ecsc.Client_Name__c = 'ClientName';
     ecsc.Is_Converted_Lead__c=true;
     ecsc.Official_Address__c = 'India Mumbai';
     ecsc.Mailing_Address__c = 'India Mumbai';
     
     ecsc.Account_Name__c='Test';
     ecsc.Account_Type__c = '1113';
     ecsc.Primary_CXO_Employee_Id__c='1221';
     ecsc.Primary_CXO_Miles_Id__c = '212';
     ecsc.Primary_FA_Employee_Id__c = '1121';
     ecsc.Primary_FA_Miles_Id__c = '121';
     ecsc.Is_Client_Family_Head__c = 'No';
     
     listBatchRecords.add(ecsc);
     insert listBatchRecords;
     
      Account a=TestClassutils.createAccount();
      a.Name='XYZ';
      a.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(EdelweissConstants.CLIENT_RECORD_TYPE).getRecordTypeId();
      insert a;  
        
     TestClassutils.InsertSysProperties();
      
     Edelweiss_batchCreateClient obj=new Edelweiss_batchCreateClient();
     Test.startTest();
     Database.executeBatch(obj);
     Test.stopTest(); 
    }
}