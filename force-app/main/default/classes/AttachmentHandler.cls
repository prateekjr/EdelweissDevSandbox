public class AttachmentHandler{
    public static void prodcutAttachment(List<Attachment> lstAttachement){
        Map<Id,List<Attachment>> MapAttach = new Map<Id,List<Attachment>>();
        for(Attachment att : lstAttachement){
            system.debug(att.Parent.Type);
            system.debug(att.Name);//startsWithIgnoreCase('01t')
            string strId = att.ParentId;
            if(att.ParentId != null && strId.startsWithIgnoreCase('01t') && att.Name.containsIgnoreCase('Product') && att.Name.containsIgnoreCase('Note')){
                if(MapAttach.get(att.ParentId) != null){
                    List<Attachment> atts =  MapAttach.get(att.ParentId);
                    atts.add(att);
                    MapAttach.put(att.ParentId, atts);
                }
                else
                    MapAttach.put(att.ParentId, new List<Attachment> {att} );
            }
        }
        system.debug(MapAttach);
        if(MapAttach != null && MapAttach.keySet().size() > 0){
            List<String> ccEmailAdds = new List<String>();
            List<User> userlist = [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Product_Manager') AND IsActive = true];
            for(User u : userlist){
                ccEmailAdds.add(u.Email);
            }
            List<OrgWideEmailAddress> owea = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM Product'];
            Map<String,List<String>> MapToEmail = ProductEmailService.getMailToEmail('Submit for approval');
            
            List<Product2> lstUpdateProduct = new List<Product2>();
            Map<Id,Product2> mapProduct = new Map<Id,Product2>([SELECT Name,Id,Manufacturer_Name__c,Family,Sub_Asset_Class__c,ApprovalSubmitDate__c  FROM Product2 WHERE Id =: MapAttach.keySet()]);
            for(Id prodId : MapAttach.keySet()){
                Product2 prod = mapProduct.get(prodId);
                prod.Product_Note_Submitted__c=true;
                prod.ApprovalSubmitDate__c = system.today();
                lstUpdateProduct.add(prod);
                //String mailTo = 'Operation Team';
                //List<String> toAddresses = new List<String>{'pradip_mohite@persistent.com'};
                List<Attachment> atts = MapAttach.get(prodId);
                String subject = 'Product ('+prod.Name+') Submit For Approval';
                String mailBody = 'Please find attached product note for the new product to be launched. Please provide requirement completion Approval.';
                for(String mailTo :  MapToEmail.keySet()){
                    List<String> toAddresses = MapToEmail.get(mailTo);
                    //toAddresses.add('pradip_mohite@persistent.com');                
                    ProductEmailService.sendEmail(mailTo+' Team',mailBody,toAddresses,subject,atts,prod,null,ccEmailAdds,owea); 
                }
                
            }
            
            //Update Product - Product Note Submitted flag
            if(!lstUpdateProduct.isEmpty()){
                update lstUpdateProduct;
            }
        }
    }

    //Case client approval upload 
    public static void caseAttachment(List<Attachment> lstAttachement){
        Map<Id,List<Attachment>> MapAttach = new Map<Id,List<Attachment>>();
        for(Attachment att : lstAttachement){
            system.debug(att.Parent.Type);
            system.debug(att.Name);//startsWithIgnoreCase('500')
            string strId = att.ParentId;
            if(att.ParentId != null && strId.startsWithIgnoreCase('500') && att.Name.containsIgnoreCase('approval') && att.Name.containsIgnoreCase('client')){
                if(MapAttach.get(att.ParentId) != null){
                    List<Attachment> atts =  MapAttach.get(att.ParentId);
                    atts.add(att);
                    MapAttach.put(att.ParentId, atts);
                }
                else
                    MapAttach.put(att.ParentId, new List<Attachment> {att} );
            }
        }
        system.debug(MapAttach);
        if(MapAttach != null && MapAttach.keySet().size() > 0){
            
            List<Case> lstUpdateCase = new List<Case>();
            Map<Id,Case> MapCase = new Map<Id,Case>([SELECT Id,RecordTypeId,IsSendToFAUploadClientApproval__c,Buy_Sell__c,IsSendToRHApproval__c,Stage_Guide__c FROM Case WHERE Id =: MapAttach.keySet()]);
            for(Id caseId : MapAttach.keySet()){
                Case caseRec = MapCase.get(caseId);
                if(caseRec.IsSendToFAUploadClientApproval__c && EdelweissConstants.CaseRecordTypeMap.get(caseRec.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && caseRec.Buy_Sell__c != 'Sell'){
                    caseRec.IsSendToFAUploadClientApproval__c = false;
                    caseRec.IsSendToRHApproval__c = true;
                    caseRec.Stage_Guide__c = 'Pending Product Suitability Approval From RH';
                    lstUpdatecase.add(caseRec);
                } 
            }
            
            //Update Product - Product Note Submitted flag
            if(!lstUpdatecase.isEmpty()){
                update lstUpdatecase;
            }
        }
    }
}