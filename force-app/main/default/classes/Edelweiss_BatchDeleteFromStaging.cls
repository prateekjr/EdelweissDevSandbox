global class Edelweiss_BatchDeleteFromStaging implements Database.Batchable<sObject>,Database.Stateful {

    global  String Query;
    
    global Integer iterationCount; 
    global List<String> queryList;    
    
    global Edelweiss_BatchDeleteFromStaging()   
    {
        queryList = new List<String>();
        iterationCount = -1; 
        /*Delete all from Staging objects*/
        
        //Delete From Prodtct Staging
        query = 'SELECT id FROM Product_Staging_Container__c';
        queryList.add(query); 
        
        // Delete from Client_Asset_Information__c        
        query = 'SELECT id From Client_Asset_Information__c';
        queryList.add(query);
        
        // Delete from Client_Asset_Staging_Container__c        
        query = 'SELECT id From Client_Asset_Staging_Container__c';
        queryList.add(query);
        
        // Delete from Edelweiss_Clients_Staging_Container__c        
        query = 'SELECT id From Edelweiss_Clients_Staging_Container__c';
        queryList.add(query);
        
        // Delete from FA_CSO_Mapping__c        
        query = 'SELECT id From FA_CSO_Mapping__c';
        queryList.add(query);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        iterationcount++;
        return Database.getQueryLocator(queryList[iterationCount]);
   }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Try
        {
            database.delete(scope);
            DataBase.emptyRecycleBin(scope);
        }
        catch(Exception ex)
        {
            system.debug('EXCEPTION:'+ex.getMessage());
            Edelweiss_ErrorLogging_Utility.saveGenericException(ex, 'Class : Edelweiss_BatchDeleteFromStaging; Function : execute()');
            
        }
       
       
   }

   global void finish(Database.BatchableContext BC){
        
   }  
  
}