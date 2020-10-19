global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
     global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = [SELECT Due_Date_Time__c FROM Case WHERE Id=:caseId];
         Long longresult= (c.Due_Date_Time__c.getTime()/1000/60) - (System.Now().getTime()/1000/60);
         System.debug('longresult :'+longresult);
         System.debug('Duw Date  :'+(c.Due_Date_Time__c.getTime()/1000/60));
         System.debug('Today Date  :'+(System.Now().getTime()/1000/60));
         Integer integerResult=(Integer)longresult;
          System.debug('integerResult Date  :'+integerResult);
          return integerResult; 
     }
}