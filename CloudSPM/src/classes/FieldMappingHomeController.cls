/*******************************************************************
* File Name : FieldMappingHomeController
* Description : Controller to manage functionalities of FieldMappingHome page.
* Copyright : CloudSPM
********************************************************************/

public with sharing class FieldMappingHomeController {
    
    private Salesforce_Oracle_Maps__c activeMap;
    
    public Boolean isEditMapping {get; private set;}
    public Boolean isEditFilters {get; private set;}
    
    private String sfObjectName;
    
    private List<Oracle_Table_Field__c> oracleTableFields;
    
    private Map<String, String> refObjects;
    private Map<String, String> relationName;
    
    public Map<String, Salesforce_Oracle_Field_Mapping__c> sfOracleMapping {get;set;}
    public Map<String, Boolean> manualStatus {get; private set;}
    public Map<String, List<SelectOption>> feildListMap {get; private set;}
    
    public List<Filter_Criteria__c> fitlerCriteria {get;set;}
    private String filterQuery;
    public Integer removeIndex {get;set;}
    private Integer counter{get;set;}
    private String relName{get;set;}
    private Map<String,String> fields_RelationshipMap{get;set;}
    
    public map<String, List<SelectOption>> lookupColumns {get; set;}
    
    private final Map<String, String> filterOperators = new Map<String, String>{'equals'=>'=', 'not equal to'=>'!=', 'less than'=>'<', 'greater than'=>'>', 'less or equal'=>'<=', 'greater or equal'=>'>=', 'includes'=>' IN ', 'excludes'=>' NOT IN '};
    
    public fieldMappingHomeController(ApexPages.StandardController stdController) {
       fields_RelationshipMap = new Map<String,String>(); 
       this.isEditMapping = false;
       this.isEditFilters = false;
           
       //setting the active map 
       Salesforce_Oracle_Maps__c currMap = (Salesforce_Oracle_Maps__c)stdController.getRecord();
       activeMap = [SELECT id, Name,Salesforce_Object_Api_Name__c,  Filter_Criterion__c FROM Salesforce_Oracle_Maps__c WHERE id=:currMap.Id ];
       //setting the active object and its related objects
       if(activeMap.Salesforce_Object_Api_Name__c != null) {
            sfObjectName = activeMap.Salesforce_Object_Api_Name__c;
            Schema.DescribeSObjectResult[] objDecsribe = Schema.describeSObjects( new String[]{ sfObjectName });
            List<Schema.SObjectField> fields = objDecsribe[0].fields.getMap().Values();
            refObjects = new Map<String, String>();
            relationName = new Map<String, String>();
            for(Schema.SObjectField field : fields) {
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                if(Schema.DisplayType.Reference == fieldDesc.getType()){
                    for(Schema.sObjectType refObject: fieldDesc.getReferenceTo()) {
                       system.debug('@@@@'+refObject);
                       Schema.DescribeSObjectResult refObjectDesc = refObject.getDescribe();                       
                       
                       refObjects.put(fieldDesc.getRelationshipName()+':'+refObjectDesc.getLabel(), refObjectDesc.getName());
                       relationName.put(fieldDesc.getRelationshipName()+':'+refObjectDesc.getLabel(), fieldDesc.getRelationshipName()); 
                                            
                       Schema.DescribeSObjectResult[] objDecsribe2 = Schema.describeSObjects( new String[]{ refObjectDesc.getName()});
                       List<Schema.SObjectField> fields2 = objDecsribe2[0].fields.getMap().Values();
                       String refstr = refObject+'';
                       for(Schema.SObjectField field2 : fields2) {
                           
                           Schema.DescribeFieldResult fieldDesc2 = field2.getDescribe();
                           if(Schema.DisplayType.Reference == fieldDesc2.getType()){
                               for(Schema.sObjectType refObject2: fieldDesc2.getReferenceTo()) {                       
                                   System.debug('@@@ inner==> '+refstr + '.' +refObject2);
                                   Schema.DescribeSObjectResult refObjectDesc2 = refObject2.getDescribe();
                                   if(fieldDesc2.getRelationshipName() != null && fieldDesc2.getRelationshipName() != 'null' && refObjects.get(fieldDesc2.getRelationshipName()+':'+refObjectDesc2.getLabel())==null){
                                       refObjects.put(fieldDesc2.getRelationshipName()+':'+refObjectDesc2.getLabel(),refObjectDesc2.getName());
                                       relationName.put(fieldDesc2.getRelationshipName()+':'+refObjectDesc2.getLabel(), fieldDesc.getRelationshipName()+'.'+fieldDesc2.getRelationshipName()); 
                                       fields_RelationshipMap.put(fieldDesc.getRelationshipName()+'.'+fieldDesc2.getRelationshipName(),fieldDesc.getRelationshipName()+'###'+fieldDesc2.getRelationshipName());
                                   
                               
                                       Schema.DescribeSObjectResult[] objDecsribe3 = Schema.describeSObjects( new String[]{ refObjectDesc2.getName()});
                                       List<Schema.SObjectField> fields3 = objDecsribe3[0].fields.getMap().Values();
                                       
                                       for(Schema.SObjectField field3 : fields3) {
                                           Schema.DescribeFieldResult fieldDesc3 = field3.getDescribe();
                                           if(Schema.DisplayType.Reference == fieldDesc3.getType()){
                                               for(Schema.sObjectType refObject3: fieldDesc3.getReferenceTo()) {                       
                                                   Schema.DescribeSObjectResult refObjectDesc3 = refObject3.getDescribe();
                                                   
                                                   if(fieldDesc3.getRelationshipName() != null && fieldDesc3.getRelationshipName() != 'null' && refObjects.get(fieldDesc3.getRelationshipName()+':'+refObjectDesc3.getLabel())==null){
                                                       refObjects.put(fieldDesc3.getRelationshipName()+':'+refObjectDesc3.getLabel(), refObjectDesc3.getName());
                                                       relationName.put(fieldDesc3.getRelationshipName()+':'+refObjectDesc3.getLabel(), fieldDesc.getRelationshipName()+'.'+fieldDesc2.getRelationshipName()+'.'+fieldDesc3.getRelationshipName()); 
                                                       fields_RelationshipMap.put(fieldDesc.getRelationshipName()+'.'+fieldDesc2.getRelationshipName()+'.'+fieldDesc3.getRelationshipName(),fieldDesc.getRelationshipName()+'###'+fieldDesc2.getRelationshipName()+'###'+fieldDesc3.getRelationshipName());
                                                   }
                                                   
                                               }
                                           } 
                                       }
                                   }   
                                    
                              
                               }    
                           }
                       }
                       
                       //counter = 1;
                       //relName = fieldDesc.getRelationshipName(); 
                      // getRelatedObjects(refObjectDesc.getName());
                    }
                }
            }
            refObjects.put(objDecsribe[0].getLabel(), sfObjectName);
            relationName.put(objDecsribe[0].getLabel(), sfObjectName);    
       }
       
       //setting field lists of all related objects
       composeFeildListMap();
       
       //setting fields in Oracle table
       oracleTableFields = [SELECT Id, Name, Field_Api_Name__c, Manual_Entry__c FROM Oracle_Table_Field__c WHERE Name != null];
       
       composeMapping();
       
       this.lookupColumns = new map<String, List<SelectOption>>();
       composeLookupColumns();
       
       composeFilterCriteria();
       
    }
    
    /* public void getRelatedObjects(string objectName){
        system.debug(' >>>>>>>>>>>>>>>> object name '+objectName);
        Schema.DescribeSObjectResult[] objDecsribe = Schema.describeSObjects( new String[]{ objectName});
            List<Schema.SObjectField> fields = objDecsribe[0].fields.getMap().Values();
            for(Schema.SObjectField field : fields) {
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                for(Schema.sObjectType refObject: fieldDesc.getReferenceTo()) {
                   Schema.DescribeSObjectResult refObjectDesc = refObject.getDescribe(); 
                   system.debug(' <<<<<<<<<<<<<<<<< '+refObjects.get(refObjectDesc.getName())); 
                   if(refObjects.get(refObjectDesc.getName())!=null){
                   }else{
                       if(counter > 2){
                           break;
                       }
                       counter += 1;
                         system.debug('!!!!!!!!!!!!!! put object name in map '+refObjectDesc.getName());
                         system.debug('XXXXXXXXXXXXXXX MAP - > '+refObjects);
  
                         refObjects.put(fieldDesc.getRelationshipName()+':'+refObjectDesc.getLabel(), refObjectDesc.getName());
                         relationName.put(fieldDesc.getRelationshipName()+':'+refObjectDesc.getLabel(), relName+'.'+fieldDesc.getRelationshipName()); 
                   
                         refObjects.put(refObjectDesc.getName(), refObjectDesc.getName());
                         getRelatedObjects(refObjectDesc.getName());
                   }
                }
            }
    } */
    
    /*
    *Getter method for Object picklist
    */
    public List<SelectOption> getSalesforceObjects() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption('null', '--Select--') );
        for(String obj : refObjects.keySet()) {
            if(relationName.get(obj) != null){
                options.add( new SelectOption( relationName.get(obj), obj ) );
            }
        }
        options.sort();
        return options;
    }
    
    /*
    *To compose the feilds list
    */
    private void composeFeildListMap() {
        feildListMap = new Map< String, List<SelectOption> >();
        feildListMap.put('null', new List<SelectOption>{new SelectOption('null', '--None--')});
        
        List<SelectOption> options;
        for(String obj : refObjects.keySet()) {
           options = new List<SelectOption>();
           Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{ refObjects.get(obj) });
           if(descResult != null) {
               List<Schema.SObjectField> fieldList = descResult[0].fields.getMap().Values();    
               for(Schema.SObjectField field : fieldList) {
                   Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                   if(fieldDesc.isAccessible()){
                       options.add( new SelectOption( fieldDesc.getName(), fieldDesc.getLabel() ) );
                   }
               }
           }    
           options.sort();
           feildListMap.put(relationName.get(obj), options);
        }
    }
    
    /*
    *To compose mapping list
    */
    private void composeMapping() {
        sfOracleMapping = new Map<String, Salesforce_Oracle_Field_Mapping__c>();
        manualStatus = new Map<String, Boolean>();
        for(Salesforce_Oracle_Field_Mapping__c mapping: [SELECT Id,Lookup_Name__c,Salesforce_Fields_Relationship__c,Lookup_Input_Column__c,Lookup_Output_Column__c,Salesforce_Object_Api_Name__c, Salesforce_Field_Api_Name__c, Oracle_Report_API__c, Oracle_Field_Name__r.Name, Oracle_Field_Name__r.Manual_Entry__c FROM Salesforce_Oracle_Field_Mapping__c WHERE Salesforce_Oracle_Map__c =:activeMap.Id] ) {
            //Handle the change of Oracle field in existing mapping to manual entry type
            if(mapping.Oracle_Field_Name__r.Manual_Entry__c == true) {
                mapping.Salesforce_Object_Api_Name__c = 'null'; 
            }
            sfOracleMapping.put(mapping.Oracle_Field_Name__r.Name, mapping);  
            manualStatus.put(mapping.Oracle_Field_Name__r.Name, mapping.Oracle_Field_Name__r.Manual_Entry__c);      
        }
       
        for(Oracle_Table_Field__c oracleField: oracleTableFields) {
            if(!sfOracleMapping.containsKey(oracleField.Name)) {
                Salesforce_Oracle_Field_Mapping__c mapping = new Salesforce_Oracle_Field_Mapping__c(Salesforce_Oracle_Map__c = activeMap.Id);   
                mapping.Oracle_Field_Name__c = oracleField.Id;
                mapping.Salesforce_Object_Api_Name__c = 'null';
                mapping.Salesforce_Field_Api_Name__c = null;
                mapping.Oracle_Report_API__c = null;
                
                manualStatus.put(oracleField.Name, oracleField.Manual_Entry__c);
                sfOracleMapping.put(oracleField.Name, mapping);
            }
       }    
    }
    
    public void composeLookupColumns() {
        set<Id> lookupManagerIds = new set<Id>();    
        for(Salesforce_Oracle_Field_Mapping__c mapping: sfOracleMapping.values()){
        	if(!lookupColumns.containsKey(mapping.Lookup_Name__c)) {
        		lookupManagerIds.add(mapping.Lookup_Name__c);	
        	}
        }   
    
        set<SelectOption> lookupColumnSet;
        for(FC_Lookup_Detail__c currObject: [SELECT FC_Lookup_Manager__c , Column_Name__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c=:lookupManagerIds]) {
        
            if( this.lookupColumns.containsKey(currObject.FC_Lookup_Manager__c) ){
                (this.lookupColumns.get(currObject.FC_Lookup_Manager__c)).add(new SelectOption(currObject.Column_Name__c, currObject.Column_Name__c));       
            } else {
                this.lookupColumns.put(currObject.FC_Lookup_Manager__c, new List<SelectOption>{new SelectOption(currObject.Column_Name__c, currObject.Column_Name__c)});    
            }
                 
        }
        
        for(String currList: this.lookupColumns.keySet()) {
           lookupColumnSet = new set<SelectOption>(); 
           lookupColumnSet.addAll(this.lookupColumns.get(currList));        
           this.lookupColumns.get(currList).clear();
           this.lookupColumns.get(currList).addAll(lookupColumnSet);           
        }
        
    }
    
    /*
    *Edit action for Mapping
    */
    public void editMapping() { 
        this.isEditMapping = true;    
    }
    
    /*
    *Save action for Mapping
    */
    public void saveMapping() {
        try {
            
            for(Salesforce_Oracle_Field_Mapping__c sof:sfOracleMapping.values()){
                if(fields_RelationshipMap.get(sof.Salesforce_Object_Api_Name__c) != null){
                    sof.Salesforce_Fields_Relationship__c = fields_RelationshipMap.get(sof.Salesforce_Object_Api_Name__c);
                }
            }
            
            Database.upsert(sfOracleMapping.values(), Salesforce_Oracle_Field_Mapping__c.Fields.Id, true);
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Mapping saved successfully'));
            this.isEditMapping = false;
        } catch(Exception e){
            System.debug('Mapping Exception: '+e);
        }
    }
    
    /*
    *Cancel action for Mapping
    */
    public void cancelMapping() {
        this.isEditMapping = false; 
        composeMapping();   
    }
    
    /*
    *To compose filter criteria
    */
    public void composeFilterCriteria() {
        fitlerCriteria = new List<Filter_Criteria__c>();
        for(Filter_Criteria__c filter: [SELECT Id, Salesforce_Object__c, Salesforce_Field__c, Operator__c, Value__c FROM Filter_Criteria__c WHERE Salesforce_Oracle_Map__c =:activeMap.Id] ) {
            fitlerCriteria.add(filter);
        }
    }
    
    /*
    *Edit action for Filters
    */
    public void editFilters() {
        this.isEditFilters = true;    
    }
    
    /*
    *Action for adding new Filters
    */
    public void addFilter() {
        Filter_Criteria__c filter = new Filter_Criteria__c();
        filter.Salesforce_Oracle_Map__c = activeMap.Id;
        filter.Salesforce_Object__c = 'null';
        filter.Salesforce_Field__c = null;
        fitlerCriteria.add(filter);
    }
    
    /*
    *Action for removing Filters
    */
    public void removeFilter() {
        Filter_Criteria__c filter = fitlerCriteria.remove(removeIndex);
        try {
            delete filter;  
        } catch(Exception e){
           System.debug('Filter Delete Exception: '+e);
        }
    }
    
    /*
    *Save action for Filters
    */
    public void saveFilters() {
        if(this.validateFilter()) {
            try {
                Database.upsert(fitlerCriteria, Filter_Criteria__c.Fields.Id, true);
                activeMap.Filter_Criterion__c = filterQuery;
                update activeMap;
                this.isEditFilters = false;
            } catch(Exception e) {
                System.debug('Filter Validate Exception: '+e);  
            }
        } 
    }
    
    /*
    *Cancel action for Filters
    */
    public void cancelFilters() {
        this.isEditFilters = false;
        composeFilterCriteria();
    }
    
    /*
    *Validate the Filter criteria query
    */
    private Boolean validateFilter() {
        Boolean returnValue = true;
        Integer resultCount;
        String fieldName, filter, value, mockQuery, dataType;
        Pattern dateTimePat = Pattern.compile('(^(\\d{4}-([0][1-9]|[1][0-2])-([0][1-9]|[1-2][0-9]|[3][0-1])\\s([0-1][0-9]|[2][0-3])(:([0-5][0-9])){2})$)');
        Pattern datePat = Pattern.compile('(^(\\d{4}-([0][1-9]|[1][0-2])-([0][1-9]|[1-2][0-9]|[3][0-1]))$)');
        
        filterQuery = '';
        
        for(Filter_Criteria__c row: fitlerCriteria) {
            dataType = ''; 
            filter = ''; 
            fieldName = '';
        
            if(row.Salesforce_Object__c == sfObjectName) {
                fieldName = row.Salesforce_Field__c;
            } else {
                fieldName = row.Salesforce_Object__c +'.'+ row.Salesforce_Field__c;     
            }
            
            if(row.Salesforce_Object__c == 'null' && row.Salesforce_Field__c == 'null' && row.Operator__c == null ) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'All values are required for each filter condition. If there are filter rows which are not used please remove them and then save.' ));    
                returnValue = false;    
            } else {
                //cleaning up the query data
                value = String.escapeSingleQuotes(row.Value__c);
                value = (value).replace('"', '\\'+'"').replace('_', '\\'+'_').replace('%', '\\'+'%');
                value = value.normalizeSpace();
                value = value.replace(', ', ',');
                
                //Identifying the data type of value
                if(dateTimePat.matcher(value).matches() == true) {
                    dataType = 'dateTime'; 
                    value = Datetime.valueOf(value).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXX');    
                } else if(datePat.matcher(value).matches() == true) {
                    dataType = 'date';
                } else if((value.replace('.','')).isNumeric()) {
                    dataType = 'numeric';   
                } else if(value == 'true' || value == 'false') {
                    dataType = 'boolean';   
                }
                
                //Composing filter string based on data type and operator
                if(row.Operator__c == 'equals' || row.Operator__c == 'not equal to') {
                    
                    if(String.isBlank(value)) {
                        filter = fieldName + filterOperators.get(row.Operator__c) + null;   
                    } else if(dataType == 'numeric' || dataType == 'boolean' || dataType == 'dateTime' || dataType == 'date') {
                        filter = fieldName + filterOperators.get(row.Operator__c) + value;      
                    } else {
                        filter = fieldName + filterOperators.get(row.Operator__c) + '\'' + value + '\'';  
                    }    
                    
                } else if(row.Operator__c == 'starts with') {
                    
                    filter = fieldName + ' LIKE ' + '\'' + value + '%\'';    
                    
                } else if(row.Operator__c == 'contains') {
                    
                    filter = fieldName + ' LIKE ' + '\'%' + value + '%\'';    
                    
                } else if(row.Operator__c == 'less than' || row.Operator__c == 'greater than' || row.Operator__c == 'less or equal' || row.Operator__c == 'greater or equal') {
                    
                    if(dataType == 'numeric' || dataType == 'dateTime' || dataType == 'date') {
                        filter = fieldName + filterOperators.get(row.Operator__c) + value;      
                    } else {
                        filter = fieldName + filterOperators.get(row.Operator__c) + '\'' + value + '\'';  
                    } 
                
                } else if(row.Operator__c == 'includes' || row.Operator__c == 'excludes') {
    
                    if(dataType == 'numeric' || (value.replace(',', '').replace('.', '')).isNumeric() || dataType == 'boolean' || dataType == 'dateTime' || dataType == 'date') {
                        filter = fieldName + filterOperators.get(row.Operator__c) + '(' + value + ')';  
                    } else {
                        filter = fieldName + filterOperators.get(row.Operator__c) + '(\'' + value.replace(',', '\' , \'') + '\')';  
                    }
                
                } else {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Operator is required for a Filter Criterion' ));
                    returnValue = false;    
                }
                
                //adding each filter string to filter query
                if(filter.length() > 0) {
                   filterQuery += filter +' AND ';
                }
            }
        }
        
        filterQuery = filterQuery.removeend(' AND ');
        
        //composing mock query and validation
        if(!String.isBlank(filterQuery)) {
            mockQuery = 'SELECT count() FROM '+ sfObjectName +' WHERE '+ filterQuery + ' LIMIT 50000';
            try {
                if(returnValue) {
                    resultCount = Database.countQuery(mockQuery);
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Filters saved successfully, Total available Records with current Filter: '+ (resultCount == 50000 ? '50000+' : ''+resultCount) ));
                }
            } catch(Exception e) {
                String errorMsg = e.getMessage();
                errorMsg = errorMsg.replace(' and should be enclosed in quotes','');
                errorMsg = errorMsg.replace('like operator','\'Starts with\' and \'Contains\'');
                errorMsg = errorMsg.replace(' = or != ',' Equals or Not Equal To ');
                errorMsg = errorMsg.replace('of type dateTime','a valid dateTime "yyyy-MM-dd HH:mm:ss"');
                errorMsg = errorMsg.replace('of type date','a valid date "yyyy-MM-dd"');
                errorMsg = errorMsg.replace('. If you are attempting to use a custom relationship, be sure to append the \'__r\' after the custom relationship name. Please reference your WSDL or the describe call for the appropriate names.', '');
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, errorMsg.capitalize() ));
                returnValue = false;    
            }       
        } 
        return returnValue;
    }
    public void createschedular(){
        List<CronTrigger> schedularList = [select Id,NextFireTime,CronJobDetail.Name from CronTrigger 
            where CronJobDetail.Name = 'OracleSynchronizationScheduler'];
            
        if(schedularList != null && schedularList.size()>0){
             System.abortJob(schedularList[0].id);
        }
        
        DateTime dt = DateTime.now();
        dt = dt.addMinutes(1);        
        dt = dt.addHours(-8);
        String sch = '0 '+dt.minuteGmt()+' '+dt.hourGmt()+' '+dt.dayGmt()+' '+dt.monthGmt()+' ? '+dt.yearGmt();
        
        System.schedule('OracleSynchronizationScheduler', sch, new OracleSynchronizationScheduler());
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Job successfully scheduled, Wait for 1 Minute') );
    }
}