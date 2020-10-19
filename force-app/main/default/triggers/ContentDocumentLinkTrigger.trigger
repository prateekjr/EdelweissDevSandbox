trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        Map<Id,Id> contentDocIdMap = new Map<Id,Id>();
        Map<Id,Id> contentDocCaseIdMap = new Map<Id,Id>();
        for(ContentDocumentLink doclink : trigger.New){
            string strId = doclink.LinkedEntityId;
            if(strId != null && strId.startsWithIgnoreCase('01t')){
                contentDocIdMap.put(doclink.ContentDocumentId,doclink.LinkedEntityId);
            }
            if(strId != null && strId.startsWithIgnoreCase('500')){
                contentDocCaseIdMap.put(doclink.ContentDocumentId,doclink.LinkedEntityId);
            }           
        }
        
        //Product Note upload 
        if(contentDocIdMap != null && contentDocIdMap.keySet().size() > 0){
            Map<Id,Product2> mapProduct = new Map<Id,Product2>([SELECT Name,Id,Manufacturer_Name__c,Family,Sub_Asset_Class__c,Product_Note_Submitted__c,Operations_and_Reporting_Approval__c, Technology_and_Reporting_Approval__c,  
                MIS_Approval__c,ApprovalSubmitDate__c,Product_Stage__c   FROM Product2 WHERE Id =: contentDocIdMap.Values()]);
            List<ContentDocument> docs = [Select Id,Title,LatestPublishedVersionId From ContentDocument Where Id =: contentDocIdMap.keySet()];
            Map<Id,Id> docVersionIdMap = new Map<Id,Id>();
            for(ContentDocument doc : docs){
                if(doc.Title.containsIgnoreCase('Product') && doc.Title.containsIgnoreCase('Note')){
                    docVersionIdMap.put(doc.Id,doc.LatestPublishedVersionId);
                }
            }  
            if(docVersionIdMap != null && docVersionIdMap.keySet().size() > 0){
                Map<Id,ContentVersion> docDataMap = new Map<Id,ContentVersion>([SELECT VersionData,Title,FileType,FileExtension FROM ContentVersion Where Id =:docVersionIdMap.values()]);
                List<Product2> lstUpdateProduct = new List<Product2>();
                List<String> ccEmailAdds = new List<String>();
                List<User> userlist = [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Product_Manager')];
                List<OrgWideEmailAddress> owea = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM Product'];
                for(User u : userlist){
                    ccEmailAdds.add(u.Email);
                }
                
                for(Id docId : docVersionIdMap.keySet()){
                    Id productId = contentDocIdMap.get(docId);
                    Id versionId = docVersionIdMap.get(docId);
                    if(productId != null && mapProduct.get(productId) != null  && (mapProduct.get(productId).Product_Stage__c == 'Initiated' || mapProduct.get(productId).Product_Stage__c == 'Product Note Submitted' ) && versionId != null && docDataMap.get(versionId) != null){
                        Product2 prod = mapProduct.get(productId);
                        prod.Product_Note_Submitted__c=true;
                        prod.ApprovalSubmitDate__c = system.today();
                        lstUpdateProduct.add(prod);
                        ContentVersion docVersion = docDataMap.get(versionId);                        
                        Map<String,List<String>> MapToEmail = ProductEmailService.getMailToEmail('Submit for approval');
                        system.debug('before==>'+MapToEmail);
                        if(prod.Operations_and_Reporting_Approval__c){
                            MapToEmail.remove('Operations and Reporting');
                        }
                        if(prod.Technology_and_Reporting_Approval__c){
                            MapToEmail.remove('Technology and Reporting');
                        }
                        if(prod.MIS_Approval__c){
                            MapToEmail.remove('MIS');
                        }
                        if(prod.Compliance_Approval__c){
                            MapToEmail.remove('Compliance');
                        }
                        
                        system.debug('after==>'+MapToEmail);
                        
                        String subject = 'Product ('+prod.Name+') Submit For Approval';
                        String mailBody = 'Please find attached product note for the new product to be launched. Please provide requirement completion Approval.';
                        for(String mailTo :  MapToEmail.keySet()){
                            List<String> toAddresses = MapToEmail.get(mailTo);
                            //toAddresses.add('pradip_mohite@persistent.com');                
                            ProductEmailService.sendEmail(mailTo+' Team',mailBody,toAddresses,subject,null,prod,docVersion,ccEmailAdds,owea);
                        }
                    }
                }
                //Update Product - Product Note Submitted flag
                if(!lstUpdateProduct.isEmpty()){
                    update lstUpdateProduct;
                }
            }
        }
        
        //Case Client Approval update
        if(contentDocCaseIdMap != null && contentDocCaseIdMap.keySet().size() > 0){
            Map<Id,Case> mapCase = new Map<Id,Case>([SELECT Id,RecordTypeId,IsSendToFAUploadClientApproval__c,Buy_Sell__c,IsSendToRHApproval__c,Stage_Guide__c FROM Case WHERE Id =: contentDocCaseIdMap.Values()]);
            List<ContentDocument> docs = [Select Id,Title,LatestPublishedVersionId From ContentDocument Where Id =: contentDocCaseIdMap.keySet()];
            Map<Id,Id> docVersionIdMap = new Map<Id,Id>();
            for(ContentDocument doc : docs){
                if(doc.Title.containsIgnoreCase('approval') && doc.Title.containsIgnoreCase('client')){
                    docVersionIdMap.put(doc.Id,doc.LatestPublishedVersionId);
                }
            }  
            if(docVersionIdMap != null && docVersionIdMap.keySet().size() > 0){
                
                List<Case> lstUpdatecase = new List<Case>();
                for(Id docId : docVersionIdMap.keySet()){
                    Id CaseId = contentDocCaseIdMap.get(docId);
                    if(CaseId != null && mapCase.get(CaseId) != null ){
                        Case caseRec = mapCase.get(CaseId);
                        if(caseRec.IsSendToFAUploadClientApproval__c && EdelweissConstants.CaseRecordTypeMap.get(caseRec.RecordTypeId) == EdelweissConstants.FINANCIAL_TRANSACTION && caseRec.Buy_Sell__c != 'Sell'){
                            caseRec.IsSendToFAUploadClientApproval__c = false;
                            caseRec.IsSendToRHApproval__c = true;
                            caseRec.Stage_Guide__c = 'Pending Product Suitability Approval From RH';
                            lstUpdatecase.add(caseRec);
                        }                        
                    }
                }
                //Update Product - Product Note Submitted flag
                if(!lstUpdatecase.isEmpty()){
                    update lstUpdatecase;
                }
            }
        }
    }
}