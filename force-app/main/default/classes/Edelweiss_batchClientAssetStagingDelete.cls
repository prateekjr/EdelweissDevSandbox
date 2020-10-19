////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 13 JAN 2016
//Description: Apex batch class to delete all the existing records of Client's Asset Satging Container.
//            
//@ 2016 Persistent System Ltd.
////////////////////////////////////

global class Edelweiss_batchClientAssetStagingDelete implements Database.Batchable<sObject> 
{
    global String strQuery;
    global List<Client_Asset_Staging_Container__c> listClientAssetStagingContainerRecords;
    // Class Constructor - set query string
    global Edelweiss_batchClientAssetStagingDelete() 
    {
        strQuery = 'SELECT id, Account_Code__c, Account_Name__c, Asset_Class__c, Client_Code__c, Client_Name__c, Family_Code__c, Family_Name__c, Scrip_Key__c, Scrip_Name__c, Source_Id__c, Sub_Asset_Class__c, Total_AUM__c, Is_Picked_By_Scheduler__c,Networth__c FROM Client_Asset_Staging_Container__c';
    }
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(strQuery);
    }
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Client_Asset_Staging_Container__c> listBatchRecords) 
    {
        delete listBatchRecords;
        DataBase.emptyRecycleBin(listBatchRecords);
    }
    
     // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        // Optional - you can send an email to an admin with results
    }
}