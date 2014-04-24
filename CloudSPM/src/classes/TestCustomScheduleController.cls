/**
    Name : TestCustomScheduleController 
    Author : 
    Date : 06/02/2014
    Description : 
*/
@isTest
public class TestCustomScheduleController{
    @isTest
    public static void test(){
    	
    	Scheduler_Manager_Setting__c schMgr= new Scheduler_Manager_Setting__c(name = 'Scheduler Manager Setting', Value__c = 1);
    	insert schMgr;
    	
        CustomScheduleController cs = new CustomScheduleController();
        
        ApexPages.CurrentPage().getParameters().put('a','weekly');
        ApexPages.CurrentPage().getParameters().put('pst0','2');
        cs.schedulerManager.End_Date__c = Date.today().adddays(1);
        cs.jobName = 'test';
    	cs.jobType = 'oracle_synchronization';
        cs.sunBool = true; 
        cs.monBool = true;
        cs.tusBool = true; 
        cs.wedBool = true; 
        cs.thsBool = true;
        cs.friBool = true;
        cs.satBool = true;
        cs.sheduleExicute();
        
        cs.jobName = 'test';
    	cs.jobType = 'lookup_refresh';
        ApexPages.CurrentPage().getParameters().put('a','monthly');
        ApexPages.CurrentPage().getParameters().put('pst0','2');
        ApexPages.CurrentPage().getParameters().put('monthRedio','day');
        cs.sheduleExicute();
        
        ApexPages.CurrentPage().getParameters().put('a','monthly');
        ApexPages.CurrentPage().getParameters().put('pst0','2');
        ApexPages.CurrentPage().getParameters().put('monthRedio','month');
        cs.sheduleExicute();
        
        ApexPages.CurrentPage().getParameters().put('a','hourly');
        ApexPages.CurrentPage().getParameters().put('pst0','2');
        cs.selectedWeekNameOpt = 'Monday';
        cs.selectedWeekNoOpt = '2';
        cs.selectedHoursOpt = '4';
        cs.sheduleExicute();
        
        list<crontrigger> cnlist = [SELECT Id FROM CronTrigger];
        system.assert(cnlist.size()>0);
    }
}