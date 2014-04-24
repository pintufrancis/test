/*******************************************************************
* File Name : OracleTableFieldEditController
* Description : Controller to manage functionalities of OracleTableFieldEdit page.
* Copyright : CloudSPM
********************************************************************/
public with sharing class OracleTableFieldEditController {
    public List<selectOption> objectList {get; private set;}
    private String lookupManagerId;
    private ApexPages.StandardController thisController;
    
    public OracleTableFieldEditController(ApexPages.StandardController stdController) {
        this.thisController = stdController;
        Oracle_Table_Field__c currField = (Oracle_Table_Field__c) stdController.getRecord();
        this.lookupManagerId = currField.Lookup_Name__c;
        
        this.objectList = composeColumnList();    
    }
    
    /*
    *Function for composing ColumnList
    */
    private List<selectOption> composeColumnList() {
        List<SelectOption> options = new List<SelectOption>();
        Set<SelectOption> optionsSet = new Set<SelectOption>();
         
        for(FC_Lookup_Detail__c currObject: [SELECT Column_Name__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c=:this.lookupManagerId ORDER BY Column_Name__c]) {
            optionsSet.add(new SelectOption(currObject.Column_Name__c, currObject.Column_Name__c));    
        }
        options.addAll(optionsSet);
        return options;    
    }
    
    public PageReference refreshColumnList() {
        Oracle_Table_Field__c currFieldTemp = (Oracle_Table_Field__c) this.thisController.getRecord();
        this.lookupManagerId = currFieldTemp.Lookup_Name__c;
        
        this.objectList = composeColumnList();  
        return null;    
    }
}