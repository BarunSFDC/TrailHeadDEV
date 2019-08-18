public with sharing class ResetPassword{
    public String userid{get;set;}
    public ResetPassword(){
        Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
        Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
        userid = pw.toString();
       // userid = ApexPages.currentPage().getParameters().get('uid');   
    }
 
    public PageReference login() {
         PageReference ref=null; 
         String userid1 = ApexPages.currentPage().getParameters().get('pg:fm:pb:uid');        
         String password = ApexPages.currentPage().getParameters().get('pg:fm:pb:pwd');  
         String password1 = ApexPages.currentPage().getParameters().get('pg:fm:pb:pwd1');  
         UserInfo__c auth ;
         Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
         try{
               auth= [Select UserId__c,Password__c,Type__c from UserInfo__c where  UserId__c=:userid LIMIT 1];
               Blob data = Blob.valueOf(password);
               String encryptedData = EncodingUtil.base64Encode(data);
               if(password !=  null && password==password1){
                    auth.Password__c=encryptedData;
                    auth.Change_Password__c=false;
                    update auth;
                    if(auth.UserId__c==userid &&  auth.Password__c==encryptedData){
                        if(auth.Type__c=='Faculty'){
                            ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                            ref = new PageReference('/apex/FacultyHomePage');    
                          //  ref.getParameters().put('Id',auth.UserId__c);
                            ref.setRedirect(true);
                        }else if(auth.Type__c=='Student'){
                            ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                            ref = new PageReference('/apex/StudentHome');
                           // ref.getParameters().put('Id',auth.UserId__c);
                            ref.setRedirect(true);
                        }else if(auth.Type__c=='Coordinator'){
                            System.debug('----I m her----');
                            ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
                            ref = new PageReference('/apex/CoordinatorHomePage');
                         //   ref.getParameters().put('Id',auth.UserId__c);
                            ref.setRedirect(true);
                        }  
                    }
              }else{
                  return null;
              }
        }catch(Exception e){
            System.debug(e);
        }
        return ref;     
    }
    
    //Test Method
    static testMethod void resetPassWordWith(){
         UserInfo__c cord = new UserInfo__c();
         cord.PIN__c=332244;
         cord.DOB__c=System.toDay();
         cord.First_Name__c='Barun';
         cord.Last_Name__c='Jena';
         cord.Mobile_No__c='1234567890';
         cord.Email_Id__c='baruna@ceptes.com';
         cord.Type__c='Student';
         Insert cord;  
         
         UserInfo__c co=[Select Id,Name,Password__c,UserId__c from UserInfo__c where Id=:cord.Id Limit 1];
         Blob data = Blob.valueOf(co.UserId__c);
         String encryptedData = EncodingUtil.base64Encode(data);             
         Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
         ApexPages.currentPage().setCookies(new Cookie[]{ctpuser}); 
         
         ResetPassword res= new ResetPassword();
         ApexPages.currentPage().getParameters().put('pg:fm:pb:uid',co.UserId__c);
         ApexPages.currentPage().getParameters().put('pg:fm:pb:pwd',co.Password__c);
         ApexPages.currentPage().getParameters().put('pg:fm:pb:pwd1',co.Password__c);
         res.login();      
         cord.Type__c='Faculty';
         update cord;   
         res.login();
         cord.Type__c='Coordinator';
         update cord;   
         res.login();
    }
    
 }