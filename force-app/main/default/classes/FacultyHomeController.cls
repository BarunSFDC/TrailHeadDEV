public class FacultyHomeController {

    public String fid; 
    public String selectedbatch{get; set;} 
    public List<SessionEntry__c> sentryList;
    public String status{get;set;}
    public List<SelectOption> batchList{get;set;}
    public List<SessionEntry__c> sessEntList{get;set;}
    public List<EntryDetails> entDetails{get;set;}
    public String daystatus;
    public UserInfo__c userName{get;set;}
    public Integer newlypost{get;set;}
        
    public FacultyHomeController() {
        selectedbatch = 'All Batches'; 
        daystatus = 'today';
        status = 'All';
        Cookie ctpuser = ApexPages.currentPage().getCookies().get('ctpuser');
        Blob pw = EncodingUtil.base64Decode(ctpuser.getValue());
        fid = pw.toString(); 
        userName=[SELECT Id, First_Name__c,(SELECT Id FROM Facultys__r limit 1), Last_Name__c,Type__c, Email_ID__c, Mobile_No__c from UserInfo__c where UserId__c=:fid AND Type__c='Faculty'];   
        List<Ctp_QPost_Related__c> facread=[Select Id,Name from Ctp_QPost_Related__c where Ctp_Query_PortalId__r.Ctp_FacultyId__c=:userName.Facultys__r[0].Id AND Fac_Post_Read__c='Unread' AND Ctp_Query_PortalId__r.Qp_Stataus__c ='Open' limit 100];
        newlypost=facread.size();
        atLoadAllDetails();
        collectEntryDet();  
    }
    
    public void showEntryDet(){
        collectEntryDet();
    }
    
    public void refreshPage(){
        selectedbatch = 'All Batches'; 
        daystatus = 'today';
        status = 'All';
        atLoadAllDetails();
        collectEntryDet();  
    }
    
    public void atLoadAllDetails(){
        sentryList = new List<sessionentry__c>(); 
        try{
            sentryList=[SELECT Id,Comment__c,Batch__c,Batch_Name__c,selectsesion__c, End_Time__c, Faculty__c, No_Of_Hours__c, Session_Name__c, Session__c, StartDate__c,EndDate__c, Start_Time__c, Status__c,Course_Name__c, Session_Type__c, Completed_Hour__c, Remaining_Hour__c 
                        from sessionentry__c  where Faculty__r.UserInfoId__r.UserId__c=:fid  order by StartDate__c  limit 500];
            
        }catch(Exception e){}  
        batchList = new List<SelectOption>();      
        String batnm = '';
        for(SessionEntry__c ss:sentryList){
            if(!batnm.contains(ss.batch__c)){
                batchList.add(new SelectOption(ss.Batch__C,ss.Batch_Name__c)); 
                batnm = batnm+ss.batch__c+';';
            }
        }            
    } 
    
    public void collectEntryDet(){
        entDetails = new List<EntryDetails>();
        Date upcdate=Date.valueOf(System.toDay().addDays(7));
        for(SessionEntry__c ss:sentryList){
            if(selectedbatch == 'All Batches'){
                if(status == 'All'){
                    if(daystatus == 'all')
                        entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));
                    else if(daystatus == 'today'){
                        if(ss.StartDate__c == System.toDay()){
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));   
                        }     
                    }else if(daystatus == 'past' ){
                        if(ss.StartDate__c < System.toDay()){                        
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    }
                    else if(daystatus == 'upc'){
                        if(ss.StartDate__c <= upcdate && ss.StartDate__c > System.toDay()){                
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    } 
                }else{
                    if(daystatus == 'all' && ss.Status__c == status)
                        entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));
                    else if(daystatus == 'today' && ss.Status__c == status){
                        if(ss.StartDate__c == System.toDay()){
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));   
                        }     
                    }else if(daystatus == 'past' && ss.Status__c == status){
                        if(ss.StartDate__c < System.toDay()){                        
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    }
                    else if(daystatus == 'upc' && ss.Status__c == status){
                        if(ss.StartDate__c <= upcdate && ss.StartDate__c > System.toDay()){                
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    } 
                }
            }else if(selectedbatch == ss.Batch__c){
                if(status == 'All'){
                    if(daystatus == 'all')
                        entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));
                    else if(daystatus == 'today'){
                        if(ss.StartDate__c == System.toDay()){
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));   
                        }     
                    }else if(daystatus == 'past' ){
                        if(ss.StartDate__c < System.toDay()){                        
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    }
                    else if(daystatus == 'upc'){
                        if(ss.StartDate__c <= upcdate && ss.StartDate__c > System.toDay()){                
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    } 
                }else{
                    if(daystatus == 'all' && ss.Status__c == status)
                        entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));
                    else if(daystatus == 'today' && ss.Status__c == status){
                        if(ss.StartDate__c == System.toDay()){
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));   
                        }     
                    }else if(daystatus == 'past' && ss.Status__c == status){
                        if(ss.StartDate__c < System.toDay()){                        
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    }
                    else if(daystatus == 'upc' && ss.Status__c == status){
                        if(ss.StartDate__c <= upcdate && ss.StartDate__c > System.toDay()){                
                            entDetails.add(new EntryDetails(ss.selectsesion__c,false,ss));        
                        }    
                    } 
                }
            }               
        }                
    }
     
    public void allDayData(){
        daystatus = 'all';
        collectEntryDet();   
    }
    
    public void pastData(){
        daystatus = 'past';
        collectEntryDet();   
    }
    
    public void toDaysData(){
        daystatus = 'today';
        collectEntryDet();   
    }
    
    public void upCommingData(){
        daystatus = 'upc';
        collectEntryDet();   
    }
    
    public void sessStatusDetails(){        
        collectEntryDet();
    }
    
    public PageReference doLogout(){
        PageReference pgref=new PageReference('/apex/loginpage');
        pgref.setRedirect(true);
        return pgref;
    }
  
    public void taskDone(){
        try{
            for(EntryDetails ent:entDetails){
                if(ent.sEntRec.selectsesion__c == true && ent.sEntRec.Status__c == 'Not Started'){
                   ent.sEntRec.Status__c = 'Completed';
                   update  ent.sEntRec; 
                   updateBatch(ent.sEntRec.Batch__c,ent.sEntRec.Status__c); 
                }
            }    
        }catch(Exception e){}
        atLoadAllDetails();
        collectEntryDet();  
    }
    
    public void taskNotDone(){
         try{
            for(EntryDetails ent:entDetails){
                if(ent.sEntRec.selectsesion__c == true && ent.sEntRec.Status__c == 'Not Started' ){
                   ent.sEntRec.Status__c = 'Not Available';
                   update  ent.sEntRec;  
                   updateBatch(ent.sEntRec.Batch__c,ent.sEntRec.Status__c); 
                }
            }    
        }catch(Exception e){}
        atLoadAllDetails();
        collectEntryDet();  
    }    
    
     public void updateBatch(String bId,String status){
         try{
            List<SessionEntry__c> sList=new List<SessionEntry__c>();
            Batch__c bat=[Select Id,Name,End_Date__c,change_from_ssentry__c,Status__c,Availability__c from Batch__c where Id=:bId Limit 1];
            List<SessionEntry__c> seList=[Select Id,Status__c,StartDate__c  from SessionEntry__c where batch__c=:bId Limit 300];
            for(SessionEntry__c s:seList){
                if(s.Status__c == 'Completed'){
                    sList.add(s);    
                }                
            }
            if(sList.size() == seList.size()){
                bat.Status__c = 'Completed';
            }
            else if(sList.size() >= 1){ 
                bat.Status__c = 'In Progress'; 
                if(status == 'Not Available')
                    bat.Availability__c =  status;
                else
                    bat.Availability__c = null;
            }
            else{
                bat.Status__c ='Not Started'; 
                if(status == 'Not Available')
                    bat.Availability__c =  status; 
                else 
                    bat.Availability__c = null;
            }
            bat.change_from_ssentry__c = 'Yes';
            update bat; 
        }catch(Exception e){}

    } 
    
    public void refreshEntry(){
        collectEntryDet();        
    }
    
    public class EntryDetails{
        public Boolean color{get;set;}
        public Boolean checked{get;set;}
        public SessionEntry__c sEntRec{get;set;}
        public EntryDetails(Boolean chk,Boolean col,SessionEntry__c snt){
            color = col;
            checked = chk;
            sEntRec = snt;    
        }
        
    }
    
    //Test Methods   
    static testMethod void facHomeTest(){
        UserInfo__c cord = new UserInfo__c();
        cord.PIN__c=332244;
        cord.DOB__c=System.toDay();
        cord.First_Name__c='Barun';
        cord.Last_Name__c='Jena';
        cord.Mobile_No__c='1234567890';
        cord.Email_Id__c='baruna@ceptes.com';
        cord.Type__c='Faculty';
        Insert cord; 
        
        Program__c prg=new Program__c();
        prg.Name='DWH';
        Insert prg;
       
        Course__c crs=new Course__c();
        crs.Name='J2ME';
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
        
        Ctp_Query_Portal__c cqp= new Ctp_Query_Portal__c();
        cqp.Ctp_CourseId__c=crs.id;
        cqp.Ctp_FacultyId__c=fac.id;
        cqp.Ctp_SessionId__c=ss.id;
        Insert cqp;
        
        List<Ctp_QPost_Related__c> cqrList=new List<Ctp_QPost_Related__c>();            
        for(Integer i=0;i<3;i++){
            Ctp_QPost_Related__c cqr= new Ctp_QPost_Related__c();
            cqr.Ctp_Query_PortalId__c=cqp.Id;
            cqrList.add(cqr);
        }   
        insert cqrList;
        
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
             ses.selectsesion__c=true;
             ses.Session__c=ss.id;
             ses.Batch_Name__c=bat.Name;
             ses.StartDate__c=System.toDay().addDays(i);
             ses.Status__c = 'Not Started';
             newssList.add(ses); 
        }   
        insert newssList; 
        
        
        UserInfo__c co=[Select Id,Name,UserId__c from UserInfo__c where Id=:cord.Id Limit 1];
        Blob data = Blob.valueOf(co.UserId__c);
        String encryptedData = EncodingUtil.base64Encode(data);             
        Cookie ctpuser = new Cookie('ctpuser',encryptedData,null,-1,false); 
        ApexPages.currentPage().setCookies(new Cookie[]{ctpuser});
        FacultyHomeController fachm=new FacultyHomeController();        
        fachm.showEntryDet();
        fachm.collectEntryDet();
        fachm.refreshPage();
        fachm.atLoadAllDetails();
        fachm.allDayData();
        fachm.pastData();
        fachm.toDaysData();
        fachm.upCommingData();
        fachm.sessStatusDetails();
        fachm.doLogout();
        fachm.taskDone();
        fachm.taskNotDone();
        fachm.updateBatch(bat.Id,'Completed');
        fachm.refreshEntry(); 
        
        
        fachm.daystatus = 'all';
        fachm.collectEntryDet();
        
        fachm.daystatus = 'all';
        fachm.status='Not Started';
        fachm.collectEntryDet();
        
        fachm.selectedbatch=bat.Id;
        fachm.status='all';
        fachm.daystatus='all';
        fachm.collectEntryDet();        
       
        fachm.daystatus='past';
        fachm.collectEntryDet();
        
        fachm.daystatus='today';
        fachm.collectEntryDet();
        
        fachm.daystatus='upc';
        fachm.collectEntryDet();
        
        fachm.daystatus='past';
        fachm.status='Completd';
        fachm.collectEntryDet();
        
        fachm.daystatus='upc';
        fachm.status='Not Started';
        fachm.collectEntryDet();
        
        fachm.daystatus='today';
        fachm.status='Completd';
        fachm.collectEntryDet();        
     
    }      
}