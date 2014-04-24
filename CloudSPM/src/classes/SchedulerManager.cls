global class SchedulerManager implements Schedulable {
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
   global void execute(SchedulableContext SC) {
   
      List<Scheduler_Manager__c> schedulerManagerList = [select id,Name,Job_Id__c,End_Date__c from Scheduler_Manager__c where End_Date__c <: Date.today()];
      if(schedulerManagerList != null && schedulerManagerList.size()>0){
          for(Scheduler_Manager__c schedulerManager:schedulerManagerList){
  			system.abortJob(schedulerManager.Job_Id__c);	
          }
          delete schedulerManagerList;
      }
      system.debug('---ajmer');
   } 
}