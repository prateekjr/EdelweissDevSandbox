@istest
global class MockHttpResponseGeneratorNew implements HttpCalloutMock {

    // Implement this interface method

    global HTTPResponse respond(HTTPRequest req) {

        // Optionally, only send a mock response for a specific endpoint

        // and method.
        
        //System.assertEquals('http://www.edelbusiness.in/PWMServiceSF/api/gw/FetchSubLobs', req.getEndpoint());

        System.assertEquals('POST', req.getMethod());
 
        // Create a fake response

        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{\"FAName\":\"Dec 2015\",\"MilesID\":\"20\"}]');
        res.setStatusCode(300);
        return res;
    }
}