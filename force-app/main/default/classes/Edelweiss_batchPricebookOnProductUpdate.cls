////////////////////////////////////
//Date: 13 JAN 2016
//@ 2016 Persistent System Ltd.
////////////////////////////////////
global class Edelweiss_batchPricebookOnProductUpdate implements Database.Batchable<sObject>,Database.Stateful 
{
    global String strQuery;
    global List<product2> listProductRecords;
   
    public List<Id> DeletionList;
    public List<Id> InsertedIds;
    global Edelweiss_batchPricebookOnProductUpdate (){
        strQuery = 'select id,name,IsActive from product2 where id not in (select product2id from PricebookEntry)';
    }   
    // Parametrized Constructor to get deleted records in case of error - set query string    
    global Edelweiss_batchPricebookOnProductUpdate (List<Id> deletedIds) 
    {
        DeletionList = new list<Id>();
        InsertedIds = new List<Id>();
        DeletionList = deletedIds;
        strQuery = 'select id,name,IsActive from product2 where id not in (select product2id from PricebookEntry)';
        //listProductRecords =[select id,name,IsActive from product2 where id not in (select product2id from PricebookEntry)];
                 
    }
    
    // "Start" runs when the class in instanciated
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
    system.debug('strQuery =='+strQuery );
        return Database.getQueryLocator(strQuery);
    }
    
    // "Execute" is what is being run as a separate process per batch
    global void execute(Database.BatchableContext bcMain, List<Product2> listBatchRecords) 
    {   
        boolean isFailed = false;
        listProductRecords= listBatchRecords;
        Map<PricebookEntry,String> FailureMap = new Map<PricebookEntry,String>();
         List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
      List<PriceBookEntry> updatedPricebookEntry = new List<PriceBookEntry>();
      for(Product2 prodObj :listProductRecords)
      {
          PriceBookEntry EntryObj = new PriceBookEntry();
          EntryObj.IsActive = prodObj.IsActive ;
          EntryObj.UnitPrice =0.0;
          EntryObj.Pricebook2ID=stdPBL[0].id;
          EntryObj.Product2ID =prodObj.id ;
          updatedPricebookEntry.add(EntryObj);
      }
        
        if(updatedPricebookEntry.size() > 0)  
        {
            Database.SaveResult[] srList = database.insert(updatedPricebookEntry,false);
             if(srList.size() > 0 ){
                Integer index = 0; 
                for (Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        //InsertedIds.add(sr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        isFailed = true;                        
                        for(Database.Error err : sr.getErrors()) {
                            FailureMap.put(updatedPricebookEntry[index], err.getMessage());
                            
                            
                        }
                        system.debug('FailureMap=='+FailureMap);
                    }
                    index++;
                }
            }
            if(isFailed){
               
                Id jobId = bcMain.getJobID();
                System.abortJob(jobId);     
            }
        }   
        //aumBatchCount=aumBatchCount+1;     
     }  
  
    // Finish the Batch Job
    global void finish(Database.BatchableContext bcMain) 
    {
        
    }
}