/*******************************************************************
* File Name : ParameterEditOverrideControllerTest
* Description : Test class for ParameterEditOverrideController.
* Copyright : CloudSPM
********************************************************************/
@isTest
private class ParameterEditOverrideControllerTest {

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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(param);
        ParameterEditOverrideController controller = new ParameterEditOverrideController(sc);
        
        controller.refreshColumnList();

    }
}