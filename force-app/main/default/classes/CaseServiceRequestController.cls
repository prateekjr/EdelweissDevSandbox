public class CaseServiceRequestController {
   		//public static List<test1__c> data = [SELECT id ,Nature_of_Request__c,Product_Type__c,Name,Sub_Type__c FROM test1__c];
        public static List<Service_Type_TAT_Mapping__c> data = [SELECT Subtype__c , Product_Type__c , Nature_Of_Request__c , Name FROM Service_Type_TAT_Mapping__c];
		public static Map<String,set<String>> mapNatureProduct = new Map<String,set<String>>();
    	public static  Map<String,set<String>> mapNatureProductRequest = new Map<String,set<String>>();
    	public static  Map<String,set<String>> mapNatureProductRequestSub = new Map<String,set<String>>();
    @AuraEnabled 
    public static List<String> prepareData(String nature){
        set<String> product = new set<string>();  
        for(Service_Type_TAT_Mapping__c d : data){	
            if(!mapNatureProduct.containsKey(d.Nature_of_Request__c)){
                mapNatureProduct.put(d.Nature_of_Request__c, new Set<String>{d.Nature_of_Request__c+'$'+d.Product_Type__c});
            }else{
                mapNatureProduct.get(d.Nature_of_Request__c).add(d.Nature_of_Request__c+'$'+d.Product_Type__c);
            }
            if(!mapNatureProductRequest.containsKey(d.Nature_of_Request__c+'$'+d.Product_Type__c)){
                mapNatureProductRequest.put(d.Nature_of_Request__c+'$'+d.Product_Type__c,new Set<String>{d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name});
            }else{
                mapNatureProductRequest.get(d.Nature_of_Request__c+'$'+d.Product_Type__c).add(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name);
            }
            
            system.debug('mapNatureProductRequest'+mapNatureProductRequest);
        }
        List<String> p = new List<String>();       
        for(String productVal : mapNatureProduct.get(nature))
        {
            if(productVal.contains('$')){
                String tempProduct = productVal.substringAfterLast('$');
                if(tempProduct == 'null'){
                    
                }else{
                    p.add(tempProduct);
                }
            }
        }
        System.debug('p list is'+p);
        return p; 
    }    
    
		@AuraEnabled 
        public static List<String> getRequestTypeData(String natureAndProduct){
            System.debug('^^^^natureAndProduct'+natureAndProduct);
        for(Service_Type_TAT_Mapping__c d : data){	
            if(!mapNatureProductRequest.containsKey(d.Nature_of_Request__c+'$'+d.Product_Type__c)){
                mapNatureProductRequest.put(d.Nature_of_Request__c+'$'+d.Product_Type__c,new Set<String>{d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name});
            }else{
                mapNatureProductRequest.get(d.Nature_of_Request__c+'$'+d.Product_Type__c).add(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name);
            }
            
            system.debug('mapNatureProductRequest'+mapNatureProductRequest);
            system.debug('natureAndProduct'+natureAndProduct);
        }
        List<String> p = new List<String>();       
        for(String productVal : mapNatureProductRequest.get(natureAndProduct))
        {
            if(productVal.contains('$')){
                String tempProduct = productVal.substringAfterLast('$');
                if(tempProduct == 'null'){
                    
                }else{
                    p.add(tempProduct);
                }
            }
        }
        System.debug('p list is'+p);
        return p; 
        }    
    
    @AuraEnabled 
    public static Map<String,String> getRecordTypeInfo(){
        Map<String,String> MapRecordType = new Map<String,String>();
        List<RecordType> RecordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case'];
        for(RecordType rt : RecordTypeList){
            string strId = rt.Id;
            strId = strId.substring(0,15);
            MapRecordType.put(strId,rt.Name);
        }
        return MapRecordType;
    }
    @AuraEnabled
    public static List<String> getProduct(String nature){
        
        
        return null;
    }
    @AuraEnabled 
        public static List<String> getSubTypeData(String natureproductrequest){
            System.debug('^^^^natureAndProduct'+natureproductrequest); 
        for(Service_Type_TAT_Mapping__c d : data){	
            if(!mapNatureProductRequestSub.containsKey(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name)){
                mapNatureProductRequestSub.put(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name,new Set<String>{d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name+'$'+d.Subtype__c});
            }else{
                mapNatureProductRequestSub.get(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name).add(d.Nature_of_Request__c+'$'+d.Product_Type__c+'$'+d.Name+'$'+d.Subtype__c);
            }
            
            system.debug('mapNatureProductRequest'+mapNatureProductRequest);
        }
        List<String> p = new List<String>();       
        for(String productVal : mapNatureProductRequestSub.get(natureproductrequest))
        {
            if(productVal.contains('$')){
                String tempProduct = productVal.substringAfterLast('$');
                if(tempProduct == 'null'){
                    
                }else{
                    p.add(tempProduct);
                }
                
            }
        }
        System.debug('p list is'+p);
        return p; 
        } 
    
}