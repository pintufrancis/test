/*******************************************************************
* File Name : OracleSynchronizationScheduler
* Description : Scheduler to manage Oracle synchronization batch process.
* Copyright : CloudSPM
********************************************************************/

global class OracleSynchronizationScheduler implements Schedulable {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    private Oracle_Connection__c connectionIC;
    private Oracle_Connection__c connectionBI;
    private List<Salesforce_Oracle_Maps__c> currentMap;
    private String sfObjectName; 
    private String oracleRespLocation;
    private String businessUnitId;
    private List<Salesforce_Oracle_Field_Mapping__c> fieldMappingList; 
     
    public OracleSynchronizationScheduler() {
        this.connectionIC = [SELECT Id, Host__c, Port__c, Username__c, Password__c FROM Oracle_Connection__c WHERE Status__c = 'Active' AND Service__c = 'Fusion Incentive Compensation' LIMIT 1];    
        this.connectionBI = [SELECT Id, Host__c, Port__c, Username__c, Password__c FROM Oracle_Connection__c WHERE Status__c = 'Active' AND Service__c = 'Fusion Transactional Business Intelligence' LIMIT 1];
        
        this.currentMap = [SELECT Id, Salesforce_Object_Api_Name__c, Business_Unit_Id__c, Filter_Criterion__c, Oracle_Response_Location__c FROM Salesforce_Oracle_Maps__c WHERE Status__c = 'Active' AND Business_Unit_Id__c NOT IN (null, 'Waiting', 'Not Found', 'Not Available') LIMIT 1];
       
        if(this.connectionIC != null && this.connectionBI != null && this.currentMap != null && currentMap.size()>0) {
            this.sfObjectName = this.currentMap[0].Salesforce_Object_Api_Name__c;
            this.oracleRespLocation = this.currentMap[0].Oracle_Response_Location__c;
            this.businessUnitId = this.currentMap[0].Business_Unit_Id__c;
            
            this.fieldMappingList = [SELECT Id,Lookup_Name__c,Salesforce_Fields_Relationship__c,Lookup_Input_Column__c,Lookup_Output_Column__c,Salesforce_Object_Api_Name__c, Salesforce_Field_Api_Name__c, Oracle_Report_API__c, Oracle_Field_Name__r.Name, Oracle_Field_Name__r.Manual_Entry__c, Oracle_Field_Name__r.Datatype__c 
                                        FROM Salesforce_Oracle_Field_Mapping__c 
                                        WHERE Salesforce_Oracle_Map__c =:this.currentMap[0].Id AND Salesforce_Field_Api_Name__c != 'null'];
        }
    }
    
    global void execute(SchedulableContext sc) {
        if(this.fieldMappingList != null) {
            String sfQuery, currField, queryFields = '';
            Set<String> queryFieldSet = new Set<String>(); 
            
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
            queryFieldSet.add('Id'); 
            for(String field: queryFieldSet ) {
                queryFields += field +',' ;     
            }  
            queryFields = queryFields.removeend(',');
             
            sfQuery = 'SELECT '+ queryFields +' FROM '+ this.sfObjectName;
            
            boolean whereflag = false;
            if(this.oracleRespLocation != null && this.oracleRespLocation.length()>0){
                whereflag = true;
                sfQuery += ' Where ' + this.oracleRespLocation + ' = null';            
            }
            if(whereflag == false){
                sfQuery += ' Where ';
            }else{
                sfQuery += ' AND ';
            }
            
            if(!String.isBlank(this.currentMap[0].Filter_Criterion__c)){
                sfQuery += this.currentMap[0].Filter_Criterion__c;
            }
            system.debug('@@@ sfQuery '+sfQuery );
            //Initiating batch 
            if(queryFieldSet.size() > 1) { 
                OracleSynchronizationBatch batchapex = new OracleSynchronizationBatch(this.connectionIC, this.connectionBI, this.sfObjectName, sfQuery, this.fieldMappingList, this.businessUnitId, this.oracleRespLocation);
                Database.executebatch(batchapex,1); 
            }     
        }
    }    
     
}