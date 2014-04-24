/**
    Name : TransactionController
    Author : CloudSPM
    Date : November 28, 2013
    Description : This controller is fetching transaction records from oracle fusion service.

*/
public with sharing class TransactionController{
     public String csvstring{get;set;}     
     public String linkId{get;set;}
     public string sessionid{get; set;}
     public string reportOutput{get; set;}
     public List<Row> rowsx{get; set;}
     public List<Row> rowsxChartData{get;set;}
     public List<Row> rowsxCompleteData{get; set;}
     public List<CombinedClass> ccList{get;set;}
     public Integer reportIndex {get;set;}  
     public Boolean multipleReportsFlag{get;set;}
     public Integer range{get;set;}
     public Boolean flag{get;set;}
     public Boolean flag2{get;set;}
     public Integer totalPage{get;set;}
     public Integer currentPage{get;set;}
     public List<SelectOption> sizeList{get;set;}     
     public Integer selectedSize{get;set;}
     public List<SelectOption> orientaionList{get;set;}
     public String selectedOrientation{get;set;}
     public String dataStr{get;set;}
     public String YAxisLabels{get;set;}
     public String path{get;set;}
     public String reportName{get;set;}
     public String displayName{get;set;}
     public String Page_Orientation{get;set;}
     public String parameterDisplayName{get;set;}
     public String deafult{get;set;}
     public List<SelectOption> participantList{get;set;}
     public List<SelectOption> periodYearList{get;set;}
     public List<SelectOption> periodNameList{get;set;}
     public String participantNameOther{get;set;}
     public String periodYearOther{get;set;}
     public String periodNameOther{get;set;}     
     public String parametersString{get;set;}
     public String defaultName{get;set;}
     public Date curDate{get;set;}
     Private Boolean participantNameFlag{get;set;}
     public Map<String,String> columnFormatMap{get;set;}
     
     public Map<String,String> paramDefaultMap{get;set;}
     public List<headerValueModel> headerValues{get;set;}
     public Set<String> headerSet{get;set;}
     public Map<String,String> displaySequenceMap{get;set;}
     public Map<String,String> displayAlignmentMap{get;set;}     
     public List<String> displaySequence{get;set;}
     public List<FICReportsConfiguration__c> ficColumns{get;set;}   
     public List<ParametersModel> paramModel{get;set;}
     
     public Map<String,List<FICReportsConfiguration__c>> groupMap{get;set;}
     public List<String> groupList{get;set;}
     public List<Oracle_Connection__c> oracleConnectionList{get;set;}
     private map<String,decimal>precisionMap;
     public TransactionController(){
         columnFormatMap = new Map<String,String>();
         ccList = new List<CombinedClass>(); 
         rowsx = new List<Row>();
         rowsxCompleteData = new List<Row>();
         rowsxChartData = new List<Row>();
         headerValues = new List<headerValueModel>();
         headerSet = new Set<String>();
         paramDefaultMap = new Map<String,String>();
         displaySequenceMap = new Map<String,String>();
         precisionMap=new map<String,decimal>();
         displayAlignmentMap = new Map<String,String>();
         displaySequence = new List<String>();         
         ficColumns = new List<FICReportsConfiguration__c>();         
         sizeList = new List<SelectOption>();         
         paramModel = new List<ParametersModel>();
         groupList = new List<String>();
         orientaionList = new List<SelectOption>();
         groupMap = new Map<String,List<FICReportsConfiguration__c>>();   
         deafult = '';
         YAxisLabels = '';
         dataStr = '';
         participantNameOther = '';
         periodYearOther = '';
         periodNameOther = '';
         flag = true;
         flag2 = false;
         participantNameFlag = false;
         //records limit per page
         range = 10;
         //page orientation in pdf
         Page_Orientation = 'Portrait';
         
         // fill orientation list
         orientaionList.add(new SelectOption('portrait','Portrait'));
         orientaionList.add(new SelectOption('landscape','Landscape'));
                
         //fill page size list
         sizeList.add(new SelectOption('10','10'));
         sizeList.add(new SelectOption('25','25'));
         sizeList.add(new SelectOption('50','50'));
         sizeList.add(new SelectOption('100','100'));
         sizeList.add(new SelectOption('150','150'));
         sizeList.add(new SelectOption('200','200'));
         
         curDate = date.today();
         defaultName = '';        
         // getting current login user email address
         List<FC_Lookup_Detail__c> fcDetailtemp = [select id,Row_Number__c from FC_Lookup_Detail__c where Column_Value__c =: UserInfo.getUserEmail() and Column_Name__c = 'EMAIL_ADDRESS' and FC_Lookup_Manager__r.Lookup_Name__c = 'Participant'];
         if(fcDetailtemp != null && fcDetailtemp.size()>0){
             List<FC_Lookup_Detail__c> fcDetailtemp2 = [select id,Column_Value__c from FC_Lookup_Detail__c where Column_Name__c = 'PARTICIPANT_NAME' and FC_Lookup_Manager__r.Lookup_Name__c = 'Participant' and Row_Number__c =: fcDetailtemp[0].Row_Number__c];
             if(fcDetailtemp2 != null && fcDetailtemp2.size()>0){
                 defaultName = fcDetailtemp2[0].Column_Value__c;
             }
         }
         
         // getting Query string parameters                
         path = ApexPages.CurrentPage().getParameters().get('path');
         reportName = ApexPages.CurrentPage().getParameters().get('name');
         displayName = ApexPages.CurrentPage().getParameters().get('displayName');
         
         if(displayName != null){
             parameterDisplayName = displayName.replaceAll(' ','_');
         }
         if(reportName == null){
            reportName = '';
         }
         
         // getting connection user name and password
         oracleConnectionList = [select Username__c,Password__c,Host__c,Service__c from Oracle_Connection__c where Service__c='Fusion Transactional Business Intelligence' and Status__c ='Active'];
         
         // managing groups in side bar      
         for(FICReportsConfiguration__c fic:[select id,Group__c,Display_Name__c,Report_Name__c,Display_Report__c from FICReportsConfiguration__c where Display_Report__c = true order by Display_Name__c ASC]){
             List<FICReportsConfiguration__c> nameList = groupMap.get(fic.Group__c);
             if(nameList == null){
                 nameList = new List<FICReportsConfiguration__c>();
             }
             nameList.add(fic);
             groupMap.put(fic.Group__c,nameList);
         }
         groupList.addAll(groupMap.KeySet());
         
         if(reportName != ''){
             // getting header values
             headerValues();  
             
             // setting dashboard display false
             multipleReportsFlag = false;
             
             // getting report
             List<FICReportsConfiguration__c> ficReport = [select id from FICReportsConfiguration__c where Report_Name__c=:reportName ];
             if(ficReport != null && ficReport.size()>0){
                 linkId = ficReport[0].id;
             }             
         }else{
             // setting dashboard display true
             multipleReportsFlag = true;
             dashboardParameters();
             if(ApexPages.CurrentPage().getParameters().get('runReport') != null)
                multipleReports();           
         }
                
     }
     // run dashboard reports
     public void multipleReports(){
        // getting dashboard reports
        List<FICReportsConfiguration__c> ficReport = [select id,Report_Path__c,Display_Name__c,Y2_Axis__c,Y2_Label__c,Page_Orientation__c,(select id,Column_Name__c,Column_Format__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,FIC_Reports_Configuration__c,Pecision__c from ColumnConfigurations__r where Display__c = true ORDER BY Display_Sequence__c ASC),Show_Chart__c,Show_Table__c,Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c from FICReportsConfiguration__c where ShowOnDashboard__c = true and Report_Name__c != 'Dashboard' order by Dashboard_Display_Sequence__c ASC limit 4];
        
        if(ficReport != null && ficReport.size()>0){
            for(FICReportsConfiguration__c fic:ficReport){                
                OracleBiWebservicesV7.SAWSessionServiceSoap service = new OracleBiWebservicesV7.SAWSessionServiceSoap();
                if (!Test.isRunningTest())
                {
                    // logon to oracle webservice
                    if(oracleConnectionList.size()>0){
                        sessionid = service.logon(oracleConnectionList[0].Username__c, oracleConnectionList[0].Password__c);            
                    }                    
                }
                OracleBiWebservicesV7Xml.XmlViewServiceSoap xmlService = new OracleBiWebservicesV7Xml.XmlViewServiceSoap();
                OracleBiWebservicesV7Xml.ReportRef report = new OracleBiWebservicesV7Xml.ReportRef();                
                report.reportPath = fic.Report_Path__c+'/'+fic.Report_Name__c;
                OracleBiWebservicesV7Xml.XMLQueryExecutionOptions executeOption = new OracleBiWebservicesV7Xml.XMLQueryExecutionOptions();
                OracleBiWebservicesV7Xml.ReportParams reportParams = new OracleBiWebservicesV7Xml.ReportParams();
                reportParams.filterExpressions = new List<String>();
                
                // filling report parameters
                String filterExpression1 = '';
                if(ApexPages.CurrentPage().getParameters().get('reportParam') != null){
                    String reportParameters = ApexPages.CurrentPage().getParameters().get('reportParam');
                    parametersString = reportParameters;
                    for(String params:reportParameters.split('!!')){
                        List<String> paramList = params.split(':');
                        if(paramList != null && paramList.size()>1){
                            filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="equal" '+
                            ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
                            ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
                            ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                            ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
                            '<sawx:expr xsi:type="sawx:sqlExpression">'+paramList[0]+'</sawx:expr>' +
                            '<sawx:expr xsi:type="xsd:string">'+paramList[1]+'</sawx:expr></sawx:expr>';
                            
                            reportParams.filterExpressions.add(filterExpression1);  
                            }
                        }
                }    
                try{            
                    if (!Test.isRunningTest())
                    {
                        // web service query execution
                        OracleBiWebservicesV7Xml.QueryResults result = xmlService.executeXMLQuery(report, null, executeOption, reportParams, sessionid);
                        reportOutput=result.rowset;           
                                           
                        
                    }else{
                        // filling deafult value
                        reportOutput = '<rowset xmlns="urn:schemas-microsoft-com:xml-analysis:rowset">';
                        for(Integer i=0;i<=50;i++){
                            reportOutput += '<Row><Column0>Test Manager1</Column0><Column1>12654</Column1><Column2>1</Column2><Column3>12</Column3></Row>';
                        }
                        reportOutput += '</rowset>';    
                    }                        
                    
                    // creating object for dashboard Managing model
                    CombinedClass comChart = new CombinedClass();                    
                    //fill index number of report
                    comChart.index = ccList.size();
                    //fill index report name
                    comChart.reportName = fic.Report_Name__c;
                    //fill report display name
                    comChart.displayName = fic.Display_Name__c;
                    //fill report parameter display name for export options
                    comChart.parameterDisplayName = fic.Display_Name__c.replaceAll(' ','_');
                    
                    // memory allocation
                    headerSet = new Set<String>();
                    displaySequence = new List<String>();
                    displaySequenceMap = new Map<String,String>();
                    displayAlignmentMap = new Map<String,String>();
                    columnFormatMap = new Map<String,String>();
                    //set page orientation
                    if(fic.Page_Orientation__c != null){
                        comChart.Page_Orientation = fic.Page_Orientation__c;
                    }
                    
                    // filling header column values and display sequence
                    if(fic.ColumnConfigurations__r != null && fic.ColumnConfigurations__r.size()>0){
                        for(ColumnConfiguration__c cc:fic.ColumnConfigurations__r){
                            headerSet.add(String.ValueOf(cc.Column_Sequence__c));
                            displaySequence.add(String.ValueOf(cc.Display_Sequence__c));
                            displaySequenceMap.put(String.ValueOf(cc.Display_Sequence__c),String.ValueOf(cc.Column_Sequence__c));
                            if(cc.Column_Format__c == 'Number' || cc.Column_Format__c == 'Percentage'){
                                precisionMap.put(String.ValueOf(cc.Column_Sequence__c),cc.Pecision__c);
                                displayAlignmentMap.put(String.ValueOf(cc.Column_Sequence__c),'right');
                            }else{
                                displayAlignmentMap.put(String.ValueOf(cc.Column_Sequence__c),'left');
                            }
                            columnFormatMap.put(string.ValueOf(cc.Column_Sequence__c),cc.Column_Format__c);
                        }
                    }                                     
                    
                    //getting parsed values for report table and chart                   
                    List<List<Row>> listOfRow = parse(reportOutput); 
                    
                    if(listOfRow != null && listOfRow.size()>0){
                        // set report table values
                        if(fic.Show_Table__c){
                            comChart.rowCompleteList = listOfRow[0];          
                        }                       
                        
                        //set chart values
                        if(listOfRow.size()>1 && fic.XAxis__c != null && (fic.YAxis__c != null || fic.Y2_Axis__c != null) && fic.Show_Chart__c == true){  
                            ChartData chatob = new ChartData(listOfRow[1],Integer.ValueOf(fic.XAxis__c),Integer.ValueOf(fic.YAxis__c),fic.XAxisLabel__c,fic.YAxisLabel__c,Integer.ValueOf(fic.Y2_Axis__c),fic.Y2_Label__c );
                            comChart.chartData =  chatob ;  
                            comChart.clsName = 'chart';
                        }
                    }else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'<b>Report Generation Status:</b>  The '+fic.Display_Name__c+' returned no results. ');
                        ApexPages.addMessage(myMsg);
                        continue;                       
                    }
                    
                    //add dashboard records
                    ccList.add(comChart);                    
                    //set dashboard report table page records
                    setMultiplePageRecords(comChart.index); 
                    //set dashboard report table headers
                    multipleReportsHeader(comChart.index);
                    
                }catch(Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            }         
        }
     }
     public void fillParameters(){
         parametersString = '';
         for(ParametersModel pm:paramModel){
             Boolean addFilter = false;
             String val = '';
             
             if(pm.param.Default_Value__c != null && pm.param.Default_Value__c.trim().length()>0){
                 if(pm.param.Default_Value__c != 'other'){
                     val = pm.param.Default_Value__c;
                     addFilter = true;
                 }else if(pm.param.Default_Value__c == 'other' && pm.otherValue != null && pm.otherValue.trim().length()>0){
                     val = pm.otherValue ;
                     addFilter = true;
                 }
             }             
             //system.debug('##$##$'+val);
             if(addFilter){
                 parametersString += pm.param.Name+':'+val+'!!';                 
             }
         }
         if(!participantNameFlag && defaultName != ''){
             parametersString += 'Participant."Participant Name":'+defaultName+'!!';     
         }          
     }
     // run dashboard report after giving parameters
     public PageReference runReport(){   
         parametersString = '';
         String url = '/apex/ShowTransactions?runReport=true';   
         String errmsg = '<ul>';        
         Boolean errFlag = false;
         for(ParametersModel pm:paramModel){
             Boolean addFilter = false;
             String val = '';
             if(pm.param.Required__c == true){
                 if(pm.param.Default_Value__c != null && pm.param.Default_Value__c.trim().length()>0){
                     if(pm.param.Default_Value__c != 'other'){
                         val = pm.param.Default_Value__c;
                         addFilter = true;
                     }else if(pm.param.Default_Value__c == 'other' && pm.otherValue != null && pm.otherValue.trim().length()>0){
                         val = pm.otherValue ;
                         addFilter = true;
                     }else{
                         errFlag = true;
                         errmsg = +'<li><Strong>'+pm.param.Label__c+'</strong> is Required</li>';
                     }
                 }else{
                     errFlag = true;
                     errmsg = +'<li><Strong>'+pm.param.Label__c+'</strong> is Required</li>';
                 }
             }else{                
                 if(pm.param.Default_Value__c != null && pm.param.Default_Value__c.trim().length()>0 && pm.param.Default_Value__c != 'other'){
                     val = pm.param.Default_Value__c;
                     addFilter = true;
                 }else if(pm.param.Default_Value__c == 'other' && pm.otherValue != null && pm.otherValue.trim().length()>0){
                     val = pm.otherValue;
                     addFilter = true;
                 }    
             }
             //system.debug('##$##$'+val);
             if(addFilter){
                 parametersString += pm.param.Name+':'+val+'!!';                 
             }
             
         }
         if(!participantNameFlag && defaultName != ''){
             parametersString += 'Participant."Participant Name":'+defaultName+'!!';     
         } 
         if(errFlag == true){
             errmsg += '</ul>';
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errmsg );
             ApexPages.addMessage(myMsg); 
         }else{
             url += '&reportParam='+parametersString;
             PageReference pg = new PageReference(url);
             return pg.setRedirect(true);  
         }         
         return null; 
         
     }     
     // set dashboard table page records
     public void setMultiplePageRecords(integer index){
         if(index != null && ccList.size()>index){             
             if(ccList[index].rowCompleteList != null &&  ccList[index].rowCompleteList.size()>0){
                 ccList[index].totalPage = (Integer)Math.ceil((Double)ccList[index].rowCompleteList.size() / (Double)ccList[index].range);
               
                 // load first page records
                 ccList[index].flag1 = true;
                 //current page number
                 ccList[index].currentPage = 1;
                        
                 ccList[index].rowList = new List<Row>();        
                 Integer start = (ccList[index].currentPage-1)*ccList[index].range;
                 for(Integer i=start; i<start+ccList[index].range && i<ccList[index].rowCompleteList.size(); i++){
                      ccList[index].rowList.add(ccList[index].rowCompleteList[i]);
                 }
                 if(ccList[index].rowCompleteList.size() <= ccList[index].range){                
                    ccList[index].flag2 = true;
                }
            }
         }
     }
    // change dashboard records per page
    public void changeMultiplePageSize(){
        if(reportIndex != null && ccList.size()>reportIndex ){
            if(ccList[reportIndex].selectedSize != null){
                ccList[reportIndex].range = ccList[reportIndex].selectedSize;
                ccList[reportIndex].flag1 = true;
                ccList[reportIndex].flag2 = false;
                setMultiplePageRecords(reportIndex );                
            }        
        }
    }
    // show next page records For dashboard Reports
    public void nextPageData(){
        if(reportIndex != null && ccList.size()>reportIndex){
            ccList[reportIndex].flag1 = false;
            //system.debug('!!!!@@@@'+reportIndex);
            if((ccList[reportIndex].currentPage+1) == ccList[reportIndex].totalPage){
                //flag work
                ccList[reportIndex].flag2 = true;            
            }
            ccList[reportIndex].rowList = new List<Row>();
            Integer start = ccList[reportIndex].currentPage*ccList[reportIndex].range;
            for(Integer i=start; i<start+ccList[reportIndex].range && i<ccList[reportIndex].rowCompleteList.size(); i++){
                ccList[reportIndex].rowList.add(ccList[reportIndex].rowCompleteList[i]);
            }
            
            ccList[reportIndex].currentPage++;
        }         
    }
    
    //show previous page records For Multiple Reports
    public void previousPageData(){
        if(reportIndex != null && ccList.size()>reportIndex){
            ccList[reportIndex].flag2 = false;
            if((ccList[reportIndex].currentPage-1) == 1){
                //flag work
                ccList[reportIndex].flag1 = true;
                
            }
            ccList[reportIndex].rowList = new List<Row>();
            Integer start = (ccList[reportIndex].currentPage-2)*ccList[reportIndex].range;
            for(Integer i=start; i<start+ccList[reportIndex].range && i<ccList[reportIndex].rowCompleteList.size(); i++){
                ccList[reportIndex].rowList.add(ccList[reportIndex].rowCompleteList[i]);
            }             
            ccList[reportIndex].currentPage--;
        }
    }
    //getting Dashboard Parameters
    public void dashboardParameters(){        
        participantNameFlag = false;
        if(ApexPages.CurrentPage().getParameters().get('reportParam') != null){
            String reportParameters = ApexPages.CurrentPage().getParameters().get('reportParam');
            for(String params:reportParameters.split('!!')){
                List<String> paramList = params.split(':');
                if(paramList != null && paramList.size()>1){
                    paramDefaultMap.put(paramList[0],paramList[1]);                      
                }
            }
        }    
        List<FICReportsConfiguration__c> ficList = [select id,(select id,Name,Lookup_Name__c,Default_Value__c,Lookup_Column__c,Required__c,Label__c from  Parameters__r where display__c = true order by Sequence_Number__c) from FICReportsConfiguration__c where Report_Name__c =: 'Dashboard'];
       
        //filling parameters model
        if(ficList != null && ficList.size()>0){        
            if(ficList[0].Parameters__r != null && ficList[0].Parameters__r.size()>0){                
                Set<String> paramIds = new Set<String>();
                Set<String> ColumnValueSet = new Set<String>(); 
                Map<String,List<SelectOption>> parameterMap = new Map<String,List<SelectOption>>();
                
                //fetching id of FC Lookup Manager
                for(Parameter__c param:ficList[0].Parameters__r){                    
                    paramIds.add(param.Lookup_Name__c);
                    ColumnValueSet.add(param.Lookup_Column__c);                    
                }
                
                //fetching option list for parameter values
                for(FC_Lookup_Manager__c manager:[select id,(select id,Column_Value__c,Column_Name__c from FC_Lookup_Details__r where Column_Name__c in:ColumnValueSet order by Column_Value__c ASC) from FC_Lookup_Manager__c where id in:paramIds]){
                    List<SelectOption> optList = new List<SelectOption>();   
                    String columnaName = '';
                    for(FC_Lookup_Detail__c fc:manager.FC_Lookup_Details__r){
                        columnaName = fc.Column_Name__c.toLowerCase();                        
                        List<SelectOption> optTempList = parameterMap.get(manager.id+columnaName);
                        if(optTempList == null){
                            optTempList = new List<SelectOption>();  
                            optTempList.add(new SelectOption('','--Select Value--'));               
                        }
                        Set<String> tempSet = new Set<String>();
                        for(SelectOption str:optTempList){
                            tempSet.add(str.getValue());
                        }      
                        System.debug('@#@#@#@#@#@#'+tempSet);                  
                        if(!tempSet.contains(fc.Column_Value__c)){
                            optTempList.add(new SelectOption(fc.Column_Value__c,fc.Column_Value__c));
                            parameterMap.put(manager.id+columnaName,optTempList);
                        }                        
                    }
                }      
                
                //filling parameters picklist       
                for(Parameter__c param:ficList[0].Parameters__r){ 
                    ParametersModel pm = new ParametersModel();
                    pm.param = param;
                    
                    if(param.Name.toLowerCase() == 'calendar."period name"'){
                        pm.param.Default_Value__c = '';
                    }else if(param.Name.toLowerCase() == 'calendar."period year"'){
                        pm.param.Default_Value__c = String.ValueOf(curDate.year());
                    }else if(param.Name.toLowerCase() == 'participant."participant name"' ){
                        participantNameFlag = true;
                        pm.param.Default_Value__c = defaultName;
                    }
                    
                    if(paramDefaultMap.get(param.Name) != null){
                        pm.param.Default_Value__c = paramdefaultMap.get(param.Name);
                    }
                    if(param.Required__c){
                        pm.requiredInput = 'requiredInput '; 
                        pm.requiredBlock = 'requiredBlock ';
                        
                    }
                    if(param.Lookup_Column__c != null && parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase()) != null){
                        pm.paramList = parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase());
                    }                    
                    pm.paramList.add(new SelectOption('other','Other'));              
                    paramModel.add(pm);
                }                
            }  
        }       
    }
    // get header values for Dashboard reports
    public void multipleReportsHeader(Integer index){
        if(index != null && ccList.size()>index){            
            ficColumns = [select id,Y2_Axis__c,Y2_Label__c,(select id,Column_Name__c,Column_Format__c,Column_Sequence__c,Display__c,Display_Sequence__c,Column_Width__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true ORDER BY Display_Sequence__c ASC),(select id,Name,Label__c from  Parameters__r),Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Report_Path__c,Report_Columns__c from FICReportsConfiguration__c where Report_Name__c =: ccList[index].reportName limit 1];
            if(ficColumns.size()>0){   
                // set chart y axis data and lable
                Boolean axisFlag = false;                
                if(ficColumns[0].YAxis__c != null){
                    ccList[index].YAxisLabels = ficColumns[0].YAxisLabel__c;
                    ccList[index].dataStr = 'data1';
                    axisFlag = true;
                }
                if(ficColumns[0].Y2_Axis__c != null){          
                   if(axisFlag){
                       ccList[index].dataStr += ',';
                       ccList[index].YAxisLabels += ',';
                   }
                   ccList[index].dataStr += 'data2';
                   ccList[index].YAxisLabels += ficColumns[0].Y2_Label__c;
                  
                }
                
                //filling header values model for dashboard report
                if(ficColumns[0].ColumnConfigurations__r != null && ficColumns[0].ColumnConfigurations__r.size()>0){
                    for(ColumnConfiguration__c cc:ficColumns[0].ColumnConfigurations__r){
                        headerValueModel hvm = new headerValueModel();
                        
                        //filling column width
                        if(cc.Column_Width__c != null){
                            hvm.width = cc.Column_Width__c+'px';
                        }
                        
                        //filling header values for dashboard report
                        String str = '';
                        if(cc.Column_Name__c.contains(' ')){
                            for(String s:cc.Column_Name__c.split(' ')){
                                str += s+'<br/>';
                            }
                            hvm.headerValue = str;
                        }else{
                            hvm.headerValue = cc.Column_Name__c;
                        }
                        
                        //setting column alignment
                        if(cc.Column_Format__c == 'Number' || cc.Column_Format__c == 'Percentage'){
                            hvm.textAlignment = 'right';    
                        }
                        
                        ccList[index].headerValues.add(hvm);
                    }
                }
                
            }
        }
    }    
    // make report csv
    private void makecsv(){
         csvstring = '';         
         if(rowsxCompleteData != null && rowsxCompleteData.size()>0){
             for(Row r : rowsxCompleteData){
                 for(String str : r.columns){
                      csvstring += str + ',' ;
                 }
                 csvstring = csvstring.substring(0,csvstring.length()-1);
                 csvstring += '\n';
             }
             csvstring = csvstring.substring(0,csvstring.length()-1);
         }
     }
     //setting header values for single report
     public void headerValues(){
        // memory allocation
        paramModel = new List<ParametersModel>();
        headerSet = new Set<String>();
        displaySequence = new List<String>();
        displaySequenceMap = new Map<String,String>();
        displayAlignmentMap = new Map<String,String>();
        columnFormatMap = new Map<String,String>();
        precisionMap = new Map<String,Decimal>();
        //getting report header
        ficColumns = [select id,Page_Orientation__c,(select id,Column_Name__c,Column_Format__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,Pecision__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true ORDER BY Display_Sequence__c ASC),(select id,Name,Label__c,Default_Value__c,Required__c,Lookup_Name__c,Lookup_Column__c from  Parameters__r where Display__c = true ORDER BY Sequence_Number__c ASC),Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Y2_Axis__c,Y2_Label__c,Report_Path__c,Report_Columns__c from FICReportsConfiguration__c where Report_Name__c =: reportName limit 1];
        if(ficColumns.size()>0){
            //filling chart y axis bars data and lable
            Boolean axisFlag = false;            
            if(ficColumns[0].YAxis__c != null){
                YAxisLabels = ficColumns[0].YAxisLabel__c;
                dataStr = 'data1';
                axisFlag = true;
            }
            if(ficColumns[0].Y2_Axis__c != null){          
               if(axisFlag){
                   dataStr += ',';
                   YAxisLabels += ',';
               }
               dataStr += 'data2';
               YAxisLabels += ficColumns[0].Y2_Label__c;
               
            }
            
            //setting page orientation for export pdf
            if(ficColumns[0].Page_Orientation__c != null){
                Page_Orientation = ficColumns[0].Page_Orientation__c;
            }
            
            //filling header model for report
            if(ficColumns[0].ColumnConfigurations__r != null && ficColumns[0].ColumnConfigurations__r.size()>0){
                for(ColumnConfiguration__c cc:ficColumns[0].ColumnConfigurations__r){
                    headerValueModel hvm = new headerValueModel();
                    
                    //filling column alignment map
                    if(cc.Column_Format__c == 'Number' || cc.Column_Format__c == 'Percentage'){
                        precisionMap.put(String.ValueOf(cc.Column_Sequence__c),cc.Pecision__c);
                        displayAlignmentMap.put(String.ValueOf(cc.Column_Sequence__c),'right');
                    }else{
                        displayAlignmentMap.put(String.ValueOf(cc.Column_Sequence__c),'left');
                    }
                    //setting column width
                    if(cc.Column_Width__c != null){
                        hvm.width = cc.Column_Width__c+'px';
                    }
                    //filling column header values
                    if(ApexPages.CurrentPage().getParameters().get('export') != null || !cc.Column_Name__c.contains(' ')){
                        hvm.headerValue = cc.Column_Name__c;
                    }else{
                        String str = '';
                        for(String s:cc.Column_Name__c.split(' ')){
                            str += s+'<br/>';
                        }
                        hvm.headerValue = str;                        
                    }
                    //setting column alignment
                    if(cc.Column_Format__c == 'Number' || cc.Column_Format__c == 'Percentage'){
                        hvm.textAlignment = 'right';    
                    }
                    columnFormatMap.put(string.ValueOf(cc.Column_Sequence__c),cc.Column_Format__c);
                    headerValues.add(hvm);
                    headerSet.add(String.ValueOf(cc.Column_Sequence__c));
                    displaySequence.add(String.ValueOf(cc.Display_Sequence__c));
                    displaySequenceMap.put(String.ValueOf(cc.Display_Sequence__c),String.ValueOf(cc.Column_Sequence__c));
                }
            }
            //filling parameters model
            if(ficColumns[0].Parameters__r != null && ficColumns[0].Parameters__r.size()>0){                
                Set<String> paramIds = new Set<String>();
                Set<String> ColumnValueSet = new Set<String>(); 
                Map<String,List<SelectOption>> parameterMap = new Map<String,List<SelectOption>>();
                
                //fetching id of FC Lookup Manager
                for(Parameter__c param:ficColumns[0].Parameters__r){                    
                    paramIds.add(param.Lookup_Name__c);
                    ColumnValueSet.add(param.Lookup_Column__c);                    
                }
                
                //fetching option list for parameter values
                for(FC_Lookup_Manager__c manager:[select id,(select id,Column_Value__c,Column_Name__c from FC_Lookup_Details__r where Column_Name__c in:ColumnValueSet order by Column_Value__c ASC) from FC_Lookup_Manager__c where id in:paramIds]){
                    List<SelectOption> optList = new List<SelectOption>();   
                    String columnaName = '';
                    for(FC_Lookup_Detail__c fc:manager.FC_Lookup_Details__r){
                        columnaName = fc.Column_Name__c.toLowerCase();                        
                        List<SelectOption> optTempList = parameterMap.get(manager.id+columnaName);
                        if(optTempList == null){
                            optTempList = new List<SelectOption>();  
                            optTempList.add(new SelectOption('','--Select Value--'));               
                        }
                        Set<String> tempSet = new Set<String>();
                        for(SelectOption str:optTempList){
                            tempSet.add(str.getValue());
                        }      
                        //System.debug('@#@#@#@#@#@#'+tempSet);                  
                        if(!tempSet.contains(fc.Column_Value__c)){
                            optTempList.add(new SelectOption(fc.Column_Value__c,fc.Column_Value__c));
                            parameterMap.put(manager.id+columnaName,optTempList);
                        }                        
                    }
                }      
                
                //filling parameters picklist       
                for(Parameter__c param:ficColumns[0].Parameters__r){ 
                    ParametersModel pm = new ParametersModel();
                    pm.param = param;
                    
                    if(param.Name.toLowerCase() == 'calendar."period name"'){
                        pm.param.Default_Value__c = '';
                    }else if(param.Name.toLowerCase() == 'calendar."period year"'){
                        pm.param.Default_Value__c = String.ValueOf(curDate.year());
                    }else if(param.Name.toLowerCase() == 'participant."participant name"' ){
                        participantNameFlag = true;
                        pm.param.Default_Value__c = defaultName;
                    }
                    
                    if(param.Required__c){
                        pm.requiredInput = 'requiredInput '; 
                        pm.requiredBlock = 'requiredBlock ';
                        
                    }
                    if(param.Lookup_Column__c != null && parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase()) != null){
                        pm.paramList = parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase());                        
                    }                    
                    pm.paramList.add(new SelectOption('other','Other'));              
                    paramModel.add(pm);
                }                
            }
        }
     }
     // run single report
     public void filterValues(){
        OracleBiWebservicesV7.SAWSessionServiceSoap service = new OracleBiWebservicesV7.SAWSessionServiceSoap();
        
        if (!Test.isRunningTest()){
            //logon to oracle webservices
            if(oracleConnectionList.size()>0){
                sessionid = service.logon(oracleConnectionList[0].Username__c, oracleConnectionList[0].Password__c);            
            }
        }
        
        OracleBiWebservicesV7Xml.XmlViewServiceSoap xmlService = new OracleBiWebservicesV7Xml.XmlViewServiceSoap();
        OracleBiWebservicesV7Xml.ReportRef report = new OracleBiWebservicesV7Xml.ReportRef();
        report.reportPath ='/users/srini.parimi@cloudspm.com/_filters/Test SFDC';
        
        //set report path
        if(ficColumns.size()>0){
            report.reportPath = ficColumns[0].Report_Path__c+'/'+reportName;
        }
        OracleBiWebservicesV7Xml.XMLQueryExecutionOptions executeOption = new OracleBiWebservicesV7Xml.XMLQueryExecutionOptions();
        OracleBiWebservicesV7Xml.ReportParams reportParams = new OracleBiWebservicesV7Xml.ReportParams();
        
        //set parameters values
        String filterExpression1 = '';
        reportParams.filterExpressions = new List<String>();
        String errmsg = '<ul>';        
        Boolean errFlag = false;
        for(ParametersModel pm:paramModel){
            Boolean addFilter = false;
            String val = '';
            if(pm.param.Required__c == true){
                if(pm.param.Default_Value__c != null && pm.param.Default_Value__c.trim().length()>0){
                    if(pm.param.Default_Value__c != 'other'){
                        val = pm.param.Default_Value__c;
                        addFilter = true;
                    }else if(pm.param.Default_Value__c == 'other' && pm.otherValue != null && pm.otherValue.trim().length()>0){
                        val = pm.otherValue ;
                        addFilter = true;
                    }else{
                        errFlag = true;
                        errmsg += '<li><Strong>'+pm.param.Label__c+'</strong> is Required</li>';
                    }
                }else{
                    errFlag = true;
                    errmsg += '<li><Strong>'+pm.param.Label__c+'</strong> is Required</li>';
                }
            }else{                
                if(pm.param.Default_Value__c != null && pm.param.Default_Value__c.trim().length()>0 && pm.param.Default_Value__c != 'other'){
                    val = pm.param.Default_Value__c;
                    addFilter = true;
                }else if(pm.param.Default_Value__c == 'other' && pm.otherValue != null && pm.otherValue.trim().length()>0){
                    val = pm.otherValue;
                    addFilter = true;
                }    
            }
            //system.debug('##$##$'+val);
            if(addFilter){
                filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="equal" '+
                ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
                ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
                ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
                '<sawx:expr xsi:type="sawx:sqlExpression">'+pm.param.Name+'</sawx:expr>' +
                '<sawx:expr xsi:type="xsd:string">'+val+'</sawx:expr></sawx:expr>';
                
                reportParams.filterExpressions.add(filterExpression1);    
            }
            
        }
        if(!participantNameFlag && defaultName != ''){
            filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="equal" '+
            ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
            ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
            ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
            ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
            '<sawx:expr xsi:type="sawx:sqlExpression">Participant."Participant Name"</sawx:expr>' +
            '<sawx:expr xsi:type="xsd:string">'+defaultName+'</sawx:expr></sawx:expr>';
            
            reportParams.filterExpressions.add(filterExpression1);       
        }  
        if(errFlag == true){
            errmsg += '</ul>';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errmsg );
            ApexPages.addMessage(myMsg); 
            return ;
        }
        try{                        
            if (!Test.isRunningTest())
            {
                //execute query
                OracleBiWebservicesV7Xml.QueryResults result = xmlService.executeXMLQuery(report, null, executeOption, reportParams, sessionid);
                reportOutput=result.rowset;
                //parsing xml
                parse(reportOutput);            
            }else{
                //set default value
                String XMLString = '<rowset xmlns="urn:schemas-microsoft-com:xml-analysis:rowset">';
                for(Integer i=0;i<=50;i++){
                    XMLString +='<Row><Column0>Test Manager1</Column0><Column1>12654</Column1><Column2>1</Column2><Column3>12</Column3></Row>';
                }
                XMLString += '</rowset>';
                parse(XMLString); 
            }
            if(rowsxCompleteData.size()==0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'<b>Report Generation Status:</b>  The report returned no results.');
                ApexPages.addMessage(myMsg);                
            }          
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        fillParameters();
       
     }
     
     public PageReference executeReport(){
        OracleBiWebservicesV7.SAWSessionServiceSoap service = new OracleBiWebservicesV7.SAWSessionServiceSoap();
        if (!Test.isRunningTest())
        {
            if(oracleConnectionList.size()>0){
                sessionid = service.logon(oracleConnectionList[0].Username__c, oracleConnectionList[0].Password__c);            
            }
            //sessionid = service.logon(OracleWebservices__c.getValues('OracleWebservice').User_Name__c, OracleWebservices__c.getValues('OracleWebservice').Password__c);
        }
        OracleBiWebservicesV7Xml.XmlViewServiceSoap xmlService = new OracleBiWebservicesV7Xml.XmlViewServiceSoap();
        OracleBiWebservicesV7Xml.ReportRef report = new OracleBiWebservicesV7Xml.ReportRef();
        report.reportPath ='/users/srini.parimi@cloudspm.com/_filters/Test SFDC';
        if(ficColumns.size()>0){
            report.reportPath = ficColumns[0].Report_Path__c+'/'+reportName;
        }
        OracleBiWebservicesV7Xml.XMLQueryExecutionOptions executeOption = new OracleBiWebservicesV7Xml.XMLQueryExecutionOptions();
        OracleBiWebservicesV7Xml.ReportParams reportParams = new OracleBiWebservicesV7Xml.ReportParams();
        
        reportParams.filterExpressions = new List<String>();        
        // filling report parameters
        String filterExpression1 = '';
        if(ApexPages.CurrentPage().getParameters().get('reportParam') != null){
            String reportParameters = ApexPages.CurrentPage().getParameters().get('reportParam');
            for(String params:reportParameters.split('!!')){
                List<String> paramList = params.split(':');
                if(paramList != null && paramList.size()>1){
                    filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="equal" '+
                    ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
                    ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
                    ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                    ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
                    '<sawx:expr xsi:type="sawx:sqlExpression">'+paramList[0]+'</sawx:expr>' +
                    '<sawx:expr xsi:type="xsd:string">'+paramList[1]+'</sawx:expr></sawx:expr>';
                    
                    reportParams.filterExpressions.add(filterExpression1);  
                }
            }
        }  
        
        try{            
            if (!Test.isRunningTest())
            {
                OracleBiWebservicesV7Xml.QueryResults result = xmlService.executeXMLQuery(report, null, executeOption, reportParams, sessionid);
                reportOutput=result.rowset;
                parse(reportOutput);            
            }else{
                String XMLString = '<rowset xmlns="urn:schemas-microsoft-com:xml-analysis:rowset">';
                for(Integer i=0;i<=50;i++){
                    XMLString +='<Row><Column0>Test Manager1</Column0><Column1>12654</Column1><Column2>1</Column2><Column3>12</Column3></Row>';
                }
                XMLString += '</rowset>';
                parse(XMLString); 
            }    
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
     }
     
     //parse the xml string
     public List<List<Row>> parse(String toParse) {
      
      DOM.Document doc = new DOM.Document();      
      try {
        doc.load(toParse);    
        DOM.XMLNode root = doc.getRootElement();
         //getting xml rows
         return getAllRows(root);         
      } catch (System.XMLException e) {  // invalid XML
         e.getMessage();         
      }
      return null;
     }
    
    // change records per page
    public void changePageSize(){
        if(selectedSize != null){
            range = selectedSize;
            flag = true;
            flag2 = false;
            PageSize();
            PageRecords();
        }        
    }
    
    //calculate number of pages 
    public void PageSize(){
        totalPage = (Integer)Math.ceil((Double)rowsxCompleteData.size() / (Double)range);
    }
    
    
    //assign records for first page
    public void PageRecords(){
        //current page number
        currentPage = 1;
                
        rowsx = new List<Row>();        
        Integer start = (currentPage-1)*range;
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
             rowsx.add(rowsxCompleteData[i]);
        }
        if(rowsxCompleteData.size() <= range){
            flag2 = true;
        }
        getData();
    }
    
    // show next page records
    public void nextPage(){
        flag = false;
        
        if((currentPage+1) == totalPage){
            //flag work
            flag2 = true;            
        }
        rowsx = new List<Row>();
        Integer start = currentPage*range;
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
            rowsx.add(rowsxCompleteData[i]);
        }
        
        currentPage++;
         
    }
    
    //show previous page records
    public void previousPage(){
        flag2 = false;
        if((currentPage-1) == 1){
            //flag work
            flag = true;
            
        }
        rowsx = new List<Row>();
        Integer start = (currentPage-2)*range;
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
            rowsx.add(rowsxCompleteData[i]);
        }
         
        currentPage--;
    }
    //getting data rows of xml
    private List<List<Row>> getAllRows(DOM.XMLNode node) {
        //system.debug(' root XML NODE column - '+node.getName());
        rowsx = new List<Row>();
        rowsxChartData = new List<Row>();
        rowsxCompleteData = new List<Row>();
        List<List<Row>> listOfRow = new List<List<Row>>();
        Map<String,String> sortMap = new Map<String,String>();
        List<DOM.XMLNode> rowsxmls =    node.getChildren();
        system.debug('$$$$%%%% '+rowsxmls );
        for(DOM.XMLNode xmlNode:rowsxmls) {            
            Row row = new Row();
            List<DOM.XMLNode> colsxmls =xmlNode.getChildren();
            //system.debug(' ROW XML NODE column - '+xmlNode.getName());
            if(xmlNode.getName()!=null){            
                List<string> cols = new List<string>();
                List<string> chartCols = new List<string>();
                for(DOM.XMLNode colxmlNode:colsxmls) {
                    alignmentModel am = new alignmentModel();
                    if(colxmlNode.getName()!=null){
                        //system.debug(' XML NODE column!!!! - '+colxmlNode.getName());
                        //system.debug(' XML NODE column - '+colxmlNode.getText());   
                                           
                        chartCols.add(colxmlNode.getText());
                        
                        if(headerSet.size()>0){
                            if(headerSet.Contains(colxmlNode.getName().removeStartIgnoreCase('Column'))){                                
                                cols.add(colxmlNode.getText());
                                am.columnValue = colxmlNode.getText();                                
                                sortMap.put(colxmlNode.getName().removeStartIgnoreCase('Column'),colxmlNode.getText());
                            }                            
                        }else{
                            am.columnValue = colxmlNode.getText();
                            cols.add(colxmlNode.getText());
                        }
                        row.columnsList.add(am);
                        
                    }
                }
                
                if(displaySequence.size()>0){
                    cols = new List<string>();
                    row.columnsList = new List<alignmentModel>();
                    for(String str:displaySequence){                    
                        alignmentModel am = new alignmentModel();
                        cols.add(sortMap.get(displaySequenceMap.get(str)));  
                        am.columnValue = sortMap.get(displaySequenceMap.get(str));                  
                        
                        if(displayAlignmentMap.get(str) != null){
                            am.textAlignment = displayAlignmentMap.get(displaySequenceMap.get(str));                        
                        }    
                        try{
                            if(columnFormatMap.get(displaySequenceMap.get(str)) != null && columnFormatMap.get(displaySequenceMap.get(str)).toLowerCase() == 'date'){
                                DateTime dt = DateTime.valueOf(am.columnValue.replace('T',' '));
                                am.columnValue = dt.format('YYYY-MM-dd');
                            } 
                            if(columnFormatMap.get(displaySequenceMap.get(str)) != null && columnFormatMap.get(displaySequenceMap.get(str)).toLowerCase() == 'number'){                            
                                
                                integer scaleType=precisionMap.get(displaySequenceMap.get(str))!=null ? integer.valueOf(precisionMap.get(displaySequenceMap.get(str))) : 2;
                                am.columnValue = string.valueOf(decimal.ValueOf(am.columnValue).setScale(scaleType));
                            } 
                        }catch(exception e){
                            row.columnsList.add(am);
                            continue;
                        }                  
                        row.columnsList.add(am);
                    }
                }
                
               
                row.columns = cols;                
                rowsxCompleteData.add(row);
                listOfRow.add(rowsxCompleteData);
                //system.debug('###$$$ 1 '+headerSet.size());
                //system.debug('###$$$ 2' +row.columns.size());
              
                row = new Row();
                row.columns = chartCols;
                rowsxChartData.add(row);
                listOfRow.add(rowsxChartData);
                
                
            }
            
        }        
        if(rowsxCompleteData.size()==0){
            return null;
        }else{
            if(!multipleReportsFlag){
                PageSize();
                PageRecords();
                makecsv();
            }
            return listOfRow;
        }
 
    }
    
    // Return a list of data points for a chart
    public List<Data> getData() {
        return getChartData();
    }
    
    // The actual chart data; needs to be static to be
    // returns table chart data list    
    public List<Data> getChartData() {
        List<Data> data = new List<Data>();
       
        if(ficColumns[0].XAxis__c != null && (ficColumns[0].YAxis__c != null || ficColumns[0].Y2_Axis__c != null)){
            Integer x = Integer.ValueOf(ficColumns[0].XAxis__c);
            Integer y = Integer.ValueOf(ficColumns[0].YAxis__c);
            Integer z = Integer.ValueOf(ficColumns[0].Y2_Axis__c);            
                       
            
            for(Row r:rowsxChartData){
                Data dt = new Data();
                if(y != null){
                    if(r.columns[y] == null || r.columns[y] == ''){
                        dt.data1 = 0;      
                    }else{                                     
                        if(r.columns[y].contains('.')){
                            dt.data1 = (Integer)Math.ceil(Double.ValueOf(r.columns[y]));                            
                        }else{
                            dt.data1 = Integer.ValueOf(r.columns[y]);                            
                        }                       
                    }
                }
                dt.name = String.ValueOf(r.columns[x]);
                if(z != null){                    
                    if(r.columns[z] == null || r.columns[z] == ''){
                        dt.data2 = 0;                    
                    }else{
                        if(r.columns[z].contains('.')){
                            dt.data2 = (Integer)Math.ceil(Double.ValueOf(r.columns[z]));
                        }else{
                            dt.data2 = Integer.ValueOf(r.columns[z]);
                        }
                    }
                }
                data.add(dt);
            }
        }
        
        return data;
    }
    //data row model
    class Row{
        public List<string> columns{get; set;}
        public List<alignmentModel> columnsList{get;set;}
        public Row(){
            columnsList = new List<alignmentModel>();
        }
    }
    
    //parameter model for report
    public class ParametersModel{
        public Parameter__c param{get;set;}
        public List<SelectOption> paramList{get;set;}
        public String requiredInput{get;set;}
        public String requiredBlock{get;set;}
        public String otherValue{get;set;}
        
        public ParametersModel(){
            requiredInput = '';
            requiredBlock = '';
            otherValue = '';
            paramList = new List<SelectOption>();
            paramList.add(new SelectOption('','--Select Value--'));
            param = new Parameter__c();
        }
    }
    //table chart model class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Integer data2 { get; set; }
        public Integer data3 { get; set; }
        
        public Data(){}
        public Data(String name, Integer data1,Integer data2) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
        }        
    }
    
    //dashboard model
    public class CombinedClass{
        public ChartData chartData{get;set;}
        public List<Row> rowCompleteList{get;set;}
        public List<Row> rowList{get;set;}
        public List<headerValueModel> headerValues{get;set;}
        public List<SelectOption> sizeList{get;set;}     
        public Integer selectedSize{get;set;}        
        public String reportName{get;set;}
        public String displayName{get;set;}
        public String parameterDisplayName{get;set;}
        public String Page_Orientation{get;set;}
        public String dataStr{get;set;}
        public String YAxisLabels{get;set;}
        public String clsName{get;set;}
        public String innerDivWidth{get;set;}
        public String outerDivWidth{get;set;}        
        public Integer totalPage {get;set;}
        public Integer currentPage {get;set;}
        public Integer range {get;set;}
        public Integer ChartWidth{get;set;}
        public Integer index{get;set;}        
        public Boolean flag1{get;set;}
        public Boolean flag2{get;set;}
                
        public CombinedClass(){
            YAxisLabels = '';
            clsName = '';
            innerDivWidth = '';
            outerDivWidth = '';
            dataStr = 'data1';            
            chartData = new ChartData();
            rowList = new List<Row>();
            rowCompleteList = new List<Row>();
            headerValues = new List<headerValueModel>();
            range = 10;
            currentPage = 1;
            Page_Orientation = 'Portrait';
            sizeList = new List<SelectOption>();
            sizeList.add(new SelectOption('10','10'));
            sizeList.add(new SelectOption('50','50'));
            sizeList.add(new SelectOption('100','100'));
            sizeList.add(new SelectOption('150','150'));
            sizeList.add(new SelectOption('200','200'));
            chartWidth = 600;
        }
    }
    
    //dashboard chart model
    public class ChartData{
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Integer data2 { get; set; }
        public List<Row> rowList{get;set;}        
        public Integer x{get;set;}
        public Integer y{get;set;}
        public Integer z{get;set;}
        public String xLabel{get;set;}
        public String yLabel{get;set;}
        public String zLabel{get;set;}
       
        public ChartData(){}             
        public ChartData(List<Row> rowList,Integer x, Integer y, String xLabel, String ylabel, Integer z, String zlabel) {
            this.rowList = rowList;
            this.x = x;
            this.y = y;
            this.xLabel = xLabel;
            this.yLabel = ylabel;
            this.z = z;
            this.zLabel = zlabel;
        }
        // return dashboard chart data
        public List<ChartData> getChartValues() {
            List<ChartData> chartDataList = new List<ChartData>();                                    
            if(rowList == null && rowList.size()==0){
                ChartData cd = new ChartData(); 
                
                cd.name =  'test';       
                cd.xLabel = 'xLabel';
                cd.data1 = 0;
                chartDataList.add(cd);
            }
            // filling chart data
            for(Row r:rowList){
                ChartData cd = new ChartData(); 
                
                cd.name =  String.ValueOf(r.columns[x]);               
                cd.xLabel = xLabel;
                
                if(y != null){
                    if(r.columns[y] == null || r.columns[y] == ''){
                        cd.data1 = 0;
                    }else{
                        try{
                            if(r.columns[y].contains('.')){
                                cd.data1 = (Integer)Math.ceil((Double.valueOf(r.columns[y])));
                            }else{
                                cd.data1 = Integer.ValueOf(r.columns[y]);   
                            }       
                        }catch(Exception e){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                            ApexPages.addMessage(myMsg);
                            continue;
                        }   
                    }
                }
                if(z != null){
                    if(r.columns[z] == null || r.columns[z] == ''){
                        cd.data2 = 0;
                    }else{
                        try{
                            if(r.columns[z].contains('.')){
                                cd.data2 = (Integer)Math.ceil((Double.valueOf(r.columns[z])));
                            }else{
                                cd.data2 = Integer.ValueOf(r.columns[z]);   
                            }       
                        }catch(Exception e){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                            ApexPages.addMessage(myMsg);
                            continue;
                        }   
                    }
                }
                        
                chartDataList.add(cd);
            }                      
                        
            //system.debug('$$$$'+chartDataList );
            return chartDataList;
            
        }
        
    }
    
    //table header column model
    public class headerValueModel{
        public String headerValue{get;set;}
        public String width{get;set;}
        public String textAlignment{get;set;}
        
        public headerValueModel(){
            width = 'auto';
            textAlignment = 'left';
        }
    }
    
    //table data column model
    public class alignmentModel{
        public String columnValue{get;set;}
        public String textAlignment{get;set;}
        
        public alignmentModel(){
            textAlignment = 'left';
        }
    } 
     
}