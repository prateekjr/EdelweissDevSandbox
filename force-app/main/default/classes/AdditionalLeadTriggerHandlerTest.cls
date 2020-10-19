@isTest
public class AdditionalLeadTriggerHandlerTest {

    @istest
    public static void verifyPANDuplicationTest(){
        
        TestClassUtils.InsertSysProperties();
        
        Account leadAcc1=TestClassUtils.createAccount();
        AccountTriggerhandler.stopUpdatefamily=false;
        leadAcc1.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Lead'); 
        leadAcc1.In_Person_Meeting_End_Date__c=Date.today();
        leadAcc1.Coverage__c='R2';
        insert leadAcc1;

        List<Case> lstCase = TestclassUtils.createTestCaseForFT();
        
        case c = lstCase[0];
        c.product_type__c ='Comtrade Only';
        c.POA__c=false;     
        c.AccountId= leadAcc1.id;
        
        insert c;
        
        Additional_Lead__c addLead = new Additional_Lead__c();
        addLead.PAN_Number__c = 'ABCDE0000F';
        addLead.Email__c = 'test@newtest.com';
        addLead.Mobile__c = '5544554455';
        addLead.Case__c = c.Id;
        insert addLead;
        
        Additional_Lead__c addLead2 = new Additional_Lead__c();
        addLead2.PAN_Number__c = 'ABCDE0000F';
        addLead2.Email__c = 'test@new.com';
        addLead2.Mobile__c = '5544554499';
        addLead2.Case__c = c.Id;
        
        try{
        	insert addLead2;    
        }catch(Exception e){
            
        }
        
        addLead2.PAN_Number__c = 'ABCDE0000G';
        insert addLead2;
        
        try{
            addLead2.PAN_Number__c = 'ABCDE0000F';
        	update addLead2;    
        }catch(Exception e){
            
        }
        
    }
    
}