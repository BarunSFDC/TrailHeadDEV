public class Ctp_Feedback_pdf {
public Ctp_Feedback_Form__c cff{get;set;}
public String sid;
public String radList;
public List<String> ratingList{get;set;}
public String fromDate{get;set;}
public String today{get;set;}
public String toDate{get;set;}

    public Ctp_Feedback_pdf(){
        sid=ApexPages.currentPage().getParameters().get('Id');
        radList=ApexPages.currentPage().getParameters().get('rList');
        System.debug('......sid.......'+sid);
        System.debug('......radList......'+radList);
        today = String.valueOf(System.today());
        cff = new Ctp_Feedback_Form__c(); 
        ratingList = new List<String>();
        ratingList = radList.split(',');
        try{
            cff=[SELECT Id,fed_Handson__c, fed_Lab_Support__c,fed_Facilities__c,fed_Faculty_Effectiveness__c,fed_CourseId__c,fed_Interaction__c,fed_Presentation_does__c,fed_Training_review__c, fed_SessionId__c,fed_Trainer_Rating__c,fed_Course_Rating__c, fed_Course_Relevance__c,fed_Faculty__c, fed_Participant_Name__c, fed_Duration_hrs__c, fed_Training_from_date__c, 
                fed_Clarity__c,fed_Excercise_quality__c,fed_Training_to_date__c,fed_Kt__c, fed_Course_Like__c, fed_Course_Dislike__c, fed_Comments__c, fed_Recommendation__c from Ctp_Feedback_Form__c  where id=:sid limit 1];  
           fromDate=String.valueOf(cff.fed_Training_from_date__c);
           toDate = String.valueOf(cff.fed_Training_to_date__c);
        }catch(Exception e){}
  
    }
    //Test Methods
    static testMethod void Ctp_Feedback_pdf(){      
        Ctp_Feedback_Form__c cff= new Ctp_Feedback_Form__c();
        cff.fed_Handson__c=2;
        insert cff;        
        ApexPages.currentPage().getParameters().put('Id',cff.Id);
        ApexPages.currentPage().getParameters().put('rList','1,2,3,4,2,1,3,4,5,4,3,2,1');          
        Ctp_Feedback_pdf cf=new Ctp_Feedback_pdf();        
    }
          
 }