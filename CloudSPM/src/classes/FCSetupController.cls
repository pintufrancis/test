public class FCSetupController{
    public boolean isAdminUser{get;set;}
    public List<FCModel> fcModelList{get;set;}
    public FCSetupController(){
        fcModelList = new List<FCModel>();
        User usr= [select id,name,Profile.Name from user where id=:UserInfo.getUserId()];
        isAdminUser = (usr.Profile.name == 'Platform System Admin' || usr.Profile.name == 'System Administrator')? true :false;
                
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Oracle_Connection__c', 'FICReportsConfiguration__c', 'FC_Lookup_Manager__c', 'Oracle_Table_Field__c', 'Salesforce_Oracle_Maps__c', 'SFMappingObjects__c', 'Dashboard_Layout__c', 'Dashboard_User_Map__c'});
        //Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Oracle_Connection__c', 'FICReportsConfiguration__c', 'FC_Lookup_Manager__c', 'Dashboard_Layout__c', 'Dashboard_User_Map__c'});
         
        for (integer i=0;i < descResult.size(); i++){
            DescribeSObjectResult desObj = descResult[i];
            FCModel fm = new FCModel();
            fm.label = desObj.getLabelPlural();
            fm.prefix = desObj.getKeyPrefix();
            fcModelList.add(fm);
        }
        FCModel fm = new FCModel();
        fm.label = 'Scheduler Screen';
        fm.prefix = 'apex/fusion__CustomSchedule';
        fcModelList.add(fm);
    }
    public class FCModel{
        public String label{get;set;}
        public String prefix{get;set;}
    }
}