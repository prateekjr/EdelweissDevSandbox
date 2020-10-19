global class InsertCorporateActions implements Database.Batchable<sObject> , Database.Stateful{
    global String query;
    global boolean sendNotifictionFlag = false;
    global boolean addQueueMembersFlag = false;
    global static set<GroupMember> groupMemberList =  new set<GroupMember>();
    
    global InsertCorporateActions(){
        query = 'SELECT id , Owner.id , Account_Code__c, Account_Name__c , Amount__c , Cashtype__c , Client_Code__c , Client_Name__c , CorpActionType__c ,Family_Code__c , Family_Name__c , Received_Date__c , Scrip_Code__c , Scrip_Name__c FROM Corporate_Action_Staging_Container__c';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bcMain) 
    {
        return Database.getQueryLocator(query);
    }
    // This function is used to insert Corporate_Action__c based on data provided at Corporate_Action_Staging_Container__c.
    // Field Mapping and Insertion of data to corporate action.
    global void execute(Database.BatchableContext bcMain, List<Corporate_Action_Staging_Container__c> listOfDataToInsert){
       	User objDefaultUser = [SELECT Id, Name FROM User WHERE Name='PWM SalesForceUpdate'];
         
        set<String> productIds = new set<String>();
        set<String> clientIds = new set<String>();
        set<String> familyIds = new set<String>();
        set<String> clientAccountIds = new set<String>();
        
        for(Corporate_Action_Staging_Container__c cascObj : listOfDataToInsert){
            productIds.add(cascObj.Scrip_Code__c);
            clientIds.add(cascObj.Client_Code__c);
            familyIds.add(cascObj.Family_Code__c);
            clientAccountIds.add(cascObj.Account_Code__c);
        }
         
        Map<Id, product2> productList = new Map<Id, product2>([SELECT id , ProductCode FROM product2 WHERE ProductCode=:productIds]);
        Map<Id, Account> accountList = new Map<Id, Account>([SELECT id , Owner.id , GWM_Online_Id__c,RecordType.Name FROM account where GWM_Online_Id__c=:clientIds AND  RecordType.Name = 'Client']);
        Map<Id, Account> FamilyList = new Map<Id, Account>([SELECT id , Owner.id , GWM_Online_Id__c,RecordType.Name FROM account where GWM_Online_Id__c=:familyIds AND  RecordType.Name = 'Family']);
		Map<Id, Client_Account__c> ClientAccountList = new Map<Id, Client_Account__c>([SELECT id , GWM_Client_Account_Id__c FROM Client_Account__c where GWM_Client_Account_Id__c=:clientAccountIds]);

        Map<String , Account> mapOfFamily = new Map<String , Account>();
        for(Account accObj : FamilyList.values()){
                mapOfFamily.put(accObj.GWM_Online_Id__c, accObj);
        }
        Map<String , Account> mapOfClient = new Map<String , Account>();
        For(Account accObj : accountList.values()){
                mapOfClient.put(accObj.GWM_Online_Id__c , accObj);
        }
        Map<String, Client_Account__c> mapOfGwmCodeAndClientAccount = new Map<String, Client_Account__c>();
        for(Client_Account__c cObj : ClientAccountList.values()){
            mapOfGwmCodeAndClientAccount.put(cObj.GWM_Client_Account_Id__c, cObj);
        }
        Map<String, product2> mapOfProductCodeAndProduct = new Map<String, product2>();
        for(product2 pObj : productList.values()){
            mapOfProductCodeAndProduct.put(pObj.ProductCode, pObj);
        }       
        
        if(listOfDataToInsert !=null && !listOfDataToInsert.isEmpty()){
            List<Corporate_Action__c> listOfCorporateActions = new List<Corporate_Action__c>();
            
            for(Corporate_Action_Staging_Container__c cObj : listOfDataToInsert){
                Corporate_Action__c caObj = new Corporate_Action__c();
                
                if(cObj.Account_Code__c != null){
                    caObj.Account_Code__c = cObj.Account_Code__c;    
                }
                if(cObj.Amount__c != null){
                    caObj.Amount__c = cObj.Amount__c;    
                }
                if(cObj.Cashtype__c != null){
                    caObj.Cashtype__c = cObj.Cashtype__c;    
                }
                if(cObj.Client_Code__c != null){
                    caObj.Client_Code__c = cObj.Client_Code__c;    
                    Account accObj = mapOfClient.get(cObj.Client_Code__c);
                    if(accObj != null){
                        caObj.Client__c = accObj.Id;
                        if(accObj.Owner.id !=null){
                            caObj.OwnerId = accObj.Owner.id;
							caObj.Corporate_Action_Owner__c = accObj.Owner.id;                           
                        }else{
                           caObj.OwnerId = objDefaultUser.id; 
                        }
                    }else{
                           caObj.OwnerId = objDefaultUser.id; 
                        }
                }else{
                    caObj.OwnerId = objDefaultUser.id; 
                }
                if(cObj.Family_Code__c != null){
                    caObj.Family_Code__c = cObj.Family_Code__c;
                    Account accObj = mapOfFamily.get(cObj.Family_Code__c);
                    if(accObj!=null){
                        caObj.Family__c = accObj.Id;
                    }
                }
             
                if(cObj.Client_Name__c != null){
                    caObj.Client_Name__c = cObj.Client_Name__c;    
                }
                if(cObj.CorpActionType__c != null){
                    caObj.CorpActionType__c = cObj.CorpActionType__c;    
                }
                if(cObj.Received_Date__c != null){
                    caObj.Received_Date__c = cObj.Received_Date__c;    
                }
                if(cObj.Scrip_Code__c != null){
                    caObj.Scrip_Code__c = cObj.Scrip_Code__c; 
                    product2 pObj = mapOfProductCodeAndProduct.get(cObj.Scrip_Code__c);
                    if(pObj !=null){
                        caObj.Product__c = pObj.id;
                    }
                }
                if(cObj.Scrip_Name__c != null){
                    caObj.Scrip_Name__c = cObj.Scrip_Name__c;    
                }
                if(cObj.Family_Name__c != null){
                    caObj.Family_Name__c = cObj.Family_Name__c;
                }
                if(cObj.Account_Code__c != null){
                    caObj.Account_Code__c = cObj.Account_Code__c;
                    Client_Account__c clientAccountObj = mapOfGwmCodeAndClientAccount.get(cObj.Account_Code__c);
                    if(clientAccountObj != null){
                        caObj.Client_Account__c = clientAccountObj.Id;
                    }
                }
                if(cObj.Account_Name__c != null){
                    caObj.Account_Name__c = cObj.Account_Name__c;
                }
                listOfCorporateActions.add(caObj);            
            }
            
            Database.SaveResult[]  resultList = Database.insert(listOfCorporateActions, false);
            for(Database.SaveResult  result: resultList){
                if(result.isSuccess()){
                    addQueueMembersFlag = true;
                }
            } 
        } 
    }
    // This Function is used to add owners of Corporate_Action__c records as members of Mobile Notification queue.
    // and members of these queue will receive the notification.
    global void finish(Database.BatchableContext bcMain) 
    {
        if(addQueueMembersFlag){
            Id groupObj = [SELECT Id FROM Group WHERE Name =:EdelweissConstants.MOBILE_NOTIFICATION].Id;
            List<Corporate_Action__c> listOfCactions = [SELECT id , Owner.id,Corporate_Action_Owner__c FROM Corporate_Action__c];
            for(Corporate_Action__c dObj : listOfCactions){
                GroupMember gm = new GroupMember();
                gm.GroupId = groupObj;
                gm.UserOrGroupId = dObj.Corporate_Action_Owner__c;
                groupMemberList.add(gm);        
            }
            List<GroupMember> insertGroupMembers = new List<GroupMember>(groupMemberList);
            Database.SaveResult[]  resultList = Database.insert(insertGroupMembers, false);
            for(Database.SaveResult  result: resultList){
                if(result.isSuccess()){
                    sendNotifictionFlag = true;
                }
            }
        }  
        if(sendNotifictionFlag){
            database.executeBatch(new DeleteCorporateActionContainer(),1000);
        }
    }
    
}