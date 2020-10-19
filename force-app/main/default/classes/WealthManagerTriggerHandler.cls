public class WealthManagerTriggerHandler{

    public static void updateLead(List<Wealth_Manager__c>wealthManagerList,Map<Id,Wealth_Manager__c>wealthManagerOldMap,Boolean isUpdate){
        List<Lead>leadList = new List<Lead>();
        Set<Id>errorLeadId = new Set<Id>();
        Map<Id,Wealth_Manager__c>WMIDObjMap = new Map<Id,Wealth_Manager__c>();
        Map<Id,List<Wealth_Manager__c>>leadIdWMMap = new Map<Id,List<Wealth_Manager__c>>();
        Set<Id> LeadIdSet = new Set<Id>();
        List<Lead>updatedLeadList = new List<Lead>();
        List<Wealth_Manager__c>WMList = new List<Wealth_Manager__c>();
        Map<Id,Double>leadIdInvestibleAssetMap = new Map<Id,Double>();
        for(Wealth_Manager__c WMObj:wealthManagerList){
            
            Wealth_Manager__c oldWMObj;
                if(isUpdate){
                    oldWMObj = wealthManagerOldMap.get(WMObj.Id);
                }else{
                    oldWMObj = WMObj;
                
                }
                if(
                    (isUpdate && 
                        (WMObj.Asset_Managed__c != oldWMObj.Asset_Managed__c
                         || WMObj.Lead__c!=oldWMObj.Lead__c
                        )
                    ) 
                    || 
                    (!isUpdate )
                    
                  ){
                    if(WMObj.Lead__c!=oldWMObj.Lead__c){
                        LeadIdSet.add(oldWMObj.Lead__c);
                        LeadIdSet.add(WMObj.Lead__c);
                    }else{
                        LeadIdSet.add(WMObj.Lead__c);
                    }
                }
            
            
        }
        if(LeadIdSet!=null && LeadIdSet.size()>0){
             WMList = [SELECT Id,Lead__c, Asset_Managed__c
                                       FROM Wealth_Manager__c
                                       WHERE 
                                       Lead__c IN:LeadIdSet
                          ];
            leadList = [SELECT Id,Asset_Allocation_Across_Wealth_Managers__c,Investible_Assets__c From Lead Where Id IN:LeadIdSet];
            system.debug('*********** WMList Size==='+WMList.size());
        }
        
        for(Lead leadObj :leadList){
            leadIdInvestibleAssetMap.put(leadObj.Id,leadObj.Investible_Assets__c);
            Id leadId = leadObj.Id;
            if(WMList !=null && WMList.size()>0){
                List<Wealth_Manager__c>tempWMList;
                Boolean WMFound = false;
                for(Wealth_Manager__c WMObj : WMList){
                    if(leadId == WMObj.Lead__c){
                        WMFound = true;
                        system.debug('WMObj.Lead__c=========='+WMObj.Lead__c);
                        if(!leadIdWMMap.isEmpty() && leadIdWMMap.containsKey(WMObj.Lead__c)){
                            tempWMList = leadIdWMMap.get(WMObj.Lead__c);
                            tempWMList.add(WMObj);
                            leadIdWMMap.put(WMObj.Lead__c,tempWMList);
                        }else{
                            tempWMList = new List<Wealth_Manager__c>();
                            tempWMList.add(WMObj);
                            leadIdWMMap.put(WMObj.Lead__c,tempWMList);
                        }
                    }
                }
                if(!WMFound){
                    Lead newLeadObj = new Lead(Id = leadId);
                    leadObj.Asset_Allocation_Across_Wealth_Managers__c = 0;
                    updatedLeadList.add(newLeadObj);
                }
            }
        }
        for(Id leadId:leadIdWMMap.keySet()){
            Lead leadObj = new Lead(Id = leadId);
            Double assetManaged = 0.0;
            for(Wealth_Manager__c WMObj: leadIdWMMap.get(leadId)){
                system.debug('WMObj==='+WMObj.Id);
                if(WMObj.Asset_Managed__c!=null){
                    assetManaged = assetManaged+WMObj.Asset_Managed__c;  
                }
                
            }
            leadObj.Asset_Allocation_Across_Wealth_Managers__c = assetManaged;
            Double InvestibleAsset = leadIdInvestibleAssetMap.get(leadObj.Id);
            if(InvestibleAsset < assetManaged){
                errorLeadId.add(leadId);
            
            }else{
                updatedLeadList.add(leadObj);
            }
            
        }
        for(Wealth_Manager__c tempWMObj:wealthManagerList){
            if(errorLeadId.contains(tempWMObj.Lead__c)){
            
                tempWMObj.addError('Asset allocation value exceeds Investible asset value for Lead');
            }
            
        }
        if(updatedLeadList!= null && updatedLeadList.size()>0){
            try{
                 update updatedLeadList;
            
            }Catch(Exception e){
            }
           
        }
    
    }
    
    public static void updateLeadonDelete(List<Wealth_Manager__c> wealthMangerList){
        Set<Id>leadIdSet = new Set<Id>();
        Map<Id,List<Wealth_Manager__c>> leadIdWealtManagerMap = new Map<Id,List<Wealth_Manager__c>>();
        List<Lead>leadList = new List<Lead>();
        List<Wealth_Manager__c> WMlist = new List<Wealth_Manager__c>();
        List<Lead>updatedLeadList = new List<Lead>();
        for(Wealth_Manager__c WelathManagerObj:wealthMangerList){
            leadIdSet.add(WelathManagerObj.Lead__c);
            if(!leadIdWealtManagerMap.isEmpty() && leadIdWealtManagerMap.containsKey(WelathManagerObj.Lead__c) ){
            
                WMlist = leadIdWealtManagerMap.get(WelathManagerObj.Lead__c);
                WMlist.add(WelathManagerObj);
                leadIdWealtManagerMap.put(WelathManagerObj.Lead__c,WMlist);
            }else{
                WMlist = new List<Wealth_Manager__c>();
                WMlist.add(WelathManagerObj);
                leadIdWealtManagerMap.put(WelathManagerObj.Lead__c,WMlist);
            }
            
            
        }
        if(leadIdSet!=null && leadIdSet.size()>0){
            leadList = [SELECT id,Asset_Allocation_Across_Wealth_Managers__c, Investible_Assets__c FROM Lead WHERE id IN:leadIdSet];
        
        }
        for(Lead leadObj:leadList){
            if(leadIdWealtManagerMap!=null && !leadIdWealtManagerMap.isEmpty() && leadIdWealtManagerMap.containsKey(leadObj.Id)){
                for(Wealth_Manager__c WMObj:leadIdWealtManagerMap.get(leadObj.Id)){
                    if(leadObj.Asset_Allocation_Across_Wealth_Managers__c!=null){
                        leadObj.Asset_Allocation_Across_Wealth_Managers__c = leadObj.Asset_Allocation_Across_Wealth_Managers__c-WMObj.Asset_Managed__c;
                    }else{
                        leadObj.Asset_Allocation_Across_Wealth_Managers__c = 0;
                    }
                                    
                }
                
                updatedLeadList.add(leadObj);
            
            }
        }
        try{
            if(updatedLeadList!=null && updatedLeadList.size()>0){
            
                update updatedLeadList;
            }
        }catch(Exception e){
        
        
        }
    
    }
     

}