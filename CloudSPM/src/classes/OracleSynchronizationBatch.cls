/*******************************************************************
* File Name : OracleSynchronizationBatch
* Description : Batch to manage Oracle synchronization batch process.
* Copyright : CloudSPM
********************************************************************/
 
global class OracleSynchronizationBatch implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts {
    private String query;  
    private String sfObjectName;
    private String oracleRespLocation;
    private String businessUnitId;
    private sObject currObject;  
    private Oracle_Connection__c connectionIC;
    private Oracle_Connection__c connectionBI;
    private List<Salesforce_Oracle_Field_Mapping__c> fieldMappingList;
    private Map<String, String> errorLog;
    private set<String> adminGroupMembers;
    
    public Set<String> lookupNameIds{get;set;}
    public Set<String> lookupInputColumn{get;set;}
    public Set<String> lookupOutputColumn{get;set;}
    public Set<String> lookupColumnValue{get;set;}
    public Set<Integer> rowSet{get;set;}
    public Map<String,Integer> FC_lookup_Map{get;set;}
    public Map<String,String> fcDetailMap{get;set;}
    
    public OracleSynchronizationBatch(Oracle_Connection__c connectionICData, Oracle_Connection__c connectionBIData, String objectName, String sfQuery, List<Salesforce_Oracle_Field_Mapping__c> mappingList, String businessUnit, String respLocation) {
        this.connectionIC = connectionICData;
        this.connectionBI = connectionBIData;
        this.sfObjectName = objectName;
        this.query = sfQuery;
        this.fieldMappingList = mappingList;   
        this.businessUnitId = businessUnit;
        this.oracleRespLocation = respLocation;
        this.errorLog = new Map<String, String>();
       
        
        //Setting users in Oracle Admin group
        this.adminGroupMembers = new set<String>();
        for(GroupMember member : [select UserOrGroupId from GroupMember where GroupId IN(select Id from Group where DeveloperName='Oracle_Admin_Group')]) {
            if(!String.isBlank(member.UserOrGroupId)) {
                this.adminGroupMembers.add(member.UserOrGroupId);
            }
        }
        
        
        
        
    }
    
    global Iterable<sObject> start(database.batchablecontext BC) {
        return Database.query(this.query);
    }
    
    global void execute(database.BatchableContext BC, List<sObject> scope) {
        String createTime, expireTime, xmlTemplate, response, value;
        
        for(sObject obj : scope) {
            this.currObject = obj;  
        }
        
        System.debug('@@@ this.currObject==>'+this.currObject);
        
        
        lookupNameIds = new Set<String>();
        lookupInputColumn = new Set<String>();
        lookupOutputColumn = new Set<String>();
        lookupColumnValue = new Set<String>();
        FC_Lookup_Map = new Map<String,Integer>();
        fcDetailMap = new Map<String,String>();
        rowSet = new Set<Integer>();
       System.debug('@@@ fieldMappingList==>'+fieldMappingList );
        for(Salesforce_Oracle_Field_Mapping__c ofMap:fieldMappingList ){
            if(!ofMap.Oracle_Field_Name__r.Manual_Entry__c && ofMap.Salesforce_Object_Api_Name__c != 'null') {
                String value1 = '';
                //System.debug('@@@ this.currObject===>'+this.currObject);
                System.debug('@@@ ofMap.Salesforce_Object_Api_Name__c==>'+ofMap.Salesforce_Object_Api_Name__c);
                
                //System.debug('@@@ this.currObject.getSObject(ofMap.Salesforce_Object_Api_Name__c)===>'+this.currObject.getSObject(ofMap.Salesforce_Object_Api_Name__c));
                if(ofMap.Salesforce_Object_Api_Name__c == sfObjectName && this.currObject != null) {
                    value1 = ''+this.currObject.get(ofMap.Salesforce_Field_Api_Name__c);
                } else if(currObject != null && ofMap.Salesforce_Object_Api_Name__c != null && !ofMap.Salesforce_Object_Api_Name__c.contains('.') && this.currObject.getSObject(ofMap.Salesforce_Object_Api_Name__c) != null){                      
                            value1 = ''+this.currObject.getSObject(ofMap.Salesforce_Object_Api_Name__c).get(ofMap.Salesforce_Field_Api_Name__c);                       
                }else{
                    List<String> strlst = ofMap.Salesforce_Fields_Relationship__c.split('###');
                    if(this.currObject.getSObject(strlst[0]) != null && this.currObject.getSObject(strlst[0]).getSObject(strlst[1]) != null){
                        if(strLst.size() == 2){
                            if(this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).get(ofMap.Salesforce_Field_Api_Name__c) != null){
                                value1 = ''+this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).get(ofMap.Salesforce_Field_Api_Name__c);         
                            }
                        }else if(strLst.size() == 3){
                            if(this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]) != null && this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]).get(ofMap.Salesforce_Field_Api_Name__c) != null){        
                                value1 = ''+this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]).get(ofMap.Salesforce_Field_Api_Name__c);         
                            }
                        }
                    }
                } 
                if(ofMap.Lookup_Name__c != null){
                    lookupNameIds.add(ofMap.Lookup_Name__c);                                  
                }
                if(ofMap.Lookup_Input_Column__c != null){
                    lookupInputColumn.add(ofMap.Lookup_Input_Column__c);                                
                }
                if(ofMap.Lookup_Output_Column__c != null){
                    lookupOutputColumn.add(ofMap.Lookup_Output_Column__c);      
                }
                if(value1 != null){
                    lookupColumnValue.add(value1);
                }
            }
        }
        system.debug('@@@###'+lookupNameIds);
        system.debug('@@@###'+lookupInputColumn);
        system.debug('@@@###'+lookupOutputColumn);
        system.debug('@@@###'+lookupColumnValue);
        //searching Record of Lookup Column in FC Lookup Detail and fill Map with Row Number
        for(FC_Lookup_Detail__c fld:[select id,Column_Name__c,Column_Value__c,Row_Number__c,FC_Lookup_Manager__c from FC_Lookup_Detail__c where Column_Name__c in:lookupInputColumn and Column_Value__c in:lookupColumnValue and FC_Lookup_Manager__c in:lookupNameIds]){       
                String st1 = fld.FC_Lookup_Manager__c+String.ValueOf(fld.Column_Name__c).toLowerCase()+String.ValueOf(fld.Column_Value__c).toLowerCase();                       
                FC_Lookup_Map.put(st1,Integer.ValueOf(fld.Row_Number__c));            
                rowSet.add(Integer.ValueOf(fld.Row_Number__c));
                
        }
        
        for(FC_Lookup_Detail__c fld:[select FC_Lookup_Manager__c,Column_Name__c,Column_Value__c,Row_Number__c from FC_Lookup_Detail__c where  Row_Number__c in:rowSet AND Column_Name__c in: lookupOutputColumn]){
            String key = fld.FC_Lookup_Manager__c+fld.Column_Name__c.toLowerCase()+fld.Row_Number__c;
            fcDetailMap.put(key,fld.Column_Value__c);
        } 
        system.debug('@@@###'+FC_Lookup_Map);
        system.debug('@@@###'+fcDetailMap);
        
        this.errorLog.put(''+this.currObject.get('Id'), ''+this.currObject.get('Id'));
        
        createTime = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        expireTime = datetime.now().addDays(1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        xmlTemplate = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>'+
                    '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">'+
                    '<S:Header>'+
                    '<wsa:To xmlns:wsa="http://www.w3.org/2005/08/addressing">'+ this.connectionIC.Host__c +':'+ this.connectionIC.Port__c +'/icCnTpTxnMgmtPublicService/TransactionService</wsa:To>'+
                    '<wsa:Action xmlns:wsa="http://www.w3.org/2005/08/addressing">http://xmlns.oracle.com/apps/incentiveCompensation/cn/transactionProcessing/transactionManagement/publicService/createIncentiveTransactionStaging</wsa:Action>'+
                    '<ReplyTo xmlns="http://www.w3.org/2005/08/addressing">'+
                      '<Address>http://www.w3.org/2005/08/addressing/anonymous</Address>'+
                    '</ReplyTo>'+
                    '<FaultTo xmlns="http://www.w3.org/2005/08/addressing">'+
                      '<Address>http://www.w3.org/2005/08/addressing/anonymous</Address>'+
                    '</FaultTo>'+
                    '<wsa:MessageID xmlns:wsa="http://www.w3.org/2005/08/addressing">'+'uuid:'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)).left(8) +
                                                                                            '-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)).left(4) +
                                                                                            '-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)).left(4) +
                                                                                            '-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)).left(4) +
                                                                                            '-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)).left(12) +
                    '</wsa:MessageID>'+
                    '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" S:mustUnderstand="1">'+
                      '<wsse:UsernameToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="UsernameToken-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)) +'">'+
                        '<wsse:Username>'+ this.connectionIC.Username__c +'</wsse:Username>'+
                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ this.connectionIC.Password__c +'</wsse:Password>'+
                        '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+ EncodingUtil.base64Encode(Crypto.generateAesKey(128)) +'</wsse:Nonce>'+
                        '<wsu:Created>'+ createTime +'</wsu:Created>'+
                      '</wsse:UsernameToken>'+
                      '<wsu:Timestamp xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="Timestamp-'+ EncodingUtil.convertToHex(Crypto.generateAesKey(128)) +'">'+
                        '<wsu:Created>'+ createTime +'</wsu:Created>'+
                        '<wsu:Expires>'+ expireTime +'</wsu:Expires>'+
                      '</wsu:Timestamp>'+
                    '</wsse:Security>'+
                  '</S:Header>'+
                  '<S:Body>'+
                    '<ns5:createIncentiveTransactionStaging xmlns:ns2="commonj.sdo" xmlns:ns3="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns4="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns5="http://xmlns.oracle.com/apps/incentiveCompensation/cn/transactionProcessing/transactionManagement/publicService/types/" xmlns:ns6="http://xmlns.oracle.com/apps/incentiveCompensation/cn/transactionProcessing/transactionManagement/publicService/" xmlns:ns7="http://xmlns.oracle.com/oracleas/schema/oracle-fault-11_0">'+
                      '<ns5:incentiveTransactionStaging>';
                        
                xmlTemplate += '<ns6:BusinessUnitId>'+ this.businessUnitId +'</ns6:BusinessUnitId>';  
                                 
                for(Salesforce_Oracle_Field_Mapping__c mapping: this.fieldMappingList) {
                    if(!mapping.Oracle_Field_Name__r.Manual_Entry__c && mapping.Salesforce_Object_Api_Name__c != 'null') {
                        value = '';
                        
                        
                        if(mapping.Salesforce_Object_Api_Name__c == sfObjectName && this.currObject != null) {
                            value = ''+this.currObject.get(mapping.Salesforce_Field_Api_Name__c);
                        }else if(currObject != null && mapping.Salesforce_Object_Api_Name__c != null && !mapping.Salesforce_Object_Api_Name__c.contains('.') && this.currObject.getSObject(mapping.Salesforce_Object_Api_Name__c) != null){
                                value = ''+this.currObject.getSObject(mapping.Salesforce_Object_Api_Name__c).get(mapping.Salesforce_Field_Api_Name__c);
                        }else{
                            List<String> strlst = mapping.Salesforce_Fields_Relationship__c.split('###');
                            if(this.currObject.getSObject(strlst[0]) != null && this.currObject.getSObject(strlst[0]).getSObject(strlst[1]) != null){
                                if(strLst.size() == 2){
                                    if(this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).get(mapping.Salesforce_Field_Api_Name__c) != null){
                                        value = ''+this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).get(mapping.Salesforce_Field_Api_Name__c);         
                                    }
                                }else if(strLst.size() == 3){
                                    if(this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]) != null && this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]).get(mapping.Salesforce_Field_Api_Name__c) != null){        
                                        value = ''+this.currObject.getSObject(strlst[0]).getSObject(strlst[1]).getSObject(strlst[2]).get(mapping.Salesforce_Field_Api_Name__c);         
                                    }
                                }
                            }
                        } 
                        
                        
                        if(mapping.Lookup_Name__c != null && mapping.Lookup_Input_Column__c!= null){                                               
                            String str = mapping.Lookup_Name__c+mapping.Lookup_Input_Column__c.toLowerCase()+value; 
                            if(FC_Lookup_Map.get(str) != null){
                                Integer rowNumber = FC_Lookup_Map.get(str);
                                String key = mapping.Lookup_Name__c+mapping.Lookup_Output_Column__c.toLowerCase()+rowNumber;
                                if(fcDetailMap.get(key) != null){
                                    value = fcDetailMap.get(key);
                                }
                            }
                        }
                        
                        if(mapping.Oracle_Field_Name__r.Datatype__c == 'DATE') {
                            value = Datetime.valueOf(value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                        }                        
                        
                        xmlTemplate += '<ns6:'+ mapping.Oracle_Field_Name__r.Name +'>'+ value +'</ns6:'+ mapping.Oracle_Field_Name__r.Name +'>';               
                        
                    } else {                           
                        xmlTemplate += '<ns6:'+ mapping.Oracle_Field_Name__r.Name +'>'+ mapping.Salesforce_Field_Api_Name__c +'</ns6:'+ mapping.Oracle_Field_Name__r.Name +'>';  
                    }                    
                }
                xmlTemplate += '</ns5:incentiveTransactionStaging>'+'</ns5:createIncentiveTransactionStaging>'+'</S:Body>'+'</S:Envelope>';
                        
        response = OracleWebservices.incentiveCompensation(xmlTemplate, this.connectionIC.Host__c, this.connectionIC.Port__c);
        system.debug('@@@@ xmlTemplate '+xmlTemplate );
        system.debug('@@@@ respons '+response );
        if(!String.isBlank(response)) {
            Xmlstreamreader reader = new Xmlstreamreader(response); 
            while(reader.hasNext()) {  
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransactionId') {
                    reader.next();
                    if(reader.hasText()) {
                        //Setting and updating Transaction Id from Oracle to Salesforce
                        this.currObject.put(this.oracleRespLocation, reader.getText());
                        Database.update(this.currObject, false);
                        system.debug('@@@@ transaction id '+reader.getText());
                        this.errorLog.remove(''+(this.currObject).get('Id'));
                    }
                }
                reader.next();
            } 
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Salesforce - Oracle Synchronization ' + a.Status);
        String bodyText = 'The Salesforce - Oracle Synchronization processed ' + a.TotalJobItems + ' records with '+ this.errorLog.size() + ' failures.';
        if(this.errorLog.size() > 0) { 
            bodyText += '\n\nFailed Records:';
            for(String record: errorLog.keyset() ) { 
                bodyText += '\n'+ errorLog.get(record) +': '+ URL.getSalesforceBaseUrl().toExternalForm() +'/'+ record +' ';
            } 
        }
        mail.setPlainTextBody(bodyText); 
        mail.setSaveAsActivity(false); 
        
        //sending notification to Admin group
        for(String objectId: this.adminGroupMembers) {
            mail.setTargetObjectId(objectId);   
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    private String composeBIReportRequest(String participant, String report) {
        String SoapXml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">'+
                          '<soapenv:Header/>'+
                          '<soapenv:Body>'+
                            '<pub:runReport>'+
                              '<pub:userID>'+ this.connectionBI.Username__c +'</pub:userID>'+
                              '<pub:password>'+ this.connectionBI.Password__c +'</pub:password>'+
                              '<pub:reportRequest>'+
                                '<pub:reportAbsolutePath>'+ report +'.xdo</pub:reportAbsolutePath>'+
                                '<parameterNameValues>'+
                                  '<item>'+
                                    '<name>src_email</name>'+
                                    '<values>'+
                                      '<item>'+ participant +'</item>'+
                                    '</values>'+
                                  '</item>'+
                                '</parameterNameValues>'+
                              '</pub:reportRequest>'+
                            '</pub:runReport>'+
                          '</soapenv:Body>'+
                        '</soapenv:Envelope>';  
                    
        return OracleWebservices.fetchParticipantId(SoapXml, this.connectionBI.Host__c, this.connectionBI.Port__c);
    }
}