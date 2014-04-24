/**
    Name : TestTransactionController
    Author : 
    Date : December 17, 2013
    Description : This controller is designed to test TransactionController.
*/

@isTest
public class TestTransactionController{
    
    @isTest
    public static void testTransaction(){
        createData();
        // calling constructor
        ApexPages.CurrentPage().getParameters().put('runReport','true');
        ApexPages.CurrentPage().getParameters().put('reportParam','test1:value1!!test2:value2');
        TransactionController tc = new TransactionController();
        tc.runReport();
        if(tc.ccList != null && tc.ccList.size()>0){            
            tc.ccList[0].chartData.getChartValues();
            tc.reportIndex = 0;
            tc.ccList[0].selectedSize = 20;
            tc.changeMultiplePageSize();            
            tc.nextPageData();
            tc.previousPageData();
            
        }
        //putting test value on current page parameter
        ApexPages.CurrentPage().getParameters().put('name','Attainment Comparison Table Report');
        ApexPages.CurrentPage().getParameters().put('displayName','Attainment_Comparison_Table_Report');
        
        tc = new TransactionController();
        
        system.assert(tc.reportName != null,'Report Name Not Found');
        system.assert(tc.groupList.size()>0,'FIC Reports Not Found');
        system.assert(tc.groupMap.size()>0,'FIC Reports Not Found');
        system.assert(tc.ficColumns.size()>0,'FIC Reports Not Found');
        system.assert(tc.paramModel.size()>0,'Parameters Not Found');        
        
        for(TransactionController.ParametersModel pm:tc.paramModel){
            pm.param.Default_Value__c = 'test';
        }
        
        tc.filterValues();
        system.assert(tc.csvstring != '' || tc.csvstring != null,'CSV Not created' );
        tc.fillParameters();
        system.assert(tc.rowsxCompleteData.size()>0,'No records found');
        
        tc.executeReport();
        system.assert(tc.csvstring != '' || tc.csvstring != null,'CSV Not created' );
        system.assert(tc.rowsxCompleteData.size()>0,'No records found');
        system.assert(tc.totalPage != null,'totalPages is not defined');
        system.assert(tc.rowsx.size()>0,'No records found in current page');
        
        tc.nextPage();
        system.assert(tc.rowsx.size()>0,'No records found in current page');
        tc.previousPage();
        system.assert(tc.rowsx.size()>0,'No records found in current page');
        
        tc.selectedSize = 50;
        tc.changePageSize();        
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