public class ResendApprovalController {
     @AuraEnabled
    public static String getResendDetail(Id recordId) {
       String returnStr = '';
       List<Product2> prodList = [Select Id, Operations_and_Reporting_Approval__c, Technology_and_Reporting_Approval__c,  
                MIS_Approval__c,Business_Head_Approval__c, Operations_Approval__c, Compliance_Approval__c, Operations_and_Reporting_Reject__c, Technology_and_Reporting_Reject__c, MIS_Reject__c, Business_Head_Reject__c, Operations_Reject__c, Compliance_Reject__c,Product_Note_Submitted__c,Requirement_Completion_Approval__c, Product_Live_Approval__c,Name, Manufacturer_Name__c, Family, Sub_Asset_Class__c ,Product_Head_Reject__c From Product2 Where Id =: recordId]; 
                
        if(prodList != null && prodList.size() > 0){
            Product2 prod = prodList[0];
            //Product ('+prod.Name+') Submit For Approval 
           /* if(prod.Product_Note_Submitted__c && !prod.Requirement_Completion_Approval__c){
                if(prod.Operations_and_Reporting_Reject__c || prod.Technology_and_Reporting_Reject__c || prod.MIS_Reject__c || prod.Compliance_Reject__c){
                    ResendApprovalController.ProductRequirementCompletionApproval(prod);
                    returnStr = 'Successfully again submitted for requirement completion Approval.';
                }else{
                    returnStr = 'This record is already submitted for requirement completion Approval.';
                }
            }else */if(prod.Product_Note_Submitted__c && !prod.Product_Live_Approval__c ){
                if(prod.Operations_and_Reporting_Reject__c || prod.Technology_and_Reporting_Reject__c || prod.Compliance_Reject__c || prod.Business_Head_Reject__c || prod.Operations_Reject__c || prod.Product_Head_Reject__c ){
                    ResendApprovalController.ProductLiveApproval(prod);
                    returnStr = 'Successfully again submitted for product live Approval.';
                }else{
                    returnStr = 'This record is already submitted for product live Approval.';
                }           
            }else{
                returnStr = 'This record does not meet the entry criteria or initial submitters of any active approval processes.';
            }
        }
        
        return returnStr;
    }
    
    public static void ProductRequirementCompletionApproval(product2 prod){
        Map<Id,Id> MapProductDoc = new Map<Id,Id>();
        Map<Id,Id> MapDocVersion = new Map<Id,Id>();        
        List<ContentDocumentLink> lstLink = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: prod.Id ORDER BY SystemModstamp ASC];
        List<String> ccEmailAdds = new List<String>();
        List<User> userlist = [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Product_Manager') AND IsActive = true];
        List<OrgWideEmailAddress> owea = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM Product'];
        for(User u : userlist){
            ccEmailAdds.add(u.Email);
        }
        for(ContentDocumentLink doc : lstLink){
            MapProductDoc.put(doc.LinkedEntityId, doc.ContentDocumentId);
        }
        Map<Id,ContentVersion> docDataMap = new Map<Id,ContentVersion>();
        if(MapProductDoc != null && MapProductDoc.keySet().size() > 0){
            docDataMap = new Map<Id,ContentVersion>([SELECT ContentDocumentId,VersionData,Title,FileType,FileExtension,Id FROM ContentVersion Where ContentDocumentId =:MapProductDoc.values() ORDER BY SystemModstamp ASC]);
            for(Id vId : docDataMap.keySet()){
                ContentVersion vDoc = docDataMap.get(vId);
                if(vDoc.Title.containsIgnoreCase('Product') && vDoc.Title.containsIgnoreCase('Note'))
                    MapDocVersion.put(docDataMap.get(vId).ContentDocumentId, vId);
            }
        }

        Map<String,List<String>> MapToEmail = ProductEmailService.getMailToEmail('Submit for approval');
        String subject = 'Product ('+prod.Name+') Submit For Approval';
        String mailBody = 'Please find attached product note for the new product to be launched. Please provide requirement completion Approval.';      
        
        ContentVersion docVersion = null;
        if(MapProductDoc != null && MapProductDoc.get(prod.Id) != null){
            Id docId = MapProductDoc.get(prod.Id);
            if(MapDocVersion != null && MapDocVersion.get(docId) != null){
                Id docVId = MapDocVersion.get(docId);
                if(docDataMap.get(docVId) != null){
                    docVersion = docDataMap.get(docVId);
                }
            }               
        }
        system.debug('before==>'+MapToEmail);
        if(!prod.Operations_and_Reporting_Reject__c){
            MapToEmail.remove('Operations and Reporting');
        }
        if(!prod.Technology_and_Reporting_Reject__c){
            MapToEmail.remove('Technology and Reporting');
        }
        if(!prod.MIS_Reject__c){
            MapToEmail.remove('MIS');
        }
        if(!prod.Compliance_Reject__c){
            MapToEmail.remove('Compliance');
        }
        
        system.debug('after==>'+MapToEmail);
        
        for(String mailTo :  MapToEmail.keySet()){
            List<String> toAddresses = MapToEmail.get(mailTo);
            //toAddresses.add('pradip_mohite@persistent.com');                
            ProductEmailService.sendEmail(mailTo+' Team',mailBody,toAddresses,subject,null,prod,docVersion,ccEmailAdds,owea);
        }
        prod.Operations_and_Reporting_Reject__c = false;
        prod.Technology_and_Reporting_Reject__c = false;
        prod.MIS_Reject__c = false;
        database.update(prod,false);        
    }
    
