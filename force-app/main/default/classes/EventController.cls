public class EventController {
    @AuraEnabled
    public static Event getEvent() {
        return [select Id , Owner.FirstName from Event Limit 1];
    }
    @AuraEnabled
    public static account getAccount(Id recId) {
        return [select Id , How_Often_Does_Client_Monitor_Portfolio__c from Account where id =:recId];
    }
    
    @AuraEnabled
    public static void saveEvent(Event eventRec, String WhoIds){
        if(eventRec != null ){
            system.debug('eventRec'+eventRec); 
            system.debug('eventRec'+WhoIds);
            system.debug('eventRec.ownerId'+eventRec.OwnerId);
           // system.debug('eventRec.DescriptionNew__c'+eventRec.DescriptionNew__c);
            //eventRec.Description = eventRec.DescriptionNew__c;	
            database.insert(eventRec);
            User u = [select id , firstname from user where id=:userinfo.getuserid()];
            List<EventRelation> eventRels = new List<EventRelation>(); 
            if(WhoIds != null && WhoIds != ''){
                List<String> whoIdList = WhoIds.split(',');
                if(whoIdList != null && whoIdList.size() > 0){
                    for(String whoId : whoIdList){
                    	EventRelation rel = new EventRelation();
                        rel.EventId = eventRec.Id;
                        rel.RelationId = whoId;
                        rel.IsWhat = true;
                        rel.IsParent = true;
                        eventRels.add(rel);
                	}
                }                
                if(eventRels != null && eventRels.size() > 0){
                    database.insert(eventRels);
                }                
            }  
            if(eventRec.Is_Requested_Tochange_Portfolio_Review__c == 'Yes' && eventRec.How_Often_Does_Client_Monitor_Portfolio__c != ''){
                Account acc = getAccount(eventRec.WhatId);
                acc.How_Often_Does_Client_Monitor_Portfolio__c = eventRec.How_Often_Does_Client_Monitor_Portfolio__c;
                database.update(acc);
                System.debug('## Account updation'+acc);
            }
        }        	
    }
}