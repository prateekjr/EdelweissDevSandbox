@istest
public with sharing class Edelweiss_BatchDeletePortfolioStagTest {

	public testmethod static void testDeletePortfolioStagRecord()
    {
	    Portfolio_Staging_Container__c objPSC=new Portfolio_Staging_Container__c();
        objPSC.Family_Name__c = 'Kapoor Suns & Family';
        objPSC.Family_Code__c = '10001';
        objPSC.Portfolio_Return_ITD__c = '100';
        objPSC.Portfolio_Return_MTD__c = '200';
        objPSC.Portfolio_Return_YTD__c = '300';
        objPSC.Date_of_Inception__c = date.newInstance(2016, 06, 21);
		objPSC.As_On_Date__c=date.newInstance(2016, 06, 21);
        insert objPSC;
        
        Edelweiss_BatchDeletePortfolioStaging obj=new Edelweiss_BatchDeletePortfolioStaging();
        
        obj.notifyAdminFlag=true;
        
        Test.startTest();
        Database.executeBatch(obj);
        Test.stopTest();
    }
}