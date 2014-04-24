/*******************************************************************
* File Name : OracleIncentiveEstimatorController
* Description : Controller for OracleIncentiveEstimator page.
* Copyright : CloudSPM
********************************************************************/

public with sharing class OracleIncentiveEstimatorController {

    public transient String searchText {get; set;}
    public transient Date closeDateFrom {get; set;}
    public transient Date closeDateTo {get; set;}
    public List<searchResultsWrapper> searchResults {get; set;} 
    
    private Oracle_Connection__c connectionIC;
    private List<Salesforce_Oracle_Maps__c> currentMap;
    private List<Salesforce_Oracle_Field_Mapping__c> fieldMappingList; 
    private String sfObjectName; 
    private String oracleRespLocation;
    private String businessUnitId;
    private String batchQuery;
     
    public OracleIncentiveEstimatorController() {
    	this.sfObjectName = 'Opportunity';
        this.searchResults = new List<searchResultsWrapper>();  
        
        //fetching the connection details
        try {
            this.connectionIC = [SELECT Id, Host__c, Port__c, Username__c, Password__c FROM Oracle_Connection__c WHERE Status__c = 'Active' AND Service__c = 'Fusion Incentive Compensation' LIMIT 1];    
            system.debug('ConnectionIC: '+this.connectionIC);
        } catch(Exception e){
            system.debug('ConnectionIC Query exception');
        }
        
        //fetching current Estimator map details
        try {
            this.currentMap = [SELECT Id, Salesforce_Object_Api_Name__c, Business_Unit_Id__c, Filter_Criterion__c, Oracle_Response_Location__c FROM Salesforce_Oracle_Maps__c WHERE Status__c = 'Estimator' AND Business_Unit_Id__c NOT IN (null, 'Waiting', 'Not Found', 'Not Available') LIMIT 1];
            system.debug('currentMap : '+this.currentMap );
        } catch(Exception e){
            system.debug('Current Map Query exception');
        }
        
        //fetching feild mapping details of current Estimator map
        if(this.connectionIC != null && this.currentMap != null && currentMap.size()>0) {
            this.sfObjectName = this.currentMap[0].Salesforce_Object_Api_Name__c;
            this.oracleRespLocation = this.currentMap[0].Oracle_Response_Location__c;
            this.businessUnitId = this.currentMap[0].Business_Unit_Id__c;
            
            try {
                this.fieldMappingList = [SELECT Id, Lookup_Name__c, Salesforce_Fields_Relationship__c, Lookup_Input_Column__c, Lookup_Output_Column__c, Salesforce_Object_Api_Name__c, Salesforce_Field_Api_Name__c, Oracle_Report_API__c, Oracle_Field_Name__r.Name, Oracle_Field_Name__r.Manual_Entry__c, Oracle_Field_Name__r.Datatype__c 
                                            FROM Salesforce_Oracle_Field_Mapping__c 
                                            WHERE Salesforce_Oracle_Map__c =:this.currentMap[0].Id AND Salesforce_Field_Api_Name__c != 'null'];
            	system.debug('fieldMappingList: '+ fieldMappingList);
            } catch(Exception e){
                system.debug('Field mapping Query exception');
            }
        }
        
        this.batchQuery = buildBaseQuery();
    }
    
    /*
    *Function to search the records
    */
    public void searchRecords() {
        this.searchResults = new List<searchResultsWrapper>();
        List<sObject> queryResults = new List<sObject>();

        searchResultsWrapper resultObj;
        
        if(!String.isBlank(searchText)) { 
        	
        	String query = 'SELECT Id, Name, Account.Name, Amount, CloseDate, StageName, Estimated_Incentive__c, Estimate_Status__c, Status_Date__c FROM Opportunity';
        	
        	query += ' WHERE (('+ buildQueryCriterion(searchText) +')';
            if(this.closeDateFrom != null) {
                query += ' AND (CloseDate>='+ formatDateforQuery(closeDateFrom) +')';        
            }
            if(this.closeDateTo != null) {
                query += ' AND (CloseDate<='+ formatDateforQuery(closeDateTo) +')';  
            }
            query += ')';
           
            try {
            	//searchText = query;
                queryResults = Database.query(query);
                
                system.debug('queryResults: '+queryResults);
                
                for(sObject currResult: queryResults) {
                    resultObj = new searchResultsWrapper(); 
                    resultObj.record = currResult;
                    resultObj.isSelected = false;
                    
                    this.searchResults.add(resultObj);
                }
            } catch(Exception e) {
                String errorMsg = e.getMessage();
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, errorMsg.capitalize() ));
            }       
        }
    }
    
    public void oracleEstimator() { 
    	String query, selectedRecords = '';
    	for(searchResultsWrapper currResult: this.searchResults) {
    		if(currResult.isSelected == true) {
    			selectedRecords += '\''+ currResult.record.Id +'\',';	
    		}	
    	}
    	selectedRecords = selectedRecords.removeEnd(',');
    	
    	if(!String.isBlank(selectedRecords)) {
    		if(this.fieldMappingList != null && this.fieldMappingList.size() > 0) {
    			query = this.batchQuery + ' WHERE Id IN('+ selectedRecords +')';
    	
		    	system.debug('batchQuery: '+ query);
		    	OracleIncentiveEstimatorBatch batchapex = new OracleIncentiveEstimatorBatch(this.connectionIC, this.sfObjectName, query, this.fieldMappingList, this.businessUnitId, this.oracleRespLocation);
		        ID batchprocessid = Database.executebatch(batchapex,10); 
		        if(batchprocessid != null) {
		        	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Successfully initiated synchronization process to Oracle' ));	
		        } 		
    		} else {
    			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, 'Mapping for Incentive Estimator not present' ));	
    		}
    		
    	}
    	
        this.searchResults = new List<searchResultsWrapper>();	
    	
    }
    
    /*
    *Function to build the base Query
    */
    private String buildBaseQuery() {
        String sfQuery, currField, queryFields = '';
        Set<String> queryFieldSet = new Set<String>{'Id', 'Estimate_Status__c', 'Status_Date__c'}; 
        if(this.fieldMappingList != null) {
            //adding query fields for SF query
            for(Salesforce_Oracle_Field_Mapping__c mapping: this.fieldMappingList) {
                if(mapping.Oracle_Field_Name__r.Manual_Entry__c != true && mapping.Salesforce_Object_Api_Name__c != 'null') {
                    if(mapping.Salesforce_Object_Api_Name__c == this.sfObjectName) {
                        currField = mapping.Salesforce_Field_Api_Name__c;                       
                    } else {
                        currField = mapping.Salesforce_Object_Api_Name__c +'.'+ mapping.Salesforce_Field_Api_Name__c;                  
                    }
                    queryFieldSet.add(currField);
                }
            }
        }
        
        for(String field: queryFieldSet ) {
            queryFields += field +',' ;     
        }  
        queryFields = queryFields.removeend(',');
         
        sfQuery = 'SELECT '+ queryFields +' FROM '+ this.sfObjectName;
    
    	return sfQuery;
    }
    
    /*
    *Function to build search Criterion
    */
    private String buildQueryCriterion(String value) {
        String dataType, returnString='';
        Pattern dateTimePat = Pattern.compile('(^((0?[1-9]|1[0-2])/(0?[1-9]|[1-2][0-9]|3[0-1])/\\d{4}\\s([0-1][0-9]|2[0-3])(:([0-5][0-9])){2})$)');
        Pattern datePat = Pattern.compile('(^((0?[1-9]|1[0-2])/(0?[1-9]|[1-2][0-9]|3[0-1])/\\d{4})$)');
        
        //cleaning up the query data
        value = String.escapeSingleQuotes(value);
        value = (value).replace('"', '\\'+'"').replace('_', '\\'+'_').replace('%', '\\'+'%');
        value = value.normalizeSpace();
        
        //Identifying the data type of value
        if(dateTimePat.matcher(value).matches() == true) {
            dataType = 'dateTime'; 
            value = DateTime.parse(value).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXX');  
        } else if(datePat.matcher(value).matches() == true) {
            dataType = 'date';
            value = DateTime.parse(value +' 01:00 AM').format('yyyy-MM-dd');    
        } else if((value.replace('.','').replace(',','')).isNumeric()) {
            dataType = 'numeric';   
            value = value.replace(',','');
        } else if(value == 'true' || value == 'false') {
            dataType = 'boolean';   
        }
        
        //Conditions for string type
        returnString += 'Name LIKE \'%'+ value +'%\' ';
        returnString += 'OR Account.Name LIKE \'%'+ value +'%\' ';
        returnString += 'OR Estimate_Status__c LIKE \'%'+ value +'%\' ';
        returnString += 'OR StageName LIKE \'%'+ value +'%\' ';
        
        if(dataType == 'numeric') {
            returnString += 'OR Amount ='+ value +' ';  
            returnString += 'OR Estimated_Incentive__c ='+ value +' ';  
        } 
      
        if(dataType == 'date') {
            returnString += 'OR Status_Date__c ='+ value +' ';
            returnString += 'OR CloseDate ='+ value +' ';   
        }
        
        return returnString;    
            
    }
    
    /*
    *Function for formating date value 
    */
    private String formatDateforQuery(Date dateValue) {
    	return datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day()).format('yyyy-MM-dd');	
    }
    
    /*
    *Display class for the search results
    */
    public class searchResultsWrapper {
        public Boolean isSelected {get; set;}   
        public sObject record {get; set;}
    }

}