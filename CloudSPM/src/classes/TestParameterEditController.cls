/**
    Name : TestParameterEditController
    Author : 
    Date : Jan 1, 2013
    Description : This controller is designed to test ParameterEditController.
*/

@isTest
public class TestParameterEditController{
    @isTest
    public static void test1(){
    	//create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager = new FC_Lookup_Manager__c();
        fcManager.Lookup_Name__c = 'Participant'; 
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
            fcDetail.Column_Name__c = 'EMAIL_ADDRESS';
            fcDetail.Column_Sequence__c = i;
            fcDetail.Column_Value__c = UserInfo.getUserEmail();
            fcDetail.Column_Format__c = 'Number';
            fcDetailList.add(fcDetail);
        }  
  		fcDetailList[0].Column_Name__c = 'PARTICIPANT_NAME';
  		
        insert fcDetailList;
        
        // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
        
        
        
        //insert test parameters for FICReportsConfiguration
        Parameter__c param = new Parameter__c();
        param.Name = 'calendar."period year"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Lookup_Name__c = fcManager.id;
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');
        
        param = new Parameter__c();
        param.Name = 'participant."participant name"';
        param.FIC_Reports_Configuration__c = fic.id;
        param.Lookup_Name__c = fcManager.id;
        param.Label__c = 'Participant Name';
        insert param;
        system.assert(param.id != null ,'parameter is Not inserted');
        
        //putting test value on current page
        apexpages.currentpage().getparameters().put('id',fic.id); 
        // calling constructor       
        ParameterEditController par= new ParameterEditController();
        par.ParameterList[0].Sequence_Number__c=-1; 
        par.save();
        par.ParameterList[0].Sequence_Number__c=1; 
        par.ParameterList[1].Sequence_Number__c=1; 
        par.save(); 
        par.ParameterList[1].Sequence_Number__c=2; 
        par.save();
        list<Parameter__c> parTempList = new list<Parameter__c>([select id,
                                                                Sequence_Number__c 
                                                                from Parameter__c]);
        system.assertEquals(parTempList[0].Sequence_Number__c,1);
        system.assertEquals(parTempList[1].Sequence_Number__c,2);
    }
}