@isTest
private class TestRestrictContactByName {
    
    @isTest static void checkInvalidContatOnInsertTest(){
        
        Contact con = new Contact();
        con.LastName = 'INVALIDNAME';
        
        try{
        	Insert con;
        }catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('The Last Name "'+con.LastName+'" is not allowed for DML'));
        }    
    }
    
     @isTest static void checkInvalidContatOnUpdateTest(){
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        
        try{
        	Insert con;
            
            con.LastName = 'INVALIDNAME';
            update con;
            
        }catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('The Last Name "'+con.LastName+'" is not allowed for DML'));
        }    
    }

}