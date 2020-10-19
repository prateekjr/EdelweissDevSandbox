global class UtilityAction{
  webservice static String sendEmail(Id whoId,Id whatId,String description,String activityId,Id relatedToId,String keyDeliverable,String nextFollowup ){
     String url;
     system.debug('whatId==='+whatId);
     system.debug('whoId==='+whoId);
     
     if(!String.isBlank(whatId)){
     	if(whatId.getSObjectType() == Account.sObjectType){
	        Account accountObj = new Account(Id=relatedToId);
	        accountObj.MinutesOfMeeting__c = description;
	        accountObj.EventId__c = activityId;
	        accountObj.Key_Deliverable__c = keyDeliverable;
	        accountObj.Next_Follow_up__c = nextFollowup;
	        AccountTriggerhandler.stopAccountTrigger = true;
	        AccountTriggerhandler.stopUpdatefamily = true;
	        update accountObj;
	        AccountTriggerhandler.stopAccountTrigger = false;
	        url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId;
	     }
	     if(whatId.getSObjectType() == Opportunity.sObjectType){
	        Opportunity opportunityObj = new Opportunity(Id=relatedToId);
	        opportunityObj.MinutesOfMeeting__c = description;
	        opportunityObj.EventId__c = activityId;
	        opportunityObj.Key_Deliverable__c = keyDeliverable;
	        opportunityObj.Next_Follow_up__c = nextFollowup;
	        update opportunityObj;
	        url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId;
	     }
	     if(whatId.getSObjectType() == Case.sObjectType){
	        Case caseObj = new Case(Id=relatedToId);
	        caseObj.MinutesOfMeeting__c = description;
	        caseObj.EventId__c = activityId;
	        caseObj.Key_Deliverable__c = keyDeliverable;
	        caseObj.Next_Follow_up__c = nextFollowup;
	        update caseObj;
	        url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId;
	     }
     }
     if(!String.isBlank(whoId) && whoId.getSObjectType() == Lead.sObjectType){
        Lead leadObj = new Lead(Id=whoId);
        leadObj.MinutesOfMeeting__c = description;
        leadObj.EventId__c = activityId;
        leadObj.Key_Deliverable__c = keyDeliverable;
        leadObj.Next_Follow_up__c = nextFollowup;
        leadTriggerHandler.stopLeadTrigger = true;
        update leadObj;
        url = '/_ui/core/email/author/EmailAuthor?p2_lkid='+whoId+'&retURL='+whoId;
     }
     return url;
  }
    
    global static void updateSegmentAnalysisDueDate(){
        
        List<Account> families = [SELECT Name, Coverage__c, Segment_Analysis_Due_Date__c FROM Account WHERE RecordType.DeveloperName = 'Family' AND Coverage__c != NULL AND Segment_Analysis_Due_Date__c = NULL Limit 1000];
        List<Account> updatedFamilies = new List<Account>();
        Date d = Date.today();
        
        if(!families.isEmpty()){
            for(Account family : families){                
				if(family.Coverage__c == 'R3')
                    family.Segment_Analysis_Due_Date__c = d.addYears(2);
                else if(family.Coverage__c == 'R4' || family.Coverage__c == 'R5')
                    family.Segment_Analysis_Due_Date__c = d.addYears(1);
                
                
                updatedFamilies.add(family);
        	}
        	AccountTriggerhandler.stopAccountTrigger = true;
            AccountTriggerhandler.stopUpdatefamily = true;
            AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
            Database.SaveResult[] srList = Database.update(updatedFamilies, false);
            
        	for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
            //        System.debug('Updated Account: ' + sr.getId());
                }else{
                    for(Database.Error err: sr.getErrors()){
                        System.debug('Error occurred: ' + err.getMessage());
            //            System.debug('Account fields that caused this error: ' + err.getFields());
                    }
                }
            }
            /*
            families = [SELECT Name, Coverage__c, Segment_Analysis_Due_Date__c FROM Account WHERE RecordType.DeveloperName = 'Family'];
            for(Account family : families){
                System.debug('Name: ' + family.Name + ' Coverage: ' + family.Coverage__c + ' Seg Analysis Due Date: ' + family.Segment_Analysis_Due_Date__c);
            }
			*/
        }
	}
}