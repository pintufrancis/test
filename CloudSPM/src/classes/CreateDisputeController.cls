public class CreateDisputeController {
	public Map<String, List<selectOption>> selectLists {get; private set;} 
	public Dispute dispute = new Dispute();
    
	public CreateDisputeController() {
		composeSelectLists();
		
         // getting current login user email address
         List<FC_Lookup_Detail__c> fcDetailRow = [SELECT id,Row_Number__c FROM FC_Lookup_Detail__c WHERE Column_Value__c =: UserInfo.getUserEmail() AND Column_Name__c = 'EMAIL_ADDRESS' AND FC_Lookup_Manager__r.Lookup_Name__c = 'Participant'];
         if(fcDetailRow != null && fcDetailRow.size() > 0){
             List<FC_Lookup_Detail__c> fcDetailValue = [SELECT id,Column_Value__c FROM FC_Lookup_Detail__c WHERE Column_Name__c = 'PARTICIPANT_NAME' AND FC_Lookup_Manager__r.Lookup_Name__c = 'Participant' AND Row_Number__c =: fcDetailRow[0].Row_Number__c];
             if(fcDetailValue != null && fcDetailValue.size() > 0){
                 dispute.participantName = fcDetailValue[0].Column_Value__c;
             }
         }

	}
	
	public Dispute getDispute() {
        return dispute;
    }
	
	/*
	*Function to compose picklist values for the Lookup column
	*/
	private void composeSelectLists() {
		this.selectLists = new Map<String, List<SelectOption>>{'Trx Type' => new List<SelectOption>(), 'DisputeType' => new List<SelectOption>()};
		SelectOption option;				
        for(FC_Lookup_Detail__c currObject: [SELECT FC_Lookup_Manager__r.Lookup_Name__c , Column_Name__c, Column_Value__c FROM FC_Lookup_Detail__c WHERE FC_Lookup_Manager__r.Lookup_Name__c IN('Trx Type','DisputeType') AND Column_Name__c IN ('MEANING','LOOKUP_CODE') ORDER BY FC_Lookup_Manager__c, Row_Number__c, Column_Name__c]) {
        	String key = currObject.FC_Lookup_Manager__r.Lookup_Name__c;
            if(currObject.Column_Name__c == 'LOOKUP_CODE') {
        		option = new SelectOption('','');	
        		option.setValue(currObject.Column_Value__c);
        	} else if(currObject.Column_Name__c == 'MEANING') {
        		option.setLabel(currObject.Column_Value__c);	
        		
        		if(this.selectLists.containsKey(key)) {
	        		(this.selectLists.get(key)).add(option);  
	            } 
        	}
            
        }
        
        //fetching the participants and setting to picklist
        this.selectLists.put('MgrHierarchy', getParticipantList()); 
	}
	
	public List<Selectoption> getParticipantList(){
    	List<Selectoption> options = new List<Selectoption>();
    	options.add(new SelectOption('','--Select Value--'));
        User user = [Select Email From User where id = : Userinfo.getUserId() limit 1];
        
        List<Decimal> rowNumbers = new List<Decimal>();
        for(FC_Lookup_Detail__c fc:[select Row_Number__c from FC_Lookup_Detail__c
								where Column_Name__c='MGR_EMAIL_ADDRESS' and Column_Value__c=:user.Email and
								FC_Lookup_Manager__c in (select id from FC_Lookup_Manager__c where Lookup_Name__c='MgrHierarchy')]){
				rowNumbers.add(fc.Row_Number__c);					
		}
								 
       for(FC_Lookup_Detail__c fc:[select Column_Value__c,Column_Name__c from FC_Lookup_Detail__c where
							FC_Lookup_Manager__c in (select id from FC_Lookup_Manager__c where Lookup_Name__c='MgrHierarchy')
							AND Row_Number__c IN :rowNumbers and Column_Name__c ='PARTICIPANT_NAME']){
								options.add(new Selectoption(fc.Column_Value__c,fc.Column_Value__c));		
		} 
		return options;		                        	
    }
	
    public PageReference quote() {
    
    StockQuoteService.StockQuoteSoap ws = new StockQuoteService.StockQuoteSoap();
   String quoteValue = ws.GetQuote(dispute.quoteStr);
   dispute.stockValue = quoteValue;
     /*  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'my error msg  '+quoteValue);
     ApexPages.addMessage(myMsg );*/
        return null;
    } 

    public PageReference cancel() {
        return null;
    }


    public PageReference save() {
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Saved Succesfully');
     ApexPages.addMessage(myMsg );
        return null;
    }
    
     
    public class Dispute{
        public String participantName{ get; set; }
        public String type { get; set; }
        public String summary { get; set; }
        public String justification { get; set; }
        public String description{ get; set; }

        public String ttype { get; set; }
        public String actualCrAmount{ get; set; }
        public String transactionNumber { get; set; }
        public String expectedAmount { get; set; }
        public Date eventDate{ get; set; }
        public String currencyType{ get; set; }
        public String quoteStr {get; set;}
         public String stockValue {get; set;}
        


    }
    public List<selectOption> getparticipants() {
    List<selectOption> options = new List<selectOption>(); 
//new list for holding all of the picklist options
        options.add(new selectOption('', '-- Select --')); 

        options.add(new selectOption('Participant1', 'Participant1')); 
                options.add(new selectOption('Participant2', 'Participant2')); 
        options.add(new selectOption('Participant3', 'Participant3')); 
        options.add(new selectOption('Participant4', 'Participant4')); 

        return options; //return the picklist options
    }
    public List<selectOption> gettypes() {
    List<selectOption> options = new List<selectOption>(); 
//new list for holding all of the picklist options
        options.add(new selectOption('', '-- Select --')); 
        options.add(new selectOption('InCorrect Credit1', 'InCorrect Credit1')); 
                options.add(new selectOption('InCorrect Credit2', 'InCorrect Credit2')); 
        options.add(new selectOption('InCorrect Credit3', 'InCorrect Credit3')); 

        return options; //return the picklist options
    }
    
    public List<selectOption> getttypes() {
    List<selectOption> options = new List<selectOption>(); 
//new list for holding all of the picklist options
        options.add(new selectOption('', '-- Select --')); 
        options.add(new selectOption('Accounts receivable revenue adjustment', 'Accounts receivable revenue adjustment')); 
        options.add(new selectOption('test', 'test')); 

        return options; //return the picklist options
    }

}