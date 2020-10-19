trigger IPSTrigger on Investment_Policy_Statement_IPS__c (before insert,before update,after update,after insert) {
        
        //update account with mini IPS creatation 
        if((trigger.isInsert || trigger.isUpdate ) && trigger.isAfter )        
            IPSTriggerHandler.updateaccountOnIPSCreation(trigger.new);
            
        //update risk logic
        if((trigger.isInsert || trigger.isUpdate ) && trigger.isBefore  )
            IPSTriggerHandler.clientRiskCalculation(trigger.new);
            
        //update account with mini IPS creatation 
        if((trigger.isInsert || trigger.isUpdate )&& trigger.isAfter )        
            IPSTriggerHandler.updateaccountOnIPSRecord(trigger.new);
        
        //Check IPS is present or not 
        if(trigger.isInsert && trigger.isBefore)        
            IPSTriggerHandler.CheckIPSRecord(trigger.new);  
            
}