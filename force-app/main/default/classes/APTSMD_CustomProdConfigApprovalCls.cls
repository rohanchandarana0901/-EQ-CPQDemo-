global class APTSMD_CustomProdConfigApprovalCls{

    Public String appReqId{get; set;}
    public string currencySymbol{get;set;}
    public Apttus_Approval__Approval_Request__c AppReqDetail{get;set;}
    public List<Apttus_Approval__Approval_Request__c> appRequestList{get;set;} 
    public string approvalSysPropertiesInstanceUrl{get;set;}
    Public String recipientIdString{get; set;}
    Public String ProposalId{get; set;}
    public Document lstDocument{get;set;}
    Public String recipientName{get; set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;} 
    Public List<Apttus_Approval__Approval_Request__c> ListOfTermApprovalLineItems{get; set;}
    public Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public Apttus_Config2__ProductConfiguration__c prodConfig {get;set;}
    
    Public APTSMD_CustomProdConfigApprovalCls(){
        currencySymbol='-';
        lstDocument = [Select Id,Name from Document where Name ='New Apttus logo' limit 1];
        approvalSysPropertiesInstanceUrl=String.valueof([SELECT Apttus_Approval__InstanceUrl__c FROM Apttus_Approval__ApprovalsSystemProperties__c WHERE Name='System Properties' LIMIT 1].Apttus_Approval__InstanceUrl__c);
    }
    
   
    Public Apttus_Proposal__Proposal__c GetProposal(){
        getAppReqDetail();
        List<Apttus_Proposal__Proposal__c> proposals = new List<Apttus_Proposal__Proposal__c>();
        proposals = [SELECT Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Name,
                      Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c ,APTSMD_Discounted_Price_Display__c,
                      APTSMD_Effective_Discount__c,Apttus_Proposal__Approval_Stage__c,Apttus_QPApprov__Approval_Status__c
                      FROM Apttus_Proposal__Proposal__c 
                      WHERE Id =: ProposalId]; 
        proposalSO = new Apttus_Proposal__Proposal__c();
        if(proposals.size() > 0) {
            proposalSO =  proposals[0];
              
        }
        
        return  proposalSO;               
    }

    Public List<Apttus_Proposal__Proposal_Line_Item__c> GetListOfProposalLineItems(){
        
        List<Apttus_Proposal__Proposal_Line_Item__c> ListOfProposalLineItems=new List<Apttus_Proposal__Proposal_Line_Item__c>();
        
        ListOfProposalLineItems=[Select Apttus_Proposal__Quantity__c, 
                Apttus_Proposal__Unit_Price__c, 
                Apttus_Proposal__Sales_Discount__c,
                Apttus_Proposal__Ext_Net_Price__c,
                Apttus_Proposal__Description__c,
                Apttus_Proposal__Unit_Net_Price__c,
                Id, Apttus_QPConfig__ListPrice__c, 
                Name,Apttus_QPConfig__NetAdjustmentPercent__c,Apttus_QPConfig__AdjustmentAmount__c,
                APTSMD_Product_or_Option_Name__c,Apttus_QPConfig__Guidance__c,
                Apttus_QPConfig__Term__c, Apttus_QPConfig__PriceUom__c ,
                Apttus_QPConfig__Quantity2__C, 
                Apttus_QPConfig__ExtendedPrice__c,
                Apttus_QPConfig__ItemSequence__c,
                Apttus_QPConfig__LineType__c,
                Apttus_QPConfig__ChargeType__c,
                Apttus_QPConfig__NetPrice__c
                from Apttus_Proposal__Proposal_Line_Item__c
                Where Apttus_Proposal__Proposal__c=:ProposalID];
        currencySymbol= string.valueOf(ListOfProposalLineItems[0].Apttus_QPConfig__NetPrice__c).replace(String.valueOf(Double.valueOf(ListOfProposalLineItems[0].Apttus_QPConfig__NetPrice__c)),'').trim();  
        return ListOfProposalLineItems;
    
    }
    
    public Apttus_Config2__ProductConfiguration__c getProductConfig() {
        
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id,APTSMD_Effective_Discount__c, APTSMD_Grand_Total__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: ProposalID Order By CreatedDate Desc];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        
        return prodConfig;
    }
    
    public Apttus_Approval__Approval_Request__c getAppReqDetail(){
        
        AppReqDetail = new Apttus_Approval__Approval_Request__c();
        appRequestList= [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__StepLabel__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c, APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where id=:appReqId];
                
        if(appRequestList.size()>0){
            AppReqDetail=appRequestList[0];
            
        }
        return AppReqDetail;
                
        
    }
    
    Public List<Apttus_Config2__LineItem__c> GetListOfLineItems(){
        
        List<Apttus_Config2__LineItem__c> ListOfLineItems = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id, APTSMD_Effective_Discount__c, APTSMD_Grand_Total__c
                                                                     FROM Apttus_Config2__ProductConfiguration__c 
                                                                     WHERE Apttus_QPConfig__Proposald__c =: ProposalID
                                                                     Order By CreatedDate Desc];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        if(prodConfig != null) {
            ListOfLineItems=[Select APTSMD_Product_or_Option_Name__c, Apttus_Config2__NetPrice__c , Apttus_Config2__Quantity__c,Apttus_Config2__ListPrice__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c,  Apttus_Config2__Guidance__c
                             from Apttus_Config2__LineItem__c
                             Where Apttus_Config2__ConfigurationId__c =: prodConfig.Id];
            for(Apttus_Config2__LineItem__c li:ListOfLineItems){
                li.Apttus_Config2__NetPrice__c=li.Apttus_Config2__NetPrice__c == null ? 0.0 : li.Apttus_Config2__NetPrice__c.setScale(2);
                li.Apttus_Config2__ListPrice__c=li.Apttus_Config2__ListPrice__c == null ? 0.0 : li.Apttus_Config2__ListPrice__c.setScale(2);
                li.Apttus_Config2__NetAdjustmentPercent__c = li.Apttus_Config2__NetAdjustmentPercent__c == null ? 0.0 : li.Apttus_Config2__NetAdjustmentPercent__c.setScale(2);
                li.Apttus_Config2__AdjustmentAmount__c= li.Apttus_Config2__NetAdjustmentPercent__c;
                if(li.Apttus_Config2__NetAdjustmentPercent__c<0){
                    li.Apttus_Config2__AdjustmentAmount__c=li.Apttus_Config2__AdjustmentAmount__c == null ? 0.0 : li.Apttus_Config2__AdjustmentAmount__c*(-1);
                }
            }
        }      
        //currencySymbol= string.valueOf(ListOfLineItems[0].Apttus_Config2__NetPrice__c).replace(String.valueOf(Double.valueOf(ListOfLineItems[0].Apttus_Config2__NetPrice__c)),'').trim();  
        return ListOfLineItems;
    
    }

    Public List<Apttus_Approval__Approval_Request__c> GetApprovalHistory(){
        
        ListOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems = [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__StepLabel__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Workflow_Trigger_Added_Comments__c,APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalID AND APTSMD_Assigned_To_Actual_Approver__c!=null ORDER BY Id];
                //AND (Apttus_Approval__Approval_Status__c!='Not Submitted' AND Apttus_Approval__Approval_Status__c!='Pending Approval' AND Apttus_Approval__Approval_Status__c!='Approval Required') AND Apttus_Approval__ProcessInstanceId__r.Apttus_Approval__ApprovalProcessId__r.Name='000000'];
                
        return ListOfApprovalLineItems;
    
    }

    Public List<Apttus_Approval__Approval_Request__c> GetTermApprovalHistory(){
        
        ListOfTermApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems=[Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__StepLabel__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c, APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where Apttus_QPApprov__ProposalId__c=:ProposalID AND (Apttus_Approval__Approval_Status__c!='Not Submitted' AND Apttus_Approval__Approval_Status__c!='Pending Approval' AND Apttus_Approval__Approval_Status__c!='Approval Required') ORDER BY Id];  
                
        return ListOfApprovalLineItems;
    
    }

     
     Public List<Task> GetTermActivityHistory(){
        
        List<Task> ListOfTermApprovalTask=new List<Task>();
        
        ListOfTermApprovalTask=[Select /*Approval_Process__c,*/ ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:ProposalID
               /* AND Approval_Process__c  like '%term%' */
                Order by CreatedDate ASC ];
                
        return ListOfTermApprovalTask;
    
    }
    
    Public List<Task> GetDiscountActivityHistory(){
        
        List<Task> ListOfDiscountApprovalTask=new List<Task>();
        
        ListOfDiscountApprovalTask=[Select /*Approval_Process__c,*/ ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:ProposalID
                /*AND Approval_Process__c like '%discount%' */
                Order by CreatedDate ASC ];
                
        return ListOfDiscountApprovalTask;
    
    }


}