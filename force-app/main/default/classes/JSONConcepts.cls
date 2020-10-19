public with sharing class JSONConcepts {

    public String name {get;set;}
    public Integer age {get;set;}
    public Car car {get;set;}
    
    public class Car {
      public String model {get;set;}
      public String year {get;set;}
    }
}