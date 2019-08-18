public class SendLinkController {
public List<StudentDet> studentRec{get;set;}
public String courseId{get;set;}
public String batchId{get;set;}
public String setId{get;set;}
public List<SelectOption> batchDet{get;set;}
public List<SelectOption> questionSet{get;set;}
public List<SelectOption> courseDet{get;set;}
public Boolean isError{get;set;}
public String fid;
public Boolean showSection{get;set;}

    public SendLinkController(){
        isError=false;
        showSection=false;
        courseDet = new List<SelectOption>();        
        List<Course__c> cList;
        try{
            cList=[SELECT Id,Name from Course__c Limit 200];
        }catch(Exception e){}
        for(Course__C c:cList)
            courseDet.add(new SelectOption(c.Id,c.Name));        
    }
        
    public void showBatch(){
        showSection=false;
        batchDet =new List<SelectOption>();
        questionSet= new List<SelectOption>();
        List<Batch__c> bList=[Select Id,Name from Batch__c where CourseId__c =: courseId Limit 50]; 
        List<Question_set__c> qList=[Select Id,Name from Question_set__c where CourseId__c =: courseId Limit 20];
        for(Batch__c b:bList)
            batchDet.add(new SelectOption(b.Id,b.Name));
        for(Question_set__c q:qList)
            questionSet.add(new SelectOption(q.Id,q.Name));
    }
    
    public void showStudent(){
        showSection=true;
        studentRec = new List<StudentDet>();
        try{          
            List<Student__c> sList=[Select Id,Name,Exam_Link__c,Question_Set_Id__c,UserInfoId__c,UserInfoId__r.Email_Id__c,UserInfoId__r.First_Name__c,UserInfoId__r.Last_Name__c from Student__c where BatchId__c =:batchId AND Exam_Link__c = null Limit 200];
            for(Student__c st:sList)
                    studentRec.add(new StudentDet(st)); 
        }catch(Exception e){}          
         
    }
    
    public void checkQuestionSet(){
        isError=false;
    }
    
    public void sendLinksToStudents(){
        if(setId != null){
            isError = false; 
            try{
                for(StudentDet st:studentRec){
                    if(st.check == true){
                        st.stuRec.Exam_Link__c = 'Link'; 
                        st.stuRec.Question_Set_Id__c = setId;      
                        upsert st.stuRec;
                        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                        email.setSubject( 'Prepared Exam');
                        email.setToAddresses( new String[]{st.stuRec.UserInfoId__r.Email_Id__c});
                        email.setPlainTextBody('Examination link has been sent to your home page.You can click the link and attend the exam.');
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });                        
                    }
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Links has been sent to all students.'));
            }catch(Exception e){ApexPages.addMessages(e);}
        }else
            isError = true;
    }
    
    public void refreshPage(){
        isError=false;
        showSection=false;
        courseId = null;    
        batchDet =new List<SelectOption>();
        questionSet= new List<SelectOption>();
        studentRec = new List<StudentDet>();
    }
    
    public class StudentDet{
        public Boolean check{get;set;}
        public Student__c stuRec{get;set;}
        public StudentDet(Student__c st){
            check=false;
            stuRec= st;
        }
    }
    
    //test Method
     static testMethod void testSendLink(){
        UserInfo__c fac = new UserInfo__c();
        fac.First_Name__c='Rakesh';
        fac.Last_Name__c='Prahaja';
        fac.Email_ID__c='baruna@ceptes.com';
        fac.DOB__c=System.toDay();
        fac.Mobile_No__c='1234567890';
        fac.PIN__c=332244;
        fac.Type__c='faculty';
        insert fac;                   
    
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
        
        Question_Set__c qset = new Question_Set__c();
        qset.Name = 'Dev_T2';
        qset.CourseId__c = crs.Id;
        qset.Passing_Mark__c = 60.0;
        qset.Total_Questions__c = 10.0;
        qset.Exam_Duration_in_minute__c = 10.0;
        insert qset;
        
        Student__c std=new Student__c();       
        std.BatchId__c=bat.Id;
        std.UserInfoId__c=fac.Id;
        std.Exam_Link__c = ' ';
        std.Question_Set_Id__c = 'qset.Id'; 
        Insert std; 
        
        
        Batch__c bh = [Select Id,Name from Batch__c where CourseId__c =: crs.Id];
        Question_set__c qst= [Select Id,Name from Question_set__c where CourseId__c =: crs.Id];
        Student__c stList = [Select Id,Name,BatchId__c,Exam_Link__c,Question_Set_Id__c,UserInfoId__c,UserInfoId__r.Email_Id__c,UserInfoId__r.First_Name__c,UserInfoId__r.Last_Name__c from Student__c where BatchId__c =:bat.Id AND Exam_Link__c = null];
        SendLinkController slc = new SendLinkController();
         slc.courseId = crs.Id;
         slc.showBatch();
         slc.batchId = bat.Id;
         slc.showStudent();
         slc.studentRec[0].check = true;
         slc.checkQuestionSet();
         slc.sendLinksToStudents();
         slc.setId ='ABC';
         slc.sendLinksToStudents();
         slc.refreshPage();
         
    }
}