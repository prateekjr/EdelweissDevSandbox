public class FieldSetMember {

    public FieldSetMember(Schema.FieldSetMember f , String referenceObjName , List<String> pickListValues , Object value, Boolean isRTF, Integer maxLength, Boolean isFormula, Boolean isEditable, Integer decimalDigits, String helpText, Boolean isAccessible) {
        this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label; 
        this.required = f.required;
        this.type = '' + f.getType();
        this.referenceObjName = referenceObjName;
        this.pickListValues = pickListValues;
        this.value = value;
        this.isHTMLFormatted = isRTF; 
        this.maxLength = maxLength;
        this.isFormula = isFormula;
        this.isEditable = isEditable;
        this.decimalDigits = decimalDigits;
        this.helpText = helpText;
		this.isAccessible = isAccessible;
     }
	 
	 public FieldSetMember(Schema.FieldSetMember f , String referenceObjName , List<String> pickListValues , Object value, Boolean isRTF, Integer maxLength, Boolean isFormula, Boolean isEditable, Integer decimalDigits, String helpText) {
        this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label; 
        this.required = f.required;
        this.type = '' + f.getType();
        this.referenceObjName = referenceObjName;
        this.pickListValues = pickListValues;
        this.value = value;
        this.isHTMLFormatted = isRTF; 
        this.maxLength = maxLength;
        this.isFormula = isFormula;
        this.isEditable = isEditable;
        this.decimalDigits = decimalDigits;
        this.helpText = helpText;
     }
 
    public FieldSetMember(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean isAccessible { get; set; }
	
	@AuraEnabled
    public String helpText { get; set; }
    
    @AuraEnabled
    public Boolean isEditable { get;set; }
    
    @AuraEnabled
    public Integer decimalDigits { get;set; }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }

    @AuraEnabled
    public String fieldPath { get;set; }

    @AuraEnabled
    public String label { get;set; }

    @AuraEnabled
    public Boolean required { get;set; }

    @AuraEnabled
    public String type { get; set; }
    
     @AuraEnabled
    public String referenceObjName { get; set; }
    
     @AuraEnabled
    public List<String> pickListValues { get; set; }
    
    @AuraEnabled
    public Object value{get;set;}
    
    @AuraEnabled
    public Boolean isHTMLFormatted{get;set;}
    
    @AuraEnabled
    public Integer maxLength{get;set;}
    
    @AuraEnabled
    public Boolean isFormula{ get;set; }
}