/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Client_Satisfaction_Measua0CTrigger on Client_Satisfaction_Measurement__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Client_Satisfaction_Measurement__c.SObjectType);
}