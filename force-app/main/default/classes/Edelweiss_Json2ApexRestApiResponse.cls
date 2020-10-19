// Class is used to generate Json Response String.

public class Edelweiss_Json2ApexRestApiResponse{

    public class Response {
        public Integer response_code;
        public String response_message;
    }

    public Response response;

    
    public static Edelweiss_Json2ApexRestApiResponse parse(String json) {
        return (Edelweiss_Json2ApexRestApiResponse) System.JSON.deserialize(json, Edelweiss_Json2ApexRestApiResponse.class);
    }
}