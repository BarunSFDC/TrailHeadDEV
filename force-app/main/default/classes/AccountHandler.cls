public class AccountHandler {

    public static Account insertNewAccount(String accountName){
        
        try{
            Account acc = new Account(Name=accountName);
            Insert acc;
            System.debug('----First POC on GIT- with some comments----');
            System.debug('----Swecond POC on GIT- with some comments----');
            return acc;
        }catch(Exception e){
            return null;
        }
    }
}