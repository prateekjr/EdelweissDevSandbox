@istest
public class Edelweiss_ErrorLogging_UtilityTest{

    public static testmethod void testEdelweiss_ErrorLogging_Utility()
    {
        Test.startTest();
        Edelweiss_ErrorLogging_Utility.saveGenericException(new NullpointerException(), 'Class : Edelweiss_BatchDeleteFromStaging; Function : execute()');
        Edelweiss_ErrorLogging_Utility.generateGenericException(new NullpointerException(),'sourceOfException');
        Edelweiss_ErrorLogging_Utility.storeExceptionWithCustomErrorLog('errDetails','errLnNo','intTransType','errorSource','errorType','sObjtName','stackTrace');
        Test.stopTest();        
    }
}