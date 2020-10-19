public class RecordTypeSelectorController {
    
    public class myRecordType{
        @AuraEnabled public RecordType rt{get;set;}  
        @AuraEnabled public String isChecked{get;set;} 
    }
    @AuraEnabled
    public static List<myRecordType> getListOfRecordType(){
        Map<Id,RecordType> caseRecType= new Map<Id,RecordType>([SELECT Id,Name , Description FROM RecordType WHERE IsActive=TRUE AND SobjectType = 'Case']);
        List<myRecordType> rtNames = new List<myRecordType>();  
        Schema.SObjectType  objType = Case.SObjectType;        
        for(RecordTypeInfo rt1 : objType.getDescribe().getRecordTypeInfos()){
            if(!(rt1.getName() == 'Master') && rt1.isAvailable() && !(rt1.getName() == 'Wealth And Infinity WorkFlow') && (rt1.getName() != 'FT_PMS') && (rt1.getName() != 'FT Bond') && (rt1.getName() != 'FT IPO')  && (rt1.getName() != 'FT SP')){
                RecordType tempRec = caseRecType.get(rt1.getRecordTypeId());
                System.debug('tempRec :'+tempRec);
                if(tempRec.id == rt1.getRecordTypeId()){
                RecordType recordTypeobj = new RecordType(Id = rt1.getRecordTypeId(),Name = rt1.getName() , Description = tempRec.Description);
                System.debug('Rec '+recordTypeobj);
                    myRecordType myRecordTypeobj = new myRecordType();
                myRecordTypeobj.rt = recordTypeobj;
                if(rt1.isDefaultRecordTypeMapping()){
                    myRecordTypeobj.isChecked = 'checked';
                }else{
                    myRecordTypeobj.isChecked = '';
                }
                rtNames.add(myRecordTypeobj);
                }
            }
        }    
        return rtNames;  
    }
    
    @AuraEnabled
    public static Id getRecordTypeSRId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        return recordTypeId;
    } 
     @AuraEnabled
    public static Id getRecordTypeFTId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fund Transfer').getRecordTypeId();
        return recordTypeId;
    } 
    @AuraEnabled
    public static Id getRecordTypeWealthInWardingId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Wealth Inwarding').getRecordTypeId();
        return recordTypeId;
    } 
    
     @AuraEnabled
    public static Id getRecordTypeFinancialTransactionId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Financial Transaction').getRecordTypeId();
        return recordTypeId;
    }
    
    @AuraEnabled
    public static Id getRecordTypeAOId() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Opening').getRecordTypeId();
        return recordTypeId;
    } 
    
    @AuraEnabled
    public static Id getAccountRecordType() {
        Id ClientRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        return ClientRecordTypeId;
    } 
    
}