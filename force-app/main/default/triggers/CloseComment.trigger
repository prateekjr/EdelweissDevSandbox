trigger CloseComment on CaseComment(after insert) 
{
    Set<Id> parentCase=new Set<Id>();
    Map<Id,Case> mapCase=new Map<Id,Case>();
    for (CaseComment t: Trigger.new)
    {
       parentCase.add(t.ParentId);
    }
    System.debug('Parent Id ::::'+parentCase);
    List<Case> lstCase =[Select Id,Status,owner.Name,ownerId,Owner_Change_Reason__c,Type,RecordTypeId from Case where Id in : parentCase];
    List<User> userList = [Select manager.Name,manager.Id from User where id =: lstCase[0].ownerId];
    
    System.debug('Case List Needs to be update ::::'+lstCase);
    System.debug('User List ::::'+userList);
    List<Case> caseUpdateList = new List<Case>();
    for(case c :lstCase)
    {
        mapCase.put(c.Id,c);
    }
    Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
    List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
    Map<String,Id> mapofCaseRecordTypeNameId = new Map<String,Id>();
    for(Schema.RecordTypeInfo info : recordTypeInfo)
    {
        mapofCaseRecordTypeNameId.put(info.getName(),info.getRecordTypeId());
    }
    
    for (CaseComment t: Trigger.new)
    {
        if(mapCase.containskey(t.ParentId))
        {
            if(mapCase.get(t.ParentId).Status=='Closed – Success' && mapCase.get(t.ParentId).Type == 'NPS' && mapCase.get(t.ParentId).RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {
                for(Case c: lstCase)
                {
                    c.Status ='In Progress';
                    c.OwnerId = userList[0].manager.Id;
                    c.Owner_Change_Reason__c = 'NPS case close by FA.';
                    caseUpdateList.add(c);
                }
                System.debug('Case New Value ::::'+caseUpdateList);
            }
             if(mapCase.get(t.ParentId).Status=='Closed – Rejected'  && mapCase.get(t.ParentId).Type == 'NPS' && mapCase.get(t.ParentId).RecordTypeId == mapofCaseRecordTypeNameId.get(EdelweissConstants.SERVICE_REQUEST))
            {
                for(Case c: lstCase)
                {
                    c.Status ='In Progress';
                    caseUpdateList.add(c);
                }
            }
        }
    }
    if(caseUpdateList.size() > 0)
    {
        upsert caseUpdateList;
    }
}