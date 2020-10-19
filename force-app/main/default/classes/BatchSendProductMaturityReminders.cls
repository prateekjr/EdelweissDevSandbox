global class BatchSendProductMaturityReminders implements Database.Batchable<sObject> , Database.Stateful{
    global String query;
    global List<Client_Asset_Information__c> clientAssetListToUpdate = new List<Client_Asset_Information__c>();     
    global List<Id> userList = new List<Id>();
    
    global BatchSendProductMaturityReminders(){        
        query = 'SELECT Id, Name, CreatedDate, Maturity_Date__c, Alert_Days__c,Primary_FA__c,'+
                 'Product__r.name  FROM Client_Asset_Information__c where Annual_Record__c = false '+
            	 'AND (Product__r.Sub_Asset_Class__c = \'Structured Products - Equity\' OR Product__r.Sub_Asset_Class__c = \'Structured Products - Debt\')';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listOfClientAsset){
        Sys_Properties__c sysProperties = Sys_Properties__c.getValues('Product Maturity');
        String daysList = sysProperties.value__c;        
        String[] listInDays = daysList.split(',');
        Integer dateDiff= 0;
        for(Client_Asset_Information__c clientAssetobj : listOfClientAsset){   
            if(clientAssetobj.Maturity_Date__c != null){
                dateDiff = date.today().daysBetween(clientAssetobj.Maturity_Date__c);               
                if(daysList != null){
                    if(daysList.contains(String.valueOf(dateDiff))){                        
                        clientAssetobj.Alert_Days__c = String.valueOf(dateDiff);                                    
                        clientAssetListToUpdate.add(clientAssetobj); 
                        
                    }                        
                } 
            }
            
        }    
        
    }
    global void finish(Database.BatchableContext bcMain) 
    { 
        if(clientAssetListToUpdate != null && clientAssetListToUpdate.size()>0){
             Database.update(clientAssetListToUpdate);
        }      
    }  
}