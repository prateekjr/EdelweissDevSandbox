// Apex REST URI, provide inteface to post FA-CXO mapping in Salesforce.
// HttpPOST() method accept data from GWM online and generate FA_CXO object record based on SF User id

@RestResource(urlMapping='/edelweisscrm/restapi/v1.0/facsomapping/*')

global with sharing class Edelweiss_RestApiFaCxo
{
    @HttpPost
    global Static void postFaCxoMapping()
    {
        Boolean isValidRequest;
        RestRequest httpReq = RestContext.request;
        RestResponse httpRes = RestContext.response;
        String strResponseMessage;
        String strJSONResponse;
        if (httpRes == null) {
            httpRes = new RestResponse();
            RestContext.response = httpRes;
        }  
        
        try
        {
            // ******************** Validate JSON string.
            //collect request body
            String strRequestBody = httpReq.requestBody.toString().trim();        
            system.debug('inside fn postFaCxoMapping() :: strRequestBody >>'+strRequestBody );
            
            Edelweiss_Json2ApexFaCxoMappingIntg insJson2ApexFaCxo = new Edelweiss_Json2ApexFaCxoMappingIntg();
            //Validate Json
            try
            {
                insJson2ApexFaCxo = Edelweiss_Json2ApexFaCxoMappingIntg.parse(strRequestBody);
                system.debug('Http Post FA-CXO mapping:: insJson2ApexFaCxo if valid request::'+insJson2ApexFaCxo);
                
                if(insJson2ApexFaCxo !=Null)
                    isValidRequest = true;
                Else
                    isValidRequest = False;
            }
            catch(exception ex)
            {
                strResponseMessage = 'Response Code 400: ' + ex.getMessage();
                isValidRequest= false;
            }
            
            // Condition to aloow only valid Json.
            if(isValidRequest ==true)
            {
                //commented because after moving FA-Cxo integation on batch operation.
                // the function generateFaCxoMappingRecordList is commented in utility class.
                List<FA_CSO_Mapping__c> listFaCxo;
                //listFaCxo = Edelweiss_Integration_Utility.generateFaCxoMappingRecordList(insJson2ApexFaCxo);
                system.debug('Http Post FA-CXO mapping:: listFaCxo if valid request::'+listFaCxo);
                
                database.insert(listFaCxo );
                
                // generate response 
                strResponseMessage = 'Response Code 202: Fa-Cxo mapping request is successfully accpeted by Salesforce CRM!!';
                strJSONResponse = Edelweiss_Integration_Utility.generateHttpPostResponseMessages(strResponseMessage, 400);
                system.debug('Http Post FA-CXO mapping:: strJSONResponse if valid request::'+strJSONResponse );
                
                Edelweiss_Integration_Container__c objIntgrContainer=Edelweiss_Integration_Utility.generateIntegrationContainerRecord(strRequestBody, EdelweissConstants.FA_CXO_REST_API_NAME, isValidRequest, EdelweissConstants.REST_API_STATUS_SUCCESSFUL, strJSONResponse);
                database.insert(objIntgrContainer);
            }
            else
            {
                //generate error response for not valid JSON.
                if (strResponseMessage ==null)
                    strResponseMessage= 'Response Code 400: Not a Valid json request!!';
                
                strJSONResponse = Edelweiss_Integration_Utility.generateHttpPostResponseMessages(strResponseMessage, 400);
                system.debug('Http Post FA-CXO mapping:: strJSONResponse if not valid request::'+strJSONResponse );
                
                Edelweiss_Integration_Container__c objIntgrContainer=Edelweiss_Integration_Utility.generateIntegrationContainerRecord(strRequestBody, EdelweissConstants.FA_CXO_REST_API_NAME, isValidRequest, EdelweissConstants.REST_API_STATUS_FAILED, strJSONResponse);
                database.insert(objIntgrContainer);
            }
            
            if(strJSONResponse.contains('Response Code 400:')) 
            {
                httpRes.statusCode = 400;    
            }
            else 
            {
                httpRes.statusCode = 202;
            }
            
            httpRes.responseBody = Blob.valueOf(strJSONResponse);
        }
        catch(exception ex)
        {
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_RestApiFaCxo; Function : postFaCxoMapping()');
            
            strResponseMessage = 'Response Code 400: Fa-Cxo mapping request is not executed successfully in Salesforce CRM!! Error Summary ::'+ex.getMessage();
            strJSONResponse=Edelweiss_Integration_Utility.generateHttpPostResponseMessages(strResponseMessage, 400);
            
            httpRes.responseBody = Blob.valueOf(strJSONResponse);
            httpRes.statusCode = 400;
        }
    }
}