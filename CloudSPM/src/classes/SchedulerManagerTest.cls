/*******************************************************************
* File Name : SchedulerManagerTest
* Description : Test class for SchedulerManager.
* Copyright : CloudSPM
********************************************************************/
@isTest
private class SchedulerManagerTest { 

    static testMethod void myUnitTest() {
    	
        // Schedule the test job
        String jobId = System.schedule('SchedulerManagerTest', SchedulerManager.CRON_EXP, new SchedulerManager());
        
        Scheduler_Manager__c mgr = new Scheduler_Manager__c();
    	mgr.Job_Id__c = jobId;
    	mgr.End_Date__c = Date.Today().addDays(-2);
    	insert mgr;
        
         // Schedule the test job
        String jobId1 = System.schedule('SchedulerManagerTest1', SchedulerManager.CRON_EXP, new SchedulerManager());
             
        // Get the information from the CronTrigger API object   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
    
        // Verify the expressions are the same
        System.assertEquals(SchedulerManager.CRON_EXP,  ct.CronExpression);
    
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
    
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00',  String.valueOf(ct.NextFireTime));   
    }
}