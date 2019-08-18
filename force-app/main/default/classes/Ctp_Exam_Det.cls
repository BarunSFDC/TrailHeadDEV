public class Ctp_Exam_Det {
public List<QuestDet> questDet{get;set;}
public String sid;

    public Ctp_Exam_Det(){
        Integer i=1;
        sid=ApexPages.currentPage().getParameters().get('Id');
        questDet = new List<QuestDet>();
        List<ctp_studentexam_history__c> qDet=[Select Id,Name,Question__c,Student_Id__c from ctp_studentexam_history__c where Student_Id__c=:sid Limit 200];
        for(ctp_studentexam_history__c qs:qDet){
            questDet.add(new QuestDet(i,qs));
            i++;
        }                
    }
    
    public class QuestDet{
        public Integer srno{get;set;}
        public ctp_studentexam_history__c examRec{get;set;}
        public  QuestDet(Integer sno,ctp_studentexam_history__c exhis){
            srno=sno;
            examRec=exhis; 
        }
    }
    
    //Test Method
   static testMethod void TestExamDet() {
        UserInfo__c uinfo=new UserInfo__c();
        uinfo.First_Name__c='Rakesh';
        uinfo.Last_Name__c='Prahaja';
        uinfo.Email_ID__c='baruna@ceptes.com';
        uinfo.DOB__c=System.toDay();
        uinfo.Mobile_No__c='1234567890';
        uinfo.PIN__c=332244;
        uinfo.Type__c='faculty';
        insert uinfo;
        
        Student__c st= new Student__c();
        st.UserInfoId__c=uinfo.Id;
        
        ApexPages.currentPage().getParameters().put('Id',st.Id);        
        
        ctp_studentexam_history__c csh= new ctp_studentexam_history__c();
        csh.Student_Id__c = String.valueOf(st.Id);
        insert csh;
       
        Ctp_Exam_Det ced = new Ctp_Exam_Det();
        ced.questDet = new List<QuestDet>();
        ced.questDet.add(new QuestDet(1,csh));   
   }
}