public class TestQsetRepeat {

public List<QuestList> repeatQBankList{get;set;}
public List<Question_Bank__c> questionList;
public String selectedProgram{get;set;}
public String selectedcourse{get;set;}
public List<SelectOption> courseName{get;set;}
public List<SelectOption> questSetName{get;set;}
public List<SessionEntry__c> sentList;
public String pblockTitle{get;set;}
public String errorMessage{get;set;}
public Boolean isError{get;set;}
public List<QuestionSet> qSetDet{get;set;}
public List<Course__c> crsList;
public List<Module_Matrix__c> questModList;
public String selectedQSetId;

    public TestQsetRepeat(){
        questSetName=new List<SelectOption>();
        isError = false;
    }
    
    public List<SelectOption> getProgramName(){
        List<SelectOption> pgList=new List<SelectOption>();  
        List<Program__c> prgList;      
        try{
            prgList=[SELECT Id,Name from Program__c  limit 50];
        }catch(Exception e){}
        for(Program__c prg : prgList){
                 pgList.add(new SelectOption(prg.Id,prg.Name));
        }
        return pgList; 
    }    
       
    //Get program related courses.
    public void courseDetails(){ 
    isError = false;
    courseName = new List<SelectOption>();
    crsList=[Select Id,Name from Course__c where programId__c =: selectedProgram Limit 50] ;
    for(Course__c crs:crsList)
        courseName.add(new SelectOption(crs.Id,crs.Name));
    }

    // Get all question sets
    public void qSetDetails(){ 
        qSet();
        try{           
            questModList=[Select Id,Name,CourseId__c,CourseId__r.Name,percent_for_qset__c from Module_Matrix__c where CourseId__c =: selectedcourse limit 100];
            questionList =[Select id,Name,Module_Name__c,CourseId__c,CourseId__r.Name,Question__c from  Question_Bank__c where CourseId__c =:selectedcourse Order by Module_Name__c limit 200 ];  
        }catch(Exception e){}        
         
    } 
    
    public void qSet(){
        isError = false;
        qSetDet = new List<QuestionSet>();
        List<Question_Set__c> qList;        
        System.debug('...selectedcourse....'+selectedcourse);
        try{
             qList=[Select Id,Name,Questions_Id__c,Passing_Mark__c,Exam_Duration_in_minute__c,Total_Questions__c,CourseId__c,CourseId__r.Name from Question_Set__c where CourseId__c =: selectedcourse order by Name Limit 100];
             for(Question_Set__c q:qList)
                 qSetDet.add(new QuestionSet(q));
        }catch(Exception e){} 
    }
    
    public void totalQuestBank(Integer qstrength){        
        repeatQBankList=new List<QuestList>();
        //String name;                
        for(Module_Matrix__c rlst : questModList){
            QuestList qs=new QuestList();
            qs.modName=rlst.Name;
            qs.crsName=rlst.CourseId__r.Name;
            qs.qbanList = new List<QuestBankRec>();           
            for(Question_Bank__c qb:questionList)
                if(qb.Module_Name__c == rlst.Name){
                    qs.qbanList.add(new QuestBankRec(qb));
                    System.debug('--qb--'+qb);
                }
            qs.qstrength=Integer.valueOf(qstrength*(Double.valueOf(rlst.percent_for_qset__c)/100));           
            repeatQBankList.add(qs);      
        }
    }
    
    public void saveQSet(){
        String qsIdList;
        Integer total_selected=0;
        Integer total_shouldbe=0;   
        try{          
            for(QuestList qlist:repeatQBankList){
                total_selected=total_selected + qlist.selrec;    
                total_shouldbe=total_shouldbe + qlist.qstrength;               
                for(QuestSetRec qbr:qlist.qsetList){
                    if(qsIdList == null){
                        qsIdList=qbr.qset.Id;                    
                    }else
                        qsIdList=qsIdList+','+qbr.qset.Id;                 
                }
            }
            System.debug('----total_selected---'+total_selected+'-------total_shouldbe---'+total_shouldbe);
            if(total_selected == total_shouldbe ){ 
                for(QuestionSet qs:qSetDet){
                    if(qs.qstList.Id == selectedQSetId){
                        qs.qstList.Questions_Id__c = qsIdList;
                        update qs.qstList;
                        break; 
                    }
                }
                isError = true;
                errorMessage='Question set succesfully created.';  
            }else{
                isError = true;
                errorMessage='Question set strength should be '+total_shouldbe+',Now it is '+total_selected+'.';
            } 
        }catch(Exception e){}           
    } 
    
    public void newQSet(){ 
        isError = false;  
        Question_Set__c qst =new Question_Set__c();
        qSetDet.add(new QuestionSet(qst));    
        for(QuestionSet qs:qSetDet){
            qs.editfield = true;
            qs.addNew = false;
        }
        qSetDet[qSetDet.size()-1].editfield = false;
        qSetDet[qSetDet.size()-1].addNew=true;
    }
    
    public void refresh(){
        qSet();
    }
    
    public void showQSet(){
        isError = false;  
        String qSetId;
        Integer qstrngth;  
        for(QuestionSet qs:qSetDet){
            System.debug('-----vvvvvvvvv-------'+qs.qstList.Name+'-------'+qs.setId);
            if(qs.qstList.Id == qs.setId  ){                
                qSetId=qs.qstList.Questions_Id__c;
                pblockTitle = qs.qstList.Name;
                qstrngth = Integer.valueOf(qs.qstList.Total_Questions__c);
                selectedQSetId = qs.setId;
                qs.setId = null;
            }
        } 
        totalQuestBank(qstrngth);   
        if(qSetId != null){
            List<String> setOfIds=qSetId.split(',');  
            for(QuestList qlist : repeatQBankList){
                Integer i=0;
                qlist.qsetList = new List<QuestSetRec>();
                Boolean flag=true;
                for(QuestBankRec qbr : qlist.qbanList){
                    for(String qsid: setOfIds){
                        if(qbr.qban.Id == qsid){
                            qbr.selectcheck = true;
                            flag = false;
                            qlist.selrec  = ++i; 
                            qlist.qsetList.add(new QuestSetRec(qbr.qban,i));
                        }
                    }
                }
                if(flag == true)
                    qlist.selrec=0;
            }
        }
    }
    
