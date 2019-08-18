public class DataArchive{
    
    public void getSearchedRecords(String objApi,String searchString){
        List<Data_Pocket__c> dps = [SELECT Id, Record_Index__c, Search_Data_Mapping__c  FROM Data_Pocket__c Where Object_Type__c = :objApi];
        Set<Integer> indexSet = new Set<Integer>();
        
        // Get all possibility record indexes
        for(Data_Pocket__c dp : dps){
            indexSet.addAll(getSearchIndexes(searchString,dp.Search_Data_Mapping__c));
        }
        
        System.debug('----indexSet----'+indexSet);
        
        if(indexSet.size() > 0){
            Map<String,Set<Integer>> fldApiIndMap = new Map<String,Set<Integer>>();
            for(Data_Pocket__c dp : dps){
                if(dp.Record_Index__c != null){
                    Map<String,String> fieldIndMap = (Map<String,String>)JSON.Deserialize(dp.Record_Index__c,Map<String,String>.class);
                    System.debug('-----fieldIndMap----'+fieldIndMap);
                    for(String fld : fieldIndMap.keySet()){
                        Integer lowerBound = Integer.valueOf(fieldIndMap.get(fld).subStringBefore('-'));
                        Integer upperBound = Integer.valueOf(fieldIndMap.get(fld).subStringAfter('-'));
                        Set<Integer> indexes = new Set<Integer>();
                        for(Integer dataPoint : indexSet){
                            if(dataPoint >= lowerBound && dataPoint <= upperBound){
                                indexes.add(dataPoint);
                            }    
                        }
                        if(indexes.size() > 0){
                            Set<Integer> IndSet = fldApiIndMap.containsKey(fld) ? fldApiIndMap.get(fld) : new Set<Integer>();
                            IndSet.addAll(indexes); 
                            fldApiIndMap.put(fld,IndSet);
                        }
                    }
                }
            }
            
            System.debug('------fldApiIndMap----'+fldApiIndMap);
            
            if(fldApiIndMap.keySet().size() > 0){
                String queryString = getQueryString(fldApiIndMap.keySet());
                queryString = 'Select Field_Set__c, '+queryString+' From Data_Pocket__c Where Object_Type__c =\''+objApi+'\'';
                System.debug('-----queryString----'+queryString);
                List<Map<String,String>> records = new List<Map<String,String>>();
                for(Data_Pocket__c dp : Database.query(queryString)){
                    for(String fld : fldApiIndMap.keySet()){
                        System.debug('--------fld----'+fld);
                        System.debug('--------indexes----'+fldApiIndMap.get(fld));
                        Map<Integer,String> indDataMap = (Map<Integer,String>)JSON.Deserialize(String.valueOf(dp.get(fld)),Map<Integer,String>.class);
                        System.debug('--------indDataMap----'+indDataMap.keySet());
                        for(Integer ind : fldApiIndMap.get(fld)){
                            records.add(getRecordJson(String.valueOf(dp.get('Field_Set__c')),indDataMap.get(ind)));
                        }
                    }
                }
            }
            
            
            System.debug('----fldApiIndMap.keySet()----'+fldApiIndMap.keySet());
        }else{
            // No records found
        }
    }

    
    private Set<Integer> getSearchIndexes(String srchStr,String dataString){
        String qoutedStr = '"'+srchStr+'"';
        Set<Integer> containsStrs = new Set<Integer>();
        if(dataString.containsIgnoreCase(qoutedStr)){
            List<String> splittedList = dataString.split(qoutedStr);
            for(Integer ind = 0; ind < (splittedList.size() - 1) ; ind++){
                String str = splittedList[ind];
                String subAfter = str.countMatches(':') == 1 ? str.subStringBetween('{',':') :  str.substringAfterLast('],');
                System.debug('---subAfter---'+subAfter);
                if(subAfter != null && subAfter.length() > 0 ){
                    containsStrs.add(Integer.valueOf(subAfter.subStringBetween('"','"')));
                }
            }
            
        }
        System.debug('---containsStrs---'+containsStrs);
        return containsStrs;
    }
    
    private String getQueryString(Set<String> dataContainsfldSet){
        String flds = '';
        for(String fld : dataContainsfldSet){
            flds = flds+fld+',';
        }
        return flds.removeEnd(',');
    }
    
    private Map<String,String> getRecordJson(String flds,String recordDet){
        System.debug('----flds----'+flds);
        System.debug('----recordDet----'+recordDet);
        System.debug('----flds size----'+flds.split(',').size());
        System.debug('----recordDet--size--'+recordDet.split(',').size());
        return null;
    }

}