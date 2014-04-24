/*
                Name        :        TestFCLookupDetailController
                Author      :        CloudSPM
                Date        :        8 jan 2014
                Description :        This  controller is to test TestFCLookupDetailController .

*/
@isTest
public class TestFCLookupDetailController{

    @isTest
    public static void demo(){
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
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcManager.id;
            fcDetail.Row_Number__c = 1;
            fcDetail.Column_Name__c = 'test';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }   
        insert fcDetailList;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(FcManager);
        
        FCLookupDetailController fcl = new FCLookupDetailController(sc);
        system.assert(fcl.rowList.size()>0,'No Records Found');
        
        fcl.rowIndex = 0;        
        fcl.deleteRecords();
        List<FC_Lookup_Detail__c> tempList= [select id from FC_Lookup_Detail__c where Row_Number__c =: fcl.rowIndex];
        system.assert(tempList.size()==0,'Records Not Delete');
        
    }
}