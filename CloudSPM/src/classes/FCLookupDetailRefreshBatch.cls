/*******************************************************************
* File Name : FCLookupDetailRefreshBatch
* Description : Batch to Refresh Lookup details.
* Copyright : CloudSPM
********************************************************************/

global class FCLookupDetailRefreshBatch implements Database.Batchable<FC_Lookup_Manager__c>, Database.AllowsCallouts {
	private List<Oracle_Connection__c> oracleConnectionList;
    private String currManagerId;
    private List<FC_Lookup_Detail__c> detailsToInsert;
	
	public FCLookupDetailRefreshBatch() {
		try{
			//fetching connect user name, password, host and port
	        this.oracleConnectionList = [select Username__c,Port__c,Password__c,Host__c,Service__c from Oracle_Connection__c where Service__c='Fusion Transactional Business Intelligence' and Status__c ='Active'];
		} catch(Exception e){
			System.debug('Oracle Connection Query exception'+ e);
		}
	}
	
	global Iterable<FC_Lookup_Manager__c> start(database.batchablecontext BC) {
        return [select id, Lookup_Name__c, Report_Name__c, Report_Path__c from FC_Lookup_Manager__c];
    }
    
    global void execute(database.BatchableContext BC, List<FC_Lookup_Manager__c> scope) {
    	if(this.oracleConnectionList.size()>0 && this.oracleConnectionList != null) {
	    	String soapXml;
	    	List<Id> managersId = new List<Id>();
	    	this.detailsToInsert = new List<FC_Lookup_Detail__c>();
	    	
	    	for(FC_Lookup_Manager__c currManager: scope) {
	    		soapXml = '';
	        	this.currManagerId = currManager.Id;
	        	managersId.add(currManager.Id);		
	        	
        	 	//fetching new records
            	soapXml = createSoapXml(oracleConnectionList[0].Username__c, oracleConnectionList[0].Password__c, (currManager.Report_Path__c+'/'+currManager.Report_Name__c) );        
	            fetchBusinessUnitId(soapXml, oracleConnectionList[0].Host__c, decimal.valueOf(''+oracleConnectionList[0].Port__c));
	            
	    	}
	    	
	    	//fetching old records
	    	Map<Id,FC_Lookup_Detail__c> fcDetailMap = new Map<Id, FC_Lookup_Detail__c>([SELECT Id FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c =:managersId]);
	    	
	    	//deleting old records
	        if(fcDetailMap.values() != null && fcDetailMap.values().size()>0) {
	            delete fcDetailMap.values();
	        }
	        
	        //inserting new records
	        if(detailsToInsert != null && detailsToInsert.size()>0) {
	            insert detailsToInsert;            
	        }
    	}
    	
    }
    
    global void finish(Database.BatchableContext BC) {
    	
    }
    
    /*
    *parsing xml
    */
    private void parse(String toParse) {        
        DOM.Document doc = new DOM.Document();  
        try {
            doc.load(toParse);    
            DOM.XMLNode root = doc.getRootElement();     
            getAllRows(root);               
        } catch (System.XMLException e) {  // invalid XML          
             e.getMessage();         
        }
    }
    
    /*
    *getting records rows
    */
    private void getAllRows(DOM.XMLNode node) {
        List<DOM.XMLNode> rowsxmls = node.getChildren();
        Integer j = 0;
        for(DOM.XMLNode xmlNode:rowsxmls){               
            List<DOM.XMLNode> colsxmls =xmlNode.getChildren();                        
            if(xmlNode.getName()!=null){                
                Integer i=0;                
                for(DOM.XMLNode colxmlNode:colsxmls) {
                    if(colxmlNode.getName()!=null){
                        if(colxmlNode.getText()!=null){
                            if(colxmlNode.getText() != null && colxmlNode.getText().length()<=255){                        
                                FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();
                                fcDetail.Column_Name__c = colxmlNode.getName();
                                fcDetail.Column_Value__c = colxmlNode.getText();
                                fcDetail.Column_Sequence__c =  i;         
                                fcDetail.Row_Number__c = j;          
                                fcDetail.FC_Lookup_Manager__c = this.currManagerId;
                                
                                detailsToInsert.add(fcDetail);
                            }
                            i++;
                        }
                    }
                    
                }
                if(colsxmls != null && colsxmls.size()>0) {
                    j++;                                    
                }
            }            
        }
    }
    
    /*
    *creating xml request
    */
    private String createSoapXml(String username , String password , String reportPath) {
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
    
    /*
    *fetching xml
    */
    private void fetchBusinessUnitId(String requestXML, String host, Decimal port) {      
        String response = businessIntelligenceReport(requestXML, host, port);
        if(response != null && response.length()>0){
            String parsestr = response.substring(response.indexof('<reportBytes>')+13,response.indexof('</reportBytes>'));
            if(!String.isBlank(response)) {
                String decoded = EncodingUtil.base64decode(parsestr) != null ? EncodingUtil.base64decode(parsestr).tostring() : '';
                if(decoded != null && decoded.length()>0){
                     parse(decoded);
                }
               
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

}