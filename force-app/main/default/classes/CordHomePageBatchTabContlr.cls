public class CordHomePageBatchTabContlr {

    public List<Batch__c> selectBatch { get; set;}
    public List<Batch__c> totalBatchRec;
    public Batch__c bat {get; set;}
    public Boolean showBatch {get; set;}
    public String batchId {get; set;}
    public String starttime{get;set;}
    public String endtime{get;set;}
    public Boolean isError{get;set;}
    public String errorMessage{get;set;} 
    public Boolean viewBatch{get;set;}
    public List<SelectOption> facultyList{get;set;}
    public String name{get;set;}
    public String condtion{get;set;}
    public String text{get;set;}
    
    public CordHomePageBatchTabContlr() {
        viewBatch =false;              
        try{
            totalBatch();
            this.bat = new Batch__c();            
        }catch(Exception e){}
    }  
    
    public void totalBatch(){
        selectBatch = new List<Batch__c>(); 
        try{           
            totalBatchRec = [SELECT Id, Name, CourseId__c,CourseId__r.Name,Status__c,Start_Time__c ,End_Time__C,Start_Date__c from Batch__c  order by Start_Date__c ];  
            selectBatch.addAll(totalBatchRec);        
            name='Name';
            text=null;
            condtion='Condition';
        }catch(Exception e){}
    }
    
    public PageReference doNewBatch() {
        bat=new Batch__c();
        showBatch = true;
        viewBatch =false;
        return null;
    }

    public void filterBatchCourse(){
        selectBatch = new List<Batch__c>();
        if(name == 'Course'){
            if(condtion == 'Equals to'){
                for(Batch__c b:totalBatchRec){
                    if(b.CourseId__r.Name == text)
                        selectBatch.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(Batch__c b:totalBatchRec){
                    if(b.CourseId__r.Name.startsWith(text))
                        selectBatch.add(b);                    
                }    
            }
        }else if(name == 'Batch'){
            if(condtion == 'Equals to'){
                for(Batch__c b:totalBatchRec){
                    if(b.Name == text)
                        selectBatch.add(b);                    
                }
            }else if(condtion == 'Like'){
                for(Batch__c b:totalBatchRec){
                    if(b.Name.startsWith(text))
                        selectBatch.add(b);     
                }
           }
        }
    }
    
    public void allBatches(){
        totalBatch();
    }

    public void cancelCourseDetail(){
         this.showBatch=false;
         viewBatch =false;
     }
     
    public void batSavePage() {
         String stime=ApexPages.currentPage().getParameters().get('pg:cordBatchTab:pg:fm:pgblk:pbs:pbsitemstime:slist2');
         String etime=ApexPages.currentPage().getParameters().get('pg:cordBatchTab:pg:fm:pgblk:pbs:pbsi:eid');
         Integer shour=Integer.valueOf(stime.split(':')[0]);
         Integer smin =Integer.valueOf(stime.subString(3,5));
         Integer ehour=Integer.valueOf(etime.split(':')[0]);
         Integer emin =Integer.valueOf(etime.subString(3,5));
         String stimeAmPm=stime.subString(5,7);
         String etimeAmPm=etime.subString(5,7);
         Double timeDiff;
         showBatch = true;
                  
         if(stimeAmPm == etimeAmPm){
             if(shour == 12)
                 timeDiff =Double.valueOf((ehour*60+emin)-((shour*60+smin) - 720))/60; 
             else 
                 timeDiff =Double.valueOf((ehour*60+emin) - (shour*60+smin))/60;  
         }       
         else if(stimeAmPm != etimeAmPm){
             if(ehour == 12)
                 timeDiff = Double.valueOf((ehour*60+emin) - (shour*60+smin))/60;
             else
                 timeDiff =Double.valueOf(720 - (shour*60+smin) + (ehour*60+emin))/60;  
         }
        try{
            String[] weekday=new String[]{};
            weekday=bat.WeekDay_Det__c.split(';');
            String dname=DateTime.newInstance(bat.Start_Date__c,Time.newInstance(0, 0, 0, 0)).format('EEEE')+'';
            Boolean dnamesub=false;
            for(Integer i=0;i<weekday.size();i++){
                if(dname.startsWith(weekday[i])){
                    dnamesub=true;
                    break;
                }
            } 
            if(timeDiff <= 0 ){
                isError = true;
                errorMessage='Start time should not gratter than or equals to end time.';
            }else if(dnamesub == false){
                isError = true;
                errorMessage='Start date is:'+dname+'.So the weekday list should contains '+dname+'.';
            }else{
                isError = false;
                bat.Start_Time__c=starttime;
                bat.End_Time__c=endtime;
                bat.Time_Diff__c=timeDiff;
                bat.Status__c = 'Not Started';
                bat.change_from_ssentry__c = 'No';
                upsert bat;
                totalBatch();
                showBatch=false;
            }
            
        } catch(Exception e) {}
        viewBatch =false; 
    }
    
    public void batCancelPage() {
        showBatch = false;
        viewBatch =false;
    }
       
    public List<SelectOption> getTimeFormatHour(){
        List<SelectOption> options = new List<SelectOption>();         
        options.add(new SelectOption('', '--Select--'));         
        for(Integer s=0;s<2;s++){
        Integer hh=0;
             for(Integer i=0;i<24;i++){
                  String tm='';
                  Integer mm=i/2;
                  Integer rem=i-mm*2;
                  if(i<20){
                           if(rem==0){
                                  String j='0'+String.valueOf(hh);
                                  String p='00';
                                  tm=j+':'+p;
                                 
                            }else{
                                  String j='0'+String.valueOf(hh);
                                  String p='30';
                                  tm=j+':'+p;
                                  hh=hh+1;  
                           }  
                  }else{
                        
                        if(rem==0){
                                  String j=String.valueOf(hh);
                                  String p='00';
                                  tm=j+':'+p;
                        }else{
                              String j=String.valueOf(hh);
                              String p='30';
                              tm=j+':'+p;
                              hh=hh+1;  
                       }
                  }
                if(s==0) 
                    options.add(new  SelectOption(tm+'AM',tm+'AM'));
                else if(s==1 && i==0){
                    tm='12:00';
                    options.add(new  SelectOption(tm+'PM',tm+'PM'));
                }else if(s==1 && i==1){
                    tm='12:30';
                    options.add(new  SelectOption(tm+'PM',tm+'PM')); 
                }else 
                    options.add(new  SelectOption(tm+'PM',tm+'PM')); 
             }      
        }
            System.debug('option return is..........'+options);
       return options; 
    }
     
     public void viewRecord(){
         viewBatch =true;
         showBatch = false; 
         try{ 
             bat=[SELECT Id,Name,CourseId__r.Name, CourseId__c,WeekDay_Det__c,Status__c,Start_Time__c ,End_Time__C,Start_Date__c 
                 from Batch__c  where Id=:batchId ];
            
         }catch(Exception e){} 
     } 
     
     public void deleteRec(){
         System.debug('The recent Batch Id is:_____________'+batchId);
         viewBatch =false;
         try{
             batch__c bat1=[SELECT Id,Name from batch__c where Id=:batchId LIMIT 1];
             List<SessionEntry__c> ssList=[Select Id,Name from  SessionEntry__c where Batch__c=:batchId Limit 100]; 
             delete ssList;                
             delete bat1;
             totalBatch();       
         } catch(Exception e) {}
            showBatch = false;  
       }
       
    public void editRecord(){
        isError=false;
        viewBatch =false;
        try{
            bat=[SELECT Id, Name, CourseId__c,WeekDay_Det__c,Status__c,Start_Time__c ,End_Time__C,Start_Date__c 
                 from Batch__c  where Id=:batchId ];  
            if(bat.Status__c == 'Not Started'){
                isError=false;
                starttime=bat.Start_Time__c;
                endtime=bat.End_Time__c;
                showBatch=true; 
            }else{
                isError = true;              
                showBatch=false;
            }
        }catch(Exception e){}
         
    
    }  
    //Test Class
      static testMethod void CordHomePageBatchTabTest(){
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
         bat.Status__c = 'Not Started';
         bat.WeekDay_Det__c='Mon;Tue;Wed;Thur;Fri;Sat;Sun';
         bat.Start_Time__c='09:00AM';
         bat.End_Time__c='11:00AM';
         bat.Start_Date__c=System.toDay();
         bat.change_from_ssentry__c='No';
         bat.Time_Diff__c=Double.valueOf(2.0);
         insert bat;        
        
            CordHomePageBatchTabContlr cobatch = new CordHomePageBatchTabContlr();
            cobatch.doNewBatch();
            
            ApexPages.currentPage().getParameters().put('pg:cordBatchTab:pg:fm:pgblk:pbs:pbsitemstime:slist2','09:00AM');
            ApexPages.currentPage().getParameters().put('pg:cordBatchTab:pg:fm:pgblk:pbs:pbsi:eid','11:00AM');
            Double timeDiff;      
            cobatch.batSavePage();
            cobatch.batCancelPage();
            cobatch.deleteRec();
            cobatch.editRecord();
            cobatch.bat.Status__c = 'Not Started';
            cobatch.editRecord();
            cobatch.name = 'Course';
            cobatch.condtion = 'Equals to';
            cobatch.text = 'crs.Id';
            cobatch.filterBatchCourse();
            cobatch.condtion = 'Like';
            cobatch.filterBatchCourse();
            cobatch.name = 'Batch';
            cobatch.condtion = 'Equals to';
            cobatch.text = 'Morning';
            cobatch.filterBatchCourse();
            cobatch.condtion = 'Like';
            cobatch.text = 'Morning';
            cobatch.filterBatchCourse();
            cobatch.allBatches();
            cobatch.cancelCourseDetail();
            cobatch.viewRecord();
            cobatch.getTimeFormatHour();
            
        
        }
}