/*******************************************************************
* File Name : ParameterEditOverrideController
* Description : Controller to manage functionalities of ParameterEdit page.
* Copyright : CloudSPM
********************************************************************/
public with sharing class ParameterEditOverrideController {
    public List<selectOption> objectList {get; private set;}
    private String parameterId;
    private ApexPages.StandardController thisController;
    
    public ParameterEditOverrideController(ApexPages.StandardController stdController) {
        this.thisController = stdController;
        Parameter__c currParameter = (Parameter__c) stdController.getRecord();
        this.parameterId = currParameter.Lookup_Name__c;
        
        this.objectList = composeColumnList();    
    }
    
    
    /*
    *Function for composing ColumnList
    */
    private List<selectOption> composeColumnList() {
        List<SelectOption> options = new List<SelectOption>();
        Set<SelectOption> optionsSet = new Set<SelectOption>();
         
        for(FC_Lookup_Detail__c currObject: [SELECT Column_Name__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c=:this.parameterId ORDER BY Column_Name__c]) {
            optionsSet.add(new SelectOption(currObject.Column_Name__c, currObject.Column_Name__c));    
        }
        options.addAll(optionsSet);
        return options;    
    }
    
    public PageReference refreshColumnList() {
        Parameter__c currParameterTemp = (Parameter__c) this.thisController.getRecord();
        this.parameterId = currParameterTemp.Lookup_Name__c;
        
        this.objectList = composeColumnList();  
        return null;    
    }
}