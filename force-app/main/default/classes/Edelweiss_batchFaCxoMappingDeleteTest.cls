@istest
public class Edelweiss_batchFaCxoMappingDeleteTest {

       public static testmethod void testEdelweiss_batchFaCxoMappingDelete()
      {
       TestClassutils.InsertSysProperties();
       List<FA_CSO_Mapping__c> listBatchRecords=new List<FA_CSO_Mapping__c>();
       FA_CSO_Mapping__c fc=new FA_CSO_Mapping__c();

       
       listBatchRecords.add(fc);       
       insert listBatchRecords; 
    
       Edelweiss_batchFaCxoMappingDelete obj=new Edelweiss_batchFaCxoMappingDelete();
       
       Test.startTest();
       Database.executeBatch(obj);
       Test.stopTest();          
          
      }
    
    
    
    
}