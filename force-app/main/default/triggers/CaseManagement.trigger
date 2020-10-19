trigger CaseManagement on Case (after insert,before insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        CaseManagementTriggerHandler.createInitialAccountOpeningTask(Trigger.new);
        CaseManagementTriggerHandler.maintainServiceHistory(Trigger.new, null);
        CaseManagementTriggerHandler.caseSharing(Trigger.new);
        CaseManagementTriggerHandler.updateAccountOnAccountOpenCase(Trigger.new);
        CaseManagementTriggerHandler.createLeadForExistingFamily(Trigger.new);
        
        //Product Suitabilty process for FT     
        CaseManagementTriggerHandler.InitiateApprovalRequest(Trigger.new,null); 
        CaseManagementTriggerHandler.InitiateTradingApprovalRequest(Trigger.new);
        //Case Acknowledgement Mail
         CaseManagementTriggerHandler.complaintAcknowledgement(Trigger.new); 
		
         
    }
    else if(Trigger.isInsert && Trigger.isBefore) {
        CaseManagementTriggerHandler.assignCaseOwner(Trigger.new,null);
        CaseManagementTriggerHandler.setCasePriority(Trigger.new);
        CaseManagementTriggerHandler.calculateServiceRequestDueDate(Trigger.new);
          CaseManagementTriggerHandler.newTATCalculateServiceRequestDueDate(Trigger.new);
        CaseManagementTriggerHandler.calculateFinancialTransactionDueDate(Trigger.new);
        //CaseManagementTriggerhandler.publishEmailIdFromLead(Trigger.new);
        CaseManagementTriggerHandler.validationForNewLead(Trigger.new); 
        //Product Suitabilty process for FT
        CaseManagementTriggerHandler.CheckProductRecommended(Trigger.new);
        CaseManagementTriggerHandler.updateBHandRH(Trigger.new,null);
        CaseManagementTriggerHandler.CheckRiskProfileSuitability(Trigger.new,null);
    }
    else if(Trigger.isUpdate && Trigger.isAfter && !CaseManagementTriggerHandler.stopCaseTrigger){
        CaseManagementTriggerHandler.maintainServiceHistory(Trigger.new, Trigger.oldMap);
        CaseManagementTriggerHandler.resetOwnerChangeReason(Trigger.new, Trigger.oldMap);
        CaseManagementTriggerHandler.restrictTaskEscalation(Trigger.new, Trigger.oldMap);
        //Product Suitabilty process for FT     
        CaseManagementTriggerHandler.InitiateApprovalRequest(Trigger.new, Trigger.oldMap);  
        CaseManagementTriggerHandler.reinitiateTradingApprovalRequest(Trigger.newMap, Trigger.oldMap);
        
    } 
    else if(Trigger.isUpdate && Trigger.isBefore){
        CaseManagementTriggerHandler.checkDependency(Trigger.new, Trigger.oldMap);
        CaseManagementTriggerHandler.recalculateServiceRequestDueDate(Trigger.new,Trigger.oldMap);  
        //Product Suitabilty process for FT     
        CaseManagementTriggerHandler.CheckRiskProfileSuitability(Trigger.new,Trigger.oldMap);
        CaseManagementTriggerHandler.updateBHandRH(Trigger.new,Trigger.oldMap);
        CaseManagementTriggerHandler.assignCaseOwner(Trigger.new,Trigger.oldMap);       
    }
    
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        CaseManagementTriggerHandler.validatePANNumber(Trigger.new);
        CaseManagementTriggerHandler.validateJointHolder(Trigger.new);
        CaseManagementTriggerHandler.NPSCaseClose(Trigger.new);
        CaseManagementTriggerHandler.validationForExistingFamily(Trigger.new);
        CaseManagementTriggerHandler.ValidateForsaleFinancialTrasaction(Trigger.new);
    }
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && CaseManagementTriggerHandler.runOnce()){
        CaseManagementTriggerHandler.updatePANonLead(Trigger.new);
        CaseManagementTriggerHandler.caseSharingForFT(Trigger.new,Trigger.oldMap);
		CaseManagementTriggerHandler.caseAccountSharing(Trigger.new,Trigger.oldMap);
    }
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
    {
        CaseManagementTriggerHandler.updateDueDateAfterCaseCreate(Trigger.new);        
         /* QRC Simplification*/
        CaseManagementTriggerHandler.updateManagerEmail(Trigger.new);
         CaseManagementTriggerHandler.calculatePaymentMode(Trigger.new);
    } 
    if((Trigger.isInsert) && Trigger.isBefore)
    {
        CaseManagementTriggerHandler.fetchSalutations(Trigger.new);
       
    } 
     if((Trigger.isInsert) && Trigger.isBefore)
    {
        CaseManagementTriggerHandler.copyDateFields(Trigger.new);
        CaseManagementTriggerHandler.cleanIncorrectFieldsValues(Trigger.new);
    } 
     if((Trigger.isUpdate) && Trigger.isBefore)
    {
        CaseManagementTriggerHandler.copyFields(Trigger.new);
    } 
     if(Trigger.isUpdate)
    {        CaseManagementTriggerHandler.restrictAmountUpdate(Trigger.new,Trigger.oldMap);
     		 CaseManagementTriggerHandler.restrictRiskProfileUpdate(Trigger.new,Trigger.oldMap);
     
     
     if(Trigger.isAfter){
  		CaseManagementTriggerHandler.saveIPS(Trigger.new);
     }
     
    } 
    
}