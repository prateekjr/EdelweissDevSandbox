public class VideoPlayController {
    public String versionData{get;set;} 
    public String VideoURL1 {get;set;} 	
    public String VideoURL2 {get;set;} 	
    public String VideoURL3 {get;set;} 
    public String VideoURL4 {get;set;}
   	public String VideoURL5 {get;set;} 	
    public String VideoURL6 {get;set;} 	
    public String VideoURL7 {get;set;} 
    public String VideoURL8 {get;set;}     
    public String VideoURL9 {get;set;}  
    public String VideoURL10 {get;set;}  
    public String VideoURL11 {get;set;}  
    public String VideoURL12 {get;set;}  
    public String VideoURL13 {get;set;}  
    public String VideoURL14 {get;set;}  
    public String VideoURL15 {get;set;}  
    public String VideoURL16 {get;set;}  
    public String VideoURL17 {get;set;}  
    public String VideoURL18 {get;set;}  
    public String VideoURL19 {get;set;}  
    public String VideoURL20 {get;set;}  
    public  VideoPlayController(){
        Sys_Properties__c URL1 = Sys_Properties__c.getValues('Youtube Video URL 1');
        VideoURL1 = String.valueOf(URL1.Value__c);
        Sys_Properties__c URL2 = Sys_Properties__c.getValues('Youtube Video URL 2');
        VideoURL2 = String.valueOf(URL2.Value__c);
        Sys_Properties__c URL3 = Sys_Properties__c.getValues('Youtube Video URL 3');
        VideoURL3 = String.valueOf(URL3.Value__c);
        Sys_Properties__c URL4 = Sys_Properties__c.getValues('Youtube Video URL 4');
        VideoURL4 = String.valueOf(URL4.Value__c);
        Sys_Properties__c URL5 = Sys_Properties__c.getValues('Youtube Video URL 5');
        VideoURL5 = String.valueOf(URL5.Value__c);
        Sys_Properties__c URL6 = Sys_Properties__c.getValues('Youtube Video URL 6');
        VideoURL6 = String.valueOf(URL6.Value__c);
        Sys_Properties__c URL7 = Sys_Properties__c.getValues('Youtube Video URL 7');
        VideoURL7 = String.valueOf(URL7.Value__c);
        Sys_Properties__c URL8 = Sys_Properties__c.getValues('Youtube Video URL 8');
        VideoURL8 = String.valueOf(URL8.Value__c);
        Sys_Properties__c URL9 = Sys_Properties__c.getValues('Youtube Video URL 9');
        VideoURL9 = String.valueOf(URL9.Value__c);
        Sys_Properties__c URL10 = Sys_Properties__c.getValues('Youtube Video URL 10');
        VideoURL10 = String.valueOf(URL10.Value__c);
        Sys_Properties__c URL11 = Sys_Properties__c.getValues('Youtube Video URL 11');
        VideoURL11 = String.valueOf(URL11.Value__c);
        Sys_Properties__c URL12 = Sys_Properties__c.getValues('Youtube Video URL 12');
        VideoURL12 = String.valueOf(URL12.Value__c);
        Sys_Properties__c URL13 = Sys_Properties__c.getValues('Youtube Video URL 13');
        VideoURL13 = String.valueOf(URL13.Value__c);
        Sys_Properties__c URL14 = Sys_Properties__c.getValues('Youtube Video URL 14');
        VideoURL14 = String.valueOf(URL14.Value__c);
        Sys_Properties__c URL15 = Sys_Properties__c.getValues('Youtube Video URL 15');
        VideoURL15 = String.valueOf(URL15.Value__c);
        Sys_Properties__c URL16 = Sys_Properties__c.getValues('Youtube Video URL 16');
        VideoURL16 = String.valueOf(URL16.Value__c);
        Sys_Properties__c URL17 = Sys_Properties__c.getValues('Youtube Video URL 17');
        VideoURL17 = String.valueOf(URL17.Value__c);
        Sys_Properties__c URL18 = Sys_Properties__c.getValues('Youtube Video URL 18');
        VideoURL18 = String.valueOf(URL18.Value__c);
        Sys_Properties__c URL19 = Sys_Properties__c.getValues('Youtube Video URL 19');
        VideoURL19 = String.valueOf(URL19.Value__c);
        Sys_Properties__c URL20 = Sys_Properties__c.getValues('Youtube Video URL 20');
        VideoURL20 = String.valueOf(URL20.Value__c);
        
    }    
}