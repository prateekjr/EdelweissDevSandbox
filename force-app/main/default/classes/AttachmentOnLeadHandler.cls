public class AttachmentOnLeadHandler {
	public static void chkProposal(List<Attachment> attachmentList){
	
		chkAttachmentOnLead(attachmentList,'proposal');
	}
	public static void chkCustReply(List<Attachment> attachmentList){
	
		chkAttachmentOnLead(attachmentList,'reply');
	}
	public static void chkProposalForOpportunity(List<Attachment> attachmentList){
		chkAttachmentOnOpportunity(attachmentList,'proposal');
	
	}
	public static void chkAttachmentOnLead(List<Attachment> attachmentList , String matchAttString){
		List<Lead> updatedLeadList = new List<Lead>();
		Set<Id> LeadIdSet = new Set<Id>();
		List<Lead>leadList = new List<Lead>();
		for(Attachment AttachmentObj : attachmentList){
			if(AttachmentObj.ParentId.getSObjectType() == Lead.sObjectType && 
			   AttachmentObj.Name.containsIgnoreCase(matchAttString) ){
				LeadIdSet.add(attachmentObj.ParentId);
			
			}
			
		}
		if(LeadIdSet!=null && LeadIdSet.size()>0){
			leadList = [SELECT id,Status,Proposal_Submitted_to_Client_Uploaded__c,Reply_received_from_client__c
							  FROM Lead WHERE Id IN:LeadIdSet];
		
		}
		
		for(Lead leadObj:leadList){
			if(matchAttString == 'proposal' && leadObj.Status == 'R0'){
			
				leadObj.Proposal_Submitted_to_Client_Uploaded__c = true;
				leadObj.Date_Proposal_is_Submitted__c = system.today();
				updatedLeadList.add(leadObj);
			}
			if(matchAttString == 'reply' && leadObj.Status == 'R1'){
			
				leadObj.Reply_received_from_client__c = true;
				updatedLeadList.add(leadObj);
			}
		}
		try{
			if(updatedLeadList!=null && updatedLeadList.size()>0){
				update updatedLeadList;
			}
		}catch(Exception e){
		
			system.debug('Exception in Lead updation and reason is::'+e);
		}
		
	} 
	public static void chkAttachmentOnOpportunity(List<Attachment> attachmentList , String matchAttString){
		List<Opportunity> updatedOpportunityList = new List<Opportunity>();
		Set<Id> opportunityIdSet = new Set<Id>();
		List<Opportunity>opportunityList = new List<Opportunity>();
		for(Attachment AttachmentObj : attachmentList){
			if(AttachmentObj.ParentId.getSObjectType() == Opportunity.sObjectType && 
			   	AttachmentObj.Name.containsIgnoreCase(matchAttString) ){
				opportunityIdSet.add(attachmentObj.ParentId);
			}
		}
		if(opportunityIdSet!=null && opportunityIdSet.size()>0){
			opportunityList = [SELECT id,StageName,Proposal_Submitted_for_the_product_opp__c
							  FROM Opportunity WHERE Id IN:opportunityIdSet];
		}
		for(Opportunity opportunityObj:opportunityList){
			if(matchAttString == 'proposal' && opportunityObj.StageName == EdelweissConstants.OPPORTUNITY_COLD_STAGE){
				opportunityObj.Proposal_Submitted_for_the_product_opp__c = true;
				updatedOpportunityList.add(opportunityObj);
			}
		}
		try{
			if(updatedOpportunityList!=null && updatedOpportunityList.size()>0){
				update updatedOpportunityList;
			}
		}catch(Exception e){
		
			system.debug('Exception in Lead updation and reason is::'+e);
		}
		
	} 
	public static void checkDocumentUploadOnProduct(List<Attachment> attachmentList){
		List<Product2> atProductList = new List<Product2>(); 
		for(Attachment atFile: attachmentList){
    		Sys_Properties__c dueDiligenceReportOnProduct = Sys_Properties__c.getValues('DueDiligenceReportOnProduct');
    		Sys_Properties__c productNoteOnProduct = Sys_Properties__c.getValues('ProductNoteOnProduct');
    		Sys_Properties__c disctributionAgreementOnProduct = Sys_Properties__c.getValues('DistributionAgreementOnProduct');    		
    		if(atFile.ParentId.getSObjectType() == Product2.sObjectType && atFile.Name.containsIgnoreCase(dueDiligenceReportOnProduct.value__c)){
	            Product2 atProduct = [SELECT id,Due_Diligence_Report_Uploaded__c, Due_Diligence_Report_Uploaded_Date__c from Product2 where id =:atFile.ParentId];
	            atProduct.Due_Diligence_Report_Uploaded_Date__c = System.today();
	            atProduct.Due_Diligence_Report_Uploaded__c = true;
	            atProductList.add(atProduct);
        	}else if(atFile.ParentId.getSObjectType() == Product2.sObjectType && atFile.Name.containsIgnoreCase(productNoteOnProduct.value__c)){
	            Product2 atProduct = [SELECT id,Product_Note_Uploaded_Date__c, Product_Note_Uploaded__c from Product2 where id =:atFile.ParentId];
	            atProduct.Product_Note_Uploaded_Date__c = System.today();
	            atProduct.Product_Note_Uploaded__c = true;
	            atProductList.add(atProduct);
        	}else if(atFile.ParentId.getSObjectType() == Product2.sObjectType && atFile.Name.containsIgnoreCase(disctributionAgreementOnProduct.value__c)){
	            Product2 atProduct = [SELECT id,Distribution_Agreement_Uploaded__c, Distribution_Agreement_Uploaded_Date__c from Product2 where id =:atFile.ParentId];
	            atProduct.Distribution_Agreement_Uploaded_Date__c = System.today();
	            atProduct.Distribution_Agreement_Uploaded__c = true;	            
	            atProductList.add(atProduct);
        	}
    	}
		try{
			if(atProductList.size()>0 && atProductList!=null){
				update atProductList;
			}
		}catch(Exception e){
			system.debug('Exception in Document Upload on Product :: '+e);
		}
		
	}
}