    public void editQSet(){
        isError = false;  
        try{
            for(QuestionSet qs:qSetDet){
                qs.addNew = false;
                if(qs.qstList.Id == qs.setId )
                    qs.editfield = false;
                else
                    qs.editfield = true;
                qs.setId = null; 
            }   
        }catch(Exception e){}                   
    }
    
    public void deleteQSet(){
        try{
            for(QuestionSet qs:qSetDet)
                if(qs.qstList.Id == qs.setId )
                    delete qs.qstList;
        }catch(Exception e){}
        qSet();
    }
    
    public void saveRecord(){
        try{                
            if(qSetDet[qSetDet.size()-1].addNew){                
                for(Course__c crs:crsList)
                    if(crs.Id == selectedcourse)
                        qSetDet[qSetDet.size()-1].qstList.Name = crs.Name.subString(0,3)+qSetDet.size()+'_'+qSetDet[qSetDet.size()-1].qstList.Name;   
                qSetDet[qSetDet.size()-1].qstList.CourseId__c = selectedcourse; 
                Insert qSetDet[qSetDet.size()-1].qstList;
            }
            else{
                for(QuestionSet qs:qSetDet){
                    if(qs.qstList.Id == qs.setId && !qs.addNew){
                        update qs.qstList;
                        break; 
                    }
                }
            }            
        }catch(Exception e){}
        qSet();
    }
    
   
    
    public PageReference selected(){
        for(QuestList qlist:repeatQBankList){
            Integer i=0;
            qlist.qsetList = new List<QuestSetRec>();
            Boolean flag=true;
            Integer qsetSize=0;
            for(QuestBankRec qbr:qlist.qbanList){
                if(qbr.selectcheck == true){ 
                    if(qlist.qstrength > qsetSize){
                        qlist.isError=false;
                        flag = false;
                        qsetSize = qsetSize +1;
                        qlist.selrec  = ++i; 
                        qlist.qsetList.add(new QuestSetRec(qbr.qban,i));
                    }else{
                        qlist.isError = true;
                        errorMessage='You cannot add more than '+qlist.qstrength +' questions';
                        break;
                    }
                }
            }
            if(flag == true)
                qlist.selrec=0;
        }
        return null;     
    }
    
    public class QuestionSet{
        public Question_Set__c qstList{get;set;}
        public Boolean editfield{get;set;}
        public Boolean addNew{get;set;}
        public String setId{get;set;}
        public QuestionSet(Question_Set__c qslst){
            qstList = qslst;
            editfield = true;
            addNew = false;
        }
    }
    
    public class QuestList{
        public Boolean isError{get;set;}
        public Integer qstrength{get;set;}
        public Integer selrec{get;set;}
        public String modName{get;set;}
        public String crsName{get;set;}
        public List<QuestBankRec> qbanList{get;set;} 
        public List<QuestSetRec>qsetList{get;set;}
        public QuestList(){
            isError=false;
            selrec=0; 
        }
    }    
    public class QuestBankRec{        
        public Boolean selectcheck{get;set;} 
        public Question_Bank__c qban{get;set;} 
        public QuestBankRec(Question_Bank__c qb){
           qban=qb; 
        }
    } 

    public class QuestSetRec{        
        public Integer counter{get;set;}
        public Question_Bank__c qset{get;set;} 
        public QuestSetRec(Question_Bank__c qb,Integer i){
           qset=qb;  
           counter=i;
        }
    }
    
    //Test methods
    static testMethod void qSetPageTest() {
        Program__c prg=new Program__c();
        prg.Name='DWH';
        Insert prg;
       
        Course__c crs=new Course__c();
        crs.Name='J2ME';
        crs.ProgramId__c=prg.Id;
        Insert crs;
        
        Module_Matrix__c md=new Module_Matrix__c();
        md.CourseId__c=crs.Id;
        md.percent_for_qset__c='50';
        md.Name='Mod1';
        insert md;        
        
        Question_Bank__c qbank=new Question_Bank__c();
        qbank.Question__c = 'How are you?';
        qbank.CourseId__c = crs.Id;
        qbank.Category__c='Simple';
        qbank.Module_Name__c = md.Name;        
        qbank.Answer__c='a';
        qbank.choice__c='Single';
        Insert qbank;
                
        Question_Set__c qs=new Question_Set__c();
        qs.Name='set1';
        qs.CourseId__c = crs.Id;
        qs.Total_Questions__c=2;
        qs.Questions_Id__c =qbank.Id;        
        Insert qs;
        
        TestQsetRepeat tq=new TestQsetRepeat();
        tq.getProgramName();
        tq.selectedProgram=prg.Id;
        tq.courseDetails(); 
        tq.selectedcourse=crs.Id;
        tq.selectedQSetId=qs.Id;
        tq.qSetDetails();
        tq.totalQuestBank(1);
        tq.saveQSet(); 
        tq.newQSet(); 
        tq.refresh();
        tq.qSetDet[0].setId=qs.Id;
        tq.showQSet(); 
        tq.editQSet();         
        tq.saveRecord(); 
        tq.selected();
        tq.deleteQSet();
        
        
        
        
    }
}