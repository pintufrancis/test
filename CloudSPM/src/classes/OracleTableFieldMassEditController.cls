/*******************************************************************
* File Name : OracleTableFieldMassEditController
* Description : Controller to manage functionalities of OracleTableFieldMassEdit page.
* Copyright : CloudSPM
********************************************************************/

public with sharing class OracleTableFieldMassEditController {
    public map<String, List<SelectOption>> lookupColumns {get;set;}
    private ApexPages.StandardSetController thisController;
    
    public OracleTableFieldMassEditController(ApexPages.StandardSetController controller) {
    	this.thisController = controller;
    	List<Oracle_Table_Field__c> currFields = controller.getSelected();
    	if(currFields.size() == 0 || currFields == null) {
    		ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'No records selected, Please select some records to edit.'));	
    	} else {
    		this.lookupColumns = new map<String, List<SelectOption>>();
	    	composeLookupColumns(); 
    	}
    }
    
    /*
    *Function to compose lookup columns
    */
    public void composeLookupColumns() {
    	List<Oracle_Table_Field__c> currFields = this.thisController.getSelected();
    	set<Id> lookupManagerIds = new set<Id>();   
    	set<SelectOption> lookupColumnSet;
    	 
        for(Oracle_Table_Field__c field: currFields){
        	if(!lookupColumns.containsKey(field.Lookup_Name__c)) {
        		lookupManagerIds.add(field.Lookup_Name__c);	
        	}
        }   
    
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
    
}