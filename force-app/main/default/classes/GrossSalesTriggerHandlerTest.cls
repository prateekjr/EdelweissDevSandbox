@isTest
public class GrossSalesTriggerHandlerTest {

     public static testmethod void grossSalesTest()
        {
            List<Gross_Sales_Details__c> FARevenueList = new List<Gross_Sales_Details__c>();
            GrossSalesTriggerHandler triggerHandler = new GrossSalesTriggerHandler();
            Gross_Sales_Details__c fObj = new Gross_Sales_Details__c();
            fObj.OwnerId = UserInfo.getUserId();
            FARevenueList.add(fObj);
            insert(FARevenueList);
            //triggerHandler.parseGrossSalesData(FARevenueList);
        }
}