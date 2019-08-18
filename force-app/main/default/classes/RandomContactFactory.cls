public class RandomContactFactory {
    
    public static List<Contact> generateRandomContacts(Integer noOfContacts, String lastName){
        
        List<Contact> contactList = new List<Contact>();
        
        if(noOfContacts > 0 && lastName != null){
            
            for(Integer i=1; i <= noOfContacts; i++){
            	contactList.add(new Contact(
                		LastName = lastName,
                    	FirstName = 'Test '+String.valueOf(i)
                	)
                );
            }    
        }
        
        return contactList;
    } 

}