    public static void ProductLiveApproval(product2 prod){
        Map<Id,Id> MapProductDoc = new Map<Id,Id>();
        Map<Id,Id> MapDocVersion = new Map<Id,Id>();        
        List<ContentDocumentLink> lstLink = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: prod.Id ORDER BY SystemModstamp ASC];
        List<String> ccEmailAdds = new List<String>();
        List<User> userlist = [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Product_Manager') AND IsActive = true];
        for(User u : userlist){
            ccEmailAdds.add(u.Email);
        }
        List<OrgWideEmailAddress> owea = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM Product'];
        for(ContentDocumentLink doc : lstLink){
            MapProductDoc.put(doc.LinkedEntityId, doc.ContentDocumentId);
        }
        Map<Id,ContentVersion> docDataMap = new Map<Id,ContentVersion>();
        if(MapProductDoc != null && MapProductDoc.keySet().size() > 0){
            docDataMap = new Map<Id,ContentVersion>([SELECT ContentDocumentId,VersionData,Title,FileType,FileExtension,Id FROM ContentVersion Where ContentDocumentId =:MapProductDoc.values() ORDER BY SystemModstamp ASC]);
            for(Id vId : docDataMap.keySet()){
                ContentVersion vDoc = docDataMap.get(vId);
                if(vDoc.Title.containsIgnoreCase('Product') && vDoc.Title.containsIgnoreCase('Note'))
                    MapDocVersion.put(docDataMap.get(vId).ContentDocumentId, vId);
            }
        }       
        Map<String,List<String>> MapToEmail = ProductEmailService.getMailToEmail('Product Live Approval');      
        //String subject = 'Product ('+prod.Name+') Live Approval';
        String mailBody = 'Please find attached product note for the new product to be launched. Please provide your approval.';
        String subject = 'Product ('+prod.Name+') Live Approval';
        
        ContentVersion docVersion = null;
        if(MapProductDoc != null && MapProductDoc.get(prod.Id) != null){
            Id docId = MapProductDoc.get(prod.Id);
            if(MapDocVersion != null && MapDocVersion.get(docId) != null){
                Id docVId = MapDocVersion.get(docId);
                if(docDataMap.get(docVId) != null){
                    docVersion = docDataMap.get(docVId);
                }
            }               
        }
        system.debug('before==>'+MapToEmail);
          if(!prod.Operations_and_Reporting_Reject__c){
            MapToEmail.remove('Operations and Reporting');
        }
        if(!prod.Technology_and_Reporting_Reject__c){
            MapToEmail.remove('Technology and Reporting');
        }
        /*if(!prod.MIS_Reject__c){
            MapToEmail.remove('MIS');
        }*/
        if(!prod.Compliance_Reject__c){
            MapToEmail.remove('Compliance');
        }
        if(!prod.Business_Head_Reject__c){
            MapToEmail.remove('Business Head');
        }
        if(!prod.Operations_Reject__c){
            MapToEmail.remove('Operations');
        }
        if(!prod.Product_Head_Reject__c ){
            MapToEmail.remove('Product Head');
        }
        system.debug('after==>'+MapToEmail);
        
        for(String mailTo :  MapToEmail.keySet()){          
            List<String> toAddresses = MapToEmail.get(mailTo);
            //toAddresses.add('pradip_mohite@persistent.com'); 
            string senderName = mailTo;
            if(!mailTo.containsIgnoreCase('Business Head'))
                senderName += ' Team';              
            ProductEmailService.sendEmail(senderName,mailBody,toAddresses,subject,null,prod,docVersion,ccEmailAdds,owea);           
        }
        prod.Operations_and_Reporting_Reject__c = false;
        prod.Technology_and_Reporting_Reject__c = false;
        prod.MIS_Reject__c = false;
        prod.Business_Head_Reject__c = false;
        prod.Operations_Reject__c = false;
        prod.Product_Head_Reject__c  = false;
        database.update(prod,false);        
    }
}