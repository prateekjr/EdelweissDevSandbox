public class TransactionInquireController {
    
    public static Map<String, String> mapOfFields = new Map<String, String>();    
    public static String orderStatus;
    public static String errorDesc;
    
    @AuraEnabled
    public static String callForApi(Id orderId){
   string responseString;
            Order_Entry__c orderOj = [SELECT Id  , Random_Number_Order_Id__c ,Status__c,InternalPEID__c, Product_Type_Order_Entry__c , PMS_Id__c , IPO_ORDER_ID__c , Plutus_Order_Id__c, Transaction_Type__c FROM Order_Entry__c WHERE id =:orderId];
         if(orderOj == null){
            responseString = 'No Data Found';
        } else if(! orderOj.Status__c.equals('Completed')){
            responseString = 'Record is Not Reviewed';
        }
        else
        { 
            String masterLabel = 'Inquire_';
            if(orderOj.Product_Type_Order_Entry__c == 'Bond'|| orderOj.Product_Type_Order_Entry__c == 'MF' ) {
               
                if(orderOj.Transaction_Type__c == 'SIP' || orderOj.Transaction_Type__c == 'SWP' || orderOj.Transaction_Type__c == 'STP') {
               			 masterLabel = masterLabel + 'SIP';
                }else {
                                    masterLabel = masterLabel + orderOj.Product_Type_Order_Entry__c+'_'+orderOj.Transaction_Type__c;
                    
                }
            }
            else if(orderOj.Product_Type_Order_Entry__c == 'PMS' || orderOj.Product_Type_Order_Entry__c == 'IPO') {
                masterLabel = masterLabel + orderOj.Product_Type_Order_Entry__c;
            }else if(orderOj.Product_Type_Order_Entry__c == 'PE / AIF' ) {
                masterLabel = masterLabel + 'PE';
            }
            

            OrderEntry_XML__mdt xmlObj = [Select Value__c from OrderEntry_XML__mdt where MasterLabel=:masterLabel];
            
            String apiUrl = '';
            String  apiUser = '';
            String  apiPass = '';
            List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
            for(IntegrationSetting__mdt setting : IntegrationSetting){
                if(setting.DeveloperName == 'OrderEntryEndPointURL')
                    apiUrl = setting.Value__c;
                if(setting.DeveloperName == 'OrderEntryUsername')
                    apiUser = setting.Value__c;
                if(setting.DeveloperName == 'OrderEntryPassword')
                    apiPass = setting.Value__c;
            }
            
            HTTPRequest req = new HTTPRequest();
            req.setMethod('POST'); 
            
            req.setEndpoint(apiUrl);
            Blob headerValue = Blob.valueOf(apiUser+ ':' + apiPass);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);   
            req.setHeader('Content-Type', 'application/xml');
            req.setTimeout(120000);
            
            
            List<OrderEntryXML_New__c> fieldandApiList = [SELECT id , FieldName__c , value__c FROM OrderEntryXML_New__c where RecordTypeName__c = 'Inquire'];
            
            for(OrderEntryXML_New__c orderEntry : fieldandApiList){
                mapOfFields.put(orderEntry.FieldName__c , orderEntry.value__c);
            }
            
            DOM.Document doc = new DOM.Document();
            String reqXml = '';
            if(xmlObj != null) {
                reqXml = xmlObj.Value__c; 
            }
            if(reqXml != null){
                doc.load(reqXml);            
                dom.XmlNode orderEntryAddRequest = doc.getRootElement(); 
                parseXml(orderEntryAddRequest,orderOj);
            }
            
                       String randomNumber = orderOj.Id + String.ValueOf(Integer.valueof((Math.random() * 10000000)));
			orderOj.Random_Number_Order_Id__c = randomNumber;
            String requestXML = doc.toXmlString();   
            if(requestXML != null) {
                
                if(requestXML.contains('#RandomNumber#')){
                     requestXML = requestXML.replace('#RandomNumber#',randomNumber);
                }
                if(orderOj.Product_Type_Order_Entry__c == 'Bond' || orderOj.Product_Type_Order_Entry__c == 'MF' ){
                    if(requestXML.contains('@@@@####')&& orderOj.Plutus_Order_Id__c != null) {
                        
                        requestXML = requestXML.replace('@@@@####',orderOj.Plutus_Order_Id__c);
                    }
                }
                else if(orderOj.Product_Type_Order_Entry__c == 'IPO'){
                    if(requestXML.contains('####@@@@')&& orderOj.Plutus_Order_Id__c != null) {
                        requestXML = requestXML.replace('####@@@@',orderOj.Plutus_Order_Id__c); 
                    }
                }
                else if(orderOj.Product_Type_Order_Entry__c == 'PE / AIF'){
                    if(requestXML.contains('@@@@####') && orderOj.InternalPEID__c != null) {
                        requestXML = requestXML.replace('@@@@####',orderOj.InternalPEID__c );
                    } 
                }
                req.setBody(requestXML);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                    System.debug('requestXML .. '+requestXML);
                System.debug('res .. '+res.getStatus());
                String xml = String.valueOf(res.getBody());
                System.debug('response xml before Parse :'+res.getBody());
                 
                if(xml != '' && xml != null && !(String.isEmpty(xml))){
                    System.debug('*** inside');
                    xml = xml.replace('&lt;','<');
                    xml = xml.replace('&gt;','>');
                    System.debug(' Response '+xml );
                    DOM.Document docRes = new DOM.Document();
                    docRes.load(xml);  
                    dom.XmlNode orderEntryAddRequest = docRes.getRootElement();  
                    parseXmlString(orderEntryAddRequest, orderOj);
                    orderOj.Order_Status__c = TransactionInquireController.orderStatus;
                    if(TransactionInquireController.orderStatus != null) {
                        if(TransactionInquireController.orderStatus.equals('SUCCESS')){
                            orderOj.Status__c = 'Completed';
                            orderOj.Error_Description__c = '';
                            //orderUpdate.Plutus_Order_Id__c = ReviewedController.orderIdField;
                            //if(orderUpdate.Product_Type_Order_Entry__c == 'PMS'){
                            //orderUpdate.PMS_Id__c =  ReviewedController.pmsIdField;
                            //                }
                        }
                        
                        if(TransactionInquireController.orderStatus.equals('FAILURE')){	
                            String errorShow = TransactionInquireController.errorDesc;
                            if(errorShow.contains('|')){
                                errorShow = errorShow.trim();	
                                errorShow = errorShow.removeStart('|');			
                                errorShow = errorShow.removeEnd('|');
                            }
                            orderOj.Error_Description__c = errorShow;
                        }
                        System.debug('orderOj Callfor PAi :'+orderOj);
                        Database.update(orderOj);
                        
                        if(TransactionInquireController.orderStatus.equals('SUCCESS')){
                            return TransactionInquireController.orderStatus;
                            
                        }else if(TransactionInquireController.orderStatus.equals('FAILURE')){
                            String errorShow = TransactionInquireController.errorDesc;
                            if(errorShow.contains('|')){
                                errorShow = errorShow.trim();	
                                errorShow = errorShow.removeStart('|');
                                errorShow = errorShow.removeEnd('|');
                            }
                            responseString = TransactionInquireController.orderStatus+' - '+errorShow;
                            return responseString;
                        }
                        else
                        {
                            responseString = 'SUCCESS';
                            return responseString;
                        }
                    }
                    else
                    {
                        Database.update(orderOj); 
                        responseString = 'SUCCESS';
                        return responseString;
                    }
                }
                else{
                 
                    String errorShow = res.getStatus();
                    if(errorShow.contains('|')){
                        errorShow = errorShow.removeStart('|');
                        errorShow = errorShow.removeEnd('|');
                    }
                     orderOj.Order_Status__c = 'FAILURE';
                    orderOj.Error_Description__c = errorShow;
                    Database.update(orderOj); 
                     responseString = 'FAILURE - '+errorShow; 
                    return responseString;
                } 
            
                
            }
        }
        return responseString;
    }
    
    private static void parseXml(DOM.XMLNode node, Order_Entry__c orderEntryRec) { 
        if(mapOfFields.get(node.getName()) != null){
            
            String fieldName = mapOfFields.get(node.getName());  
            if(fieldName != null){
                String fieldvalue = String.valueOf(orderEntryRec.get(fieldName));            
                if(fieldvalue != null){
                    node.addTextNode(fieldvalue);
                }
                
            }
        }
        for (Dom.XMLNode child: node.getChildElements()){
            parseXml(child,orderEntryRec);
        }        
    }  
    
    public static void parseXmlString(DOM.XMLNode node, Order_Entry__c orderOj) {
    // Order_Entry__c orderOj = [SELECT Id  , Product_Type_Order_Entry__c , Transaction_Type__c FROM Order_Entry__c WHERE id =:orderEntryRecid];

        if((node.getName()) == 'HostTransaction' || node.getName() == 'OrderId'){
            for(DOM.XMLNode nodeObj : node.getChildElements()){
                if(orderOj.Product_Type_Order_Entry__c == 'Bond'|| orderOj.Product_Type_Order_Entry__c == 'MF' || orderOj.Product_Type_Order_Entry__c == 'PE / AIF') {     
                    if(nodeObj.getName()=='tranStatus'){
                        System.debug('Status from F :'+ string.valueOf(nodeObj.getText()));
                        TransactionInquireController.orderStatus = nodeObj.getText();
                    }
                }
                if(orderOj.Product_Type_Order_Entry__c == 'PMS'|| orderOj.Product_Type_Order_Entry__c == 'IPO'){
                    if(node.getName()== 'Status'){
                        TransactionInquireController.orderStatus = node.getText();
                        System.debug('Status from F :'+ string.valueOf(nodeObj.getText()));
                        
                    }
                }

        
       
            }
        }
        if(node.getName()=='ErrorDesc'){
            String errorShow = TransactionInquireController.errorDesc;
            errorShow = errorShow + ' | '+ node.getText();
            if(errorShow.contains('null')){
                errorShow = errorShow.remove('null');
            }
            
            TransactionInquireController.errorDesc = errorShow;
        }
        
        
        for (Dom.XMLNode child: node.getChildElements()){
            System.debug('child Elements :'+child.getText());
            parseXmlString(child,orderOj);
        }        
        
    }    
}