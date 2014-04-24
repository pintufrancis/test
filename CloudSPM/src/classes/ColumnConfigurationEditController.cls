public class ColumnConfigurationEditController{
    public string FICReportsConfId;
    public list<ColumnConfiguration__c> ColumnConfigurationList{get;set;}
    public set<Decimal> ColumnSequenceSet;
    public set<Decimal> DisplaySequenceSet;
    
    public ColumnConfigurationEditController(){
        ColumnConfigurationList = new list<ColumnConfiguration__c>();
        
        FICReportsConfId = apexpages.currentpage().getparameters().get('id');
        
        ColumnConfigurationList = [Select Name, Id,Pecision__c, FIC_Reports_Configuration__c, Display__c, Mobile_Display__c, Display_Sequence__c, Column_Width__c, Column_Sequence__c, Column_Name__c, Column_Format__c, Pivot_Result__c, Pivot_Sequence__c From ColumnConfiguration__c WHERE FIC_Reports_Configuration__c =: FICReportsConfId ORDER BY Column_Sequence__c];
        
    }
    
    public pagereference save(){
        
        if(ColumnConfigurationList!=null && ColumnConfigurationList.size()>0){
            ColumnSequenceSet = new set<Decimal>();
            DisplaySequenceSet = new set<Decimal>();
            boolean flage = true;
            
            for(ColumnConfiguration__c c: ColumnConfigurationList){
                if(c.Column_Sequence__c!=null){
                    if(c.Column_Sequence__c>=0){
                        if(ColumnSequenceSet.contains(c.Column_Sequence__c)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Column Sequence cannot be Duplicate('+c.Column_Sequence__c+').'));
                            flage = false;
                            break;
                        }else{
                            ColumnSequenceSet.add(c.Column_Sequence__c);
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Column Sequence cannot be Negative('+c.Column_Sequence__c+').'));
                        flage = false;
                        break;
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Column Sequence is required.'));
                    flage = false;
                    break;
                }
                if(c.Display_Sequence__c!=null){
                    if(c.Display_Sequence__c>=0){
                        if(DisplaySequenceSet.contains(c.Display_Sequence__c)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Display Sequence cannot be Duplicate('+c.Display_Sequence__c+').'));
                            flage = false;
                            break;
                        }else{
                            DisplaySequenceSet.add(c.Display_Sequence__c);
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Display Sequence cannot be Negative('+c.Display_Sequence__c+').'));
                        flage = false;
                        break;
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Display Sequence is required.'));
                    flage = false;
                    break;
                }
            }
            if(flage){
                update ColumnConfigurationList;
                return new pagereference('/'+FICReportsConfId); 
            }
        }
        
        return null;
    }
}