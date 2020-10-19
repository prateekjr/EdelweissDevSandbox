public class SubmitForApprovalsController {

     @AuraEnabled
     public static Account getAccountRecord(String recordId){
        String errorStr = 'Success';
         List<Account> lstAccount = [select Id,Acquisiton_Approval_For_FY__c,Request_Approval_for_R5__c,Name,Approved_Acquistion_Year__c,Requestor_Comments_For_Approval__c,IsR4_Plus_Approved__c from Account where Id=: recordId Limit 1];
         Account acc;
        if(lstAccount != null && lstAccount.size() > 0 ){
            acc = lstAccount[0];  
            acc.Request_Approval_for_R5__c='';
            acc.Acquisiton_Approval_For_FY__c='';
            acc.Requestor_Comments_For_Approval__c='';
        }
          return acc;
    }
    
     @AuraEnabled
    public static String UpdateAccRecord(Account updateAccRecord ,String recordId)
    {
        String errorStr = 'Success';
        try{
        String approvalProcessName;
        database.update(updateAccRecord);
        errorStr= validateAndSetApprovalProcess(updateAccRecord);
        }catch(Exception e){
           return e.getMessage();
        }
       if(errorStr!='Success'){
           System.debug('updateAccRecord   '+updateAccRecord);
            updateAccRecord.Request_Approval_for_R5__c=null;
            updateAccRecord.Acquisiton_Approval_For_FY__c=null;
            updateAccRecord.Requestor_Comments_For_Approval__c=null;
            database.update(updateAccRecord);
        }
        return errorStr;
        
    }
    private static String validateAndSetApprovalProcess(Account updateAccRecord){
        String approvalProcessName;
        String errorStr = 'Success';
        try{
        if(updateAccRecord.Request_Approval_for_R5__c!=null && !(String.isEmpty(updateAccRecord.Request_Approval_for_R5__c)) ){
            if(updateAccRecord.Request_Approval_for_R5__c=='R5 Approval'){
              approvalProcessName='Approval_Process_R5_Conversion';  
            }
            else if(updateAccRecord.Request_Approval_for_R5__c=='R4+ Approval'){
                approvalProcessName='Approval_Process_R4_Conversion';
            }
        }
        else if(updateAccRecord.Acquisiton_Approval_For_FY__c!=null && !(String.isEmpty(updateAccRecord.Acquisiton_Approval_For_FY__c)) ){
                approvalProcessName='Approval_For_Acquisition';
        } 
        Approval.ProcessSubmitRequest submitAprovalRequest =loadApprovalMap().get(approvalProcessName);
        submitAprovalRequest.setObjectId(updateAccRecord.Id);
            if(updateAccRecord.Requestor_Comments_For_Approval__c!=null){
                submitAprovalRequest.setComments(updateAccRecord.Requestor_Comments_For_Approval__c);
            }    
        System.debug('Submitting for '+approvalProcessName);    
        Approval.ProcessResult result = Approval.process(submitAprovalRequest);
        return errorStr;
        }
        catch(Exception e){
           if(e.getMessage().contains('No applicable approval process was found')){
                 return 'No applicable approval process was found';
            }
           return e.getMessage();
        }
    }
    
    private static Map<String,Approval.ProcessSubmitRequest> loadApprovalMap(){
        // Prepare Approval Process Map
        Approval.ProcessSubmitRequest reqForR5 = new Approval.ProcessSubmitRequest();
        reqForR5.setComments('Submitting request for R5 approval.');
        reqForR5.setProcessDefinitionNameOrId('Approval_Process_R5_Conversion');
        reqForR5.skipEntryCriteria=false;
        
        Approval.ProcessSubmitRequest reqForAcquistion = new Approval.ProcessSubmitRequest();
        reqForAcquistion.setComments('Submitting request for Acquisition approval.');
        reqForAcquistion.setProcessDefinitionNameOrId('Approval_For_Acquisition');
        reqForAcquistion.skipEntryCriteria=false;
        
        Approval.ProcessSubmitRequest reqForR4 = new Approval.ProcessSubmitRequest();
        reqForR4.setComments('Submitting request for R4+ approval.');
        reqForR4.setProcessDefinitionNameOrId('Approval_Process_R4_Conversion');
        reqForR4.skipEntryCriteria=false;
        
        Map<String,Approval.ProcessSubmitRequest> approvalMap=new Map<String,Approval.ProcessSubmitRequest>();
        approvalMap.put('Approval_Process_R5_Conversion',reqForR5);
        approvalMap.put('Approval_For_Acquisition',reqForAcquistion);
        approvalMap.put('Approval_Process_R4_Conversion',reqForR4);
        
        
        return approvalMap;
       
    }
}