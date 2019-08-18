Public class StudentController{
    public String sid{get;set;}
    public Student__c uinfo{get;set;}
    public Boolean timeUp{get;set;}
    public Boolean isError{get;set;}
    public Date today{get;set;}
    public Integer newlypost{get;set;}
    public StudentController() {
        Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
        Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
        sid = pw.toString(); 
        isError=false; 
        today = System.toDay();       
        try{
            uinfo=[Select Id,Name,BatchId__c,Exam_Link__c,Question_Set_Id__c,UserInfoId__r.Type__C,UserInfoId__r.First_Name__c,UserInfoId__r.Last_Name__c,UserInfoId__r.Mobile_No__c,UserInfoId__r.Email_Id__c from Student__c where UserInfoId__r.UserId__c=:sid];           
            List<Ctp_QPost_Related__c> cqrlst=[Select Id,Assigned_Id__c from Ctp_QPost_Related__c where Ctp_Query_PortalId__r.Ctp_StudentId__c=:uinfo.Id AND Stud_Post_Read__c = 'Unread' AND Ctp_Query_PortalId__r.Qp_Stataus__c ='Open'  limit 100];
            newlypost = cqrlst.size();
            if(uinfo.Exam_Link__c == 'Link' || uinfo.Exam_Link__c == 'In Progress')
                timeUp=true;
            else
                timeUp=false;
        }catch(Exception e){}    
    }
   
    public PageReference doExam() {    
        PageReference pgref;
        if(uinfo.Question_Set_Id__c != null){
            if(uinfo.Exam_Link__c == 'Link'){           
                uinfo.Exam_Link__c = 'In Progress';
                try{
                    update uinfo;
                }catch(Exception e){}
                
                pgref=new PageReference('/apex/ExamSheet');
                pgref.getParameters().put('id', uinfo.Question_Set_Id__c);               
                pgref.setRedirect(true);
            }else if(uinfo.Exam_Link__c == 'In Progress'){
                isError=true;
            }else
                isError=false; 
        }
        return pgref;
    }
    
    public PageReference doLogout(){
        PageReference pgref=new PageReference('/apex/loginpage');
        pgref.setRedirect(true);
        return pgref;
    }
    
  
    //test method here

    static testMethod void studentTest(){        
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
            
            
            List<Question_Bank__c> qbnk = new List<Question_Bank__c>();             
            for(Integer i=0;i<3;i++) {
            Question_Bank__c qb= new Question_Bank__c();    
                qb.Question__c='Only to test'+i+' ?';
                qb.CourseId__c = crs.Id;                 
                qb.Category__c = 'Sample';
                if(i < =1 ){
                    qb.choice__c = 'Single';
                    qb.Answer__c='a';
                }
                else{
                    qb.choice__c = 'Multi';
                    qb.Answer__c='b,c';
            }
            qbnk.add(qb);
            }
            insert qbnk;
            
            String qsetId='';         
            for(Integer i=0;i<3;i++) {
                if(i==0)
                    qsetId=qbnk[i].id;
                else
                    qsetId+= ','+qbnk[i].id;
            }  
            List<Answer_Bank__c> alst = new List<Answer_Bank__c>();
            for(Integer i=0;i<3;i++) { 
                Answer_Bank__c ans= new Answer_Bank__c();   
                ans.QuestionId__c = qbnk[i].Id;
                ans.Possible_Answer__c = 'asd';
                ans.Sub_Script__c = 'a';
                alst.add(ans);
            }
            insert alst; 
            
            Question_Set__c qset = new Question_Set__c();
            qset.Name = 'Dev_T2';
            qset.CourseId__c = crs.Id;
            qset.Questions_Id__c = qsetId;
            qset.Passing_Mark__c = 60.0;
            qset.Total_Questions__c = 10.0;
            qset.Exam_Duration_in_minute__c = 10.0;
            insert qset;
            
            Student__c std=new Student__c();       
            std.BatchId__c=bat.Id;
            std.UserInfoId__c=fac.Id;
            std.Exam_Link__c = 'Link';
            std.Question_Set_Id__c = 'qset.Id'; 
            Insert std; 
            
    
       UserInfo__c co=[Select Id,Name,Email_ID__c,UserId__c from UserInfo__c where Id=:fac.Id Limit 1];
       system.debug('..............co..'+co);   
      
        Question_Set__c qst=[Select Id,Name,CourseId__c,Questions_Id__c,Passing_Mark__c,Total_Questions__c,Exam_Duration_in_minute__c from question_set__C where Id=:qset.Id];    
        system.debug('..............qst..'+qst);    
        Blob data = Blob.valueOf(co.UserId__c);
        String encryptedData = EncodingUtil.base64Encode(data);             
        Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
        ApexPages.currentPage().setCookies(new Cookie[]{ctpuser}); 
        ApexPages.currentPage().getParameters().put('Id',qst.Id );
         StudentController stc=new StudentController();
         stc.doLogout();
         stc.doExam();
         
         std.Exam_Link__c = 'In Progress';
         update std;
         stc.doExam();
    }
    
}