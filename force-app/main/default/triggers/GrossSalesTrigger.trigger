trigger GrossSalesTrigger on Gross_Sales_Details__c (before insert,before update) {
  if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        GrossSalesTriggerHandler.parseGrossSalesData(Trigger.new);
    }
}