public class CustomScheduleController {
    //---lists----
    public list<SelectOption> daysOpt{get;set;}
    public list<SelectOption> wmOpt{get;set;}
    public list<SelectOption> weekNoOpt{get;set;}
    public list<SelectOption> weekNameOpt{get;set;}
    public list<SelectOption> hoursOpt{get;set;}
   
    //---Objects---
    public Scheduler_Manager__c schedulerManager{get;set;}
    //--varebles---
    public string FrequencyValue{get;set;}
    public string temp{get;set;}
    public boolean sunBool{get;set;}
    public boolean monBool{get;set;}
    public boolean tusBool{get;set;}
    public boolean wedBool{get;set;}
    public boolean thsBool{get;set;}
    public boolean friBool{get;set;}
    public boolean satBool{get;set;}
    
    public String scheduleOpt{get;set;}
    public String selectedWeekNames{get;set;}
    public String selectedDaysopt{get;set;}
    public String selectedWeekNoOpt{get;set;}
    public String selectedWeekNameOpt{get;set;}
    public String selectedHoursOpt{get;set;}
    public String selectedDayOpt{get;set;}
    public String jobName{get;set;}
    public String jobType{get;set;}
    public String preferedStartTime{get;set;}
    
    public CustomScheduleController() {
        sunBool = false;
        monBool = false;
        tusBool = false;
        wedBool = false;
        thsBool = false;
        friBool = false;
        satBool = false;
        
        selectedDaysopt = '';
        selectedWeekNoOpt = '';
        selectedWeekNameOpt = '';
        selectedDayOpt = '';
        jobName = '';
        
        schedulerManager = new Scheduler_Manager__c();
        
        daysOpt = new list<SelectOption>();
        for(integer i=1;i<=31;i++)
            daysOpt.add(new SelectOption(string.valueOf(i),string.valueOf(i)));
        
        wmOpt = new List<SelectOption>(); 
        wmOpt.add(new SelectOption('weekly','Weekly'));
        wmOpt.add(new SelectOption('monthly','Monthly'));
        wmOpt.add(new SelectOption('hourly','Hourly'));
        //scheduleOpt = 'weekly';
        
        weekNoOpt = new list<SelectOption>();
        weekNoOpt.add(new SelectOption('1','the 1st'));
        weekNoOpt.add(new SelectOption('2','the 2nd'));
        weekNoOpt.add(new SelectOption('3','the 3rd'));
        weekNoOpt.add(new SelectOption('4','the 4th'));
        weekNoOpt.add(new SelectOption('5','the last'));
    
        weekNameOpt = new list<SelectOption>();
        weekNameOpt.add(new SelectOption('1','Sunday'));
        weekNameOpt.add(new SelectOption('2','Monday'));
        weekNameOpt.add(new SelectOption('3','Tuesday'));
        weekNameOpt.add(new SelectOption('4','Wednesday'));
        weekNameOpt.add(new SelectOption('5','Thursday'));
        weekNameOpt.add(new SelectOption('6','Friday'));
        weekNameOpt.add(new SelectOption('7','Saturday'));
    
        hoursOpt = new list<SelectOption>();
        for(integer i=1 ; i<=23; i++)
            hoursOpt.add(new SelectOption(string.valueOf(i),string.valueOf(i)));
       
    }
    //--sheduleExicute---
    public void sheduleExicute() {        
        scheduleOpt = ApexPages.CurrentPage().getParameters().get('a');        
        preferedStartTime = ApexPages.CurrentPage().getParameters().get('pst0');        
        String sch ='';
        String errMsg = '<ul style="margin:0px 0px -16px -45px;">';
        Boolean errFlag = false;
        if(jobName == null || jobName.trim().length()==0){
            errFlag = true;
            errmsg += '<li><strong>Job Name:</strong> Value is Required.</li>';
        }                
        if(schedulerManager.End_Date__c < Date.today()){ 
            //errFlag = true;
            //errmsg += '<li><strong>End Date:</strong>Date can not be less than today.</li>';
        }
        //weekNames = ApexPages.CurrentPage().getParameters().get('weekNameOpt');
        if(scheduleOpt == 'weekly'){
            String Day_of_weeks = '';
            Boolean flag = false;
            if(sunBool){
                Day_of_weeks += '1,';
            }
            if(monBool){
                Day_of_weeks += '2,';
                flag = true;
            }
            if(tusBool){
                Day_of_weeks += '3,';
            }
            if(wedBool){
                Day_of_weeks += '4,';
            }
            if(thsBool){
                Day_of_weeks += '5,';
            }
            if(friBool){
                Day_of_weeks += '6,';
            }
            if(satBool){
                Day_of_weeks += '7,';
            }
            
            if(Day_of_weeks == ''){
                // add error message                
                errmsg += '<li>Please select atleast one day</li>';                
                errFlag = true;                
            }
            Day_of_weeks = Day_of_weeks.removeEnd(',');
            sch = '0 0 '+preferedStartTime+' ? * '+Day_of_weeks;
            //sch =  '0 0 8 2-5 Feb-Mar ? 2014-2015';
            
        }else if(scheduleOpt == 'monthly'){
            selectedDayOpt = ApexPages.CurrentPage().getParameters().get('monthRedio');
            if(selectedDayOpt == 'day'){
                if(selectedDaysopt == '' || selectedDaysopt == null || selectedDaysopt.trim().length() == 0){
                    //add error
                    errmsg += '<li>Please select day</li>';                   
                    errFlag = true;
                }
                sch = '0 0 '+preferedStartTime+' '+selectedDaysopt+' * ?';
            }else if(selectedDayOpt == 'month'){
                if(selectedWeekNameOpt == '' || selectedWeekNameOpt == null || selectedWeekNameOpt.trim().length() == 0
                    || selectedWeekNoOpt == '' || selectedWeekNoOpt == null || selectedWeekNoOpt.trim().length() == 0)
                {
                    //add error
                    errmsg += '<li>Please select day and week Both</li>';
                    errFlag = true;                        
                }
                sch = '0 0 '+preferedStartTime+' ? * '+selectedWeekNameOpt+'#'+selectedWeekNoOpt;
            }else{
                // add error
                errFlag = true;
                errmsg += '<li>Please select Month Day or Week Day</li>';                   
            }
        }else if(scheduleOpt == 'hourly'){
            if(selectedHoursOpt == '' || selectedHoursOpt == null || selectedHoursOpt.trim().length() == 0){
                //add error
                errmsg += '<li>Please select Hours</li>';   
            }
            String hoursString = '';                   
            for(integer i=Integer.ValueOf(selectedHoursOpt); i<=23; i+=Integer.ValueOf(selectedHoursOpt)){            
                hoursString += i+',';
            }
            integer j = math.mod(Integer.ValueOf(selectedHoursOpt), 2);
            if( j == 0){
                j = 2;
            }
            for(integer i=j; i<Integer.ValueOf(selectedHoursOpt); i+=Integer.ValueOf(selectedHoursOpt)){            
                hoursString += i+',';
            }
            hoursString = hoursString.removeEnd(',');
            sch = '0 0 '+hoursString+' * * ?';          
        }
        
        if(errFlag){
            errMsg += '</ul>';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errMsg));
            return;
        } 
        
        system.debug('---my 1111 class');
        //scheduledMerge m = new scheduledMerge();
        //String sch = '20 30 8 10 2 ?';
                       
        try{
            //  new OracleSynchronizationScheduler()
            String jobId;
            if(jobType == 'oracle_synchronization') {
            	jobId = system.schedule(jobName, sch, new OracleSynchronizationScheduler());      	
            } else if(jobType == 'lookup_refresh') {
            	jobId = system.schedule(jobName, sch, new FCLookupDetailRefreshScheduler());      	
            }
              
            system.debug('---'+jobID);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Job Successfully Scheduled.'));
            
            
            schedulerManager.Name = jobName;
            schedulerManager.Job_Id__c = jobId;
            insert schedulerManager;
            schedulerManager = new Scheduler_Manager__c();
            
            List<Scheduler_Manager_Setting__c> schedulerManagerList = [select id,Value__c from Scheduler_Manager_Setting__c where name = 'Scheduler Manager Setting' and Value__c = 1];
            
            if(schedulerManagerList != null && schedulerManagerList.size()>0){
                schedulerManagerList[0].Value__c += 1;
                update schedulerManagerList;
                
                for(crontrigger cron:[select id from crontrigger where CronJobDetail.Name = 'SchedulerManager']){
                    System.abortJob(cron.id);
                }
                
                schedulerManager = new Scheduler_Manager__c();
                sch = '0 0 0 * * ?';
                system.schedule('SchedulerManager', sch, new SchedulerManager());   
                
            }            
                    
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }
    
}