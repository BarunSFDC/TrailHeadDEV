public with sharing class DataArchiveController{
    
    
    public String objectAPIName {set;get;}
    public String searchableFields {set;get;}
    public Map<String,String> objectAPILabelMap {set;get;}
    public List<String> objectAPINames {set;get;}
    
    
    public DataArchiveController(){
        objectAPINames = new List<String>();
        for(string objectAPI : Schema.getGlobalDescribe().keyset()){
            if(objectAPI == 'account')
                objectAPINames.add(objectAPI);
        }
    }
    
    
    public void startArchivalProcess(){
        String commaSeparatedFields = '';
        Integer maxCharacters=0;
        if(objectAPIName != null && searchableFields != null){
            Map<String,Schema.SObjectField> objmap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
            for(String fieldName : objMap.keyset()){
                Schema.DescribeFieldResult fieldResult = objMap.get(fieldName).getDescribe();
                System.debug('------'+fieldResult.getName());
                if(fieldResult.isAccessible() && fieldResult.isUpdateable()){
                    commaSeparatedFields = commaSeparatedFields + fieldResult.getName() + ',';
                    maxCharacters = maxCharacters + fieldResult.getLength();
                }
            }
            commaSeparatedFields = commaSeparatedFields.removeEnd(',');
        }
        System.debug('------commaSeparatedFields------'+commaSeparatedFields);
        if(commaSeparatedFields != '')
            database.executeBatch(new ProcessArchivalRecords(objectAPIName,searchableFields,commaSeparatedFields,maxCharacters), 1000); 
    }

}