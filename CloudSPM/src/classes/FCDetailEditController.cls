/*
                Name        :        FCDetailEditController
                Author      :        CloudSPM
                Date        :        8 jan 2014
                Description :        This  Controller Update FC Lookup Details records for the FC Lookup Managers .

*/
public class FCDetailEditController{
    public List<FC_Lookup_Detail__c> fcDetailList{get;set;}
    public String id{get;set;}
    public String rowIndex{get;set;}
    public FCDetailEditController(){
        //fetching FC Lookup Manager id
        id = ApexPages.CurrentPage().getParameters().get('id');
        //fetching row number
        rowIndex = ApexPages.CurrentPage().getParameters().get('row');
        
        //fetching FCDetail records
        if(id != null && rowIndex != null){
            fcDetailList = [select id,FC_Lookup_Manager__c,Row_Number__c,Column_Name__c,Column_Sequence__c,Column_Value__c,Column_Format__c from FC_Lookup_Detail__c where FC_Lookup_Manager__c=:id and Row_Number__c =: Integer.ValueOf(rowIndex) ];
        }
    }  
    public PageReference updateFCDetail(){
        //updating records
        update fcDetailList;        
        
        PageReference pg = new PageReference('/'+id);
        return pg.setRedirect(true);
    }  
}