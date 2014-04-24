/*******************************************************************
* File Name : FCLookupDetailRefreshScheduler
* Description : Scheduler to manage Oracle synchronization batch process.
* Copyright : CloudSPM
********************************************************************/
global class FCLookupDetailRefreshScheduler implements Schedulable {
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	
	global void execute(SchedulableContext sc) {
		FCLookupDetailRefreshBatch batchapex = new FCLookupDetailRefreshBatch();
		Database.executebatch(batchapex,10); 
	}

}