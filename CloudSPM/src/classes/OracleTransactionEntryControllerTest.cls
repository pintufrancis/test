/*******************************************************************
* File Name : OracleTransactionEntryControllerTest
* Description : Test class for OracleTransactionEntryController.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class OracleTransactionEntryControllerTest {

    static testMethod void successCase() {
    	OracleWebservices.isRunningTest = true;
    	
    	Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        
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
        
        Oracle_Table_Field__c oracleField = new Oracle_Table_Field__c(Name='Attribute1', Manual_Entry__c=true,  Lookup_Name__c = fcManager.Id, Lookup_Input_Column__c = fcDetailList[0].Column_Name__c, Lookup_Column__c = fcDetailList[0].Column_Name__c);
        insert oracleField;
        System.assertEquals(oracleField.Name, 'Attribute1');
        
        OracleTransactionEntryController controller = new OracleTransactionEntryController();
        controller.oracleFieldList[0].value = 'test';
        controller.saveAction();
    }
    
    static testMethod void errorCase() {
        OracleTransactionEntryController controller = new OracleTransactionEntryController();
        controller.saveAction();
        
        Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        
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
        
        Oracle_Table_Field__c oracleField1 = new Oracle_Table_Field__c(Name='Attribute1', Datatype__c='NUMBER',  Lookup_Name__c = fcManager.Id, Lookup_Input_Column__c = fcDetailList[0].Column_Name__c, Lookup_Column__c = fcDetailList[0].Column_Name__c);
        insert oracleField1;
        System.assertEquals(oracleField1.Name, 'Attribute1');
        
        controller = new OracleTransactionEntryController();
        controller.oracleFieldList[0].value = 'test';
        controller.saveAction();
    }
    
    static testMethod void errorCase1() {
        
        Oracle_Connection__c connection = new Oracle_Connection__c(Host__c='https://host.com', Port__c=443, Username__c='myuser', Password__c='mypassword', Status__c='Active', Service__c='Fusion Incentive Compensation');
        insert connection;
        System.assertEquals(connection.Service__c, 'Fusion Incentive Compensation');
        
        
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
        
        
        Oracle_Table_Field__c oracleField2 = new Oracle_Table_Field__c(Name='Attribute2', Datatype__c='DATE');
        insert oracleField2;
        System.assertEquals(oracleField2.Name, 'Attribute2');
        
        Oracle_Table_Field__c oracleField3 = new Oracle_Table_Field__c(Name='Attribute3', Datatype__c='VARCHAR2');
        insert oracleField3;
        System.assertEquals(oracleField3.Name, 'Attribute3');
        
        OracleTransactionEntryController controller = new OracleTransactionEntryController();
        controller.oracleFieldList[0].value = '3/9/2014';
        controller.oracleFieldList[1].value = 'test';
        controller.saveAction();
        
        controller.oracleFieldList[0].value = 'test';
        controller.saveAction();
        
    }
}