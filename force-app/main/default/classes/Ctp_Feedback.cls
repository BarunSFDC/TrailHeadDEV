public class Ctp_Feedback {
public List<SelectOption> crsList{get;set;}
public List<SelectOption> sessList{get;set;}
public List<SelectOption> facList{get;set;}
public Ctp_Feedback_Form__c cff{get;set;}
public List<String> ssname{get;set;}
public List<String> ratingList{get;set;}
public String crsName{get;set;}
public String facName{get;set;}
public String totssnList{get;set;}
public String totRadioList{get;set;}
public String recomend{get ;set;}
public String today{get;set;}
    
    public Ctp_Feedback(){  
        System.debug('I m inside second page');      
        cff = new Ctp_Feedback_Form__c();
        facList = new List<SelectOption>();
        sessList = new List<SelectOption>();
        crsList = new List<SelectOption>();     
        ssname = new List<String>();   
        today = String.valueOf(System.today());
        Student__c stRec=[Select Id,CourseId__c,BatchId__c,BatchId__r.CourseId__c,BatchId__r.CourseId__r.Name from Student__c where UserInfoId__r.UserId__c='harish@ceptes.com' limit 1];
        List<Session__c> ssList=[Select Id,Name,Session_Name__c from Session__c where CourseId__c=:stRec.BatchId__r.CourseId__c Limit 50];
        crsList.add(new SelectOption(stRec.BatchId__r.CourseId__r.Name,stRec.BatchId__r.CourseId__r.Name));
        for(Session__c ss:ssList)          
          ssname.add(ss.Session_Name__c);
    }
    public void saveFeedBackForm(){
       try{
            System.debug(crsName+'--'+facName+'--'+totssnList+'--'+totRadioList+'--'+recomend);
            ratingList = new List<String>(); 
            ratingList = totRadioList.split(',');
            cff.fed_CourseId__c = crsName;
            cff.fed_Faculty__c = facName;
            cff.fed_Recommendation__c = recomend;        
            cff.fed_SessionId__c = totssnList;
            cff.fed_Course_Relevance__c = Double.valueOf(ratingList[0]);
            cff.fed_Clarity__c = Double.valueOf(ratingList[1]);
            cff.fed_Excercise_quality__c = Double.valueOf(ratingList[2]);
            cff.fed_Handson__c = Double.valueOf(ratingList[3]);
            cff.fed_Lab_Support__c = Double.valueOf(ratingList[4]);
            cff.fed_Facilities__c = Double.valueOf(ratingList[5]);
            cff.fed_Faculty_Effectiveness__c = Double.valueOf(ratingList[6]);
            cff.fed_Kt__c = Double.valueOf(ratingList[7]);
            cff.fed_Interaction__c = Double.valueOf(ratingList[8]);
            cff.fed_Presentation_does__c = Double.valueOf(ratingList[9]);        
            cff.fed_Training_review__c = Double.valueOf(ratingList[10]);
            cff.fed_Trainer_Rating__c = Double.valueOf(ratingList[11]);
            cff.fed_Course_Rating__c = Double.valueOf(ratingList[12]);     
                   
            upsert cff; 
                       
       }catch(Exception e){} 
    } 
    
    public PageReference sendPdf(){
        try{            
            PageReference pdf= new PageReference('/apex/Ctp_feedback_form_pdf');
            pdf.getParameters().put('id',cff.Id);
            pdf.getParameters().put('rList',totRadioList);
            //pdf.setRedirect(false);            
            Blob body;
            if(test.isRunningTest() == false){                        
                body=pdf.getContent();  
            }else
                body=Blob.valueOf('sdfdsfds');                
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('barun');
            attach.setInline(false);
            attach.Body = body;            
            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
            email.setUseSignature(false);
            email.setSubject( 'Feedback form...');
            email.setHtmlBody('<b>'+'Feedback form Details.</b>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            email.setToAddresses( new String[]{'baruna@ceptes.com'});        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });                
            PageReference ref= new PageReference('/apex/StudentHome');
            ref.setRedirect(true);
            return ref;
        }catch(Exception e){}
        return   null;
    }   
    
    //Test Classes
    static testMethod void examTest(){
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
        st.Email_Id__c='harish@ceptes.com';
        st.Mobile_No__c='1234567890';
        st.Pin__c=233455;
        st.Type__c = 'Student';
        Insert st; 
        
        Student__c std=new Student__c();       
        std.BatchId__c=bat.Id;
        std.UserInfoId__c=st.Id;
        std.CourseId__c=crs.Id;
        Insert std;  
        
         
        Ctp_Feedback ctp= new Ctp_Feedback();
        ctp.totRadioList = '2,3,4,5,4,3,2,3,4,3,2,3,2';
        ctp.saveFeedBackForm(); 
        ctp.sendPdf();
    }
   
}