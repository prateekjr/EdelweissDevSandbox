//database.executeBatch(new BatchForProductApprovalReminder()); 
global class BatchForProductApprovalReminder implements Database.Batchable<sObject> ,Database.Stateful
{
        
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        Date Day3Before = System.Today();
        Day3Before = Day3Before.addDays(-3);
        //String SOQL = 'Select Id,Product_Head__c,Product_Head_Approval__c,Product_Head_Reject__c Operations_and_Reporting_Approval__c, Technology_and_Reporting_Approval__c,MIS_Approval__c, Business_Head_Approval__c, Operations_Approval__c, Compliance_Approval__c, Operations_and_Reporting_Reject__c, Technology_and_Reporting_Reject__c, MIS_Reject__c, Business_Head_Reject__c, Operations_Reject__c, Compliance_Reject__c,Product_Note_Submitted__c,Requirement_Completion_Approval__c, Product_Live_Approval__c,Name, Manufacturer_Name__c, Family, Sub_Asset_Class__c,ApprovalSubmitDate__c From Product2  Where Product_Stage__c != \'Active\' AND Product_Note_Submitted__c = true AND (Requirement_Completion_Approval__c != true OR Product_Live_Approval__c != true) AND ApprovalSubmitDate__c <=: Day3Before ' ;Commented for Change : Club Sumbit for approval and Product Live Approval
       String SOQL = 'Select Id,Product_Head__c,Product_Head_Approval__c,Product_Head_Reject__c Operations_and_Reporting_Approval__c, Technology_and_Reporting_Approval__c,MIS_Approval__c, Business_Head_Approval__c, Operations_Approval__c, Compliance_Approval__c, Operations_and_Reporting_Reject__c, Technology_and_Reporting_Reject__c, MIS_Reject__c, Business_Head_Reject__c, Operations_Reject__c, Compliance_Reject__c,Product_Note_Submitted__c,Requirement_Completion_Approval__c, Product_Live_Approval__c,Name, Manufacturer_Name__c, Family, Sub_Asset_Class__c,ApprovalSubmitDate__c From Product2  Where Product_Stage__c != \'Active\' AND Product_Note_Submitted__c = true AND (Product_Live_Approval__c != true) AND ApprovalSubmitDate__c <=: Day3Before ' ;
        
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext ctx, List<sObject> scope)
    {
        if(scope != null){
           // Map<String,List<String>> MapSubmitForApproval = ProductEmailService.getMailToEmail('Submit for approval'); Commented for Change : Club Sumbit for approval and Product Live Approval
           // Map<Id,Map<String,List<String>>> MapToEmailSubmitToApproval = new Map<Id,Map<String,List<String>>>();
            Map<String,List<String>> MapProductLiveApproval = ProductEmailService.getMailToEmail('Product Live Approval');
            Map<Id,Map<String,List<String>>> MapToEmailProductLiveApproval = new Map<Id,Map<String,List<String>>>();
            Map<Id,Product2> MapProduct = new Map<Id,Product2>();
            
            List<Product2> prodList = (List<Product2>) scope; 
            if(prodList != null && prodList.size() > 0){
                for(Product2 prod : prodList){
                    MapProduct.put(prod.Id,prod);
                    /*if(prod.Product_Note_Submitted__c && !prod.Requirement_Completion_Approval__c){
                        Map<String,List<String>> MapEmail = new Map<String,List<String>>();
                        if(!prod.Operations_and_Reporting_Approval__c && !prod.Operations_and_Reporting_Reject__c){
                            MapEmail.put('Operations and Reporting',MapSubmitForApproval.get('Operations and Reporting'));
                        }
                        if(!prod.Technology_and_Reporting_Approval__c && !prod.Technology_and_Reporting_Reject__c){
                            MapEmail.put('Technology and Reporting',MapSubmitForApproval.get('Technology and Reporting'));
                        }
                        if(!prod.MIS_Approval__c && !prod.MIS_Reject__c){
                            MapEmail.put('MIS',MapSubmitForApproval.get('MIS'));
                        }
                        if(!prod.Compliance_Approval__c && !prod.Compliance_Reject__c){
                            MapEmail.put('Compliance',MapSubmitForApproval.get('Compliance'));
                        }
                        if(MapEmail != null && MapEmail.keySet().size() > 0)
                            MapToEmailSubmitToApproval.put(prod.Id, MapEmail);                  
                        
                    }*/if(prod.Product_Note_Submitted__c &&!prod.Product_Live_Approval__c ){                     
                        Map<String,List<String>> MapEmail = new Map<String,List<String>>();                     
                        		if(!prod.Operations_and_Reporting_Approval__c && !prod.Operations_and_Reporting_Reject__c){
                            MapEmail.put('Operations and Reporting',MapProductLiveApproval.get('Operations and Reporting'));
                        }
                        if(!prod.Technology_and_Reporting_Approval__c && !prod.Technology_and_Reporting_Reject__c){
                            MapEmail.put('Technology and Reporting',MapProductLiveApproval.get('Technology and Reporting'));
                        }
                        if(!prod.Compliance_Approval__c && !prod.Compliance_Reject__c){
                            MapEmail.put('Compliance',MapProductLiveApproval.get('Compliance'));
                        }
                        
                        if(!prod.Business_Head_Approval__c && !prod.Business_Head_Reject__c){
                            MapEmail.put('Business Head',MapProductLiveApproval.get('Business Head'));
                        }
                        if(!prod.Operations_Approval__c && !prod.Operations_Reject__c){
                            MapEmail.put('Operations',MapProductLiveApproval.get('Operations'));
                        }
                        if(!prod.Product_Head_Approval__c && !prod.Product_Head_Reject__c){
                            MapEmail.put('Product Head',MapProductLiveApproval.get('Product Head'));
                        }
                        if(MapEmail != null && MapEmail.keySet().size() > 0)
                            MapToEmailProductLiveApproval.put(prod.Id, MapEmail);
                    }                   
                }               
            }
            Map<Id,Id> MapProductDoc = new Map<Id,Id>();
            Map<Id,Id> MapDocVersion = new Map<Id,Id>(); 
            Map<Id,ContentVersion> docDataMap = new Map<Id,ContentVersion>();
           // if((MapToEmailSubmitToApproval != null && MapToEmailSubmitToApproval.keySet().size() > 0 ) ||  ( MapToEmailProductLiveApproval != null && MapToEmailProductLiveApproval.keySet().size() > 0) ){             
            if(( MapToEmailProductLiveApproval != null && MapToEmailProductLiveApproval.keySet().size() > 0) ){             
                List<Id> prodIds = new List<Id>();
                //if(MapToEmailSubmitToApproval.keySet().size() > 0)
                    //prodIds.addAll(MapToEmailSubmitToApproval.keySet());
                if(MapToEmailProductLiveApproval.keySet().size() > 0)
                    prodIds.addAll(MapToEmailProductLiveApproval.keySet());
                List<ContentDocumentLink> lstLink = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: prodIds ORDER BY SystemModstamp ASC];
                
                for(ContentDocumentLink doc : lstLink){
                    MapProductDoc.put(doc.LinkedEntityId, doc.ContentDocumentId);
                }
                
                if(MapProductDoc != null && MapProductDoc.keySet().size() > 0){
                    docDataMap = new Map<Id,ContentVersion>([SELECT ContentDocumentId,VersionData,Title,FileType,FileExtension,Id FROM ContentVersion Where ContentDocumentId =:MapProductDoc.values() ORDER BY SystemModstamp ASC]);
                    for(Id vId : docDataMap.keySet()){
                        ContentVersion vDoc = docDataMap.get(vId);
                        if(vDoc.Title.containsIgnoreCase('Product') && vDoc.Title.containsIgnoreCase('Note'))
                            MapDocVersion.put(docDataMap.get(vId).ContentDocumentId, vId);
                    }
                } 
            }
            List<Product_Approval_History__c> productApp = new List<Product_Approval_History__c>();           
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            /*if(MapToEmailSubmitToApproval != null && MapToEmailSubmitToApproval.keySet().size() > 0 ){
                for(Id PId : MapToEmailSubmitToApproval.keySet()){
                    Product2 prod = MapProduct.get(PId);
                    String subject = 'Reminder : Product ('+prod.Name+') Submit For Approval';
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
                    Map<String,List<String>> MapToEmail = MapToEmailSubmitToApproval.get(PId);
                    for(String mailTo :  MapToEmail.keySet()){          
                        List<String> toAddresses = MapToEmail.get(mailTo);
                        string senderName = mailTo;            
                        Messaging.SingleEmailMessage mail = BatchForProductApprovalReminder.getEmail(senderName,mailBody,toAddresses,subject,null,prod,docVersion,null,null);
                        mails.add(mail);                
                        productApp.add( BatchForProductApprovalReminder.productApprovalHistory(mail.plainTextBody,mail.subject,prod.Id,mailTo,'Sent',''));
                    }                   
                }           
            }*/
            
            if(MapToEmailProductLiveApproval != null && MapToEmailProductLiveApproval.keySet().size() > 0 ){
                for(Id PId : MapToEmailProductLiveApproval.keySet()){
                    Product2 prod = MapProduct.get(PId);
                    String mailBody = 'Please find attached product note for the new product to be launched. Please provide your approval.';
                    String subject = 'Reminder : Product ('+prod.Name+') Live Approval';
                    
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
                    Map<String,List<String>> MapToEmail = MapToEmailProductLiveApproval.get(PId);
                    for(String mailTo :  MapToEmail.keySet()){          
                        List<String> toAddresses = MapToEmail.get(mailTo);
                        //toAddresses.add('pradip_mohite@persistent.com'); 
                        string senderName = mailTo;
                        if(!mailTo.containsIgnoreCase('Business Head'))
                            senderName += ' Team';              
                        Messaging.SingleEmailMessage mail = BatchForProductApprovalReminder.getEmail(senderName,mailBody,toAddresses,subject,null,prod,docVersion,null,null);
                        mails.add(mail);                
                        productApp.add( BatchForProductApprovalReminder.productApprovalHistory(mail.plainTextBody,mail.subject,prod.Id,mailTo,'Sent',''));
                    }                   
                }           
            }
            
            if(mails != null && mails.size() > 0)
                Messaging.sendEmail(mails);  
            
            if(productApp != null && productApp.size() > 0)
                database.insert(productApp,true);
            
            
        }
    }
    
    global void finish(Database.BatchableContext ctx)
    {
      //database.executeBatch(new BatchForProductApprovalReminder());  
    }
    
    global static Messaging.SingleEmailMessage getEmail(String mailTo, String mailBody, List<String> toAddresses, String subject,List<Attachment> atts, Product2 product, ContentVersion docVersion, List<String> ccAddress,List<OrgWideEmailAddress> owea) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            Sys_Properties__c ProductEmailService = Sys_Properties__c.getValues('ProductEmailService');
            mail.setReplyTo(ProductEmailService.Value__c);
            mail.setSenderDisplayName('PWM-Product');
            if(ccAddress != null && ccAddress.size() > 0){              
                mail.setCcAddresses(ccAddress);
            }
            mail.setSubject(subject);
            mail.setBccSender(false);            
            
            // ContentDocment present 
            if(docVersion != null){
                List<Messaging.EmailFileAttachment> fileNames = new List<Messaging.EmailFileAttachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.Body = docVersion.VersionData;
                attach.FileName = docVersion.Title+'.'+docVersion.FileExtension;
                fileNames.add(attach);
                mail.setFileAttachments(fileNames);
            }            
            mail.setBccSender(false);
            mail.setUseSignature(false);        
            mail.htmlBody = getEmailBody(product, mailTo, mailBody);
            return mail;
      }
      
      global static String getEmailBody(Product2 product, String mailTo, String mailBody){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();       
        String prodURL = baseUrl + '/' + product.Id;
        String emailBody =  '<p style="font-family:Calibri;"> Hi '+ mailTo +',</br></br>' + mailBody +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Product Name</td>'+
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+prodURL+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + product.Name + '</a></td></tr>' +
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Manufacturer Name</td>'+
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">'+ product.Manufacturer_Name__c + '</a></td></tr>' +
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Asset Class</td>'+
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">'+ product.Family + '</a></td></tr>' +
                            '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px">Sub-Asset Class</td>'+
                            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">'+ product.Sub_Asset_Class__c + '</a></td></tr>'; 
        
       
       String endBody ='</table></br></br>Reply All to this email with one of these words in the <span style="background-color: #efff00;">first line</span> of the email message: APPROVE, APPROVED, YES, REJECT, REJECTED, NO.</br></br>You can also add comments on the <span style="background-color: #efff00;">second line</span>. Comments will be stored with the approval request in Salesforce CRM</br>';
       
        endBody += '</br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">PWM Product</p>';
        return(emailBody + endBody);
    }
    
    global static Product_Approval_History__c productApprovalHistory(String textBody, String subject, Id productId, String mailTo, String Action, string Status){ 
            Product_Approval_History__c prod = new Product_Approval_History__c();
            prod.Name = mailTo;
            prod.EmailBody__c = textBody;
            prod.EmailSubject__c = subject;
            prod.EmailAction__c = Action;
            prod.Product__c = productId;
            prod.Status__c = Status;
            return prod;
    }
}