global class Edelweiss_batchUndeleteCAI implements Database.Batchable<sObject>,Database.Stateful{
    global String strQuery;
    global List<Id> deletedList;
    global Edelweiss_batchUndeleteCAI(List<Id> deletedIds){
    	deletedList = new List<Id>();
    	deletedList = deletedIds;
        strQuery = 'Select id from Client_Asset_Information__c where id IN :deletedList AND isdeleted = true all rows';
    }
    global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listBatchRecords){
        Database.undelete(listBatchRecords,true);       
    }
    global void finish(Database.BatchableContext bcMain){
        //TODO
    }
}