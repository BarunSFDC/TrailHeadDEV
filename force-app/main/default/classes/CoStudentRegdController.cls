public class CoStudentRegdController {

    public List<UserInfo__c> selectStudent { get; set;}
    public List<UserInfo__c> tempStuRec;
    public UserInfo__c uInfoStu{get;set;}
    public Student__c student {get; set;}
    public String selectBatch{get;set;}
    public String selectProgram {get; set;}
    public String selectCourse {get; set;}
    public Boolean viewStudent {get; set;}   
    public Lead Ld;
    public Boolean isErrorBat {get;set;}
    public Boolean isError {get;set;}   
    public Boolean showLead {get;set;}
    public Boolean showStudent {get; set;}   
    public String studId {get;set;} 
    public String name{get;set;}
    public String condtion{get;set;}
    public String text{get;set;}
    public List<Batch__c> batCrsPrgList;
    public List<SelectOption> programName{get;set;}
    public List<SelectOption> courseList{get;set;}
    public List<SelectOption> batchList{get;set;}
   
   
    // Default Constructor  
    public CoStudentRegdController() {
       this.student=new Student__c();
       this.uInfoStu=new UserInfo__c(); 
       totalStudent();
       this.showLead=true;
    }
   
    public void totalStudent(){
        selectStudent = new List<UserInfo__c>(); 
        try{           
            tempStuRec =  [SELECT Id,Name,First_Name__c,Last_Name__c,DOB__c,Date_Of_Joining__c,Gender__c,Marital_Status__c,Email_Id__c,Mobile_No__c,Address__c,
                            City__c,State__c,Pin__c,Language_Known__c from UserInfo__c where Type__c='Student'  order by  First_Name__c ]; 
            selectStudent.addAll(tempStuRec);        
            name='Name';
            text=null;
            condtion='Condition';
            batCrsPrgList = [Select Id,Name,CourseId__r.Id,CourseId__r.Name,CourseId__r.ProgramId__r.Id from Batch__c Order by CourseId__r.Name Limit 200];
        }catch(Exception e){}
    } 
     
    public void doFilter(){
        selectStudent = new List<UserInfo__c>(); 
        if(name == 'fName'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempStuRec){
                    if(b.First_Name__c == text)
                        selectStudent.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempStuRec){
                    if(b.First_Name__c.startsWith(text))
                        selectStudent.add(b);                    
                }    
            }
        }else if(name == 'lName'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempStuRec){
                    if(b.Last_Name__c == text)
                        selectStudent.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempStuRec){
                    if(b.Last_Name__c.startsWith(text))
                        selectStudent.add(b);     
                }
           }
        }else if(name == 'Email'){
            if(condtion == 'Equals to'){
                for(UserInfo__c b:tempStuRec){
                    if(b.Email_Id__c == text)
                        selectStudent.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(UserInfo__c b:tempStuRec){
                    if(b.Email_Id__c.startsWith(text))
                        selectStudent.add(b);     
                }
            }
        }
    }   
    
    public void allStudent(){
        totalStudent();
    }    
         
    // Create New Student
    public PageReference doNewStudent() {
        programName = new List<SelectOption>();
        List<Program__c> pList=[Select Id,Name from Program__c limit 200];
        for(Program__c p:pList)
            programName.add(new SelectOption(p.Id,p.Name));    
        this.uInfoStu=new UserInfo__c();
        this.student=new Student__c();
        selectProgram=null;
        selectBatch=null;
        this.showStudent = true;
        viewStudent = false;
        studId = null;
        return null;
    }                
    
    public void cancelCourseDetail(){
         showStudent=false;
         viewStudent = false;
     }
     
    // Get All Program Names           
    public void crsList(){
        String cname;
        courseList = new List<SelectOption>();
        for(Batch__c b:batCrsPrgList){
            if(b.CourseId__r.ProgramId__r.Id == selectProgram &&  cname != b.CourseId__r.Name){    
                courseList.add(new SelectOption(b.CourseId__r.Id,b.CourseId__r.Name));
                cname = b.CourseId__r.Name;
            }
        }
    } 
     
    // Get All Courses         
    public void batList(){
        batchList = new List<SelectOption>();
        for(Batch__c b:batCrsPrgList){
            if(b.CourseId__r.Id == selectCourse ){    
                batchList.add(new SelectOption(b.Id,b.Name));
            }
        }
    } 
          
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Direct','Direct'));
        options.add(new SelectOption('Instalment','Installment'));
        return options;
    }
       
    // Check for Lead               
    public void fromLead(){
        try{
         Ld=[SELECT Id,LastName,FirstName,Email,Phone,City,State from Lead where Email=:uInfoStu.Email_Id__c  LIMIT 1];
         }
         catch(Exception e){System.debug(e);}
         System.debug('Lead---------------------' +uInfoStu.Email_Id__c); 
        if(Ld != null) {
            uInfoStu.First_Name__c = Ld.FirstName;
            uInfoStu.Last_Name__c = Ld.LastName;
            uInfoStu.Mobile_No__c = Ld.Phone;
            uInfoStu.City__c=Ld.City;
            uInfoStu.State__c=Ld.State;
            isError = false;
            this.showLead = false; 
        }else{
            System.debug('...else...EmailId is..'+uInfoStu.Email_Id__c);
            isError=true;
        }
    }
    
    // Student Save Page           
    public void studentSave(){       
        Boolean flag = false;
        try{  
            System.debug('...studId..'+studId);
            if(studId == null){  
                List<UserInfo__c> uinfoList=[Select Id,Email_ID__c from UserInfo__c ];  
                for(UserInfo__c uinfo:uinfoList){
                    if(uinfo.Email_ID__c == uInfoStu.Email_ID__c){
                        flag = true;
                        uInfoStu.Email_ID__c = null;
                        break;
                    }
                }            
                if(flag){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Email Id is exist.'));
                    showStudent = true;
                }else if(selectBatch == null){
                    isErrorBat = true;
                }else{   
                    Integer led=[select count() from lead where Email=:uInfoStu.Email_Id__c  LIMIT 1];
                    if(led>0){
                        Ld = [select id,status from lead where Email=:uInfoStu.Email_Id__c  LIMIT 1];
                        Ld.status = 'Enrolled';
                        update Ld;
                    }
                    uInfoStu.Type__c='Student';
                    Upsert uInfoStu;
                    student.BatchId__c = selectBatch;
                    student.ProgramId__c=selectProgram;
                    student.CourseId__c=selectCourse;
                    student.UserInfoId__c=uInfoStu.Id;  
                    insert this.student;        
                    totalStudent();            
                    UserInfo__c uinf=[SELECT Id,UserId__c,Password__c from UserInfo__c where id=:uInfoStu.Id];
                    Blob pw = EncodingUtil.base64Decode(uinf.Password__c);
                    String decryptedPw = pw.toString();
                    // Student__c st=[Select Id,Name,SEmail_Id__c,loginId__c from Student__c where SEmail_Id__c=:uInfoStu.Email_Id__c Limit 1];
                    Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                    email.setSubject( 'Account Setup Notification');
                    email.setToAddresses( new String[]{uInfoStu.Email_Id__c} );
                    email.setPlainTextBody( 'Hello  '+uInfoStu.First_Name__c+'\n\n'+ 'Thank you for registering with us.\n\n Your unique user name is :\n\n User Name:  '+uInf.UserId__c+
                                          '\n\nYour Temporary Password:'+ decryptedPw +' \n\nNow get started by signing up online to view all  your course details and get updates on your course status.'+
                                          '\nFor queries related to account logins, please send email to'+
                                          '\n training@ceptes.com\n\n Happy learning \n\n Sincerely,\nCTP program team '+
                                          '\n Site link:  http://ctpauth-developer-edition.na12.force.com/ctp');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    showStudent = false; 
                    viewStudent = false;
                    isErrorBat =false; 
                  }
              }else{
                    update  student;
                    update  uInfoStu; 
                    totalStudent();
                    studId = null;  
                    showStudent = false;
                    viewStudent = false;
              }          
          }catch(Exception ex) {
              System.debug(ex);
          }      
    }      
   
    public void viewRecords(){
        editRecords(); 
        viewStudent = true;
        showStudent =false;        
     }
     
     public void editRecords(){
         for(UserInfo__c f:tempStuRec)
             if(f.Id == studId )
                 uInfoStu = f;
         try{                     
             student = [Select Id,Name,BatchId__c,BatchId__r.Name,ProgramId__c,CourseId__c,Highest_Qualification__c,Year_Of_Passing__c,University__c,PaymentType__c from Student__c where UserInfoId__r.Id =: studId Limit 1]; 
             selectBatch = student.BatchId__c;
             selectProgram=student.ProgramId__c;
             selectCourse=student.CourseId__c;
             showStudent = true; 
             viewStudent =false; 
         }catch(Exception e){}
     }
   
     public void deleteRecords(){
         System.debug('Student Id is+++++++++++++++++'+studId); 
         try{
             UserInfo__c uinfSt=[SELECT Id,First_Name__c from UserInfo__c where Id=:studId LIMIT 1];
             delete uinfSt;
             totalStudent();  
         } catch(Exception e){}
         showStudent = false;
    } 
    
    //Test Methods
      static testMethod void CoStudentRegdTest(){
        
        Program__c prg=new Program__c();
        prg.Name='ABCD';
        insert prg;
        
        Course__c crs=new Course__c();
        crs.Name='ABC';
        crs.ProgramId__c=prg.Id;
        insert crs;
        
         Session__c ss=new Session__c();
         ss.Session_Name__c='Introduction';
         ss.CourseId__c = crs.Id;
         ss.Session_Type__c='Development';
         ss.Duration_In_Hour__c='14';
         insert ss;   
        
        Batch__c bat=new Batch__c();
        bat.CourseId__c=crs.Id;
        bat.Name='Morning';
        bat.Start_Time__c='10:00AM';
        bat.End_Time__c='12:00PM';
        bat.Time_Diff__c = Double.valueOf(2);
        bat.WeekDay_Det__c = 'Mon;Tue;Wed;Thur;Fri;Sat;Sun  ';
        bat.Start_Date__c=System.toDay();
        insert bat;
                
        UserInfo__c st=new UserInfo__c();
        st.First_Name__c='Milan';
        st.Last_Name__c='Sanghani';
        st.Email_Id__c='Milan@ceptes.com';
        st.Mobile_No__c='1234567890';
        st.Pin__c=233455;
        st.Type__c = 'Student';
        Insert st; 
        
        Student__c std=new Student__c();       
        std.BatchId__c=bat.Id;
        std.UserInfoId__c=st.Id;
        Insert std;  
        
        CoStudentRegdController cstrg = new CoStudentRegdController();
            cstrg.totalStudent();
            cstrg.allStudent();
            cstrg.doNewStudent();
            cstrg.cancelCourseDetail();
            cstrg.crsList();
            cstrg.batList();
            cstrg.getItems();            
            
            cstrg.uInfoStu=[Select Id,Name,First_Name__c,Last_Name__c,Email_Id__c,Mobile_No__c,Pin__c,Type__c From UserInfo__c where id=:st.Id Limit 1]; 
            
            Lead ld = new Lead();
            ld.LastName = 'Sanghani';
            ld.FirstName= 'Ajit';
            ld.Company = 'ABC';
            ld.Email = st.Email_Id__c;
            ld.Phone = '4567787656';
            ld.City = 'Bangalore';
            ld.State ='Karnataka';
            ld.Status = 'Open';
            Insert ld;
            cstrg.fromLead();             
            cstrg.studentSave();
            
            cstrg.uInfoStu.Email_Id__c='chandu@gmail.com';
            cstrg.selectBatch=String.valueOf(bat.Id);
            cstrg.selectProgram=prg.Id;         
            cstrg.selectCourse=crs.Id;   
            cstrg.studentSave();
            
            cstrg.studId = st.Id;
            cstrg.studentSave();           
            cstrg.doFilter();
            cstrg.name = 'fName';
            cstrg.condtion = 'Equals to';
            cstrg.text = 'Milan';
            cstrg.doFilter();
            cstrg.condtion = 'Like';
            cstrg.doFilter();
            cstrg.name = 'lName';
            cstrg.condtion = 'Equals to';
            cstrg.text = 'Sanghani';
            cstrg.doFilter();
            cstrg.condtion = 'Like';
            cstrg.doFilter();
            cstrg.name = 'Email';
            cstrg.condtion = 'Equals to';
            cstrg.text = 'Milan@ceptes.com';
            cstrg.doFilter();   
            cstrg.condtion = 'Like';
            cstrg.text = 'Milan@ceptes.com'; 
            cstrg.doFilter();   
            cstrg.studId = st.Id;
            cstrg.viewRecords();
            cstrg.editRecords();
            cstrg.deleteRecords();
        } 
}