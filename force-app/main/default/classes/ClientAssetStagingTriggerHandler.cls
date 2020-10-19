public class ClientAssetStagingTriggerHandler {

    public static void validateAsOnDate(List<Client_Asset_Staging_Container__c> stagingRecords){
        
        for(Client_Asset_Staging_Container__c record : stagingRecords){
            
            if(record.Annual_Record__c == '1'){
            	Date aDate = record.As_On_Date__c;    
                //Valide Month & Day is March 31
                if(aDate.month() != 3 || aDate.day() != 31){
                    record.addError('The As On Date is invalid for annual record');
                }
               
                if(System.today().month() < 4){
                    if(!(aDate.year() >= System.today().year()-2 && aDate.year() < System.today().year())){
                        record.addError('The As On Date is invalid for annual record');
                    }
                }
                else{
                    if(!(aDate.year() >= System.today().year()-1 && aDate.year() <= System.today().year())){
                    	record.addError('The As On Date is invalid for annual record');
                    }
                }
            }
            else if(String.isEmpty(record.Annual_Record__c)){
                record.Annual_Record__c = '0';
            }
        }
    }
}