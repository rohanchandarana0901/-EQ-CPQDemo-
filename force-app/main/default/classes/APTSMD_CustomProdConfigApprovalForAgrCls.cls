global class APTSMD_CustomProdConfigApprovalForAgrCls{

    Public String appReqId{get; set;}
    public string currencySymbol{get;set;}
    public Apttus_Approval__Approval_Request__c AppReqDetail{get;set;}
    public List<Apttus_Approval__Approval_Request__c> appRequestList{get;set;} 
    public string approvalSysPropertiesInstanceUrl{get;set;}
    Public String recipientIdString{get; set;}
    Public String AgreementId{get; set;}
    public Document lstDocument{get;set;}
    Public String recipientName{get; set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;} 
    Public List<Apttus_Approval__Approval_Request__c> ListOfTermApprovalLineItems{get; set;}
    public Apttus__APTS_Agreement__c agreementSO{get;set;}
    public Apttus_Config2__ProductConfiguration__c prodConfig {get;set;}
    
    Public APTSMD_CustomProdConfigApprovalForAgrCls(){
        currencySymbol='-';
        lstDocument = [Select Id,Name from Document where Name ='New Apttus logo' limit 1];
        approvalSysPropertiesInstanceUrl=String.valueof([SELECT Apttus_Approval__InstanceUrl__c FROM Apttus_Approval__ApprovalsSystemProperties__c WHERE Name='System Properties' LIMIT 1].Apttus_Approval__InstanceUrl__c);
    }
    
   
    Public Apttus__APTS_Agreement__c GetAgreement(){
        getAppReqDetail();
        List<Apttus__APTS_Agreement__c> agreements = new List<Apttus__APTS_Agreement__c>();
        agreements = [SELECT Apttus__FF_Agreement_Number__c, APTSMD_AccountName__c, Name,
                      Apttus__Contract_End_Date__c, Apttus__Contract_Start_Date__c ,Apttus__Total_Contract_Value__c,
                      Apttus__Status__c, Apttus__Status_Category__c, Apttus_Approval__Approval_Status__c
                      FROM Apttus__APTS_Agreement__c 
                      WHERE Id =: AgreementId]; 
        agreementSO = new Apttus__APTS_Agreement__c();
        if(agreements.size() > 0) {
            agreementSO =  agreements[0];
              
        }
        
        return  agreementSO;               
    }
    
    public Apttus_Config2__ProductConfiguration__c getProductConfig() {
        
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id,APTSMD_Effective_Discount__c, APTSMD_Grand_Total__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_CMConfig__AgreementId__c =: AgreementId Order By CreatedDate Desc];
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
                                                                     WHERE Apttus_CMConfig__AgreementId__c =: AgreementId
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
        return ListOfLineItems;
    
    }

    Public List<Apttus_Approval__Approval_Request__c> GetApprovalHistory(){
        
        ListOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems = [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__StepLabel__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Workflow_Trigger_Added_Comments__c,APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_CQApprov__CartId__r.Apttus_CMConfig__AgreementId__c =: AgreementId AND APTSMD_Assigned_To_Actual_Approver__c!=null ORDER BY Id];
                
        return ListOfApprovalLineItems;
    
    }

    Public List<Apttus_Approval__Approval_Request__c> GetTermApprovalHistory(){
        
        ListOfTermApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems=[Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__StepLabel__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c, APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where Apttus_CQApprov__CartId__r.Apttus_CMConfig__AgreementId__c =:AgreementId AND (Apttus_Approval__Approval_Status__c!='Not Submitted' AND Apttus_Approval__Approval_Status__c!='Pending Approval' AND Apttus_Approval__Approval_Status__c!='Approval Required') ORDER BY Id];  
                
        return ListOfApprovalLineItems;
    
    }

     
     Public List<Task> GetTermActivityHistory(){
        
        List<Task> ListOfTermApprovalTask=new List<Task>();
        
        ListOfTermApprovalTask=[Select ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:AgreementId
                Order by CreatedDate ASC ];
                
        return ListOfTermApprovalTask;
    
    }
    
    Public List<Task> GetDiscountActivityHistory(){
        
        List<Task> ListOfDiscountApprovalTask=new List<Task>();
        
        ListOfDiscountApprovalTask=[Select ActivityDate, 
                CreatedDate, Description, Subject
                from Task
                Where whatid=:AgreementId
                Order by CreatedDate ASC ];
                
        return ListOfDiscountApprovalTask;
    
    }


}