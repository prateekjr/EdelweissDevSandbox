////////////////////////////////////
//Author: Abhishek Jyoti
//Date: 14 JAN 2016
//Description: Class is used for logging errors occurred during any process involved in integration.
//
//@ 2016 Persistent System Ltd.
////////////////////////////////////

public class Edelweiss_ErrorLogging_Utility 
{
    // Static function to log Exception object standered error logging.
    public static void saveGenericException(exception ex, String sourceOfException)
    {        
        Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
        exceptionRec.Error_Line_Number__c = String.ValueOf(ex.getLineNumber());
        exceptionRec.Error_Details__c = ex.getMessage();
        exceptionRec.Error_Type__c = ex.getTypeName();
        exceptionRec.Stack_Trace__c = ex.getStackTraceString();
        exceptionRec.Error_Source__c = sourceOfException;
        
        database.insert(exceptionRec);    
    }
    
    //return error log object record
    // used to log error on batch operations of integration
    public static Edelweiss_Error_Log__c generateGenericException(exception ex, String sourceOfException)
    {        
        Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
        exceptionRec.Error_Line_Number__c = String.ValueOf(ex.getLineNumber());
        exceptionRec.Error_Details__c = ex.getMessage();
        exceptionRec.Error_Type__c = ex.getTypeName();
        exceptionRec.Stack_Trace__c = ex.getStackTraceString();
        exceptionRec.Error_Source__c = sourceOfException;
        
        return exceptionRec;    
    }
    
    
    // Static function to log customize errors.
    public static void storeExceptionWithCustomErrorLog(String errorDetails, String errorLineNumber, String integrationTransactionType, String errorSource, String errorType, String sObjectName, String stackTrace)
    {
        Edelweiss_Error_Log__c exceptionRec = new Edelweiss_Error_Log__c();
        
        exceptionRec.Error_Details__c = errorDetails;
        exceptionRec.Error_Line_Number__c = errorLineNumber;
        exceptionRec.Error_Occurred_In__c = integrationTransactionType;
        exceptionRec.Error_Source__c = errorSource;
        exceptionRec.Error_Type__c = errorType;
        exceptionRec.Related_Object_Name__c = sObjectName;
        exceptionRec.Stack_Trace__c = stackTrace;
        
        database.insert(exceptionRec);
    }  
}