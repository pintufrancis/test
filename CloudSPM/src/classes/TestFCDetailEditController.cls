/*
                Name        :        TestFCDetailEditController
                Author      :        CloudSPM
                Date        :        8 jan 2014
                Description :        This  controller is to test FCDetailEditController.

*/

@isTest
public class TestFCDetailEditController{
    
    @isTest
    public Static void demo(){
        //create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'test1'; 
        fcManager.Report_Name__c = 'test1';
        fcManager.Report_Path__c = 'test1';
        insert fcManager;
        system.assert(fcManager.id != null,'FC_Lookup_Manager is Not inserted');
        
        //create test FC_Lookup_Detail
        List<FC_Lookup_Detail__c> fcDetailList = new List<FC_Lookup_Detail__c>();
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 0;
            fcDetail.Column_Name__c = 'test';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
        insert fcDetailList;
        
        ApexPages.CurrentPage().getParameters().put('id',fcManager.id);
        ApexPages.CurrentPage().getParameters().put('row','0');
        
        FCDetailEditController fcDetail = new FCDetailEditController();
        
        system.assert(fcDetail.fcDetailList.size()>0,'N Records Found'); 
        
        for(FC_Lookup_Detail__c fcDet:fcDetail.fcDetailList){
            fcDet.Row_Number__c = 1;
        }
        fcDetail.updatefcDetail();
        
        List<FC_Lookup_Detail__c> tempList = [select id,FC_Lookup_Manager__c,Row_Number__c,Column_Name__c,Column_Sequence__c,Column_Value__c,Column_Format__c from FC_Lookup_Detail__c where FC_Lookup_Manager__c=:fcManager.id and Row_Number__c = 1 ];
        system.assert(tempList.size()>0,'Records not Updated');
    }
}