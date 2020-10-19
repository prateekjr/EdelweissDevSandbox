public class HomeBannerController {
	@AuraEnabled 
    public static string getFilecontent(){
        List<ContentDocument> docs = [Select Id,Title,LatestPublishedVersionId From ContentDocument Where Title ='HomeBanner_Popup'];
        if(docs != null && docs.size() > 0){
            List<ContentVersion> docDataList = [SELECT VersionData,Title,FileType,FileExtension FROM ContentVersion Where Id =:docs[0].LatestPublishedVersionId];
            if(docDataList !=null && docDataList.size() > 0){
                return docs[0].Id; //EncodingUtil.base64Encode(docDataList[0].VersionData);
            }
        }
        return null;
    }
    
    public ContentVersion cnt {
        get {
            if (cnt == null) {
                 List<ContentDocument> docs = [Select Id,Title,LatestPublishedVersionId From ContentDocument Where Title ='HomeBanner_SideBar'];
                if(docs != null && docs.size() > 0){
                    List<ContentVersion> docDataList = [SELECT Id,VersionData,Title,FileType,FileExtension FROM ContentVersion Where Id =:docs[0].LatestPublishedVersionId];
                    if(docDataList !=null && docDataList.size() > 0){
                        cnt = docDataList[0];
                        //return EncodingUtil.base64Encode(docDataList[0].VersionData);
                    }
                }
            }
            return cnt; 
        }
        private set;
    }
    public String pdf {
        get {
            return EncodingUtil.Base64Encode(cnt.VersionData);
        }
    }
}