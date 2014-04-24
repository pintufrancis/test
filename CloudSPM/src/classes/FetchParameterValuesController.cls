/*
                Name        :        FetchParameterValuesController
                Author      :        
                Date        :        6 jan 2014
                Description :        This  controller Refresh the parameter values .

*/

public class FetchParameterValuesController{
    public string sessionid{get; set;}
    public String reportName{get;set;}
    public String parameter{get;set;}
    public List<Row> rowsxCompleteData{get;set;}
    public List<Oracle_Connection__c> oracleConnectionList{get;set;}
    public List<FICReportsConfiguration__c> ficColumns{get;set;} 
    public string reportOutput{get; set;}
    public List<Parameter_Values__c> parameterValueList{get;set;}
    public String response{get;set;}
    public List<ParameterModel> modelList{get;set;}
    private Map<String,Set<String>>recordsMap;
    
    public FetchParameterValuesController(){
        modelList=new List<ParameterModel>();
        oracleConnectionList = [select Username__c,Password__c,Host__c,Service__c from Oracle_Connection__c where Service__c='Fusion Transactional Business Intelligence' and Status__c ='Active'];
        //ficColumns = new List<FICReportsConfiguration__c>(); 
        //ficColumns = [select id,X2nd_Axis__c,X2ndXAxis_Label__c,(select id,Column_Name__c,Column_Format__c,Column_Sequence__c,Column_Width__c,Display__c,Display_Sequence__c,FIC_Reports_Configuration__c from ColumnConfigurations__r where Display__c = true ORDER BY Display_Sequence__c ASC),(select id,Name,Label__c from  Parameters__r),Report_Name__c,XAxis__c,YAxis__c,XAxisLabel__c,YAxisLabel__c,Report_Path__c,Report_Columns__c from FICReportsConfiguration__c where Report_Name__c ='SPM_GET_PARTICIPANT'  limit 1];
        //System.debug('###oracleConnectionList '+oracleConnectionList );
        parameterValueList=new List<Parameter_Values__c>();
    }
    public void callServices(){   
        ///Custom/SFDC/Reports/SPM_GET_PARTICIPANT 
        //String soapXml = createSoapXml('ed.kelly','AWd34985',reportName,'InFusion Corporation BU');
        modelList=new List<ParameterModel>();
        System.debug('####call');
        System.debug('#### '+reportName);
        String soapXml = '';
        if(oracleConnectionList.size()>0 && reportName != null){
            soapXml = createSoapXml(oracleConnectionList[0].Username__c,oracleConnectionList[0].Password__c,reportName.trim());
        
        
            //fetchBusinessUnitId(soapXml,'https://fap0912-bi.oracleads.com',decimal.valueOf('443'),'a0Mm000000002Od');
            //System.debug('####soapXml  '+soapXml);
            fetchBusinessUnitId(soapXml,'https://cagj-test.bi.us2.oraclecloud.com',decimal.valueOf('443'),'a0Mm000000002Od');
        }
        
    }
    public void fetchBusinessUnitId(String requestXML, String host, Decimal port, String recordId) {
       // Salesforce_Oracle_Maps__c salesOracleMap = [SELECT Id, Business_Unit_Name__c FROM Salesforce_Oracle_Maps__c  WHERE Id =: recordId];
      //  salesOracleMap.Business_Unit_Id__c = 'Not Available';
        //Calling webservice and getting report response
        String response = businessIntelligenceReport(requestXML, host, port);
        System.debug('####response '+response );
        if(!String.isBlank(response)) {
            //salesOracleMap.Business_Unit_Id__c = 'Not Found';
            String decodedReportBytes;
            
            //Read report data from Oracle response
            Xmlstreamreader reader = new Xmlstreamreader(response);
            /*
            while(reader.hasNext()) {  
                        
                reader.next();
                    if(reader.hasText()) {
                        //decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString();
                        system.debug('#####decodedReportBytes '+reader.getText());
                        //parse(decodedReportBytes);
                        
                                            
                    }        
              
                reader.next();
            }*/
             while(reader.hasNext()) {  
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'reportBytes' == reader.getLocalName()) {
                    reader.next();
                    if(reader.hasText()) {
                        decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString();
                        System.debug('####decodedReportBytes '+decodedReportBytes );
                        //break;
                        parse(decodedReportBytes);                          
                    }
                }
                reader.next();
            }
            if(recordsMap!=null && recordsMap.size()>0){
                for(String parameterName : recordsMap.keySet()){
                    ParameterModel model =new ParameterModel();
                    model.rec.Parameter_Name__c=parameterName;
                    model.rec.Possible_Values__c ='';
                    for(String parameterValue : recordsMap.get(parameterName)){
                        model.rec.Possible_Values__c += parameterValue+',';
                    }
                    model.rec.Possible_Values__c=model.rec.Possible_Values__c.subString(0,model.rec.Possible_Values__c.length()-1);
                    modelList.add(model);
                }
            }
          
        }
    }
    public String createSoapXml(String username , String password , String reportPath) {
        System.debug('####call createSoapXml');
        return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">'+
                  '<soapenv:Header/>'+
                  '<soapenv:Body>'+
                    '<pub:runReport>'+
                      '<pub:userID>'+ username +'</pub:userID>'+
                      '<pub:password>'+ password +'</pub:password>'+
                      '<pub:reportRequest>'+
                        '<pub:reportAbsolutePath>'+ reportPath+'.xdo</pub:reportAbsolutePath>'+                        
                      '</pub:reportRequest>'+
                    '</pub:runReport>'+
                  '</soapenv:Body>'+
                '</soapenv:Envelope>';

    }
    public void saveRecords(){
        try{
            List<Parameter_Values__c> records=new List<Parameter_Values__c>();
            Set<String>existParametersName=new Set<String>();
            for(ParameterModel model :modelList){
                if(model.check){
                    existParametersName.add(model.rec.Parameter_Name__c);
                    //records.add(model.rec);
                }
            }
            Map<String,Parameter_Values__c>existRecordsMap=new Map<String,Parameter_Values__c>();
            List<Parameter_Values__c>existRecirdsList=[select id,Parameter_Name__c,Possible_Values__c from Parameter_Values__c where Parameter_Name__c in : existParametersName];
            for(Parameter_Values__c parameterObj : existRecirdsList){
                existRecordsMap.put(parameterObj.Parameter_Name__c,parameterObj);
            }
            for(ParameterModel model :modelList){
                if(model.check){
                    Parameter_Values__c newRec;
                    if(existRecordsMap.containsKey(model.rec.Parameter_Name__c)){
                        newRec=existRecordsMap.get(model.rec.Parameter_Name__c);
                        newRec.Possible_Values__c =model.rec.Possible_Values__c;
                    }else{
                        newRec=model.rec;
                    }
                    records.add(newRec);
                }
            }
            if(records.size()>0){
                upsert records;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Records has been saved successfully'));
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }
    /*public void executeReport(){
        OracleBiWebservicesV7.SAWSessionServiceSoap service = new OracleBiWebservicesV7.SAWSessionServiceSoap();
        if (!Test.isRunningTest())
        {
            if(oracleConnectionList.size()>0){
                sessionid = service.logon(oracleConnectionList[0].Username__c, oracleConnectionList[0].Password__c);            
            }
            //sessionid = service.logon(OracleWebservices__c.getValues('OracleWebservice').User_Name__c, OracleWebservices__c.getValues('OracleWebservice').Password__c);
        }
        try{  
        OracleBiWebservicesV7Xml.XmlViewServiceSoap xmlService = new OracleBiWebservicesV7Xml.XmlViewServiceSoap();
        OracleBiWebservicesV7Xml.ReportRef report = new OracleBiWebservicesV7Xml.ReportRef();
        report.reportPath ='/Custom/SFDC/Reports/SPM_GET_ORG_ID';
        //System.debug('###ficColumns'+ficColumns);
        
        OracleBiWebservicesV7Xml.XMLQueryExecutionOptions executeOption = new OracleBiWebservicesV7Xml.XMLQueryExecutionOptions();
        OracleBiWebservicesV7Xml.ReportParams reportParams = new OracleBiWebservicesV7Xml.ReportParams();
        
                  
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
        
     }*/
     private void parse(String toParse) {
      recordsMap=new Map<String,Set<String>>();
      DOM.Document doc = new DOM.Document(); 
      system.debug('@@@@1'+toParse);   
      try {
        doc.load(toParse);    
        DOM.XMLNode root = doc.getRootElement();           
        system.debug('@@@@'+root);
        getAllRows(root);               
      } catch (System.XMLException e) {  // invalid XML          
         system.debug('@@@@ error '+e.getMessage());
         e.getMessage();         
      }
      
     }
     private void getAllRows(DOM.XMLNode node) {
        //system.debug(' root XML NODE column - '+node.getName());
        
        
        //rowsxCompleteData = new List<Row>();
        
        List<DOM.XMLNode> rowsxmls =    node.getChildren();
        //system.debug('@@@@###'+rowsxmls);
        for(DOM.XMLNode xmlNode:rowsxmls) {
            //Row row = new Row();
            List<DOM.XMLNode> colsxmls =xmlNode.getChildren();
            //system.debug(' ROW XML NODE column - '+xmlNode.getName());
            if(xmlNode.getName()!=null){
                //List<string> cols = new List<string>();
                //List<string> chartCols = new List<string>();
                for(DOM.XMLNode colxmlNode:colsxmls) {
                    //chartCols.add(colxmlNode.getText());
                    if(colxmlNode.getName()!=null){
                        Set<String>existValues=recordsMap.get(colxmlNode.getName());
                        if(existValues==null)
                            existValues=new Set<String>();
                        if(colxmlNode.getText()!=null)
                            existValues.add(colxmlNode.getText());
                        recordsMap.put(colxmlNode.getName(),existValues);
                    }
                
                    /*
                    
                    if(colxmlNode.getName()!=null){
                        system.debug(' XML NODE column!!!! - '+colxmlNode.getName());
                        system.debug(' XML NODE column - '+colxmlNode.getText());   
                        //system.debug('#$#$  '+colxmlNode.getName().removeStartIgnoreCase('Column'));                     
                        chartCols.add(colxmlNode.getText());
                        
                       
                    }
                    */
                }
                //row.columns = chartCols;                
                //rowsxCompleteData.add(row);
              
                
                
            }
            
        }
        
    }
     /*
    *Webservice to run report and get data from Oracle
    */
    private String businessIntelligenceReport(String requestXML, String host, Decimal port) {
        Integer ContentLength = 0;
        String response;
        
        ContentLength = requestXML.length();
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('POST');
        req.setEndPoint(host +':'+ port +'/xmlpserver/services/PublicReportService'); 
        req.setHeader('Content-type','text/xml'); 
        req.setHeader('Content-Length',ContentLength.format());
        req.setHeader('SoapAction','https://bi-aufsn4x0dha.oracleoutsourcing.com:443/xmlpserver/services/PublicReportService/runReport');
        req.setBody(requestXML);
        
        res.setHeader('Content-type','text/xml');
        
        try {
            if(!test.isRunningTest()){
                res = h.send(req);
                if(res.getStatusCode() == 200) {
                    response = res.getBody();
                }
            } else {
                response = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><runReportResponse xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"><runReportReturn><reportBytes>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLUdlbmVyYXRlZCBieSBPcmFjbGUgQkkgUHVibGlzaGVyIDExLjEuMS43LjEzMTAxNyAtRGF0YWVuZ2luZSwgZGF0YW1vZGVsOi9DdXN0b20vSW5jZW50aXZlIENvbXBlbnNhdGlvbi9TUE1fR0VUX09SR19JRC54ZG0gLS0+CjxEQVRBX0RTPjxTUkNfT1JHPklDIFBlcmZvcm1hbmNlIFRlc3Q8L1NSQ19PUkc+CjxHXzE+CjxPUkdfTkFNRT5JQyBQZXJmb3JtYW5jZSBUZXN0PC9PUkdfTkFNRT4KPE9SR19JRD4zMDAwMDAwMDA2Nzg0NzNMPC9PUkdfSUQ+CjwvR18xPgo8L0RBVEFfRFM+</reportBytes><reportContentType>text/xml</reportContentType><reportFileID xsi:nil="true"/><reportLocale xsi:nil="true"/></runReportReturn></runReportResponse></soapenv:Body></soapenv:Envelope>';
            }
        } catch(Exception e) {
            System.debug('Incentive Compensation Exception: ' + e);    
        }
        
        return response;
    }
     class Row{
        public List<string> columns{get; set;}
     }
     public class ParameterModel{
         public boolean check{get;set;}
         public Parameter_Values__c rec{get;set;}
         public ParameterModel(){
            rec = new Parameter_Values__c();
            check=false;
         }
     }
}