public class UtilityActionLighting{

  @AuraEnabled
  public static String sendEmail(String eventId){
     String url;
     List<Event> lstEvent = [SELECT Subject,Id,Description,WhatId,WhoId,Key_Deliverables_Information__c,Next_Step__c FROM Event Where Id =: eventId];
     Event eventRecord;
     if(lstEvent != null && lstEvent.size() > 0)
        eventRecord =  lstEvent[0];
    
    
    if(eventRecord != null && !string.isBlank(eventRecord.Description)){
        Id whoId = eventRecord.WhoId;
        Id whatId = eventRecord.WhatId;
        String description = eventRecord.Description;
		String Subject = eventRecord.Subject;
        String activityId = eventRecord.Id;
        Id relatedToId = eventRecord.WhatId;
        String keyDeliverable = eventRecord.Key_Deliverables_Information__c;
        String nextFollowup = eventRecord.Next_Step__c;
     
        if(!String.isBlank(whatId)){
            if(whatId.getSObjectType() == Account.sObjectType){
                Account accountObj = new Account(Id=relatedToId);
                accountObj.MinutesOfMeeting__c = description;
                accountObj.EventId__c = activityId;
                accountObj.Key_Deliverable__c = keyDeliverable;
                accountObj.Next_Follow_up__c = nextFollowup;
                AccountTriggerhandler.stopAccountTrigger = true;
                AccountTriggerhandler.stopUpdatefamily = true;
				accountObj.Event_Creation_DateTime__c = DateTime.now().getTime();  
                update accountObj;
                AccountTriggerhandler.stopAccountTrigger = false;
                
                //p6 � Subject
                //p23- Email Body
                //p24 � Additional To
                
                url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId+'&p23='+description+'&p6='+Subject;
             }
             if(whatId.getSObjectType() == Opportunity.sObjectType){
                Opportunity opportunityObj = new Opportunity(Id=relatedToId);
                opportunityObj.MinutesOfMeeting__c = description;
                opportunityObj.EventId__c = activityId;
                opportunityObj.Key_Deliverable__c = keyDeliverable;
                opportunityObj.Next_Follow_up__c = nextFollowup;
                update opportunityObj;
                url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId+'&p23='+description+'&p6='+Subject;
             }
             if(whatId.getSObjectType() == Case.sObjectType){
                Case caseObj = new Case(Id=relatedToId);
                caseObj.MinutesOfMeeting__c = description;
                caseObj.EventId__c = activityId;
                caseObj.Key_Deliverable__c = keyDeliverable;
                caseObj.Next_Follow_up__c = nextFollowup;
                update caseObj;
                url = '/_ui/core/email/author/EmailAuthor?p3_lkid='+relatedToId+'&retURL='+relatedToId+'&p23='+description+'&p6='+Subject;
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
            url = '/_ui/core/email/author/EmailAuthor?p2_lkid='+whoId+'&retURL='+whoId+'&p23='+description+'&p6='+Subject;
         }
            
        }else{
            url = 'Error';
        }
     
    return url;
  }
}