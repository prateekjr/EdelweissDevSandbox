public class checkAccount
{
    @future(callout=true)
    public static void callApi()
    {
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        httpRequest.setEndpoint('http://182.73.52.130:5045/api/Client/GetSalesForceClients');  
        String response = '';
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                System.debug('Response :'+httpResponse.getBody());
            } else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }   
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        }  
        System.debug(' ** response ** : ' + response );  
    }
}