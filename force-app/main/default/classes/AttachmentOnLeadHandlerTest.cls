@isTest(seeAlldata=true)
public class AttachmentOnLeadHandlerTest {
    

    public  testmethod static void chkProposalTest(){
        
        //Testclassutils.InsertSysProperties();
        
        List<Attachment> attach=new List<Attachment>();
        
      
        List<Lead> llist=TestCLassutils.createLead();
        
        Lead l1=llist[0];
        l1.LastName='rajmane';
        l1.Company='PSL';
        l1.Status='R0';
        insert l1;    
   
        Attachment obj=new Attachment();
        obj.ParentId=l1.Id;
        obj.Name='proposal.txt';
        obj.Body=Blob.valueOf('proposal');
        attach.add(obj);
        
        Attachment obj1=new Attachment();
        /*List<Lead> llist1=TestCLassutils.createLead();
        Lead l2=llist[0];
        l2.LastName='rajmane';
        l2.Company='PSL';
        l2.Status='R1';
        insert l2;  */  
        obj1.ParentId=l1.Id;
        obj1.Name='reply.txt';
        obj1.Body=Blob.valueOf('reply');
        attach.add(obj1);
       
        
        
        
        Opportunity o1=new Opportunity();
       // start: modified by Abhishek Rajput
        o1.StageName='Ongoing';
        // end: modified by Abhishek Rajput
        o1.Name='ABC';
        o1.CloseDate=Date.Today() ;
        insert o1;
         
        Attachment objnew=new Attachment();        
        objnew.ParentId=o1.Id;
        objnew.Name='reply.txt';
        objnew.Body=Blob.valueOf('reply');
        attach.add(objnew);
        
        
        Attachment objnew1=new Attachment();
        objnew1.ParentId=o1.Id;
        objnew1.Name='proposal.txt';
        objnew1.Body=Blob.valueOf('proposal');
        attach.add(objnew1);
     
        insert attach;
      
      
        Product2 p2=new Product2();
        p2.Name='DueDiligence';
        insert p2;
        
        Attachment atprod=new Attachment();
        atprod.ParentId=p2.Id;
        atprod.Name='DueDiligence.txt';
        atprod.Body=Blob.valueOf('proposal');
        insert atprod;
        
        
        
        
    }

}