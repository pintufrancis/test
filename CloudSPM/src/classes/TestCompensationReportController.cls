/**
    Name : TestCompensationReportController
    Author : 
    Date : Feburary 6, 2014
    Description : This controller is designed to test CompensationReportController.
*/

@isTest
public class TestCompensationReportController{  
    
    
    @isTest
    private static void testCompensationReport(){
    	PageReference testPage = Page.compensationReports;
		Test.setCurrentPage(testPage);

    	 Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        fic.XAxis__c = 0;
        fic.YAxis__c = 1;
        fic.Y2_Axis__c = 2;
        fic.Report_Type__c = 'Analysis';
        fic.XAxisLabel__c = 'test1';
        fic.YAxisLabel__c = 'test2';
        fic.Y2_Label__c = 'test3';
        fic.ShowOnDashboard__c = true;
        fic.Show_Chart__c = true;
        fic.Page_Orientation__c = 'landscape';
        fic.Display_Name__c = 'Attainment Comparison Table Report';
        fic.Report_Path__c = '/shared/Incentive Compensation/Transactional Analysis Samples/Report Components';
        fic.Report_Columns__c = 'Participant,Attainment,ITD Target,Period Year,';
        fic.Spedometer_Band__c = '#FFF';
        fic.Spedometer_Band_Color__c= '#FFF';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
                
        
        
        //create test Column Configuration
        ColumnConfiguration__c cc = new ColumnConfiguration__c();
        cc.Column_Format__c = 'Number';
        cc.Column_Name__c = 'test col';
        cc.Column_Sequence__c = 0;
        cc.Column_Width__c = '200';
        cc.Display__c = true;
        cc.Display_Sequence__c = 0;
        cc.FIC_Reports_Configuration__c = fic.id;
        cc.Pecision__c = 2;
        insert cc;
        
        cc = new ColumnConfiguration__c();
        cc.Column_Format__c = 'Character';
        cc.Column_Name__c = 'test col2';
        cc.Column_Sequence__c = 1;
        cc.Column_Width__c = '200';
        cc.Display__c = true;
        cc.Display_Sequence__c = 1;
        cc.FIC_Reports_Configuration__c = fic.id;
        cc.Pecision__c = 2;
        insert cc;
        
        //create test FCLookupManager
        FC_Lookup_Manager__c fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant';
        fcManager.Report_Name__c = 'SPM_GET_PARTICIPANT';
        fcManager.Report_Path__c = '/Custom/SFDC/Reports';
        insert fcManager;
        
        FC_Lookup_Detail__c fcLookupDeatail = new FC_Lookup_Detail__c();
        fcLookupDeatail.Column_Name__c = 'EMAIL_ADDRESS';
        fcLookupDeatail.Column_Sequence__c = 0;
        fcLookupDeatail.Column_Value__c = UserInfo.getUserEmail();
        fcLookupDeatail.FC_Lookup_Manager__c = fcManager.id;
        fcLookupDeatail.Row_Number__c = 0;
        insert fcLookupDeatail;
        
        fcLookupDeatail = new FC_Lookup_Detail__c();
        fcLookupDeatail.Column_Name__c = 'PARTICIPANT_NAME';
        fcLookupDeatail.Column_Sequence__c = 1;
        fcLookupDeatail.Column_Value__c = 'test';
        fcLookupDeatail.FC_Lookup_Manager__c = fcManager.id;
        fcLookupDeatail.Row_Number__c = 0;
        insert fcLookupDeatail;
              
        
        //insert test parameters for FICReportsConfiguration
        Parameter__c param = new Parameter__c();
        param.Name = 'Calendar."Period Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Period Name';
        param.Default_Value__c = 'test';
        param.Required__c = true;
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        param.Display__c = true;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');
        
        param = new Parameter__c();
        param.Name = 'Participant."Participant Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Participant Name';
        param.Default_Value__c = 'test';
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        //param.Required__c = true;
        param.Display__c = true;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');

        //create test ecords for dashboard        
        fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Dashboard';
        insert fic;
        
        param = new Parameter__c();
        param.Name = 'Calendar."Period Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Period Name';
        param.Default_Value__c = 'test';
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        param.Display__c = true;
        insert param;
        // end of dashboard records
        
        // inster test Oracle Web services
        OracleWebservices__c ow = new OracleWebservices__c();
        ow.Name='OracleWebservice';
        ow.User_Name__c = 'Srini.parimi@cloudspm.com';
        ow.Password__c ='Spm123';
        ow.ServiceSoapEndpoint__c='https://bi-aufsn4x0dha.oracleoutsourcing.com/analytics-ws/saw.dll?SoapImpl=';
        insert ow;
        system.assert(ow.id != null ,'Oracle Web services is Not inserted');
            
        // calling constructor
        ApexPages.CurrentPage().getParameters().put('runReport','true');
        ApexPages.CurrentPage().getParameters().put('reportParam','test1:value1!!test2:value2');
        Dashboard_Layout__c layout = new Dashboard_Layout__c();
        insert layout;
        
        fusion__Dashboard_User_Map__c dashboardUser = new fusion__Dashboard_User_Map__c();
        dashboardUser.User__c = UserInfo.getUserId();
        dashboardUser.Dashboard_Layout__c = layout.Id;
        insert dashboardUser;
        
        Dashboard_Row__c row = new Dashboard_Row__c();
        row.Columns__c = 1;
        row.Dashboard_Layout__c = layout.Id;
        row.Row_Number__c = 1;
        insert row;
        
        FICReportsConfiguration__c reportConfig = new FICReportsConfiguration__c();
        reportConfig.Y2_Axis__c = 0;
        reportConfig.Y2_Label__c = 'Target Incentive';
        reportConfig.Chart_Type__c = 'Pie';
        reportConfig.Dashboard_Display_Sequence__c = null;
        reportConfig.Display_Name__c = 'Sample BI report';
        reportConfig.Display_Report__c = true;
        reportConfig.Group__c = 'Reports';
        reportConfig.Is_Pivot__c = false;
        reportConfig.Page_Orientation__c = '';
        reportConfig.Report_Columns__c = 'Year,Plan,Plan Component,Currency,Earnings,Target Incentive';
        reportConfig.Report_Name__c = 'SPM_GET_PARTICIPANT';
        reportConfig.Report_Path__c = '/shared/Incentive Compensation/Transactional Analysis Samples/Report Components';
        reportConfig.Report_Type__c = 'BI Report';
        reportConfig.Show_Chart__c = true;
        reportConfig.ShowOnDashboard__c = true;
        reportConfig.Show_Table__c = false;
        reportConfig.Spedometer_Band__c = '';
        reportConfig.Spedometer_Band_Color__c= '';
        reportConfig.XAxis__c = 2;
        reportConfig.XAxisLabel__c = 'Plan Component';
        reportConfig.YAxis__c = 2;
        reportConfig.YAxisLabel__c = 'Earnings';
        insert reportConfig;
        
         //create test Column Configuration
        ColumnConfiguration__c cc1 = new ColumnConfiguration__c();
        cc1.Column_Format__c = 'Number';
        cc1.Column_Name__c = 'test col';
        cc1.Column_Sequence__c = 0;
        cc1.Column_Width__c = '200';
        cc1.Display__c = true;
        cc1.Display_Sequence__c = 0;
        cc1.FIC_Reports_Configuration__c = reportConfig.id;
        cc1.Pecision__c = 2;
        insert cc1;
        
        cc1 = new ColumnConfiguration__c();
        cc1.Column_Format__c = 'Character';
        cc1.Column_Name__c = 'test col2';
        cc1.Column_Sequence__c = 1;
        cc1.Column_Width__c = '200';
        cc1.Display__c = true;
        cc1.Display_Sequence__c = 1;
        cc1.FIC_Reports_Configuration__c = reportConfig.id;
        cc1.Pecision__c = 2;
        insert cc1;
        
        Dashboard_Report__c dashboardReport = new Dashboard_Report__c();
        dashboardReport.Dashboard_Row__c = row.Id;
        dashboardReport.FIC_Reports_Configuration__c = reportConfig.id;
        dashboardReport.Sequence__c = 1;
        insert dashboardReport;
        
        
        compensationReportController crc = new compensationReportController();
        crc.runReport();
        if(crc.ccList != null && crc.ccList.size()>0){            
            crc.ccList[0].chartData.getChartValues();
            crc.reportIndex = 0;
            crc.ccList[0].selectedSize = 20;
            crc.changeMultiplePageSize();            
            crc.nextPageData();
            crc.previousPageData();
            crc.ccList[0].chartData.getHighChartValues();
            
        }
        //putting test value on current page parameter
        ApexPages.CurrentPage().getParameters().put('name','Attainment Comparison Table Report');
        ApexPages.CurrentPage().getParameters().put('displayName','Attainment_Comparison_Table_Report');
        
        crc = new compensationReportController();
        
        system.assert(crc.reportName != null,'Report Name Not Found');
        system.assert(crc.groupList.size()>0,'FIC Reports Not Found');
        system.assert(crc.groupMap.size()>0,'FIC Reports Not Found');
        system.assert(crc.ficColumns.size()>0,'FIC Reports Not Found');
        system.assert(crc.paramModel.size()>0,'Parameters Not Found');        
        
        for(compensationReportController.ParametersModel pm:crc.paramModel){
            pm.param.Default_Value__c = 'test';
        }
        crc.preparePivotData();
        crc.invokeReport();
        
        
        //system.assert(crc.csvstring != '' || crc.csvstring != null,'CSV Not created' );
        crc.fillParameters();
        //system.assert(crc.rowsxCompleteData.size()>0,'No records found');
        
        crc.executeReport();
        //system.assert(crc.csvstring != '' || crc.csvstring != null,'CSV Not created' );
        //system.assert(crc.rowsxCompleteData.size()>0,'No records found');
        //system.assert(crc.totalPage != null,'totalPages is not defined');
        //system.assert(crc.rowsx.size()>0,'No records found in current page');
        crc.runBIReport();
        crc.nextPage();
        system.assert(crc.rowsx.size()>0,'No records found in current page');
        crc.previousPage();
        system.assert(crc.rowsx.size()>0,'No records found in current page');
        
        crc.selectedSize = 50;        
        crc.changePageSize(); 
        crc.getParticipantList();      
        crc.getHighChartData(); 
        crc.getDataJsonStr();
        //crc.getHighChartValues();
        compensationReportController.Row row1 = new compensationReportController.Row();
        compensationReportController.ChartData obj = new compensationReportController.ChartData();
        obj.rowList = new List<compensationReportController.Row>{row1}; 
        obj.getHighChartValues();
        
        obj.getDataJsonStr();
        
        
        compensationReportController.headerValueModel header = new compensationReportController.headerValueModel();
        header.setInnerHeaderValues(new List<string>{'test','test'});
        header.getInnerHeaderValues();
    }
    Private static void createData(){
        // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        fic.XAxis__c = 0;
        fic.YAxis__c = 1;
        fic.Y2_Axis__c = 2;
        fic.XAxisLabel__c = 'test1';
        fic.YAxisLabel__c = 'test2';
        fic.Y2_Label__c = 'test3';
        fic.ShowOnDashboard__c = true;
        fic.Page_Orientation__c = 'landscape';
        fic.Display_Name__c = 'Attainment Comparison Table Report';
        fic.Report_Path__c = '/shared/Incentive Compensation/Transactional Analysis Samples/Report Components';
        fic.Report_Columns__c = 'Participant,Attainment,ITD Target,Period Year,';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
                
        
        //create test Column Configuration
        ColumnConfiguration__c cc = new ColumnConfiguration__c();
        cc.Column_Format__c = 'Number';
        cc.Column_Name__c = 'test col';
        cc.Column_Sequence__c = 0;
        cc.Column_Width__c = '200';
        cc.Display__c = true;
        cc.Display_Sequence__c = 0;
        cc.FIC_Reports_Configuration__c = fic.id;
        cc.Pecision__c = 2;
        insert cc;
        
        cc = new ColumnConfiguration__c();
        cc.Column_Format__c = 'Character';
        cc.Column_Name__c = 'test col2';
        cc.Column_Sequence__c = 1;
        cc.Column_Width__c = '200';
        cc.Display__c = true;
        cc.Display_Sequence__c = 1;
        cc.FIC_Reports_Configuration__c = fic.id;
        cc.Pecision__c = 2;
        insert cc;
        
        //create test FCLookupManager
        FC_Lookup_Manager__c fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant';
        fcManager.Report_Name__c = 'SPM_GET_PARTICIPANT';
        fcManager.Report_Path__c = '/Custom/SFDC/Reports';
        insert fcManager;
        
        FC_Lookup_Detail__c fcLookupDeatail = new FC_Lookup_Detail__c();
        fcLookupDeatail.Column_Name__c = 'EMAIL_ADDRESS';
        fcLookupDeatail.Column_Sequence__c = 0;
        fcLookupDeatail.Column_Value__c = UserInfo.getUserEmail();
        fcLookupDeatail.FC_Lookup_Manager__c = fcManager.id;
        fcLookupDeatail.Row_Number__c = 0;
        insert fcLookupDeatail;
        
        fcLookupDeatail = new FC_Lookup_Detail__c();
        fcLookupDeatail.Column_Name__c = 'PARTICIPANT_NAME';
        fcLookupDeatail.Column_Sequence__c = 1;
        fcLookupDeatail.Column_Value__c = 'test';
        fcLookupDeatail.FC_Lookup_Manager__c = fcManager.id;
        fcLookupDeatail.Row_Number__c = 0;
        insert fcLookupDeatail;
              
        
        //insert test parameters for FICReportsConfiguration
        Parameter__c param = new Parameter__c();
        param.Name = 'Calendar."Period Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Period Name';
        param.Default_Value__c = 'test';
        param.Required__c = true;
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        param.Display__c = true;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');
        
        param = new Parameter__c();
        param.Name = 'Participant."Participant Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Participant Name';
        param.Default_Value__c = 'test';
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        //param.Required__c = true;
        param.Display__c = true;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');

        //create test ecords for dashboard        
        fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Dashboard';
        insert fic;
        
        param = new Parameter__c();
        param.Name = 'Calendar."Period Name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Label__c = 'Period Name';
        param.Default_Value__c = 'test';
        param.Lookup_Name__c = fcManager.id;
        param.Lookup_Column__c = 'test';
        param.Display__c = true;
        insert param;
        // end of dashboard records
        
        // inster test Oracle Web services
        OracleWebservices__c ow = new OracleWebservices__c();
        ow.Name='OracleWebservice';
        ow.User_Name__c = 'Srini.parimi@cloudspm.com';
        ow.Password__c ='Spm123';
        ow.ServiceSoapEndpoint__c='https://bi-aufsn4x0dha.oracleoutsourcing.com/analytics-ws/saw.dll?SoapImpl=';
        insert ow;
        system.assert(ow.id != null ,'Oracle Web services is Not inserted');
    }
}