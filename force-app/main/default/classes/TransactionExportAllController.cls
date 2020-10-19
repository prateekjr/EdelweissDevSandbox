public class TransactionExportAllController {
    
    @AuraEnabled
    public static list <Order_Entry__c> fetchTransactionToExport(String transactionType){
        
        List<Order_Entry__c>  idExportedList = new List<Order_Entry__c>();
        List <Order_Entry__c> transactionaList = new List < Order_Entry__c > ();     
        
        System.debug('Inside fetchTransactionToExport');
        if(transactionType.equals('Purchase/Redemption Direct')){    
            
            List<Order_Entry__c> orderEntryList = TransactionExportAllController.getOrderList();
            System.debug('orderEntryList' + orderEntryList);
            for(Order_Entry__c orderObj : orderEntryList){
                if((orderObj.Transaction_Type__c == 'Purchase' || orderObj.Transaction_Type__c == 'Redemption') && orderObj.scheme_plan_export__c =='Direct') {
                    transactionaList.add(orderObj);
                }
            }

            System.debug('transactionaList ********  '+ transactionaList);
            TransactionExportAllController.updateTransaction(transactionaList);
            return transactionaList;
            
        } else if(transactionType.equals('Switch Direct')){
            
            System.debug('Inside Switch Direct');

            List<Order_Entry__c> orderEntryList = TransactionExportAllController.getOrderList();
            System.debug('orderEntryList 1' + orderEntryList);
            
            for(Order_Entry__c orderObj : orderEntryList){
                if((orderObj.Transaction_Type__c == 'Switch') && orderObj.scheme_plan_export__c == 'Direct') {
                    transactionaList.add(orderObj);
                }
            }
            System.debug('transactionaList1 ********  '+ transactionaList);
            
            TransactionExportAllController.updateTransaction(transactionaList);
            return transactionaList;
            
            
        } else if(transactionType.equals('Purchase/Redemption Normal')){ 
            
            System.debug('Inside Purchase/Redemption Normal');            
            List<Order_Entry__c> orderEntryList = TransactionExportAllController.getOrderList();
            System.debug('orderEntryList 2' + orderEntryList);
            
            for(Order_Entry__c orderObj : orderEntryList){
                if((orderObj.Transaction_Type__c == 'Purchase' || orderObj.Transaction_Type__c == 'Redemption') && orderObj.scheme_plan_export__c =='Normal') {
                    transactionaList.add(orderObj);
                }
            }
            System.debug('transactionaList ******** 2 '+ transactionaList);
            
            TransactionExportAllController.updateTransaction(transactionaList);
            return transactionaList;
            
            
        } else if(transactionType.equals('Switch Normal')){
            System.debug('Inside Switch Normal');       
            List<Order_Entry__c> orderEntryList = TransactionExportAllController.getOrderList();
            System.debug('orderEntryList3' + orderEntryList);
            
            for(Order_Entry__c orderObj : orderEntryList){
                if((orderObj.Transaction_Type__c == 'Switch') && orderObj.scheme_plan_export__c =='Normal') {
                    transactionaList.add(orderObj);
                }
            }
            System.debug('transactionaList 3********  '+ transactionaList);
            
            TransactionExportAllController.updateTransaction(transactionaList);
            return transactionaList;
        }
        return null;
    }   
    
    public static List <Order_Entry__c> getOrderList(){
        List <Order_Entry__c> listOfOrderEntry = [SELECT Transaction_Type__c ,Product_Type_Order_Entry__c, to_scheme_code_export__c,scheme_code_export__c,PURCHASE_REDEEM__c,BUY_SELL_TYPE__c,UCC__c,dematPhysicalCNP__c,Status__c,
                                                  Transaction_Amount_Export__c ,Folio_Blank__c,Remarks__c,KYC_Flag_Default__c,
                                                  Sub_Broker_Code_Blank__c,EUIN__c ,EUIN_Declaration_Default__c,MIN_redemption_flag_default__c,
                                                  DPC_Flag_default__c,All_Units_blank__c,Redemption_Units_Blank__c,Sub_broker_ARN_Blank__c,isExported__c,scheme_plan_export__c, OrderEntryMF__c
                                                  FROM Order_Entry__c  
                                                  WHERE isReviewed__c = true AND status__c ='Reviewed' AND isExported__c = false AND Product_Type_Order_Entry__c='MF' And OrderEntryMF__c=false];
        return listOfOrderEntry;
    }
    
    @AuraEnabled
    public static void updateTransaction(List <Order_Entry__c> orderEntryList){
        List <Order_Entry__c> listToBeUpdated = new List <Order_Entry__c>();
        for(Order_Entry__c oeExport : orderEntryList){
            oeExport.isExported__c = true;
            oeExport.Status__c ='Completed';   
            listToBeUpdated.add(oeExport);
        }
        
        if(listToBeUpdated!=null && !listToBeUpdated.isEmpty()) {
            update listToBeUpdated;
        }
        
    }       
}