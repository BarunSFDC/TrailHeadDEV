public class AccountProcessor {
	
    @future
    public static void countContacts(List<Id> accountIds){
        
        if(accountIds != null && accountIds.size() > 0){
            
            List<Account> accounts = [SELECT Id,Number_of_Contacts__c ,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIds];
            for(Account acc :accounts){
                acc.Number_of_Contacts__c = acc.Contacts != null ? acc.Contacts.size() : 0;
            }
            
            update accounts;
        }
    } 
}