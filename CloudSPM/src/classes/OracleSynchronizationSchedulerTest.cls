/*******************************************************************
* File Name : OracleSynchronizationSchedulerTest
* Description : Test class for OracleSynchronizationScheduler.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class OracleSynchronizationSchedulerTest {

    static testMethod void myUnitTest() {
        OracleWebservices.isRunningTest = true;
        
        Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        FC_Lookup_Manager__c mng = new FC_Lookup_Manager__c(Lookup_Name__c = 'test',Report_Name__c = 'test',Report_Path__c = 'test');
        insert mng;
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Status__c = 'Active',Lookup_Name__c = mng.Id,Lookup_Column__c = 'test',Salesforce_Object_Api_Name__c='OpportunityLineItem',Business_Unit_Name__c='Unit Name', Business_Unit_Id__c='test', Filter_Criterion__c='Quantity > 0', Oracle_Response_Location__c='Oracle_Transaction_Id__c');
        insert testMap;
        System.assertEquals(testMap.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');       
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=false);
        insert oracleField1;
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Manual_Entry__c=true);
        insert oracleField2;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        System.assertEquals(oracleField2.Name, 'Attribute2');
        
        Salesforce_Oracle_Field_Mapping__c mapping1 = new Salesforce_Oracle_Field_Mapping__c(Salesforce_Object_Api_Name__c='OpportunityLineItem', Salesforce_Field_Api_Name__c='Subtotal', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping1;
        System.assertEquals(mapping1.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        Salesforce_Oracle_Field_Mapping__c mapping2 = new Salesforce_Oracle_Field_Mapping__c(Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Subtotal', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping2;
        System.assertEquals(mapping2.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        // Schedule the test job
        String jobId = System.schedule('OracleSynchronizationSchedulertest', OracleSynchronizationScheduler.CRON_EXP, new OracleSynchronizationScheduler());
             
        // Get the information from the CronTrigger API object   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    
        // Verify the expressions are the same
        System.assertEquals(OracleSynchronizationScheduler.CRON_EXP,  ct.CronExpression);
    
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
    
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00',  String.valueOf(ct.NextFireTime));   
    
    }
}