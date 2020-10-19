public class GoToPrismControllerNew {
    @AuraEnabled
    public static string getUrl(){   
        String url = '';
        List<IntegrationSetting__mdt> IntegrationSetting = [Select ID, DeveloperName, Value__c From IntegrationSetting__mdt ]; 
        for(IntegrationSetting__mdt setting : IntegrationSetting){
            if(setting.DeveloperName == 'PrismUrlNew'){
                System.debug('Inside '+setting.Value__c);
                url = setting.Value__c;
            }
            
        }
        return url;
    }
}