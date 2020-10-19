global class NPSEmailService implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    		System.debug('Email'+email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            string strEventId = '';
            if(email.plainTextBody.containsIgnoreCase('force.com/')){
                strEventId = email.plainTextBody.substringAfter('force.com/');
            }else{
                strEventId = email.plainTextBody.substringAfter('<http:');
            }
    		if(strEventId != ''){
                strEventId = strEventId.substringBefore('>');
            }
            string strBody = email.plainTextBody;
    		
    
            strBody = strBody.trim();
    		String RecordId;
    		String[] toAddresses = email.toAddresses;
    		String appendToAdd = 'To Address : '+toAddresses;
    		strBody = appendToAdd+strBody;
            System.debug('BODY of Mail'+strBody);
    if(strbody.contains('#NPS##')){
        System.debug('Yes inside');
        Integer index = strbody.indexOf('#NPS##');
        System.debug('index of '+index);
        RecordId = strBody.substring(index+7, index+23);
        System.debug('RecordId'+RecordId);
        Attachment  myAttachment =new Attachment();
        myAttachment .clear();
        String htmlContent = email.htmlBody; 
        System.debug('htmlContent'+htmlContent);
        myAttachment.Body = Blob.valueOf(htmlContent); 
        myAttachment.Name = 'Email Sent.html' ; 
        myAttachment.ParentId = RecordId.trim();  
        System.debug('myAttachment'+myAttachment); 
        
        insert myAttachment;     
    }
	 
    if(strbody.contains('#CCN##')){
        System.debug('Yes inside');
        Integer index = strbody.indexOf('#CCN##');
        System.debug('index of '+index);
        RecordId = strBody.substring(index+7, index+22);
        System.debug('RecordId'+RecordId);
        Attachment  myAttachment =new Attachment();
        myAttachment .clear();
        String htmlContent = email.htmlBody; 
        System.debug('htmlContent'+htmlContent);
        myAttachment.Body = Blob.valueOf(htmlContent); 
        myAttachment.Name = 'Email Sent.html' ; 
        myAttachment.ParentId = RecordId.trim();  
        System.debug('myAttachment'+myAttachment); 
        
        insert myAttachment;     
    }

    	return result;
      }   
}