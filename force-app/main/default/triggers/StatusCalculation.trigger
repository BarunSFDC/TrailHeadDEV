trigger StatusCalculation on Batch__c (Before Insert,Before update,After Insert,After Update){
    
   Batch__c bat=Trigger.new[0];
   
    double timeDiff = bat.Time_Diff__c ;                        
    Integer count=0;  
    Double totHour=0;       
    Integer noOfDays;      
    Double timeRem; 
    String[] weekday=new String[]{}; 
    weekday=bat.WeekDay_Det__c.split(';');      
    Date[] dateList=new Date[]{};  
    List<Session__c> ssList;  
    Course__c crs;                  
    try{
           ssList=[Select Id,Name,Session_Name__c,Session_Type__c,Duration_In_Hour__c from Session__c where CourseId__c=:bat.CourseId__c order by CreatedDate  limit 50]; 
           crs=[select Id,Name,Course_Duration_in_hr__c from Course__c where Id=:bat.CourseId__c];    
             
           for(Session__c ss : ssList)
               totHour=totHour+Double.valueOf(ss.Duration_In_Hour__c);
           noOfDays=Integer.valueOf(totHour/timeDiff);
           timeRem=totHour-(noOfDays*timeDiff);
         
           if(timeRem != 0)
               noOfDays=noOfDays+1;
         //calculate array list of dates.    
           while(noOfDays > 0){ 
               String today=DateTime.newInstance(bat.Start_Date__c.addDays(count),Time.newInstance(0, 0, 0, 0)).format('EEEE')+'';
               for(Integer i=0;i<weekday.size();i++){
                   if(today.startsWith(weekday[i])){
                       dateList.add(bat.Start_Date__c.addDays(count));
                       noOfDays = noOfDays-1; 
                   }
               }count++;   
           }
    }catch(Exception e){}
     
     if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){  
            for(Batch__c b:Trigger.new){ 
                if(b.change_from_ssentry__c == 'No')        
                    b.End_Date__c = dateList[dateList.size()-1];
            }              
        }
    }   
       
   if(Trigger.isAfter){
       if(Trigger.isInsert){
           calculateDate();
       }
       if(Trigger.isUpdate){
           if(bat.Status__c == 'Not Started' && bat.change_from_ssentry__c == 'No' ){
               List<SessionEntry__c> sntList=[Select Id,Name from SessionEntry__c where batch__c=:bat.Id Limit 300];               
               try{
                   delete sntList;
               }catch(Exception e){}
               calculateDate();
           }
       }
   }
       
   public void calculateDate(){
       try{          
           List<SessionEntry__c> sentList=new  List<SessionEntry__c>();           
         //Assign dates to session entry..
          Double completedHour=0.0;
          Double totalHour=0.0;
          Double noOfHour;
          count=0;
          for(Session__c ss : ssList){
              totalHour= Double.valueOf(ss.Duration_In_Hour__c)+completedHour;
              Integer chkcnt=0;
              noOfHour=0;                  
              while(totalHour > 0 ){ 
                  chkcnt++;                      
                  if(totalHour == timeDiff){
                      if(chkcnt == 1)
                          noOfHour = Double.valueOf(ss.Duration_In_Hour__c);
                      else
                          noOfHour = totalHour;
                      sentList.add(new SessionEntry__c(
                               Session__c = ss.Id,
                               Session_Name__c=ss.Session_Name__c,
                               StartDate__c=dateList[count],
                               Session_Type__c=ss.Session_Type__c,
                               Batch__c=bat.Id,
                               Start_Time__c=bat.Start_Time__c,
                               End_Time__c=bat.End_Time__c,
                               Course_Name__c=crs.Name,
                               Batch_Name__c=bat.Name,
                               No_Of_Hours__c=noOfHour*60,
                               Remaining_Hour__c=noOfHour*60,
                               Status__C='Not Started'));                          
                      
                      totalHour = totalHour - timeDiff; 
                      completedHour=0;
                      count++;
                  }else if(totalHour < timeDiff){
                      if(chkcnt == 1)
                          noOfHour = Double.valueOf(ss.Duration_In_Hour__c);
                      else 
                          noOfHour = totalHour;
                      sentList.add(new SessionEntry__c(
                               Session__c = ss.Id,
                               Session_Name__c=ss.Session_Name__c,
                               StartDate__c=dateList[count],
                               Session_Type__c=ss.Session_Type__c,
                               Batch__c=bat.Id,
                               Start_Time__c=bat.Start_Time__c,
                               End_Time__c=bat.End_Time__c,
                               Course_Name__c=crs.Name,
                               Batch_Name__c=bat.Name,
                               No_Of_Hours__c=noOfHour*60,
                               Remaining_Hour__c=noOfHour*60,
                               Status__C='Not Started'));                          
                      if(chkcnt == 1)
                          completedHour=completedHour+Double.valueOf(ss.Duration_In_Hour__c);
                      else
                          completedHour=totalHour;          
                      totalHour = totalHour - timeDiff;                     
                  }else{
                      if(chkcnt == 1)
                          noOfHour = timeDiff - completedHour;
                      else 
                          noOfHour = timeDiff;
                      sentList.add(new SessionEntry__c(
                               Session__c = ss.Id,
                               Session_Name__c=ss.Session_Name__c,
                               StartDate__c=dateList[count],
                               Session_Type__c=ss.Session_Type__c,
                               Batch__c=bat.Id,
                               Start_Time__c=bat.Start_Time__c,
                               End_Time__c=bat.End_Time__c,
                               Course_Name__c=crs.Name,
                               Batch_Name__c=bat.Name,
                               No_Of_Hours__c=noOfHour*60,
                               Remaining_Hour__c=noOfHour*60,
                               Status__C='Not Started'));                              
                      count++;
                      totalHour = totalHour - timeDiff;                                                
                      if(totalHour > 0 && totalHour < timeDiff)
                          completedHour=totalHour;
                      else 
                          completedHour=0;                               
                  }
              }
          }          
          Insert sentList;
       }catch(Exception e){}  
   } 
}