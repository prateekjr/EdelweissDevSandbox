@isTest(seeAlldata = true) 
public class AccountOpenCaseCreationtest {
    
    @isTest 
    public static void getClientInformationTest() { 
        Account accRec = new Account();
        accRec.name = 'Test';
        accRec.RecordTypeId =Schema.SObjectType.account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        accRec.GWM_Online_Id__c = '12345';
        accRec.Pan_Number__c = 'DDMGG7447H';
        insert accRec;
        Case c = new case(Family__c = 'Account case',Product_Type__c = 'Demat',Single_Joint__c = 'Single');
     insert c;
        list<case> c1 = new list<case>();
        Case c11 = new case(Family__c = 'contact case',Product_Type__c = 'Demat',Single_Joint__c = '');
        Case c12 = new case(Family__c = 'case',Product_Type__c = 'Demat',Single_Joint__c = 'Single',Number_of_Joint_Holders_Max_2__c = '1');
        c1.add(c11);
        c1.add(c12);
         insert c1;
        AccountOpenCaseCreation.getRecordTypeInfo();
        AccountOpenCaseCreation.SaveAllCases(c1);
    }
   
}