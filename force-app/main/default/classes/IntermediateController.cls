public class IntermediateController {
    
    public String RecordTypeName { get; set; }
    public String nn { get; set; }
    public String s { get; set; }
    public id IpsId {get;set;}
    public IntermediateController(ApexPages.StandardController controller) {
        IpsId = ApexPages.currentPage().getParameters().get('Id');
        Investment_Policy_Statement_IPS__c RT = [select client_name__r.Category__c from Investment_Policy_Statement_IPS__c where id=:IpsId ];
          RecordTypeName = RT.client_name__r.Category__c;
        
    }


    
     public IntermediateController()
     {
         IpsId = ApexPages.currentPage().getParameters().get('Id');
          Investment_Policy_Statement_IPS__c RT = [select client_name__r.Category__c from Investment_Policy_Statement_IPS__c where id=:IpsId ];
          RecordTypeName = RT.client_name__r.Category__c;
     }
}