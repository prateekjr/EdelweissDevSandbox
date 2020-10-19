public class AudioFilePlayController {
	public Id recordId { get; set; }
    public List<ContentVersionCls> ContentVersionClsList { get; set; }
    
    public class ContentVersionCls{
        public String VersionData{ get; set; }
        public String Title{ get; set; }
        public String FileExtension{ get; set; }        
    }
    
    public AudioFilePlayController() {
		ContentVersionClsList = new List<ContentVersionCls>();
    	recordId = ApexPages.currentPage().getParameters().get('id');
        if(recordId != null){ 
           List<Id> ContentDocumentIds = new List<Id>();
            List<ContentDocumentLink> lstLink = [SELECT ContentDocumentId,Id,LinkedEntityId 
                                                 FROM ContentDocumentLink WHERE LinkedEntityId =: recordId 
                                                 ORDER BY SystemModstamp ASC];
            for(ContentDocumentLink doc : lstLink){
                ContentDocumentIds.add(doc.ContentDocumentId);
            } 
             
            if(ContentDocumentIds != null && ContentDocumentIds.size() > 0){
                List<ContentVersion> ContentVersionList = [SELECT ContentDocumentId,VersionData,Title,FileType,FileExtension,Id 
                                      FROM ContentVersion Where ContentDocumentId =:ContentDocumentIds 
                                      ORDER BY SystemModstamp ASC];
                
                Set<string> fileType = new set<string>{'MP3','AAC','WAV'};
                for(ContentVersion cv : ContentVersionList){                    
                    if(fileType.contains(cv.FileType)){
                        ContentVersionCls obj = new ContentVersionCls();
                        obj.VersionData = EncodingUtil.base64Encode(cv.VersionData);
                        obj.Title = cv.Title;
                        obj.FileExtension = cv.FileType;
                        ContentVersionClsList.add(obj);
                    }                     
                }                
            } 
        }          
    }    
}