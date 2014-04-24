public with sharing class CompensationMPGController {
public String csvstring{get;set;}  
	 public String isMobile{get;set;}    
     public String linkId{get;set;}
     public string sessionid{get; set;}
     public string reportOutput{get; set;}
     public List<Row> rowsx{get; set;}
     public List<Row> pivotRows{get; set;} 
     
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
     public Map<String,boolean> columnTotalMap{get;set;}
     
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
     public Boolean isPivot{get;set;}
     private List<String> dashboardRepWidth{get;set;}
     private map<String,decimal>precisionMap;
     public CompensationMPGController(){

     	isMobile = 'false';
     	if( ApexPages.currentPage().getUrl().containsIgnoreCase(page.compensationMPG.getUrl())) {
     		isMobile = 'true';	
     	}
     	
     	
         columnFormatMap = new Map<String,String>();
         columnTotalMap = new Map<String,boolean>();
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
     	List<FICReportsConfiguration__c> reportList= getCurrentUserDashboard();
        // getting dashboard reports
      //  List<FICReportsConfiguration__c> ficReport = [select id,Report_Path__c,Display_Name__c,Y2_Axis__c,Y2_Label__c,Page_Orientation__c,Spedometer_Band__c,Spedometer_Band_Color__c,(select id,Column_Name__c,Column_Format__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,FIC_Reports_Configuration__c,Pecision__c from ColumnConfigurations__r where Display__c = true ORDER BY Display_Sequence__c ASC),Show_Chart__c,Show_Table__c,Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Chart_Type__c from FICReportsConfiguration__c where ShowOnDashboard__c = true and Report_Name__c != 'Dashboard' order by Dashboard_Display_Sequence__c ASC limit 4];
        List<FICReportsConfiguration__c> ficReport = [select id,Report_Path__c,Display_Name__c,Y2_Axis__c,Y2_Label__c,Page_Orientation__c,Spedometer_Band__c,Spedometer_Band_Color__c,(select id,Column_Name__c,Column_Format__c,Show_Total__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,FIC_Reports_Configuration__c,Pecision__c from ColumnConfigurations__r where Display__c = true AND Mobile_Display__c = true ORDER BY Display_Sequence__c ASC),Show_Chart__c,Show_Table__c,Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Chart_Type__c from FICReportsConfiguration__c where id in :reportList];
        // query doesn not return result in order
        List<FICReportsConfiguration__c> orderList = new List<FICReportsConfiguration__c>();
        for(FICReportsConfiguration__c userRep:reportList){
        	for(FICReportsConfiguration__c ficRep:ficReport){
        		if(userRep.id==ficRep.id){
        			orderList.add(ficRep);
        		}
        	}
        }
        
        ficReport=orderList;
        
        if(ficReport != null && ficReport.size()>0){
        	Integer repIndex=0;
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
              //   ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,' PARAMS -> '+reportParams);
               //  ApexPages.addMessage(myMsg1);
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
                    comChart.chartType = fic.Chart_Type__c;
                    comChart.width = dashboardRepWidth.get(repIndex);
                    // memory allocation
                    headerSet = new Set<String>();
                    displaySequence = new List<String>();
                    displaySequenceMap = new Map<String,String>();
                    displayAlignmentMap = new Map<String,String>();
                    columnFormatMap = new Map<String,String>();
                    columnTotalMap = new Map<String,boolean>();
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
                            columnTotalMap.put(string.ValueOf(cc.Column_Sequence__c),cc.Show_Total__c);
                        }
                    }                                     
                    
                    //getting parsed values for report table and chart                   
                    List<List<Row>> listOfRow = parse(reportOutput); 
                    
                    if(listOfRow != null && listOfRow.size()>0){
                        // set report table values
                        if(fic.Show_Table__c){ 
                            comChart.rowCompleteList = listOfRow[0];          
                        }             
                        String yaxislabel = '';  
                        boolean axisFlag = false;        
                        if(fic.YAxis__c != null){
		                    yaxislabel= fic.YAxisLabel__c;
		                    axisFlag = true;
		                }
		                if(fic.Y2_Axis__c != null){          
		                   if(axisFlag){
		                       yaxislabel += ',';
		                   }
		                   yaxislabel += fic.Y2_Label__c;
		                  
		                }
                        //set chart values
                        if(listOfRow.size()>1 && fic.XAxis__c != null && (fic.YAxis__c != null || fic.Y2_Axis__c != null) && fic.Show_Chart__c == true){  
                            ChartData chatob = new ChartData(listOfRow[1],Integer.ValueOf(fic.XAxis__c),Integer.ValueOf(fic.YAxis__c),fic.XAxisLabel__c,fic.YAxisLabel__c,Integer.ValueOf(fic.Y2_Axis__c),fic.Y2_Label__c,yaxislabel,comChart );
                           	chatob.chartType=comChart.chartType;
                           	chatob.plotBands = fic.Spedometer_Band__c;
                           	chatob.bandColors = fic.Spedometer_Band_Color__c;
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
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
                    ApexPages.addMessage(myMsg);
                }
                repIndex++;
            }         
        }
     }
       public List<FICReportsConfiguration__c> getCurrentUserDashboard(){
       	List<FICReportsConfiguration__c> reportList = new List<FICReportsConfiguration__c>();
       	dashboardRepWidth = new List<string>();
     	String userid =UserInfo.getUserId();
     	string str =' REPORTS FOR- '+userid+' -- ';
     	Dashboard_User_Map__c dashboard = [select id,Dashboard_Layout__c from Dashboard_User_Map__c where User__c=:userid limit 1];
     	str +=' '+dashboard.Dashboard_Layout__c;
     	List<Dashboard_Row__c> dashboardRows = [select id,Columns__c,(select FIC_Reports_Configuration__r.id,FIC_Reports_Configuration__r.Display_Name__c from Dashboard_Report__r order by  Sequence__c) from Dashboard_Row__c where Dashboard_Layout__c=:dashboard.Dashboard_Layout__c order by Row_Number__c];
     	
     	for(Dashboard_Row__c dashrow:dashboardRows){
     		String width= ((100/dashrow.Columns__c).setScale(2)-0.5)+'';
     		
     		for(Integer i=0;i<dashrow.Columns__c;i++){
     			dashboardRepWidth.add('100');
     		}
     		for(Dashboard_Report__c dashCol:dashrow.Dashboard_Report__r	){
     			
	     		FICReportsConfiguration__c rep = dashCol.FIC_Reports_Configuration__r;
	     		reportList.add(rep);
	     		str +=rep.Display_Name__c;
     		}
     	}
        return reportList;
     }
     public void preparePivotData(){
     	List<Integer> pivotColSequence = new List<Integer>();
     	Map<Integer,String> pivoteColSeqName = new Map<Integer,string>();
     	List<Integer> nonPivotCols = new List<Integer>();
     	List<Integer> pivotCols = new List<Integer>();
     	Integer pivotResultColSeq = null;
 	    List<FICReportsConfiguration__c>  report = [select id,Is_Pivot__c,(select id,Column_Sequence__c,Column_Name__c,Pivot_Sequence__c,Pivot_Result__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true AND Mobile_Display__c = true ORDER BY Pivot_Sequence__c ASC) from FICReportsConfiguration__c where Report_Name__c =: reportName limit 1];
 		if(report[0].Is_Pivot__c!=null && report[0].Is_Pivot__c ){
 			isPivot = true;
 		}
 		for(ColumnConfiguration__c colConf:report[0].ColumnConfigurations__r){
 			Integer pivotColSeq=Integer.valueOf(colConf.Column_Sequence__c);
 			pivotColSequence.add(Integer.valueOf(colConf.Column_Sequence__c));
 			pivoteColSeqName.put(Integer.valueOf(colConf.Column_Sequence__c),colConf.Column_Name__c);
 			Integer i=0;  // i is nothing but the sequence of the xml cols
 			
 			for(headerValueModel hvm: headerValues){
	 				if(hvm.actualHeaderValue == colConf.Column_Name__c && colConf.Pivot_Sequence__c != null ){
	 					hvm.innerHeaderValues = getPivotColumns(i);	// get headers for the pivot column
	 					hvm.isPivotCol=true;
	 					pivotCols.add(i);  //
	 				} 
	 				if(hvm.actualHeaderValue == colConf.Column_Name__c && colConf.Pivot_Result__c==true){
	 					hvm.isPivotResult=true; 
	 				}
 					i++;
 				}
 				
 			}
 			
 		
 		Integer i=0;
 		for(headerValueModel hvm: headerValues){
 			// consider non pivot column if it is not pivotcol or pivot result col
 			if((hvm.isPivotCol==null || hvm.isPivotCol==false) && (hvm.isPivotResult==null || hvm.isPivotResult==false) ){ 
 				nonPivotCols.add(i);
 			}
 			if(hvm.isPivotResult!=null && hvm.isPivotResult==true){
 				pivotResultColSeq=i;
 			}
 			i++;
 		}
 		createPivotRows(nonPivotCols, pivotResultColSeq);
     }
     
     public void createPivotRows(List<Integer> nonPivotCols,Integer pivotResultColSeq){
     	Map<string,Row> pivotMap = new Map<string,Row>();
     	pivotRows = new List<Row>();
     	for(Row row:rowsxCompleteData){    // loop over all data from bi service
     		List<string> nonPivotColData = new List<string>();
     		string key=''; 
     		
     		boolean flag=false;
	     	for(Integer cols:nonPivotCols){
	     		key = key + row.columns[cols];
	     		nonPivotColData.add(row.columns[cols]);
	     	}
	     	string result = row.columns[pivotResultColSeq];
	     	Row pRow =  pivotMap.get(key);
	     	if(pRow==null){
	     		pRow = new Row();
	     		//resultCols.add(result);
	     		pivotMap.put(key,pRow);
	     		pRow.columns= nonPivotColData;
	     		pRow.columns.add(result);
	     		flag = true;
	     			
	     	}else{
	     		pRow.columns.add(result);
	     		//resultCols.add(result);
	     	}
	     	
	     	//pivotRows.add(row);
	     	
     	}
     	pivotRows = pivotMap.values();

     }
     
     public List<string> getPivotColumns(Integer pivoteColSeq){
     	Set<string> pivotColsSet = new Set<string>();
     	List<string> pivotCols = new List<string>();
     	try{
	 		for(Row row:rowsxCompleteData){
	 			if(pivotColsSet.add(row.columns[pivoteColSeq])){
	 				pivotCols.add(row.columns[pivoteColSeq]); // using list to maintain record order, sets do not handle order
	 			}
	 		}
 		}
 		catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
            ApexPages.addMessage(myMsg);
        }
 		return pivotCols;
     }
     
     public class PivotData{
     	 Map<headerValueModel,List<headerValueModel>> headers = new Map<headerValueModel,List<headerValueModel>>();
     	 List<Row> rows = new List<Row>();
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
        /* if(!participantNameFlag && defaultName != ''){
             parametersString += 'Participant."Participant Name":'+defaultName+'!!';     
         }  */        
     }
     // run dashboard report after giving parameters
     public PageReference runReport(){   
         parametersString = '';
         String url = '/apex/compensationMPG?runReport=true';   
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
         /*if(!participantNameFlag && defaultName != ''){
             parametersString += 'Participant."Participant Name":'+defaultName+'!!';     
         } */
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
     public void addTotalRow(List<Row> rowList){
     	Row totalRow = new Row();
        List<Decimal> totalCols = new List<Decimal>();
        if(rowList.size()>0){
        	for(integer c=0;c<rowList[0].columnsList.size();c++){
        		totalCols.add(0.0);
        	}
        }
        for(Row row:rowList){
        	integer colIndex=0;
             for(alignmentModel am: row.columnsList){
             	if(am.isTotal != null && am.isTotal){
             		   am.isTotal = false;	
             		   Decimal  totalVal= totalCols.get(colIndex);
	 				   Decimal decimalVal=am.decimalVal;
	                   if(totalVal==null){
	                   		totalCols.add(decimalVal);
	                   }else{
	                   		totalVal = totalVal + decimalVal;
	                   		totalCols.set(colIndex,totalVal);
	                   }
             	}
             	colIndex++;
             }
        }
        List<alignmentModel> rowCols = new List<alignmentModel>();
        for(Decimal val:totalCols){
        	alignmentModel am = new alignmentModel();
        	am.textAlignment='right';
        	if(val>0){
        		am.columnValue ='<b>'+val +'</b>';
        		am.isTotal =true;
        	}else{
        		am.columnValue ='';
        	}
        	rowCols.add(am);
        }
        totalRow.columnsList = rowCols;
        rowList.add(totalRow);
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
                 addTotalRow(ccList[index].rowList);
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
    	getCurrentUserDashboard();   
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
        List<FICReportsConfiguration__c> ficList = [select id,(select id,Name,Lookup_Name__c,Default_Value__c,Lookup_Column__c,Required__c,Label__c,Multi_Select__c  from  Parameters__r where display__c = true order by Sequence_Number__c) from FICReportsConfiguration__c where Report_Name__c =: 'Dashboard'];
       
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
                for(FC_Lookup_Manager__c manager:[select id,(select id,Column_Value__c,Column_Name__c from FC_Lookup_Details__r where Column_Name__c in:ColumnValueSet order by Row_Number__c ASC) from FC_Lookup_Manager__c where id in:paramIds]){
                    List<SelectOption> optList = new List<SelectOption>();   
                    String columnaName = '';
                    for(FC_Lookup_Detail__c fc:manager.FC_Lookup_Details__r){
                    	
                        columnaName = fc.Column_Name__c.toLowerCase();    
                        System.debug(' columnaName  >>>>>>> '+columnaName);                    
                        List<SelectOption> optTempList = parameterMap.get(manager.id+columnaName);
                        if(optTempList == null){
                            optTempList = new List<SelectOption>();  
                            optTempList.add(new SelectOption('','--Select Value--', true));               
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
                	participantNameFlag = false;
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
                    System.debug('param.Lookup_Column__c   ' +param.Lookup_Column__c);
                    if(param.Lookup_Column__c.toLowerCase()=='participant_name'){
                    	participantNameFlag = true;
                    }
                    if(param.Lookup_Column__c != null && parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase()) != null){
                        pm.paramList = parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase());
                        if(participantNameFlag){
                        	 pm.paramList = getParticipantList();
                        }
                    }                    
                    //pm.paramList.add(new SelectOption('other','Other'));              
                    paramModel.add(pm);
                }                
            }  
        }       
    }
    
    public List<Selectoption> getParticipantList(){
    	List<Selectoption> options = new List<Selectoption>();
    	options.add(new SelectOption('','--Select Value--', true));
    	Id userid = Userinfo.getUserId();
        User user = [Select Email From User where id = : userid limit 1];
        string email = user.Email;
        System.debug(' EMAIL >>>> '+Email);
        List<Decimal> rowNumbers = new List<Decimal>();
        for(FC_Lookup_Detail__c fc:[select Row_Number__c from FC_Lookup_Detail__c
								where Column_Name__c='MGR_EMAIL_ADDRESS' and Column_Value__c=:email and
								FC_Lookup_Manager__c in (select id from FC_Lookup_Manager__c where Lookup_Name__c='MgrHierarchy')]){
				rowNumbers.add(fc.Row_Number__c);					
		}
								 
       for(FC_Lookup_Detail__c fc:[select Column_Value__c,Column_Name__c from FC_Lookup_Detail__c where
							FC_Lookup_Manager__c in (select id from FC_Lookup_Manager__c where Lookup_Name__c='MgrHierarchy')
							AND Row_Number__c IN :rowNumbers and Column_Name__c ='PARTICIPANT_NAME']){
								options.add(new Selectoption(fc.Column_Value__c,fc.Column_Value__c));		
		} 
		 System.debug(' Options >>>> '+options);               	
		return options;		                        	
    }
    
    // get header values for Dashboard reports
    public void multipleReportsHeader(Integer index){
        if(index != null && ccList.size()>index){            
            ficColumns = [select id,Y2_Axis__c,Y2_Label__c,(select id,Column_Name__c,Column_Format__c,Show_Total__c,Column_Sequence__c,Display__c,Display_Sequence__c,Column_Width__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true AND Mobile_Display__c = true ORDER BY Display_Sequence__c ASC),(select id,Name,Label__c from  Parameters__r),Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Report_Path__c,Report_Columns__c from FICReportsConfiguration__c where Report_Name__c =: ccList[index].reportName limit 1];
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
                        hvm.actualHeaderValue =cc.Column_Name__c;
                        
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
        columnTotalMap = new Map<String,boolean>();
        precisionMap = new Map<String,Decimal>();
        //getting report header
        ficColumns = [select id,Page_Orientation__c,Is_Pivot__c,(select id,Column_Name__c,Column_Format__c,Show_Total__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,Pecision__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true AND Mobile_Display__c = true ORDER BY Display_Sequence__c ASC),(select id,Name,Label__c,Default_Value__c,Required__c,Lookup_Name__c,Lookup_Column__c,Multi_Select__c  from  Parameters__r where Display__c = true ORDER BY Sequence_Number__c ASC),Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Y2_Axis__c,Y2_Label__c,Report_Path__c,Report_Columns__c,Chart_Type__c from FICReportsConfiguration__c where Report_Name__c =: reportName limit 1];
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
            //setting if report type is pivot
            if(ficColumns[0].Is_Pivot__c!=null && ficColumns[0].Is_Pivot__c ){
 				isPivot = true;
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
                     hvm.actualHeaderValue =cc.Column_Name__c;
                    //setting column alignment
                    if(cc.Column_Format__c == 'Number' || cc.Column_Format__c == 'Percentage'){
                        hvm.textAlignment = 'right';    
                    }
                    columnFormatMap.put(string.ValueOf(cc.Column_Sequence__c),cc.Column_Format__c);
                    columnTotalMap.put(string.ValueOf(cc.Column_Sequence__c),cc.Show_Total__c);
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
                for(FC_Lookup_Manager__c manager:[select id,(select id,Column_Value__c,Column_Name__c from FC_Lookup_Details__r where Column_Name__c in:ColumnValueSet order by Row_Number__c ASC) from FC_Lookup_Manager__c where id in:paramIds]){
                    List<SelectOption> optList = new List<SelectOption>();   
                    String columnaName = '';
                    for(FC_Lookup_Detail__c fc:manager.FC_Lookup_Details__r){
                        columnaName = fc.Column_Name__c.toLowerCase();                        
                        List<SelectOption> optTempList = parameterMap.get(manager.id+columnaName);
                        if(optTempList == null){
                            optTempList = new List<SelectOption>();  
                            optTempList.add(new SelectOption('','--Select Value--', true));               
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
                    if(param.Lookup_Column__c.toLowerCase()=='participant_name'){  // assumption : if lookup column set to participant_name then it is participant param
                    	participantNameFlag = true;
                    }     
                    if(param.Lookup_Column__c != null && parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase()) != null){
                        pm.paramList = parameterMap.get(param.Lookup_Name__c+param.Lookup_Column__c.toLowerCase());     
                        if(participantNameFlag){
                        	 pm.paramList = getParticipantList(); // get participant list by manager
                        }                   
                    }                    
                   // pm.paramList.add(new SelectOption('other','Other'));              
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
            	if(pm.param.Multi_Select__c){
            		 List<string> values =val.split(',');
	            		filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="in" '+
	                ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
	                ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
	                ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
	                ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
	                '<sawx:expr xsi:type="sawx:sqlExpression">'+pm.param.Name+'</sawx:expr>' ;
	                for(string sval:values){
	               	 filterExpression1 +='<sawx:expr xsi:type="xsd:string">'+sval+'</sawx:expr>';
	                }
	                
	               filterExpression1 +='</sawx:expr>';
            	}else{
	                filterExpression1 = '<sawx:expr xsi:type="sawx:comparison" op="equal" '+
	                ' xmlns:saw="com.siebel.analytics.web/report/v1.1" '+
	                ' xmlns:sawx="com.siebel.analytics.web/expression/v1.1" ' +
	                ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
	                ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"> ' +
	                '<sawx:expr xsi:type="sawx:sqlExpression">'+pm.param.Name+'</sawx:expr>' +
	                '<sawx:expr xsi:type="xsd:string">'+val+'</sawx:expr></sawx:expr>';
            	}
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
            if(isPivot != null && isPivot){  
            	preparePivotData();
            }
                  
        }catch(Exception e){
        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
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
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
            ApexPages.addMessage(myMsg);
        }
        return null;
     }
     
     //parse the xml string
     public List<List<Row>> parse(String toParse) {
      /*
      Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
      msg.setToAddresses(new String[] { 'tarunjain43@gmail.com' });
      msg.setPlainTextBody(toParse);      
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
      */
      
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
        Row totalRow = new Row();
        List<Decimal> totalCols = new List<Decimal>();
        if(rowsxCompleteData.size()>0){
        	for(integer c=0;c<rowsxCompleteData[0].columnsList.size();c++){
        		totalCols.add(0.0);
        	}
        }
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
             rowsx.add(rowsxCompleteData[i]);
             integer colIndex=0;
             for(alignmentModel am: rowsxCompleteData[i].columnsList){
             	if(am.isTotal != null && am.isTotal){
             		  // am.isTotal = false;	
             		   Decimal  totalVal= totalCols.get(colIndex);
	 				   Decimal decimalVal=am.decimalVal;
	                   if(totalVal==null){
	                   		totalCols.add(decimalVal);
	                   }else{
	                   		totalVal = totalVal + decimalVal;
	                   		totalCols.set(colIndex,totalVal);
	                   }
             	}
             	colIndex++;
             }
        }
        List<alignmentModel> rowCols = new List<alignmentModel>();
        for(Decimal val:totalCols){
        	alignmentModel am = new alignmentModel();
        	am.isTotalVal=true;
        	am.textAlignment='right';
        	if(val>0){
        		am.columnValue =val +'';
        		am.isTotal =true;
        	}else{
        		am.columnValue ='';
        	}
        	rowCols.add(am);
        }
        totalRow.columnsList = rowCols;
        rowsx.add(totalRow);
        
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
        Row totalRow = new Row();
        List<Decimal> totalCols = new List<Decimal>();
        if(rowsxCompleteData.size()>0){
        	for(integer c=0;c<rowsxCompleteData[0].columnsList.size();c++){
        		totalCols.add(0.0);
        	}
        }
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
             rowsx.add(rowsxCompleteData[i]);
             integer colIndex=0;
             for(alignmentModel am: rowsxCompleteData[i].columnsList){
             	if(am.isTotal != null && am.isTotal){
             		   //am.isTotal = false;	
             		   Decimal  totalVal= totalCols.get(colIndex);
	 				   Decimal decimalVal=am.decimalVal;
	                   if(totalVal==null){
	                   		totalCols.add(decimalVal);
	                   }else{
	                   		totalVal = totalVal + decimalVal;
	                   		totalCols.set(colIndex,totalVal);
	                   }
             	}
             	colIndex++;
             }
        }
        List<alignmentModel> rowCols = new List<alignmentModel>();
        for(Decimal val:totalCols){
        	
        	alignmentModel am = new alignmentModel();
        	am.isTotalVal=true;
        	am.textAlignment='right';
        	if(val>0){
        		am.columnValue =val +'';
        		am.isTotal =true;
        	}else{
        		am.columnValue ='';
        	}
        	rowCols.add(am);
        }
        totalRow.columnsList = rowCols;
        rowsx.add(totalRow);
        
        currentPage++;
         
    }
    
    //show previous page records
    public void previousPage(){ 
    	try{
        flag2 = false;
        if((currentPage-1) == 1){
            //flag work
            flag = true;
            
        }
        rowsx = new List<Row>();
        Integer start = (currentPage-2)*range;
        Row totalRow = new Row();
        List<Decimal> totalCols = new List<Decimal>();
        
        if(rowsxCompleteData.size()>0){
        	for(integer c=0;c<rowsxCompleteData[0].columnsList.size();c++){
        		totalCols.add(0.0);
        	}
        }
        for(Integer i=start; i<start+range && i<rowsxCompleteData.size(); i++){
             rowsx.add(rowsxCompleteData[i]);
             integer colIndex=0;
             for(alignmentModel am: rowsxCompleteData[i].columnsList){
             	if(am.isTotal != null && am.isTotal){
             		 //  am.isTotal = false;	
             		   Decimal  totalVal= totalCols.get(colIndex);
	 				   Decimal decimalVal=am.decimalVal;
	                   if(totalVal==null){
	                   		totalCols.add(decimalVal);
	                   }else{
	                   		totalVal = totalVal + decimalVal;
	                   		totalCols.set(colIndex,totalVal);
	                   }
             	}
             	colIndex++;
             }
        }
        List<alignmentModel> rowCols = new List<alignmentModel>();
        for(Decimal val:totalCols){
        	alignmentModel am = new alignmentModel();
        	am.isTotalVal=true;
        	am.textAlignment='right';
        	if(val>0){
        		am.columnValue =val +'';
        		am.isTotal =true;
        	}else{
        		am.columnValue ='';
        	}
        	rowCols.add(am);
        }
        totalRow.columnsList = rowCols;
        rowsx.add(totalRow); 
         
        currentPage--;
 
    	}catch(Exception e){
    		 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
            ApexPages.addMessage(myMsg);
    	}
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
        Row totalRow = new Row();
        List<Decimal> totalCols = new List<Decimal>();
        Integer rowIndex = 0;
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
                        string colValue=sortMap.get(displaySequenceMap.get(str));
                       // cols.add(sortMap.get(displaySequenceMap.get(str)));  
                        am.columnValue = sortMap.get(displaySequenceMap.get(str));                  
                        
                        if(displayAlignmentMap.get(str) != null){
                            am.textAlignment = displayAlignmentMap.get(displaySequenceMap.get(str));                        
                        }    
                        try{
                            if(columnFormatMap.get(displaySequenceMap.get(str)) != null && columnFormatMap.get(displaySequenceMap.get(str)).toLowerCase() == 'date'){
                                DateTime dt = DateTime.valueOf(am.columnValue.replace('T',' '));
                                am.columnValue = dt.format('YYYY-MM-dd');
                                colValue = dt.format('YYYY-MM-dd');
                            } 
                            if(columnFormatMap.get(displaySequenceMap.get(str)) != null && columnFormatMap.get(displaySequenceMap.get(str)).toLowerCase() == 'number'){                            
                                
                                integer scaleType=precisionMap.get(displaySequenceMap.get(str))!=null ? integer.valueOf(precisionMap.get(displaySequenceMap.get(str))) : 2;
                               Decimal decimalVal = decimal.ValueOf(am.columnValue).setScale(scaleType);
                               am.columnValue = string.valueOf(decimalVal.format());
                               
                               boolean showTotal = columnTotalMap.get(displaySequenceMap.get(str));
                               if(showTotal!= null && showTotal){
                               	am.isTotal = true;
                               }
                               am.decimalVal=decimalVal;
                              /* Decimal  totalVal= totalCols.get(rowIndex);
                               if(totalVal==null){
                               		totalCols.add(decimalVal);
                               }else{
                               		totalVal = totalVal + decimalVal;
                               		totalCols.set(rowIndex,totalVal);
                               }*/
                               colValue = am.columnValue;
                                
                            } 
                        }catch(exception e){ 
                        //	 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+colValue+' '+e.getMessage()+' '+e.getStackTraceString());
         				//	ApexPages.addMessage(myMsg);
                        	cols.add(colValue);
                            row.columnsList.add(am);
                            continue;
                        }                  
                        row.columnsList.add(am); 
                        cols.add(colValue);
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
            rowIndex++;
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
    public String getDataJsonStr() {
        return Json.serialize(getHighChartData());
    }
    // The actual chart data; needs to be static to be
    // returns table chart data list    
    public List<Data> getChartData() {
        List<Data> data = new List<Data>();
        
        List<Integer> series1 = new List<Integer>();
        List<Integer> series2 = new List<Integer>();
        List<string> categories = new List<string>();
       
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
                    series1.add(dt.data1);
                }
                dt.name = String.ValueOf(r.columns[x]);
                categories.add(dt.name);
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
                    series2.add(dt.data2);
                }
                data.add(dt);
            }
        }
        
        return data;
    }
    
    // The actual chart data; needs to be static to be
    // returns table chart data list    
    public HighChartData getHighChartData() {
        List<Data> data = new List<Data>();
        
        List<Integer> series1Data = new List<Integer>();
        List<Integer> series2Data = new List<Integer>();
        List<string> categories = new List<string>();
       
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+ficColumns[0].Chart_Type__c);
        ApexPages.addMessage(myMsg);       
            
       
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
                    series1Data.add(dt.data1);
                }
                dt.name = String.ValueOf(r.columns[x]);
                categories.add(dt.name);
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
                    series2Data.add(dt.data2);
                }
                data.add(dt);
            }
        }
        HighChartData hData = new HighChartData();
        hData.series = new List<Series>();
        Series series1 = new Series();
        series1.name=ficColumns[0].YAxisLabel__c;
        Series1.data=series1Data;
        
        Series series2 = new Series();
        series2.name=ficColumns[0].Y2_Label__c;
        Series2.data=series2Data;
        
        hData.series.add(series1);
        hData.series.add(series2);
        
        hData.categories=categories;
        
        hData.yAxisLAble=ficColumns[0].YAxisLabel__c;
        hData.xAxisLAble=ficColumns[0].XAxisLabel__c;
        hData.reportName=ficColumns[0].Report_Name__c;
        hData.chartType=ficColumns[0].Chart_Type__c;
        return hData;
    }
    
    
    public class HighChartData {
    	public List<Series> series {get;set;}
        public List<string> categories{get;set;}
        public string yAxisLAble{get;set;} 
        public string xAxisLAble{get;set;}
        public string reportName{get;set;}
        public String chartType{get;set;}
        public List<PlotBand> plotBands{get;set;}
        public String height{get;set;}
    }
    public class PlotBand{
    	public Integer fromVal{get;set;}
    	public Integer to{get;set;}
    	public Integer thickness{get;set;}
    	public string color{get;set;}
    	
    }
    public class Series{
    	public string name{get;set;}
    	public List<Integer> data{get;set;}
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
            paramList.add(new SelectOption('','--Select Value--',true));
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
        public String chartType;
    	public string width{get;set;}
        
        
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
        public String YAxisLabels{get;set;}
        public String chartType;
        public String plotBands{get;set;}
        public String bandColors{get;set;}
        
        Public CombinedClass cClass;
        public ChartData(){}              
        public ChartData(List<Row> rowList,Integer x, Integer y, String xLabel, String ylabel, Integer z, String zlabel,String YAxisLabels,CombinedClass cClass) {
            this.rowList = rowList;
            this.x = x;
            this.y = y;
            this.xLabel = xLabel;
            this.yLabel = ylabel;
            this.z = z;
            this.zLabel = zlabel;
            this.YAxisLabels =YAxisLabels;
            this.cClass = cClass;
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
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
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
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
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
        
        public HighChartData getHighChartValues() {
        	 HighChartData hData =null;
        	try{
            List<ChartData> chartDataList = new List<ChartData>();                                    
            if(rowList == null || rowList.size()==0){
                ChartData cd = new ChartData(); 
                
                cd.name =  'test';       
                cd.xLabel = 'xLabel';
                cd.data1 = 0;
                chartDataList.add(cd);
                return null;
            }
	        List<Integer> series1Data = new List<Integer>();
	        List<Integer> series2Data = new List<Integer>();
	        List<string> categories = new List<string>();
        
            // filling chart data
            for(Row r:rowList){
                ChartData cd = new ChartData(); 
                
                cd.name =  String.ValueOf(r.columns[x]);               
                cd.xLabel = xLabel;
                categories.add(cd.name);
                
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
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
                            ApexPages.addMessage(myMsg);
                            continue;
                        }   
                    }
                    series1Data.add(cd.data1);
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
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
                            ApexPages.addMessage(myMsg);
                            continue;
                        }   
                    }
                    series2Data.add(cd.data2);
                }
                
                        
                chartDataList.add(cd);
            }                      
            hData = new HighChartData();
            string[] seriesName = YAxisLabels.split(',');
            
	        hData.series = new List<Series>();
	        if(chartType=='Spedometer'){
	        	Integer temp = series1Data.get(0);
	        	series1Data.clear();
	        	series2Data.clear();
	        	series1Data.add(temp);
	        }
	        Series series1 = new Series();
	        series1.name=seriesName[0];
	        Series1.data=series1Data;
	        
	        Series series2 = new Series();
	        series2.name=seriesName[1];
	        Series2.data=series2Data; 
	        
	        hData.series.add(series1);
	        hData.series.add(series2);
	        
	        hData.categories=categories;
	        
	        hData.yAxisLAble=yLabel;
	        hData.xAxisLAble=xLabel;
	        hData.reportName= cClass.reportName;
	        hData.chartType = chartType;
	        hData.plotBands = new List<PlotBand>();
	        if(plotBands!=null && bandColors!=null){
		        List<String> lstBands = plotBands.split(',');
		       	List<String> colors = bandColors.split(',');
		       	Integer count=0;
		       	for(string strband:lstBands){
		       		PlotBand band = new PlotBand();
		       		 List<string> fromTo = strband.split('-');
		       		 band.fromVal = Integer.valueOf(fromTo[0]);
		       		 band.to =  Integer.valueOf(fromTo[1]);
		       		 band.color = colors[count];
		       		 band.thickness = 15;
		       		 hData.plotBands.add(band);
		       		 count++;
		       	}
	        }
	        
	         }catch(Exception e){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getStackTraceString());
                            ApexPages.addMessage(myMsg);
                        }   
	        return hData;                        
        }
         public String getDataJsonStr() {
         	if(getHighChartValues()!=null){
         		string jsonstr = Json.serialize(getHighChartValues());
         		jsonstr = jsonstr.replace('fromVal','from');
         		return jsonstr;
         	}else{
         		return '{}';
         		
         	}
   		 }
    
        
    }
    
    //table header column model
    public class headerValueModel{
        public String headerValue{get;set;}
        public string actualHeaderValue{get;set;} // without BR tag between space
        public String width{get;set;}
        public String textAlignment{get;set;}
        public List<string> innerHeaderValues;
        public Integer innerHeaderSize{get{
        	return innerHeaderValues.size();
        }
        set;}
        public Boolean isPivotCol{get;set;}
        public Boolean isPivotResult{get;set;}
        public headerValueModel(){
            width = 'auto';
            textAlignment = 'left';
            innerHeaderValues=new List<string>();
        }
        public void setInnerHeaderValues(List<string> innerHeaderValues){
        	this.innerHeaderValues=innerHeaderValues;
        	this.innerHeaderSize=innerHeaderValues.size();
        }
        public List<string> getInnerHeaderValues(){
        	return this.innerHeaderValues;
        }
    }
    
    //table data column model
    public class alignmentModel{
        public String columnValue{get;set;}
        public decimal decimalVal{get;set;}
        public String textAlignment{get;set;}
        public boolean isTotal;
        public boolean isTotalVal;
        public alignmentModel(){
            textAlignment = 'left';
        }
    } 

}