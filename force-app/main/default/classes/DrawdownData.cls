public class DrawdownData {

     public class DrawdownDataWrapper {
        @AuraEnabled
        public String drawDownDueDate {get;set;}
        @AuraEnabled
        public String drawDownAmtStr {get;set;}
        @AuraEnabled
        public String drawDownAmtPaidTillDateStr {get;set;}
        @AuraEnabled
        public String drawDownAmtDueStr {get;set;}
     }
    
       public class refreshApiWrapper
    {
        @AuraEnabled
        public  string HoldingMode { get; set; }
        @AuraEnabled
        public  string ARN { get; set; }
        @AuraEnabled
        public string FolioNum { get; set; }
        @AuraEnabled
        public  string AvailableHoldings { get; set; }
    }
}