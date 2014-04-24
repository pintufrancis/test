/*******************************************************************
* File Name : OracleWebservices
* Description : Library class for OracleWebservices.
* Copyright : CloudSPM
********************************************************************/

public with sharing class OracleWebservices { 
    public static boolean isRunningTest = false; 
    
    /*
    *Webservice to push data to Oracle
    */
    public static String incentiveCompensation(String requestXML, String host, Decimal port) {
        Integer ContentLength = 0;
        String response;
         
        ContentLength = requestXML.length();
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse(); 

        req.setMethod('POST');
        req.setEndPoint(host +':'+ port +'/icCnTpTxnMgmtPublicService/TransactionService'); 
        req.setHeader('Content-type','text/xml'); 
        req.setHeader('Content-Length',ContentLength.format());
        req.setHeader('SoapAction','http://xmlns.oracle.com/apps/incentiveCompensation/cn/transactionProcessing/transactionManagement/publicService/createIncentiveTransactionStaging');
        req.setBody(requestXML);
        
        try {
            if(!isRunningTest){
                res = h.send(req);
                system.debug('resp:' +res.getBody());
                if(res.getStatusCode() == 200) {
                    response = res.getBody();
                }
            } else {
                response = '<TransactionId>300000001175314</TransactionId>';
            }
        } catch(Exception e) {
            System.debug('Incentive Compensation Exception: ' + e);    
        }
        return response;
    }
    
    /*
    *Webservice to run report and get data from Oracle
    */
    public static String businessIntelligenceReport(String requestXML, String host, Decimal port) {
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
            if(!isRunningTest){
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
    
    /*
    *Function to compose xml request to run businessIntelligenceReport
    */
   
    public static String composeBIRequest(String username , String password , String reportPath, String filter) {
        String response;
        
        response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">'+
                  '<soapenv:Header/>'+
                  '<soapenv:Body>'+
                    '<pub:runReport>'+
                      '<pub:userID>'+ username +'</pub:userID>'+
                      '<pub:password>'+ password +'</pub:password>'+
                      '<pub:reportRequest>'+
                        '<pub:reportAbsolutePath>'+ reportPath+'.xdo</pub:reportAbsolutePath>';
                        
        if(!String.isBlank(filter)) {
            response += '<pub:parameterNameValues>'+ filter +'</pub:parameterNameValues>';
        }                
                                       
        response +=    '</pub:reportRequest>'+
                    '</pub:runReport>'+
                  '</soapenv:Body>'+
                '</soapenv:Envelope>';  
        return response;  
    }
    
    
    /*
    *Function to convert binary data to xml
    */
    public static String decodeBinaryResponse(String binaryData) {
        String decodedReportBytes;
        Xmlstreamreader reader = new Xmlstreamreader(binaryData);
        while(reader.hasNext()) {  
            if (reader.getEventType() == XmlTag.START_ELEMENT && 'reportBytes' == reader.getLocalName()) {
                reader.next();
                if(reader.hasText()) {
                    decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString();
                    break;
                }
            }
            reader.next();
        }
        
        return decodedReportBytes;
    }
    
    /*
    *Function to fetch business unit Id from Oracle
    */
    @Future(callout=true)
    public static void fetchBusinessUnitId(String requestXML, String host, Decimal port, String recordId) {
        Salesforce_Oracle_Maps__c salesOracleMap = [SELECT Id, Business_Unit_Name__c FROM Salesforce_Oracle_Maps__c  WHERE Id =: recordId];
        salesOracleMap.Business_Unit_Id__c = 'Not Available';
        //Calling webservice and getting report response
        String response = businessIntelligenceReport(requestXML, host, port);
        
        if(!String.isBlank(response)) {
            salesOracleMap.Business_Unit_Id__c = 'Not Found';
            String decodedReportBytes;
            
            //Read report data from Oracle response
            Xmlstreamreader reader = new Xmlstreamreader(response);
            while(reader.hasNext()) {  
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'reportBytes' == reader.getLocalName()) {
                    reader.next();
                    if(reader.hasText()) {
                        decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString();
                        break;                          
                    }
                }
                reader.next();
            }
            //Read Business Unit Id from report data
            if(!String.isBlank(decodedReportBytes)) {
                reader = new Xmlstreamreader(decodedReportBytes);
                while(reader.hasNext()) {  
                    if (reader.getEventType() == XmlTag.START_ELEMENT && 'ORG_ID' == reader.getLocalName()) {
                        reader.next();
                        if(reader.hasText()) {
                            salesOracleMap.Business_Unit_Id__c = reader.getText(); 
                            break;                          
                        }
                    }
                    reader.next();
                }
            }
            
        }
            
        Database.update(salesOracleMap, false);
    }
       
    /*
    *Function to fetch participant Id from Oracle
    */
    public static String fetchParticipantId(String requestXML, String host, Decimal port) {
        String returnValue;
        
        //Calling webservice and getting report response
        String response = businessIntelligenceReport(requestXML, host, port);
        
        if(!String.isBlank(response)) {
            String decodedReportBytes;
            
            //Read report data from Oracle response
            Xmlstreamreader reader = new Xmlstreamreader(response);
            while(reader.hasNext()) {  
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'reportBytes' == reader.getLocalName()) {
                    reader.next();
                    if(reader.hasText()) {
                        decodedReportBytes = EncodingUtil.base64decode(reader.getText()).toString(); 
                        break;                          
                    }
                }
                reader.next();
            }
            
            //Read Participant Id from report data
            if(!String.isBlank(decodedReportBytes)) {
                reader = new Xmlstreamreader(decodedReportBytes);
                while(reader.hasNext()) {  
                    if (reader.getEventType() == XmlTag.START_ELEMENT && 'PARTICIPANT_ID' == reader.getLocalName()) {
                        reader.next();
                        if(reader.hasText()) {
                            returnValue = reader.getText(); 
                            break;                          
                        }
                    }
                    reader.next();
                }
            }
        } 
        return returnValue;
    }
}