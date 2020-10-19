global class StagingInsertStatusEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.Inboundenvelope envelope) {
        String body =  email.plainTextBody;
        if(!String.isEmpty(body)){
            string returnVal = body.substringBetween('ref:',':ref');
            if(!String.isEmpty(returnVal)){
                String[] splitString = returnVal.split('-');
                system.debug('returnVal: '+returnVal );
                StagingErrorResult__c res = StagingErrorResult__c.getInstance(splitString[0].trim());
                if(res == null){
                    res  = new StagingErrorResult__c ();
                    res.Name = splitString[0].trim();
                }
 
                if(splitString[1].trim()!= '0'){
                    res.ErrorExist__c= true; 
                }else{
                    res.ErrorExist__c= false; 
                }
                upsert res;

            }
        }
        return null;
    }
}