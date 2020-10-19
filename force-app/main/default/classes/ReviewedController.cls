public class ReviewedController {
    public string xmlstring { get; set;}
    public static Map<String, String> mapOfFields = new Map<String, String>();
    public static Id orderId;
    public static Order_ENTRY__c orderEntryRec = new Order_Entry__c();
    public static String orderStatus;
    public static String orderIdField;
    public static String errorDesc;
    public static String pmsIdField;
    public static String privateEquityIdField;
    
    @AuraEnabled
    public static Order_Entry__c getOrderEntryObj(Id recordId){
        Order_Entry__c orderEntry = [Select Id, From_Scheme__c,Payment_Mode_PMS_API__c,To_Scheme__c,MFIncludeCustodyAcctNum__c, MFFrequency_API__c,Payment_Mode__c, Scheme__c,isReviewed__c,Status__c,Product_Type_Order_Entry__c,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount_Financial_Transaction__c,Currency__c,Nav__c,ProductCode__c,Client_Account_gwm_Id__c, OrderEntryMF__c,POA_Non_POA__c , Client_Account_Remitter_Id_API__c , Communication_Mode_API__c , MF_Feed_File_Gen_Reg_API__c , Folio__c , holdingModeMFAPI__c , Payment_Mode_MF_API__c , TranRouteModeAPI__c , Transaction_Type_MF_API__c , transmissionEntityMFAPI__c , transmissionEntTypeMFAPI__c , Value_Date__c ,RedeemAllAPI__c , TransactionModeMFAPI__c, TransactionUnitMFAPI__c, Transaction_Unit__c,PE_payment_mode_API__c,Transaction_Type_PE_API__c,custodyACNoMFAPI__c , reguRegNumAPI__c,Value_Date_API__c , MFDividentOptionAPI__c , Start_Date_API__c , End_Date_API__c, No_of_units__c , Cut_Off_Price_IPO_API__c , Funding_ROI__c , Order_Date__c  , Payment_Mode_IPO_API__c , IPOsettleFundsFlgAPI__c ,Price_new__c ,Order_Date_API__c, IPO_Application_Number__c , IPO_Code__c ,Start_Date_Day_API__c, custodyAcctIdIPOAPI__c , of_Facevalue__c , Request_XML__c, Response_XML__c ,Random_Number_Order_Id__c  from Order_Entry__c where Id =: recordId  LIMIT 1];
        return orderEntry;
    }
    
    @AuraEnabled
    public static Integer checkForProfile(){
        Integer isValid = 1;
        string pName ;
        String userId = UserInfo.getUserId();
        List<user> userList = [SELECT ProfileId, Profile.Name FROM User WHERE Id =:userId];
        if(userList != null && userList.size() > 0){
            User currentUser = userList[0];
            pName =  currentUser.Profile.Name;
            
            if(pName .containsIgnoreCase('Client Experience Office (CXO)')){
                isValid  = -1;
            }
        }   
        
        return isValid;
    }
    
    @AuraEnabled
    public static Integer setIsReviewed(Id recordId){
        Integer flag;
        List<Schema_Master__c> toSchemeList;
        List<Order_Entry__c> orderEntry = [Select Id, From_Scheme__c,To_Scheme__c, MFIncludeCustodyAcctNum__c, Scheme__c,isReviewed__c,MFFrequency_API__c,Start_Date_Day_API__c,Status__c,Product_Type_Order_Entry__c,RecordTypeId, Transaction_Type__c,remarks__c,Transaction_Amount_Financial_Transaction__c,Currency__c,Nav__c , Client_Account_gwm_Id__c, ProductCode__c,POA_Non_POA__c ,Client_Account_Remitter_Id_API__c , Communication_Mode_API__c , MF_Feed_File_Gen_Reg_API__c , Folio__c , holdingModeMFAPI__c , Payment_Mode_MF_API__c , TranRouteModeAPI__c , Transaction_Type_MF_API__c , transmissionEntityMFAPI__c , transmissionEntTypeMFAPI__c , Value_Date__c , RedeemAllAPI__c, TransactionModeMFAPI__c, TransactionUnitMFAPI__c,Transaction_Unit__c,custodyACNoMFAPI__c , reguRegNumAPI__c ,Value_Date_API__c , MFDividentOptionAPI__c , Start_Date_API__c , End_Date_API__c, No_of_units__c , Cut_Off_Price_IPO_API__c , Funding_ROI__c , Order_Date__c  , Payment_Mode_IPO_API__c , IPOsettleFundsFlgAPI__c ,Price_new__c ,Order_Date_API__c, IPO_Application_Number__c , IPO_Code__c , custodyAcctIdIPOAPI__c , of_Facevalue__c, Request_XML__c, Response_XML__c,Random_Number_Order_Id__c from Order_Entry__c where Id =: recordId AND isReviewed__c = false LIMIT 1];
        
        if(orderEntry.size() == 0){
            flag = 0;
        } else if(! orderEntry[0].Status__c.equals('Pending For Review')){
            flag = -1;
        } else { 
            orderEntry[0].isReviewed__c = true;
            orderEntry[0].Status__c ='Reviewed';
            
            
            /*Logic for liquid cutoff Time Start*/
            DateTime now = DateTime.now();
            Double currentTime = Double.valueOf(now.hour()+'.'+now.minute());
            //Double currentTime = 13.00;
            OrderEntrySchem__c code = OrderEntrySchem__c.getInstance('LiquidCuttoffTime');
            Double LiquidCuttoffTime = decimal.valueOf(code.value__c);
            
            OrderEntrySchem__c codeLess2L = OrderEntrySchem__c.getInstance('NonLiquidCuttoffTime < 2L');
            Double nonLiquidctOffLess2L = decimal.valueOf(codeLess2L.value__c);
            
            OrderEntrySchem__c codeGreater2L = OrderEntrySchem__c.getInstance('NonLiquidCuttoffTime > 2L');
            Double nonLiquidctOffGret2L = decimal.valueOf(codeGreater2L.value__c);
            String ScheNameTemp;
            List<Schema_Master__c> iSINTemp;
            List<Schema_Master__c> iSINTo;
            if(orderEntry[0].Transaction_Type__c == 'Switch'){
                //ScheNameTemp = orderEntry[0].From_Scheme__c;
                /* code is for te get ISIN of selected From scheme and To Scheme */
                iSINTemp = [SELECT ISIN__c FROM Schema_Master__c WHERE scheme_name__c =:orderEntry[0].From_Scheme__c];
                iSINTo = [SELECT ISIN__c FROM Schema_Master__c WHERE scheme_name__c =:orderEntry[0].To_Scheme__c];
                /*
                System.debug('Inside Switch == orderEntry[0].From_Scheme__c== '+orderEntry[0].From_Scheme__c);
                System.debug('Inside Switch == orderEntry[0].To_Scheme__c== '+orderEntry[0].To_Scheme__c);
                System.debug('Inside Switch == iSINTemp == '+iSINTemp);
                System.debug('Inside Switch == iSINTo == '+iSINTo);*/
                /* code  is deed to get to scheme code start */
                /*toSchemeList = [SELECT Scheme_code__c , Switch_FLAG__c , Purchase_Transaction_mode__c FROM Schema_Master__c 
                                where scheme_name__c =: orderEntry[0].To_Scheme__c  AND Switch_FLAG__c = 'Y'AND Purchase_Transaction_mode__c IN ('DP','P')] ;*/
                toSchemeList = [SELECT Scheme_code__c , Switch_FLAG__c , Purchase_Transaction_mode__c FROM Schema_Master__c 
                                where ISIN__c =: iSINTo[0].ISIN__c  AND Switch_FLAG__c = 'Y'AND Purchase_Transaction_mode__c IN ('DP','P')] ;
                
                /* code  is deed to get to scheme code ends */
                
            } else {
                //ScheNameTemp = orderEntry[0].Scheme__c;                 
                iSINTemp = [SELECT ISIN__c FROM Schema_Master__c WHERE scheme_name__c =:orderEntry[0].Scheme__c];
                //System.debug('Inside Switch else == iSINTemp== '+iSINTemp);
            }
            List<Schema_Master__c> schemeMasterList = new  List<Schema_Master__c>();
            if(orderEntry[0].Transaction_Type__c == 'Purchase'){
                //scheme_name__c =: ScheNameTemp for all 3
                schemeMasterList = [SELECT Scheme_code__c,Purchase_Allowed__c,Purchase_Transaction_mode__c,Redemption_Transaction_Mode__c,Redemption_Allowed__c,Switch_FLAG__c,scheme_Type__c,Scheme_Plan__c   FROM Schema_Master__c 
                                    where ISIN__c =: iSINTemp[0].ISIN__c AND Purchase_Allowed__c = 'Y' AND Purchase_Transaction_mode__c IN ('DP','P')                                    
                                   ];
            }else if (orderEntry[0].Transaction_Type__c == 'Redemption'){
                schemeMasterList = [SELECT Scheme_code__c,Purchase_Allowed__c,Purchase_Transaction_mode__c,Redemption_Transaction_Mode__c,Redemption_Allowed__c,Switch_FLAG__c,scheme_Type__c,Scheme_Plan__c   FROM Schema_Master__c 
                                    where ISIN__c =: iSINTemp[0].ISIN__c AND Redemption_Allowed__c = 'Y' AND Redemption_Transaction_Mode__c IN ('DP','P')                                    
                                   ];
            }else if(orderEntry[0].Transaction_Type__c == 'Switch'){
                schemeMasterList = [SELECT Scheme_code__c,Purchase_Allowed__c,Purchase_Transaction_mode__c, Redemption_Transaction_Mode__c,Redemption_Allowed__c,Switch_FLAG__c,scheme_Type__c,Scheme_Plan__c   FROM Schema_Master__c 
                                    where ISIN__c =: iSINTemp[0].ISIN__c  AND Switch_FLAG__c = 'Y' AND Redemption_Transaction_Mode__c IN ('DP','P')                                            
                                   ];
            }
            /*System.debug('iSINTemp[0].ISIN__c == '+iSINTemp[0].ISIN__c);
            System.debug('schemeMasterList -- '+schemeMasterList);
            
            */
            for(Schema_Master__c scMaster : schemeMasterList){
                
                if(scMaster.scheme_Type__c.equals('LIQUID')){
                    
                    //Purchase
                    if(scMaster.Purchase_Allowed__c == 'Y' &&  orderEntry[0].Transaction_Type__c =='Purchase'){
                        
                        if((currentTime > LiquidCuttoffTime && currentTime < 15.0) ){
                            
                            if(scMaster.Scheme_code__c.contains('-L0')){
                                
                                
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L0', '');
                                orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            }else {
                                
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                                orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            }
                            
                        }else{
                            
                            if(scMaster.Scheme_code__c.contains('-L0')){
                                
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                                orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            }else {
                                
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L0';
                                orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            }
                        }
                        
                    } else if(scMaster.Redemption_Allowed__c =='Y' &&  orderEntry[0].Transaction_Type__c == 'Redemption' ){
                        if((currentTime > LiquidCuttoffTime && currentTime < 15.0)){
                            if(scMaster.Scheme_code__c.contains('-L0'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L0', '');                                
                            else 
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            /*else {
orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
}*/
                        }else{
                            if(scMaster.Scheme_code__c.contains('-L0'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L0', ''); //scMaster.Scheme_code__c;                                
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            /*else {
orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L0';
orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
}*/
                        } 
                        
                    } else if(scMaster.Switch_FLAG__c == 'Y' && orderEntry[0].Transaction_Type__c=='Switch'){
                        if((currentTime > LiquidCuttoffTime && currentTime < 15.0) ){
                            if(scMaster.Scheme_code__c.contains('-L0') )
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L0', '');
                            else 
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            if(toSchemeList[0].Scheme_code__c.contains('-L0') )
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L0', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            
                            /*else {
orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
}*/
                            
                        }else{
                            if(scMaster.Scheme_code__c.contains('-L0'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L0', '');
                            else 
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            if(toSchemeList[0].Scheme_code__c.contains('-L0'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L0', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            /*else {
orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L0';
orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
}*/
                            
                        }
                        
                    }
                    //Nav Logic
                    if((currentTime > 9.0 && currentTime < LiquidCuttoffTime) ){	
                        orderEntry[0].Nav__c  = 'Nav will be applicable of T-1';
                    }else{
                        orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                    } 
                    
                    
                } else if(! scMaster.scheme_Type__c.contains('LIQUID')){
                    
                    if(scMaster.Purchase_Allowed__c == 'Y' && orderEntry[0].Transaction_Type__c =='Purchase' ){
                        
                        if((currentTime > 9.0 && currentTime < nonLiquidctOffGret2L)&& (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) >= 200000) && scMaster.Scheme_code__c.contains('-L1') ){	
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;//+'-L1';
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        }else if((currentTime > 9.0 && currentTime < nonLiquidctOffLess2L)&& (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000)  && (! scMaster.Scheme_code__c.contains('-L1'))){
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        } else if((currentTime > nonLiquidctOffGret2L)&& (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) > 200000) && scMaster.Scheme_code__c.contains('-L1')  ){	
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;//+'-L1';
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        } else if((currentTime > nonLiquidctOffLess2L)&& (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000) && (! scMaster.Scheme_code__c.contains('-L1')) ){
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        } else if(currentTime < 9.0 && (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) >= 200000) && scMaster.Scheme_code__c.contains('-L1') ){	
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;//+'-L1';
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        } else if(currentTime < 9.0 && (Decimal.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000)  && (! scMaster.Scheme_code__c.contains('-L1'))){
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        }
                        
                    } else if(scMaster.Redemption_Allowed__c =='Y' &&  orderEntry[0].Transaction_Type__c =='Redemption' ){
                        
                        if((currentTime > 9.0 && currentTime < nonLiquidctOffGret2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) > 200000)  ){	
                            
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                            
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L1';
                        }else if((currentTime > 9.0 && currentTime < nonLiquidctOffLess2L)){ //&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000)  ){
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';                            
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                        } else if((currentTime > nonLiquidctOffGret2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) > 200000)  ){	
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            // orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L1';
                        }else if((currentTime > nonLiquidctOffLess2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000) ){
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            // orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                        } else if(currentTime < 9.0){	
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        } 
                        
                    } else if(scMaster.Switch_FLAG__c == 'Y' && orderEntry[0].Transaction_Type__c =='Switch'){
                        if((currentTime > 9.0 && currentTime < nonLiquidctOffGret2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) > 200000)  ){	
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            if(toSchemeList[0].Scheme_code__c.contains('-L1'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L1';
                        }else if((currentTime > 9.0 && currentTime < nonLiquidctOffLess2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000)  ){
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            if(toSchemeList[0].Scheme_code__c.contains('-L1'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                        } else if((currentTime > nonLiquidctOffGret2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) > 200000)  ){	
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            if(toSchemeList[0].Scheme_code__c.contains('-L1'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c+'-L1';
                        }else if((currentTime > nonLiquidctOffLess2L)){//&& (Integer.valueof(orderEntry[0].Transaction_Amount_Financial_Transaction__c) < 200000) ){
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            if(toSchemeList[0].Scheme_code__c.contains('-L1'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                        } else if(currentTime < 9.0){	
                            orderEntry[0].Nav__c  = 'Nav will be applicable of T+1';
                            //orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            if(scMaster.Scheme_code__c.contains('-L1'))
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].scheme_code_export__c = scMaster.Scheme_code__c;
                            
                            
                            //orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            if(toSchemeList[0].Scheme_code__c.contains('-L1'))
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c.replace('-L1', '');
                            else
                                orderEntry[0].to_scheme_code_export__c = toSchemeList[0].Scheme_code__c;
                            
                            orderEntry[0].scheme_plan_export__c =  scMaster.Scheme_Plan__c;
                        }
                        
                    }
                    
                }     
                
            }
            
            /*Ends*/
            
            flag = 1;
            
            
            update orderEntry;
            
        }
        /* if(orderEntry[0].Product_Type_Order_Entry__c == 'Bond'){

XmlProcessing xpObj = new XmlProcessing();
Order_Entry__c orderObj = orderEntry[0];
XmlProcessing.generateRequestXml1(orderObj);
} */
        
        
        return flag;  
    }
    
    
    @AuraEnabled
    public static String callForApi(Id recordId){
        System.debug('Call For API Time'+ System.now());
        Order_Entry__c orderObj = [Select Id, isReviewed__c ,Transaction_Amount_Financial_Transaction__c,Payment_Mode_PMS_API__c,Product_Type_Order_Entry__c ,Payment_Mode__c, 
                                   Quantity__c , Order_Status__c , Face_Value__c , Rate__c , Client_Account_Display__c , RecordTypeId, Transaction_Type__c,Status__c,remarks__c,
                                   Transaction_Amount__c,Currency__c , ProductCode__c, Client_Account_gwm_Id__c,Client_Account_Remitter_Id_API__c, Communication_Mode_API__c, 
                                   Indicative_Market_Price_API__c ,Market_Type_API__c, Counterparty_investment_API__c,Transaction_Type_API__c, PMS_Folio_API__c,POA_Non_POA__c ,
                                   MF_Feed_File_Gen_Reg_API__c , Folio__c , holdingModeMFAPI__c ,MFIncludeCustodyAcctNum__c,  Payment_Mode_MF_API__c , TranRouteModeAPI__c , Transaction_Type_MF_API__c ,
                                   transmissionEntityMFAPI__c , transmissionEntTypeMFAPI__c , Value_Date__c,MFFrequency_API__c,Start_Date_Day_API__c, RedeemAllAPI__c, TransactionModeMFAPI__c, TransactionUnitMFAPI__c,
                                   Transaction_Unit__c, ToProduct_Code__c, To_Folio__c ,PE_payment_mode_API__c,Transaction_Type_PE_API__c,custodyACNoMFAPI__c , reguRegNumAPI__c,Commitment_Amount__c , Value_Date_API__c,PE_ID__c ,CreationPEID__c, MFDividentOptionAPI__c , Start_Date_API__c , End_Date_API__c, No_of_units__c , Cut_Off_Price_IPO_API__c , Funding_ROI__c , Order_Date__c  , Payment_Mode_IPO_API__c , IPOsettleFundsFlgAPI__c ,Price_new__c , Order_Date_API__c , IPO_Application_Number__c , IPO_Code__c , custodyAcctIdIPOAPI__c , of_Facevalue__c , Request_XML__c, Response_XML__c,Random_Number_Order_Id__c from Order_Entry__c where Id =: recordId  LIMIT 1];
        Boolean isReviewed =  orderObj.isReviewed__c;
        if(isReviewed){
            return 'FAILURE - Already Reviewed'; 
        }else if(orderObj.Status__c.equals('Preview Mode')){
            return 'FAILURE - Record is not submitted for review';
        }else if(orderObj.Status__c.equals('Pending For Review')){
            String response = generateRequestXml1(orderObj);
            
            return response;
        }
        return '';
    }
    public static String generateRequestXml1(Order_Entry__C orderEntryRec){
        
        String productTypeSearch;
        if(orderEntryRec.Product_Type_Order_Entry__c.equals('Bond') || orderEntryRec.Product_Type_Order_Entry__c.equals('SP') || orderEntryRec.Product_Type_Order_Entry__c.equals('CD') || orderEntryRec.Product_Type_Order_Entry__c.equals('CP') || orderEntryRec.Product_Type_Order_Entry__c.equals('FD') || orderEntryRec.Product_Type_Order_Entry__c.equals('ICD')){
            
            productTypeSearch = 'commonRecord';
        }else {
            
            productTypeSearch = '%'+orderEntryRec.Product_Type_Order_Entry__c+'%';            
        }
        System.debug('productTypeSearch === '+productTypeSearch);
        List<OrderEntryXML_New__c> fieldandApiList = [SELECT id , FieldName__c , value__c FROM OrderEntryXML_New__c where RecordTypeName__c like :productTypeSearch];
        
        for(OrderEntryXML_New__c orderEntry : fieldandApiList){
            mapOfFields.put(orderEntry.FieldName__c , orderEntry.value__c);
        }
        
        orderId = orderEntryRec.id;
        String response = generateRequestXml(orderEntryRec);
        
        return response;
    }
    
    public static String generateRequestXml(Order_Entry__c orderEntryRec1){ 
        
        //orderEntryRec.id = orderEntryRec1.id;
        
        DOM.Document doc = new DOM.Document();
        String xml = getXML(EdelweissConstants.OrderEntryRecordTypeMap.get(orderEntryRec1.RecordTypeId),orderEntryRec1.Transaction_Type__c,orderEntryRec1);
        if(xml != null){
            doc.load(xml);            
            dom.XmlNode orderEntryAddRequest = doc.getRootElement();    
            if(orderEntryRec1.Product_Type_Order_Entry__c == 'PMS'){
                
                parseXmlPMS(orderEntryAddRequest,orderEntryRec1);
            }else{
                parseXml(orderEntryAddRequest,orderEntryRec1);
            }
            
            String response = processXmlResponse(doc.toXmlString(),orderEntryRec1.Id);
            System.debug('response==== '+response);
            return response;
            //Database.update(orderEntryRec);
        } else{
            
        }
        return '';
    }
    /*
* This method is for fetching xml from custom metadata on created master lable.
*/
    
    public static String getXML(String RecordType, String TransactionType,Order_Entry__c orderEntryRec){    
        System.debug('inside get Xml = '+RecordType);
        //String masterLable = RecordType+TransactionType+'_Request';
        String masterLable;
        if(orderEntryRec.Product_Type_Order_Entry__c == 'PMS'){
            
            masterLable = RecordType +'_'+ orderEntryRec.Payment_Mode__c;
            
        }else if(orderEntryRec.Product_Type_Order_Entry__c == 'Bond' || orderEntryRec.Product_Type_Order_Entry__c == 'SP' || orderEntryRec.Product_Type_Order_Entry__c == 'CP' ||orderEntryRec.Product_Type_Order_Entry__c == 'CD' || orderEntryRec.Product_Type_Order_Entry__c == 'FD' || orderEntryRec.Product_Type_Order_Entry__c == 'ICD'){
            masterLable = RecordType +'_'+ orderEntryRec.Payment_Mode__c; 
            
        }
        // Added for MF Order Entry
        else if(orderEntryRec.Product_Type_Order_Entry__c == 'MF'){
            String paymentMode = orderEntryRec.POA_Non_POA__c;
            if(paymentMode != null){
                if(paymentMode.equals('POA – Online') || paymentMode.equals('POA – Offline')){
                    masterLable = RecordType +'_'+ 'POA_Request';
                }else if(paymentMode.equals('Non POA – Online') || paymentMode.equals('Non POA – Offline')){
                    masterLable = RecordType +'_'+ 'NONPOA_Request';
                }
            }
        }else if(orderEntryRec.Product_Type_Order_Entry__c == 'PE / AIF'){
            System.debug('Inside PE/ AIF === RecordType == '+RecordType);// PE / AIF_Withdrawal_POA Bank
            if(orderEntryRec.Transaction_Type__c=='Log Commitment'){
                masterLable = RecordType; 
            }else if(orderEntryRec.Transaction_Type__c=='Log Drawdown'){                
                masterLable ='PE_AIF_DD_'+ orderEntryRec.Payment_Mode__c; 
            }else if(orderEntryRec.Transaction_Type__c=='Withdrawal'){                
                masterLable ='PE_AIF_WD_'+ orderEntryRec.Payment_Mode__c; 
            } else if(orderEntryRec.Transaction_Type__c=='Close Out'){
                //masterLable = RecordType +'_'+ orderEntryRec.Payment_Mode__c; 
                masterLable ='PE_AIF_CO_'+ orderEntryRec.Payment_Mode__c; 
            }
        }else if(orderEntryRec.Product_Type_Order_Entry__c == 'IPO'){
          masterLable =  RecordType +'_'+ orderEntryRec.Payment_Mode__c;
        }else{ 
            masterLable    = RecordType+'_Request';
        }
        System.debug('masterLable==== '+masterLable);
        
        List<OrderEntry_XML__mdt> xmlList = [Select Value__c from OrderEntry_XML__mdt where MasterLabel=:masterLable];
        
        return xmlList[0].value__c;
    }
    /*
* This method is for parsing the case data in xml.
*/
    
    private static void parseXml(DOM.XMLNode node, Order_Entry__c orderEntryRec) { 
        if(mapOfFields.get(node.getName()) != null){
            
            String fieldName = mapOfFields.get(node.getName());  
            System.debug('fieldName=== '+fieldName);
            if(fieldName != null){
                String fieldvalue = String.valueOf(orderEntryRec.get(fieldName));            
                if(fieldvalue != null){
                    System.debug('fieldvalue=== '+fieldvalue);
                    node.addTextNode(fieldvalue);
                }
                
            }
        }
        for (Dom.XMLNode child: node.getChildElements()){
            parseXml(child,orderEntryRec);
        }        
    }  
    
    private static void parseXmlPMS(DOM.XMLNode node, Order_Entry__c orderEntryRec) {
        
        if(mapOfFields.get(node.getName()) != null){
            
            String fieldName = mapOfFields.get(node.getName());  
            
            String nodeName = node.getName();
            if(nodeName.equals('InvestmentId')){
                
                for(DOM.XMLNode nodeObj : node.getChildElements()){
                    String childName = nodeObj.getName();
                    
                    if(childName.equals('InvestmentId')){
                        String fieldvalue = String.valueOf(orderEntryRec.get(fieldName));     
                        
                        if(fieldvalue != null){
                            nodeObj.addTextNode(fieldvalue);
                        }
                    }
                }  
            }
            else{
                String fieldvalue = String.valueOf(orderEntryRec.get(fieldName));            
                if(fieldvalue != null){
                    node.addTextNode(fieldvalue);
                }
            }
        }
        
        for (Dom.XMLNode child: node.getChildElements()){
            parseXmlPMS(child,orderEntryRec);
        }        
    }  
    
    public static String processXmlResponse(String requestXml,Id orderEntryRecid){     
        //String requestXML = '<?xml version="1.0" encoding="UTF-8"?><FIXML xsi:schemaLocation="http://www.finacle.com/fixml BOOtcSellOrderAddVer.xsd" xmlns="http://www.finacle.com/fixml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Header><RequestHeader><MessageKey><RequestUUID>1043</RequestUUID><ServiceRequestId>BOOtcSellOrderAddVer</ServiceRequestId><ServiceRequestVersion>10.2</ServiceRequestVersion><ChannelId>COR</ChannelId><LanguageId></LanguageId></MessageKey><RequestMessageInfo><BankId>EDWW</BankId><TimeZone></TimeZone><EntityId></EntityId><EntityType></EntityType><ArmCorrelationId></ArmCorrelationId><MessageDateTime>2019-11-06T11:54:55.444</MessageDateTime></RequestMessageInfo><Security><Token><PasswordToken><UserId></UserId><Password></Password></PasswordToken></Token><FICertToken></FICertToken><RealUserLoginSessionId></RealUserLoginSessionId><RealUser></RealUser><RealUserPwd></RealUserPwd><SSOTransferToken></SSOTransferToken></Security></RequestHeader></Header><Body><BOOtcSellOrderAddVerRequest><BOOtcSellOrderAddVerRq><BOOtcSellOrderCritDtls><InvestmentID>INVID00000514</InvestmentID><BondCode>ICIBK0405A</BondCode></BOOtcSellOrderCritDtls><BOOtcSellOrderDtls><BOOtcOrderDetails><OrderByPrice>M</OrderByPrice><IndicativeMarketPrice><value>100</value><crncy>INR</crncy></IndicativeMarketPrice><OrderQuantity><amountValue>100000</amountValue><currencyCode>INR</currencyCode></OrderQuantity><PaymentMode>C</PaymentMode></BOOtcOrderDetails></BOOtcSellOrderDtls></BOOtcSellOrderAddVerRq></BOOtcSellOrderAddVerRequest></Body></FIXML>';        HttpRequest req = new HttpRequest();        
        String apiUrl = '';
        String  apiUser = '';
        String  apiPass = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'OrderEntryEndPointURL')
                apiUrl = setting.Value__c;
            if(setting.DeveloperName == 'OrderEntryUsername')
                apiUser = setting.Value__c;
            if(setting.DeveloperName == 'OrderEntryPassword')
                apiPass = setting.Value__c;
        }
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST'); 
        
        req.setEndpoint(apiUrl);
        Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);   
        req.setHeader('Content-Type', 'application/xml');
        req.setTimeout(120000);
        
        Order_Entry__c orderUpdate = [Select Id, Quantity__c ,Transaction_Amount_Financial_Transaction__c,MFIncludeCustodyAcctNum__c, MFFrequency_API__c,Payment_Mode_PMS_API__c, Payment_Mode__c,Product_Type_Order_Entry__c ,  isReviewed__c , Face_Value__c  , Rate__c ,Order_Status__c, Plutus_Order_Id__c ,Client_Account_Display__c , RecordTypeId, Transaction_Type__c,Status__c,remarks__c,Transaction_Amount__c,Currency__c,Client_Account_gwm_Id__c, ProductCode__c, Client_Account_Remitter_Id_API__c, Communication_Mode_API__c, Indicative_Market_Price_API__c ,Market_Type_API__c, Counterparty_investment_API__c, Transaction_Type_API__c,PMS_Folio_API__c,POA_Non_POA__c   , MF_Feed_File_Gen_Reg_API__c , Folio__c , holdingModeMFAPI__c , Payment_Mode_MF_API__c , TranRouteModeAPI__c , Transaction_Type_MF_API__c , transmissionEntityMFAPI__c , transmissionEntTypeMFAPI__c , Value_Date__c , RedeemAllAPI__c, TransactionModeMFAPI__c, TransactionUnitMFAPI__c , Transaction_Unit__c ,PE_payment_mode_API__c,Transaction_Type_PE_API__c,custodyACNoMFAPI__c , reguRegNumAPI__c,Commitment_Amount__c , Value_Date_API__c,PE_ID__c,CreationPEID__c, MFDividentOptionAPI__c , Start_Date_API__c , End_Date_API__c, No_of_units__c , Cut_Off_Price_IPO_API__c , Funding_ROI__c , Order_Date__c  , Payment_Mode_IPO_API__c , IPOsettleFundsFlgAPI__c ,Price_new__c,Order_Date_API__c, IPO_Application_Number__c , IPO_Code__c , custodyAcctIdIPOAPI__c, of_Facevalue__c , Request_XML__c, Response_XML__c,Random_Number_Order_Id__c from Order_Entry__c where id =:orderEntryRecid Limit 1];    
        if(orderUpdate.Product_Type_Order_Entry__c == 'MF' && (orderUpdate.Transaction_Type__c == 'Redemption' )){
            String subStr = requestXML.substringBetween('</InvestmentId>');
            integer startIndex = requestXML.lastIndexOf(subStr);
            integer lastIndex = startIndex+subStr.length();
            String subStr1 = requestXML.subString(0,startIndex);
            String subStr2 = requestXML.subString(lastIndex,requestXML.length());
            requestXML = subStr1+subStr2;
            
        }
        /*Code start for PE / AIF investId  ans PEID Starts */
        
        if(orderUpdate.Product_Type_Order_Entry__c == 'PE / AIF'){
            String subStr = requestXML.substringBetween('</investId>');
            integer startIndex = requestXML.lastIndexOf(subStr);
            integer lastIndex = startIndex+subStr.length();
            String subStr1 = requestXML.subString(0,startIndex);
            String subStr2 = requestXML.subString(lastIndex,requestXML.length());
            requestXML = subStr1+subStr2;
            
        }
        
            if(orderUpdate.Product_Type_Order_Entry__c == 'PMS'){
            String subStr = requestXML.substringBetween('</pmsId>');
            integer startIndex = requestXML.lastIndexOf(subStr);
            integer lastIndex = startIndex+subStr.length();
            String subStr1 = requestXML.subString(0,startIndex);
            String subStr2 = requestXML.subString(lastIndex,requestXML.length());
            requestXML = subStr1+subStr2;
            
        }
        
        if(orderUpdate.Product_Type_Order_Entry__c == 'PE / AIF' && !orderUpdate.Transaction_Type__c.equals('Log Commitment')){
            String subStr = requestXML.substringBetween('</peId>');
            integer startIndex = requestXML.lastIndexOf(subStr);
            integer lastIndex = startIndex+subStr.length();
            String subStr1 = requestXML.subString(0,startIndex);
            String subStr2 = requestXML.subString(lastIndex,requestXML.length());
            requestXML = subStr1+subStr2;
            
        }
        if(orderUpdate.Product_Type_Order_Entry__c == 'PE / AIF' && orderUpdate.Transaction_Type__c == 'Log Commitment'){
            Integer flag = 0;
					if(orderUpdate.Commitment_Amount__c != null && flag == 0){
                        System.debug('Inside Commitment Amount Not Null');
						requestXML = requestXML.replace('@@@@####',String.valueof(orderUpdate.Commitment_Amount__c));
                        flag = 1;
                    }else{
                        System.debug('Inside empty Commitment ');
                        requestXML = requestXML.replace('@@@@####','');
                    }					
		System.debug('RD requestXML === '+requestXML);
        }
        if(orderUpdate.Product_Type_Order_Entry__c == 'PE / AIF' && (orderUpdate.Transaction_Type__c == 'Log Drawdown' || orderUpdate.Transaction_Type__c == 'Withdrawal'  )){					
            Integer flag = 0;
					if(orderUpdate.Transaction_Amount_Financial_Transaction__c != null && flag == 0){
                        System.debug('Inside Transaction  Amount Not Null');
						requestXML = requestXML.replace('####@@@@',orderUpdate.Transaction_Amount_Financial_Transaction__c);
                        flag = 1;

                    }else{
                        	System.debug('Inside Empty Transaction');
                        	requestXML = requestXML.replace('####@@@@','');
                    }
              
		}
        /*Code start for PE / AIF investId Ends */
          if(orderUpdate.Product_Type_Order_Entry__c == 'IPO' && (orderUpdate.Transaction_Type__c == 'Equity IPO' || orderUpdate.Transaction_Type__c == 'Bond IPO' )){
					if(orderUpdate.Price_new__c != null){
						requestXML = requestXML.replace('@@@@####',String.valueof(orderUpdate.Price_new__c));
                    }else{
                        requestXML = requestXML.replace('@@@@####','');
                    }
					if(orderUpdate.No_of_units__c != null){
						requestXML = requestXML.replace('####@@@@',orderUpdate.No_of_units__c);

                    }else{
                        	requestXML = requestXML.replace('####@@@@','');
                    }if(orderUpdate.of_Facevalue__c != null){
						requestXML = requestXML.replace('%%%%####',String.valueof(orderUpdate.of_Facevalue__c));
                    }else{
                        requestXML = requestXML.replace('%%%%####','');
                    }
              
		}
        
        System.debug('requestXML === '+requestXML);
        
        req.setBody(requestXML);
        Http http = new Http();
        System.debug('API Reuest Done Time '+ System.now());
        //orderUpdate.Request_XML__c = requestXML;
        Order_Entry_XMLs__c xmlObj = new Order_Entry_XMLs__c();
        xmlObj.Request_XML__c = requestXML;
        HTTPResponse res = http.send(req);
                System.debug('Response Received Time '+System.now());

        DOM.Document doc = new DOM.Document();
        String xml = res.getBody();
        System.debug('Resonse XML '+xml);
        if(xml != ''){
            xml = xml.replace('&lt;','<');
            xml = xml.replace('&gt;','>');
            doc.load(xml);     
            //orderUpdate.Response_XML__c = xml;
            xmlObj.Response_XML__c = xml;
            xmlObj.Order_Entry__c = orderUpdate.Id;
            insert xmlObj;
            System.debug('XML ==== '+xml);
            dom.XmlNode orderEntryAddRequest = doc.getRootElement();  
            
            parseXmlString(orderEntryAddRequest, orderEntryRecid);
            
            orderUpdate.Order_Status__c = ReviewedController.orderStatus;
            if(ReviewedController.orderStatus.equals('SUCCESS')){
                
                orderUpdate.Status__c = 'Completed';
                orderUpdate.isReviewed__c = true;
                orderUpdate.Plutus_Order_Id__c = ReviewedController.orderIdField;
                if(orderUpdate.Product_Type_Order_Entry__c == 'PMS'){
                    orderUpdate.PMS_Id__c =  ReviewedController.pmsIdField;
                }
                if(orderUpdate.Product_Type_Order_Entry__c == 'PE / AIF' && orderUpdate.Transaction_Type__c == 'Log Commitment'){
                    orderUpdate.InternalPEID__c =  ReviewedController.privateEquityIdField;                    
                }                
            }
            
            if(ReviewedController.orderStatus.equals('FAILURE')){	
                System.debug('888 '+ReviewedController.errorDesc);
                String errorShow = ReviewedController.errorDesc;
                if(errorShow.contains('|')){
                    errorShow = errorShow.trim();	
                    errorShow = errorShow.removeStart('|');			
                    System.debug('888 between'+errorShow);
                    errorShow = errorShow.removeEnd('|');
                }
                System.debug('888 After'+errorShow);
                orderUpdate.Error_Description__c = errorShow;
            }
            
            Database.update(orderUpdate); 
            if(ReviewedController.orderStatus.equals('SUCCESS')){
                return ReviewedController.orderStatus;
                
            }else if(ReviewedController.orderStatus.equals('FAILURE')){
                String errorShow = ReviewedController.errorDesc;
                if(errorShow.contains('|')){
                    errorShow = errorShow.trim();	
                    errorShow = errorShow.removeStart('|');
                    errorShow = errorShow.removeEnd('|');
                }
                return ReviewedController.orderStatus+' - '+errorShow;
            }
            return '';
            
        }else{
            orderUpdate.Order_Status__c = 'FAILURE';
            Database.update(orderUpdate); 
            String errorShow = res.getStatus();
            if(errorShow.contains('|')){
                errorShow = errorShow.removeStart('|');
                errorShow = errorShow.removeEnd('|');
            }
            return 'FAILURE - '+errorShow; 
        }
        
    }
    public static void parseXmlString(DOM.XMLNode node, Id orderEntryRecid) {
        // Order_Entry__c orderUpdate = [Select Id, Quantity__c , Rate__c ,Order_Status__c, Plutus_Order_Id__c ,Client_Account_Display__c , RecordTypeId, Transaction_Type__c,Status__c,remarks__c,Transaction_Amount__c,Currency__c from Order_Entry__c where id =:orderEntryRecid Limit 1];
        
        if((node.getName()) == 'HostTransaction'){
            for(DOM.XMLNode nodeObj : node.getChildElements()){
                if(nodeObj.getName()=='Status'){
                    
                    ReviewedController.orderStatus = nodeObj.getText();
                    
                }
            }	
        }
        if(node.getName()=='OrderID'){
            ReviewedController.orderIdField = node.getText();
        }
         if(node.getName()=='TransactionId'){
            ReviewedController.orderIdField = node.getText();
        }
        if(node.getName()=='TranId'){
            ReviewedController.orderIdField = node.getText();
        }
        
        if(node.getName()=='pmsId'){
            ReviewedController.pmsIdField = node.getText();
        }
        
        if(node.getName()=='privateEquityId'){
            ReviewedController.privateEquityIdField = node.getText();
        }
        
        if(node.getName()=='ErrorDesc'){
            String errorShow = ReviewedController.errorDesc;
            errorShow = errorShow + ' | '+ node.getText();
            if(errorShow.contains('null')){
                errorShow = errorShow.remove('null');
            }
            
            ReviewedController.errorDesc = errorShow;
        }
        
        
        for (Dom.XMLNode child: node.getChildElements()){
            parseXmlString(child,orderEntryRecid);
        }        
        
    }    
    
    
}