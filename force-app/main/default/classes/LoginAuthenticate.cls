public   class  LoginAuthenticate {

    public Boolean forgot{get;set;}
    public Boolean isError{get;set;}
    public Boolean checkmail{get;set;}
    public String userid {get;set;}
    public String errorMessage{get;set;}
    public String emailMessage{get;set;}
    public Boolean errMessage{get;set;}
    public String takeId{get;set;}
  
    public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Admin','Admin'));  
    options.add(new SelectOption('Coordinator','Coordinator')); 
    options.add(new SelectOption('Faculty','Faculty'));
    options.add(new SelectOption('Student','Student'));
    return options; 
    }  

    public PageReference login() {   
        String password = ApexPages.currentPage().getParameters().get('pg:fm:pwd');
        PageReference ref = null;
        UserInfo__c  auth;
         try{
             if(takeId=='Admin'){
                //Redirect to Salesforce Loginpage.
                ref = new PageReference('https://login.salesforce.com/');
                ref.setRedirect(true);
             }
             auth  = [Select UserId__c,Password__c,Type__c,Change_Password__c,UserSuspend__c,UserRevoked__c from UserInfo__c where  UserId__c=:userid LIMIT 1];
                         
             //....Cookie .........
             Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
              if (ctpuser == null) {
                  ref = new PageReference('/apex/LoginPage');
                  ref.setRedirect(true);
              }                 
                 if(auth.Password__c != null){
                     Blob pw = EncodingUtil.base64Decode(auth.Password__c);
                     String decryptedPw = pw.toString();
                     Blob data = Blob.valueOf(userid);
                     String encryptedData = EncodingUtil.base64Encode(data);
                     ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false);
                     System.debug('..........decryptedPw.....'+decryptedPw+'........'+password);
                     if(decryptedPw != null && decryptedPw == password){
                         if(auth.Change_Password__c){
                             //redirect to reset password pagepublic class LoginAuthenticate 
                             System.debug('I mn here...');
                             ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                             ref = new PageReference('/apex/SignUpPage');
                             ref.setRedirect(true);
                         }else{
                            if(auth.UserRevoked__c==true){
                               isError = true;
                               errorMessage = 'User Revoked.';
                            }else if(auth.UserSuspend__c==true){
                                isError = true;
                                errorMessage = 'User Suspended.';
                            }else if(auth.Type__c=='Faculty' && takeId=='Faculty'){
                                    ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                                    ref = new PageReference('/apex/FacultyHomePage');
                                    ref.setRedirect(true);
                                    
                             } else if(auth.Type__c=='Student' && takeId=='Student'){
                                    ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                                    ref = new PageReference('/apex/StudentHome');
                                    ref.setRedirect(true);
                             } else if(auth.Type__c=='Coordinator' && takeId=='Coordinator'){
                                    ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                                    ref = new PageReference('/apex/CoordinatorHomePage');
                                    ref.setRedirect(true);
                             } else{
                                    isError = true;
                                    errorMessage = 'Select Proper User Type.'; 
                             }
                         }
                      }else{
                          isError = true;
                          errorMessage = 'Invalid Password. Enter valid password.';
                          forgot = true;
                     }
                 }else{
                      isError = true;
                      errorMessage = 'Try with your default Password.';
                      forgot = true;
                 }
             
         }catch(Exception e){
             System.debug(e);
              isError = true;
              errorMessage = 'User does not exist. Enter valid user.';
         }
        return ref; 
   }
    
   public void forgotPassword(){
        isError = false;  
        String uname;       
        UserInfo__c  auth;        
        try{
            auth  = [Select UserId__c,Password__c,First_Name__c,Type__c,Last_Name__c,Change_Password__c,Email_Id__c from UserInfo__c where  UserId__c=:userid LIMIT 1];
            String fname=auth.First_Name__c.substring(0,2);
            String lname=auth.Last_Name__c.substring(0,2);            
            uname=fname+lname+String.valueof(auth.Email_Id__c.length());
            Blob pw = Blob.valueOf(uname);
            String encryptedPw = EncodingUtil.base64Encode(pw); 
            auth.password__c=encryptedPw;
            auth.Change_Password__c=true; 
            update auth;
        }catch(Exception e){
            isError = true;
            errorMessage ='Invalid User';
        }
        if(auth != null){
            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
            email.setSubject( 'Your request for password');
            email.setPlainTextBody( 'Hi! your temporary password is :'+uname);
            email.setToAddresses( new String[]{auth.Email_Id__c} );
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }catch(Exception e){
                isError = true;
                errorMessage = 'Error in sending the mail.';
            }
            if(!isError){
                errMessage=true;
                emailMessage = 'A mail has been sent to your mail id with new password'; 
            }
        }
    }

   
   // Test Methods    
    static testMethod void TestLoginAuthenticate(){
        
            UserInfo__c fac = new UserInfo__c();
            fac.First_Name__c='Rakesh';
            fac.Last_Name__c='Prahaja';
            fac.Email_ID__c='asdf@ceptes.com';
            fac.DOB__c=System.toDay();
            fac.Mobile_No__c='1234567890';
            fac.PIN__c=332244;
            fac.UserSuspend__c = true;
            fac.UserRevoked__c = true;
         
            fac.Type__c = 'Faculty'; 
          
          //  fac.Type__c = 'Coordinator';            
            insert fac;                  
            UserInfo__c co=[Select Id,Type__c,Change_Password__c,Name,Email_ID__c,UserId__c, Password__c, UserSuspend__c,UserRevoked__c from UserInfo__c where Id=:fac.Id limit 1];
                                  
            Blob data = Blob.valueOf(co.UserId__c);
            String encryptedData = EncodingUtil.base64Encode(data);               
            Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
            ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});   
            
            LoginAuthenticate log=new LoginAuthenticate();        
            log.userid = co.UserId__c;
            log.takeId ='Faculty';    
            Blob pw = EncodingUtil.base64Decode(co.Password__c);
            String decryptedPw = pw.toString();
            ApexPages.currentPage().getParameters().put('pg:fm:pwd',decryptedPw);            
            log.login();  
            
            if(co.Change_Password__c){
                co.Change_Password__c = false;
                update co;
            }
            log.login();
            if(co.UserRevoked__c){
                co.UserRevoked__c = false;
                update co;
            }
            log.login();                
            if(co.UserSuspend__c){
                co.UserSuspend__c = false;
                update co;
            }
            log.login();           
            log.takeId = 'Student';
            co.Type__c = 'Student'; 
            update co;              
            log.login();
           
            log.takeId = 'Admin';
            co.Type__c = 'Admin'; 
            update co;              
            log.login();
            
            co.Type__c = 'Coordinator'; 
            log.takeId = 'Coordinator';
            update co;      
            log.login();           
          
            
            co.Password__c='';
            update co;                   
            log.login();  
            
            log.forgotPassword();
            log.getItems();
        }       
}