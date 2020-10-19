public class LeadTriggerHandler{
    public static boolean stopLeadTrigger= false;
    public static void resetLeadFields(Map<Id,Lead> leadMap){
        List<Lead>leadList = new List<Lead>();
        
        leadList = [SELECT id,Category__c,CreatedBy.ProfileId,CreatedById,Owner.Type,OwnerId,RecordType.DeveloperName, RecordTypeId from Lead WHERE Id IN:leadMap.keySet() ];
        List<Lead>updatedLeadList = new List<Lead>();
        List<Group> queueList = [Select g.Name, g.Id, g.DeveloperName,g.Type From Group g
                     Where g.Type ='Queue' 
                     AND 
                     g.DeveloperName =: EdelweissConstants.LEAD_DATABASE_QUEUE_API_NAME Limit 1 ];
        for(Lead leadObj :leadList ){
            system.debug('Lead Owner Type=======>'+leadObj.Owner.Type+' '+leadObj.Owner+'=='+ queueList);
            if(queueList!=null && queueList.size()>0){
              if(leadObj.OwnerId == queueList[0].Id
                              && (leadObj.RecordType.DeveloperName=='Corporate_Prospect'||       
                                                leadObj.RecordType.DeveloperName=='Individual_Prospect'||
                                                leadObj.RecordType.DeveloperName=='Both_Prospect'||
                                                leadObj.RecordType.DeveloperName=='Prospect_Approved_Record_Type')){
                  Lead newleadObj= new Lead(id = leadObj.id);
                  newleadObj.Prospect_1st_Milestone_Complete__c = false;
                  newleadObj.Prospect_2nd_Milestone_Complete__c = false;
                  newleadObj.Prospect_3rd_Milestone_Complete__c = false;
                  newleadObj.ExtensionGranted__c = false;
                  newleadObj.isAssigned__c = false;
                  newleadObj.Extension_Approved_Date__c = null;
                  newleadObj.isAssignedDate__c = null;
                  newleadObj.Hot_Communication_Count__c = null;
                  newleadObj.Cold_Communication_Count__c = null;
                  newleadObj.Warm_Communication_Count__c = null;
                  newleadObj.Status = EdelweissConstants.LEAD_DATABASE_STATUS ;
                  newleadObj.Is_Meeting_Established__c = false;
                  newleadObj.Entered_Initial_Meeting_Notes_with_task__c = false;
                  newleadObj.Expiration_Date__c = null;
                   
                  if(leadObj.RecordType.DeveloperName=='Prospect_Approved_Record_Type'){
                        if(leadObj.Category__c == 'Corporate'){
                            newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect');
                        }
                        if(leadObj.Category__c == 'Individual' ){
                            newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect');
                        }
                        if(leadObj.Category__c == 'Both'){
                            newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Both_Prospect');
                        }
                  }
                  updatedLeadList .add(newleadObj);
              }
                
              if(leadObj.OwnerId == queueList[0].Id
                                && (leadObj.RecordType.DeveloperName=='Lead'||
                                                  leadObj.RecordType.DeveloperName=='Lead_Approved_Record_Type')){
                  Lead newleadObj= new Lead(id = leadObj.id);
                  newleadObj.Lead_1st_Milestone_Complete__c = false;
                  newleadObj.Lead_2nd_Milestone_Complete__c = false;
                  newleadObj.Lead_3rd_Milestone_Complete__c = false;
                  newleadObj.Lead_4th_Milestone_Complete__c = false;
                  newleadObj.Lead_5th_Milestone_Complete__c = false;                
                  newleadObj.Extension_Approved_for_45_days__c = false;
                  newleadObj.Extension_Approved_for_60_days__c = false;
                  newleadObj.Extension_Approved_for_90_days__c = false;
                  newleadObj.reallocate_Lead__c  = false;
                  newleadObj.isAssigned__c = false;
                  if(leadObj.Category__c == 'Corporate'){
                      newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect');
                  }
                  if(leadObj.Category__c == 'Individual' ){
                      newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect');
                  }
                  if(leadObj.Category__c == 'Both'){
                      newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Both_Prospect');
                  }
                  newleadObj.Status = EdelweissConstants.LEAD_DATABASE_STATUS ;                
                  newleadObj.Prospect_1st_Milestone_Complete__c = false;
                  newleadObj.Prospect_2nd_Milestone_Complete__c = false;
                  newleadObj.Prospect_3rd_Milestone_Complete__c = false;
                  newleadObj.ExtensionGranted__c = false;
                  newleadObj.isAssigned__c = false;
                  newleadObj.Extension_Approved_Date__c = null;
                  newleadObj.isAssignedDate__c = null;
                  newleadObj.Hot_Communication_Count__c = null;
                  newleadObj.Cold_Communication_Count__c = null;
                  newleadObj.Warm_Communication_Count__c = null;
                  newLeadObj.Is_Meeting_Established__c = false;
                  newLeadObj.Entered_Initial_Meeting_Notes_with_task__c = false;
                  newleadObj.Expiration_Date__c = null;
                  
                  updatedLeadList.add(newleadObj);                                 
              }
            }
            
                                                
        }
        if(updatedLeadList!=null && updatedLeadList.size()>0){
            try{
                stopLeadTrigger = true;
                update updatedLeadList;
            
            }Catch(Exception e){
            
                system.debug('Updation fail and exception is:::'+e);
            }
        
        } 
        
        
        
    }
    public static void reallocateLead(List<Lead>newLeadList,Map<Id,Lead> leadOldMap){
    System.debug('Inside function');
        Boolean isLD = false;
        List<Lead> updatedLeadList = new List<Lead>();
        List<Lead> reallocatedLeadList = new List<Lead>();
        List<Profile> faProfileList = [SELECT p.Name, p.Id FROM Profile p WHERE p.Name =: EdelweissConstants.FAProfileName limit 1];
        List<Lead> leadList = [SELECT id,reallocate_Lead__c,CreatedBy.ProfileId,
                               Category__c,CreatedById
                               FROM Lead 
                               WHERE 
                                 id IN:leadOldMap.keySet() 
                               ];
        List<Owner_Assignment_History__c> ownerChangeHitoryList = new List<Owner_Assignment_History__c>();                                
        for(Lead leadObj:leadList){
            Lead oldLeadObj = leadOldMap.get(leadObj.Id);
            System.debug('reallocate_Lead__c =='+leadObj.reallocate_Lead__c+','+oldLeadObj.reallocate_Lead__c);
            if(leadObj.reallocate_Lead__c != oldLeadObj.reallocate_Lead__c  ){
                Lead newleadObj= new Lead(id = leadObj.id);
                newleadObj.Lead_1st_Milestone_Complete__c = false;
                newleadObj.Lead_2nd_Milestone_Complete__c = false;
                newleadObj.Lead_3rd_Milestone_Complete__c = false;
                newleadObj.Lead_4th_Milestone_Complete__c = false;
                newleadObj.Lead_5th_Milestone_Complete__c = false;                
                newleadObj.Extension_Approved_for_45_days__c = false;
                newleadObj.Extension_Approved_for_60_days__c = false;
                newleadObj.Extension_Approved_for_90_days__c = false;
                newleadObj.reallocate_Lead__c  = false;
                newleadObj.isAssigned__c = false;
                newleadObj.R0_Expired__c=false;
                newleadObj.R1_Expired__c=false;
                newleadObj.R2_Expired__c=false;
                newleadObj.RH_Extenssion_Approved__c= False;
                newleadObj.BH_Extension_Approved__c= False;
                newleadObj.Manco_Extension_Approved__c= False;
                newleadObj.R0_Expiry_Date__c=null;
                newleadObj.R1_Expiry_Date__c=null;
                newleadObj.R2_Expiry_Date__c=null;
                
                newleadObj.Prospect_1st_Milestone_Complete__c = false;
                newleadObj.Prospect_2nd_Milestone_Complete__c = false;
                newleadObj.Prospect_3rd_Milestone_Complete__c = false;
                newleadObj.Prospect_4th_Milestone_Complete__c = false;
                newleadObj.ExtensionGranted__c = false;
                newleadObj.isAssigned__c = false;
                newleadObj.Extension_Approved_Date__c = null;
                newleadObj.isAssignedDate__c = null;
                newleadObj.Hot_Communication_Count__c = null;
                newleadObj.Cold_Communication_Count__c = null;
                newleadObj.Warm_Communication_Count__c = null;
                newLeadObj.Entered_Meeting_Notes_For_R1__c = false;
                newLeadObj.Follow_up_Done_Post_Submission__c = false;
                newLeadObj.Proposal_Submitted_to_Client_Uploaded__c = false;
                newleadObj.Next_Follow_Up_Established__c = false;
                newLeadObj.Reply_received_from_client__c = false;
                newLeadObj.BH_is_in_Meeting__c = false;
                newLeadObj.RH_is_in_Meeting__c = false;
                newLeadObj.Rashesh_Nitin_met_Client__c = false;
                newLeadObj.Manco_Members_Met_the_Client_Description__c = '';
               
                system.debug('leadObj.CreatedBy.ProfileId==='+leadObj.CreatedBy.ProfileId);
                system.debug('leadObj.CreatedBy.ProfileId == faProfileList[0].id ======'+(leadObj.CreatedBy.ProfileId == faProfileList[0].id ));
                system.debug('faProfileList[0]!=null=============='+(faProfileList[0]!=null));
                system.debug('faProfileList[0].id================'+faProfileList[0].id);
                if(faProfileList[0]!=null && leadObj.CreatedBy.ProfileId == faProfileList[0].id ){
                    if(leadObj.Category__c == 'Corporate'){
                        newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Corporate_Prospect');
                    }
                    if(leadObj.Category__c == 'Individual' ){
                        newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Individual_Prospect');
                    }
                    if(leadObj.Category__c == 'Both'){
                        newleadObj.RecordTypeId = EdelweissConstants.LeadrecordTypeMap.get('Both_Prospect');
                    }
                    //newleadObj.status = 'Warm';
                    newleadObj.OwnerId = Label.Lead_Database_Queue_ID;
                    isLD = true;
                    updatedLeadList.add(newleadObj);                    
                }else{
                    newleadObj.OwnerId = leadObj.CreatedById;
                    newleadObj.Status = 'R0';
                    reallocatedLeadList.add(newleadObj);
                }
                 
            }
        }
        if(updatedLeadList!=null && updatedLeadList.size()>0){
            try{
                stopLeadTrigger = true;
                update updatedLeadList;
                if(isLD){
                    sendNotificationOnReallocation(updatedLeadList);
                }
            }Catch(Exception e){
            
                system.debug('Updation fail and exception is:::'+e);
            }
        } 
        if(reallocatedLeadList!=null && reallocatedLeadList.size()>0){
            try{
                stopLeadTrigger = true;
                update reallocatedLeadList;
                
            }Catch(Exception e){
            
                system.debug('Updation fail and exception is:::'+e);
            }
        }
    }
    public static void changeOwner(List<Lead>leadList){
        system.debug('In Change Owner***************');
        /*Set option for running assignment rule*/
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];                   
        List<Lead>updatedLeadList= new List<Lead>();   
        
        for(Lead leadObj  :leadList){
            Boolean isAssignmentRuleSet = false;
            system.debug('In Change Owner for loop***************');
            if((leadObj.Sub_Category__c =='Treasury'||leadObj.Sub_Category__c == 'Family Office')){
                system.debug('dml option set for 1 time************');
                isAssignmentRuleSet = true;
                
            }
            /*if(!(leadObj.Sub_Source_Level_2__c =='Client Referral'|| leadObj.Sub_Source_Level_2__c =='FA Referral')
                &&(leadObj.LeadSource =='External'&& leadObj.Sub_Source_Level_2__c != 'Client Referral')){
                system.debug('dml option set for 2 time************');
                isAssignmentRuleSet = true;
            }*/
            if(!(leadObj.Sub_Source_Level_2__c =='Client Referral'|| leadObj.Sub_Source_Level_2__c =='FA Referral')){
                system.debug('dml option set for 2 time************');
                isAssignmentRuleSet = true;
            }
        
            if(isAssignmentRuleSet ){
                Lead newleadObj= new Lead(id=leadObj.id);
                //Setting the DMLOption on Case instance
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                dmlOpts.EmailHeader.triggerUserEmail=true;
                //newleadObj.Status = EdelweissConstants.LEAD_HOT_STATUS ;
                newleadObj.setOptions(dmlOpts);                
                updatedLeadList.add(newleadObj);
                system.debug('DML option is set=========');
            
            }
        }   
        if(updatedLeadList!=null && updatedLeadList.size()>0){
            try{
                stopLeadTrigger = true;
                update updatedLeadList;
            
            }Catch(Exception e){
            
                system.debug('Updation fail and exception is:::'+e);
            }
        
        } 
    }
    public static void sendNotificationOnReallocation(List<Lead> leadList){
        List<Messaging.Singleemailmessage> msgList = new List<Messaging.Singleemailmessage>();
        List<EmailTemplate> templateList =   [Select Id,Name,DeveloperName from EmailTemplate where DeveloperName = 'Lead_Database_Queue_Notification'];
            if(!templateList.isEmpty())
            {
                for(Lead leadObj:leadList)
                {
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(templateList[0].Id);
                  mail.setTargetObjectId(leadObj.Id);
                  Profile sys_adm_profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                  List<User> sysAdm = [SELECT id, Email FROM User WHERE ProfileId = :sys_adm_profile.id];
                  List<String> toAddresses = new List<String>();//{sys_adm.Email};
                  for(User userObj : sysAdm )
                  {
                      toAddresses.add(userObj.Email);
                  }
                  toAddresses.add(leadObj.Old_Owner_email__c);
                  mail.setToAddresses(toAddresses);
                  //mail.setToAddresses(new List<String>{leadObj.Owner.Email});
                  List<String> ccAddresses = new List<String>();
                  mail.setSenderDisplayName('Edelweiss Admin');
                  msgList.add(mail);
                }
            }
            try
            {
                if(msgList != null && msgList.size() > 0){
                    Messaging.sendEmail(msgList,false);
                }
            }
            catch(Exception e)
            {
                system.debug('EMAIL EXCEPTION:'+e.getMessage());
                
            }
            
    
    }
    
     public static void shareLeadWithCXO(List<Lead>leadList,Map<Id,Lead>leadOldMap){
        Set<Id> FAIdSet = new Set<Id>();
        Map<Id,Id>FAIdCSOIdMap = new Map<Id,Id>();
        List<LeadShare> leadShareList = new List<LeadShare>();
        Map<Id,Id>leadIdownerIdMap = new Map<Id,Id>();
        
        for(Lead leadObj :leadList){
            Lead oldLeadObj = leadOldMap.get(leadObj.Id);
            if((oldLeadObj.Status!= leadObj.Status || oldLeadObj.OwnerId != leadObj.OwnerId  ) && leadObj.Status == EdelweissConstants.LEAD_R2_STATUS){
                FAIdSet.add(leadObj.OwnerId);
                leadIdownerIdMap.put(leadObj.Id,leadObj.OwnerId);
            }
        }
            
         
        if(FAIdSet!=null && FAIdSet.size()>0){
            FAIdCSOIdMap = AccountTriggerhandler.getFAMappedCSO(FAIdSet); 
        } 
           
        for(Id leadId:leadIdownerIdMap.keySet()){
            Id CSOId;
            Id FAId = leadIdownerIdMap.get(leadId);
            if(FAIdCSOIdMap!=null && !FAIdCSOIdMap.isEmpty() && FAIdCSOIdMap.containsKey(FAId)){
                CSOId = FAIdCSOIdMap.get(FAId);
                LeadShare leadShareObj = new LeadShare(LeadId = leadId, UserOrGroupId = CSOId, LeadAccessLevel='Edit',RowCause='Manual');
                leadShareList .add(leadShareObj);
            } 
        }
    
        if(leadShareList !=null && leadShareList .size()>0){
            try{
            
                upsert leadShareList ;
            }catch(Exception e){
                system.debug('*********Error in insertion for Account Share record*********');
            
            }
            
        
        }
    }
    public static void checkOwnerAssignment(List<Lead>leadList,Map<Id,Lead>leadOldMap){
        Map<Id, Id> userMap = new Map<Id, Id>(); 
        //List<Lead> lList = [SELECT id,Category__c,owner.ProfileId,CreatedById,Owner.Type,OwnerId,RecordType.DeveloperName, RecordTypeId from Lead WHERE Id IN:leadOldMap.keySet() ];
        List<User> usrList = [SELECT Id,ProfileId FROM User];
        for(User lst: usrList){
            userMap.put(lst.id, lst.profileId);
        }
        Sys_Properties__c profileId = Sys_Properties__c.getValues('Profile Financial Advisor Id');
        List<Owner_Assignment_History__c> ownerChangeHitoryList = new List<Owner_Assignment_History__c>();
        
        for(Lead leadObj :leadList){
            Lead oldLeadObj = leadOldMap.get(leadObj.Id);
            
            if(oldLeadObj.OwnerId != leadObj.OwnerId && leadObj.OwnerId == Label.Lead_Database_Queue_ID){
                if(!isAssignmentRestricted(leadObj.id, oldLeadObj.OwnerId)){
                    Owner_Assignment_History__c ownerChangeHitory = new Owner_Assignment_History__c(); 
                    ownerChangeHitory.Lead__c = leadObj.id;
                    ownerChangeHitory.Lead_Owner__c = oldLeadObj.OwnerId;
                    ownerChangeHitoryList.add(ownerChangeHitory); 
                }
            }else if(oldLeadObj.OwnerId != leadObj.OwnerId && leadObj.OwnerId != Label.Lead_Database_Queue_ID){
                if(isAssignmentRestricted(leadObj.id, leadObj.OwnerId)){
                    leadObj.OwnerId.addError(Label.Lead_Owner_Re_Assignment);
                }
            }
        }
        try{
            if(ownerChangeHitoryList.size() > 0 && ownerChangeHitoryList != null){
                insert ownerChangeHitoryList;
            }               
        }catch(Exception ex){
            System.debug('EXCEPTION @ checkOwnerAssignment : ' + ex.getMessage());
        }
    }
    private static boolean isAssignmentRestricted(Id leadId,Id ownerId){
        System.debug('DildarLog: leadId - ' + leadId + ', ownerId - ' + ownerId);
        List<Owner_Assignment_History__c> owners = [select id from Owner_Assignment_History__c where Lead__c =:leadId And Lead_Owner__c =:ownerId limit 1];
        System.debug('DildarLog: owners - ' + owners);
        if(owners.size() > 0 && owners != null)
            return true;
        else
            return false;
    }    
}