public class TravelRequestController {
    @AuraEnabled
    public static Event getEvent() {
        return [select Id , Owner.FirstName from Event Limit 1];
    }
    @AuraEnabled
    public static account getAccount(Id recId) {
        return [select Id , How_Often_Does_Client_Monitor_Portfolio__c from Account where id =:recId];
    }
    @AuraEnabled
    public static String getObjectType(Id recId) {
        
        Schema.SObjectType stype = recId.getsobjecttype();
        Schema.DescribeSObjectResult r = stype.getDescribe();
        String objectName = r.getName();
        return objectName;
    }
    
    @AuraEnabled
    public static String getDates(Id recId) {
        return '';
    }
    
    @AuraEnabled
    public static String saveEvent(Event eventRec, String WhoIds){
        if(eventRec != null ){
            system.debug('eventRec'+eventRec); 
            system.debug('eventRec'+WhoIds);
            system.debug('eventRec.ownerId'+eventRec.OwnerId);    
            eventRec.Lead_Family__r = null;
            eventRec.Travel_Request_Lookup__r = null;
            eventRec.WhatId = eventRec.Lead_Family__c; 
           // eventRec.Description = eventRec.DescriptionNew__c;	

            if(eventRec.Travel_Request_Lookup__c != null){
                List<Travel_Request__c> tr = [SELECT From_Date__c , To_Date__c,Travel_Request_Status__c FROM Travel_Request__c WHERE id =:eventRec.Travel_Request_Lookup__c LIMIT 1];
                for(Travel_Request__c trObj : tr)	{
                    if(trObj.From_Date__c >= eventRec.StartDateTime || trObj.To_Date__c <= eventRec.EndDateTime){
                        return 'Date should always be within the Date range as of travel request';
                    }
                    if((eventRec.StartDateTime > System.today() && eventRec.Status__c == 'completed') || (eventRec.EndDateTime > System.today() && eventRec.Status__c == 'completed')){
                        return  'Activty Status can not be Completed as its future dated';
                    }
                    /*if(eventRec.Status__c == 'completed' && trObj.To_Date__c > System.today().addDays(1)){
                        return 'As the Travel Request Date is future dated, Activty Status can not be Completed';
                    }*/
                    if(eventRec.EndDateTime < System.today()){
						return 'BackDated Events are not allowed';                        
                    }
                }
            }
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
                    System.debug('eventRels '+eventRels);
                    database.insert(eventRels);
                }               
            }  
            if(eventRec.Is_Requested_Tochange_Portfolio_Review__c == 'Yes' && eventRec.How_Often_Does_Client_Monitor_Portfolio__c != ''){
                Account acc = getAccount(eventRec.WhatId);
                acc.How_Often_Does_Client_Monitor_Portfolio__c = eventRec.How_Often_Does_Client_Monitor_Portfolio__c;
                database.update(acc);
                return 'Success';	
            }
        } 
        return 'Success';
    }
    
}