@isTest
private class RejectControllerTest {
		@isTest 
    	public static void setIsRejectedTest() {        	
            List<Order_Entry__c> odList = TestDataFactory.createOrderEntry();            
            Integer flag =  RejectController.setIsRejected(odList[0].id);
             system.assertEquals(flag, 1);
        }
    
    	@isTest 
    	public static void setIsRejectedTest1() {        	
            List<Order_Entry__c> odList = TestDataFactory.createOrderEntry(); 
            odList[0].Status__c ='Rejected';
            update odList;
            Integer flag = RejectController.setIsRejected(odList[0].id);
            system.assertEquals(flag, 0);
        }    
    	@isTest 
    	public static void setIsRejectedTest2() {        	
            List<Order_Entry__c> odList = TestDataFactory.createOrderEntry(); 
            odList[0].isFundTransfered__c = true;
            update odList;
            Integer flag = RejectController.setIsRejected(odList[0].id);
            system.assertEquals(flag, 2);
        }
    	
    	@isTest 
    	public static void setIsRejectedTest3() {        	
            List<Order_Entry__c> odList = TestDataFactory.createOrderEntry(); 
            odList[0].Status__c ='Reviewed';
            update odList;
            Integer flag = RejectController.setIsRejected(odList[0].id);
            system.assertEquals(flag, -1);
        }
    	@isTest 
    	public static void checkForProfileTest() {        	
            User userObj = TestDataFactory.getUserProfile();            
            Integer flag = RejectController.checkForProfile();
             system.assertEquals(flag, 1);
        }
}