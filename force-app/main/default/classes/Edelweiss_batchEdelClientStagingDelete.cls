///////////////////////////////////
//Author: Abhishek Jyoti
//Date: 18 JAN 2016
//Description: Apex batch class to delete all the existing records of Client's from Edelweiss Clients Satging Container.
//            
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class Edelweiss_batchEdelClientStagingDelete implements Database.Batchable<sObject> 
{
    global String strQuery;
    global List<Edelweiss_Clients_Staging_Container__c> listClientAssetStagingContainerRecords;
    // Class Constructor - set query string
    global Edelweiss_batchEdelClientStagingDelete() 
    {
        strQuery = 'SELECT id, Name FROM Edelweiss_Clients_Staging_Container__c';
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Edelweiss_Clients_Staging_Container__c> listBatchRecords) 
    {
        database.delete(listBatchRecords);
        DataBase.emptyRecycleBin(listBatchRecords);
    }
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        // Optional - you can send an email to an admin with results
    }
}