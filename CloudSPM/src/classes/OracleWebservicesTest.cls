/*******************************************************************
* File Name : OracleWebservicesTest
* Description : Test class for OracleWebservices.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class OracleWebservicesTest {

    static testMethod void myUnitTest() {
        OracleWebservices.incentiveCompensation('xml data', 'https://host.com', 443);
        
        OracleWebservices.fetchParticipantId('xml data', 'www.oraclefusionInstanceSalesRep.com', 443);
        
        
        //OracleWebservices.fetchBusinessUnitId('xml data', 'www.oraclefusionInstance.com', 443, testMap.Id);
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTest());
        
        OracleWebservices.incentiveCompensation('xml data', 'https://host.com', 443);
        
        OracleWebservices.fetchParticipantId('xml data', 'www.oraclefusionInstanceSalesRep.com', 443);
        
        //OracleWebservices.fetchBusinessUnitId('xml data', 'www.oraclefusionInstance.com', 443, testMap.Id);
        
        
        Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        FC_Lookup_Manager__c mng = new FC_Lookup_Manager__c(Lookup_Name__c = 'test',Report_Name__c = 'test',Report_Path__c = 'test');
        insert mng;

        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Name='testMap',Lookup_Column__c = 'test',Lookup_Name__c = mng.Id, Salesforce_Object_Api_Name__c='OpportunityLineItem', Filter_Criterion__c='', Business_Unit_Name__c='IC Performance Test',  Oracle_Response_Location__c='Oracle_Transaction_Id__c');
        insert testMap;
        System.assertEquals(testMap.Name, 'testMap');
        
        
        OracleWebservices.isRunningTest = true;
        OracleWebservices.incentiveCompensation('xml data', 'https://host.com', 443);
        
        OracleWebservices.fetchParticipantId('xml data', 'www.oraclefusionInstanceSalesRep.com', 443);
        
        OracleWebservices.fetchBusinessUnitId('xml data', 'www.oraclefusionInstance.com', 443, testMap.Id);
        
        
        OracleWebservices.composeBIRequest('user', 'pswd', 'path', 'filter');
        
        OracleWebservices.decodeBinaryResponse('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><runReportResponse xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"><runReportReturn><reportBytes>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLUdlbmVyYXRlZCBieSBPcmFjbGUgQkkgUHVibGlzaGVyIDExLjEuMS43LjEzMTAxNyAtRGF0YWVuZ2luZSwgZGF0YW1vZGVsOi9DdXN0b20vSW5jZW50aXZlIENvbXBlbnNhdGlvbi9TUE1fR0VUX09SR19JRC54ZG0gLS0+CjxEQVRBX0RTPjxTUkNfT1JHPklDIFBlcmZvcm1hbmNlIFRlc3Q8L1NSQ19PUkc+CjxHXzE+CjxPUkdfTkFNRT5JQyBQZXJmb3JtYW5jZSBUZXN0PC9PUkdfTkFNRT4KPE9SR19JRD4zMDAwMDAwMDA2Nzg0NzNMPC9PUkdfSUQ+CjwvR18xPgo8L0RBVEFfRFM+</reportBytes><reportContentType>text/xml</reportContentType><reportFileID xsi:nil="true"/><reportLocale xsi:nil="true"/></runReportReturn></runReportResponse></soapenv:Body></soapenv:Envelope>');
        
    }
}