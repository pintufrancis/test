/*******************************************************************
* File Name : CreateDisputeControllerTest
* Description : Test class for CreateDisputeController.
* Copyright : CloudSPM
********************************************************************/

@isTest
private class CreateDisputeControllerTest {

    static testMethod void myUnitTest() {
    	//create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager1 = new FC_Lookup_Manager__c();
        fcManager1.Lookup_Name__c = 'DisputeType'; 
        fcManager1.Report_Name__c = 'test1';
        fcManager1.Report_Path__c = 'test1';
        insert fcManager1;
        system.assert(fcManager1.id != null,'FC_Lookup_Manager is Not inserted');
        
        //create test FC_Lookup_Detail

        FC_Lookup_Detail__c fcDetail1 = new FC_Lookup_Detail__c();        
        fcDetail1.FC_Lookup_Manager__c = fcManager1.id;
        fcDetail1.Row_Number__c = 0;
        fcDetail1.Column_Name__c = 'LOOKUP_CODE';
        fcDetail1.Column_Sequence__c = 0;
        fcDetail1.Column_Value__c = 'test';
        fcDetail1.Column_Format__c = 'Number';
        insert fcDetail1;
        system.assert(fcDetail1.id != null,'FC_Lookup_Detail__c is Not inserted');
        
        FC_Lookup_Detail__c fcDetail2 = new FC_Lookup_Detail__c();        
        fcDetail2.FC_Lookup_Manager__c = fcManager1.id;
        fcDetail2.Row_Number__c = 0;
        fcDetail2.Column_Name__c = 'MEANING';
        fcDetail2.Column_Sequence__c = 1;
        fcDetail2.Column_Value__c = 'test';
        fcDetail2.Column_Format__c = 'Number';
        insert fcDetail2;
        system.assert(fcDetail2.id != null,'FC_Lookup_Detail__c is Not inserted');
        
        //create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager2 = new FC_Lookup_Manager__c();
        fcManager2.Lookup_Name__c = 'Participant'; 
        fcManager2.Report_Name__c = 'test1';
        fcManager2.Report_Path__c = 'test1';
        insert fcManager2;
        system.assert(fcManager2.id != null,'FC_Lookup_Manager is Not inserted');
        
        //create test FC_Lookup_Detail

        FC_Lookup_Detail__c fcDetail3 = new FC_Lookup_Detail__c();        
        fcDetail3.FC_Lookup_Manager__c = fcManager2.id;
        fcDetail3.Row_Number__c = 0;
        fcDetail3.Column_Name__c = 'EMAIL_ADDRESS';
        fcDetail3.Column_Sequence__c = 0;
        fcDetail3.Column_Value__c = UserInfo.getUserEmail();
        fcDetail3.Column_Format__c = 'Number';
        insert fcDetail3;
        system.assert(fcDetail3.id != null,'FC_Lookup_Detail__c is Not inserted');
        
		FC_Lookup_Detail__c fcDetail4 = new FC_Lookup_Detail__c();        
        fcDetail4.FC_Lookup_Manager__c = fcManager2.id;
        fcDetail4.Row_Number__c = 0;
        fcDetail4.Column_Name__c = 'PARTICIPANT_NAME';
        fcDetail4.Column_Sequence__c = 1;
        fcDetail4.Column_Value__c = 'name';
        fcDetail4.Column_Format__c = 'Number';
        insert fcDetail4;
        system.assert(fcDetail4.id != null,'FC_Lookup_Detail__c is Not inserted');
        
         //create test FC_Lookup_Manager
        FC_Lookup_Manager__c  fcManager3 = new FC_Lookup_Manager__c();
        fcManager3.Lookup_Name__c = 'MgrHierarchy'; 
        fcManager3.Report_Name__c = 'test1';
        fcManager3.Report_Path__c = 'test1';
        insert fcManager3;
        system.assert(fcManager3.id != null,'FC_Lookup_Manager is Not inserted');
        
        //create test FC_Lookup_Detail

        FC_Lookup_Detail__c fcDetail5 = new FC_Lookup_Detail__c();        
        fcDetail5.FC_Lookup_Manager__c = fcManager3.id;
        fcDetail5.Row_Number__c = 0;
        fcDetail5.Column_Name__c = 'MGR_EMAIL_ADDRESS';
        fcDetail5.Column_Sequence__c = 0;
        fcDetail5.Column_Value__c = UserInfo.getUserEmail();
        fcDetail5.Column_Format__c = 'Number';
        insert fcDetail5;
        system.assert(fcDetail5.id != null,'FC_Lookup_Detail__c is Not inserted');
        
		FC_Lookup_Detail__c fcDetail6 = new FC_Lookup_Detail__c();        
        fcDetail6.FC_Lookup_Manager__c = fcManager3.id;
        fcDetail6.Row_Number__c = 0;
        fcDetail6.Column_Name__c = 'PARTICIPANT_NAME';
        fcDetail6.Column_Sequence__c = 1;
        fcDetail6.Column_Value__c = 'name';
        fcDetail6.Column_Format__c = 'Number';
        insert fcDetail6;
        system.assert(fcDetail6.id != null,'FC_Lookup_Detail__c is Not inserted');
  
        
        CreateDisputeController controller = new CreateDisputeController();
        
        controller.quote();
        
        controller.getDispute();
        
        controller.cancel();
        
        controller.save();
        
        controller.getparticipants();
        
        controller.gettypes();
        
        controller.getttypes();
        
    }
}