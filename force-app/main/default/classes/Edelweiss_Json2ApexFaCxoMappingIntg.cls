//
// Class is used to convert FA-CXO JSON string into class variable.
//

public class Edelweiss_Json2ApexFaCxoMappingIntg {

    public List<Fa_cso_mapping> fa_cso_mapping;

    public class Fa_cso_mapping {
        public String fa_employee_id;
        public String fa_miles_id;
        public String cso_employee_id;
        public String cso_miles_id;
    }

    
    public static Edelweiss_Json2ApexFaCxoMappingIntg parse(String json) {
        return (Edelweiss_Json2ApexFaCxoMappingIntg) System.JSON.deserialize(json, Edelweiss_Json2ApexFaCxoMappingIntg.class);
    }
}