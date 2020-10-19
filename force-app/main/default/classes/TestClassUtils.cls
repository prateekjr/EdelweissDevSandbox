public with sharing class TestClassUtils {
    public static List<Case> createTestCaseForMAO(){
        List<Case> caseList = new List<Case>{};
            Case testCase = new Case();
        RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Case' and (Name =: EdelweissConstants.MILES_ACCOUNT_OPENING Or Name =: EdelweissConstants.FUNDING_ACCOUNT_OPENING or Name =: EdelweissConstants.EXCHANGE_ACCOUNT_OPENING  )Limit 1];
        //Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Exchange Account Opening').getRecordTypeId(); //; '012O0000000597G';     //recordTypeList.id;
        //testCase.Lead__c = '00QO0000004i0tq';   
        caseList.add(testCase);
        return caseList;
    }
    
    
    public static List<Case> createTestCaseForSR(){
        List<Case> caseList = new List<Case>{};
        RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Case' and Name =: EdelweissConstants.SERVICE_REQUEST];
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeList.id;
        caseList.add(testCase);
        return caseList;
    }

    
    public static List<Case> createTestCaseForSROnHold(){
        List<Case> caseList = new List<Case>{};
        RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Case' and Name =: EdelweissConstants.SERVICE_REQUEST];
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeList.id;
        testCase.Status = 'on Hold';
        testCase.On_Hold_Date__c = System.Now()-1;
        testCase.Due_Date_Time__c = System.Now()+1;
        caseList.add(testCase);
        return caseList;
    }

    public static List<Case> createTestCaseForFT(){
        List<Case> caseList = new List<Case>{};
        RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
                                         From RecordType where SobjectType = 'Case' and ( Name =: EdelweissConstants.EXCHANGE_ACCOUNT_OPENING ) Limit 1];
                                                                                        
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeList.id;
        testCase.Status = 'In Progress';
        testCase.Product_Type__c = 'Comtrade Only';
        testCase.Due_Date_Time__c = System.Now()+1;
        
        caseList.add(testCase);
        return caseList;
    }
    private static Integer c1,c2;
    public static Wealth_Manager__c createWealth_Manager(Lead ldObj){
        c1=0;
        Wealth_Manager__c WM =new Wealth_Manager__c();
        WM.Asset_Managed__c=123456+c1;
        
        WM.Lead__c=ldObj.Id;
        WM.Name='HDFC Limited'+c1;
        c1++;
        //insert WM;
        return WM;
    }
    
    public static List<Lead> createLead(){
        c2=0;
        List<Lead> leadLst=new List<Lead>();
        Lead l1=new Lead();
        l1.Category__c='Individual';
        l1.Sub_Category__c='Institutions';
        l1.LeadSource='Internal';
        l1.Sub_Source_Level_1__c='Internal Referral';
        l1.Sub_Source_Level_2__c='FA Referral';
        l1.Employee_name__c='TestEmployee';
        l1.Size_of_Deal__c=15233.0;
        l1.Company='Persistent Systems Ltd';
        l1.LastName='Singh'+c2;
        //l1.Sub_Source_Level_1__c = 'Database';
        //l1.Database_Name__c = '';
        l1.PAN_Number__c='CXBPP2043Q';
        l1.Office_Number__c='2067982014';
        l1.Phone='0987654321';
        leadLst.add(l1);
        c2++;
        return leadLst;
    }
    
    public static Task createTask(Lead lead){
        
        Task t=new Task();
        t.CallDurationInSeconds=45;
        t.Description__c='jdfghkdghd';
        t.Status = EdelweissConstants.TASK_COMPLETED_STATUS ;
        t.Type = EdelweissConstants.MoM_TASK_TYPE;
        t.Subject='Call';
        t.WhoId=lead.Id;
        //insert t;
        return t;
    }
    
     public static Opportunity createOpportunity()
    {
        Opportunity o=new Opportunity();
        o.Name='Test Data';
        o.StageName='Ongoing';
        o.CloseDate= System.today()+1;
        //insert o;
       return o;        
        
    }
    
    public static Account createAccount(){
       Account fam = createFamily();
       insert fam; 
        Account accountObj = new Account();
            accountObj.ParentId = fam.id;
            //accountObj.Name_RecordType__c='Family';
            accountObj.Name='Reliance group';
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase= true;
            return accountObj;
    }
    
    public static Account createFamily(){
         RecordType recordTypeList = [Select Id, Name, SobjectType, DeveloperName 
           From RecordType where SobjectType = 'Account' and Name = 'Family' Limit 1];
            Account accountObj = new Account();
            accountObj.RecordTypeId=recordTypeList.id;
            accountObj.Name='Reliance Family';
            AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase= true;
            return accountObj;
    }
    Public static void LoadMeetingFrequency() 
    {
        
        Meeting_Frequency__c mf=new  Meeting_Frequency__c();
        mf.Name='RH BH Criteria 2';
        mf.Frequency__c='1:1,2:1,3:1,4:1,5:1,6:1';
        insert mf;
        
       
            
        Meeting_Frequency__c mf1=new  Meeting_Frequency__c();
        mf1.Name='InPersonMeeting_Criteria2';
        mf1.Frequency__c='1:1,1:10,1:15,1:20,1:25,1:30';
        insert mf1;
        
          
        Meeting_Frequency__c mf2=new  Meeting_Frequency__c();
        mf2.Name='InPersonMeeting_Criteria3';
        mf2.Frequency__c='1:1,2:1,3:1,4:1,5:1,6:1';
        insert mf2;
        
        Meeting_Frequency__c mf3=new  Meeting_Frequency__c();
        mf3.Name='InPersonMeeting_Criteria1';
        mf3.Frequency__c='1:1,1:15,1:30,2:1,2:15,2:30';
        insert mf3;
        
        Meeting_Frequency__c mf4=new  Meeting_Frequency__c();
        mf4.Name='Interaction_Criteria1';
        mf4.Frequency__c='1:5,1:10,1:15,1:20,1:25,1:27,1:29,1:30';
        insert mf4;
        
        
        Meeting_Frequency__c mf5=new  Meeting_Frequency__c();
        mf5.Name='Interaction_Criteria2';
        mf5.Frequency__c='1:1,2:1';
        insert mf5;
        
          
        Meeting_Frequency__c mf6=new  Meeting_Frequency__c();
        mf6.Name='Portfolio_Review_Criteria3';
        mf6.Frequency__c='10,5,6,6,3';
        insert mf6;
        

        Meeting_Frequency__c mf7=new  Meeting_Frequency__c();
        mf7.Name='Portfolio_Review_Criteria1';
        mf7.Frequency__c='30,15,15,15,10,2,3';
        insert mf7;

        
        Meeting_Frequency__c mf8=new  Meeting_Frequency__c();
        mf8.Name='Portfolio_Review_Criteria2';
        mf8.Frequency__c='30,15,15,15,10,2,3';
        insert mf8;

        
        Meeting_Frequency__c mf9=new  Meeting_Frequency__c();
        mf9.Name='RH BH Criteria 3';
        mf9.Frequency__c='1:1,2:1';
        insert mf9;
        
      }
    
        
    Public static void InsertSysProperties()
    {
        List<Sys_Properties__c> lstSysProp = new List<Sys_Properties__c>();
        
        Sys_Properties__c s1=new Sys_Properties__c();
        s1.Name='Product Mismatch Notification To Email';
        s1.Value__c='abhishek_jyoti@persistent.co.in';
        lstSysProp.add(s1); 
        
        Sys_Properties__c s2=new Sys_Properties__c();
        s2.Name='Product Mismatch Notification Email';
        s2.Value__c='dildar_hussian@persistent.co.in';
        lstSysProp.add(s2); 
        
        Sys_Properties__c s3=new Sys_Properties__c();
        s3.Name='Profile Client Experience Office Id';
        s3.Value__c=[select id from Profile where Name = 'Client Experience Office (CXO)'].id;
        lstSysProp.add(s3); 
        
        Sys_Properties__c s4=new Sys_Properties__c();
        s4.Name='Profile Financial Advisor Id';
        s4.Value__c=[select id from Profile where Name = 'Financial Advisor'].id;
        lstSysProp.add(s4); 
        
        Sys_Properties__c s5=new Sys_Properties__c();
        s5.Name='ProductNoteOnProduct';
        s5.Value__c='ProductNote';
        lstSysProp.add(s5); 
        
        Sys_Properties__c s6=new Sys_Properties__c();
        s6.Name='DueDiligenceReportOnProduct';
        s6.Value__c='DueDiligence';
        lstSysProp.add(s6); 
        
        Sys_Properties__c s7=new Sys_Properties__c();
        s7.Name='ProfileSendNotification MilesTicket';
        s7.Value__c='   System Administrator';
        lstSysProp.add(s7); 
        
        Sys_Properties__c s8=new Sys_Properties__c();
        s8.Name='Document Verification';
        s8.Value__c='5';
        lstSysProp.add(s8); 
        
        Sys_Properties__c s10=new Sys_Properties__c();
        s10.Name='FianancialTransactionDomain';
        s10.Value__c='http://www.edelbusiness.in';
        lstSysProp.add(s10); 
        
        Sys_Properties__c s11=new Sys_Properties__c();
        s11.Name='FianancialTransactionUser';
        s11.Value__c='ProdUser';
        lstSysProp.add(s11); 
        
        Sys_Properties__c s12=new Sys_Properties__c();
        s12.Name='FinancialTransactionPass';
        s12.Value__c='prod1234';
        lstSysProp.add(s12); 
        
        Sys_Properties__c s13=new Sys_Properties__c();
        s13.Name='FinancialTransactionURL';
        s13.Value__c='https://wealth.edelweiss.in/pwmsfService/api/gw/FetchTransactionStatus';
        lstSysProp.add(s13); 
        
        Sys_Properties__c s14=new Sys_Properties__c();
        s14.Name='CommonProductTypes';
        s14.Value__c='Comtrack Only;Comtrade Only;Comtrade + Comtrack';
        lstSysProp.add(s14);
        
        Sys_Properties__c s15=new Sys_Properties__c();
        s15.Name='Profile Financial Advisor FOIG Id';
		List<Profile> lstProfile = [select id from Profile where Name = 'Financial Advisor'];
		if(lstProfile != null && lstProfile.size() > 0)
			s15.Value__c=lstProfile[0].id;
        lstSysProp.add(s15);
        
        Sys_Properties__c s16=new Sys_Properties__c();
        s16.Name='Profile Team Leader Advisory FOIG Id';
        lstProfile = [select id from Profile where Name = 'Team Leader Advisory FOIG'];
		if(lstProfile != null && lstProfile.size() > 0)
			s16.Value__c=lstProfile[0].id;
        lstSysProp.add(s16);
        
        Sys_Properties__c s17=new Sys_Properties__c();
        s17.Name='Profile Team Leader Advisory Id';
        lstProfile = [select id from Profile where Name = 'Team Leader Advisory'];
		if(lstProfile != null && lstProfile.size() > 0)
			s17.Value__c=lstProfile[0].id;
        lstSysProp.add(s17);
        
        Sys_Properties__c s18=new Sys_Properties__c();
        s18.Name='Profile Regional Head Id';
        lstProfile = [select id from Profile where Name = 'Regional Head'];
		if(lstProfile != null && lstProfile.size() > 0)
			s18.Value__c=lstProfile[0].id;
        lstSysProp.add(s18);
        
        Sys_Properties__c s19=new Sys_Properties__c();
        s19.Name='Profile CXO Zonal Head Id';
        lstProfile = [select id from Profile where Name = 'CXO Zonal Head'];
		if(lstProfile != null && lstProfile.size() > 0)
			s19.Value__c=lstProfile[0].id;
        lstSysProp.add(s19);
        
        Sys_Properties__c s20=new Sys_Properties__c();
        s20.Name='Profile CXO National Head Id';
        lstProfile = [select id from Profile where Name = 'CXO National Head'];
		if(lstProfile != null && lstProfile.size() > 0)
			s20.Value__c=lstProfile[0].id;
        lstSysProp.add(s20);
        
		Sys_Properties__c s21=new Sys_Properties__c();
        s21.Name='Integration Email Recipient User';
        s21.Value__c='PWM SalesForceUpdate';
        lstSysProp.add(s21);
        
        Sys_Properties__c s22=new Sys_Properties__c();
        s22.Name='Trading Inactive Time';
        s22.Value__c='180';
        lstSysProp.add(s22);
		
        upsert lstSysProp;
        
    }
      
    Public static void InsertSysPropertiesForTrend()
    {
        Sys_Properties__c s1=new Sys_Properties__c();
        s1.Name='FamilyTrendApiDomain';
        s1.Value__c='http://www.edelbusiness.in';
        insert s1; 
        
        
        Sys_Properties__c s2=new Sys_Properties__c();
        s2.Name='FamilyTrendApiPass';
        s2.Value__c='test1234';
        insert s2; 
        
        Sys_Properties__c s3=new Sys_Properties__c();
        s3.Name='FamilyTrendApiUrl';
        s3.Value__c='http://www.edelbusiness.in/PWMServiceSF/api/gw';
        insert s3; 
        
                
        Sys_Properties__c s4=new Sys_Properties__c();
        s4.Name='FamilyTrendApiUser';
        s4.Value__c='FamilyTrendApiUser';
        insert s4; 
        
       
        
    }
}