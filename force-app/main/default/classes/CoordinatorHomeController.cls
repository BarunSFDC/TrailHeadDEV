public class CoordinatorHomeController {
public CoordinatorHomeController(){
    
}
  
    //  Sign Out Page
    public PageReference doSignOut() {
        PageReference pgref1=new PageReference('/apex/LoginPage');
        pgref1.setRedirect(true);
        return pgref1;
     }
     
     static testMethod void CoHomeCont(){
         CoordinatorHomeController co=new CoordinatorHomeController();
         co.doSignOut();
     }
}