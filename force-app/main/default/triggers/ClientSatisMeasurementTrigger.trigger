trigger ClientSatisMeasurementTrigger on Client_Satisfaction_Measurement__c (before insert, before update,after insert,after update) 
{
    if(Trigger.IsBefore)
    {
        // Assign NPS picklist value 
        ClientSatisMeasurementTrigger_Helper.updateNPSValue(Trigger.New);
    }
    if(Trigger.IsBefore && Trigger.IsInsert) {
        ClientSatisMeasurementTrigger_Helper.updateFamilyHead(Trigger.New);
        ClientSatisMeasurementTrigger_Helper.updatePrimaryFaForAllRecords(Trigger.New);	
        ClientSatisMeasurementTrigger_Helper.updateNPSEmailUser(Trigger.New);	
    }   
    if(Trigger.isInsert && Trigger.isAfter)
    {
       if(ClientSatisMeasurementTrigger_Helper.Flag = true){
           ClientSatisMeasurementTrigger_Helper.Flag = false;
			ClientSatisMeasurementTrigger_Helper.createCaseOnClientSatisfaction(Trigger.New);
       }
        
    }
    if((trigger.isInsert || trigger.isUpdate )&& trigger.isAfter)
    {
        ClientSatisMeasurementTrigger_Helper.createNPSYTDOnAccount(Trigger.New);
    }
    
   /* if(Trigger.isInsert && Trigger.isAfter)
    {
        ClientSatisMeasurementTrigger_Helper.createRollUpDataFromFA_TL_RHOnClientSatisfaction(Trigger.New);
    }*/
    
}