public class CordHomePageHomeTabContr {
    public String coid;
    public Boolean updateFaculty{get;set;}
    public String status{get;set;}
    public Boolean showAll{get;set;}
    public Boolean showEntryTable{get;set;}
    public Boolean showSave{get;set;}
    public Boolean showText{get;set;}   
    public Boolean batchstatus{get;set;} 
    public String textMessage{get;set;}
    public List<TaskDetails> taskDetFromSEntry{get;set;}
    public String seletedCors{get;set;}
    public List<Batch__c> batList ;
    public Batch__c bDet{get;set;}
    public String[] weekday;
    public List<SessionEntry__c> sEntryList;
    public String selectedBatch{get;set;}
    public List<Date> dateList;
    public String ssId{get;set;} 
    public String faId {get;set;}
    public Integer rownum{get;set;}
    public List<SelectOption> options;
    public Coordinator__c cord{get;set;}
    public String cnfrmpwd{get;set;}
    
    public CordHomePageHomeTabContr(){
       Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
       Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
       coid = pw.toString();
       System.debug('coid........'+coid);
       batList = new List<Batch__c>();
       showText=true;
       showSave=false;
       showEntryTable = false;
       batchstatus=false;
       updateFaculty = false;
       textMessage='Select Program and course to see related tasks';
       faId = null;    
       try{
           cord = [SELECT Id,Skills__c,UserInfoId__r.Type__c,UserInfoId__r.Password__c, Technical_Experience__c, Training_Experience__c, Work_Experience__c, UserInfoId__r.Address__c,
                    UserInfoId__r.City__c, UserInfoId__r.DOB__c, UserInfoId__r.Date_Of_Joining__c, UserInfoId__r.Email_Id__c, 
                    UserInfoId__r.First_Name__c, UserInfoId__r.Gender__c, UserInfoId__r.Last_Name__c, UserInfoId__r.Mobile_No__c, UserInfoId__r.Pin__c,
                    UserInfoId__r.State__c, UserInfoId__r.Language_Known__c, UserInfoId__r.Marital_Status__c FROM Coordinator__c 
                    where UserInfoId__r.UserId__c=:coid LIMIT 1];
      }catch(Exception e){}
    }
       
    public void saveChangedPassword(){
        try{
            cord.UserInfoId__r.Password__c = cnfrmpwd;
            update cord.UserInfoId__r; 
        }catch(Exception e){}        
    } 
    
    public void entryDetails(){
       showSave=true; 
       taskDetFromSEntry = new  List<TaskDetails>();
       sEntryList = new List<SessionEntry__C>();
       dateList=new List<Date>();
       options=new List<SelectOption>();
      try{  
           List<faculty__c> fList=[SELECT Id,UserInfoId__c,UserInfoId__r.First_Name__c FROM Faculty__c  Limit 100];
           options.add(new SelectOption('','-select-'));
           for(faculty__c fa:fList)
               options.add(new SelectOption(fa.Id,fa.UserInfoId__r.First_Name__c));
           sEntryList=[SELECT Id,Name,No_Of_Hours__c,StartDate__c, EndDate__c,Faculty__c,faculty__r.UserInfoId__r.First_Name__c, Batch__c, Session_Type__c, Session__c, Status__c, Session_Name__c, Course_Name__c, Start_Time__c, End_Time__c, 
                                           selectsesion__c from SessionEntry__c where Batch__c =: selectedBatch order by Name  ASC Limit 200 ]; 
           bDet = [Select Id,Name,CourseId__c,Status__c,End_Time__c,Availability__c,Start_Time__c,Start_Date__c,End_Date__c,WeekDay_Det__c,Total_Hours__c,Time_Diff__c  from Batch__c where Id=:selectedBatch order by Name Limit 1];   
           System.debug('......sEntryList....'+sEntryList);
           Boolean stts=false;
           if(sEntryList.size() > 0){    
               for(SessionEntry__c sce : sEntryList){
                   if(sce.Status__c == 'Not Available'){
                            stts = true;
                            break;
                    }
               }
               if(stts)
                    bDet.Availability__c = 'Not Available';
                else
                    bDet.Availability__c = null;
                bDet.change_from_ssentry__c = 'Yes';
                bDet.End_Date__c = sEntryList[sEntryList.size()-1].StartDate__c;
                update bDet;                     
                showEntryTable = true;       
               if(status == 'Alert' && showAll == false){                   
                   for(SessionEntry__c sce : sEntryList){
                       dateList.add(sce.StartDate__c);
                       if(sce.Status__c == 'Not Available')
                           taskDetFromSEntry.add(new TaskDetails(sce.StartDate__c,sce.faculty__c,sce,options));
                   }
               }else{
                   showAll = true;
                   for(SessionEntry__c sce : sEntryList){
                       dateList.add(sce.StartDate__c);                      
                       taskDetFromSEntry.add(new TaskDetails(sce.StartDate__c,sce.faculty__c,sce,options));
                   }
               } 
               showText=false;
           }else{
               showEntryTable = false;
               showText=true;
               textMessage='Sorry !currently no entry is there.';
           }
       }catch(Exception e){}       
    }    
   
