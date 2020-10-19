public class IPSTriggerHandler
{
    public static void updateaccountOnIPSCreation(List<Investment_Policy_Statement_IPS__c > IPSList)
    {
        List<Account> updateAccountList = new List<Account>();
        List<Id> accIds = New List<Id>();
        Map<Id,Investment_Policy_Statement_IPS__c> IPSAccountMap =  new Map<Id,Investment_Policy_Statement_IPS__c>(); 
        for(Investment_Policy_Statement_IPS__c IPS : IPSList){
            accIds.add(IPS.Client_Name__C);
            IPSAccountMap.put(IPS.Client_Name__C,IPS);
        }
        updateAccountList = [Select Id, Basic_Details_of_Mini_IPS_filled__c,Coverage__c,ownerId,IPS_Creation_DateTime__c From Account where Id IN : accIds];
        List<Account> accUpdates = new List<Account>();
        for(Account acc : updateAccountList)
        {
            if(acc.Coverage__c ==  'Lead Database' && acc.ownerId ==  userinfo.getuserid())
            {
               IPSAccountMap.get(acc.Id).addError('Action Not Allowed.');
            }
            else if(acc.Coverage__c ==  'R1')
            {
                acc.Basic_Details_of_Mini_IPS_filled__c = true;
                acc.Coverage__c =  'R2'; 
                acc.IPS_Creation_DateTime__c = datetime.now().getTime();
                accUpdates.add(acc);
            }
        }
        if(accUpdates != null && accUpdates.size() > 0)
        database.update(accUpdates);
    }
    public Static void updateaccountOnIPSRecord(List<Investment_Policy_Statement_IPS__c > IPSList)
    {
        system.debug('updateaccountOnIPSRecord'+IPSList);
        List<Account> updateAccountList = new List<Account>();
        List<Id> accIds = New List<Id>();
        List<DateTime> lstCreatedDate = new List<DateTime>();
        Map<Id,Investment_Policy_Statement_IPS__c> AccountIPSMap = new Map<Id,Investment_Policy_Statement_IPS__c>();
        for(Investment_Policy_Statement_IPS__c IPS : IPSList){
            accIds.add(IPS.Client_Name__C);
            lstCreatedDate.add(IPS.CreatedDate);
            AccountIPSMap.put(IPS.Client_Name__C,IPS);
        }
        updateAccountList = [Select Id,Coverage__c,ownerId,Basic_Details_of_Mini_IPS_filled__c,Total_Investible_Assets__c ,
                             Risk_Profile_Based_on_IPS__c,Lead_Database_Prvious_User__c,IPS_Creation_DateTime__c,
                             IsFilled_MINIIPS__c,MINIIPS_Creation_Date__c,IsFilledDetailIPS__c,DetailIPS_Creation_Date__c,
                             IsReview_DetailIPS__c,IsReview_MINIIPS__c,IPSReview_in_Fiscal_Year__c,MilesActivationDate__c,
                             MINI_IPS_Review_Date__c,DetailIPS_Review_Date__c
                             From Account where Id IN : accIds];
        Set<Id> addErrorSet = new Set<Id>();
        for(Account acc : updateAccountList)
        {
            Investment_Policy_Statement_IPS__c IPS = AccountIPSMap.get(acc.Id);
            system.debug('updateaccountOnIPSRecord:: IPS.Total_Investible_Assets__c ::'+IPS.Total_Investible_Assets__c);
            acc.Investible_Assets__c = IPS.Total_Investible_Assets__c;
            //acc.Risk_Profile_Based_on_IPS__c =  IPS.Risk_Rating__c; 
            acc.How_Often_Does_Client_Monitor_Portfolio__c = IPS.How_often_does_client_monitor_po__c; 
            if(!acc.IsFilled_MINIIPS__c){
                acc.MINIIPS_Creation_Date__c = date.today();//datetime.now();
                //acc.IsFilled_MINIIPS__c = True;  
            }   
            if(acc.MINIIPS_Creation_Date__c != null && !(lstCreatedDate.isEmpty()) && IPS != null)
            {
                acc.IsFilled_MINIIPS__c = True;  // Update If IPS is MINI
            }
            if(acc.IsFilledDetailIPS__c != True && acc.DetailIPS_Creation_Date__c != null && !(lstCreatedDate.isEmpty()) && IPS != null)
            {
                acc.IsFilledDetailIPS__c = True; // Update If IPS is Detailed
            }
            if(acc.DetailIPS_Creation_Date__c != null && acc.MilesActivationDate__c != null)//acc.Coverage__c =='R3' && 
            {
                DateTime MilesActivationDate = acc.MilesActivationDate__c.addMonths(12);
                //acc.IPS_filled_Due_Date__c = Date.valueOf(MilesActivationDate);
            }
            if(acc.MINI_IPS_Review_Date__c != null && !(lstCreatedDate.isEmpty()) && IPS != null)
            {
                acc.IsReview_MINIIPS__c = True;  
            }
            if(acc.DetailIPS_Review_Date__c != null && !(lstCreatedDate.isEmpty()) && IPS != null)
            {
                acc.IsReview_DetailIPS__c = True; 
            }
            if( acc.IsReview_DetailIPS__c == True)
            {
                acc.IPSReview_in_Fiscal_Year__c = lastDateOfFiscalQuarter();
            }
            if(acc.Coverage__c ==  'Lead Database' && acc.Lead_Database_Prvious_User__c ==  userinfo.getuserid())
            {
                  addErrorSet.add(acc.Id);
            }
            else if(acc.Coverage__c ==  'R1')
            {
                acc.Basic_Details_of_Mini_IPS_filled__c = true;
                acc.Coverage__c =  'R2';
            }
            acc.How_Often_Does_Client_Monitor_Portfolio__c = IPS.How_often_does_client_monitor_po__c; 
            
            System.debug('acc.IPS_Creation_DateTime__c1'+ acc.IPS_Creation_DateTime__c);
            acc.IPS_Creation_DateTime__c = datetime.now().getTime();
            System.debug('acc.IPS_Creation_DateTime__c2'+ acc.IPS_Creation_DateTime__c);
        }
        AccountTriggerhandler.stopAccountTrigger = true;
        AccountTriggerhandler.stopUpdatefamily = true;
        AccountTriggerhandler.stopupdateOwnerLeadDataBase = true;
        
        System.debug('updateAccountList'+ updateAccountList);
        if(updateAccountList != null && updateAccountList.size() > 0 && addErrorSet.size() == 0){
            list<Account> tobeUpdate =  new List<Account>();
            for(Account acc : updateAccountList){
                //acc.IPS_Creation_DateTime__c = datetime.now().addDays(2).getTime();
                System.debug('acc.IPS_Creation_DateTime__c3'+ acc.IPS_Creation_DateTime__c);
                tobeUpdate.add(acc);
            }
            database.update(tobeUpdate);
        }
            
        if(addErrorSet.size() > 0)
        {
            for(Investment_Policy_Statement_IPS__c IPS : IPSList)
            {
                if(addErrorSet.contains(IPS.Client_Name__C))
                    IPS.addError('Action Not Allowed.');
            }        
        }    
    }
    public static Date lastDateOfFiscalQuarter()  // Set last day of Fiscal Year i.e 2018-03-31 ,2019-03-31
    {
       Integer YearEndMonth = 3;
        /*sysConstant = [Select ID, DeveloperName, Value__c From System_Constant__mdt where DeveloperName = 'Year_End_Month_Number'];        
        if(sysConstant != null && sysConstant.size() > 0){
            YearEndMonth = integer.valueof(sysConstant[0].Value__c);
        }*/
        
        date tday = system.today();
        Integer Addyear =  2;
        if(tday.month() >= 1 && tday.month() <= 3 )
            Addyear =  1;
        
    
        Date fiscalYearStartDate;
        if(YearEndMonth != null)
        {
            //if(system.today().month() >= (YearEndMonth))
            {
                fiscalYearStartDate = date.newinstance(system.today().year()+Addyear, YearEndMonth, 31);
            }
            /*else
            {
                fiscalYearStartDate = date.newinstance(system.today().year(), FiscalYearStartMonth -1, 31);
            }*/
        }
        Date lastDateOfThisQuarter = fiscalYearStartDate;
        System.debug('lastDateOfFiscalQuarter::lastDateOfThisQuarter'+lastDateOfThisQuarter);
        return lastDateOfThisQuarter;
    }
    public static void clientRiskCalculation(List<Investment_Policy_Statement_IPS__c > IPSList)
    {
     
        /*for(Investment_Policy_Statement_IPS__c IPS : IPSList){
            if(IPS.Risk_Rating_Total__c <= 20){
                IPS.Risk_Rating__c = 'Conservative';
            }else if(IPS.Risk_Rating_Total__c > 20 && IPS.Risk_Rating_Total__c <= 30){
                IPS.Risk_Rating__c = 'Balanced';
            }else if(IPS.Risk_Rating_Total__c > 30){
                IPS.Risk_Rating__c = 'Aggressive';
            }System.debug(' IPS.Risk_Rating__c'+ IPS.Risk_Rating__c);
            System.debug(' IPS.Risk_Rating_Total__c'+ IPS.Risk_Rating_Total__c);
        }      */  
        //update IPSList;    
        
        List<Account> updateAccountList = new List<Account>();
        List<Id> accIds = New List<Id>();
        for(Investment_Policy_Statement_IPS__c IPS : IPSList){
            accIds.add(IPS.Client_Name__C);
        }
        updateAccountList = [Select Id,Coverage__c,ownerId,Basic_Details_of_Mini_IPS_filled__c, Total_Investible_Assets__c ,Risk_Profile_Based_on_IPS__c,Lead_Database_Prvious_User__c From Account where Id IN : accIds];
        Set<Id> addErrorSet = new Set<Id>();
        for(Account acc : updateAccountList){                     
            if(acc.Coverage__c ==  'Lead Database' && acc.Lead_Database_Prvious_User__c ==  userinfo.getuserid()){
                  addErrorSet.add(acc.Id);
            }
        }
        if(addErrorSet.size() > 0){
            for(Investment_Policy_Statement_IPS__c IPS : IPSList){
                if(addErrorSet.contains(IPS.Client_Name__C))
                    IPS.addError('Action Not Allowed.');
            }        
        } 
    }
        
    public Static void CheckIPSRecord(List<Investment_Policy_Statement_IPS__c > IPSList)
    {
        List<Investment_Policy_Statement_IPS__c> checkIPSList = new List<Investment_Policy_Statement_IPS__c>();
        List<Id> ipsId = New List<Id>();
        for(Investment_Policy_Statement_IPS__c IPS : IPSList)
        {
            ipsId.add(IPS.Client_Name__C);
        }
        checkIPSList = [Select Id,Client_Name__C,Name From Investment_Policy_Statement_IPS__c where Client_Name__C IN : ipsId];
        
        if(checkIPSList != null && checkIPSList.size() > 0)
        {
            for(Investment_Policy_Statement_IPS__c IPS : IPSList)
            {
               IPS.addError('You Can Not Create New IPS For Same Client.');
            }
        }
    }
}