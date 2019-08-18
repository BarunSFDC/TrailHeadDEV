public class ContactSearch {

    public static List<Contact> searchForContacts(String lastName, String mailingCode){
        
        return [SELECT Id,Name FROM Contact WHERE LastName =:lastName AND MailingPostalCode =:mailingCode];
    }
}