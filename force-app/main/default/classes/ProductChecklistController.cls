public class ProductChecklistController {
	public class StageInfo{
        @AuraEnabled public String label { get;set; }
        @AuraEnabled public Boolean value { get;set; }
        Public StageInfo(String strlabel, Boolean isvalue){
            label = strlabel;
            value = isvalue;
        }
    }
    @AuraEnabled   
    public static List<StageInfo> getStageInfo(String CaseId)
    {   
        List<Case> lstCase = [Select Id,
		Script_Name__c,Script_Name__r.Recommended_Product__c,Script_Name__r.Risk_Profile_of_Product__c, 
		AccountId, Account.ParentId, Account.Parent.Risk_Profile_Based_on_IPS__c, Account.Parent.Rollup_AUM_of_Family__c,
		IsProductRecommended__c,IsSendToRHApproval__c,IsCaseAssignToCSO__c,IsProductRiskProfile__c,Amount__c,Buy_Sell__c
		From Case Where Id =: CaseId];
        List<StageInfo> lstStageInfo = new List<StageInfo>();
		MAP<String,Integer> riskProfileCount = new MAP<String,Integer>();
		riskProfileCount.put('Aggressive'.toUpperCase(),3);
		riskProfileCount.put('Balanced'.toUpperCase(),2);
		riskProfileCount.put('Conservative'.toUpperCase(),1);
        if(lstCase != null && lstCase.size() > 0){
          	case c = lstCase[0];
            if(c.Buy_Sell__c == 'Sell'){
               lstStageInfo.add(new StageInfo('SellCase',false)); 
            }else{
                integer accRisk = 0;
                if(c.AccountId != null && c.Account.ParentId != null && c.Account.Parent.Risk_Profile_Based_on_IPS__c != null)
                    accRisk = riskProfileCount.get(c.Account.Parent.Risk_Profile_Based_on_IPS__c.toUpperCase());
                integer prodRisk = 0;
                if(c.Script_Name__c != null && c.Script_Name__r.Risk_Profile_of_Product__c != null)
                    prodRisk = riskProfileCount.get(c.Script_Name__r.Risk_Profile_of_Product__c.toUpperCase());       
                Decimal familyAUAInLakh = 0;
                if(c.AccountId != null && c.Account.ParentId != null && c.Account.Parent.Rollup_AUM_of_Family__c != null && c.Account.Parent.Rollup_AUM_of_Family__c != 0)
                    familyAUAInLakh = (((c.Account.Parent.Rollup_AUM_of_Family__c /100000) * 10)/100);			
                
                system.debug('accRisk'+accRisk);
                system.debug('prodRisk'+prodRisk);
                system.debug('familyAUAInLakh'+familyAUAInLakh);
                                    
                if(c.Script_Name__r.Recommended_Product__c != 'Yes')
                    lstStageInfo.add(new StageInfo(Label.Need_Product_Recommendation_From_BH_and_RH,c.IsProductRecommended__c));
                if(c.Script_Name__r.Risk_Profile_of_Product__c == null){
                    lstStageInfo.add(new StageInfo(Label.Need_to_Update_Product_with_Risk_Profile,c.IsProductRiskProfile__c));
					lstStageInfo.add(new StageInfo(Label.Need_to_upload_Client_Approval_Document,false));
                    lstStageInfo.add(new StageInfo(Label.Need_Product_Suitability_Approval_From_RH,false));
				}
                
                if(accRisk > = prodRisk){
                    //Assigned case to CSO         
                }else if((accRisk + 1) == prodRisk && c.Amount__c <= familyAUAInLakh){
                    lstStageInfo.add(new StageInfo(Label.Need_Product_Suitability_Approval_From_RH,c.IsCaseAssignToCSO__c));	
                }else{
                    lstStageInfo.add(new StageInfo(Label.Need_to_upload_Client_Approval_Document,c.IsSendToRHApproval__c));
                    lstStageInfo.add(new StageInfo(Label.Need_Product_Suitability_Approval_From_RH,c.IsCaseAssignToCSO__c));
                }
            }                
        }else{ 
                lstStageInfo.add(new StageInfo('Case Id not found',false));   
        }    
        
        return lstStageInfo;
    }
}