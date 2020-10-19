@isTest(SeeAllData = true)
public class ContentDocumentLinkTriggerTest  
{
    static testMethod void CreateContentDocumentLinkTrigger()
    {
        List<Product2> products = new List<Product2>();
        for(Integer i = 1; i <= 10; i++){
            Product2 p = new Product2(
                        Name = 'Test Product ' + i,
                        ProductCode = 'testprod' + i,
                        IsActive = Math.mod(i, 2) == 0 ? true : false);
            products.add(p); 
        }
        insert products;
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'Test document';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=products[0].id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;

        insert contentlink;

    }
}