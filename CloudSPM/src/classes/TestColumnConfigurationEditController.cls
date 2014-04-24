/**
    Name : TestColumnConfigurationEditController
    Author : 
    Date : Jan 1, 2013
    Description : This controller is designed to test ColumnConfigurationEditController.
*/
@isTest
public class TestColumnConfigurationEditController{
    @isTest
    public static void test1(){
         // insert test FIC Reports Configuration
        FICReportsConfiguration__c fic = new FICReportsConfiguration__c();
        fic.Group__c = 'Reports';
        fic.Report_Name__c = 'Attainment Comparison Table Report';
        insert fic;
        system.assert(fic.id != null ,'FIC Reports Configuration is Not inserted');
        
         // insert test Column Configuration
        ColumnConfiguration__c colCon = new ColumnConfiguration__c();
        colCon.FIC_Reports_Configuration__c=fic.id;
        insert colCon;
        system.assert(colCon.id != null ,'Column Configuration is Not inserted');
        colCon = new ColumnConfiguration__c();
        colCon.FIC_Reports_Configuration__c=fic.id;
        insert colCon;
        system.assert(colCon.id != null ,'Column Configuration is Not inserted');
        
        //Putting parameter on current page
        apexpages.currentpage().getparameters().put('id',fic.id);
        //calling Constructor
        ColumnConfigurationEditController colObj = new ColumnConfigurationEditController();
        colObj.ColumnConfigurationList[0].Column_Sequence__c=-1; 
        colObj.ColumnConfigurationList[0].Display_Sequence__c=-1;
        colObj.save(); 
        colObj.ColumnConfigurationList[0].Column_Sequence__c=2; 
        colObj.ColumnConfigurationList[0].Display_Sequence__c=2;
        colObj.save(); 
        colObj.ColumnConfigurationList[0].Column_Sequence__c=3; 
        colObj.ColumnConfigurationList[0].Display_Sequence__c=3;
        colObj.ColumnConfigurationList[1].Column_Sequence__c=3; 
        colObj.ColumnConfigurationList[1].Display_Sequence__c=3;
        colObj.save();
        colObj.ColumnConfigurationList[1].Column_Sequence__c=4; 
        colObj.ColumnConfigurationList[1].Display_Sequence__c=4;
        colObj.save();
        
        list<ColumnConfiguration__c> colCnList = new list<ColumnConfiguration__c>([select id,
                                                                                  Column_Sequence__c,
                                                                                  Display_Sequence__c
                                                                                  from ColumnConfiguration__c]);
        system.assertEquals(colCnList[0].Column_Sequence__c,3);
        system.assertEquals(colCnList[0].Display_Sequence__c,3);
        system.assertEquals(colCnList[1].Column_Sequence__c,4);
        system.assertEquals(colCnList[1].Display_Sequence__c,4);
    }
}