global class Edelweiss_batchProductIntegration implements Database.Batchable<sObject>,Database.Stateful {

    global String strQuery {get; set;}
    global Boolean isError = false;
    global List<Id> lstActivatedProductId;
    global Id orgWideEmailId;
    
    global Edelweiss_batchProductIntegration(){
        lstActivatedProductId = new List<Id>();
        isError = false;
        strQuery = 'SELECt Id, Asset_Class__c, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c,'+
            ' is_Deleted__c, ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c,'+
            ' Product_Class_Miles__c, Product_Name__c, Scrip_Key__c, Source_Id__c,Settlement_Date__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c, Error_Message__c , Amc_Code__c , Amc_Name__c , SchemeType__c,Scheme_Plan__c'+
            ' FROM Product_Staging_Container__c WHERE Synch__c = false';
        
        for(OrgWideEmailAddress owa : [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress]) {
            if(owa.DisplayName.equals('PWM SalesforceUpdate')){
                orgWideEmailId = owa.Id; 
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Product_Staging_Container__c> lstStgRecords) {
        List<Product2> lstInsertProduct = new List<Product2>();
        List<Product2> lstUpdateProduct = new List<Product2>();
        Set<String> setOfStgProductCode = new Set<String>();
        Map<String, Product_Staging_Container__c> mapStgProductCodeSourceId = new Map<String, Product_Staging_Container__c>();
        Map<String, Product_Staging_Container__c> mapStgProductName = new Map<String, Product_Staging_Container__c>();
        List<Product_Staging_Container__c> lstUpdateStgRecords = new List<Product_Staging_Container__c>();
        
        for(Product_Staging_Container__c objStgRecord : lstStgRecords){
            setOfStgProductCode.add(objStgRecord.Scrip_Key__c);
            mapStgProductCodeSourceId.put(objStgRecord.Scrip_Key__c +'_'+ objStgRecord.Source_Id__c, objStgRecord);
            mapStgProductName.put(objStgRecord.Product_Name__c, objStgRecord);
        }
        
        List<Product2> lstTemp1 = [
            SELECT Id, Name,IsActive, ProductCode, Family, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c, 
            ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c, Product_Class_Miles__c, 
            Source_Id__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c , Settlement_Date__c, Amc_Code__c , Amc_Name__c , SchemeType__c
            FROM Product2
            WHERE ProductCode IN :setOfStgProductCode 
        ];
        
        List<Product2> lstTemp2 = [
            SELECT Id, Name,IsActive, ProductCode, Family, Category_Miles__c, Draw_Down_Percentage__c, Face_Value__c, First_Draw_Down_Date__c, 
            ISIN__c, Issue_Date__c, Manufacturer_Name__c, Maturity_Date__c, Minimum_Investment_Value__c, Product_Class_Miles__c, 
            Source_Id__c, Structure__c, Sub_Asset_Class__c, Valid_Up_to__c , Settlement_Date__c , Amc_Code__c , Amc_Name__c , SchemeType__c
            FROM Product2
            WHERE Name IN :mapStgProductName.keySet() 
        ];
        
        Map<String, Product2> mapProductCodeSourceId = new Map<String, Product2>();
        Map<String, Product2> mapProductName = new Map<String, Product2>();
        
        if(lstTemp1 != Null){
            for(Product2 objProject : lstTemp1){
                if(!String.isEmpty(objProject.ProductCode) && !String.isEmpty(objProject.Source_Id__c)){
                    mapProductCodeSourceId.put(objProject.ProductCode +'_'+ objProject.Source_Id__c, objProject);    
                }
            }
        }
        if(lstTemp2 != null){
            for(Product2 objProject : lstTemp2){
                if(!String.isEmpty(objProject.Name)){
                    mapProductName.put(objProject.Name, objProject);    
                }
            }
        }
        
        for(Product_Staging_Container__c objStgRecord : lstStgRecords){
            try{
                if(mapProductCodeSourceId.containsKey(objStgRecord.Scrip_Key__c +'_'+ objStgRecord.Source_Id__c)){
                    Product2 objProduct = mapProductCodeSourceId.get(objStgRecord.Scrip_Key__c +'_'+ objStgRecord.Source_Id__c);
                    
                    //If mismatch in fields, then add product record to update list
                    //Else exclude record in update list
                    Product2 updatedProduct = updateProductDetails(objProduct, objStgRecord);
                    
                    if(objProduct.Name != objStgRecord.Product_Name__c){
                        if(updatedProduct == null){
                            updatedProduct = objProduct;
                        }
                        updatedProduct.Name = objStgRecord.Product_Name__c;
                    }
                    
                    if(updatedProduct != null){
                        lstUpdateProduct.add(updatedProduct); 
                    }
                }
                else if(mapProductName.containsKey(objStgRecord.Product_Name__c)){
                    Product2 objProduct = mapProductName.get(objStgRecord.Product_Name__c);
                    
                    //If mismatch in fields, then add product record to update list
                    //Else exclude record in update list
                    Product2 updatedProduct = updateProductDetails(objProduct, objStgRecord);
                    
                    if(objProduct.ProductCode != objStgRecord.Scrip_Key__c){
                        if(updatedProduct == null){
                            updatedProduct = objProduct;
                        }
                        updatedProduct.ProductCode = objStgRecord.Scrip_Key__c;
						if(!objProduct.IsActive)
							lstActivatedProductId.add(updatedProduct.Id);
                    }
                    if(objProduct.Source_Id__c != objStgRecord.Source_Id__c){
                        if(updatedProduct == null){
                            updatedProduct = objProduct;
                        }
                        updatedProduct.Source_Id__c = objStgRecord.Source_Id__c;
                    }
                    
                    if(updatedProduct != null){
                        lstUpdateProduct.add(updatedProduct); 
                    }
                }
                else{
                    //Create New Product Record with Active stage
                    Product2 newProduct = updateProductDetails(new Product2(), objStgRecord);
                    newProduct.Name = objStgRecord.Product_Name__c;
                    newProduct.ProductCode = objStgRecord.Scrip_Key__c;
                    newProduct.Source_Id__c = objStgRecord.Source_Id__c;
                    newProduct.Product_Type__c = 'External';
                    newProduct.Recommended_Product__c = 'No';
                    newProduct.Created_By_Integration__c = true;
                    lstInsertProduct.add(newProduct);
                }
            }catch(Exception e){
                System.debug('Error in Edelweiss_batchProductIntegration : '+e.getMessage());
                System.debug('Error Line Number : '+e.getLineNumber());
                System.debug('Error Stack Trace : '+e.getStackTraceString());
            }
        }
        isError = false;
        Integer index = 0;
        
        System.debug('lstUpdateProduct :: '+lstUpdateProduct);
        System.debug('lstInsertProduct :: '+lstInsertProduct);
        
        if(!lstInsertProduct.isEmpty()){
            Database.SaveResult[] products  = database.insert(lstInsertProduct, false);
            for(Database.SaveResult sr : products){
                
                Product2 insertedProduct = lstInsertProduct[index++];
                Product_Staging_Container__c stgRecord = null;
                if(mapStgProductCodeSourceId.containsKey(insertedProduct.ProductCode+'_'+insertedProduct.Source_Id__c)){
                    stgRecord = mapStgProductCodeSourceId.get(insertedProduct.ProductCode+'_'+insertedProduct.Source_Id__c);
                }else if(mapStgProductName.containsKey(insertedProduct.Name)){
                    stgRecord = mapStgProductName.get(insertedProduct.Name);
                }
                
                if(stgRecord != null){
                    if(!sr.isSuccess()){
                        String errorMessage = '';
                        if(String.isEmpty(stgRecord.Error_Message__c)){
                            stgRecord.Error_Message__c = '';
                        }
                        errorMessage = stgRecord.Error_Message__c = '';
                        for(Database.Error err : sr.getErrors()) {
                            stgRecord.Synch__c = false;
                            errorMessage += err.getMessage() + '\n'; 
                        }
                        stgRecord.Error_Message__c = errorMessage;
                        isError = true;
                    }
                    else{
                        stgRecord.Synch__c = true;
                        stgRecord.Error_Message__c = '';
                    }
                    lstUpdateStgRecords.add(stgRecord);
                } 
            }
        }
        
        index = 0;
        if(!lstUpdateProduct.isEmpty()){
            Database.SaveResult[] products = Database.update(lstUpdateProduct, false);
            for(Database.SaveResult sr : products){
                
                Product2 insertedProduct = lstUpdateProduct[index++];
                Product_Staging_Container__c stgRecord = null;
                if(mapStgProductCodeSourceId.containsKey(insertedProduct.ProductCode+'_'+insertedProduct.Source_Id__c)){
                    stgRecord = mapStgProductCodeSourceId.get(insertedProduct.ProductCode+'_'+insertedProduct.Source_Id__c);
                }else if(mapStgProductName.containsKey(insertedProduct.Name)){
                    stgRecord = mapStgProductName.get(insertedProduct.Name);
                }

                if(stgRecord != null){
                    if(!sr.isSuccess()){
                        String errorMessage = '';
                        if(String.isEmpty(stgRecord.Error_Message__c)){
                            stgRecord.Error_Message__c = '';
                        }
                        errorMessage = stgRecord.Error_Message__c = '';
                        for(Database.Error err : sr.getErrors()) {
                            stgRecord.Synch__c = false;
                            errorMessage += err.getMessage() + '\n'; 
                        }
                        stgRecord.Error_Message__c = errorMessage;
                        isError = true;
                    }
                    else{
                        stgRecord.Synch__c = true;
                        stgRecord.Error_Message__c = '';
                    }
                    lstUpdateStgRecords.add(stgRecord);
                } 
            }
        }
        if(!lstUpdateStgRecords.isEmpty()){
            Database.update(lstUpdateStgRecords);
        }
    }
    
	global void finish(Database.BatchableContext bcMain) {
        sendNotificationToAdmin(isError);
        
        if(lstActivatedProductId != null && !lstActivatedProductId.isEmpty()){
            sendNotificationToBHPH();   
        }
    }
    
    
    public static Product2 updateProductDetails(Product2 objProduct, Product_Staging_Container__c objStaging){
        Boolean isUpdated = false;
        if(!String.isEmpty(objStaging.Asset_Class__c) && objStaging.Asset_Class__c != objProduct.Family ){
            objProduct.Family = objStaging.Asset_Class__c;
        	isUpdated = true;
        }
        if(!String.isEmpty(objStaging.Sub_Asset_Class__c) && objStaging.Sub_Asset_Class__c != objProduct.Sub_Asset_Class__c ){
            objProduct.Sub_Asset_Class__c = objStaging.Sub_Asset_Class__c;
        	isUpdated = true;
        }
        if(!String.isEmpty(objStaging.Category_Miles__c) && objStaging.Category_Miles__c != objProduct.Category_Miles__c ){
            objProduct.Category_Miles__c = objStaging.Category_Miles__c;
        	isUpdated = true;
        }
        if(!String.isEmpty(objStaging.Product_Class_Miles__c) && objStaging.Product_Class_Miles__c != objProduct.Product_Class_Miles__c ){
            objProduct.Product_Class_Miles__c = objStaging.Product_Class_Miles__c;
        	isUpdated = true;
        }
        if(!String.isEmpty(objStaging.Draw_Down_Percentage__c) && objStaging.Draw_Down_Percentage__c != objProduct.Draw_Down_Percentage__c ){
            objProduct.Draw_Down_Percentage__c = objStaging.Draw_Down_Percentage__c;
        	isUpdated = true;
        }
        if(objStaging.Face_Value__c > 0 && objStaging.Face_Value__c != objProduct.Face_Value__c ){
            objProduct.Face_Value__c = objStaging.Face_Value__c;
        	isUpdated = true;
        } 
		if(objStaging.First_Draw_Down_Date__c != null && objStaging.First_Draw_Down_Date__c != objProduct.First_Draw_Down_Date__c ){
            objProduct.First_Draw_Down_Date__c = objStaging.First_Draw_Down_Date__c;
        	isUpdated = true;
        } 
		if(!String.isEmpty(objStaging.ISIN__c) && objStaging.ISIN__c != objProduct.ISIN__c ){
            objProduct.ISIN__c = objStaging.ISIN__c;
        	isUpdated = true;
        } 
		if(objStaging.Issue_Date__c != null && objStaging.Issue_Date__c != objProduct.Issue_Date__c ){
            objProduct.Issue_Date__c = objStaging.Issue_Date__c;
        	isUpdated = true;
        } 
		if(!String.isEmpty(objStaging.Manufacturer_Name__c) && objStaging.Manufacturer_Name__c != objProduct.Manufacturer_Name__c ){
            objProduct.Manufacturer_Name__c = objStaging.Manufacturer_Name__c;
        	isUpdated = true;
        } 
		if(objStaging.Maturity_Date__c != null && objStaging.Maturity_Date__c != objProduct.Maturity_Date__c ){
            objProduct.Maturity_Date__c = objStaging.Maturity_Date__c;
        	isUpdated = true;
        } 
		if(objStaging.Minimum_Investment_Value__c > 0 && objStaging.Minimum_Investment_Value__c != objProduct.Minimum_Investment_Value__c ){
            objProduct.Minimum_Investment_Value__c = objStaging.Minimum_Investment_Value__c;
        	isUpdated = true;
        } 
		if(!String.isEmpty(objStaging.Structure__c) && objStaging.Structure__c != objProduct.Structure__c ){
            objProduct.Structure__c = objStaging.Structure__c;
        	isUpdated = true;
        } 
		if(objStaging.Valid_Up_to__c != null && objStaging.Valid_Up_to__c != objProduct.Valid_Up_to__c ){
            objProduct.Valid_Up_to__c = objStaging.Valid_Up_to__c;
        	isUpdated = true;
        }
        if(objStaging.Settlement_Date__c != null && objStaging.Settlement_Date__c != objProduct.Settlement_Date__c ){
           System.debug('**** Updating product');
            objProduct.Settlement_Date__c = objStaging.Settlement_Date__c;
        	isUpdated = true;
        }
        	if(objStaging.Amc_Code__c != null && objStaging.Amc_Code__c != objProduct.Amc_Code__c ){
            objProduct.Amc_Code__c = objStaging.Amc_Code__c;
        	isUpdated = true;
        }
		  if(objStaging.Amc_Name__c != null && objStaging.Amc_Name__c != objProduct.Amc_Name__c ){
            objProduct.Amc_Name__c = objStaging.Amc_Name__c;
        	isUpdated = true;
        }
        
         if(objStaging.SchemeType__c != null && objStaging.SchemeType__c != objProduct.SchemeType__c ){
            objProduct.SchemeType__c = objStaging.SchemeType__c;
        	isUpdated = true;
        }
        
        if(objStaging.Scheme_Plan__c != null && objStaging.Scheme_Plan__c != objProduct.Scheme_Plan__c ){
            objProduct.Scheme_Plan__c = objStaging.Scheme_Plan__c;
            isUpdated = true;
        }
        
        
        
        
        if(isUpdated){
            objProduct.Product_Stage__c = 'Active';
            objProduct.Bypass_Validation__c = true;
            return objProduct;
        }
        
        return null;
    }
   
    public  void sendNotificationToAdmin(boolean hasErrors){
        
        List<String> lstToAddress = new List<String>();
        Sys_Properties__c custSettingEmailRecipient = Sys_Properties__c.getValues('Integration Email Recipient User');
        String strUserName = String.isEmpty(custSettingEmailRecipient.Value__c) ? 'PWM SalesforceUpdate' : custSettingEmailRecipient.Value__c ;
        
        List<User> listUsers = [
          SELECT Id, Email FROM User WHERE Name =: strUserName   
        ];
        for(User objUser: listUsers){
           lstToAddress.add(objUser.Email); 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(lstToAddress); 
        
        if(Null != orgWideEmailId){
            mail.setOrgWideEmailAddressId(orgWideEmailId);
        }else{
            mail.setSenderDisplayName('PWM SalesforceUpdate');
        }
        mail.setSubject('Product Integration Error Report');
        string mailHtmlBody = 'Hello Admin team,<br/><br/> The product integration batch executed successfully.';
        
        if(hasErrors){
            List<Report> reports  = [SELECT Id FROM Report WHERE DeveloperName = 'Product_Staging_Error_report'];
            string baseURL = '';
            if(reports.size() > 0){
                baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + reports[0].Id;
            }
        	mailHtmlBody = 'Hello Admin team,<br/><br/>There were errors reported while running the <b>Product Integration</b> batch. ' + '<br/><br/>To view failed records, go to <b> <a href="'+baseURL +'"> Product Data Error Report</a> </b>';
        }
        String signature = '<br /><br/>Regards,<br/><b>Edeleweiss Salesforce Integration Support</b>';
        
        mail.HtmlBody= mailHtmlBody+ signature;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
		//Commented: The below code sends daily emali containing some products which are never going to be created in MILES  
		//User do not want such emails, hence stoped sending such emails tentatively.
		/* 
        List<Product2> lstProducts = [
            SELECt Id, Name, Manufacturer_Name__c, Family, Sub_Asset_Class__c, Product_Class_Miles__c, Category_Miles__c 
            FROM Product2 WHERE Product_Stage__c = 'Product Live Approval Received' AND (ProductCode = null OR Source_Id__c = null)
        ];
        
        if(!lstProducts.isEmpty()){
            
            List<String> userRoles = new List<String>();
            userRoles.add('Operations Head');
            userRoles.add('Operations Manager');
            
            system.debug(userRoles);
            List<User> lstUser = [
                SELECT Id, Email, Name, UserRoleId, UserRole.Name FROM User WHERE IsActive = true AND UserRole.Name IN: userRoles
            ];
            
            List<String> emailAdds = new List<String>();
            for(User u : lstUser){
                if(u.UserRoleId != null){
                    emailAdds.add(u.Email);
                }
            }
            
            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            newMail.setToAddresses(emailAdds); 
            if(Null != orgWideEmailId){
                newMail.setOrgWideEmailAddressId(orgWideEmailId);
            }else{
                newMail.setSenderDisplayName('PWM SalesforceUpdate');
            }
            newMail.setSubject('Product creation in miles');
            newMail.htmlBody = getEmailBody(lstProducts);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newMail });
        }
		*/
    }
    
    public static String getEmailBody(List<Product2> products){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody =  '<p style="font-family:Calibri;">Hi Team,</br></br>Below listed products are required to create in Miles:' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Product Name</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Manufacturer Name</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Asset Class</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Sub Asset Class</th>' +
            				'<th style="border:1px solid #dddddd;text-align:left;padding:8px">Product Class (Miles)</th>' +
                            '<th style="border:1px solid #dddddd;text-align:left;padding:8px">Category (Miles)</th></tr>';
        
        String table; 
        for(Product2 p : products){
            String productUrl = baseUrl + '/' + p.Id;
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+productUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + returnEmptyForNull(p.Name) + '</a></td>' +
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + returnEmptyForNull(p.Manufacturer_Name__c) + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + returnEmptyForNull(p.Family) + '</td>'+
           	'<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + returnEmptyForNull(p.Sub_Asset_Class__c) + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + returnEmptyForNull(p.Product_Class_Miles__c) + '</td>'+
            '<td style="border:1px solid #dddddd;text-align:left;padding:8px">' + returnEmptyForNull(p.Category_Miles__c) + '</td></tr>';
            
            if(table == null)
                table = row;
            else
                table = table + row;       
        }
        
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + table + endBody);
    }
    
    public void sendNotificationToBHPH(){
        
        List<Product2> lstProducts = [
            SELECt Id, Name, Manufacturer_Name__c, Family, Sub_Asset_Class__c, Product_Class_Miles__c, Category_Miles__c , CreatedBy.Email
            FROM Product2 
            WHERE Id IN :lstActivatedProductId AND isActive = true AND Product_Stage__c = 'Active' AND ProductCode <> null AND Source_Id__c <> null
        ];
        
        if(!lstProducts.isEmpty()){
            
            // Send notification to BHPH - START
            List<String> userRoles = new List<String>();
            userRoles.add('Product Head');
            userRoles.add('Business Head');
            
            List<User> lstUser = [
                SELECT Id, Email, Name, UserRoleId, UserRole.Name FROM User WHERE IsActive = true AND UserRole.Name IN: userRoles
            ];
            
            List<String> emailAdds = new List<String>();
            for(User u : lstUser){
                if(u.UserRoleId != null){
                    emailAdds.add(u.Email);
                }
            }
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            newMail.setToAddresses(emailAdds); 
            if(Null != orgWideEmailId){
                newMail.setOrgWideEmailAddressId(orgWideEmailId);
            }else{
                newMail.setSenderDisplayName('PWM SalesforceUpdate');
            }
            newMail.setSubject('Product creation in miles');
            newMail.htmlBody = getProductCreationNotificationEmailBody(lstProducts, 'Dear All');
            messages.add(newMail);
            // Send notification to BHPH - END
            
            // Send notification to product creator - START
            Set<String> creatorEmailId = new Set<String>();
            for(Product2 prod : lstProducts){
                creatorEmailId.add(prod.CreatedBy.Email);
            }
            
            for(String email : creatorEmailId){
                List<Product2> lstProductCreatorWise = new List<Product2>();
                for(Product2 p : lstProducts){
                    if(p.CreatedBy.Email == email){
                        lstProductCreatorWise.add(p);
                    }
                }
                
                if(!lstProductCreatorWise.isEmpty()){
                    Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
                    e.setToAddresses(new List<String>{email}); 
                    if(Null != orgWideEmailId){
                        e.setOrgWideEmailAddressId(orgWideEmailId);
                    }else{
                        e.setSenderDisplayName('PWM SalesforceUpdate');
                    }
                    e.setSubject('Product creation in miles');
                    e.htmlBody = getProductCreationNotificationEmailBody(lstProductCreatorWise, 'Hi');
                    messages.add(e);
                }
            }
			// Send notification to product creator - END
            
            if(!messages.isEmpty()){
            	Messaging.sendEmail(messages);
            }
        }
    }
    
    public static String getProductCreationNotificationEmailBody(List<Product2> products, String strSalutation){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        String emailBody =  '<p style="font-family:Calibri;">'+strSalutation+',</br></br>This is to inform you that below product is active and is available Financial Transactions.' +
                            '</p></br><table style="border-collapse:collapse;font-family:Calibri;width:60%;">' +
                            '<tr><th style="border:1px solid #dddddd;text-align:left;padding:8px">Product Name</th></tr>';
        String table; 
        for(Product2 p : products){
            String productUrl = baseUrl + '/' + p.Id;
            String row = '<tr><td style="border:1px solid #dddddd;text-align:left;padding:8px"><a href="'+productUrl+'" target="_blank" style="text-decoration:none;color:#4d94ff;">' + returnEmptyForNull(p.Name) + '</a></td></tr>';
            if(table == null)
                table = row;
            else
                table = table + row;       
        }
        String endBody = '</table></br></br></br><p style="font-family:Calibri;">Regards,</p><p style="font-family:Calibri;">Edelweiss Administration</p>';
        return(emailBody + table + endBody);
    }
    
    public static String returnEmptyForNull(String str){
        if(null == str || str.trim() == ''){
           return ''; 
        }
        return str;
    }
    
}