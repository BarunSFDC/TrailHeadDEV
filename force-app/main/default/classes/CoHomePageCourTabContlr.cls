public class CoHomePageCourTabContlr {

    public List<Course__c> selectCors { get; set;}
    public List<Course__c> selectCourse { get; set;}   
    public List<Course__c> tempCourseList; 
    public List<Module_Matrix__c> modList{get;set;}
    public List<sesDetail> selectsess{get;set;}
    public Course__c cours { get; set;}
    public Boolean courseDetails1{get;set;}
    public Boolean courseDetails2{get;set;}
    public Boolean showcourse{get;set;}     
    public String courseId {get; set;}
    public Boolean isError{get;set;}
    public Integer selectPage {get; set;}
    private final Course__c cors;  
    public String errorMessage{get;set;}
    public Integer countmod{get;set;}
    public Integer countses{get;set;}
    public List<SelectOption> moduleList{get;set;}
    public String name{get;set;}
    public String condtion{get;set;}
    public String text{get;set;}
    
    
    public CoHomePageCourTabContlr() {               
        this.courseDetails1=false;
        countmod=0;
        countses=0;
        modList = new List<Module_Matrix__c>();
        totalCourse();
    }   
 
    public void totalCourse(){
        selectCors = new List<Course__c>(); 
        try{           
            tempCourseList = [SELECT Id, Name,CreatedDate,Course_Fees__c,ProgramId__r.Name, ProgramId__c from Course__c  order by ProgramId__c ];  
            selectCors.addAll(tempCourseList);        
            name='Name';
            text=null;
            condtion='Condition';
        }catch(Exception e){}
    }
    
      public void doFilter(){        
        selectCors = new List<Course__c>();
        if(name == 'Program'){
            if(condtion == 'Equals to'){
                for(Course__c c:tempCourseList){
                    if(c.ProgramId__r.Name == text)
                        selectCors.add(c);                    
                }
            }else if(condtion == 'Like'){
                for(Course__c c:tempCourseList){
                    if(c.ProgramId__r.Name.startsWith(text))
                        selectCors.add(c);                    
                }    
            }
        }else if(name == 'Course'){
            if(condtion == 'Equals to'){
                for(Course__c c:tempCourseList){
                    if(c.ProgramId__r.Name == text)
                        selectCors.add(c);                    
                }
            }else if(condtion == 'Like'){
                for(Course__c c:tempCourseList){
                    if(c.Name.startsWith(text))
                        selectCors.add(c);     
                }
           }
        } 
    }
    
    public void allCourses(){
        totalCourse(); 
    }
     public void cancelCourseDetail(){
         this.courseDetails1=false;
     }
     
     public void doNewCourse() {
        cours=new Course__c();
        modList = new List<Module_Matrix__c>();
        modList.add(new Module_Matrix__c());
        selectsess=new List<sesDetail>(); 
        courseDetails1=true;
        courseDetails2=true;
        showcourse=false;
        isError=false;       
    }
    
    //Add New Module in the list 
    public void addNewModule(){
        modList.add(new Module_Matrix__c());              
    } 
     
    //Module Details After Add or remove for reusable
    public void addRemoveModule(){
        moduleList = new List<SelectOption>();        
        if(modList.size() > 0 ){
            for(Module_Matrix__c mod:modList){
                System.debug('.....mod:modList...'+mod.Name);
                moduleList.add(new SelectOption(mod.Name,mod.Name));   
            }     
        }   
    } 
    
    // To add a new session
    public void addNewSession(){   
        addRemoveModule();
        Session__c ss=new Session__c();
        if(selectsess.size() == 0){
                selectsess=new List<sesDetail>();                 
                selectsess.add(new sesDetail('',ss));
        }else
            selectsess.add(new sesDetail('',ss));
    }
    
    //To delete an existing module
    public void deleteModule(){
        System.debug('..........Among modules are up....'+modList);
        if(modList.size() == 1){
            isError=true;
            errorMessage='At least one Module should be inside course';
        }else{
            try{
                List<Session__c> sId=[Select Id from Session__c where Module_Name__c =: modList[countmod].Name Limit 20];
                delete [Select Id from Module_Matrix__c where Id =: modList[countmod].Id Limit 1];
                modList.remove(countmod); 
                addRemoveModule();
                if(sid.size() > 0){
                    delete sId;
                    showEdit();
                }    
            }catch(Exception e){}
        }
        System.debug('..........Among modules are....'+modList);
    }
      
    //To remove one existing session from list     
    public void deleteSession(){
        try{
           selectsess.remove(countses);
        }catch(Exception e){} 
    }    
    
    //Save all the sessions,modules and the corresponding course
    public void saveCourse(){          
        if(modList == null || modList.size() == 0 || selectsess.Size() == 0){
            isError=true;
            errorMessage='Check:At least one Module and one Session should be inside course.';
         }else{    
             //Calculate and check on module percent rating
             Integer tot=0;
             Boolean check=false;
             for(Module_Matrix__c md: modList)     
                 if(md.percent_for_qset__c != null){
                     tot=tot+Integer.valueOf(md.percent_for_qset__c);
                 }else{
                     check=true;                      
                     break;   
                 }
              
             if(tot == 100 && check == false){ 
                 try{
                     Decimal Totalhour=0;
                     for(sesDetail ss : selectsess)
                         Totalhour=Totalhour+Double.valueOf(ss.sess.Duration_In_Hour__c);    
                                      
                     cours.Course_Duration_in_hr__c=Totalhour;
                     upsert cours;
                     System.debug('......cours....'+cours);               
                     //Insert Module_Matrix__c data
                     List<Module_Matrix__c> modmatList=[Select Id,Name,percent_for_qset__c,CourseId__c from Module_Matrix__c where CourseId__c =:cours.Id Limit 100];
                     System.debug('......modmatList....'+modmatList+'..modList...'+modList);                    
                     for(Module_Matrix__c mod:modList){   
                         Boolean flag=false;                   
                         for(Module_Matrix__c md:modmatList){
                             if(md.id == mod.Id){    
                                 flag = true;
                                 break;
                              }
                         }
                         if(flag == true)
                            upsert mod;
                         else{
                        mod.CourseId__c = cours.Id;
                        upsert mod;
                         }
                    }
             
                     //Insert Session__c data
                     List<Session__c> ssList=[Select Id,Name,Module_Name__c,Session_Name__c,Duration_In_Hour__c from Session__c where CourseId__c=:cours.Id order by CreatedDate Limit 100];
                     for(sesDetail ssn : selectsess){
                         Boolean flag=false;
                         for(Session__c ss : ssList){
                             if(ssn.sess.Id == ss.Id){
                                 flag=true;
                                 break;
                             }
                         }
                         if(flag){  
                             ssn.sess.Module_Name__c = ssn.modName;                  
                             upsert ssn.sess;
                         }else{
                              ssn.sess.Module_Name__c = ssn.modName;  
                              ssn.sess.CourseId__c = cours.Id; 
                              upsert ssn.sess;
                          }                      
                      }       
                      
                      //After remove from UI list we need to delete the records from session object
                      for(Session__c ss : ssList){ 
                          Boolean flg=false;                               
                          for(sesDetail sss : selectsess){ 
                              if(ss.Id == sss.sess.Id){
                                  flg=true;
                                  break;
                              }
                          }
                          if(flg == false)
                              delete ss;
                      }  
                    totalCourse();                     
                 }catch(Exception e){
                     System.debug('Error ---- '+e);
                 }
                 courseDetails1=false;
             }else{                 
                 isError=true;
                 if(check == true)
                     errorMessage='Check:All Module should have some value.';
                 else
                     errorMessage='Check Module:Aggregate percent should be 100.'; 
            }
        }        
    }
    
    //get picklisted sessiontype values from the object      
    public List<SelectOption> getfieldValues(){
        List<SelectOption> fieldValues = new List<SelectOption>();
        Schema.DescribeFieldResult evntField = Schema.sObjectType.Session__c.fields.Session_Type__c;
        Schema.PicklistEntry [] values = evntField.getPickListValues();
        for(Schema.PicklistEntry val : values){
            fieldValues.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return fieldValues;
    }  
     
    //Delete course
    public void deleteCourseRecords(){
         try{
             Course__c cors=[SELECT Id,CreatedDate,Name,ProgramId__c,Course_Fees__c
                             from course__c where Id=:courseId LIMIT 1];  
             delete cors;            
             totalCourse();       
         }catch(Exception e) {}
            courseDetails1=false;
    }
    
    //Retrive session details for reusability  
    public void showEdit(){
        selectsess=new List<sesDetail>();        
        try{ 
            List<Session__c> sslst=[select Id,Session_Name__c,Duration_In_Hour__c,Module_Name__c,Session_Type__c from Session__c where CourseId__c=:courseId order by CreatedDate limit 200];             
            for(Session__c s:sslst)
                selectsess.add(new  sesDetail(s.Module_Name__c,s));     
        }catch(Exception e){}  
    }
    
    //On click of edit button
    public void editCoursreDetails(){
        isError=false;
        cours = new Course__c();
        modList = new List<Module_Matrix__c>();    
        for(Course__c c:selectCors){
           if(c.Id == courseId)  
               cours = c;  
        }
        try{            
            modList=[Select Id,Name,percent_for_qset__c,CourseId__c from Module_Matrix__c where CourseId__c =:courseId Limit 100];
            showEdit();
            addRemoveModule();             
        }catch(Exception e){}       
        courseDetails1=true;
        courseDetails2=true;
        showcourse=false;
        
    }   
   
   //On click of the view button  
   public void showSessionDetails(){
       selectCourse = new List<Course__c>();
       for(Course__c c:selectCors){
           if(c.Id == courseId)
               selectCourse.add(c);
       }
       showEdit();
       courseDetails1=true;
       courseDetails2=false;
       showcourse=true; 
   }  
   
   //wrapper class for sessions
   public class sesDetail{
       public String modName{get;set;} 
       public Session__c sess{get;set;} 
       public sesDetail(String mn,Session__c ssn){
           modName=mn;
           sess=ssn;                   
       }     
   }
   
   
   
   //Test Method
   static testMethod void TestCourse() {
        Program__c prg=new Program__c();
        prg.Name='DWH';
        Insert prg;
       
        Course__c crs=new Course__c();
        crs.Name='J2ME';
        crs.ProgramId__c=prg.Id;
        Insert crs;
        
        Module_Matrix__c mm=new Module_Matrix__c();
        mm.CourseId__c=crs.Id;
        mm.percent_for_qset__c=String.valueOf(100);
        mm.Name='abc';
        Insert mm;
             
        Session__c ssn = new Session__c();
        ssn.CourseId__c = crs.Id;
        ssn.Session_Name__c = 'intro';
        ssn.Session_Type__c = 'Theory';
        ssn.Duration_In_Hour__c ='3';
        ssn.Module_Name__c=mm.Name;
        insert ssn;
    
        CoHomePageCourTabContlr cordCourTab = new CoHomePageCourTabContlr();        
        cordCourTab.courseId=crs.Id;
        cordCourTab.getfieldValues();
        cordCourTab.totalCourse();
        
        cordCourTab.name='Program';
        cordCourTab.text='DWH';
        cordCourTab.condtion = 'Equals to';       
        cordCourTab.doFilter();
        
        cordCourTab.condtion = 'Like';       
        cordCourTab.doFilter();
        
        cordCourTab.name='Course';
        cordCourTab.text='J2ME';
        cordCourTab.condtion = 'Equals to';       
        cordCourTab.doFilter();
        
        cordCourTab.condtion = 'Like';       
        cordCourTab.doFilter();
        
        
        cordCourTab.allCourses(); 
        cordCourTab.cancelCourseDetail();
        cordCourTab.doNewCourse();
        cordCourTab.addNewModule();
        cordCourTab.modList= new List<Module_Matrix__c>();
        cordCourTab.saveCourse();
        cordCourTab.modList.add(mm);
        cordCourTab.deleteModule();
        cordCourTab.addRemoveModule();
        
        cordCourTab.modList.add(mm);
        cordCourTab.deleteModule();
        cordCourTab.deleteSession();
        cordCourTab.addNewSession();
        
        cordCourTab.selectsess=new List<sesDetail>();
        cordCourTab.selectsess.add(new sesDetail(mm.Name,ssn));
        cordCourTab.cours=new Course__c();
        cordCourTab.cours = crs;
        cordCourTab.saveCourse();
        cordCourTab.deleteCourseRecords();
        cordCourTab.showEdit();
        cordCourTab.editCoursreDetails();
        cordCourTab.showSessionDetails();

    }      
}