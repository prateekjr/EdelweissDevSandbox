public class ProductTriggerhandler{
    public static boolean stopAccountTrigger= false;
    //public static boolean stopUpdateClient= false;
    public static boolean stopUpdatefamily= false;
   
    public static void setStandardPrice(List<product2>productList){
      List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
      List<PriceBookEntry> updatedPricebookEntry = new List<PriceBookEntry>();
      for(Product2 prodObj :productList)
      {
          PriceBookEntry EntryObj = new PriceBookEntry();
          EntryObj.IsActive = prodObj.IsActive ;
          EntryObj.UnitPrice =0.0;
          if(stdPBL.size()>0){
            EntryObj.Pricebook2ID=stdPBL[0].id;
         }
          EntryObj.Product2ID =prodObj.id ;
          updatedPricebookEntry.add(EntryObj);
      }
      if(updatedPricebookEntry!=null && updatedPricebookEntry.size()>0)
      {
      System.debug('updatedPricebookEntry=='+updatedPricebookEntry);
          upsert updatedPricebookEntry;
      }
        
    }
    
    public static void ProductLiveApproval(List<product2>productList, Map<Id,product2> OldMap){
        
        List<Product2> sendNotification = new List<Product2>(); 
        List<Id> ProdIds = new List<Id>();
        for(Product2 prodObj :productList)
        {
            Product2 oldProd = OldMap.get(prodObj.Id);
            //if(oldProd.Requirement_Completion_Approval__c != prodObj.Requirement_Completion_Approval__c && prodObj.Requirement_Completion_Approval__c){              
            if(oldProd.Product_Note_Submitted__c != prodObj.Product_Note_Submitted__c && prodObj.Product_Note_Submitted__c)  {
                sendNotification.add(prodObj);
                ProdIds.add(prodObj.Id); 
            }
        }
        system.debug(sendNotification);
        if(sendNotification != null && sendNotification.size() > 0){            
            Map<Id,Id> MapProductDoc = new Map<Id,Id>();
            Map<Id,Id> MapDocVersion = new Map<Id,Id>();
            
            List<ContentDocumentLink> lstLink = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: ProdIds ORDER BY SystemModstamp ASC];
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
            List<String> ccEmailAdds = new List<String>();
            List<User> userlist = [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName  IN ('Product_Head','Product_Manager') AND IsActive = true];
            for(User u : userlist){
                ccEmailAdds.add(u.Email);
            }
            List<OrgWideEmailAddress> owea = [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress WHERE DisplayName = 'PWM Product'];
            //String subject = 'Product ('+prod.Name+') Live Approval';
            String mailBody = 'Please find attached product note for the new product to be launched. Please provide your approval.';
            for(Product2 prod : sendNotification){
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
                
                for(String mailTo :  MapToEmail.keySet()){
                    List<String> toAddresses = MapToEmail.get(mailTo);
                    //toAddresses.add('pradip_mohite@persistent.com'); 
                    string senderName = mailTo;
                    if(!mailTo.containsIgnoreCase('Business Head') && !mailTo.containsIgnoreCase('Product Head'))
                        senderName += ' Team';              
                    ProductEmailService.sendEmail(senderName,mailBody,toAddresses,subject,null,prod,docVersion,ccEmailAdds,owea);
                }
            }
            
            
        }
      
        
    }
    
    public static void updateStatus(List<Product2> lstProduct, Map<Id,product2> OldMap){
        
        for(Product2 product : lstProduct){
            
           // if(product.Operations_and_Reporting_Approval__c && product.Technology_and_Reporting_Approval__c && product.MIS_Approval__c && product.Compliance_Approval__c){Commented for Change : Club Sumbit for approval and Product Live Approval
      /*if(product.Operations_and_Reporting_Approval__c && product.Technology_and_Reporting_Approval__c && product.Compliance_Approval__c){
                product.Requirement_Completion_Approval__c = true;
                if(OldMap != null && OldMap.get(product.Id) != null && !OldMap.get(product.Id).Requirement_Completion_Approval__c)
                    product.ApprovalSubmitDate__c = system.today();
            }*/
            if(product.Operations_and_Reporting_Approval__c && product.Technology_and_Reporting_Approval__c && product.Compliance_Approval__c && product.Business_Head_Approval__c && product.Operations_Approval__c && product.Product_Head_Approval__c){
                product.Product_Live_Approval__c = true;
            }
            
            if(!String.isBlank(product.Source_Id__c) && !String.isBlank(product.ProductCode)){
                product.Product_Creation_In_Miles__c = true;
                product.IsActive = true;
                product.Product_Stage__c = 'Active';
            }
//            else if(product.Product_Creation_In_Miles__c){
//                product.Product_Stage__c = 'Pending Product Creation In Miles';
//            }
            else if(product.Product_Live_Approval__c){
                product.Product_Stage__c = 'Product Live Approval Received';
            }
            /*else if(product.Requirement_Completion_Approval__c){
                product.Product_Stage__c = 'Requirement Completion Approval Received';
            }*/
            else if(product.Product_Note_Submitted__c){
                product.Product_Stage__c = 'Product Note Submitted';
            }
            else if(product.Initiated__c){
                product.Product_Stage__c = 'Initiated';
            }
            
        }
    }
    
    //update FT case for Product Risk profile updated
    public static void updateFinancialTransaction(List<Product2> lstProduct, Map<Id,product2> OldMap){
        List<Id> prodId = new List<Id>();
        for(Product2 product : lstProduct){            
            If(product.Risk_Profile_of_Product__c != null && !(OldMap.get(product.Id).Risk_Profile_of_Product__c != null))
                prodId.add(product.Id);
        }       
        List<Case> lstUpdate = [SELECT Id,IsProductRiskProfile__c FROM Case WHERE Script_Name__c =: prodId AND Status = 'In Progress' AND IsProductRecommended__c = true ];
        for(Case c : lstUpdate){
            c.IsProductRiskProfile__c =  true;
        }
        if(lstUpdate != null && lstUpdate.size() > 0)
            update lstUpdate;
    }
    
    public static void validateProductName(List<Product2> lstNewProduct, Map<Id, Product2> mapOldProduct){
        
        Map<String, Product2> mapProductName = new Map<String, Product2>();
        
        if(Trigger.isUpdate){
            for(Product2 objProduct : lstNewProduct){
                if(objProduct.Name != mapOldProduct.get(objProduct.Id).Name){
                    mapProductName.put(objProduct.Name, objProduct);
                }
            }
            
            if(!mapProductName.isEmpty()){
                List<Product2> lstExistingProductMatchName = [
                    SELECT Id, Name FROM Product2 WHERE Name IN :mapProductName.keySet()
                ];
                
                for(Product2 objProduct : lstExistingProductMatchName){
                    Product2 newProduct = mapProductName.get(objProduct.Name);
                    newProduct.Name.addError('Product Name already exist');
                }
            }
        }
        else if(Trigger.isInsert){
            for(Product2 objProduct : lstNewProduct){
                mapProductName.put(objProduct.Name, objProduct);
            }
            
            if(!mapProductName.isEmpty()){
                List<Product2> lstExistingProductMatchName = [
                    SELECT Id, Name FROM Product2 WHERE Name IN :mapProductName.keySet()
                ];
                
                for(Product2 objProduct : lstExistingProductMatchName){
                    Product2 newProduct = mapProductName.get(objProduct.Name);
                    newProduct.Name.addError('Product Name already exist');
                }
            }
        }
        
    }
    
}