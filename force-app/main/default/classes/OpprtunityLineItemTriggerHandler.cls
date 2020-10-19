public class OpprtunityLineItemTriggerHandler{
    /*public static void updateOpportunity(List<OpportunityLineItem>opportunityLineItemList,Map<Id,OpportunityLineItem>OpportunityLineItemOldMap,Boolean isUpdate){
        
        Map<Id,List<OpportunityLineItem>>opportunityIdOLIMap = new Map<Id,List<OpportunityLineItem>>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Opportunity>updatedOpportunityList = new List<Opportunity>();
        List<OpportunityLineItem>OLIList = new List<OpportunityLineItem>();
        for(OpportunityLineItem OLIObj:opportunityLineItemList){
            OpportunityLineItem oldOLIObj;
                if(isUpdate){
                    oldOLIObj = OpportunityLineItemOldMap.get(OLIObj.Id);
                }else{
                    oldOLIObj = OLIObj;
                
                }
                if(
                    (isUpdate && 
                        (OLIObj.TotalPrice != oldOLIObj.TotalPrice
                         || OLIObj.OpportunityId!=oldOLIObj.OpportunityId 
                         || OLIObj.Deal_Done__c!= oldOLIObj.Deal_Done__c 
                        )
                    ) 
                    || 
                    (!isUpdate )
                    
                  ){
                    if(OLIObj.OpportunityId!=oldOLIObj.OpportunityId){
                        opportunityIdSet.add(oldOLIObj.OpportunityId);
                        opportunityIdSet.add(OLIObj.OpportunityId);
                    }else{
                        opportunityIdSet.add(OLIObj.OpportunityId);
                    }
                }
            
            
        }
        
        if(opportunityIdSet!=null && opportunityIdSet.size()>0){
             OLIList = [SELECT Id,OpportunityId,Deal_Done__c, TotalPrice
                                       FROM OpportunityLineItem
                                       WHERE 
                                       OpportunityId IN:opportunityIdSet
                                       AND Deal_Done__c = true
                          ];
            system.debug('*********** OLIList Size==='+OLIList.size());
        }
        for(Id OpportunityId :opportunityIdSet){
            
                List<OpportunityLineItem>tempOLIList;
                Boolean OLIFound = false;
                for(OpportunityLineItem OLIObj : OLIList){
                    if(OpportunityId == OLIObj.OpportunityId){
                        OLIFound = true;
                        system.debug('OLIObj.OpportunityId=========='+OLIObj.OpportunityId);
                        if(!opportunityIdOLIMap.isEmpty() && opportunityIdOLIMap.containsKey(OLIObj.OpportunityId)){
                            tempOLIList = opportunityIdOLIMap.get(OLIObj.OpportunityId);
                            tempOLIList.add(OLIObj);
                            opportunityIdOLIMap.put(OLIObj.OpportunityId,tempOLIList);
                        }else{
                            tempOLIList = new List<OpportunityLineItem>();
                            tempOLIList.add(OLIObj);
                            opportunityIdOLIMap.put(OLIObj.OpportunityId,tempOLIList);
                        }
                    }
                }
                if(!OLIFound){
                    Opportunity OpportunityObj = new Opportunity(Id = OpportunityId);
                    OpportunityObj.Opportunity_Amount__c  = 0;
                    updatedOpportunityList.add(OpportunityObj);
                }
            
        }
        for(Id OpportunityId:opportunityIdOLIMap.keySet()){
            Opportunity OpportunityObj = new Opportunity(Id = OpportunityId);
            Double assetManaged = 0.0;
            for(OpportunityLineItem OLIObj: opportunityIdOLIMap.get(OpportunityId)){
                system.debug('OLIObj==='+OLIObj.Id);
                if(OLIObj.TotalPrice!=null){
                    assetManaged = assetManaged+OLIObj.TotalPrice;  
                }
            }
            OpportunityObj.Opportunity_Amount__c  = assetManaged;
            updatedOpportunityList.add(OpportunityObj);
        }
        if(updatedOpportunityList!= null && updatedOpportunityList.size()>0){
            update updatedOpportunityList;
        }
    
    }
    
    public static void updateOpportunityOnDelete(List<OpportunityLineItem > opportunityLineItemList){
        Set<Id>opportunityIdSet = new Set<Id>();
        Set<Id>errorLeadIdSet = new Set<Id>();
        Map<Id,List<OpportunityLineItem >> opportunityIdOpportunityLineItemMap = new Map<Id,List<OpportunityLineItem >>();
        List<Opportunity>opportunityList = new List<Opportunity>();
        List<OpportunityLineItem > OLIList = new List<OpportunityLineItem >();
        List<Opportunity>updatedOpportunityList = new List<Opportunity>();
        for(OpportunityLineItem opportunityLineItemListObj :opportunityLineItemList){
            opportunityIdSet.add(opportunityLineItemListObj.OpportunityId);
            if(!opportunityIdOpportunityLineItemMap.isEmpty() && opportunityIdOpportunityLineItemMap.containsKey(opportunityLineItemListObj.OpportunityId) ){
                OLIList = opportunityIdOpportunityLineItemMap.get(opportunityLineItemListObj.OpportunityId);
                OLIList.add(opportunityLineItemListObj );
                opportunityIdOpportunityLineItemMap.put(opportunityLineItemListObj.OpportunityId,OLIList);
            }else{
                OLIList= new List<OpportunityLineItem >();
                OLIList.add(opportunityLineItemListObj );
                opportunityIdOpportunityLineItemMap.put(opportunityLineItemListObj.OpportunityId,OLIList);
            }
            
            
        }
        if(opportunityIdSet !=null && opportunityIdSet.size()>0){
            opportunityList = [SELECT id,Opportunity_Amount__c,StageName FROM Opportunity WHERE id IN:opportunityIdSet];
        }
        for(Opportunity opportunityObj:opportunityList ){
            if(opportunityIdOpportunityLineItemMap!=null && !opportunityIdOpportunityLineItemMap.isEmpty() && opportunityIdOpportunityLineItemMap.containsKey(opportunityObj.Id)){
                for(OpportunityLineItem  OLIObj : opportunityIdOpportunityLineItemMap.get(opportunityObj.Id)){
                    if(OLIObj.Deal_Done__c){
                        if(opportunityObj.Opportunity_Amount__c !=null){
                        opportunityObj.Opportunity_Amount__c = opportunityObj.Opportunity_Amount__c  - OLIObj.TotalPrice;
                        }else{
                            opportunityObj.Opportunity_Amount__c = 0;
                        }
                        if(opportunityObj.StageName == 'Closed Won'){
                            errorLeadIdSet.add(opportunityObj.Id);
                            
                        }
                        updatedOpportunityList.add(opportunityObj);
                    
                    }
                }
                
                
            
            }
        }
        for(OpportunityLineItem tempOLIObj:opportunityLineItemList){
            if(errorLeadIdSet.contains(tempOLIObj.OpportunityId)){
            
                tempOLIObj.addError('As opportunity is Closed won,you cannot remove Product!');
            }
        }
        try{
            if(updatedOpportunityList!=null && updatedOpportunityList.size()>0){
            
                update updatedOpportunityList ;
            }
        }catch(Exception e){
        
        
        }
    
    }*/
    

}