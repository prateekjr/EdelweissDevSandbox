public class IPSController{
    public ID recordId{get;set;}
    public List<Investment_Policy_Statement_IPS__c> iPsList;
    private final ApexPages.StandardController controller;
    public IPSController(ApexPages.StandardController controller){
        this.controller = controller;
        if(recordId == Null){
           recordId = ApexPages.currentPage().getParameters().get('id');
           iPsList = [Select Id, Name from Investment_Policy_Statement_IPS__c where id =: recordId];

        }
        System.debug('DildarLog: recordId - ' + recordId );
    }
    public List<Investment_Policy_Statement_IPS__c> getIpsList(){
        System.debug('DildarLog: iPsList - ' + iPsList);
        return iPsList;
    }
}