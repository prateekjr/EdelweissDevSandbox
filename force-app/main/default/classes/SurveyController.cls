public class SurveyController {
    public String Query_Resolution{get;set;} 
    public String Query_Resolution_Rating{get;set;} 
    public String Satisfaction{get;set;} 
    public String overallRating{get;set;} 
    public String feedback{get;set;} 
    public String result{get;set;} 
    public Boolean render {get; set;}
    public String inputText1{get;set;} 
    public String inputText2{get;set;} 
    public Boolean successflag{get;set;}
    Public Boolean surveyFilled{get;set;}
    public SurveyController(){
        result = null;
        successflag  = false;
        String SurveyId = apexpages.currentpage().getparameters().get('surveyId');
		List<Survey__c> surveyList = [SELECT id,Query_Resolution__c,Satisfaction__c ,Feedback__c, account__c, Survey_Sent_Date__c FROM Survey__c WHERE id=:SurveyId AND IsSurveyFilled__c = true LIMIT 1];
 		 if(!surveyList.isEmpty()){
            surveyFilled = true;
         }
    }
    
    public void saveSurvey() {
        
        system.debug('result1 : '+ result);
		system.debug('successflag1 : '+successflag);
        String SurveyId = apexpages.currentpage().getparameters().get('surveyId');
        String accountId = apexpages.currentpage().getparameters().get('id');
        Query_Resolution = Apexpages.currentPage().getParameters().get('Query_Resolution');
       
        feedback = Apexpages.currentPage().getParameters().get('feedback');
        overallRating = Apexpages.currentPage().getParameters().get('overallRating');
        Query_Resolution_Rating = Apexpages.currentPage().getParameters().get('Query_Resolution_Rating');
        List<Survey__c> surveyList = [SELECT id,Query_Resolution__c,Satisfaction__c ,Feedback__c, account__c,IsSurveyFilled__c FROM Survey__c WHERE id=:SurveyId LIMIT 1];
        
        if(surveyList.isEmpty()){
            result = 'Oops! Something went wrong.';
        }else{
            Survey__c survey = surveyList[0];	
            render = true;
            survey.Query_Resolution__c = Query_Resolution;
            survey.Satisfaction__c = Satisfaction;
            survey.Feedback__c = feedback;
            survey.account__c = accountId;
            survey.Query_Resolution_Rating_reason__c = Query_Resolution_Rating;
            survey.Overall_Experience_Rating_Reson__c = overallRating;
            survey.IsSurveyFilled__c = true;
            survey.Feedback_received_date_time__c = System.now();
            Query_Resolution = '';
            Satisfaction = '';
            feedback = '';
            Query_Resolution_Rating = '';
            overallRating = '';
            System.debug('survey'+survey);
            List<Survey__c> s = new List<Survey__c>();
            s.add(survey);
            
            try{
                Database.SaveResult[] srList = Database.update(s, false);
                System.debug('srList'+srList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        system.debug('Inside success');
                        result = 'Thank you for your time! Your feedback is valued';
                        successflag = true;
                    } else {
                        system.debug('Inside Error');
                        result = 'Oops! Something went wrong. Please contact your financial advisor.';
                        successflag = false;
                    }
                }
            } catch (Exception e){
                result = e.getMessage();                
            }
            
        }
        system.debug('result : '+ result);
		system.debug('successflag : '+successflag);
    }

    public void yesClicked(){
        String feed=Apexpages.currentPage().getParameters().get('feedback');
        System.debug('Yes '+feed);
        feedback = feed;
    }
}