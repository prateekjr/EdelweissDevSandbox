@istest
public class BatchDeleteFromFaCxoStagingContainerTest {

    public testmethod static void testBatchDeleteFromFaCxoStagingContainer()
    {
        
    FA_CXO_Staging_Container__c fcs=new FA_CXO_Staging_Container__c();
        
    insert fcs;    
     
    BatchDeleteFromFaCxoStagingContainer obj=new BatchDeleteFromFaCxoStagingContainer();
        
     Test.startTest();
     Database.executeBatch(obj);
     Test.stopTest();
        
    }
    
}