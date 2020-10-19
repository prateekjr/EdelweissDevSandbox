@istest
public with sharing class Edelweiss_batchCaseUpdateSchedulerTest {

public testmethod static void TestEdelweiss_batchCaseUpdateScheduler()
{
    Test.startTest();
    Edelweiss_batchCaseUpdateScheduler sh1 = new Edelweiss_batchCaseUpdateScheduler();      
    String sch = '0 0 23 * * ?';
    system.schedule('Test check', sch, sh1);
    Test.stopTest();    
}

}