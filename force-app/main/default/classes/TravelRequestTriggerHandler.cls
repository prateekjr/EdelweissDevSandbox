public class TravelRequestTriggerHandler {
    
    public static void initiateApprovalProcess(Map<Id,Travel_Request__c> TRlist){
        System.debug('Inside initiateApprovalProcess ');
        List<Id> travelrequestInitiated = new List<Id>();
        for(Travel_Request__c tr : TRlist.values()){
            if(tr.Travel_Request_Status__c == 'Initiated'){
                travelrequestInitiated.add(tr.Id);
            }
            
        }
        System.debug('travelrequestInitiated'+travelrequestInitiated);
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            
            for(Travel_Request__c tr : TRlist.values()){
                if(tr.Travel_Request_Status__c == 'Initiated' && !tr.Is_Approval_Sent__c){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(tr.id);
                    req1.setSubmitterId(TRlist.get(tr.id).CreatedById);
                    req1.setProcessDefinitionNameOrId('Travel_Request_Approval');
                    Approval.ProcessResult result = Approval.process(req1);
                    System.debug('End '+result);
                }
            }
    }
    
    
    public static void updateManagerEmail(List<Travel_Request__c> ticket){
        MAP<ID , User> tempMap = EdelweissConstants.userList;
        List<ID> AccountList = new  List<ID>();
        for(Travel_Request__c obj : ticket){
            User u1 = tempMap.get(obj.OwnerId);
            if(u1.Manager.email != null){
                obj.RecordCreatorManagerEmail__c = u1.Manager.email;
            }
            
        }
        
    }
    public static void restrictFamilyLeadUpdate(Map<Id,Travel_Request__c> oldTicket,Map<Id,Travel_Request__c> newTicket){
        for(Travel_Request__c trObjOld : oldTicket.values()){
            Travel_Request__c trObjnew = newTicket.get(trObjOld.Id);
            if(trObjnew.Travel_Request_Status__c == 'Approved' || trObjnew.Travel_Request_Status__c == 'Cancelled' ||  trObjnew.Travel_Request_Status__c == 'Rejected'){
                if(trObjnew.City__c != trObjOld.City__c){
                    trObjnew.City__c.addError('Record is locked , You cannot change the City of travel request.');
                }
                if(trObjnew.From_Date__c != trObjOld.From_Date__c){
                    trObjnew.From_Date__c.addError('Record is locked , You cannot change the From Date of travel request.');
                }
                if(trObjnew.To_Date__c != trObjOld.To_Date__c){
                    trObjnew.To_Date__c.addError('Record is locked , You cannot change the To Date of travel request.');
                }
                if(trObjnew.Actual_Cost_In_Rs__c != trObjOld.Actual_Cost_In_Rs__c){
                    trObjnew.Actual_Cost_In_Rs__c.addError('Record is locked , You cannot change the Actual Cost of travel request.');
                }
                if(trObjnew.account_1__c != trObjOld.account_1__c){
                    trObjnew.account_1__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_2__c != trObjOld.account_2__c){
                    trObjnew.account_2__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_3__c != trObjOld.account_3__c){
                    trObjnew.account_3__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_4__c != trObjOld.account_4__c){
                    trObjnew.account_4__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_5__c != trObjOld.account_5__c){
                    trObjnew.account_5__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_6__c != trObjOld.account_6__c){
                    trObjnew.account_6__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_7__c != trObjOld.account_7__c){
                    trObjnew.account_7__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_8__c != trObjOld.account_8__c){
                    trObjnew.account_8__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_9__c != trObjOld.account_9__c){
                    trObjnew.account_9__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }if(trObjnew.account_10__c != trObjOld.account_10__c){
                    trObjnew.account_1__c.addError('Record is locked , You cannot change the Family/Lead of travel request.');
                }












                
            }
        }
        
    }
    
    public static void validateData(List<Travel_Request__c> ticket){
        List<Id> accountLookupId = new List<Id>();
        for(Travel_Request__c obj : ticket){
            accountLookupId.add(obj.account_10__c);
            accountLookupId.add(obj.account_9__c);
            accountLookupId.add(obj.account_8__c);accountLookupId.add(obj.account_7__c);accountLookupId.add(obj.account_6__c);
            accountLookupId.add(obj.account_5__c);accountLookupId.add(obj.account_4__c);accountLookupId.add(obj.account_3__c);
            accountLookupId.add(obj.account_2__c);accountLookupId.add(obj.account_1__c);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT id , Name , Recordtype.Id , RecordType.Name FROM Account WHERE id  =: accountLookupId]);
        
        for(Travel_Request__c obj : ticket){
            if(obj.From_Date__c != null){
                Date FromDate = date.newinstance(obj.From_Date__c.year(), obj.From_Date__c.month(), obj.From_Date__c.day());
                if(FromDate <= System.today()){
                    obj.From_Date__c.addError('Please Select Future Date');
                }
            }
            if(obj.To_Date__c != null){
                Date ToDate = date.newinstance(obj.To_Date__c.year(), obj.To_Date__c.month(), obj.To_Date__c.day());
                if(ToDate <= System.today()){
                    obj.To_Date__c.addError('Please Select Future Date');
                }
            }
            if(obj.account_1__c != null){
                if(accountMap.get(obj.account_1__c).RecordType.Name == 'Client'){
                    obj.account_1__c.addError('Please Select Lead or Family');
                }
            }
            if(obj.account_2__c != null){
                if(accountMap.get(obj.account_2__c).RecordType.Name == 'Client'){
                    obj.account_2__c.addError('Please Select Lead or Family');
                }
            }
            if(obj.account_3__c != null){
                if(accountMap.get(obj.account_3__c).RecordType.Name == 'Client'){
                    obj.account_3__c.addError('Please Select Lead or Family');
                }
            }
            if(obj.account_4__c != null){
                if(accountMap.get(obj.account_4__c).RecordType.Name == 'Client'){
                    obj.account_4__c.addError('Please Select Lead or Family');
                }
                
            }
            if(obj.account_5__c != null){
                if(accountMap.get(obj.account_5__c).RecordType.Name == 'Client'){
                    obj.account_5__c.addError('Please Select Lead or Family');
                }
                
            }
            if(obj.account_6__c != null){
                if(accountMap.get(obj.account_6__c).RecordType.Name == 'Client'){
                    obj.account_6__c.addError('Please Select Lead or Family');
                }
            }
            
            if(obj.account_7__c != null){
                if(accountMap.get(obj.account_7__c).RecordType.Name == 'Client'){
                    obj.account_7__c.addError('Please Select Lead or Family');
                }
            }
            if(obj.account_8__c != null){
                if(accountMap.get(obj.account_8__c).RecordType.Name == 'Client'){
                    obj.account_8__c.addError('Please Select Lead or Family');
                } 
            }
            if(obj.account_9__c != null ){
                if(accountMap.get(obj.account_9__c).RecordType.Name == 'Client'){
                    obj.account_9__c.addError('Please Select Lead or Family');
                }
            }
            if(obj.account_10__c != null){
                if(accountMap.get(obj.account_10__c).RecordType.Name == 'Client'){
                    obj.account_10__c.addError('Please Select Lead or Family');
                }
            }
        }
    }
    
}