/*
                Name        :        FCLookupManagerController
                Author      :        CloudSPM
                Date        :        7 jan 2014
                Description :        This  controller Refresh the parameter values .

*/

public class FCLookupManagerController{
    public List<FC_Lookup_Manager__c> fcManagerList{get;set;}
    public List<FC_Lookup_Detail__c> fcDetailList{get;set;}
    public List<FC_Lookup_Detail__c> insertList{get;set;}
    public List<Oracle_Connection__c> oracleConnectionList{get;set;}
    public Map<String,Set<String>> recordsMap{get;set;}
    public Map<String,Integer> columnNameMap{get;set;}
    public String id{get;set;}
    
    public FCLookupManagerController(){        
        fcManagerList  = new List<FC_Lookup_Manager__c>();
        fcDetailList = new List<FC_Lookup_Detail__c>();   
        insertList = new List<FC_Lookup_Detail__c>();   
        recordsMap = new Map<String,Set<String>>();
        columnNameMap = new Map<String,Integer>();
    }
    
    public PageReference fetchValues(){  
        //fetching recor id
        id = ApexPages.CurrentPage().getParameters().get('id');
        //fetching connect user name, password, host and port
        oracleConnectionList = [select Username__c,Port__c,Password__c,Host__c,Service__c from Oracle_Connection__c where Service__c='Fusion Transactional Business Intelligence' and Status__c ='Active'];            
        if(id != null){
            //fetching report path and report name
            fcManagerList = [select id, Lookup_Name__c,Report_Name__c,Report_Path__c from FC_Lookup_Manager__c where id=:id ];            
            //fetching old records
            if(fcManagerList != null && fcManagerList.size()>0){
                fcDetailList = [select id from FC_Lookup_Detail__c where FC_Lookup_Manager__c =: id];
            }            
        }
        
        String soapXml = '';
        recordsMap=new Map<String,Set<String>>();
        columnNameMap = new Map<String,Integer>();
        //fetching new records
        if(oracleConnectionList.size()>0 && oracleConnectionList != null && fcManagerList != null  && fcManagerList.size() > 0){
            soapXml = createSoapXml(oracleConnectionList[0].Username__c,oracleConnectionList[0].Password__c,(''+fcManagerList[0].Report_Path__c+'/'+fcManagerList[0].Report_Name__c));        
            fetchBusinessUnitId(soapXml,oracleConnectionList[0].Host__c,decimal.valueOf(''+oracleConnectionList[0].Port__c));
            //fetchBusinessUnitId(soapXml,'https://cagj-test.bi.us2.oraclecloud.com',decimal.valueOf('443'));
        } 
        
        /*
        List<FC_Lookup_Detail__c> insertList = new List<FC_Lookup_Detail__c>();         
        if(recordsMap != null && recordsMap.size()>0){
            for(String str:recordsMap.keySet()){
                for(String s:recordsMap.get(str)){
                    FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();
                    fcDetail.Column_Name__c = str;
                    fcDetail.Column_Value__c = s;
                    fcDetail.Column_Sequence__c =  columnNameMap.get(str);                   
                    fcDetail.FC_Lookup_Manager__c = id;
                    
                    insertList.add(fcDetail);
                }
            }
        }
        */
        //deleting old records
        if(fcDetailList != null && fcDetailList.size()>0){
            delete fcDetailList;
        }
        
        //inserting new records
        if(insertList != null && insertList.size()>0){
            insert insertList;            
        }
        
        PageReference pg = new PageReference('/'+id);
        return pg.setRedirect(true);
        
    }
    // parsing xml
    private void parse(String toParse) {  
    	system.debug('toParse: '+ toParse);      
        DOM.Document doc = new DOM.Document();  
        try {
            doc.load(toParse);    
            DOM.XMLNode root = doc.getRootElement();     
            getAllRows(root);               
        }catch (System.XMLException e) {  // invalid XML          
             e.getMessage();         
        }
    }
    //getting records rows
    private void getAllRows(DOM.XMLNode node) {
        List<DOM.XMLNode> rowsxmls = node.getChildren();
        Integer j = 0;
        System.debug('rowsxmls ===>'+rowsxmls);
        for(DOM.XMLNode xmlNode:rowsxmls){               
            List<DOM.XMLNode> colsxmls =xmlNode.getChildren();                        
            if(xmlNode.getName()!=null){                
                Integer i=0;                
                for(DOM.XMLNode colxmlNode:colsxmls) {
                    if(colxmlNode.getName()!=null){
                        if(colxmlNode.getText()!=null){
                            System.debug('@@@ colxmlNode.getText()===>'+colxmlNode.getText());
                            if(colxmlNode.getText() != null && colxmlNode.getText().length()<=255){                        
                                FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();
                                fcDetail.Column_Name__c = colxmlNode.getName();
                                fcDetail.Column_Value__c = colxmlNode.getText();
                                fcDetail.Column_Sequence__c =  i;         
                                fcDetail.Row_Number__c = j;          
                                fcDetail.FC_Lookup_Manager__c = id;
                                
                                insertList.add(fcDetail);
                            }
                            /*Set<String>existValues=recordsMap.get(colxmlNode.getName());
                            if(existValues==null)
                                existValues=new Set<String>();
                            if(colxmlNode.getText()!=null)
                                existValues.add(colxmlNode.getText());                                
                                recordsMap.put(colxmlNode.getName(),existValues);
                                if(!columnNameMap.containsKey(colxmlNode.getName())){
                                    columnNameMap.put(colxmlNode.getName(),i);
                                }
                            */
                            i++;
                        }
                    }
                    
                }
                if(colsxmls != null && colsxmls.size()>0){
                    //system.debug('@@@###'+j+' ##@@@ '+xmlNode.getName() );
                    j++;                                    
                }
            }            
        }
        
    }
    public String createSoapXml(String username , String password , String reportPath) {
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
    
    //fetching xml    
    public void fetchBusinessUnitId(String requestXML, String host, Decimal port) {      
        String response = businessIntelligenceReport(requestXML, host, port);
        System.debug('####response '+response );
        if(response != null && response.length()>0){
            String parsestr = response.substring(response.indexof('<reportBytes>')+13,response.indexof('</reportBytes>'));
            System.debug('@@@ parsestr===>'+parsestr );
            //System.debug('@@@@ decoded==>');
            if(!String.isBlank(response)) {
                String decoded = EncodingUtil.base64decode(parsestr) != null ? EncodingUtil.base64decode(parsestr).tostring() : '';
               // String decoded = EncodingUtil.base64decode(parsestr).tostring();
                if(decoded != null && decoded.length()>0){
                     parse(decoded);
                }
               
            }
        }
        
        // parse(decodedReportBytes);
        
       /*if(!String.isBlank(response)) {
            
            String decodedReportBytes;
            Xmlstreamreader reader = new Xmlstreamreader(response);
            
             while(reader.hasNext()) {  
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'reportBytes' == reader.getLocalName()) {
                    reader.next();
                    if(reader.hasText()) {
                        decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString();
                        system.debug('@@@ decodedReportBytes===>'+decodedReportBytes);
                        // prase xml
                        parse(decodedReportBytes);                          
                    }
                }
                reader.next();
            }            
        }*/
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
                    system.debug('my resp: '+ response);
                }
            } else {
                response = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><runReportResponse xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"><runReportReturn><reportBytes>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLUdlbmVyYXRlZCBieSBPcmFjbGUgQkkgUHVibGlzaGVyIDExLjEuMS43LjEzMTAxNyAtRGF0YWVuZ2luZSwgZGF0YW1vZGVsOi9DdXN0b20vSW5jZW50aXZlIENvbXBlbnNhdGlvbi9TUE1fR0VUX09SR19JRC54ZG0gLS0+CjxEQVRBX0RTPjxTUkNfT1JHPklDIFBlcmZvcm1hbmNlIFRlc3Q8L1NSQ19PUkc+CjxHXzE+CjxPUkdfTkFNRT5JQyBQZXJmb3JtYW5jZSBUZXN0PC9PUkdfTkFNRT4KPE9SR19JRD4zMDAwMDAwMDA2Nzg0NzNMPC9PUkdfSUQ+CjwvR18xPgo8L0RBVEFfRFM+</reportBytes><reportContentType>text/xml</reportContentType><reportFileID xsi:nil="true"/><reportLocale xsi:nil="true"/></runReportReturn></runReportResponse></soapenv:Body></soapenv:Envelope>';
            }
        } catch(Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            //System.debug('Incentive Compensation Exception: ' + e);    
        }
        
        return response;
    }
}