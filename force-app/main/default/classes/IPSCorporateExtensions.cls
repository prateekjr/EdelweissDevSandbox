public with sharing class IPSCorporateExtensions {

    // Get client Id from URL parameter
   // String clientId {get; set;}
    //Account object to hold Client's values (i.e. Client Name, owner)
    public Account accountObj {get; set;}
    
    private ApexPages.StandardController stdController;
    public Investment_Policy_Statement_IPS__c ObjIps{get;set;}
     public id IpsId = ApexPages.currentPage().getParameters().get('Id');
    public Id AccountId = ApexPages.currentPage().getParameters().get('parentId');
   
    public IPSCorporateExtensions(ApexPages.StandardController controller) {
     //   clientId = ApexPages.currentPage().getParameters().get('parentId');
     
      
              
            
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
                } catch (QueryException e){
                        //perform exception handling
                }  
                stdController = controller;//new ApexPages.StandardController(ObjIps);     
            }
            else{
                this.stdController = controller;
            }
            if(accountId!=null)
            {
                accountObj = [SELECT name,owner.name FROM Account where ID =:accountId];
            }
            else
            {
                
                accountObj = [SELECT name,owner.name FROM Account where ID =:ObjIps.client_name__c];
                accountId=ObjIps.client_name__c;
            }
            
    }
    public PageReference Save()
    {
    /*if block to insert Record 
    else block to update record*/
    
    if(stdController.getId()==null)
    {
        ObjIps=(Investment_Policy_Statement_IPS__c)stdController.getRecord();
        ObjIps.Client_Name__c = accountObj.id;
        RecordType RT =[select id from RecordType where Name='Corporate'];
        ObjIps.RecordTypeId = RT.id;
        try
        {
           insert ObjIps;
           

        }
        catch(DmlException ex){

            ApexPages.addMessages(ex);
            return null;
           }

        
    }
    else
    {
        ObjIps=(Investment_Policy_Statement_IPS__c)stdController.getRecord();
        
        try
        {
           update ObjIps;
           

        }
        catch(DmlException ex){

            ApexPages.addMessages(ex);
            return null;
           }

    /*System.debug('ObjIps='+ObjIps);
     try
        {
           stdController.save();
           

        }
        catch(DmlException ex){
                        ApexPages.addMessages(ex);
            return null;

          }*/
          
        
    }
   PageReference reRend = new PageReference('/Apex/IPSCorporateDetail?Id='+ObjIps.id);
        return reRend;
        
    }
    /*public PageReference Print() {

    //return this.controller.save();
   
   
    PageReference reRend = new PageReference('/Apex/IPSCorporatePDF?Id='+ObjIps.id);
        return reRend;
    

    }*/
    public PageReference cancel()
    {
        /*PageReference cancel = controller.cancel();
        
        return cancel;*/
        PageReference reRend = new PageReference('/'+accountId );
        return reRend;
    }
    public PageReference editIps()
    {
        /*PageReference cancel = controller.cancel();
        
        return cancel;*/
        PageReference reRend = new PageReference('/apex/IPSCorporate?id='+ObjIps.id);
        return reRend;
    }

    
    
    

}