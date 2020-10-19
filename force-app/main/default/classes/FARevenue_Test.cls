@istest
public class FARevenue_Test {

        public static testmethod void FARevenue_Test()
        {
            List<FA_Revenue__c> FARevenueList = new List<FA_Revenue__c>();
            FARevenueTriggerHandler TriggerHandler = new FARevenueTriggerHandler();
            FA_Revenue__c fObj = new FA_Revenue__c();
            fObj.OwnerId = UserInfo.getUserId();
            fObj.Revenue_Date__c = System.today();
            fobj.Edelweiss_Employee_Id__c = '123456';
            fobj.RevenueId__c = 'ASDFCNRGHOKLWES';
            FARevenueList.add(fObj);
            insert(FARevenueList);
            FARevenueTriggerHandler.parseFARevenueData(FARevenueList);
        }
}