/*******************************************************************
* File Name : OracleSynchronizationBatchTest
* Description : Test class for OracleSynchronizationBatch.
* Copyright : CloudSPM
********************************************************************/

@isTest(seeAllData=true)
private class OracleSynchronizationBatchTest {

      static testMethod void myUnitTestForSuccess() {
        
       Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        FC_Lookup_Manager__c mng = new FC_Lookup_Manager__c(Lookup_Name__c = 'test',Report_Name__c = 'test',Report_Path__c = 'test');
        insert mng;
        
        FC_Lookup_Detail__c lcdetail = new FC_Lookup_Detail__c(Column_Name__c = 'test',Column_Value__c = 'test',Row_Number__c = 1,FC_Lookup_Manager__c = mng.id);
        insert lcdetail;
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Lookup_Name__c = mng.Id, Lookup_Column__c = 'test', Salesforce_Object_Api_Name__c='OpportunityLineItem',Business_Unit_Name__c='Unit Name', Business_Unit_Id__c='123456', Filter_Criterion__c='Quantity > 0', Oracle_Response_Location__c='Oracle_Transaction_Id__c', Status__c = 'Active');
        insert testMap;
        System.assertEquals(testMap.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        testMap.Business_Unit_Name__c = 'Unit Name1';
        update testMap;
        System.assertEquals(testMap.Business_Unit_Name__c, 'Unit Name1');
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=false, Datatype__c = 'DATE');
        insert oracleField1;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Manual_Entry__c=false);
        insert oracleField2;
        System.assertEquals(oracleField2.Name, 'Attribute2');
        Oracle_Table_Field__c oracleField3 = new Oracle_Table_Field__c(Name='Attribute3', Manual_Entry__c=true);
        insert oracleField3;
        System.assertEquals(oracleField3.Name, 'Attribute3');
        Oracle_Table_Field__c oracleField4 = new Oracle_Table_Field__c(Name='ParticipantId', Manual_Entry__c=false);
        insert oracleField4;      
       
        System.assertEquals(oracleField4.Name, 'ParticipantId');
        
        
        Salesforce_Oracle_Field_Mapping__c mapping1 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='OpportunityLineItem', Salesforce_Field_Api_Name__c='CreatedDate', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping1;
        System.assertEquals(mapping1.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        Salesforce_Oracle_Field_Mapping__c mapping2 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField2.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping2;
        System.assertEquals(mapping2.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        Salesforce_Oracle_Field_Mapping__c mapping3 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField3.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping3;
        System.assertEquals(mapping3.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        Salesforce_Oracle_Field_Mapping__c mapping4 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='CreatedBy', Salesforce_Field_Api_Name__c='Email', Oracle_Report_API__c='reportPath', Oracle_Field_Name__c=oracleField4.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping4;
        
       
        System.assertEquals(mapping4.Salesforce_Object_Api_Name__c, 'CreatedBy');
        
        Salesforce_Oracle_Field_Mapping__c[] fieldMappingList = [SELECT Id,Lookup_Name__c,Lookup_Input_Column__c,Lookup_Output_Column__c, Salesforce_Object_Api_Name__c, Salesforce_Field_Api_Name__c, Oracle_Report_API__c, Oracle_Field_Name__r.Name, Oracle_Field_Name__r.Manual_Entry__c, Oracle_Field_Name__r.Datatype__c 
                                    FROM Salesforce_Oracle_Field_Mapping__c 
                                    WHERE Salesforce_Oracle_Map__c =:testMap.Id AND Salesforce_Field_Api_Name__c != 'null'];
        
        Opportunity opp = new Opportunity(Name='Opp name', StageName='Stage', CloseDate=Date.today());
        insert opp;
        System.assertEquals(opp.Name, 'Opp name');
        
        Pricebook2 book = new Pricebook2(Name='book');
        insert book;
        System.assertEquals(book.Name, 'book');
        
        Product2 prod = new Product2(Name='prod');
        insert prod;
        System.assertEquals(prod.Name, 'prod');
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry  price = new PricebookEntry (UnitPrice=10, Pricebook2Id=standardPB.Id, Product2Id=prod.Id, IsActive = true, UseStandardPrice = false);
        insert price;
        System.assertEquals(price.UnitPrice, 10);
        
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId=opp.Id, Quantity=10, TotalPrice=100, PricebookEntryId=price.Id);
        insert lineItem;
        System.assertEquals(lineItem.OpportunityId, opp.Id);
        
        OracleWebservices.isRunningTest = true;
        OracleSynchronizationBatch batchapex = new OracleSynchronizationBatch(connection, connection1, 'OpportunityLineItem', 'SELECT Id, CreatedDate, Opportunity.Name, CreatedBy.Email FROM OpportunityLineItem LIMIT 1', fieldMappingList, '123456', 'Oracle_Transaction_Id__c');
        Database.executebatch(batchapex,1); 
        
    }
    
    static testmethod void myUnitTestForError() {
        
        Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
      
        FC_Lookup_Manager__c mng = new FC_Lookup_Manager__c(Lookup_Name__c = 'test',Report_Name__c = 'test',Report_Path__c = 'test');
        insert mng;   
        
        FC_Lookup_Detail__c lcdetail = new FC_Lookup_Detail__c(Column_Name__c = 'test',Column_Value__c = '',Row_Number__c = 1,FC_Lookup_Manager__c = mng.id);
        insert lcdetail;     
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Lookup_Name__c = mng.Id, Lookup_Column__c = 'test',Salesforce_Object_Api_Name__c='OpportunityLineItem',Business_Unit_Name__c='Unit Name', Business_Unit_Id__c='123456', Filter_Criterion__c='Quantity > 0', Oracle_Response_Location__c='Oracle_Transaction_Id__c', Status__c = 'Active');
        insert testMap;
        System.assertEquals(testMap.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=false, Datatype__c = 'DATE');
        insert oracleField1;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Manual_Entry__c=false);
        insert oracleField2;
        System.assertEquals(oracleField2.Name, 'Attribute2');
        Oracle_Table_Field__c oracleField3 = new Oracle_Table_Field__c(Name='Attribute3', Manual_Entry__c=true);
        insert oracleField3;
        System.assertEquals(oracleField3.Name, 'Attribute3');
        
        
        Salesforce_Oracle_Field_Mapping__c mapping1 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='OpportunityLineItem', Salesforce_Field_Api_Name__c='CreatedDate', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping1;
        System.assertEquals(mapping1.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        Salesforce_Oracle_Field_Mapping__c mapping2 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test',Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField2.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping2;
        System.assertEquals(mapping2.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        Salesforce_Oracle_Field_Mapping__c mapping3 = new Salesforce_Oracle_Field_Mapping__c(Lookup_Name__c = mng.Id,Lookup_Input_Column__c = 'test',Lookup_Output_Column__c = 'test', Salesforce_Object_Api_Name__c='Opportunity', Salesforce_Field_Api_Name__c='Name', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField3.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping3;
        System.assertEquals(mapping3.Salesforce_Object_Api_Name__c, 'Opportunity');
        
        Salesforce_Oracle_Field_Mapping__c[] fieldMappingList = [SELECT Id,Lookup_Name__c,Lookup_Input_Column__c,Lookup_Output_Column__c, Salesforce_Object_Api_Name__c, Salesforce_Field_Api_Name__c, Oracle_Report_API__c, Oracle_Field_Name__r.Name, Oracle_Field_Name__r.Manual_Entry__c, Oracle_Field_Name__r.Datatype__c 
                                    FROM Salesforce_Oracle_Field_Mapping__c 
                                    WHERE Salesforce_Oracle_Map__c =:testMap.Id AND Salesforce_Field_Api_Name__c != 'null'];
        
        Opportunity opp = new Opportunity(Name='Opp name', StageName='Stage', CloseDate=Date.today());
        insert opp;
        System.assertEquals(opp.Name, 'Opp name');
        
        Pricebook2 book = new Pricebook2(Name='book');
        insert book;
        System.assertEquals(book.Name, 'book');
        
        Product2 prod = new Product2(Name='prod');
        insert prod;
        System.assertEquals(prod.Name, 'prod');
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        PricebookEntry  price = new PricebookEntry (UnitPrice=10, Pricebook2Id=standardPB.Id, Product2Id=prod.Id, IsActive = true, UseStandardPrice = false);
        insert price;
        System.assertEquals(price.UnitPrice, 10);
        
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId=opp.Id, Quantity=10, TotalPrice=100, PricebookEntryId=price.Id);
        insert lineItem;
        System.assertEquals(lineItem.OpportunityId, opp.Id);
        
        OracleSynchronizationBatch batchapex = new OracleSynchronizationBatch(connection, connection1, 'OpportunityLineItem', 'SELECT Id, CreatedDate, Opportunity.Name, CreatedBy.Email FROM OpportunityLineItem LIMIT 1', fieldMappingList, '123456', 'Oracle_Transaction_Id__c');
        Database.executebatch(batchapex,1); 
    }
}