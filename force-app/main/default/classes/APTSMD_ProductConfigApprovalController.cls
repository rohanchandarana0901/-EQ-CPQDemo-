global class APTSMD_ProductConfigApprovalController{
    
    // Initialize Variables
    public String proposalId{get; set;}
    public List<Apttus_Approval__Approval_Request__c> listOfApprovalLineItems{get; set;}
    public List<Apttus_Approval__Approval_Request__c> listOfTermApprovalLineItems{get; set;}
    public Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public Apttus_Config2__ProductConfiguration__c prodConfig {get;set;} 
    public Map<String, String> participantsInfo {get;set;}
    public Map<String, Decimal> participantsAmountInfo {get;set;}
    public String currencyCode{get; set;}
    public Decimal totalAmount{get; set;}
    public Decimal totalTrxAmount{get; set;}
    public Decimal totalCommissionAmount{get; set;}
    public Decimal percentLiability{get; set;}
    public String instanseURL{get;set;}
    // Initialize Constructor
    public APTSMD_ProductConfigApprovalController(){
        instanseURL = System.URL.getOrgDomainUrl().toExternalForm();
    }
    
    // getProposal() - fetch proposal and return proposal
    public Apttus_Proposal__Proposal__c getProposal(){
        List<Apttus_Proposal__Proposal__c> proposals = new List<Apttus_Proposal__Proposal__c>();
        proposals = [SELECT Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Name,
                      Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c 
                      FROM Apttus_Proposal__Proposal__c 
                      WHERE Id =: proposalId]; 
        proposalSO = new Apttus_Proposal__Proposal__c();
        if(proposals.size() > 0) {
            proposalSO =  proposals[0];
        }
        return  proposalSO;               
    }

    // getListOfProposalLineItems() - Get list of proposal line item for particular proposal
    public List<Apttus_Proposal__Proposal_Line_Item__c> getListOfProposalLineItems(){
        List<Apttus_Proposal__Proposal_Line_Item__c> listOfProposalLineItems=new List<Apttus_Proposal__Proposal_Line_Item__c>();
        listOfProposalLineItems=[Select Apttus_Proposal__Quantity__c, 
                Apttus_Proposal__Unit_Price__c, 
                Apttus_Proposal__Sales_Discount__c,
                Apttus_Proposal__Ext_Net_Price__c,
                Apttus_Proposal__Description__c,
                Apttus_Proposal__Unit_Net_Price__c,
                Id,  
                Name,
                APTSMD_Product_or_Option_Name__c,
                Apttus_QPConfig__Term__c, Apttus_QPConfig__PriceUom__c ,
                Apttus_QPConfig__Quantity2__C, 
                Apttus_QPConfig__ExtendedPrice__c,
                Apttus_QPConfig__ItemSequence__c,
                Apttus_QPConfig__LineType__c,
                Apttus_QPConfig__ChargeType__c,
                Apttus_QPConfig__NetPrice__c
                from Apttus_Proposal__Proposal_Line_Item__c
                Where Apttus_Proposal__Proposal__c=:ProposalID];
        return listOfProposalLineItems;
    }
    
    // getProductConfig() - Get product configuration for particular proposal
    public Apttus_Config2__ProductConfiguration__c getProductConfig() {
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id, APTSMD_Effective_Discount__c, APTSMD_Grand_Total__c, Apttus_QPConfig__Proposald__r.CreatedBy.Name FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: ProposalID AND Apttus_Config2__Status__c!='Superseded'];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        return prodConfig;
    }
    
    // getStringWith2Decimals() - Function which returns string with 2 decimal places
    private String getStringWith2Decimals(String numberInput){
        if(numberInput.indexOf('.') > 0){
            if(numberInput.length() - numberInput.indexOf('.') < 3){
                return numberInput.subString(0, numberInput.indexOf('.') + 2);
            }
            return numberInput.subString(0, numberInput.indexOf('.') + 3);
        }
        return numberInput;
    }
    
    // getListOfLineItems() - Get list of line item for particular configuration
    public List<Apttus_Config2__LineItem__c> getListOfLineItems(){
        List<Apttus_Config2__LineItem__c> listOfLineItems = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id, APTSMD_Effective_Discount__c, APTSMD_Grand_Total__c
                                                                     FROM Apttus_Config2__ProductConfiguration__c 
                                                                     WHERE Apttus_QPConfig__Proposald__c =: ProposalID AND Apttus_Config2__Status__c!='Superseded'];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        if(prodConfig != null) {
            listOfLineItems=[Select APTSMD_Product_or_Option_name__c, Apttus_Config2__NetPrice__c ,Apttus_Config2__Quantity__c, 
            Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c,  Apttus_Config2__Guidance__c
                             from Apttus_Config2__LineItem__c
                             Where Apttus_Config2__ConfigurationId__c =: prodConfig.Id];
        }        
        return listOfLineItems;
    }

    // getApprovalHistory() - Get approval histrory for particular proposal
    public List<Apttus_Approval__Approval_Request__c> getApprovalHistory(){
    
        listOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        listOfApprovalLineItems = [Select Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalID];
        return listOfApprovalLineItems;
    }
    
    // getTermApprovalHistory() - Get term approval history for a paroposal
    public List<Apttus_Approval__Approval_Request__c> getTermApprovalHistory(){
        listOfTermApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        listOfApprovalLineItems=[Select Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where Apttus_QPApprov__ProposalId__c=:ProposalID
                AND Apttus_Approval__ProcessInstanceId__r.Apttus_Approval__ApprovalProcessId__r.Name='000023'];
        return listOfApprovalLineItems;
    
    }

    // getTermActivityHistory() - Get term activity history
    public List<Task> getTermActivityHistory(){
        List<Task> listOfTermApprovalTask=new List<Task>();
        listOfTermApprovalTask=[Select /*Approval_Process__c,*/ ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:ProposalID
               /* AND Approval_Process__c  like '%term%' */
                Order by CreatedDate ASC ];
        return listOfTermApprovalTask;
    }
    
    // getDiscountActivityHistory() - Get Discount Activity History
    public List<Task> getDiscountActivityHistory(){
        List<Task> listOfDiscountApprovalTask=new List<Task>();
        listOfDiscountApprovalTask=[Select /*Approval_Process__c,*/ ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:ProposalID
                /*AND Approval_Process__c like '%discount%' */
                Order by CreatedDate ASC ];
        return listOfDiscountApprovalTask;
    }


}