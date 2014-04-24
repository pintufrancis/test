@isTest
public class TestFCLookupManagerController{
    
    @isTest
    public static void demo(){
        //create test FC_Lookup_Manager
        FC_Lookup_Manager__c fcLookup = new FC_Lookup_Manager__c ();
        fcLookup.Lookup_Name__c = 'test';
        fcLookup.Report_Name__c = 'test Report';
        fcLookup.Report_Path__c = 'test path';
        insert fcLookup;
        
        //create test FC Lookup Detail
        List<FC_Lookup_Detail__c> fcDetailList = new List<FC_Lookup_Detail__c>();
        for(Integer i=0;i<=4;i++){
            FC_Lookup_Detail__c fcDetail = new FC_Lookup_Detail__c();        
            fcDetail.FC_Lookup_Manager__c = fcLookup.id;
            fcDetail.Row_Number__c = 0;
            fcDetail.Column_Name__c = 'test';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = 'test123';
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
        insert fcDetailList;
        
        //create test Oracle Connection
        Oracle_Connection__c connection = new Oracle_Connection__c();
        connection.Username__c = 'test@test.com';
        connection.Port__c = 444;
        connection.Password__c = '123';
        connection.Host__c = 'https://test.com';
        connection.Service__c = 'Fusion Transactional Business Intelligence';
        connection.Status__c ='Active';
        insert connection;
        
        ApexPages.CurrentPage().getParameters().put('id',fcLookup.id);
        
        FCLookupManagerController fcl = new FCLookupManagerController();
        fcl.fetchValues();
        
        List<FC_Lookup_Detail__c> fcDetail = [select id from FC_Lookup_Detail__c where Column_Format__c = 'Number' and Column_Value__c = 'test123' and FC_Lookup_Manager__c =: fcLookup.id];
        system.assert(fcDetail.size()==0,'Old Records Are Not Deleted');
        
        fcDetail = [select id from FC_Lookup_Detail__c where FC_Lookup_Manager__c =: fcLookup.id];
        system.assert(fcDetail.size()>0,'Old Records Are Not Deleted');
    }
}