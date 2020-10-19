/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Edelweiss_batchDeleteInsertedCAITest {

    static testMethod void testEdelweiss_batchDeleteInsertedCAITest() {
        Account a=new Account();
        a.Name='RAjesh';
        a.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Family');
        insert a;
        
        Account aa=new Account();
        aa.Name='RAjesh';
        
        aa.RecordTypeId=EdelweissConstants.AccountRecordTypeMap.get('Client');
        aa.ParentId=a.id;
        insert aa;
        
        
        Client_Account__c ca=new Client_Account__c();
        ca.Client__c=aa.Id;
        ca.Name='Rajesh';
      
        insert ca;
        
        Client_Asset_Information__c csi=new Client_Asset_Information__c();
        csi.Family__c=a.id;
        csi.Client_Account__c=ca.id;
        csi.Total_AUM__c=200;
        insert csi;
        List<Id> deletedIds = new List<Id>();
        deletedIds.add(csi.id);
        delete csi;
        
        Client_Asset_Information__c csi2=new Client_Asset_Information__c();
        csi2.Family__c=a.id;
        csi2.Client_Account__c=ca.id;
        csi2.Total_AUM__c=200;
        insert csi2;
        List<Id> insertedIds = new List<Id>();
        insertedIds.add(csi2.id);
        
        Edelweiss_batchDeleteInsertedCAI obj=new  Edelweiss_batchDeleteInsertedCAI(insertedIds,deletedIds); 
        
        Test.startTest();
        Database.executeBatch(obj, 200);
        Test.stopTest();
    }
}