global class ProductEmailService implements Messaging.InboundEmailHandler {
      
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
            system.debug(email.subject);
            //system.debug(email); 
            List<Product_Approval_History__c> productApp = new List<Product_Approval_History__c>();
            string strProductId = '';
          System.debug('email.plainTextBody'+email.plainTextBody);
          string strBody = email.plainTextBody; 
            strBody = strBody.trim();
            String ProductId =  null;
           /* if(email.plainTextBody.containsIgnoreCase('ForInternalUse')){
                strProductId = email.plainTextBody.substringAfter('ForInternalUse');
            }/*else{
                strProductId = email.plainTextBody.substringAfter('<http:');
            }
            string strBody = email.plainTextBody; 
            strBody = strBody.trim();
            
            String ProductId =  null;
            system.debug('===>'+strProductId );
            if(strProductId != ''){
                strProductId = strProductId.substringBefore('</font>');
                ProductId = strProductId;
                //ProductId = '01t'+strProductId;
                /*List<string> prodIds = strProductId.split('/');
                if(prodIds != null && prodIds.size() > 0){
                    ProductId = prodIds[prodIds.size() -1];
                }
                system.debug('===>'+ProductId);             
                }*/
          
          if(strBody.containsIgnoreCase('ForInternalUse')){
              ProductId = email.plainTextBody.substringbetween('ForInternalUse','ForInternalUseEnd');
            }
            String strAppval = 'REJECT';
            if(strBody.startsWithIgnoreCase('APPROVE') || strBody.startsWithIgnoreCase('APPROVED') || strBody.startsWithIgnoreCase('YES'))
                strAppval = 'APPROVE';
            
            Product2 prod = [Select Id, Operations_and_Reporting_Approval__c, Technology_and_Reporting_Approval__c,  
                MIS_Approval__c,Business_Head_Approval__c, Operations_Approval__c, Compliance_Approval__c, Operations_and_Reporting_Reject__c, Technology_and_Reporting_Reject__c, MIS_Reject__c, Business_Head_Reject__c, Operations_Reject__c, Compliance_Reject__c , Product_Head__c , Product_Head_Approval__c , Product_Head_Reject__c From Product2 Where Id =: ProductId];
                
            List<Product_Approval_Email__mdt> ProductApprovalSetting = [Select Approval_Stage__c,MasterLabel,Id,User_Details__c,User_Origin__c From Product_Approval_Email__mdt];
            String strfrom = '';
           // if(email.subject.containsIgnoreCase('Submit For Approval') ){Commented for Change : Club Sumbit for approval and Product Live Approval
                if(email.plainTextBody.containsIgnoreCase('Operations and Reporting Team')){
                    if(strAppval == 'APPROVE')
                        prod.Operations_and_Reporting_Approval__c = true;
                    else
                        prod.Operations_and_Reporting_Reject__c = true;
                    
                    strfrom = 'Operations and Reporting Team';
                }
                else if(email.plainTextBody.containsIgnoreCase('Technology and Reporting Team') ){                   
                    if(strAppval == 'APPROVE')
                        prod.Technology_and_Reporting_Approval__c = true;
                    else
                        prod.Technology_and_Reporting_Reject__c = true;
                    strfrom = 'Technology and Reporting Team';
                }
                /*else if(email.plainTextBody.containsIgnoreCase('MIS Team')){
                    if(strAppval == 'APPROVE')
                        prod.MIS_Approval__c = true;
                    else
                        prod.MIS_Reject__c = true;
                    strfrom = 'MIS Team';
                }*/
                else if(email.plainTextBody.containsIgnoreCase('Compliance Team')){
                    if(strAppval == 'APPROVE')
                        prod.Compliance_Approval__c = true;
                    else
                        prod.Compliance_Reject__c = true;
                    strfrom = 'Compliance Team';
                }
          //  } Commented for Change : Club Sumbit for approval and Product Live Approval
        //  else if(email.subject.containsIgnoreCase('Live Approval')){
                if(email.plainTextBody.containsIgnoreCase('Business Head')){
                    if(strAppval == 'APPROVE')
                        prod.Business_Head_Approval__c = true;
                    else
                        prod.Business_Head_Reject__c = true;
                    strfrom = 'Business Head';
                }
                else if(email.plainTextBody.containsIgnoreCase('Operations Team')){
                    if(strAppval == 'APPROVE')
                        prod.Operations_Approval__c = true;
                    else
                        prod.Operations_Reject__c = true;
                    strfrom = 'Operations Team';
                }
               else if(email.plainTextBody.containsIgnoreCase('Product Head')){
                  
                   if(strAppval == 'APPROVE'){
                       prod.Product_Head_Approval__c = true;
                   }
                    else
                        prod.Product_Head_Reject__c = true;
                    strfrom = 'Product Head';
                   
                   System.debug('prod.Product_Head_Approval__c '+prod.Product_Head_Reject__c );
                }
          //  }
            
            database.update(prod,true);
            productApp.add( productApprovalHistory(email.plainTextBody,email.subject,ProductId,strfrom+' - '+email.fromName,'Receive',strAppval));
            database.insert(productApp,true);
            return result;
      }   
      
      global static void sendEmail(String mailTo, String mailBody, List<String> toAddresses, String subject,List<Attachment> atts, Product2 product, ContentVersion docVersion, List<String> ccAddress,List<OrgWideEmailAddress> owea) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Product_Approval_History__c> productApp = new List<Product_Approval_History__c>();
            mail.setToAddresses(toAddresses);
			System.debug('toAddresses : '+toAddresses);
			System.debug('ccAddress : '+ccAddress);
            Sys_Properties__c ProductEmailService = Sys_Properties__c.getValues('ProductEmailService');
            mail.setReplyTo(ProductEmailService.Value__c);
            mail.setSenderDisplayName('PWM-Product');
            if(ccAddress != null && ccAddress.size() > 0){              
                mail.setCcAddresses(ccAddress);
            }
            mail.setSubject(subject);
            mail.setBccSender(false);
            
            /*
            if (owea != null && owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setSenderDisplayName('PWM-Product');
            }
            */
            
            //List<Attachment> attList = [SELECT Body, ContentType,Name,OwnerId,ParentId FROM Attachment Where ParentId = '01t28000000bNmLAAU'];
            //Attachment att = attList[0];
            if(atts != null && atts.size() > 0){
                List<Messaging.EmailFileAttachment> fileNames = new List<Messaging.EmailFileAttachment>();
                for(Attachment att : atts){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.Body = att.Body;
                    attach.FileName = att.Name;
                    attach.ContentType = att.ContentType;
                    fileNames.add(attach);                  
                }               
                mail.setFileAttachments(fileNames); 
            }
            
            // ContentDocment present 
            if(docVersion != null){
                List<Messaging.EmailFileAttachment> fileNames = new List<Messaging.EmailFileAttachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.Body = docVersion.VersionData;
                attach.FileName = docVersion.Title+'.'+docVersion.FileExtension;
                //attach.ContentType = docVersion.FileType;
                fileNames.add(attach);
                mail.setFileAttachments(fileNames);
            }
            
            mail.setBccSender(false);
            mail.setUseSignature(false);        
            mail.htmlBody = getEmailBody(product, mailTo, mailBody);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            mails.add(mail);
            productApp.add( productApprovalHistory(mail.plainTextBody,mail.subject,product.Id,mailTo,'Sent','')); 
			System.debug('Mail Sent : '+mails);
            Messaging.sendEmail(mails);  
			System.debug('Mail Sent complete');			
            database.insert(productApp,true);
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
        String appendId = '<font color="white">ForInternalUse'+product.Id+'ForInternalUseEnd</font>';
          return(emailBody + endBody+appendId);
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
    
    global static Map<String,List<String>> getMailToEmail(string ApprovalStage){
            List<Product_Approval_Email__mdt> ProductApprovalSetting = [Select Approval_Stage__c,MasterLabel,Id,User_Details__c,User_Origin__c From Product_Approval_Email__mdt Where Approval_Stage__c =:ApprovalStage];
            Map<String,List<String>> MapToEmail = new Map<String,List<String>>();
            Map<String,List<String>> MapToUser = new Map<String,List<String>>();
            Map<String,List<String>> MapToRole = new Map<String,List<String>>();
            for(Product_Approval_Email__mdt prodSetting : ProductApprovalSetting){
                if(prodSetting.User_Origin__c == 'Email'){
                    MapToEmail.put(prodSetting.MasterLabel,prodSetting.User_Details__c.split(','));
                }else if(prodSetting.User_Origin__c == 'Role'){
                    MapToRole.put(prodSetting.MasterLabel,prodSetting.User_Details__c.split(','));
                }else if(prodSetting.User_Origin__c == 'User'){
                    MapToUser.put(prodSetting.MasterLabel,prodSetting.User_Details__c.split(','));
                }
            }
            system.debug(MapToEmail);
            system.debug(MapToRole);
            system.debug(MapToUser);
            system.debug(MapToRole.values());
            if(MapToRole != null && MapToRole.keySet().size() > 0){
                Set<String> userRoles = new Set<String>();
                for(String mailTo : MapToRole.keySet() ){
                    userRoles.addAll(MapToRole.get(mailTo));
                }
                system.debug(userRoles);
                List<User> users = [Select Email, Name, UserRoleId, UserRole.Name from User Where UserRole.Name IN: userRoles];
                for(String mailTo : MapToRole.keySet() ){
                    Set<String> roleNames = new Set<String>(MapToRole.get(mailTo));
                    List<string> emailAdds = new List<String>();
                    for(User u : users){
                        if(u.UserRoleId != null && roleNames.contains(u.UserRole.Name ))
                            emailAdds.add(u.Email);
                    }
                    MapToEmail.put(mailTo,emailAdds);
                }           
            }
            if(MapToUser != null && MapToUser.keySet().size() > 0){
                Set<String> userRoles = new Set<String>();
                for(String mailTo : MapToUser.keySet() ){
                    userRoles.addAll(MapToUser.get(mailTo));
                }
                system.debug(userRoles);
                List<User> users = [Select Email, Name, UserRoleId, UserRole.Name from User Where Name =: userRoles];
                for(String mailTo : MapToUser.keySet() ){
                    Set<String> roleNames = new Set<String>(MapToUser.get(mailTo));
                    List<string> emailAdds = new List<String>();
                    for(User u : users){
                        if(roleNames.contains(u.Name ))
                            emailAdds.add(u.Email);
                    }
                    MapToEmail.put(mailTo,emailAdds);
                }           
            }
            system.debug(MapToEmail);
            return MapToEmail;
    }
}