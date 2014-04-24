/*******************************************************************
* File Name : DashboardParameterEditController
* Description : Controller to manage functionalities of ParameterEdit page.
* Copyright : CloudSPM
********************************************************************/
public with sharing class DashboardParameterEditController {
    public List<selectOption> objectList {get; private set;}
    private String parameterId;
    private ApexPages.StandardController thisController;
    
    public DashboardParameterEditController(ApexPages.StandardController stdController) {
        this.thisController = stdController; 
        Dashboard_Parameter__c currParameter = (Dashboard_Parameter__c) stdController.getRecord();
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
        Dashboard_Parameter__c currParameterTemp = (Dashboard_Parameter__c) this.thisController.getRecord();
        this.parameterId = currParameterTemp.Lookup_Name__c;
        
        this.objectList = composeColumnList();  
        return null;    
    }
}