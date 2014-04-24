/*******************************************************************
* File Name : SalesforceOracleMapEditController
* Description : Controller to manage functionalities of SalesforceOracleMapEdit page.
* Copyright : CloudSPM
********************************************************************/

public with sharing class SalesforceOracleMapEditController {
	public List<selectOption> objectList {get; private set;} 
	
	public salesforceOracleMapEditController(ApexPages.StandardController stdController) {
		this.objectList = composeObjectList();	
	}
	
	/*
    *Function for fetching the available onbjects and composing Select list
    */
	public List<selectOption> composeObjectList() {
		List<SelectOption> options = new List<SelectOption>();
		for(SFMappingObjects__c currObject: [SELECT SF_Object__c FROM SFMappingObjects__c WHERE  SF_Object__c != null ORDER BY SF_Object__c]) {
			options.add(new SelectOption(currObject.SF_Object__c, currObject.SF_Object__c));	
		}
		return options;	
	}

}