public class CordFacultyRegdController {

    public List<UserInfo__c> selectFaculty { get; set;}
    public List<UserInfo__c> tempFacRec;
    public UserInfo__c uInfoFac{get;set;}
    public Faculty__c faculty {get; set;}
    public Boolean showFaculty {get; set;} 
    public String facId{get;set;}
    public String coid; 
    public Boolean viewFaculty{get;set;}
    public String name{get;set;}
    public String condtion{get;set;}
    public String text{get;set;}
    
    public CordFacultyRegdController() {
        Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
        Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
        coid = pw.toString();
        totalFacList();        
    }
    
    public void totalFacList(){
        selectFaculty = new List<UserInfo__c>(); 
        try{           
            tempFacRec =  [SELECT Id,Name,First_Name__c,Last_Name__c,DOB__c,Date_Of_Joining__c,Gender__c,Marital_Status__c,Email_Id__c,Mobile_No__c,Address__c,
                            City__c,State__c,Pin__c,Language_Known__c from UserInfo__c where Type__c='Faculty'  order by  First_Name__c ];  
            selectFaculty.addAll(tempFacRec);        
            name='Name';
            text=null;
            condtion='Condition';
        }catch(Exception e){}
    } 
     
    public void doFilter(){
        selectFaculty = new List<UserInfo__c>(); 
        if(name == 'fName'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempFacRec){
                    if(b.First_Name__c == text)
                        selectFaculty.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempFacRec){
                    if(b.First_Name__c.startsWith(text))
                        selectFaculty.add(b);                    
                }    
            }
        }else if(name == 'lName'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempFacRec){
                    if(b.Last_Name__c == text)
                        selectFaculty.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempFacRec){
                    if(b.Last_Name__c.startsWith(text))
                        selectFaculty.add(b);     
                }
           }
        }else if(name == 'Email'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempFacRec){
                    if(b.Email_Id__c == text)
                        selectFaculty.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempFacRec){
                    if(b.Email_Id__c.startsWith(text))
                        selectFaculty.add(b);     
                }
            }
        }
    }   
    
    public void allFaculty(){
        totalFacList();
    }    
     
    public void cancelCourseDetail(){
         showFaculty=false;
     }
     
    // Saving the Faculty Record    
    public void facultySavePage() {
        Boolean flag = false;
        try {
            if(facId == null){  
                List<UserInfo__c> uinfoList=[Select Id,Email_ID__c from UserInfo__c ];  
                System.debug('....uinfoList...'+uinfoList);
                for(UserInfo__c uinfo:uinfoList){
                    if(uinfo.Email_ID__c == uInfoFac.Email_ID__c){
                        flag = true;
                        uInfoFac.Email_ID__c = null;
                        break;
                    }
                }            
                if(flag){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Email Id is exist.'));
                    showFaculty = true;
                }else{           
                    Coordinator__c cord=[Select Id,Name from Coordinator__c where UserInfoId__r.UserId__c=:coid Limit 1]; 
                    uInfoFac.Type__c='faculty';
                    insert this.uInfoFac;
                    System.debug('.....uInfoFac....'+uInfoFac);
                    faculty.CoordinatorId__c=cord.Id;
                    faculty.UserInfoId__c=uInfoFac.Id;
                    insert this.faculty;
                    totalFacList();  
                    UserInfo__c uinfo=[Select Id,UserId__c,Password__c from UserInfo__c where id=:uInfoFac.Id limit 1];
                    Blob pw = EncodingUtil.base64Decode(uinfo.Password__c);
                    String decryptedPw = pw.toString();
                    
                    //  Sending Email                     
                    Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                    email.setSubject( 'Account Setup Notification');    
                    email.setToAddresses( new String[]{uInfoFac.Email_ID__c} );
                    email.setPlainTextBody( 'Hello  '+uInfoFac.First_Name__c+'\n\n'+ 'Thank you for Registering with us.\n\nYour UNIQUE User Name is :\n\nUser Name: '+uInfo.UserId__c+
                                      '\nDefault Password is:'+decryptedPw+
                                      '\n\nNow get started by signing up online to view all your course details and get updates on your course status.'+
                                      '\nFor queries related to account logins, Please Send Email to:'+
                                      '\ntraining@ceptes.com\n\nHappy Learning \n\nSincerely,\nCTP Program Team ');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
                    showFaculty = false;
                    viewFaculty = false;
                }
            }else{
                update  faculty;
                update  uInfoFac; 
                totalFacList();
                facId = null;  
                showFaculty = false;
                viewFaculty = false;              
            } 
        } catch(Exception e) {}        
    }
    
    
    // Cancel to Faculty Detail Page.
    public PageReference facultyCancelPage() {
        PageReference ref = new PageReference('/apex/FacultyRegdPage');
        ref.setRedirect(true);
        return ref;
    }  
      
  
   public PageReference doNewFaculty() {
        this.faculty = new Faculty__c();
        this.uInfoFac=new UserInfo__c();
        this.showFaculty = true;
        this.viewFaculty = false;
        facId = null;
        return null;
    }  
   
   public void viewRecords(){
       editRecords();
       this.showFaculty=false;
       this.viewFaculty=true;
   }
   
   public void editRecords(){
        for(UserInfo__c u:tempFacRec){
            if(u.Id == facId )
                uInfoFac = u;
        }    
        
        System.debug('facid........'+facid);        
        try{                      
            faculty = [Select Id,Name,Training_Experience__c,Technical_Experience__c,Work_Experience__c,Courses_Association__c
                            from Faculty__c where UserInfoId__r.Id=:facId Limit 1];
            this.showFaculty = true; 
            this.viewFaculty=false;           
        }catch(Exception e){}
   }
     
   public void deleteRecords(){          
     try{
         UserInfo__c uinffac=[SELECT Id,First_Name__c from UserInfo__c where Id=:facId LIMIT 1];
         delete uinffac; 
         totalFacList();  
         facId = null;      
     } catch(Exception e) {}
       showFaculty = false;
    
    }  
    
    //Test Methods
    static testMethod void CordFacultyRegdTest(){
            UserInfo__c fac = new UserInfo__c();
            fac.First_Name__c='Rakesh';
            fac.Last_Name__c='Prahaja';
            fac.Email_ID__c='baruna@ceptes.com';
            fac.DOB__c=System.toDay();
            fac.Mobile_No__c='1234567890';
            fac.PIN__c=332244;
            fac.Type__c='faculty';
            insert fac;            
           
            
            Coordinator__c cord = new Coordinator__c();
            cord.UserInfoId__c=fac.Id;
            Insert cord;
    
            Faculty__c facdet = new Faculty__c();
            facdet.UserInfoId__c=fac.Id;
            facdet.CoordinatorId__c=cord.Id;
            insert facdet;
                
              UserInfo__c co=[Select Id,Name,Email_ID__c,UserId__c from UserInfo__c where Id=:fac.Id Limit 1];
              
              Blob data = Blob.valueOf(co.UserId__c);
              String encryptedData = EncodingUtil.base64Encode(data);             
              Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
              ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});  
              CordFacultyRegdController CordFactRegd = new CordFacultyRegdController();              
              
              CordFactRegd.uInfoFac = new UserInfo__c();
              CordFactRegd.uInfoFac = fac;
              CordFactRegd.facultySavePage();   
              
              CordFactRegd.uInfoFac = new UserInfo__c();
              CordFactRegd.uInfoFac.Email_ID__c = 'milan@ceptes.com';
              CordFactRegd.uInfoFac.First_Name__c = 'AAAAAAAA';
              CordFactRegd.uInfoFac.Last_Name__c = 'BBBBBBBBB';
              CordFactRegd.uInfoFac.Mobile_No__c='1234967890';
              CordFactRegd.facultySavePage();
              
              CordFactRegd.facultyCancelPage();
              CordFactRegd.doNewFaculty();
              CordFactRegd.deleteRecords(); 
              CordFactRegd.totalFacList();
              CordFactRegd.name ='fName';
              CordFactRegd.condtion = 'Equals to';
              CordFactRegd.text = 'Rakesh';
           
              CordFactRegd.doFilter();
              CordFactRegd.condtion = 'Like';
              CordFactRegd.doFilter();
              CordFactRegd.name = 'lName';
              CordFactRegd.condtion = 'Equals to';
              CordFactRegd.text = 'Prahaja';
              CordFactRegd.doFilter();
              CordFactRegd.condtion = 'Like';
              CordFactRegd.doFilter();
              CordFactRegd.name = 'Email';
              CordFactRegd.condtion = 'Equals to';
              CordFactRegd.text = 'baruna@ceptes.com';
              CordFactRegd.doFilter();
              CordFactRegd.condtion = 'Like';
              CordFactRegd.doFilter();
              CordFactRegd.viewRecords();
              CordFactRegd.facId=fac.id;
              CordFactRegd.editRecords();
              CordFactRegd.cancelCourseDetail();
              CordFactRegd.allFaculty();     
        
        }
    
        static testMethod void CordFacultyRegdTest1(){
            UserInfo__c fac = new UserInfo__c();
            fac.First_Name__c='Rakesh';
            fac.Last_Name__c='Prahaja';
            fac.Email_ID__c='baruna@ceptes.com';
            fac.DOB__c=System.toDay();
            fac.Mobile_No__c='1234567890';
            fac.PIN__c=332244;
            fac.Type__c='faculty';
            insert fac;
            
            Coordinator__c cord = new Coordinator__c();
            cord.UserInfoId__c=fac.Id;
            Insert cord;
    
            Faculty__c facdet = new Faculty__c();
            facdet.UserInfoId__c=fac.Id;
            facdet.CoordinatorId__c=cord.Id;
            insert facdet;
                
              UserInfo__c co=[Select Id,Name,UserId__c from UserInfo__c where Id=:fac.Id Limit 1];
              Blob data = Blob.valueOf(co.UserId__c);
              String encryptedData = EncodingUtil.base64Encode(data);             
              Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
              ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});  
              CordFacultyRegdController CordFactRegd = new CordFacultyRegdController();
              CordFactRegd.facultySavePage();
              CordFactRegd.facultyCancelPage();
              CordFactRegd.doNewFaculty();
              CordFactRegd.deleteRecords(); 
              CordFactRegd.totalFacList();
              CordFactRegd.condtion = 'Like';
              CordFactRegd.text = 'Rakesh';
              CordFactRegd.doFilter();
              CordFactRegd.viewRecords();
              CordFactRegd.editRecords();
              CordFactRegd.cancelCourseDetail();
              CordFactRegd.allFaculty();     
        
        }
 
}