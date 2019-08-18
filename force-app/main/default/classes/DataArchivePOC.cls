public class DataArchivePOC{
    public DataArchivePOC() {
       List<Contact> cons = [SELECT Id,Name,OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Level__c, Languages__c FROM Contact ORDER BY CreatedDate ASC];
       Map<Integer,String> indDataMap = new Map<Integer,String>();
        
        String fset = 'Id, Name, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Level__c, Languages__c';
        
        
        Integer recCount = 1;
        
        for(Contact con : cons){
            String csData = '';
            for(String fld : fset.split(',')){
                fld = fld.trim();
                String val = con.get(fld) == null ? '' : String.valueOf(con.get(fld));
                csData = csData + (csData == '' ? val : ',' + val);
            }
            indDataMap.put(recCount,csData);
            recCount++;
        
        }
        System.debug('--indDataMap--'+indDataMap);
        System.debug('--indDataMap json--'+JSON.serialize(indDataMap));  

    }
}