global class ScheduledMessanger implements Schedulable{


    public static void start() { 
            Datetime sysTime = System.now().addDays(1);       
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('ScheduledMessanger', chronExpression, new ScheduledMessanger());
    }
    
    global void execute(SchedulableContext SC) {    
            if(!isJobAlreadyRunning('MessagingBatch')){
                Type t = Type.forName('MessagingBatch');                  
                Database.Batchable<sObject> batch = (Database.Batchable<sObject>)t.newInstance();
                Database.executeBatch(batch);
            }
            
            
            // Abort job and start again
            System.abortJob( SC.getTriggerId() );  
            ScheduledMessanger.start();
            
        
    }
    
    public static boolean isJobAlreadyRunning(String apexClassName) {
        ApexClass batchApexClass = [Select Id From ApexClass Where Name = :apexClassName limit 1][0];
        List<AsyncApexJob> apexJobs = [Select Id, CompletedDate From AsyncApexJob Where JobType = 'BatchApex' AND ApexClassID = :batchApexClass.Id AND CompletedDate = null];
        if(apexJobs != null && apexJobs.size() > 0){
            return true;
        }   
        //check if more than 5 concurrant batch is running
        if(!([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5)) {
                return true;
        }
        return false; 
  }
}