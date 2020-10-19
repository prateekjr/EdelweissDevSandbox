@isTest
public class SubmitForReviewedControllerTest {

    @isTest 
    	public static void setIsRejectedTest() {        	
            List<Order_Entry__c> odList = TestDataFactoryNew.createOrderEntry();            
            RejectController.setIsRejected(odList[0].id);
        }
    
    /*	@isTest 
    	public static void checkforNullOrderEntry() {        	
            List<Order_Entry__c> odList = TestDataFactoryNew.createOrderEntry(); 
            odList[0].Id=null;
            Integer response= SubmitForReviewedController.setIsSubmitForReviewed(odList[0].Id);
            System.debug('response :'+response);
            system.assertEquals(response, 3);
        }    
*/
    	
    	@isTest 
    	public static void setIsSubmitForReviewed() {        	
            List<Order_Entry__c> odList = TestDataFactoryNew.createOrderEntry(); 
            odList[0].Status__c ='Preview Mode';
            odList[0].isReviewed__c =false;
            update odList;
           Integer response= SubmitForReviewedController.setIsSubmitForReviewed(odList[0].id);
            system.assertEquals(response, 2);
        }
    	@isTest 
    	public static void checkForProfileTest() {        	
            
            User userObj = TestDataFactoryNew.getUserProfile();      
            Integer flag = SubmitForReviewedController.checkForProfile();
            system.assertEquals(flag, 1);
        }
    	@isTest 
    	public static void checkForProfileOpration() {        	
            User userObj = TestDataFactoryNew.getUserProfileOperation();
            system.runAs(userObj)
            {       
                Integer flag = SubmitForReviewedController.checkForProfile();
            }
        }
    @isTest 
    	public static void checkvariables() {        	
            
            SubmitForReviewedController obj = new SubmitForReviewedController();
            obj.xmlstring='test';
        }
}