@isTest
private class LeadProcessorTest {
    
    @testSetup static void generateLeadTest() {
        
        Lead lead1 = new Lead(LastName = 'Test Lead 1', LeadSource = 'SFDC', Company = 'Salesforce');
        Lead lead2 = new Lead(LastName = 'Test Lead 2', LeadSource = 'SFDC2', Company = 'Salesforce');
        
        List<Lead> leads = new List<Lead>();
        leads.add(lead1);
        leads.add(lead2);
        
        Insert leads;
        
    }
    
    @isTest static void checkInvalidContatOnInsertTest(){
        
        Test.startTest();
        Database.executeBatch(new LeadProcessor(), 200);
        Test.stopTest();
        
        Lead lead = [SELECT Id,LeadSource FROM Lead LIMIT 1];
        System.assertEquals(lead.LeadSource, 'Dreamforce');
        
    } 
    
}