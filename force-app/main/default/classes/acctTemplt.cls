public  class acctTemplt
{
    public Id accountId {get;set;}
    public List<Account> getAccountList()
    {
        List<Account> accList;
        accList = [SELECT Name, Mobile_1__c FROM Account WHERE id =: accountId];
        return accList;
    }
}