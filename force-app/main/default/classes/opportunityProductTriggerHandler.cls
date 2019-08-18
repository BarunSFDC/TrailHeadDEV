public class opportunityProductTriggerHandler {
    
 public static void isAfterInsert(List<OpportunityLineItem> lstOpportunityLineItemsNew ){
       
       
        Map<String, POR_Summary__c> mapPorSummary = new Map<String, POR_Summary__c>();
        Set<String> oppMonthYear = new Set<String>();
        
        for(OpportunityLineItem objOppLineItem : lstOpportunityLineItemsNew){
            oppMonthYear.add(objOppLineItem.Opportunity_Month_Year__c );
        }
        
        for(POR_Summary__c objPORSummary : [SELECT Id, Service_Start_Date__c, Service_End_Date__c, Total_Discount__c, Total_Amount__c, Opportunity_Month_Year1__c FROM POR_Summary__c 
                                            WHERE Opportunity_Month_Year1__c IN : oppMonthYear]){
        }
        
        for(OpportunityLineItem objOppLineItem : lstOpportunityLineItemsNew){
            
           
                POR_Summary__c objPORSummary = new POR_Summary__c();
                objPORSummary.Service_Start_Date__c = objOppLineItem.ServiceDate ;
              // objPORSummary.Service_End_Date__c = objOppLineItem.Service_End_Date1__c;
                objPORSummary.Total_Amount__c = objOppLineItem.ListPrice ;
               // objPORSummary.Total_Discount__c = objOppLineItem.Discount;
				objPORSummary.Opportunity__c    =  objOppLineItem.OpportunityId;           
                mapPorSummary.put(objOppLineItem.Opportunity_Month_Year__c, objPORSummary);
                
            }    
}
}