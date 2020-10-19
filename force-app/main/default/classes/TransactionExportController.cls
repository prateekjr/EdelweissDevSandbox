public class TransactionExportController {
@AuraEnabled
   public static list <Order_Entry__c> fetchTransactionToExport(String transactionType){
      
      List<Order_Entry__c>  idExportedList = new List<Order_Entry__c>();
      List <Order_Entry__c> transactionaList = new List < Order_Entry__c > ();      
       if(transactionType.equals('Purchase/Redemption Direct')){    
           
           for(Order_Entry__c orderEntry: [SELECT scheme_code_export__c,PURCHASE_REDEEM__c,BUY_SELL_TYPE__c,UCC__c,dematPhysicalCNP__c,
                                           Transaction_Amount_Export__c ,Folio_Blank__c,Remarks__c,KYC_Flag_Default__c,
                                           Sub_Broker_Code_Blank__c,EUIN__c ,EUIN_Declaration_Default__c,MIN_redemption_flag_default__c,
                                           DPC_Flag_default__c,All_Units_blank__c,Redemption_Units_Blank__c,Sub_broker_ARN_Blank__c,isExported__c,scheme_plan_export__c
                                           FROM Order_Entry__c  
                                           WHERE
                                           (Transaction_Type__c = 'Purchase' OR Transaction_Type__c = 'Redemption') AND
                                           isReviewed__c = true AND status__c ='Reviewed' AND isExported__c = false AND scheme_plan_export__c='Direct']) { 
                                                                                          
                                               transactionaList.add(orderEntry);
            }
       } else if(transactionType.equals('Switch Direct')){
           
           for(Order_Entry__c orderEntry: [SELECT scheme_code_export__c,to_scheme_code_export__c,BUY_SELL_TYPE__c,UCC__c ,Status__c,
                                           dematPhysicalCNP__c,Transaction_Amount_Export__c,Redemption_Units_Blank__c,
                                           All_Units_blank__c,Folio_Blank__c,Remarks__c,KYC_Flag_Default__c,
                                           Sub_Broker_Code_Blank__c,EUIN__c,EUIN_Declaration_Default__c,
                                           Sub_broker_ARN_Blank__c,scheme_plan_export__c
                                           FROM Order_Entry__c 
                                           WHERE
                                           Transaction_Type__c = 'Switch' AND 
                                           isReviewed__c = true AND status__c ='Reviewed' AND isExported__c = false AND scheme_plan_export__c='Direct'
                                           ]) {
                                               
                                               transactionaList.add(orderEntry);
                                               //To_Scheme__c , From_Scheme__c
                                           }
       } else if(transactionType.equals('Purchase/Redemption Normal')){ 
           
           for(Order_Entry__c orderEntry: [SELECT scheme_code_export__c,PURCHASE_REDEEM__c,BUY_SELL_TYPE__c,UCC__c,dematPhysicalCNP__c,
                                           Transaction_Amount_Export__c ,Folio_Blank__c,Remarks__c,KYC_Flag_Default__c,
                                           Sub_Broker_Code_Blank__c,EUIN__c ,EUIN_Declaration_Default__c,MIN_redemption_flag_default__c,
                                           DPC_Flag_default__c,All_Units_blank__c,Redemption_Units_Blank__c,Sub_broker_ARN_Blank__c,isExported__c,scheme_plan_export__c
                                           FROM Order_Entry__c  
                                           WHERE
                                           (Transaction_Type__c = 'Purchase' OR Transaction_Type__c = 'Redemption') AND
                                           isReviewed__c = true AND status__c ='Reviewed' AND isExported__c = false AND scheme_plan_export__c='Normal'
                                           ]) {                                                
                                               transactionaList.add(orderEntry);
            }
       } else if(transactionType.equals('Switch Normal')){
           
           for(Order_Entry__c orderEntry: [SELECT scheme_code_export__c,to_scheme_code_export__c,BUY_SELL_TYPE__c,UCC__c ,Status__c,
                                           dematPhysicalCNP__c,Transaction_Amount_Export__c,Redemption_Units_Blank__c,
                                           All_Units_blank__c,Folio_Blank__c,Remarks__c,KYC_Flag_Default__c,
                                           Sub_Broker_Code_Blank__c,EUIN__c,EUIN_Declaration_Default__c,
                                           Sub_broker_ARN_Blank__c,scheme_plan_export__c
                                           FROM Order_Entry__c 
                                           WHERE
                                           Transaction_Type__c = 'Switch' AND 
                                           isReviewed__c = true AND status__c ='Reviewed' AND isExported__c = false AND scheme_plan_export__c='Normal'
                                           ]) {
                                               
                                               transactionaList.add(orderEntry);
                                           }
           //From_Scheme__c,To_Scheme__c
       }
            
	   	
       for(Order_Entry__c oeExport : transactionaList){
           oeExport.isExported__c = true;
           oeExport.Status__c ='Completed';   
           idExportedList.add(oeExport);
       }
       
       update idExportedList;
        return transactionaList;
   }
}