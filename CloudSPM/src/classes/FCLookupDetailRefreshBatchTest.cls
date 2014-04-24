/*******************************************************************
* File Name : FCLookupDetailRefreshBatchTest
* Description : Test class for Batch to Refresh Lookup details.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class FCLookupDetailRefreshBatchTest {

    static testMethod void myUnitTest() { 
    	
    	Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Transactional Business Intelligence');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Transactional Business Intelligence');
        
        //create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'test1'; 
        fcManager.Report_Name__c = 'test1';
        fcManager.Report_Path__c = 'test1';
        insert fcManager;
        system.assert(fcManager.id != null,'FC_Lookup_Manager is Not inserted');
        
        //create test FC_Lookup_Detail
        List<FC_Lookup_Detail__c> fcDetailList = new List<FC_Lookup_Detail__c>();
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 0;
            fcDetail.Column_Name__c = 'test';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 1;
            fcDetail.Column_Name__c = 'test';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }   
        insert fcDetailList;
        
        FCLookupDetailRefreshBatch batchapex = new FCLookupDetailRefreshBatch();
        Database.executebatch(batchapex,10); 
    }
}