/*******************************************************************
* File Name : OracleTransactionEntryController
* Description : Comtroller for OracleTransactionEntry page.
* Copyright : CloudSPM
********************************************************************/

public with sharing class OracleTransactionEntryController {
	public List<oracleFieldWrapper> oracleFieldList {get; private set;}
	public Map<String, List<selectOption>> selectLists {get; private set;}
	private Set<Id> lookupManagerIds;
	private Set<String> lookupInputColumns;
	private Set<String> lookupOutputColumns;
	private Set<String> columnValues;
	private Oracle_Connection__c connectionIC;
	private String businessUnitId;
	
	public OracleTransactionEntryController() {
		this.businessUnitId = '300000000488569';
		
		//fetching the connection details
        try {
            this.connectionIC = [SELECT Id, Host__c, Port__c, Username__c, Password__c FROM Oracle_Connection__c WHERE Status__c = 'Active' AND Service__c = 'Fusion Incentive Compensation' LIMIT 1];    
            system.debug('ConnectionIC: '+this.connectionIC);
        } catch(Exception e){
            system.debug('ConnectionIC Query exception: '+e);
        }
        
        composeOracleFields();
		
		composeSelectLists();	
		
		if(this.connectionIC == null) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, 'Active connection for Fusion Incentive Compensation not found in Connection Manager'));
		}
	}
	
	/*
	*Function to compose Oracle Fields from Oracle Object Manager
	*/
	private void composeOracleFields() {
		oracleFieldWrapper oracleField; 
		
		this.oracleFieldList = new List<oracleFieldWrapper>();
		this.lookupManagerIds = new Set<Id>();
		this.lookupInputColumns = new Set<String>(); 
		this.lookupOutputColumns = new Set<String>(); 
		
		for(Oracle_Table_Field__c field: [SELECT Id, Name, Display_Name__c, Lookup_Name__c, Lookup_Input_Column__c, Lookup_Column__c, Datatype__c, Not_Null__c, Length__c FROM Oracle_Table_Field__c WHERE Display_Field__c = true ORDER BY Display_Sequence__c]) {
			oracleField = new oracleFieldWrapper();
			
			oracleField.name = field.Name;
			oracleField.label = field.Display_Name__c;
			oracleField.lookup = field.Lookup_Name__c;
			oracleField.lookupInputColumn = field.Lookup_Input_Column__c;
			oracleField.lookupOutputColumn = field.Lookup_Column__c;
			oracleField.dataType = field.Datatype__c;
			oracleField.notNull = field.Not_Null__c;
			oracleField.length = ''+field.Length__c;

			if(field.Lookup_Name__c != null && field.Lookup_Input_Column__c != null) {
				this.lookupManagerIds.add(field.Lookup_Name__c);
				this.lookupInputColumns.add(field.Lookup_Input_Column__c);	
				this.lookupOutputColumns.add(field.Lookup_Column__c);
			}
			
			this.oracleFieldList.add(oracleField);	
		}	
	}
	
	/*
	*Function to compose picklist values for the Lookup column
	*/
	private void composeSelectLists() {
		this.selectLists = new Map<String, List<SelectOption>>();
		
        for(FC_Lookup_Detail__c currObject: [SELECT FC_Lookup_Manager__c , Column_Name__c, Column_Value__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c IN:this.lookupManagerIds AND Column_Name__c IN:this.lookupInputColumns ORDER BY Column_Value__c]) {
        	String key = currObject.FC_Lookup_Manager__c + currObject.Column_Name__c;
            if( this.selectLists.containsKey(key) ) {
                (this.selectLists.get(key)).add(new SelectOption(currObject.Column_Value__c, currObject.Column_Value__c));       
            } else {
                this.selectLists.put(key, new List<SelectOption>{new SelectOption(currObject.Column_Value__c, currObject.Column_Value__c)});    
            }
        }
	}
	
	/*
	*Function to perfome save action
	*/
	public pagereference saveAction() {
		boolean proceed = true, success = false;
		String request, response;
		Pattern datePat = Pattern.compile('(^((0?[1-9]|1[0-2])/(0?[1-9]|[1-2][0-9]|3[0-1])/\\d{4})$)');
		this.columnValues = new Set<String>();
		
		for(oracleFieldWrapper fieldObj: oracleFieldList) {
			if(fieldObj.dataType == 'NUMBER' && !fieldObj.value.isNumeric()) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, fieldObj.label+': Validation Error: Value should be Numeric.'));
				proceed = false;	
			} else if(fieldObj.dataType == 'DATE' && datePat.matcher(fieldObj.value).matches() == false) {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, fieldObj.label+': Validation Error: Value should be Date.'));
				proceed = false;	
			}	
			
			//adding all lookup column values to set
			if(fieldObj.lookup != null && fieldObj.lookupInputColumn != null && fieldObj.lookupOutputColumn != null) {
				this.columnValues.add(fieldObj.value);	
			}
			
		}	
		
		if(proceed == true) {
			if(this.connectionIC != null) {
				request = composeRequest();	
				
				//calling webservice and getting responce
				response = OracleWebservices.incentiveCompensation(request, this.connectionIC.Host__c, this.connectionIC.Port__c);
				
				//parsing response
		        if(!String.isBlank(response)) {
		            Xmlstreamreader reader = new Xmlstreamreader(response); 
		            while(reader.hasNext()) {  
		                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransactionId') {
		                    reader.next();
		                    if(reader.hasText()) {
		                    	system.debug('TransactionId: '+reader.getText());
		                    	success = true;
		                    	break;
		                    }
		                }
		                reader.next();
		            } 
		        }
		        
		        If(success == true) {
		        	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Successfully pushed data to Oracle'));	
		        } else {
		        	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error occured while pushing the data to Oracle'));		
		        }
			} else {
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Active connection for Fusion Incentive Compensation not found in Connection Manager'));	
			}
			
		}
		
		return null;
	}
	
	/*
	*Function to compose webservice request
	*/
	private String composeRequest() {
		String createTime, expireTime, xmlTemplate, response, value;
		set<Decimal> rowNumbers = new set<Decimal>();
		
		Map<String, String> rowValueMap = new Map<String, String>();
		Map<String, String> resultValueMap = new Map<String, String>();
		
		//fetching the required row numbers from Input Columns
		for( FC_Lookup_Detail__c lookupDetail: [SELECT  Row_Number__c, FC_Lookup_Manager__c, Column_Name__c, Column_Value__c FROM  FC_Lookup_Detail__c WHERE  FC_Lookup_Manager__c IN:this.lookupManagerIds AND  Column_Value__c IN:this.columnValues AND  Column_Name__c IN:this.lookupInputColumns]) {
			rowNumbers.add(lookupDetail.Row_Number__c);
			rowValueMap.put( (lookupDetail.FC_Lookup_Manager__c + lookupDetail.Column_Name__c + lookupDetail.Column_Value__c), ''+lookupDetail.Row_Number__c);	
		}
		
		//fetching the required results from Output Columns
		for( FC_Lookup_Detail__c lookupDetail: [SELECT fusion__Column_Value__c, FC_Lookup_Manager__c, Column_Name__c, Row_Number__c FROM fusion__FC_Lookup_Detail__c WHERE fusion__Row_Number__c IN:rowNumbers AND fusion__FC_Lookup_Manager__c IN:this.lookupManagerIds AND fusion__Column_Name__c IN:this.lookupOutputColumns]) {
			resultValueMap.put( (lookupDetail.FC_Lookup_Manager__c + lookupDetail.Column_Name__c + lookupDetail.Row_Number__c), lookupDetail.fusion__Column_Value__c);	
		}
		
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
                 
                for(oracleFieldWrapper fieldObj: oracleFieldList) {
                	if(!String.isBlank(fieldObj.value)) {
                		if(fieldObj.lookup != null && fieldObj.lookupInputColumn != null && fieldObj.lookupOutputColumn != null) {
                			value = resultValueMap.get(fieldObj.lookup + fieldObj.lookupOutputColumn + rowValueMap.get( (fieldObj.lookup + fieldObj.lookupInputColumn + fieldObj.value)) );	
                		} else if(fieldObj.dataType == 'DATE') {
                            value = Datetime.parse(fieldObj.value+' 01:00 AM').formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                        } else {
                			value = fieldObj.value;	
                		}
                		xmlTemplate += '<ns6:'+ fieldObj.name +'>'+ value +'</ns6:'+ fieldObj.name +'>';	
                	}
                }                 
                
                xmlTemplate += '</ns5:incentiveTransactionStaging>'+'</ns5:createIncentiveTransactionStaging>'+'</S:Body>'+'</S:Envelope>';
              
		return xmlTemplate;
	}
	
	/*
	*Wrapper class for display in Page
	*/
	public class oracleFieldWrapper {
		private String name;
		public String label {get; set;}
		public String value {get; set;}
		public String lookup {get; set;}
		public String lookupInputColumn {get; set;}
		private String lookupOutputColumn;
		public String dataType {get; set;}
		public boolean notNull {get; set;}
		public String length {get; set;}
	}

}