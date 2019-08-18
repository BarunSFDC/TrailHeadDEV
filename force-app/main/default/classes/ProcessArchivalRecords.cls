public class ProcessArchivalRecords implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

    String queryString;
    String objectAPI;
    String searchableFields;
    Integer maxCharacters;
    
    public ProcessArchivalRecords(String objectAPIName,String searchableFieldNames,String commaSeparatedAPINames, Integer maxChar){
        queryString =  commaSeparatedAPINames;  
        objectAPI = objectAPIName;
        searchableFields = searchableFieldNames;
        maxCharacters = maxChar;
    }
        
    public Database.QueryLocator start(Database.BatchableContext BC){
        queryString = 'Select '+queryString+' From '+objectAPI;
        System.debug('-----queryString----'+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sobject> scope){
        for(sobject sobj : scope){
            System.debug('-----sobj----'+sobj);
        }    
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}