@isTest
private class AccountProcessorTest {
    
    @testSetup static void methodName() {
		
        Account acc = new Account(Name = 'Test 1');
        Insert acc;
        
        Contact con = new Contact(Lastname = 'Test Con', AccountId = acc.Id);
        Insert con;
        
        Account acc2 = new Account(Name = 'Test 2');
        Insert acc2;
        
        Contact con2 = new Contact(Lastname = 'Test Con2', AccountId = acc2.Id);
        Insert con2;
        
	}
    
    @isTest static void checkInvalidContatOnInsertTest(){
        
        List<Id> accIds = new List<Id>();
        for(Account acc :[SELECT Id FROM Account WHERE Name LIKE 'Test%' LIMIT 9999]){
        	accIds.add(acc.Id);
        }
        
        Test.startTest();
        AccountProcessor.countContacts(accIds);
        Test.stopTest();

        Account acc = [SELECT Id,Number_of_Contacts__c FROM Account WHERE Id = :accIds[0]];
        System.assertEquals(acc.Number_of_Contacts__c, 1);
        
    }    

}