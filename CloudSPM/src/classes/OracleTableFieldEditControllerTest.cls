/*******************************************************************
* File Name : OracleTableFieldEditControllerTest
* Description : Test class for OracleTableFieldEditController.
* Copyright : CloudSPM
********************************************************************/
@isTest
private class OracleTableFieldEditControllerTest {

    static testMethod void myUnitTest() {
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
  
        insert fcDetailList;
        
        // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
        
        //insert test parameters for FICReportsConfiguration
        Parameter__c param = new Parameter__c();
        param.Name = 'Calendar."Period Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Lookup_Name__c = fcManager.Id;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');
        
        Oracle_Table_Field__c oracleField = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=true,  Lookup_Name__c = fcManager.Id);
        insert oracleField;

        System.assertEquals(oracleField.Name, 'Attribute1');
                
        ApexPages.StandardController sc = new ApexPages.StandardController(oracleField);
        OracleTableFieldEditController controller = new OracleTableFieldEditController(sc);
        
        controller.refreshColumnList();
    }
}