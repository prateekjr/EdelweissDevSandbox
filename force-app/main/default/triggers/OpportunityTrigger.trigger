trigger OpportunityTrigger on Opportunity (before insert, after Insert, before Update) { 
 if(Trigger.isInsert && Trigger.isBefore){
 List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
 if(!stdPBL.isEmpty()){
  for(Opportunity o: Trigger.new)
   o.PriceBook2Id = stdPBL[0].id;
  }
 }
 if(Trigger.isInsert && Trigger.isAfter)
      OpprtunityTriggerHandler.linkProductLineWithOpportunity(Trigger.new);
  
  //if(Trigger.isUpdate && Trigger.isBefore)
      //OpprtunityTriggerHandler.opportunityValidation(Trigger.new);
}