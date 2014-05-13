global class EditorsPickForContentBatchableContext implements Database.Batchable <Contact> {
    String editorsPicksString = '';
    
    global EditorsPickForContentBatchableContext() {        
        //Composing the Editors Picks string
        for(Content__c contentRecord: [SELECT Id, Content_Title__c, Url_inc_http__c, Content_Author__c, Topics_Taxonomy__c, SCM_Content_Type__c, Short_description__c  FROM  Content__c WHERE Editor_s_Pick__c = true]) {
            this.editorsPicksString += '%' + contentRecord.Content_Title__c + '#' + contentRecord.Url_inc_http__c + '#' + contentRecord.Content_Author__c + '#' + contentRecord.Short_description__c + '#' + contentRecord.Topics_Taxonomy__c+ '#' + contentRecord.SCM_Content_Type__c; 
        }
    }
    
    global Iterable <Contact> start(database.batchablecontext BC) {
        //Selecting active Members
        return [SELECT Id, Yourmembership_id__c, Editors_Pick_From_Content__c FROM Contact WHERE Yourmembership_id__c != null];    
    } 

    global void execute(Database.BatchableContext BC, List<Contact> pContacts) {
        List<Contact> contactList = new List<Contact>();
        
        for (Contact contactRecord : pContacts) {   
            contactRecord.Editors_Pick_From_Content__c = this.editorsPicksString;
           
            contactList.add(contactRecord);
        }
        
        //Updating the contact records
        Database.update(contactList, false);
    }
    
    global void finish(Database.BatchableContext info) {
            
    }    
}