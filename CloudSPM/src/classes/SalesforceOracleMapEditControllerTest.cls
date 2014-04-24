/*******************************************************************
* File Name : SalesforceOracleMapEditControllerTest
* Description : Test methods for SalesforceOracleMapEditController.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class SalesforceOracleMapEditControllerTest {

    static testMethod void myUnitTest() {
        SFMappingObjects__c objectDetail = new SFMappingObjects__c(SF_Object__c='Opportunity');
        insert objectDetail;
        
        //create test FC Lookup Manager
        FC_Lookup_Manager__c fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant';
        fcManager.Report_Name__c = 'SPM_GET_PARTICIPANT';
        fcManager.Report_Path__c = '/Custom/SFDC/Reports';
        insert fcManager;
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Name='testMap',Lookup_Name__c=fcManager.id,Lookup_Column__c = 'test', Salesforce_Object_Api_Name__c='OpportunityLineItem', Filter_Criterion__c='', Business_Unit_Name__c='IC Performance Test', Oracle_Response_Location__c='Oracle_Transaction_Id__c');
        insert testMap;
        System.assertEquals(testMap.Name, 'testMap');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testMap);
        SalesforceOracleMapEditController controller = new SalesforceOracleMapEditController(sc);
    }
}