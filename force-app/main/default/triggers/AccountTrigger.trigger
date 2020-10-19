trigger AccountTrigger on Account (after insert, after update,before update, before insert) {
    system.debug('accountTriggerhandler.stopAccountTrigger============'+AccountTriggerhandler.stopAccountTrigger);
    
    if((Trigger.isUpdate ) && Trigger.isAfter && !AccountTriggerhandler.stopAccountTrigger){
        AccountTriggerhandler.changeStatusToR4(Trigger.new);
        //AccountTriggerhandler.changeStatusToR5(Trigger.new);
        //AccountTriggerhandler.setDueDates(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
    }
    if(Trigger.isUpdate && Trigger.isAfter && !AccountTriggerhandler.stopUpdatefamily){
        //AccountTriggerhandler.upadateClientAssetCount(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
        AccountTriggerhandler.upadateInvestibleAsset(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
        AccountTriggerhandler.updateFamilyHead(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
    }
    if(Trigger.isInsert && Trigger.isAfter && !AccountTriggerhandler.stopUpdatefamily){
       // AccountTriggerhandler.upadateClientAssetCount(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
        AccountTriggerhandler.upadateInvestibleAsset(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
        AccountTriggerhandler.updateFamilyHead(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
    }
    if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter && !AccountTriggerhandler.stopSharingRules){
        AccountTriggerhandler.shareAccountWithCXO(Trigger.new,Trigger.oldMap,Trigger.isUpdate);
        AccountTriggerhandler.shareWithReferar(Trigger.new,Trigger.oldMap);
    
    }
    //Update cetegory depend on lead category 
    if((Trigger.isUpdate || Trigger.isInsert ) && Trigger.isBefore && !AccountTriggerhandler.stopupdateOwnerLeadDataBase){              
        AccountTriggerhandler.updateCriteria(Trigger.new);
        AccountTriggerhandler.updateLeadDataBaseQueueToR0(trigger.New,trigger.oldMap);
        if(Trigger.isInsert)
            AccountTriggerHandler.updateIPSFilledDateOnAccount(Trigger.new);
        if(!AccountTriggerhandler.stopupdateOwnerLeadDataBase)
            AccountTriggerhandler.updateOwnerLeadDataBase(trigger.New,trigger.oldMap);
    
    }   
    
    if(Trigger.isInsert && Trigger.isBefore){
        AccountTriggerhandler.updateLeadDataBaseQueue(trigger.New);
    }
	if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        AccountTriggerhandler.copyFields(trigger.New);
    }
    
    if((Trigger.isUpdate || Trigger.isInsert ) && Trigger.isAfter){
        AccountTriggerhandler.updateSharingRuleForLDBQ(trigger.New,trigger.oldMap); 
        AccountTriggerhandler.updateSharingRuleForLeadDataBaseQueueToR0(trigger.New,trigger.oldMap);        
     }
     
     
     //VANDANA  Sync updates on Client to Contact
     
   if(Trigger.isUpdate && Trigger.isAfter && !AccountTriggerhandler.stopAccountTrigger) {      
      if(EdelweissUtils.runOnce()){
            AccountTriggerHandler.updateContact(trigger.new, trigger.oldMap);  
         }     
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        AccountTriggerHandler.addExtensionDays(Trigger.NewMap, Trigger.OldMap);
    }
	if(Trigger.isUpdate && Trigger.isAfter){
        AccountTriggerHandler.rollupCreditEligibility(Trigger.New, Trigger.OldMap);
        AccountTriggerHandler.riskProfileHistory(Trigger.New, Trigger.OldMap);
    }
}