public class Ctp_Query_Portal_Controller {
public String queryString{get;set;} 
public String crntdt{get;set;}  
public String crsId{get;set;}
public String ssnId{get;set;} 
public String facid{get;set;}
public Ctp_QPost_Related__c CQR;
public Ctp_Query_Portal__c CQ;
public String relQId{get;set;}
public String s_f_id{get;set;}
public String f_s_id{get;set;}
public String s_f_type{get;set;}
public String s_f_name{get;set;}
public String courseId{get;set;}
public String fid;

    public Ctp_Query_Portal_Controller(){ 
        s_f_id=ApexPages.currentPage().getParameters().get('Id'); 
        s_f_type=ApexPages.currentPage().getParameters().get('type');
        s_f_name=ApexPages.currentPage().getParameters().get('name');
        f_s_id=ApexPages.currentPage().getParameters().get('faid');
        if(s_f_type == 'Student'){ 
            Student__c st=[Select Id,Name,CourseId__c,BatchId__r.Id from Student__c where Id =:s_f_id Limit 1];
           // courseId = st.CourseId__c;
            courseId = st.BatchId__r.Id;             
        }    
    }
    
    public void saveQury(){
        try{
            CQ = new Ctp_Query_Portal__c();
            CQR = new Ctp_QPost_Related__c();
            CQ.Main_Posted_Query__c = queryString;
            CQ.Qp_Date_Time__c = crntdt;
            CQ.Qp_Stataus__c='Open';
            CQ.Ctp_FacultyId__c = facid;           
            CQ.Ctp_StudentId__c =s_f_id;
            CQ.Faculty_Post_Read__c='Unread';
            CQ.post_read__c='Read';
         //   CQ.Qp_Criticality__c             
         //   CQ.Qp_Satisfaction__c           
          
          Insert CQ;
          
          CQR.Ctp_Query_PortalId__c = CQ.Id;
          CQR.Q_Post__c = queryString;
          CQR.Created_d_t__c= crntdt;
          CQR.Assigned_Id__c = s_f_name;   
          CQR.Stud_Post_Read__c='Read';
          CQR.Fac_Post_Read__c='Unread';     
          Insert CQR;       
          
          System.debug(' Cq --CQR--'+CQ+'---'+CQR);  
       }catch(Exception e){}  
    }  
    
    public PageReference goHome() {
        PageReference ref;
        if(s_f_type == 'Student')
            ref=new PageReference('/apex/StudentHome');
        else if(s_f_type == 'Faculty')
            ref=new PageReference('/apex/FacultyHomePage');
        ref.setRedirect(true);    
        return ref;
     } 
     
      static testMethod void TestCtp_Query_Portal(){
            UserInfo__c fac = new UserInfo__c();
                fac.First_Name__c='Rakesh';
                fac.Last_Name__c='Prahaja';
                fac.Email_ID__c='baruna@ceptes.com';
                fac.DOB__c=System.toDay();
                fac.Mobile_No__c='1234567890';
                fac.PIN__c=332244;
                fac.Type__c='faculty';
                insert fac;                        

            Student__c std=new Student__c();       
                std.UserInfoId__c=fac.Id;
                std.Exam_Link__c = 'Complete';
                Insert std; 
            
            
            Student__c st = [Select Id,Name,CourseId__c,BatchId__r.Id from Student__c where Id =:std.Id];
            ApexPages.currentPage().getParameters().put('Id',st.Id);
            ApexPages.currentPage().getParameters().put('type','Student');    
            Ctp_Query_Portal_Controller cqp = new Ctp_Query_Portal_Controller();
                cqp.saveQury();
                cqp.facId = st.Id;
                cqp.saveQury();
                cqp.goHome();
                cqp.s_f_type ='Faculty';
                cqp.goHome();
    }
}