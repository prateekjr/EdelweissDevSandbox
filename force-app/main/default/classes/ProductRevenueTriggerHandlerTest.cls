@isTest
public class ProductRevenueTriggerHandlerTest {

    
    public static testmethod void ProductRevenue_Test()
        {
            List<ProductRevenue__c> revenueList = new List<ProductRevenue__c>();
            
            ProductRevenue__c fObj = new ProductRevenue__c();
            fObj.OwnerId = UserInfo.getUserId();
            fObj.Revenue_Date__c = System.today();
            fobj.Edelweiss_Employee_Id__c = '123456';
            fobj.ProductRevenueId__c = 'ASDFCNRGHOKLWES';
            revenueList.add(fObj);
            insert(revenueList);
            ProductRevenueTriggerHandler.parseRevenueData(revenueList);
        }
    
}