    public void saveSessEntry(){             
        String faculty;
        if(faId == null || faId == '')
            faculty = taskDetFromSEntry[rownum].sec.faculty__c; 
        else 
            faculty = faId; 
        showText=false;       
        weekday=new String[]{};
        weekday=bDet.WeekDay_Det__c.split(';'); 
        try{
            Boolean flag=false;             
            if(taskDetFromSEntry[rownum].sec.StartDate__c != taskDetFromSEntry[rownum].clickdate || (taskDetFromSEntry[rownum].sec.StartDate__c != taskDetFromSEntry[rownum].clickdate  &&  taskDetFromSEntry[rownum].sec.faculty__c != faId)){
                System.debug('taskDetFromSEntry....'+taskDetFromSEntry[rownum].sec.StartDate__c+'.........'+taskDetFromSEntry[rownum-1].clickdate);
                if(taskDetFromSEntry[rownum -1].clickdate < taskDetFromSEntry[rownum].sec.StartDate__c){                    
                    String today=DateTime.newInstance(taskDetFromSEntry[rownum].sec.StartDate__c,Time.newInstance(0, 0, 0, 0)).format('EEEE')+'';                            
                    for(Integer i=0;i<weekday.size();i++){
                        if(today.startsWith(weekday[i])){
                            showText=false;
                            flag = true; 
                            System.debug('flag.....'+flag);                                                     
                            break;   
                        }                                
                     }
                     if(!flag){   
                            taskDetFromSEntry[rownum].sec.StartDate__c = taskDetFromSEntry[rownum].clickdate;                                
                            showText=true;
                            textMessage='This date is not comming under the selected week days.';
                    }  
                }else{
                    taskDetFromSEntry[rownum].sec.StartDate__c = taskDetFromSEntry[rownum].clickdate;
                    showText=true;
                    textMessage='Selected date should greatter than previous date';
                    System.debug('flag.111....'+flag);        
                }
            }else if(taskDetFromSEntry[rownum].sec.faculty__c != faId){
                if(!updateFaculty){    
                    sEntryList[rownum].faculty__c = faId;
                    sEntryList[rownum].Status__c = 'Not Started';
                    sEntryList[rownum].selectsesion__c=false;
                    update sEntryList[rownum];
                }
                else{
                    for(Integer i=rownum;i<sEntryList.size();i++){
                        sEntryList[i].faculty__c = faId;
                        sEntryList[rownum].Status__c = 'Not Started';
                        sEntryList[i].selectsesion__c=false;
                        update sEntryList[i];    
                    }                        
                }
            }            
            if(flag){ 
                System.debug('-----------taskDetFromSEntry111------'+taskDetFromSEntry[rownum].sec.StartDate__c+'....'+faculty+'....'+Double.valueOf(bDet.Time_Diff__c));
                caculateUpdatedDate(taskDetFromSEntry[rownum].sec.Id,taskDetFromSEntry[rownum].sec.StartDate__c,faculty,Double.valueOf(bDet.Time_Diff__c));                                            
            }                                
        }catch(Exception e){}  
    }
    
