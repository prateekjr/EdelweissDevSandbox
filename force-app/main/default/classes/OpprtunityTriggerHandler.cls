public class OpprtunityTriggerHandler{
        
    public static void linkProductLineWithOpportunity(List<opportunity> lstOpp){
        //SELECT Name,Pricebook2Id,Product2Id,ProductCode FROM PricebookEntry
        List<opportunitylineitem> oppLineitems = new List<opportunitylineitem>();
        List<Id> productIds = new List<Id>(); 
        Map<Id,PricebookEntry> productMap = new MAp<Id,PricebookEntry>(); 
        for(Opportunity opp : lstOpp){
            productIds.add(opp.scrip_Name__c);
        }
        
        System.debug('productIds'+productIds);
        List<PricebookEntry> productlst = [SELECT Id, Name,Pricebook2Id,Product2Id,ProductCode, unitprice FROM PricebookEntry Where Product2Id IN: productIds];
        
        for(PricebookEntry prdt : productlst){
            productMap.put(prdt.Product2Id,prdt);
        }
        
        for(Opportunity opp : lstOpp){
            PricebookEntry priceObj = productMap.get(opp.scrip_Name__c);
            if(priceObj != null ){
                opportunitylineitem lineItemObj = new opportunitylineitem();
                lineItemObj.unitprice = priceObj.unitprice;
                lineItemObj.quantity = 1;
                lineItemObj.pricebookentryid = priceObj.id;
                lineItemObj.OpportunityId = opp.Id;
                oppLineitems.add(lineItemObj);
            }            
        }
        
        if(oppLineitems != null && oppLineitems.size() >0)
            insert oppLineitems;        
    } 

    public static void opportunityValidation(List<opportunity> lstOpp){
        //SELECT Name,Pricebook2Id,Product2Id,ProductCode FROM PricebookEntry
        List<Id> oppIds = new List<Id>(); 
        Map<Id,List<opportunitylineitem>> pricebookMap = new MAp<Id,List<opportunitylineitem>>(); 
        for(Opportunity opp : lstOpp){
            if(opp.StageName == 'Won')
                oppIds.add(opp.Id);
        }
        
        List<opportunitylineitem> lineitem = [SELECT Id,OpportunityId, Actual_AUM_Size_INR_Lakhs__c FROM opportunitylineitem Where OpportunityId IN: oppIds];
        
        for(opportunitylineitem lineObj : lineitem){
            List<opportunitylineitem> lstLineItem = new List<opportunitylineitem>();
            if(pricebookMap.get(lineObj.OpportunityId) != null){
                lstLineItem = pricebookMap.get(lineObj.OpportunityId);
                lstLineItem.add(lineObj);
                pricebookMap.put(lineObj.OpportunityId,lstLineItem);
            }else{
                lstLineItem.add(lineObj);
                pricebookMap.put(lineObj.OpportunityId,lstLineItem);
            }   
        }
        
        for(Opportunity opp : lstOpp){
            if(opp.StageName == 'Won'){
                List<opportunitylineitem> lstLineItem = pricebookMap.get(opp.Id);
                if(lstLineItem != null && lstLineItem.size() > 0){
                    for(opportunitylineitem itemObj : lstLineItem){
                        if( itemObj.Actual_AUM_Size_INR_Lakhs__c == null){
                            opp.addError('Opportunity as Closed Won should mandatorily update the Actual AuA value');
                        }
                    }
                }
            }            
        }       
    }

}