global class Edelweiss_batchDeleteInsertedCAI implements Database.Batchable<sObject>,Database.Stateful{
	global String strQuery;
	global List<Id> deletedList;
    global List<Id> insertedList;
	global Edelweiss_batchDeleteInsertedCAI(List<Id> insertedIds, List<Id> deletedIds){
		deletedList = new list<Id>();
		insertedList = new list<Id>();
		
		deletedList = deletedIds;
		insertedList = insertedIds;
		
		strQuery = 'Select id from Client_Asset_Information__c where id IN :insertedList';
	}
	global Database.QueryLocator start(Database.BatchableContext bcMain){
        return Database.getQueryLocator(strQuery);
    }
	global void execute(Database.BatchableContext bcMain, List<Client_Asset_Information__c> listBatchRecords){
		Database.delete(listBatchRecords,true);		
	}
	global void finish(Database.BatchableContext bcMain){
	 	//TODO
	 	Database.executeBatch(new Edelweiss_batchUndeleteCAI(deletedList), 1000);
	}
}