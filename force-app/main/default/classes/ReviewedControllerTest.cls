@isTest
public class ReviewedControllerTest {
 @isTest static void testMethodForException()//Checking Records for exception
    {
        Schema_Master__c schemaRec = new Schema_Master__c();
        schemaRec.AMC_Code__c = '12345';
        schemaRec.Purchase_Allowed__c = 'Y';
        insert schemaRec;
OrderEntrySchem__c setting= new OrderEntrySchem__c(Name='Euindefault', value__c='E331257');
             insert setting;
             
             OrderEntrySchem__c setting1= new OrderEntrySchem__c(Name='HardCuttOffTime', value__c='14.00');
             insert setting1;    
             
             OrderEntrySchem__c setting2= new OrderEntrySchem__c(Name='LiquidCuttoffTime', value__c='12.20');
             insert setting2;  
             
             OrderEntrySchem__c setting3= new OrderEntrySchem__c(Name='NonLiquidCuttoffTime < 2L', value__c='14.50');
             insert setting3; 
             
             
             OrderEntrySchem__c setting4= new OrderEntrySchem__c(Name='NonLiquidCuttoffTime > 2L', value__c='13.20');
             insert setting4; 
             
             
             OrderEntrySchem__c setting5= new OrderEntrySchem__c(Name='SoftCuttOffTime', value__c='13.30');
             insert setting5; 
        
        
        Account accRec = new Account();
        accRec.name = 'Test';
        accRec.RecordTypeId =Schema.SObjectType.account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        accRec.GWM_Online_Id__c = '12345';
        accRec.Pan_Number__c = 'DDMGG7447H';
        insert accRec;
        
                Account accRec1 = new Account();
        accRec1.name = 'Test1'; 
        accRec1.RecordTypeId =Schema.SObjectType.account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accRec1.ParentId = accRec.Id;
        insert accRec1; 
        
        Client_Account__c cAccRec = new Client_Account__c();
        cAccRec.Client__c = accRec1.Id;
        cAccRec.name = 'Test';
        insert cAccRec;
        
         Order_Entry__c orderCommitment = new Order_Entry__c();
        orderCommitment.Transaction_Type__c='Log Commitment';
        orderCommitment.scheme_plan_export__c ='Direct';
        orderCommitment.Product_Type_Order_Entry__c='PE / AIF';
        orderCommitment.Folio__c ='55555';
        orderCommitment.Transaction_Amount_Export__c='2000';
        orderCommitment.OrderEntryMF__c=false;
        orderCommitment.Status__c = 'Reviewed'; 
        orderCommitment.Transaction_Amount_Financial_Transaction__c= '200';
        orderCommitment.End_Date__c =Date.valueOf('2020-06-30');
        orderCommitment.End_Date__c =Date.valueOf('2020-06-22');
        orderCommitment.InternalPEID__c='1234';
      
        orderCommitment.RecordTypeId=Schema.SObjectType.Order_Entry__c.getRecordTypeInfosByName().get('PE_AIF_Log Drawdown').getRecordTypeId();
        orderCommitment.Client_Account_Display__c =cAccRec.Name;
        insert orderCommitment; 

        
             Order_Entry__c orderEntry = new Order_Entry__c();
           orderEntry.Transaction_Type__c='Purchase';
          orderEntry.scheme_plan_export__c ='Direct';
          orderEntry.Product_Type_Order_Entry__c='MF';
          orderEntry.isReviewed__c = true;
          orderEntry.Folio__c ='55555';
          orderEntry.UCC__c ='5255';
          orderEntry.Transaction_Amount_Export__c='2000';
          orderEntry.OrderEntryMF__c=false;
          orderEntry.Status__c = 'Reviewed'; 
          orderEntry.Transaction_Amount_Financial_Transaction__c= '200';
        insert orderEntry;
        Order_Entry__c orderEntry1 = new Order_Entry__c();
           orderEntry1.Transaction_Type__c='SIP';
          orderEntry1.scheme_plan_export__c ='Direct';
          orderEntry1.Product_Type_Order_Entry__c='MF';
          orderEntry1.isReviewed__c = false;
          orderEntry1.Folio__c ='55555';
          orderEntry1.Transaction_Amount_Export__c='2000';
          orderEntry1.OrderEntryMF__c=true;
          orderEntry1.Status__c = 'Pending For Review'; 
          orderEntry1.Transaction_Amount_Financial_Transaction__c= '200';
        insert orderEntry1;
         USer userRec = TestDataFactory.getUserProfile();
        userRec.Edelweiss_Employee_Id__c = '12345';
        update userRec;
         ReviewedController rev = new ReviewedController();
        
        ReviewedController.getOrderEntryObj(orderEntry.Id);
        ReviewedController.checkForProfile();
         ReviewedController.setIsReviewed(orderEntry.Id);
           ReviewedController.setIsReviewed(orderEntry1.Id);
         ReviewedController.setIsReviewed(orderCommitment.Id);
          ReviewedController.callForApi(orderEntry1.Id);
         ReviewedController.callForApi(orderEntry.Id);
         ReviewedController.callForApi(orderCommitment.Id);
    }
}