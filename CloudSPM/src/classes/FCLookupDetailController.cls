/*
                Name        :        FCLookupDetailController
                Author      :        CloudSPM
                Date        :        8 jan 2014
                Description :        This  controller fetch FC Lookup Details of the FC Lookup Managers .

*/
public class FCLookupDetailController{
    public List<FC_Lookup_Detail__c> fcDetailList{get;set;}
    public Map<Integer,List<FC_Lookup_Detail__c>> fcDetailMap{get;set;}
    public List<Integer> keySetList{get;set;}
    public List<RowModel> rowList{get;set;}
    public List<String> headerValues{get;set;}
    public Integer rowIndex{get;set;}
    public String id{get;set;}
    
    public FCLookupDetailController(ApexPages.StandardController sc){
        fcDetailMap = new Map<Integer,List<FC_Lookup_Detail__c>>();
        keySetList = new List<Integer>();
        rowList = new List<RowModel>();
        headerValues = new List<String>();
        
        //getting record id
        id = sc.getRecord().id;
                
        //fetching FC Lookup Detail Records
        for(FC_Lookup_Detail__c fcDetail:[select id,FC_Lookup_Manager__c,Row_Number__c,Column_Name__c,Column_Sequence__c,Column_Value__c,Column_Format__c from FC_Lookup_Detail__c where FC_Lookup_Manager__c=:id order by Column_Name__c ]){
            Integer rowNo = Integer.ValueOf(fcDetail.Row_Number__c);
            List<FC_Lookup_Detail__c> tempList = fcDetailMap.get(rowNo);
            if(tempList == null)
                tempList = new List<FC_Lookup_Detail__c>();
            
            tempList.add(fcDetail);
            fcDetailMap.put(rowNo,tempList);
        }
        
        // add all map keys in list
        keySetList.addAll(fcDetailMap.keySet());
        
        //sort list according to key
        keySetList.sort();
        
        //fill record model rows
        Integer headerSize = 0;
        for(Integer i:keySetList){
            List<String> colList = new List<String>();                      
            RowModel row = new RowModel();
            List<FC_Lookup_Detail__c> tempList = fcDetailMap.get(i);
            if(tempList.size() > headerSize){
                headerSize = tempList.size();
            }
            
            if(headerSize != headerValues.size()){
                headerValues = new List<String>();
                for(FC_Lookup_Detail__c fcDetail:tempList ){
                    headerValues.add(fcDetail.Column_Name__c);
                }
            }
            for(FC_Lookup_Detail__c fcDetail:tempList ){                                
                colList.add(fcDetail.Column_Value__c);
            }
            row.columns = colList;
            row.index = i;
            rowList.add(row);
        }
    }
    // delete records row
    public void deleteRecords(){
        if(rowIndex != null){            
            List<FC_Lookup_Detail__c> tempList = fcDetailMap.get(integer.ValueOf(rowIndex));
            system.debug('@@@###'+fcDetailMap+ '###'+tempList );
            if(tempList != null && tempList.size()>0){
                try{
                    delete tempList;               
                }catch(exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            }            
        }
    }
    
    public class RowModel{
        public List<String> columns{get;set;}
        public Integer index{get;set;}
        public RowModel(){
            columns = new List<String>();
        }
    }
}