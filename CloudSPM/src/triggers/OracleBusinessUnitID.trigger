/*******************************************************************
* File Name : OracleBusinessUnitID
* Description : Trigger to fill Salesforce_Oracle_Maps BusinessUnitId on Insert and Update.
* Copyright : CloudSPM
********************************************************************/

trigger OracleBusinessUnitID on Salesforce_Oracle_Maps__c (before insert,before update) {
    public Set<String> oracleSetLookup = new Set<String>();
    public Set<String> oracleSetName = new Set<String>();
    public Set<Integer> rowSet = new Set<Integer>();
    //public Map<String,Integer> FC_Lookup_Map = new Map<String,Integer>();
    public Map<String,List<Salesforce_Oracle_Maps__c>> fcMap = new Map<String,List<Salesforce_Oracle_Maps__c>>();
    public Map<String,String> columnSet = new Map<String,String>();
    public Map<String,String> updateMap = new Map<String,String>();
    
    
    //fetching Records for Insert and Update and filling Map
    for(Salesforce_Oracle_Maps__c som:trigger.new){
        //oracleMap.put(som.Lookup_Name__c,som.Business_Unit_Name__c);
        oracleSetLookup.add(som.Lookup_Name__c);
        oracleSetName.add(som.Business_Unit_Name__c);
        String str = som.Lookup_Name__c+(som.Lookup_Column__c != null && som.Lookup_Column__c.length() > 0 ?  som.Lookup_Column__c.toLowerCase() : '')+ ( som.Business_Unit_Name__c != null && som.Business_Unit_Name__c.length() > 0 ? som.Business_Unit_Name__c.toLowerCase() : '');
        if(!Test.isRunningtest()){
            som.Business_Unit_Id__c = 'Not Found';
        }else{
            som.Business_Unit_Id__c = 'test';
        }
        List<Salesforce_Oracle_Maps__c> sfList = fcMap.get(str);
        if(sfList == null){
            sfList = new List<Salesforce_Oracle_Maps__c>();
        }
        sfList.add(som);
        fcMap.put(str,sfList);        
    }
    
    //searching Record of Lookup Column in FC Lookup Detail and fill Map with Row Number
    for(FC_Lookup_Detail__c fld:[select id,Column_Name__c,Column_Value__c,Row_Number__c,FC_Lookup_Manager__c from FC_Lookup_Detail__c where Column_Value__c in:oracleSetName and FC_Lookup_Manager__c in:oracleSetLookup]){       
            String st1 = fld.FC_Lookup_Manager__c+String.ValueOf(fld.Column_Name__c).toLowerCase()+String.ValueOf(fld.Column_Value__c).toLowerCase();                       
            //FC_Lookup_Map.put(st1,Integer.ValueOf(fld.Row_Number__c));            
            rowSet.add(Integer.ValueOf(fld.Row_Number__c));
            columnSet.put(fld.FC_Lookup_Manager__c+String.ValueOf(fld.Row_Number__c),fld.FC_Lookup_Manager__c+String.ValueOf(fld.Column_Name__c).toLowerCase()+String.ValueOf(fld.Column_Value__c).toLowerCase());          
    }
    
    //updating salesforce Oracle Maps With Business Unit Id
    for(FC_Lookup_Detail__c fld:[select FC_Lookup_Manager__c,Column_Name__c,Column_Value__c,Row_Number__c from FC_Lookup_Detail__c where  Row_Number__c in:rowSet AND Column_Name__c = 'ORG_ID']){
        String key = columnSet.get(fld.FC_Lookup_Manager__c+String.ValueOf(fld.Row_Number__c));        
        if(fcMap.get(key) != null){
            List<Salesforce_Oracle_Maps__c> sfMap = fcMap.get(key);
            for(Salesforce_Oracle_Maps__c sf:sfMap ){
                 sf.Business_Unit_Id__c = fld.Column_Value__c;
            }
           
        }
    }
    
}