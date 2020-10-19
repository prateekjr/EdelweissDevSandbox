global class BatchUpdateMINIAndDetailedIPS implements Database.Batchable<sObject>,Database.Stateful
{
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id,Name,MINIIPS_filled_Due_Date__c,DetailIPS_filled_Due_Date__c,
                                         MINI_IPS_Review_Date__c,DetailIPS_Review_Date__c,CreatedDate,Coverage__c,
                                         IsFilledDetailIPS__c,IsFilled_MINIIPS__c,IsReview_MINIIPS__c,IsReview_DetailIPS__c
                                         FROM Account
                                         WHERE RecordType.DeveloperName = 'Family']);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> updateDateOnAccount)
    {
        for(Account acc: updateDateOnAccount)
        {
            if(acc.Coverage__c =='R4' || acc.Coverage__c == 'R5')
            {
                DateTime IPSDate= date.today().addMonths(12);
                //DateTime IPSDate = acc.CreatedDate.addMonths(12);
            	acc.DetailIPS_filled_Due_Date__c = Date.valueOf(IPSDate);
                system.debug('BatchUpdateMINIAndDetailedIPS::acc.IsFilledDetailIPS__c'+acc.IsFilledDetailIPS__c);
            }
            if(acc.Coverage__c =='R4' || acc.Coverage__c == 'R5')
            {
                DateTime IPSDate= date.today().addMonths(6);
                //DateTime IPSDate = acc.CreatedDate.addMonths(6);
            	acc.MINIIPS_filled_Due_Date__c = Date.valueOf(IPSDate);
            }
            if(acc.Coverage__c =='R3')
            {
                DateTime IPSDate= date.today().addMonths(24);
                //DateTime IPSDate = acc.CreatedDate.addMonths(24);
            	acc.DetailIPS_filled_Due_Date__c = Date.valueOf(IPSDate);
            }
            if(acc.Coverage__c =='R3')
            {
                DateTime IPSDate= date.today().addMonths(12);
                //DateTime IPSDate = acc.CreatedDate.addMonths(12);
            	acc.MINIIPS_filled_Due_Date__c = Date.valueOf(IPSDate);
            }
            if(acc.IsReview_DetailIPS__c == True)
            {
                DateTime IPSDate= date.today().addMonths(24);
                //DateTime IPSDate = acc.CreatedDate.addMonths(24);
            	acc.DetailIPS_Review_Date__c = Date.valueOf(IPSDate);
            }
            if(acc.IsReview_MINIIPS__c == True)
            {
                DateTime IPSDate= date.today().addMonths(12);
                //DateTime IPSDate = acc.CreatedDate.addMonths(12);
                acc.MINI_IPS_Review_Date__c = Date.valueOf(IPSDate);
            }
    	}
        update updateDateOnAccount;
	}
    global void finish(Database.BatchableContext ctx)
    {
           /*
         * Batch_DetailIPS_Review_within_2year ReviewDetailIPS = new Batch_DetailIPS_Review_within_2year();
			Database.executeBatch(ReviewDetailIPS, 200);
         * */    
    }
}