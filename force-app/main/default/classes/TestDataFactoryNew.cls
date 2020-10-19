@isTest
public class TestDataFactoryNew {
    public static List<Order_Entry__c> createOrderEntry(){
        List<Order_Entry__c> oeList = new List<Order_Entry__c>();
        Order_Entry__c orderEntry = new Order_Entry__c();
        orderEntry.isReviewed__c = false;
        orderEntry.Status__c = 'Pending For Review';        
        oeList.add(orderEntry);
        insert oeList;
        return oeList;
    }
    
    public static User getUserProfile(){        
        User userObj = new User();
        List<Profile> profileObj = [Select Id from Profile Where Name = 'Client Experience Office (CXO)'];
        userObj.ProfileId = profileObj[0].Id;
        userObj.Username = 'rk50@test.com';
        userObj.LastName = 'Test Last Name';
        userObj.Email = 'Test@test.com';
        userObj.Alias ='tst';
        userObj.TimeZoneSidKey ='America/Los_Angeles';
        userObj.LocaleSidKey ='en_IN';
        userObj.EmailEncodingKey ='ISO-8859-1';
        userObj.LanguageLocaleKey ='en_US';
        insert userObj;
        return userObj;
    }
      public static User getUserProfileOperation(){        
        User userObj = new User();
        List<Profile> profileObj = [Select Id from Profile Where Name = 'Operations'];
        userObj.ProfileId = profileObj[0].Id;
        userObj.Username = 'rk50@test.com';
        userObj.LastName = 'Test Last Name';
        userObj.Email = 'Test@test.com';
        userObj.Alias ='tst';
        userObj.TimeZoneSidKey ='America/Los_Angeles';
        userObj.LocaleSidKey ='en_IN';
        userObj.EmailEncodingKey ='ISO-8859-1';
        userObj.LanguageLocaleKey ='en_US';
        insert userObj;
        return userObj;
    }
    public static List<Product2> getProduct2ListSearch(String searchKey){  
        List<Product2> prodList = new List<Product2>();
        Product2 prodObj = new Product2();
        prodObj.Name = 'Prod1';
        prodObj.ISIN__c ='ProdISIN';
        prodObj.Amc_Code__c= 'ProdAMC';
        prodObj.ProductCode = 'PR001';     
        prodList.add(prodObj);
        
        Insert prodList;
        return prodList;
               
    }
}