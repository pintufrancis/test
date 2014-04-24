/*******************************************************************
* File Name : OracleIncentiveEstimatorControllerTest
* Description : Test class for OracleIncentiveEstimatorControllerTest.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class OracleIncentiveEstimatorControllerTest {

    static testMethod void myUnitTest() {
        OracleWebservices.isRunningTest = true;
        
        Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        FC_Lookup_Manager__c mng = new FC_Lookup_Manager__c(Lookup_Name__c = 'test',Report_Name__c = 'test',Report_Path__c = 'test');
        insert mng;
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Status__c = 'Estimator',Lookup_Name__c = mng.Id,Lookup_Column__c = 'test',Salesforce_Object_Api_Name__c='Opportunity',Business_Unit_Name__c='Unit Name', Business_Unit_Id__c='test', Oracle_Response_Location__c='Estimator_Transaction_Id__c');
        insert testMap;
        System.assertEquals(testMap.Salesforce_Object_Api_Name__c, 'Opportunity');   
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=false);
        insert oracleField1;
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Manual_Entry__c=false);
        insert oracleField2;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        System.assertEquals(oracleField2.Name, 'Attribute2');
        
        Salesforce_Oracle_Field_Mapping__c mapping1 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test', Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping1;
        System.assertEquals(mapping1.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        Salesforce_Oracle_Field_Mapping__c mapping2 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test', Salesforce_Fields_Relationship__c='Account###Name', Salesforce_Object_Api_Name__c='Account', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField2.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping2;
        System.assertEquals(mapping2.Salesforce_Object_Api_Name__c, 'Account');
        
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate=Date.Today(), StageName='ASR - Case Design');
        insert opp;
        System.assertEquals(opp.Name, 'Test Opp');
        
        OracleIncentiveEstimatorController controller = new OracleIncentiveEstimatorController();
        
        controller.searchText = 'test';
        controller.closeDateFrom = Date.today().addDays(-1);
        controller.closeDateTo = Date.today();
        controller.searchRecords();
        controller.searchResults[0].isSelected = true;
        controller.oracleEstimator();
        
        controller.searchText = '10/14/2011 11:46 AM'; 
        controller.searchRecords();
        
        controller.searchText = '2/10/2014'; 
        controller.searchRecords();
        
        controller.searchText = '2'; 
        controller.searchRecords();
        
        controller.searchText = 'true'; 
        controller.searchRecords();
    }
}