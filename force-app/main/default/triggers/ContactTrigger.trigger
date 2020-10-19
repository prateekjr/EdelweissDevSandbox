trigger ContactTrigger on Contact (after update, after insert)  {

 //Sync updates on Contact to Client
    
    if(Trigger.isUpdate  && Trigger.isAfter) {      
      //if(EdelweissUtils.runOnce()){
            ContactTriggerHandler.updateAccount(trigger.new, trigger.oldMap);  
         //}     
    }
}