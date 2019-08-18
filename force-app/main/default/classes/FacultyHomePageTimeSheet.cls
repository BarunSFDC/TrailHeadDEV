public  class FacultyHomePageTimeSheet{ 
   
    public String Status { get; set; } 
    public List<TimeSheet> listTimeSheet {get;set;}
    Public Date currentWeekEndDate {get;set;}
    public double SelectedTimeEntry {get;set;}
    public IntiPM_Time__c WeekEndDate {get;set;}
    public String fid{get;set;}
    
    public string DateMon {get;set;}
    public string DateTue {get;set;}
    public string DateWed {get;set;}
    public string DateThu {get;set;}
    public string DateFri {get;set;}
    public string DateSat {get;set;}
    public string DateSun {get;set;}
    //start to get the day name with (dd/mm)--31/05--Rojalin
    public Integer week {get; set; }
    public String defaultDate { get; set; } 
    public boolean append{get; set;}
    public boolean withHours{get;set;}
    public boolean showWeekends { get; set; }
    public Boolean lock { get; set; } 
    
    public FacultyHomePageTimeSheet() {
        try{   
            fid=ApexPages.currentPage().getParameters().get('Id'); 
            Boolean chStatus;
            listTimeSheet = new List<Timesheet>();
            currentWeekEndDate = weekendDate(Date.TODAY());
            showWeekends=false;
            WeekEndDate = new IntiPM_Time__c();
            System.debug('.......WeekEndDate...'+WeekEndDate+'.....currentWeekEndDate...'+currentWeekEndDate);
            WeekEndDate.Week_Ending_Date__c = currentWeekEndDate;
            for(Timesheet__c  ttss: [Select Id, Total_Hours__c,Session_Id__c, Week_Ending_Date__c, Status__c From Timesheet__c 
                                     Where Week_Ending_Date__c = :WeekEndDate.Week_Ending_Date__c  Order By CreatedDate ASC]){
                if(ttss.Status__c == 'Submitted'){
                    chStatus=true;
                    break;
                }
            }
          /*  if(chStatus == true )
                this.lock = true;
            else 
                this.Status='Not Submitted';    */
              this.lock = false;  
            fillDate();
            
            if(Test.isRunningTest() == false){
               populateRecords();
            }
     
         }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }
    }

    public void PopulateLabels(Date WeekEndDt){
        DateTime dt = DateTime.newInstance(WeekEndDt.year(),WeekEndDt.month(),WeekEndDt.day(),0,0,0);
        
        DateSun = dt.format('MMM ddd');
        dt = dt.addDays(-1);
        DateSat = dt.format('MMM dd');
        dt = dt.addDays(-1);
        DateFri = dt.format('MMM dd');
        dt = dt.addDays(-1);
        DateThu = dt.format('MMM ddd');
        dt = dt.addDays(-1);
        DateWed = dt.format('MMM dd');
        dt = dt.addDays(-1);
        DateTue = dt.format('MMM dd');
        dt = dt.addDays(-1);
        DateMon = dt.format('MMM dd');
   }
   
    Public pagereference addLinesTask() {
        return addLines();
    }
    
    public pagereference addLines() {
        Timesheet t = new Timesheet();
        IntiPM_Time__c tm = new IntiPM_Time__c();
        t.TimeMon = tm;
        tm = new IntiPM_Time__c();
        t.TimeTue = tm;
        tm = new IntiPM_Time__c();
        t.TimeWed = tm;
        tm = new IntiPM_Time__c();
        t.TimeThu = tm;
        tm = new IntiPM_Time__c();
        t.TimeFri = tm;
        tm = new IntiPM_Time__c();
        t.TimeSat = tm;
        tm = new IntiPM_Time__c();
        t.TimeSun = tm;
        IntiPM_Time__c thr = new IntiPM_Time__c();
        thr.ru_Hours_Actual__c = 0;
        t.TotalHours  = thr;
        thr = new IntiPM_Time__c();
        thr.ru_Hours_Actual__c = 0; 
               
        listTimesheet.add(t);
        List<Timesheet> lstGM = new List<Timesheet>();
        for(Timesheet tsh : listTimesheet){
            if(tsh.IsTotal != true){
                lstGM.add(tsh);
            }
        }
        listTimesheet = new List<Timesheet>();
        listTimesheet.addAll(lstGM);
        if(listTimesheet.size() > 0){
            PopulateVerticleTotal();
        }
        
        return null;
    }
    
    public pagereference deleteLinesTask(){
        return deleteLines();
    }
   
    public pagereference deleteLines (){
        try{
            SET<ID> setTimeID = new SET<ID>();
            List<Timesheet> deleteList;
            deleteList = listTimesheet;
            
            if(SelectedTimeEntry != null){
                List<Timesheet> lstGM = new List<Timesheet>();
                for(integer i=0; i<deleteList.size();i++){
                    if(i != SelectedTimeEntry && deleteList.get(i).IsTotal != true){
                        lstGM.add(deleteList.get(i));
                    }
                    else {
                        if(deleteList.get(i).TimeMon.Id != null){
                            setTimeID.add(deleteList.get(i).TimeMon.Id);
                        }
                        if(deleteList.get(i).TimeTue.Id != null){
                            setTimeID.add(deleteList.get(i).TimeTue.Id);
                        }
                        if(deleteList.get(i).TimeWed.Id != null){
                            setTimeID.add(deleteList.get(i).TimeWed.Id);
                        }
                        if(deleteList.get(i).TimeThu.Id != null){
                            setTimeID.add(deleteList.get(i).TimeThu.Id);
                        }
                        if(deleteList.get(i).TimeFri.Id != null){
                            setTimeID.add(deleteList.get(i).TimeFri.Id);
                        }
                        if(deleteList.get(i).TimeSat.Id != null){
                            setTimeID.add(deleteList.get(i).TimeSat.Id);
                        }
                        if(deleteList.get(i).TimeSun.Id != null){
                            setTimeID.add(deleteList.get(i).TimeSun.Id);
                        }
                    }
                }
                
                if(setTimeID.size() > 0){
                    
                    List<IntiPM_Time__c> lstTDel = [Select Id, Timesheet__c From IntiPM_Time__c Where Id IN : setTimeID];
                    
                    SET<ID> sss = new SET<ID>();
                    for(IntiPM_Time__c inti : lstTDel){
                        sss.add(inti.Timesheet__c);
                    }
                    
                    List<Timesheet__c> lstTTT = [Select Id From Timesheet__c Where Id IN : sss];
                    delete lstTTT;
                }
               
                listTimesheet = new List<Timesheet>();
                listTimesheet.addAll(lstGM);
                if(listTimesheet.size() > 0){
                    PopulateVerticleTotal();
                }
            }
        }
        catch(DMLException dex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dex.getDMLMessage(0))); 
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }
        return null;
    }
    
   
    
    Public pagereference leftArrow() {
        WeekEndDate.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c.addDays(-7);
        PopulateLabels(WeekEndDate.Week_Ending_Date__c);
        currentWeekEndDate = weekendDate(WeekEndDate.Week_Ending_Date__c);
        WeekEndDate.Week_Ending_Date__c = currentWeekEndDate;
        populateRecords();
        fillDate();
        return null;
    }
    
    
    Public pagereference rightArrow() {
        WeekEndDate.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c.addDays(7);
        PopulateLabels(WeekEndDate.Week_Ending_Date__c);
        currentWeekEndDate = weekendDate(WeekEndDate.Week_Ending_Date__c);
        WeekEndDate.Week_Ending_Date__c = currentWeekEndDate;
        populateRecords();
        fillDate();
        return null;
    }
    
    Public pagereference PopulateTimecards() {
        currentWeekEndDate = weekendDate(WeekEndDate.Week_Ending_Date__c);
        WeekEndDate.Week_Ending_Date__c = currentWeekEndDate;
        populateRecords();
        fillDate();
        return null;
    }
    
      Public pagereference copyFromPreviousWeek() {
      Date previousWeekEndDate = WeekEndDate.Week_Ending_Date__c.addDays(-7);
        
        List<Timesheet__c> lltt = [Select i.Id, i.Total_Hours__c From Timesheet__c i WHERE Week_Ending_Date__c = :previousWeekEndDate  Order By CreatedDate ASC];
        System.debug('the value of append...........'+append);
        System.debug('the value of list..............'+lltt.size());
        if(!append && lltt.size() > 0){    
            listTimesheet = new List<Timesheet>();
        }   
                            
        for(Timesheet__c ts :  lltt) {
            Timesheet t = new Timesheet();
            IntiPM_Time__c tm = new IntiPM_Time__c();
            t.TimeMon = tm;
            tm = new IntiPM_Time__c();
            t.TimeTue = tm;
            tm = new IntiPM_Time__c();
            t.TimeWed = tm;
            tm = new IntiPM_Time__c();
            t.TimeThu = tm;
            tm = new IntiPM_Time__c();
            t.TimeFri = tm;
            tm = new IntiPM_Time__c();
            t.TimeSat = tm;
            tm = new IntiPM_Time__c();
            t.TimeSun = tm;
            IntiPM_Time__c thr = new IntiPM_Time__c();
            thr.ru_Hours_Actual__c = 0;            
            if(withHours)
               thr.ru_Hours_Actual__c = ts.Total_Hours__c;
            t.TotalHours  = thr;
            thr = new IntiPM_Time__c();
            thr.ru_Hours_Actual__c = 0;
            
             for(IntiPM_Time__c i : [Select i.Week_Day__c,i.Session_Id__c,i.Percent_Complete__c, i.Week_Ending_Date__c, i.ru_Hours_Actual__c, 
                                     i.SystemModstamp,   i.Name,i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id,  i.Description__c, i.CreatedDate, Timesheet__r.Status__c,Timesheet__c,
                                    i.CreatedById, i.Session_Id__r.CourseId__c,i.Session_Id__r.CourseId__r.ProgramId__c,i.Timesheet__r.Week_Ending_Date__c,i.Timesheet__r.Total_Hours__c,
                                    i.Approval_Status__c   From IntiPM_Time__c i 
                                    WHERE i.Timesheet__c = : ts.Id AND Week_Day__c != null  ]){
             
                if( i.Session_Id__c != null) {
                    if(withHours){
                        if(i.Week_Day__c == 'Monday'){
                            t.TimeMon.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }
                        else if(i.Week_Day__c == 'Tuesday'){
                            t.TimeTue.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }   
                        else if(i.Week_Day__c == 'Wednesday'){
                            t.TimeWed.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }
                        else if(i.Week_Day__c == 'Thursday'){
                            t.TimeThu.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }
                        else if(i.Week_Day__c == 'Friday'){
                            t.TimeFri.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }
                        else if(i.Week_Day__c == 'Saturday'){
                            t.TimeSat.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        }
                        else if(i.Week_Day__c == 'Sunday'){
                            t.TimeSun.ru_Hours_Actual__c = i.ru_Hours_Actual__c;
                        } 
                    }
                    if(t.SelectedTask == null && i.Session_Id__c != null){
                        t.SelectedTask = i.Session_Id__c;
                    }
                    if(t.SelectedCourse == null && i.Session_Id__r.CourseId__c != null){
                        t.SelectedCourse = i.Session_Id__r.CourseId__c;
                    }
                    if(t.SelectedProgram == null && i.Session_Id__r.CourseId__r.ProgramId__c != null){
                        t.SelectedProgram = i.Session_Id__r.CourseId__r.ProgramId__c;
                    }    
                
                }
             
            }
              if(t.selectedTask != null ){
                listTimesheet.add(t);
               } 
         }
         
            List<Timesheet> lstTimeSheetNew = new List<Timesheet>();
            for(Timesheet tsh : listTimesheet) {
                if(tsh.IsTotal == true){
                    continue;
                }
                lstTimeSheetNew.add(tsh);
            }
            
            listTimesheet = new List<Timesheet>();
            listTimesheet.addAll(lstTimeSheetNew);
          
            if(listTimesheet.size() > 0 ){
                PopulateVerticleTotal();
            }
        return null;
    }
    
     
    public string getCurrentWeekEndDateFormat(){
      return  string.valueof(currentWeekEndDate.day()) +'-' + string.valueof(currentWeekEndDate.month()) +'-' +string.valueof(currentWeekEndDate.year()) ;      
    }
    
    Public pagereference saveTimeCard() {
        try{
            List<IntiPM_Time__c> listNewTime = new List<IntiPM_Time__c>();
            List<Timesheet> timesheetsToSave = new List<Timesheet>();
            Faculty__c fac=[Select Id,Name from faculty__c where UserInfoId__r.UserId__c=:fid Limit 1];
            timesheetsToSave.addAll(listTimesheet);
            System.debug('................................................the size of timesheetstosave is '+timesheetsToSave.size());
            for(Timesheet t : timesheetsToSave){
            System.debug('the content of comments is.........................................................'+t.Comment);
                if(t.SelectedTask != null || t.SelectedProgram != null || t.SelectedCourse !=null ) {  
                    Timesheet__c tmSheet = new Timesheet__c();
                    string TimesheetId = null;
                    if(t.TimeMon.Timesheet__c == null && t.TimeTue.Timesheet__c == null && t.TimeWed.Timesheet__c == null && t.TimeThu.Timesheet__c == null && t.TimeFri.Timesheet__c == null && t.TimeSat.Timesheet__c == null && t.TimeSun.Timesheet__c == null){
                       
                        tmSheet.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                        tmSheet.Comments__c= t.Comment;
                        tmsheet.Session_Id__c=t.selectedTask;
                        tmsheet.Faculty__c=fac.id;
                        upsert tmSheet;
                        TimesheetId = tmSheet.Id;
                    }else{
                        if(t.TimeMon.Timesheet__c != null){
                            TimesheetId = t.TimeMon.Timesheet__c;
                        }
                        else if(t.TimeTue.Timesheet__c != null){
                            TimesheetId = t.TimeTue.Timesheet__c;
                        }
                        else if(t.TimeWed.Timesheet__c != null){
                            TimesheetId = t.TimeWed.Timesheet__c;
                        }
                        else if(t.TimeThu.Timesheet__c != null){
                            TimesheetId = t.TimeThu.Timesheet__c;
                        }
                        else if(t.TimeFri.Timesheet__c != null){
                            TimesheetId = t.TimeFri.Timesheet__c;
                        }
                        else if(t.TimeSat.Timesheet__c != null){
                            TimesheetId = t.TimeSat.Timesheet__c;
                        }
                        else if(t.TimeSun.Timesheet__c != null){
                            TimesheetId = t.TimeSun.Timesheet__c;
                        }
                    }
                    t.TimeTue.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    t.TimeWed.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    t.TimeThu.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    t.TimeFri.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    t.TimeSat.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    t.TimeSun.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                    if(t.TimeMon.Timesheet__c == null){
                        t.TimeMon.Timesheet__c = TimesheetId;
                    }
                    if(t.SelectedTask != null)
                        t.TimeMon.Session_Id__c = t.SelectedTask;
                    t.TimeMon.Week_Day__c = 'Monday';
                    t.TimeMon.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeMon.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeMon);
                    }
                    if(t.SelectedTask != null)
                        t.TimeTue.Session_Id__c = t.SelectedTask;
                    t.TimeTue.Week_Day__c = 'Tuesday';
                    t.TimeTue.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeTue.Timesheet__c == null){
                        t.TimeTue.Timesheet__c = TimesheetId;
                    }
                    if(t.TimeTue.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeTue);
                    }
                    if(t.SelectedTask != null)
                        t.TimeWed.Session_Id__c = t.SelectedTask;
                    t.TimeWed.Week_Day__c = 'Wednesday';
                    t.TimeWed.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeWed.Timesheet__c == null){
                        t.TimeWed.Timesheet__c = TimesheetId;
                    }
                    if(t.TimeWed.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeWed);
                    }
                    if(t.SelectedTask != null)
                        t.TimeThu.Session_Id__c = t.SelectedTask;
                    t.TimeThu.Week_Day__c = 'Thursday';
                    t.TimeThu.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeThu.Timesheet__c == null){
                        t.TimeThu.Timesheet__c = TimesheetId;
                    }
                    if(t.TimeThu.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeThu);
                    }
                    if(t.SelectedTask != null)
                        t.TimeFri.Session_Id__c = t.SelectedTask;
                    t.TimeFri.Week_Day__c = 'Friday';
                    t.TimeFri.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeFri.Timesheet__c == null){
                        t.TimeFri.Timesheet__c = TimesheetId;
                    }
                    if(t.TimeFri.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeFri);
                    }
                    if(t.SelectedTask != null)
                        t.TimeSat.Session_Id__c = t.SelectedTask;
                    t.TimeSat.Week_Day__c = 'Saturday';
                    t.TimeSat.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeSat.Timesheet__c == null){
                        t.TimeSat.Timesheet__c = TimesheetId;
                    } 
                    if(t.TimeSat.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeSat);
                    }
                    if(t.SelectedTask != null)
                        t.TimeSun.Session_Id__c = t.SelectedTask;
                    t.TimeSun.Week_Day__c = 'Sunday';
                    t.TimeSun.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    if(t.TimeSun.Timesheet__c == null){
                        t.TimeSun.Timesheet__c = TimesheetId;
                    }
                    if(t.TimeSun.ru_Hours_Actual__c!= null){
                        listNewTime.add(t.TimeSun);
                    }
                } 
            }
            if(listNewTime.size() > 0){
                system.debug('dit is voor de upsert van listNewTime');
                upsert listNewTime;
                system.debug('dit is na de upsert van listNewTime');
                populateRecords();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Timesheets have been saved'));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Session'));
            }
        }catch(DMLException dex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dex.getDMLMessage(0))); 
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }
        return null;
    }
    
    
      Public pagereference submitTimeCard() {
        try{    
            
            List<IntiPM_Time__c> listNewTime = new List<IntiPM_Time__c>();
            Faculty__c fac=[Select Id,Name from faculty__c where UserInfoId__r.UserId__c=:fid Limit 1];
            System.debug('......faculty__c.......'+fac);
           List<Timesheet__c> tsheetList=[Select Id,Name,Status__c from Timesheet__c where Faculty__c =: fac.id Limit 50];
            for(Timesheet__c ts:tsheetList){
                ts.Status__c='Submitted';
                update ts;
            }
            
                
            for(Timesheet t : listTimesheet){
              if(t.SelectedTask != null  && t.Status != 'Submitted' && t.Status != 'Approved'){  
                
                Timesheet__c tmSheet = new Timesheet__c();
                string TimesheetId = null;
                
                if(t.TimeMon.Timesheet__c == null && t.TimeTue.Timesheet__c == null && t.TimeWed.Timesheet__c == null && t.TimeThu.Timesheet__c == null && t.TimeFri.Timesheet__c == null && t.TimeSat.Timesheet__c == null && t.TimeSun.Timesheet__c == null){
                    //tmSheet.Activity__c = t.SelectedActivity;
                    tmSheet.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                    tmSheet.Status__c='Submitted';
                    tmSheet.Comments__c= t.Comment;
                    tmsheet.Session_Id__c=t.selectedTask;
                    tmsheet.Faculty__c=fac.id;
                    upsert tmSheet;
                    TimesheetId = tmSheet.Id;
                }
                else{
                    if(t.TimeMon.Timesheet__c != null){
                        TimesheetId = t.TimeMon.Timesheet__c;
                    }
                    else if(t.TimeTue.Timesheet__c != null){
                        TimesheetId = t.TimeTue.Timesheet__c;
                    }
                    else if(t.TimeWed.Timesheet__c != null){
                        TimesheetId = t.TimeWed.Timesheet__c;
                    }
                    else if(t.TimeThu.Timesheet__c != null){
                        TimesheetId = t.TimeThu.Timesheet__c;
                    }
                    else if(t.TimeFri.Timesheet__c != null){
                        TimesheetId = t.TimeFri.Timesheet__c;
                    }
                    else if(t.TimeSat.Timesheet__c != null){
                        TimesheetId = t.TimeSat.Timesheet__c;
                    }
                    else if(t.TimeSun.Timesheet__c != null){
                        TimesheetId = t.TimeSun.Timesheet__c;
                    }
                }
                
                t.TimeTue.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                t.TimeWed.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                t.TimeThu.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                t.TimeFri.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                t.TimeSat.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                t.TimeSun.Percent_Complete__c = t.TimeMon.Percent_Complete__c;
                
                if(t.TimeMon.Timesheet__c == null){
                    t.TimeMon.Timesheet__c = TimesheetId;
                }
                t.TimeMon.Session_Id__c = t.SelectedTask;
                t.TimeMon.Week_Day__c = 'Monday';
                t.TimeMon.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeMon.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeMon);
                }
                
                if(t.TimeTue.Timesheet__c == null){
                    t.TimeTue.Timesheet__c = TimesheetId;
                }
                t.Timetue.Session_Id__c = t.SelectedTask;
                t.TimeTue.Week_Day__c = 'Tuesday';
                t.TimeTue.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                
                if(t.TimeTue.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeTue);
                }
                
                t.TimeWed.Session_Id__c = t.SelectedTask;
                t.TimeWed.Week_Day__c = 'Wednesday';
                t.TimeWed.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeWed.Timesheet__c == null){
                    t.TimeWed.Timesheet__c = TimesheetId;
                }
                if(t.TimeWed.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeWed);
                }
                
                t.TimeThu.Session_Id__c = t.SelectedTask;
                t.TimeThu.Week_Day__c = 'Thursday';
                t.TimeThu.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeThu.Timesheet__c == null){
                    t.TimeThu.Timesheet__c = TimesheetId;
                }
                if(t.TimeThu.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeThu);
                }
                
                t.TimeFri.Session_Id__c = t.SelectedTask;
                t.TimeFri.Week_Day__c = 'Friday';
                t.TimeFri.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeFri.Timesheet__c == null){
                    t.TimeFri.Timesheet__c = TimesheetId;
                }
                if(t.TimeFri.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeFri);
                }
                
                t.TimeSat.Session_Id__c = t.SelectedTask;
                t.TimeSat.Week_Day__c = 'Saturday';
                t.TimeSat.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeSat.Timesheet__c == null){
                    t.TimeSat.Timesheet__c = TimesheetId;
                } 
                if(t.TimeSat.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeSat);
                }
                
                t.TimeSun.Session_Id__c = t.SelectedTask;
                t.TimeSun.Week_Day__c = 'Sunday';
                t.TimeSun.Week_Ending_Date__c = WeekEndDate.Week_Ending_Date__c;
                if(t.TimeSun.Timesheet__c == null){
                    t.TimeSun.Timesheet__c = TimesheetId;
                }
                if(t.TimeSun.ru_Hours_Actual__c!= null){
                    listNewTime.add(t.TimeSun);
                }
               
              } 
            }
            
            if(listNewTime.size() > 0){
                
                upsert listNewTime;
                populateRecords();
                this.lock=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Timecard has been submitted for approval'));
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select activity'));
            }
            if(listNewTime.size() > 0){
                upsert listNewTime;
                populateRecords();
                this.lock=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Timecard has been submitted for approval'));
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select activity'));
            }
     
        }
        catch(DMLException dex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dex.getDMLMessage(0))); 
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
        }
        return null;
    }
    
    public Date weekendDate(Date curDate) {
       DateTime d1 = datetime.newInstance(curDate.year(), curDate.month(), curDate.day(), 0,0,0);
       String weekday = d1.format('EEEE');
               
       while(weekday!='Sunday')
       {
               d1= d1.addDays(1);
               weekday = d1.format('EEEE');
       }
       
       return Date.newInstance(d1.year(), d1.month(), d1.day());
    }
 
    public PageReference DoUpdateTotal(){
      try{
        List<Timesheet> lstTimeSheetNew = new List<Timesheet>();
        
        for(Timesheet t : listTimesheet){
            if(t.IsTotal == true){
                continue;
            }
            
            t.TotalHours.ru_Hours_Actual__c = 0;

            if(t.TimeMon.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeMon.ru_Hours_Actual__c;
            }
            if(t.TimeTue.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeTue.ru_Hours_Actual__c;
            }
            if(t.TimeWed.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeWed.ru_Hours_Actual__c;
            }
            if(t.TimeThu.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeThu.ru_Hours_Actual__c;
            }
            if(t.TimeFri.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeFri.ru_Hours_Actual__c;
            }
            if(t.TimeSat.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeSat.ru_Hours_Actual__c;
            }
            if(t.TimeSun.ru_Hours_Actual__c != null){
                t.TotalHours.ru_Hours_Actual__c = t.TotalHours.ru_Hours_Actual__c + t.TimeSun.ru_Hours_Actual__c;
            }
         //   GrandTotal=t.TotalHours.ru_Hours_Actual__c;
            lstTimeSheetNew.add(t);
        }
        
        listTimesheet = new List<Timesheet>();
        listTimesheet.addAll(lstTimeSheetNew);
        
        lstTimeSheetNew = new List<Timesheet>();
        for(Timesheet t : listTimesheet){
            if(t.IsTotal == true){
                continue;
            }
            lstTimeSheetNew.add(t);
        }
        
        listTimesheet = new List<Timesheet>();
        listTimesheet.addAll(lstTimeSheetNew);
        
        if(listTimesheet.size() > 0){
            PopulateVerticleTotal();
        }
      } 
      catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
      }
      return null;
    }
    
    public void PopulateVerticleTotal(){

        double TotalMon = 0;
        double TotalTue = 0;
        double TotalWed = 0;
        double TotalThu = 0;
        double TotalFri = 0;
        double TotalSat = 0;
        double TotalSun = 0;
        double TotalWeek = 0;
        
        for(Timesheet t : listTimesheet){
            if(t.TimeMon.ru_Hours_Actual__c != null){
                TotalMon = TotalMon + t.TimeMon.ru_Hours_Actual__c;
            }
            if(t.TimeTue.ru_Hours_Actual__c != null){
                TotalTue = TotalTue + t.TimeTue.ru_Hours_Actual__c;
            }
            if(t.TimeWed.ru_Hours_Actual__c != null){
                TotalWed = TotalWed + t.TimeWed.ru_Hours_Actual__c;
            }
            if(t.TimeThu.ru_Hours_Actual__c != null){
                TotalThu = TotalThu + t.TimeThu.ru_Hours_Actual__c;
            }
            if(t.TimeFri.ru_Hours_Actual__c != null){
                TotalFri = TotalFri + t.TimeFri.ru_Hours_Actual__c;
            }
            if(t.TimeSat.ru_Hours_Actual__c != null){
                TotalSat = TotalSat + t.TimeSAt.ru_Hours_Actual__c;
            }
            if(t.TimeSun.ru_Hours_Actual__c != null){
                TotalSun = TotalSun + t.TimeSun.ru_Hours_Actual__c;
            }
        }
        
        TotalWeek = TotalMon + TotalTue + TotalWed + TotalThu + TotalFri + TotalSat + TotalSun;
        
        Timesheet t = new Timesheet();
        t.IsTotal = true;
        
        IntiPM_Time__c tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalMon;
        t.TimeMon = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalTue;
        t.TimeTue = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalWed;
        t.TimeWed = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalThu;
        t.TimeThu = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalFri;
        t.TimeFri = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalSat;
        t.TimeSat = tm;
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalSun;
        t.TimeSun = tm; 
        tm = new IntiPM_Time__c();
        tm.ru_Hours_Actual__c = TotalWeek;
        t.TotalHours = tm; 
        
        System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!>>>>>>>>>>>>>>>>'+t);
        listTimesheet.add(t);
        
    }  
    
    public void populateRecords(){
        listTimesheet = new List<Timesheet>();
        Date dtTEE = null;
        Timesheet t = new Timesheet();
        boolean flag=false;
        for(Timesheet__c  ttss: [Select Id, Total_Hours__c,Session_Id__c,Week_Ending_Date__c, Status__c From Timesheet__c 
                                    Where Week_Ending_Date__c = :WeekEndDate.Week_Ending_Date__c  Order By CreatedDate ASC]){
            System.debug('----------------------------------------------------'+ttss.Status__c);
            t = new Timesheet();
            
            Status=ttss.Status__c;            
            IntiPM_Time__c thr = new IntiPM_Time__c();
            thr.ru_Hours_Actual__c = ttss.Total_Hours__c;
            
            t.TotalHours  = thr;
            
            thr = new IntiPM_Time__c();
            
            IntiPM_Time__c tm = new IntiPM_Time__c();
            t.TimeMon = tm;
            tm = new IntiPM_Time__c();
            t.TimeTue = tm;
            tm = new IntiPM_Time__c();
            t.TimeWed = tm;
            tm = new IntiPM_Time__c();
            t.TimeThu = tm;
            tm = new IntiPM_Time__c();
            t.TimeFri = tm;
            tm = new IntiPM_Time__c();
            t.TimeSat = tm;
            tm = new IntiPM_Time__c();
            t.TimeSun = tm;  
                     
         for(IntiPM_Time__c i : [Select i.Week_Day__c,i.Session_Id__c,i.Percent_Complete__c, i.Week_Ending_Date__c, i.ru_Hours_Actual__c, 
                                     i.SystemModstamp, i.Name, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id,  i.Description__c, i.CreatedDate, Timesheet__r.Status__c,Timesheet__c,
                                    i.CreatedById, i.Session_Id__r.CourseId__c,i.Session_Id__r.CourseId__r.ProgramId__c, i.Timesheet__r.Week_Ending_Date__c,i.Timesheet__r.Total_Hours__c,
                                    i.Approval_Status__c   From IntiPM_Time__c i 
                                    WHERE i.Timesheet__c = : ttss.Id AND Week_Day__c != null AND i.Session_Id__c != null]){
                
                if(i.Week_Day__c == 'Monday'){
                    t.TimeMon = i;
 
                }
                else if(i.Week_Day__c == 'Tuesday'){
                    t.TimeTue = i;
 
                }   
                else if(i.Week_Day__c == 'Wednesday'){
                    t.TimeWed = i;
 
                }
                else if(i.Week_Day__c == 'Thursday'){
                    t.TimeThu = i;
 
                }
                else if(i.Week_Day__c == 'Friday'){
                    t.TimeFri = i;
 
                }
                else if(i.Week_Day__c == 'Saturday'){
                    t.TimeSat = i;
 
                }
                else if(i.Week_Day__c == 'Sunday'){
                    t.TimeSun = i;
 
                }   
                
                if(t.SelectedTask == null && i.Session_Id__c != null ){
                    t.SelectedTask = i.Session_Id__c ;
                }
                if(t.SelectedCourse == null && i.Session_Id__r.CourseId__c != null){
                    t.SelectedCourse = i.Session_Id__r.CourseId__c;
                }
                if(t.SelectedProgram == null && i.Session_Id__r.CourseId__r.ProgramId__c != null){
                    t.SelectedProgram = i.Session_Id__r.CourseId__r.ProgramId__c;
                }    
                flag=true;
            } 
            if(flag)
            listTimesheet.add(t);   
            flag=false;
        }           
       if(listTimesheet.size() == 0 ){
             t = new Timesheet();
            IntiPM_Time__c tm = new IntiPM_Time__c();
            t.TimeMon = tm;
            tm = new IntiPM_Time__c();
            t.TimeTue = tm;
            tm = new IntiPM_Time__c();
            t.TimeWed = tm;
            tm = new IntiPM_Time__c();
            t.TimeThu = tm;
            tm = new IntiPM_Time__c();
            t.TimeFri = tm;
            tm = new IntiPM_Time__c();
            t.TimeSat = tm;
            tm = new IntiPM_Time__c();
            t.TimeSun = tm;
            IntiPM_Time__c thr = new IntiPM_Time__c();
            thr.ru_Hours_Actual__c = 0;
            t.TotalHours  = thr;
            thr = new IntiPM_Time__c();
            thr.ru_Hours_Actual__c = 0;
            listTimesheet.add(t);
        }  
        
        if(listTimesheet.size() > 0){
            PopulateVerticleTotal();
        }  
    }
    
    //Start to get the day name with (dd/mm)--31/05--Rojalin
    public string getSun(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate);
        }else{
            return getFormatDate(currentWeekEndDate.addDays(1));
        }
    }
    
    public string getSat(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-1));
        }else{
            return getFormatDate(currentWeekEndDate);
        }
    }
    
    public string getFri(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-2));
        }else{
            return getFormatDate(currentWeekEndDate.addDays(-1));
        }
    }
    
    public string getThur(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-3));
        }else{
            return getFormatDate(currentWeekEndDate.addDays(-2));
        }
    }
    
    public string getWed(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-4));
        }else{
            return getFormatDate(currentWeekEndDate.addDays(-3));
        }
    }
    
    public string getTue(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-5));
        }else{
            return getFormatDate(currentWeekEndDate.addDays(-4));
        }
    }
    
    public string getMon(){
        if(DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)== 'Sun'){
            return getFormatDate(currentWeekEndDate.addDays(-6));
        }else{
            return getFormatDate(currentWeekEndDate.addDays(-5));
        }
    }
    
    public String getFormatDate(Date currentWeekEndDate) {
        return DateTime.newInstanceGmt(currentWeekEndDate,Time.newInstance(0, 0, 0, 0)).format('EEEE').substring(0,3)+'('+String.valueof(currentWeekEndDate.day())+'/'+String.valueof( currentWeekEndDate.month())+')';
    }

     public PageReference fillDate(){        
        Date dt = WeekEndDate.Week_Ending_Date__c;
        Date dtm = dt.toStartOfMonth();
        Date dtmw = dtm.toStartOfWeek(); 
        Date dtw = dt.toStartOfWeek();
        Integer days = dtmw.daysBetween(dtw); 
        System.debug('....................................th no. of days are '+days);
        Integer weeks = days/7;
        week = weeks+1; 
        System.debug('.......................................the week number is '+(weeks+1));
        currentWeekEndDate = weekendDate(WeekEndDate.Week_Ending_Date__c);
        WeekEndDate.Week_Ending_Date__c = currentWeekEndDate;        
        return null;
    }

    public PageReference showWeekend(){
    if(showWeekends==true)
        showWeekends=true;
    else
        showWeekends=false;    
        return null;
    }
    
     Public List<SelectOption> getPrograms(){
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('','--None--'));
            for(Program__c p : [SELECT Id,Name from Program__c Limit 50]){
                    lst.add(new SelectOption(p.Id,p.Name));
                } 
            return lst;
        }
        
  /*  public PageReference goHome(){
        PageReference ref=new PageReference('apex/FacultyHomePage/Id=BaJe0');    
        ref.setRedirect(true);
        return ref;
    }    */
     
    public class TimeSheet{
        public boolean IsTotal {get;set;}
        public IntiPM_Time__c TimeMon {get;set;}
        public IntiPM_Time__c TimeTue {get;set;}
        public IntiPM_Time__c TimeWed {get;set;}
        public IntiPM_Time__c TimeThu {get;set;}
        public IntiPM_Time__c TimeFri {get;set;}
        public IntiPM_Time__c TimeSat {get;set;}
        public IntiPM_Time__c TimeSun {get;set;}
        
        public string SelectedTask {get;set;}
        public string SelectedProgram {get; set;}
        public string SelectedCourse {get; set;}
        
        public IntiPM_Time__c TotalHours {get;set;}
        public string Status {get;set;}
        public String Comment { get; set; }
        public TimeSheet(){}
        
        Public List<SelectOption> getCourses(){
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('','--None--'));
            if(SelectedProgram != null){
                for(Course__c c:[Select Id,Name from Course__c where ProgramId__c=:SelectedProgram Limit 100]){
                    lst.add(new SelectOption(c.id,c.Name));
                }
            }
            return lst;
        }
        
        Public List<SelectOption> getTask(){
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('','--None--'));
            if(SelectedCourse != null){
                for(Session__c s:[Select Id,Name,Session_Name__c from Session__c where CourseId__c = :SelectedCourse  Order By Name Limit 1000]){
                    lst.add(new SelectOption(s.id, s.Session_Name__c));
                }
            }
            return lst;
        }   
    }
    
    // Test Method
   static testMethod void TestTimeSheet() {
        
        Program__c prg=new Program__c();
        prg.Name = 'Java';
        insert prg;
        
        Course__c crs = new Course__c();
        crs.Name = 'j2ee';
        crs.ProgramId__C = prg.Id;
        crs.Course_Duration_in_hr__c = 10;
        insert crs;
        
        Session__c ssn = new Session__c();
        ssn.Session_Name__c = 'test';
        ssn.CourseId__c = crs.Id;
        insert ssn;
        
        UserInfo__c fac = new UserInfo__c();
        fac.First_Name__c='Rakesh';
        fac.Last_Name__c='Prahaja';
        fac.Email_ID__c='baruna@ceptes.com';
        fac.DOB__c=System.toDay();
        fac.Mobile_No__c='1234567890';
        fac.PIN__c=332244;
        fac.Type__c='faculty';
        insert fac;            
        
        
        Coordinator__c cord = new Coordinator__c();
        cord.UserInfoId__c=fac.Id;
        Insert cord;
        
        Faculty__c faty = new Faculty__c();
        faty.UserInfoId__c=fac.Id;
        faty.CoordinatorId__c=cord.Id;
        insert faty;
                   
        Timesheet__c ts = new Timesheet__c();
        ts.Week_Ending_Date__c = System.today().addDays(-7);
        ts.Session_Id__c=ssn.Id;
        ts.NoOfHours__c=20;
        ts.Faculty__c = faty.Id;
        ts.Status__c='Submitted';
        insert ts;

      //  Faculty__c fc = [Select Id,Name,UserInfoId__c, CoordinatorId__c from faculty__c where UserInfoId__c=:fac.Id ];
      //  System.debug('........Faculty__c....'+fc);     
        ApexPages.currentPage().getParameters().put('Id',faty.Id);
        FacultyHomePageTimeSheet factTimeSht = new FacultyHomePageTimeSheet();
        
        factTimeSht.SelectedTimeEntry=1;
        factTimeSht.append=false;
        factTimeSht.withHours=true;
        factTimeSht.addLinesTask();
        factTimeSht.addLines();
        factTimeSht.deleteLines();
     
        factTimeSht.currentWeekEndDate = System.today();
        factTimeSht.SelectedTimeEntry = 10.00; 

        factTimeSht.deleteLinesTask();
        factTimeSht.leftArrow();
        factTimeSht.rightArrow();
        factTimeSht.PopulateTimecards();
        factTimeSht.weekendDate(System.toDay().addDays(-7));
        factTimeSht.copyFromPreviousWeek();
    
        factTimeSht.getCurrentWeekEndDateFormat();
        factTimeSht.saveTimeCard();
        factTimeSht.DoUpdateTotal();
        factTimeSht.getSun();
        factTimeSht.getSat();
        factTimeSht.getFri();
        factTimeSht.getThur();
        factTimeSht.getWed();
        factTimeSht.getTue();
        factTimeSht.getMon();
        
        factTimeSht.showWeekend();
        factTimeSht.getPrograms();
        factTimeSht.submitTimeCard();
        
      //  FacultyHomePageTimeSheet.TimeSheet  tsheet= new FacultyHomePageTimeSheet.TimeSheet();
        FacultyHomePageTimeSheet.TimeSheet  tsheet=factTimeSht.listTimeSheet.get(0);
                
        tsheet.SelectedProgram=prg.Id;
        tsheet.SelectedCourse=crs.Id;
        tsheet.SelectedTask=ssn.Id;
        tsheet.TimeMon.Hours__c =20.00;
        tsheet.TimeThu.Hours__c = 15.00;
        tsheet.TimeTue.Hours__c = 10.00;
        tsheet.TimeWed.Hours__c = 12.00;
        tsheet.TimeFri.Hours__c = 10.00;
        tsheet.TimeSat.Hours__c = 17.00;
        tsheet.TimeSun.Hours__c = 18.00;
        
        tsheet.getCourses();
        tsheet.getTask();
    }
}