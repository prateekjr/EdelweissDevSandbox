public class FundTranferController {
    
    @AuraEnabled
    public static List<Non_POA_Account__c> getBeneficiaryDetails(String GWM_Client_Account_Id){
        System.debug('GWM_Client_Account_Id'+GWM_Client_Account_Id);
        if(GWM_Client_Account_Id != null){
            List<Non_POA_Account__c>  beneficiaryDetailsObj = [SELECT Bank_Details__c ,GWM_Client_Account_Id__c, Beneficiary_Account_Number__c  , Beneficiary_Name__c , Client_Account__c ,Beneficiary_bank_IFSC_code__c FROM Non_POA_Account__c where GWM_Client_Account_Id__c =: GWM_Client_Account_Id];
            if(beneficiaryDetailsObj != null){
                return beneficiaryDetailsObj;
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Client_Account__c getRemitterInfo(Id clientAccount){
        if(clientAccount != null){
            Client_Account__c cObj = [SELECT Id , Backoffice_Code_Equity__c, Remitter_Account_No__c , Client__r.name , GWM_Client_Account_Id__c FROM Client_Account__c WHERE id=:clientAccount];
            System.debug('cObj'+cObj);
            if(cObj != null){
                return cObj;
            }
        }
        return null;
    }
        @AuraEnabled
    public static List<Remitter_Account_Details__c> getAllRemitterInfo(Id clientAccount){
        System.debug('*****clientAccountid is'+clientAccount);
        if(clientAccount != null){
            Client_Account__c cObj = [SELECT Id , Backoffice_Code_Equity__c, Remitter_Account_No__c , Client__r.name , GWM_Client_Account_Id__c FROM Client_Account__c WHERE id=:clientAccount];
            List<Remitter_Account_Details__c> rObjList = [SELECT Remitter_Account_No__c , id,GWM_Client_Account_Id__c  FROM Remitter_Account_Details__c WHERE GWM_Client_Account_Id__c =:cObj.GWM_Client_Account_Id__c];
			System.debug('********rObjList'+rObjList);           
            if(rObjList != null){
                return rObjList;
            }
        }
        return null;
    }
    
    
    @AuraEnabled
    public static List<Non_POA_Account__c> fetchBeneficiaryDetails(String Bank_Details){
        if(Bank_Details != null){
            List<Non_POA_Account__c> beneficiaryDetailsObj = [SELECT Beneficiary_Account_Number__c  ,Bank_Details__c, GWM_Client_Account_Id__c , Beneficiary_bank_IFSC_code__c ,Beneficiary_Name__c , Client_Account__c FROM Non_POA_Account__c where Bank_Details__c =:Bank_Details];
            if(beneficiaryDetailsObj != null){
                return beneficiaryDetailsObj;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static Non_POA_Account__c fetchBeneficiaryDetailsFromSetting(String TransferTo){
        BeneficiaryDetails__c beneficiaryDetails = BeneficiaryDetails__c.getValues(TransferTo);
        if(beneficiaryDetails != null){
            String beneficiaryAccountNumber = beneficiaryDetails.Beneficiary_Account_Number__c;
            String beneficiaryifscCode = beneficiaryDetails.Beneficiary_Bank_IFSC_Code__c;
            String beneficiaryName = beneficiaryDetails.Beneficiary_Name__c;
            
            Non_POA_Account__c  obj = new Non_POA_Account__c();
            obj.Beneficiary_Account_Number__c = beneficiaryAccountNumber;
            obj.Beneficiary_Name__c = beneficiaryName;
            obj.Beneficiary_Bank_IFSC_Code__c = beneficiaryifscCode;
            return obj;
        }
        return null;
    }
    
    @AuraEnabled
    public static Id getRecordTypeFTId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fund Transfer').getRecordTypeId();
        return recordTypeId;
    } 
    
}