    //calculate updated session entries.
    public void caculateUpdatedDate(String ssnId,Date ssnDate,String fid,Double timeDiff){
        List<SessionEntry__c> existssEntry = new  List<SessionEntry__c>();
        existssEntry.addAll(sEntryList);      
            
        try{               
            List<SessionEntry__c> oldssEntry = new List<SessionEntry__c>();
            List<SessionEntry__c> newssEntry = new List<SessionEntry__c>();
            List<Session__c> ssnList=new List<Session__c>();
            List<Date> existanceDate=new List<Date>(); 
            List<Date> distinctDate=new List<Date>();
            List<Date> maxPosibleDate=new List<Date>();
            Date[] dateList=new Date[]{}; 
            Integer diffDays=0; 
            Double totHour = 0.0;
            Integer noOfDays = 0;
            Double timeRem = 0.0 ;
            Integer count=0;
            Date dt = null;
            Boolean flg=false;  
            Double fst_tot_hr=0.0;  
            String ssId=null; 
            List<String> session_Id=new List<String>();     
            for(SessionEntry__c ss:existssEntry){            
                if(ss.Id == ssnId){
                    ssId = ss.Session__c;
                    flg=true;                    
                }
                if(flg == true){                     
                    if(ss.Session__c == ssId )
                        fst_tot_hr = fst_tot_hr + ss.No_Of_Hours__c;
                    session_Id.add(ss.Session__c); 
                    System.debug('I m here.......'+session_Id);      
                    totHour=totHour+ss.No_Of_Hours__c;
                    existanceDate.add(ss.StartDate__c);
                    if( dt != ss.StartDate__c){
                        distinctDate.add(ss.StartDate__c); 
                        dt=ss.StartDate__c;  
                    }  
                    oldssEntry.add(ss);
                }
            }              
            ssnList=[Select Id,Name,CourseId__c,CourseId__r.Name,Session_Name__c,Session_Type__c,Duration_In_Hour__c from Session__c where Id IN:session_Id order by CreatedDate  limit 50]; 
            System.debug('ssnList.....'+session_Id);
            totHour = totHour / 60;        
            noOfDays=Integer.valueOf(totHour/timeDiff);
            timeRem=totHour-(noOfDays*timeDiff);
            if(timeRem != 0)
                noOfDays=noOfDays+1;
                        
            maxPosibleDate.addALL(distinctDate);
            Integer cnt = 0;
            Integer p=0;
            Date chkdate;                
            while(cnt < 3){            
                flg=false;
                chkdate=maxPosibleDate[p];
                for(Date d : maxPosibleDate){
                    if(chkdate.addDays(7) == d){
                        flg=true;
                        break;
                    }                
                }            
                if(!flg){
                    maxPosibleDate.add(maxPosibleDate[p].addDays(7));  
                    cnt++;            
                }p++;
            }
            cnt=0;
            flg=false;
            for(Date dat:maxPosibleDate){
                cnt++;
                if(dat == ssnDate){
                    flg= true;
                    break;
                }            
            }
            if(flg){
                showText=false;
                if(cnt < 4){
                    showText=false;                    
                    //calculate array list of dates.
                    while(noOfDays > 0){
                        String today=DateTime.newInstance(ssnDate.addDays(count),Time.newInstance(0, 0, 0, 0)).format('EEEE')+'';
                        for(Integer i=0;i<weekday.size();i++){
                            if(today.startsWith(weekday[i])){
                                dateList.add(ssnDate.addDays(count));
                                noOfDays = noOfDays-1;
                            }
                        }count++;
                     }
                                        
                    //Assign dates to session entry..
                     Double completedHour=0.0;
                     Double totalHour=0.0;
                     Double noOfHour=0.0;
                     count=0;
                     Integer status_and_fac_count=0;
                     Integer sscnt=0;                 
                     for(Session__c ss : ssnList){
                         if(sscnt == 0)
                             totalHour = fst_tot_hr/60;
                         else
                             totalHour= Double.valueOf(ss.Duration_In_Hour__c)+completedHour;
                         
                         Integer chkcnt=0;
                         noOfHour=0;
                         while(totalHour > 0 ){
                             System.debug('...status_and_fac_count...'+status_and_fac_count);                             
                             chkcnt++;
                             if(totalHour == timeDiff && oldssEntry.size() > status_and_fac_count){
                                 if(chkcnt == 1 && sscnt != 0)
                                     noOfHour = Double.valueOf(ss.Duration_In_Hour__c);
                                 else
                                     noOfHour = totalHour;
                                                                      
                                 if(sscnt == 0 && chkcnt == 1){                                 
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C='Not Started'));    
                                 }else if(updateFaculty){
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));     
                                 }else     
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=oldssEntry[status_and_fac_count].faculty__c,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));    
                                 
                                 totalHour = totalHour - timeDiff;
                                 completedHour=0;
                                 count++;
                             }else if(totalHour < timeDiff && oldssEntry.size() > status_and_fac_count){
                                 if(chkcnt == 1 && sscnt != 0){                                     
                                     noOfHour = Double.valueOf(ss.Duration_In_Hour__c);
                                     completedHour=completedHour+Double.valueOf(ss.Duration_In_Hour__c);
                                 }
                                 else{
                                     noOfHour = totalHour;
                                     completedHour=totalHour;
                                 }
                                 if(sscnt == 0 && chkcnt == 1){                                 
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C='Not Started'));    
                                 }else if(updateFaculty){
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));     
                                 }else     
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=oldssEntry[status_and_fac_count].faculty__c,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));     
                                
                                 totalHour = totalHour - timeDiff;                                 
                             }else if(totalHour > timeDiff && oldssEntry.size() > status_and_fac_count){
                                 if(chkcnt == 1 )
                                     noOfHour = timeDiff - completedHour;
                                 else 
                                     noOfHour = timeDiff;    
                                 if(sscnt == 0 && chkcnt == 1){                                 
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C='Not Started'));    
                                 }else if(updateFaculty){
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=fid,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));     
                                 }else     
                                     newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=oldssEntry[status_and_fac_count].faculty__c,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C=oldssEntry[status_and_fac_count].Status__C));    
                                 count++;
                                 totalHour = totalHour - timeDiff; 
                                 if(totalHour > 0 && totalHour < timeDiff)
                                     completedHour=totalHour;
                                 else 
                                     completedHour=0;
                             }else{
                                 noOfHour = totalHour;
                                 newssEntry.add(new SessionEntry__c(Session__c = ss.Id,Session_Name__c=ss.Session_Name__c,StartDate__c=dateList[count],Session_Type__c=ss.Session_Type__c,Batch__c=bDet.Id,Start_Time__c=bDet.Start_Time__c,End_Time__c=bDet.End_Time__c,Course_Name__c=ss.CourseId__r.Name,faculty__c=oldssEntry[status_and_fac_count-1].faculty__c,Batch_Name__c=bDet.Name,No_Of_Hours__c=noOfHour*60,Remaining_Hour__c=noOfHour*60,Status__C='Not Started'));      
                                 totalHour = totalHour - timeDiff;
                             }status_and_fac_count++;
                         }
                         sscnt++;                         
                    }
                    delete oldssEntry;
                    Insert newssEntry;
            entryDetails();  
                }else{
                    showText=true;
                    textMessage='Date difference should be less or equal to 3days.';    
                }
            }else{
                showText=true;
                textMessage='Invalid date.';
            }
            updateFaculty = false;          
        }catch(Exception e){}    
    }  
    
    //Save Into coordinator
    public void saveCordDet(){
        try{
            Update cord;
            Update cord.UserInfoId__r;
        }catch(Exception e){}
    }
    
     //Refresh the page 
    public void refreshPage(){
        showSave=true; 
        entryDetails();
    }
    
    public class TaskDetails{ 
        public Date clickdate;
        public List<SelectOption> facList{get;set;}
        public String fid;    
        public SessionEntry__c sec {get;set;}
        public TaskDetails(Date dt,String fd,SessionEntry__c sc,List<SelectOption> fList){ 
            facList = fList;
            fid = fd;
            clickdate = dt;
            sec=sc;            
        }  
     } 
     
    
      //Test Method
  static testMethod void testValidData(){
         UserInfo__c cord = new UserInfo__c();
         cord.PIN__c=332244;
         cord.DOB__c=System.toDay();
         cord.First_Name__c='Barun';
         cord.Last_Name__c='Jena';
         cord.Mobile_No__c='1234567890';
         cord.Email_Id__c='baruna@ceptes.com';
         Insert cord;  
         
         Program__c prg=new Program__c();
         prg.Name='DWH';
         Insert prg;
         
         Course__c crs=new Course__c();
         crs.Name='J2EE';
         crs.ProgramId__c=prg.Id;
         Insert crs; 
         
         Session__c ss=new Session__c();
         ss.Session_Name__c='Introduction';
         ss.CourseId__c = crs.Id;
         ss.Session_Type__c='Development';
         ss.Duration_In_Hour__c='14';
         insert ss;    

         Batch__c bat=new Batch__c();
         bat.CourseId__c=crs.Id;
         bat.Name='Morning';
         bat.WeekDay_Det__c='Mon;Tue;Wed;Thur;Fri;Sat;Sun';
         bat.Start_Time__c='09:00AM';
         bat.End_Time__c='11:00AM';
         bat.Start_Date__c=System.toDay();
         bat.change_from_ssentry__c='No';
         bat.Time_Diff__c=Double.valueOf(2.0);
         insert bat;         
         
         faculty__c fac = new faculty__c();
         fac.Course_Offered__c=true;
         fac.UserInfoId__c=cord.Id;
         insert fac;
         
         List<SessionEntry__c> newssList= new List<SessionEntry__c>();
         for(Integer i=0;i<3;i++){
             SessionEntry__c ses= new SessionEntry__c();
             ses.Session_Name__c='Intr'+i;
             ses.Session_Type__c='Devlopment'+i;
             ses.Course_Name__c=crs.Name;
             ses.Start_Time__c='10:00AM';
             ses.End_Time__c='12:00PM';
             ses.faculty__c=fac.Id;
             ses.No_Of_Hours__c=2*i;
             ses.Batch__c=bat.Id;
             ses.Session__c=ss.id;
             ses.StartDate__c=System.toDay().addDays(i+1);
             ses.Status__c = 'Not Available';
             newssList.add(ses); 
         }
         insert newssList;        
         
         UserInfo__c co=[Select Id,Name,UserId__c from UserInfo__c where Id=:cord.Id Limit 1];
                    
         System.debug('.........co.Login_ID__c.........'+co.UserId__c);
         Blob data = Blob.valueOf(co.UserId__c);
         String encryptedData = EncodingUtil.base64Encode(data);             
         Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
         ApexPages.currentPage().setCookies(new Cookie[]{ctpuser}); 
         CordHomePageHomeTabContr cordhm=new CordHomePageHomeTabContr();  
         cordhm.seletedCors=crs.Id;
         cordhm.cnfrmpwd='bkjena123';
         cordhm.saveChangedPassword();
         cordhm.rownum=1;
         cordhm.selectedBatch=bat.Id;
         cordhm.status = 'Alert';
         cordhm.showAll = false;    
         cordhm.entryDetails(); 
       
         SessionEntry__c sent=[Select Id,Name,Session_Name__c from SessionEntry__c where id=:newssList[0].Id limit 1];
         System.assertEquals(sent.Session_Name__c,'Intr0');
         
         for(TaskDetails tsk:cordhm.taskDetFromSEntry)
             tsk.clickdate=System.toDay();
         
         cordhm.saveSessEntry();       
         
         Delete cord;
         Delete bat;
     } 
}