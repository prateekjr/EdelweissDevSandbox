public class IndividualIPSController{

    
     private ApexPages.StandardController controller;
     
        
   //Liabilities__c Liability{set;get;} 
 
  
    public Integer tat{set;get;}
    public Account Acc{get;set;}
    Public Investment_Policy_Statement_IPS__c ObjIps{set;get;}
    public Id AccountId = ApexPages.currentPage().getParameters().get('parentId');
    public id IpsId = ApexPages.currentPage().getParameters().get('Id');
    public List<liabilities__c> LstLiabilities {get;set;}
     public List<Insurance__c> LstInsurance {get;set;}
       public IndividualIPSController(ApexPages.StandardController controller) {
        this.controller = controller;
        //Liability= new Liabilities__c();
        System.debug('IPsId='+IpsId);
        if(IpsId !=null)
        {
        String objectName = 'Investment_Policy_Statement_IPS__c';  // modify as needed
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName ).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
        
        
        // Strip off the last comma if it exists.
        //if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-2);
        //}
        System.debug('Query=='+query);
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id = \''+IpsId+'\''; // modify as needed
         
        try {
                ObjIps = database.query(query);
                Id IPSid=ObjIps.id;
        
        lstLiabilities = Database.query('SELECT Bank_Institution_Name__c,EMI_Date__c,EMI_INR__c,End_Date__c,Id,Name,Outstanding_Loan_INR__c,OwnerId,Rate_of_Interest__c,Start_Date__c,Type_of_Loan__c FROM Liabilities__c where Investment_Policy_Statement_IPS__c =:IPSid');
        LstInsurance = Database.query('SELECT Id,Insurance_Type__c,Insurer__c,Investment_Policy_Statement_IPS__c,Name,OwnerId,Policy_Name__c,Policy_Type__c,Premium__c,Sum_Assured__c,Term__c FROM Insurance__c where Investment_Policy_Statement_IPS__c=:IPSid');
        } catch (QueryException e){
                //perform exception handling
        }        
        }
        else
        {
            ObjIps = new Investment_Policy_Statement_IPS__c();
        }
        System.debug('AccountId ='+AccountId );
        if(AccountId !=null)
            Acc= [SELECT Name, Date_of_Birth__c,nationality__c,Investible_Assets__c,Type__c,Primary_FA__r.Name FROM Account WHERE id= :AccountId ];
        else
        {
            AccountId = ObjIps.client_name__c;
            Acc= [SELECT Name, Date_of_Birth__c,nationality__c,Investible_Assets__c,Type__c,Primary_FA__r.Name FROM Account WHERE id= :AccountId ];
        }
        

    }
    public Account getAcc()
    {
         Acc= [SELECT Name, Date_of_Birth__c FROM Account WHERE id= :AccountId ];
           return Acc;
    }
    public IndividualIPSController() {
        if(IpsId !=null)
        {
        String objectName = 'Investment_Policy_Statement_IPS__c';  // modify as needed
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName ).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
        
        
        // Strip off the last comma if it exists.
        //if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-2);
        //}
        System.debug('Query=='+query);
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id = \''+IpsId+'\''; // modify as needed
         
        try {
                ObjIps = database.query(query);
                Id IPSid=ObjIps.id;
        
       lstLiabilities = Database.query('SELECT Bank_Institution_Name__c,EMI_Date__c,EMI_INR__c,End_Date__c,Id,Name,Outstanding_Loan_INR__c,OwnerId,Rate_of_Interest__c,Start_Date__c,Type_of_Loan__c FROM Liabilities__c where Investment_Policy_Statement_IPS__c =:IPSid');
        LstInsurance = Database.query('SELECT Id,Insurance_Type__c,Insurer__c,Investment_Policy_Statement_IPS__c,Name,OwnerId,Policy_Name__c,Policy_Type__c,Premium__c,Sum_Assured__c,Term__c FROM Insurance__c where Investment_Policy_Statement_IPS__c=:IPSid');
       } catch (QueryException e){
                //perform exception handling
        }        
        }
        else
        {
            ObjIps = new Investment_Policy_Statement_IPS__c();
        }
        System.debug('AccountId ='+AccountId );
        if(AccountId !=null)
            Acc= [SELECT Name, Date_of_Birth__c,nationality__c,Investible_Assets__c,Type__c,Primary_FA__r.Name FROM Account WHERE id= :AccountId ];
        else
        {
            AccountId = ObjIps.client_name__c;
            Acc= [SELECT Name, Date_of_Birth__c,nationality__c,Investible_Assets__c,Type__c,Primary_FA__r.Name FROM Account WHERE id= :AccountId ];
        }
        
        




            }
   public PageReference saveRecord() {

    //return this.controller.save();
    System.debug('ObjIps.Client_Name__c=='+ObjIps.Client_Name__c);
    if(ObjIps.Client_Name__c==null)
    {
        ObjIps.Client_Name__c = Acc.id;
        System.debug('ObjIps='+ObjIPs);
        RecordType RT =[select id from RecordType where Name='Individual'];
        ObjIps.RecordTypeId = RT.id;
        try
        {
           insert ObjIps;
           

        }
        catch(DmlException ex){
            ObjIps.Client_Name__c = null;
            ApexPages.addMessages(ex);
            return null;
           }
    }
    else
    {
        try
        {
           update ObjIps;
           

        }
        catch(DmlException ex){

            ApexPages.addMessages(ex);
            return null;
           }
    }
    
    PageReference reRend = new PageReference('/Apex/IPSIndividualDetail?Id='+ObjIps.id);
        return reRend;
    

}
 public PageReference viewAsPdf() {

    //return this.controller.save();
    //String Query ='SELECT Bank_Institution_Name__c,CreatedById,CreatedDate,EMI_Date__c,EMI_INR__c,End_Date__c,Id,Investment_Policy_Statement_IPS__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Outstanding_Loan_INR__c,OwnerId,Rate_of_Interest__c,Start_Date__c,SystemModstamp,Type_of_Loan__c FROM Liabilities__c where Investment_Policy_Statement_IPS__c ='+ObjIps.id;
    PageReference reRend = new PageReference('/Apex/testPrint?Id='+ObjIps.id);
        return reRend;
    

}
 
public PageReference EditRecord() {

    //return this.controller.save();
   
    PageReference reRend = new PageReference('/Apex/IPS_Individual?Id='+ObjIps.id);
        return reRend;
    

}
public PageReference cancel()
{
    /*PageReference cancel = controller.cancel();
    
    return cancel;*/
    PageReference reRend = new PageReference('/'+AccountId );
    return reRend;
}


    
    /*public void save(){
        PageReference detailPage = controller.save();
        
    }*/
}