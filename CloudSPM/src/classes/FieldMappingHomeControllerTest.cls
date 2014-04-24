/*******************************************************************
* File Name : FieldMappingHomeControllerTest
* Description : Test class for FieldMappingHomeController.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class FieldMappingHomeControllerTest {
    
    static testMethod void myUnitTest() {
    	//create test FC Lookup Manager
        FC_Lookup_Manager__c fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant';
        fcManager.Report_Name__c = 'SPM_GET_PARTICIPANT';
        fcManager.Report_Path__c = '/Custom/SFDC/Reports';
        insert fcManager;
        
        //create test FC_Lookup_Detail
        List<FC_Lookup_Detail__c> fcDetailList = new List<FC_Lookup_Detail__c>();
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 0;
            fcDetail.Column_Name__c = 'test'+i;
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
  
        insert fcDetailList;
        
        // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=true,  Lookup_Name__c = fcManager.Id);
        insert oracleField1;
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Manual_Entry__c=false);
        insert oracleField2;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        System.assertEquals(oracleField2.Name, 'Attribute2');
        
        Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        
        Salesforce_Oracle_Maps__c testMap = new Salesforce_Oracle_Maps__c(Name='testMap',Lookup_Name__c=fcManager.id,Lookup_Column__c = 'test', Salesforce_Object_Api_Name__c='OpportunityLineItem', Filter_Criterion__c='', Business_Unit_Name__c='IC Performance Test', Oracle_Response_Location__c='Oracle_Transaction_Id__c');
        insert testMap;
        System.assertEquals(testMap.Name, 'testMap');
        
        Salesforce_Oracle_Field_Mapping__c mapping1 = new Salesforce_Oracle_Field_Mapping__c(Salesforce_Object_Api_Name__c='OpportunityLineItem', Salesforce_Field_Api_Name__c='Subtotal', Oracle_Report_API__c=' ', Oracle_Field_Name__c=oracleField1.Id, Salesforce_Oracle_Map__c=testMap.Id);
        insert mapping1;
        System.assertEquals(mapping1.Salesforce_Object_Api_Name__c, 'OpportunityLineItem');
        
        Filter_Criteria__c filter1 = new Filter_Criteria__c(Salesforce_Object__c='OpportunityLineItem', Salesforce_Field__c='Subtotal', Operator__c='equals', Value__c='10',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter1;
        System.assertEquals(filter1.Salesforce_Object__c, 'OpportunityLineItem');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testMap);
        FieldMappingHomeController controller = new FieldMappingHomeController(sc);
        
        controller.getSalesforceObjects();
        
        controller.editMapping();
        
        controller.saveMapping();
        
        controller.sfOracleMapping.get(oracleField2.Name).Salesforce_Field_Api_Name__c='Subtotal';
        
        controller.saveMapping();
        
        controller.cancelMapping();
        
        controller.editFilters();
        
        controller.addFilter();
        
        controller.removeIndex = 1;
        controller.removeFilter();
        
        controller.cancelFilters();
        
        Filter_Criteria__c filter2 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='contains', Value__c='abc',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter2;
        System.assertEquals(filter2.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter3 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='CreatedDate', Operator__c='equals', Value__c='2013-10-01 10:30:00',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter3;
        System.assertEquals(filter3.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter4 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='CloseDate', Operator__c='greater than', Value__c='2013-10-01',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter4;
        System.assertEquals(filter4.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter5 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='IsDeleted', Operator__c='equals', Value__c='false',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter5;
        System.assertEquals(filter5.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter6 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='equals', Value__c='namea',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter6;
        System.assertEquals(filter6.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter7 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='starts with', Value__c='name',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter7;
        System.assertEquals(filter7.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter8 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='contains', Value__c='name',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter8;
        System.assertEquals(filter8.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter9 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='less than', Value__c='name',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter9;
        System.assertEquals(filter9.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter10 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='includes', Value__c='name',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter10;
        System.assertEquals(filter10.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter11 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='Name', Operator__c='excludes', Value__c='name',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter11;
        System.assertEquals(filter11.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter12 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='TotalOpportunityQuantity', Operator__c='includes', Value__c='1',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter12;
        System.assertEquals(filter12.Salesforce_Object__c, 'Opportunity');
        Filter_Criteria__c filter13 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='TotalOpportunityQuantity', Operator__c='excludes', Value__c='1',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter13;
        System.assertEquals(filter13.Salesforce_Object__c, 'Opportunity');
        controller.composeFilterCriteria();
        controller.saveFilters();
        
        Filter_Criteria__c filter14 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='TotalOpportunityQuantity', Operator__c='equals', Value__c='abc',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter14;
        System.assertEquals(filter14.Salesforce_Object__c, 'Opportunity');
        controller.composeFilterCriteria();
        controller.saveFilters();
        
        Filter_Criteria__c filter15 = new Filter_Criteria__c(Salesforce_Object__c='Opportunity', Salesforce_Field__c='TotalOpportunityQuantity', Operator__c=null, Value__c='1',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter15;
        System.assertEquals(filter15.Salesforce_Object__c, 'Opportunity');
        controller.composeFilterCriteria();
        controller.saveFilters();
        
        Filter_Criteria__c filter16 = new Filter_Criteria__c(Salesforce_Object__c='null', Salesforce_Field__c='null', Operator__c=null, Value__c='a',Salesforce_Oracle_Map__c=testMap.Id);
        insert filter16;
        System.assertEquals(filter16.Salesforce_Object__c, 'null');
        controller.composeFilterCriteria();
        controller.saveFilters();
        
        controller.fitlerCriteria.clear();
        controller.saveFilters();
        
        //create test FC Lookup Manager
        fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant';
        fcManager.Report_Name__c = 'SPM_GET_PARTICIPANT';
        fcManager.Report_Path__c = '/Custom/SFDC/Reports';
        insert fcManager;
        
        //create test FC_Lookup_Detail
        fcDetailList = new List<FC_Lookup_Detail__c>();
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 0;
            fcDetail.Column_Name__c = 'test'+i;
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
  
        insert fcDetailList;
        
        oracleField1 = new Oracle_Table_Field__c(Name='Attribute3', Lookup_Name__c = fcManager.Id);
        insert oracleField1;
        
        controller.composeLookupColumns();
    }
}