public with sharing class ClientAssetInformationTriggerHandler {
    
   /* public static void updateFamilyAUM(List<Client_Asset_Information__c >clientInfoList)
    {
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Id clientRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Client');
        Map<Id,List<Client_Asset_Information__c>>familyIdClientAssetInfolistMap = new Map<Id,List<Client_Asset_Information__c>>(); 
        
        //Map<Id,List<Client_Asset_Information__c>>clientIdClientAssetInfolistMap = new Map<Id,List<Client_Asset_Information__c>>(); 
        List<Account>updatedFamilyList = new List<Account>();
        List<Client_Asset_Information__c>tempClientAssetInfoList;
        Set<Id>familyIdSet = new Set<Id>();
        //Set<Id>clientIdSet = new Set<Id>();

        Map<Id,Account>familyIdObjMap = new Map<Id,Account>();
        //Map<Id,Account>clientIdObjMap = new Map<Id,Account>();

        List<Account>familyList = new List<Account>();
        //List<Account>clientList = new List<Account>();

        for(Client_Asset_Information__c clientAssetInfo:clientInfoList)
        {
            if(familyIdClientAssetInfolistMap!=null && familyIdClientAssetInfolistMap.size()>0 && 
            familyIdClientAssetInfolistMap.containsKey(clientAssetInfo.Family__c))
            {
                tempClientAssetInfoList = familyIdClientAssetInfolistMap.get(clientAssetInfo.Family__c);
                tempClientAssetInfoList.add(clientAssetInfo);
                familyIdClientAssetInfolistMap.put(clientAssetInfo.Family__c,tempClientAssetInfoList);
            }else{
                tempClientAssetInfoList = new List<Client_Asset_Information__c>();
                tempClientAssetInfoList.add(clientAssetInfo);
                familyIdClientAssetInfolistMap.put(clientAssetInfo.Family__c,tempClientAssetInfoList);
            }
            familyIdSet.add(clientAssetInfo.Family__c);
            if(clientIdClientAssetInfolistMap!=null && clientIdClientAssetInfolistMap.size()>0 && 
            clientIdClientAssetInfolistMap.containsKey(clientAssetInfo.Client__c))
            {
                tempClientAssetInfoList = clientIdClientAssetInfolistMap.get(clientAssetInfo.Client__c);
                tempClientAssetInfoList.add(clientAssetInfo);
                clientIdClientAssetInfolistMap.put(clientAssetInfo.Client__c,tempClientAssetInfoList);
            }else{
                tempClientAssetInfoList = new List<Client_Asset_Information__c>();
                tempClientAssetInfoList.add(clientAssetInfo);
                clientIdClientAssetInfolistMap.put(clientAssetInfo.Client__c,tempClientAssetInfoList);
            }
            clientIdSet.add(clientAssetInfo.Client__c);

        }
        
        system.debug('DildarLog: familyIdClientAssetInfolistMap - '+familyIdClientAssetInfolistMap);
        system.debug('DildarLog: familyIdSet - '+familyIdSet);
        if(familyIdSet!=null && familyIdSet.size()>0){
            familyList = [SELECT Rollup_AUM_of_Family__c, RecordTypeId, Id,Asset_Classes_Client_is_Interested_in__c,Asset_Classes_Count__c  FROM Account  
                     WHERE 
                     RecordTypeId =:familyRecordTypeId 
                     AND Id IN: familyIdSet FOR UPDATE];
        
        }
       if(clientIdSet!=null && clientIdSet.size()>0){
            clientList = [SELECT product_client__c, RecordTypeId, Id,Asset_Classes_Count__c ,Asset_Classes_Client_is_Interested_in__c FROM Account  
                     WHERE 
                     RecordTypeId =:clientRecordTypeId 
                     AND Id IN: clientIdSet];
        
        }

        for(Account family:familyList){
            familyIdObjMap.put(family.Id,family);
        
        }
        for(Account Client:clientList ){
            clientIdObjMap.put(Client.Id,Client);
        
        }

        system.debug('familyIdObjMap >>'+familyIdObjMap);

        
        for(Id clientId: clientIdClientAssetInfolistMap.keySet())
        {
        Account ClientObj = new Account(Id=clientId);
            if(clientIdObjMap!=null && clientIdObjMap.size()>0 && clientIdObjMap.containsKey(clientId))
            {
                ClientObj = clientIdObjMap.get(clientId);
            }
            String tempProduct;
            if(ClientObj.Product_client__c!=null)
            {
                tempProduct=ClientObj.Product_client__c;
            }
            for(Client_Asset_Information__c clientAssetInfoObj: clientIdClientAssetInfolistMap.get(clientId)){
                if(clientAssetInfoObj.Product__c!=null)
                {
                    tempProduct= tempProduct+','+clientAssetInfoObj.Product__c;
                }
                
            }
            ClientObj.Product_client__c=tempProduct;
            updatedFamilyList.add(ClientObj);
        }
        for(Id familyId: familyIdClientAssetInfolistMap.keySet())
        {
            Account familyObj;
            
            if(familyIdObjMap!=null && !familyIdObjMap.isEmpty() && familyIdObjMap.containsKey(familyId))
            {
                familyObj = familyIdObjMap.get(familyId);
                system.debug('in if part=familyObj =='+familyObj );
            }
            else
            {
                system.debug('in else part===');
                familyObj = new Account(Id = familyId);
            }
            
            // Check is Family having Rollup AUM = 0 or not
            Double totalAUM = 0.0;
            Decimal AssetClassCOUNT = 0;
            String AssetClassList ='';
            if(familyIdObjMap.get(familyId) !=null)            
            {
                system.debug('Existing family AUM>>>>'+familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c);
                if(familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c !=null && familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c != 0 )
                {
                    totalAUM = familyIdObjMap.get(familyId).Rollup_AUM_of_Family__c ;
                    AssetClassCOUNT = familyIdObjMap.get(familyId).Asset_Classes_Count__c ;
                    AssetClassList = familyIdObjMap.get(familyId).Asset_Classes_Client_is_Interested_in__c;
                }
            }          
            
            system.debug('Total AUM of existing Family = '+totalAUM );
            system.debug(' familyIdClientAssetInfolistMap.get(familyId)>>'+familyIdClientAssetInfolistMap.get(familyId));
            Date AUMDATE;
            for(Client_Asset_Information__c clientAssetInfoObj: familyIdClientAssetInfolistMap.get(familyId)){
                
                if(clientAssetInfoObj.Total_AUM__c!=null){
                system.debug('AUM =='+totalAUM+',ClientInfoAUM='+clientAssetInfoObj.Total_AUM__c);
                    totalAUM = totalAUM+clientAssetInfoObj.Total_AUM__c;  
                    if(!AssetClassList.contains(clientAssetInfoObj.Asset_Class__c))
                    {
                        AssetClassList = AssetClassList + ';'+clientAssetInfoObj.Asset_Class__c;
                        AssetClassCOUNT =AssetClassCOUNT +1;
                    }
                    if(clientAssetInfoObj.AS_On_Date__c!=null )
                    {
                        AUMDATE =clientAssetInfoObj.AS_On_Date__c;
                    }
                }
            }
            system.debug('totalAUM for update on existing Family>>>'+totalAUM);
            familyObj.Rollup_AUM_of_Family__c = totalAUM;
            familyObj.AUM_As_on_Date_Family__c = AUMDATE;
            familyObj.Asset_Classes_Count__c = AssetClassCOUNT;
            familyObj.Asset_Classes_Client_is_Interested_in__c = AssetClassList;
            system.debug('familyObj.Rollup_AUM_of_Family__c======'+familyObj.Rollup_AUM_of_Family__c);
            system.debug('familyObj.AUM_As_on_Date_Family__c ======'+familyObj.AUM_As_on_Date_Family__c );
            if(familyObj.RecordTypeId == familyRecordTypeId)
                updatedFamilyList.add(familyObj);
        }
        for(Account FamilyObj:updatedFamilyList)
        {
            Double tempAUM = FamilyObj.Rollup_AUM_of_Family__c;
            System.debug('AUM Data before='+FamilyObj.name+'='+FamilyObj.Rollup_AUM_of_Family__c);
            tempAUM =tempAUM /10000000;
            FamilyObj.Rollup_AUM_of_Family__c = tempAUM;
            System.debug('AUM Data after='+FamilyObj.name+'='+FamilyObj.Rollup_AUM_of_Family__c);
        }
        System.debug('DildarLog: updatedFamilyList - ' + updatedFamilyList);
        System.debug('DildarLog: updatedFamilyList - ' + updatedFamilyList.size());
        if(updatedFamilyList!=null && updatedFamilyList.size()>0){
            Update updatedFamilyList;
        }
    }
    
    
    
    // function is used to set Family rollup to 0
    public static void setFamilyAUMRollupToZero(List<Client_Asset_Information__c > clientInfoList)
    {
        Id familyRecordTypeId = EdelweissConstants.AccountRecordTypeMap.get('Family');
        Set<Id>familyIdSet = new Set<Id>();
        List<Account>updatedFamilyList = new List<Account>();
        // collect Family id 
        for(Client_Asset_Information__c  objAssetInfo: clientInfoList)
        {
            if(objAssetInfo.Family__c != null || objAssetInfo.Family__c != '')
                familyIdSet.add(objAssetInfo.Family__c);  
        }
        System.debug('DildarLog: familyIdSet - ' + familyIdSet);
        for(Id familyId:familyIdSet){
            Account familyObj = new Account(Id = familyId);
            familyObj.Rollup_AUM_of_Family__c  = 0;
            if(familyObj.RecordTypeId == familyRecordTypeId)
                updatedFamilyList.add(familyObj);        
        }
        System.debug('DildarLog: updatedFamilyList - ' + updatedFamilyList);
        if(updatedFamilyList!=null && updatedFamilyList.size()>0){
            update updatedFamilyList;
        
        }
    }*/
    
    public static void rollupCreditEligibility(List<Client_Asset_Information__c > clientInfoList)
    {
        Map<Id,Client_Asset_Information__c> MapClientAsset = new Map<Id,Client_Asset_Information__c>();
        Set<Id> DeletedId = new Set<Id>();
        for(Client_Asset_Information__c asset : clientInfoList){
            MapClientAsset.put(asset.Client_Account__c,asset);
            DeletedId.add(asset.Id);
        }
        List<Client_Account__c> updateClientAccount = new List<Client_Account__c>();
        
        if(MapClientAsset != null && MapClientAsset.keySet().size() > 0){           
            List<Client_Account__c> lstClientAccount = [Select Id,Credit_Eligibility__c, (Select Id, Credit_Eligibility_AUA_LTV__c,Annual_Record__c From Client_AUM_Information__r) From Client_Account__c Where Id =:MapClientAsset.keySet()];          
            for(Client_Account__c cAsset : lstClientAccount){               
                Decimal rollupCurrency = 0;
                if(cAsset.Client_AUM_Information__r != null && cAsset.Client_AUM_Information__r.size() > 0){
                    for(Client_Asset_Information__c asset :  cAsset.Client_AUM_Information__r){
                        if(asset.Credit_Eligibility_AUA_LTV__c != null && !asset.Annual_Record__c){
                            if(Trigger.isDelete && !DeletedId.Contains(asset.Id))
                                rollupCurrency += asset.Credit_Eligibility_AUA_LTV__c;
                            else if(Trigger.isInsert)
                                rollupCurrency += asset.Credit_Eligibility_AUA_LTV__c;
                        }
                    }                   
                }
                cAsset.Credit_Eligibility__c = rollupCurrency;
                updateClientAccount.add(cAsset);
            }
            
            if(updateClientAccount != null && updateClientAccount.size() > 0)
                database.update(updateClientAccount, true);
            
        }
        
        
        
    }
}