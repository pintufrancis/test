/*******************************************************************
* File Name : MockHttpResponseTest
* Description : Mock response class for OracleSynchronizationBatch.
* Copyright : CloudSPM
********************************************************************/

@isTest
public class MockHttpResponseTest implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().startsWith('www.oraclefusionInstance.com:443/xmlpserver/services/PublicReportService')){
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><runReportResponse xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"><runReportReturn><reportBytes>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLUdlbmVyYXRlZCBieSBPcmFjbGUgQkkgUHVibGlzaGVyIDExLjEuMS43LjEzMTAxNyAtRGF0YWVuZ2luZSwgZGF0YW1vZGVsOi9DdXN0b20vSW5jZW50aXZlIENvbXBlbnNhdGlvbi9TUE1fR0VUX09SR19JRC54ZG0gLS0+CjxEQVRBX0RTPjxTUkNfT1JHPklDIFBlcmZvcm1hbmNlIFRlc3Q8L1NSQ19PUkc+CjxHXzE+CjxPUkdfTkFNRT5JQyBQZXJmb3JtYW5jZSBUZXN0PC9PUkdfTkFNRT4KPE9SR19JRD4zMDAwMDAwMDA2Nzg0NzNMPC9PUkdfSUQ+CjwvR18xPgo8L0RBVEFfRFM+</reportBytes><reportContentType>text/xml</reportContentType><reportFileID xsi:nil="true"/><reportLocale xsi:nil="true"/></runReportReturn></runReportResponse></soapenv:Body></soapenv:Envelope>');
            res.setStatusCode(200);    
        } else if(req.getEndpoint().startsWith('https://host.com:443/icCnTpTxnMgmtPublicService/TransactionService')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<?xml version=\'1.0\' encoding=\'UTF-8\'?> <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"> <S:Body> <ns5:createIncentiveTransactionStaging> <ns5:incentiveTransactionStaging> <ns6:TransactionId>300000001175314</ns6:TransactionId> </ns5:incentiveTransactionStaging> </ns5:createIncentiveTransactionStaging> </S:Body> </S:Envelope>');    
            res.setStatusCode(200);
        } else if(req.getEndpoint().startsWith('www.oraclefusionInstanceSalesRep.com:443/xmlpserver/services/PublicReportService')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><runReportResponse xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"><runReportReturn><reportBytes>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLUdlbmVyYXRlZCBieSBPcmFjbGUgQkkgUHVibGlzaGVyIDExLjEuMS43LjEzMTAxNyAtRGF0YWVuZ2luZSwgZGF0YW1vZGVsOi9+c3JpbmkucGFyaW1pQGNsb3Vkc3BtLmNvbS9TUE1fR0VUX1BBUlRJQ0lQQU5ULnhkbSAtLT4KPERBVEFfRFM+PFNSQ19FTUFJTD5UZXN0TWdyOUBvcmFjbGUuY29tPC9TUkNfRU1BSUw+CjxHXzE+CjxQQVJUSUNJUEFOVF9JRD4xMjAwMDwvUEFSVElDSVBBTlRfSUQ+CjxQQVJUSUNJUEFOVF9UWVBFPlBBUlRJQ0lQQU5UPC9QQVJUSUNJUEFOVF9UWVBFPgo8UEFSVElDSVBBTlRfRklSU1RfTkFNRT5UZXN0PC9QQVJUSUNJUEFOVF9GSVJTVF9OQU1FPgo8UEFSVElDSVBBTlRfTEFTVF9OQU1FPk1hbmFnZXI5PC9QQVJUSUNJUEFOVF9MQVNUX05BTUU+CjxFTUFJTF9BRERSRVNTPlRlc3RNZ3I5QG9yYWNsZS5jb208L0VNQUlMX0FERFJFU1M+CjxPUkdfSUQ+MzAwMDAwMDAwNjc4NDczPC9PUkdfSUQ+CjwvR18xPgo8L0RBVEFfRFM+</reportBytes><reportContentType>text/xml</reportContentType><reportFileID xsi:nil="true"/><reportLocale xsi:nil="true"/></runReportReturn></runReportResponse></soapenv:Body></soapenv:Envelope>');    
            res.setStatusCode(200);
        }
        
        return res;
    }
}