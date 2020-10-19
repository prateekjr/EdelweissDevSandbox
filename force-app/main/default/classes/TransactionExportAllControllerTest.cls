@isTest 
public class TransactionExportAllControllerTest {
    @isTest 
    public static void testExportAllForPurchaseDirect() {   
        
        List<Order_Entry__c> odList = TestDataFactory.createOrderEntryExportAll(); 
        List <Order_Entry__c> listOfOrderEntry=TransactionExportAllController.getOrderList();
        List <Order_Entry__c> listOfOrderEntryResult=new  List <Order_Entry__c>();
        
        listOfOrderEntry[0].Transaction_Type__c ='Purchase';
        listOfOrderEntry[0].scheme_plan_export__c ='Direct';
        update listOfOrderEntry;
        listOfOrderEntryResult =TransactionExportAllController.fetchTransactionToExport('Purchase/Redemption Direct');
        System.assertEquals('Completed', listOfOrderEntryResult[0].Status__c);
        System.assertEquals(true, listOfOrderEntryResult[0].isExported__c);
    }
 
    @isTest 
    public static void testExportAllForSwitchDirect() { 
        List<Order_Entry__c> odList = TestDataFactory.createOrderEntryExportAll(); 
        List <Order_Entry__c> listOfOrderEntry=TransactionExportAllController.getOrderList();
        List <Order_Entry__c> listOfOrderEntryResult=new  List <Order_Entry__c>();
        
        listOfOrderEntry[0].Transaction_Type__c ='Switch';
        listOfOrderEntry[0].scheme_plan_export__c ='Direct';
        update listOfOrderEntry;
        listOfOrderEntryResult =TransactionExportAllController.fetchTransactionToExport('Switch Direct');  
        System.assertEquals('Completed', listOfOrderEntryResult[0].Status__c);
        System.assertEquals(true, listOfOrderEntryResult[0].isExported__c);
        
    }
    
    @isTest 
    public static void testExportAllForPurchaseNormal() { 
        List<Order_Entry__c> odList = TestDataFactory.createOrderEntryExportAll(); 
        List <Order_Entry__c> listOfOrderEntry=TransactionExportAllController.getOrderList();
        List <Order_Entry__c> listOfOrderEntryResult=new  List <Order_Entry__c>();
        
        listOfOrderEntry[0].Transaction_Type__c ='Purchase';
        listOfOrderEntry[0].scheme_plan_export__c ='Normal';
        update listOfOrderEntry;
        listOfOrderEntryResult = TransactionExportAllController.fetchTransactionToExport('Purchase/Redemption Normal');  
        System.assertEquals('Completed', listOfOrderEntryResult[0].Status__c);
        System.assertEquals(true, listOfOrderEntryResult[0].isExported__c);
        
    }
    
    @isTest 
    public static void testExportAllForSwitchNormal() { 
        List<Order_Entry__c> odList = TestDataFactory.createOrderEntryExportAll(); 
        List <Order_Entry__c> listOfOrderEntry=TransactionExportAllController.getOrderList();
        List <Order_Entry__c> listOfOrderEntryResult=new  List <Order_Entry__c>();
        
        listOfOrderEntry[0].Transaction_Type__c ='Switch';
        listOfOrderEntry[0].scheme_plan_export__c ='Normal';
        update listOfOrderEntry;
        listOfOrderEntryResult =  TransactionExportAllController.fetchTransactionToExport('Switch Normal');   
        System.assertEquals('Completed', listOfOrderEntryResult[0].Status__c);
        System.assertEquals(true, listOfOrderEntryResult[0].isExported__c);
        
    }
     
}