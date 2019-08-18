public class Ctp_PreparedExam {
public String question{get;set;}
public List<String> qId;
public Integer noOfQuestions{get;set;}
public Integer i{get;set;}
public Integer j{get;set;}
public String selectedRadio{get;set;}
public Boolean isError{get;set;}
public String errorMessage{get;set;}
public List<SelectOption> answerList{get;set;}
public List<Question_Bank__c> qbank;
public List<Multicheck> multiChk{get;set;}
public Boolean ifCheck{get;set;}
public Integer corr{get;set;}
public Integer incorr{get;set;}
public List<Integer> skippedIndex{get;set;}
public Boolean skipDisable{get;set;}
public String clickSkip{get;set;}
public Integer skpInd{get;set;}
public Boolean nextQst{get;set;}
public Boolean viewskipped;
public Boolean completeresult{get;set;}
public Integer passingno;
public Integer failedno;
public Boolean submitShow{get;set;}
public Boolean skipShow{get;set;}
public List<String> qaList;
public String fid;
public String setName;
public String sentResultMsg;

    public Ctp_PreparedExam(){
        i=0;   
        j=0;    
        corr=0;
        incorr=0;
        skpInd=0;
        skipDisable = true;
        submitShow = false;
        skipShow=false;
        completeresult = false;
        nextQst = true;
        clickSkip = null;
        viewskipped=false;
        qaList=new List<String>();
        skippedIndex = new List<Integer>();
        Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
        Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
        fid = pw.toString();
      // fid='JaSa5';
        System.debug('.........fid............'+fid);
        String qstId=ApexPages.currentPage().getParameters().get('Id');
       // String qstId='a0QU0000000MF1iMAG';
        Question_Set__c qset=[Select Id,Name,CourseId__c,Questions_Id__c,Passing_Mark__c,Total_Questions__c,Exam_Duration_in_minute__c from question_set__C where Id=:qstId];        
        
        system.debug('..........Qset11...............'+qset);
        qId=qset.Questions_Id__c.split(',');
        setName=qset.Name;
        noOfQuestions=Integer.valueOf(qset.Total_Questions__c);
        passingno=Integer.valueOf(qset.Total_Questions__c*qset.Passing_Mark__c/100);
        failedno = Integer.valueOf(qset.Total_Questions__c) - passingno;
        qbank=[Select Id,Name,Question__c,choice__c,Answer__c from Question_Bank__c where id IN:qid order by Id];
        choice();
    }
   
   
    //It calculates the answer is single choiced or multi choiced
    public void choice(){ 
        try{            
            List<Answer_Bank__c> ansList=[Select Id,Name,Possible_Answer__c,Sub_Script__c from Answer_Bank__c  where QuestionId__c =:qbank[i].Id ];
            if(qbank[i].choice__c == 'Single'){
                ifCheck = true;  
                selectedRadio=null;     
                answerList = new List<SelectOption>();
                question='Q'+(i+1)+'.'+' '+qbank[i].Question__c;
                for(Answer_Bank__c a:ansList)
                    answerList.add(new SelectOption(a.Sub_Script__c,a.Possible_Answer__c));            
            }
            if(qbank[i].choice__c == 'Multi'){
                ifCheck = false;
                question='Q'+(i+1)+'.'+' '+qbank[i].Question__c;
                multiChk = new List<Multicheck>();
                for(Answer_Bank__c a:ansList)
                    multiChk.add(new Multicheck(a)); 
            } 
        }catch(Exception e){}   
    }
    
    //Calculate correct and incorrect answers
    public void corrIncorr(){
        String ans = null;
        isError = true;
        try{
            if(qbank[i].choice__c == 'Single' ){
                System.debug('------selectedRadio--------'+selectedRadio);
                if(selectedRadio != null){
                    submitShow = true;
                    skipShow=true;     
                    isError = true;  
                    qaList.add('\n'+ qbank[i].Question__c +'___Ans('+qbank[i].Answer__c+' )');
                    if(selectedRadio == qbank[i].Answer__c)
                        errorMessage='Correct !';
                    else{
                        errorMessage='incorrect !';
                        incorr=incorr+1;
                    }
                }else{
                    errorMessage='Select answer from  list';
                    nextQst = true;
                    submitShow = false;
                    skipShow=false; 
                }
            }else if(qbank[i].choice__c == 'Multi'){
                for(Multicheck mul:multiChk){
                    if(mul.selectch == true){
                        if(ans == null )
                            ans=mul.abank.Sub_Script__c;
                        else 
                            ans=ans+','+mul.abank.Sub_Script__c;
                    }
                }
                if(ans != null ){
                   submitShow = true;
                   skipShow=true;     
                   isError = true;  
                   qaList.add(qbank[i].Question__c +'___Ans('+qbank[i].Answer__c+' )');
                   if(ans ==  qbank[i].Answer__c )
                       errorMessage='Correct !';
                   else{
                       errorMessage='incorrect !';
                       incorr=incorr+1;
                   }
                }else{
                    errorMessage='Select answer from  list';
                    nextQst = true;
                    submitShow = false;
                    skipShow=false; 
                }
            }                         
        }catch(Exception e){}
    }
    
    //Submit your answer
    public void submitAnswer(){        
        nextQst = false; 
        corrIncorr(); 
    }
        
    //Add on skipped one
    public void skipQuestion(){
        skippedIndex.add(i);
        nextQst = false; 
        submitShow = true;
        skipShow=true;     
    }
    
    //Go to next question if there
    public void nextQuestion(){        
        isError=false;    
        if(incorr < failedno ){ 
            submitShow = false;
            sentResultMsg = 'Your result is Pass.Check the attachment';                       
            if(viewskipped == true){
                skipShow=true;
                if(skpInd+1 < skippedIndex.size()){                
                    skpInd=skpInd+1;                
                    i=skippedIndex.get(skpInd);                                    
                    choice();
                }else{              
                    skpInd=skpInd+1; 
                    completeresult=true;
                    errorMessage='You have attempted all the questions,you can submit it.';
                    nextQst = true;
                }
            }else{    
                 skipShow=false;            
                 if(i+1 < qid.size()){                
                    i=i+1;
                    j=i;
                    choice();            
                }else{                              
                    if(skippedIndex.size() == 0){
                        completeresult=true;
                        errorMessage='You have attempted all the questions,you can submit it.';
                        nextQst = true;
                    }else{
                        skipDisable = false;
                        nextQst = true;
                        isError=true;
                        errorMessage='There is no more questions,you can check your skipped all.';
                    }
                } 
            }    
            nextQst = true;  
            clickSkip = null;
        }else{
            submitShow=true;
            nextQst = true;
            completeresult=true;
            sentResultMsg='Your result is failed.';
            errorMessage='Sorry!Your result is failed.You cannot go ahead.';
        } 
    }
   
    //Select Skipped Questions
    public void goToSkippedQuestion(){
        viewskipped = true;
        skipShow=true;
        i=skippedIndex.get(skpInd);        
        choice(); 
        skipDisable = true; 
        nextQst =false;
        isError = false;          
    }
    
    public Student__c st;
   
    //create pdf and send mail to coordinator 
    public PageReference sentMail(){              
        try{
            st=[Select Id,Name,Exam_Link__c,UserInfoId__r.First_Name__c,UserInfoId__r.Email_Id__c  from Student__c where UserInfoId__r.UserId__c =: fid limit 1];
            System.debug('....student details....'+st);
            st.Exam_Link__c = 'Complete';
            update st;  
            List<ctp_studentexam_history__c> csList=[Select Id,Question__c,Student_Id__c from ctp_studentexam_history__c Limit 200];
            delete csList;
            
            List<ctp_studentexam_history__c> cshList=new List<ctp_studentexam_history__c>();
            for(String qs:qaList)            
                cshList.add(new ctp_studentexam_history__c(Question__c = qs,Student_Id__c=st.Id));
            Insert cshList;             
            
            String sname=st.UserInfoId__r.First_Name__c+'_'+setName+'.pdf';
            PageReference pdf= new PageReference('/apex/Ctp_Exam_Det');
            pdf.getParameters().put('id',st.Id);
            Blob body;        
            if(Test.isRunningTest() == false)
                body=pdf.getContent();  
            else 
                body=Blob.valueOf('Sorry!This is only for Test.');    
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(sname);
            attach.setInline(false);
            attach.Body = body;
            
            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
            email.setUseSignature(false);
            email.setSubject( 'Exam Details of...'+st.UserInfoId__r.First_Name__c);
            email.setHtmlBody('<b>'+'Student Exam Details.'+sentResultMsg+'</b>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
          //  email.setToAddresses( new String[]{'baruna@ceptes.com',st.UserInfoId__r.Email_Id__c } );  
            email.setToAddresses( new String[]{'baruna@ceptes.com'});        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });    
        
        }catch(Exception e){}
        PageReference pg=new PageReference('/apex/loginPage');
        pg.setRedirect(true);
        return pg;
    } 
    
    public class Multicheck{
        public Boolean selectch{get;set;}
        public Answer_Bank__c abank{get;set;}
        public multicheck(Answer_Bank__c ans){
            selectch = false;
            abank=ans;
        }
    }
    
    //Test Method    
     static testMethod void TestCtp_PreparedExam(){
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
                std.Exam_Link__c = 'Complete';
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
            
       
      Ctp_PreparedExam cpre = new Ctp_PreparedExam();           
           cpre.choice();
           cpre.corrIncorr();
           cpre.selectedRadio=qbnk[0].Answer__c;   
           cpre.errorMessage='Correct !';
           cpre.corrIncorr();
           cpre.i=2;            
           cpre.choice();         
           cpre.selectedRadio=qbnk[2].Answer__c;
           cpre.errorMessage='Correct !';            
           cpre.multiChk[0].selectch = true;                    
           cpre.corrIncorr();
           cpre.submitAnswer();
           cpre.skipQuestion();
           cpre.nextQuestion();
           cpre.viewskipped = true;
           cpre.nextQuestion();
           cpre.skippedIndex=new List<Integer>();
               for(Integer i=0;i<5;i++)
                   cpre.skippedIndex.add(i);
           cpre.goToSkippedQuestion();
           cpre.sentMail();    
       }
  
}