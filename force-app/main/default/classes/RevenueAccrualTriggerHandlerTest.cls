@isTest
public class RevenueAccrualTriggerHandlerTest {
 public static testmethod void revenueAccrualInsertTest()
        {
            List<Revenue_Accrual__c> insertList = new List<Revenue_Accrual__c>();
            Revenue_Accrual__c fObj = new Revenue_Accrual__c();
            fObj.OwnerId = UserInfo.getUserId();
            fObj.Order_Transaction_Commitment_Date__c=System.today();
            insertList.add(fObj);
            insert(insertList);
           
        }
}