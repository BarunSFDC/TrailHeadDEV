public class ContactAndLeadSearch {

    public static List<List<sObject>> searchContactsAndLeads(String input){
        
        return [FIND 'Smith' IN ALL FIELDS RETURNING Contact(FirstName,LastName), Lead(FirstName,LastName)];
    }
}