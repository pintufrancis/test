/*
                Name        :        TestFetchParameterValuesController
                Author      :        
                Date        :        6 jan 2014
                Description :        Test class for controller FetchParameterValuesController.

*/
@isTest
public class TestFetchParameterValuesController{
    @isTest
    private static void test(){
    	Oracle_Connection__c connection1 = new Oracle_Connection__c(Host__c='www.oraclefusionInstance.com', Port__c=443, Username__c='user', Password__c='pass',Status__c='Active',Service__c='Fusion Transactional Business Intelligence');
        insert connection1;
        System.assertEquals(connection1.Service__c, 'Fusion Transactional Business Intelligence');
        
        FetchParameterValuesController testObj=new FetchParameterValuesController();
        testObj.callServices();
        if(testObj.modelList.size()>0)
            testObj.modelList[0].check=true;
        testObj.saveRecords();
        List<Parameter_Values__c>parameterValues=[select id from Parameter_Values__c];
        //System.assertEquals(parameterValues.size(),1);
    }
}