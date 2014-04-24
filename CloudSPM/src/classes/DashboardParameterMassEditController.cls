public class DashboardParameterMassEditController{
    public string DashboardLayout;
    public string defaultName;
    public list<Dashboard_Parameter__c> ParameterList{get;set;}
    public set<Decimal> SequenceNumberSet;
    private set<Id> lookupManagerIds;
    public map<String, List<SelectOption>> lookupColumns {get;set;}
    
    public DashboardParameterMassEditController(){
        ParameterList = new list<Dashboard_Parameter__c>(); 
        defaultName = '';
        DashboardLayout = apexpages.currentpage().getparameters().get('id');
        Date dt = date.today();   
        this.lookupManagerIds = new set<Id>();      
               
        List<FC_Lookup_Detail__c> fcDetail = [select id,Row_Number__c from FC_Lookup_Detail__c where Column_Value__c =: UserInfo.getUserEmail() and Column_Name__c = 'EMAIL_ADDRESS' and FC_Lookup_Manager__r.Lookup_Name__c = 'Participant'];
        if(fcDetail != null && fcDetail.size()>0){
            List<FC_Lookup_Detail__c> fcDetail2 = [select id,Column_Value__c from FC_Lookup_Detail__c where Column_Name__c = 'PARTICIPANT_NAME' and FC_Lookup_Manager__r.Lookup_Name__c = 'Participant' and Row_Number__c =: fcDetail[0].Row_Number__c];
            if(fcDetail2 != null && fcDetail2.size()>0){
                defaultName = fcDetail2[0].Column_Value__c;
            }
        }
        ParameterList = [Select Display_Sequence__c,Lookup_Column__c,Name,Lookup_Name__c,Label__c, Id, Dashboard_Layout__c, Display__c, Required__c, Default_Value__c, Lookup_Name_Formula__c, Multi_Select__c From Dashboard_Parameter__c WHERE Dashboard_Layout__c =: DashboardLayout ORDER BY Display_Sequence__c];
        for(Dashboard_Parameter__c frc:ParameterList){
            this.lookupManagerIds.add(frc.Lookup_Name__c);     
            if(frc.Name.toLowerCase() == 'calendar."period year"'){                
                frc.Default_Value__c = String.ValueOf(dt.year());
            }
            if( frc.Name.toLowerCase() == 'participant."participant name"' && defaultName != ''){
                frc.Default_Value__c = defaultName;
            }
            
        }   
        
        composeLookupColumns(); 
    }
    
    public void composeLookupColumns() {
        
        for(Dashboard_Parameter__c frc:ParameterList){
            this.lookupManagerIds.add(frc.Lookup_Name__c);             
        }   
    
        this.lookupColumns = new map<String, List<SelectOption>>();
        set<SelectOption> lookupColumnSet;
        for(FC_Lookup_Detail__c currObject: [SELECT FC_Lookup_Manager__c , Column_Name__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__c=:this.lookupManagerIds]) {
        
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
    
    public pagereference save(){
        
        if(ParameterList!=null && ParameterList.size()>0){
            SequenceNumberSet = new set<Decimal>();
            boolean flage = true;
            
            for(Dashboard_Parameter__c p: ParameterList){
                if(p.Display_Sequence__c!=null){
                    if(p.Display_Sequence__c < 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sequence Number cannot be Negative('+p.Display_Sequence__c+').'));
                        flage = false;
                        break;                        
                    }else{
                        if(SequenceNumberSet.contains(p.Display_Sequence__c)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sequence Number cannot be Duplicate('+p.Display_Sequence__c+').'));
                            flage = false;
                            break;
                        }else{
                            SequenceNumberSet.add(p.Display_Sequence__c);
                        }
                    }
                }
            }
            if(flage){
                update ParameterList;
                return new pagereference('/'+DashboardLayout); 
            }
        }
        
        return null;
    }
}