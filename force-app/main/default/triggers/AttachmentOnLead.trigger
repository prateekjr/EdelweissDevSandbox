trigger AttachmentOnLead on Attachment (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        AttachmentOnLeadHandler.chkProposal(Trigger.new);
        AttachmentOnLeadHandler.chkCustReply(Trigger.new);
        AttachmentOnLeadHandler.chkProposalForOpportunity(Trigger.new);
        AttachmentOnLeadHandler.checkDocumentUploadOnProduct(Trigger.new); 
        
        //Product note attchment 
        AttachmentHandler.prodcutAttachment(Trigger.new);  

        //Case Client Approval attchment 
        AttachmentHandler.caseAttachment(Trigger.new);
    }
}