global class APTSMD_CustomAgreementApprovalCls{
    
    Public String appReqId{get; set;}
    public string currencySymbol{get;set;}
    public List<Apttus_Approval__Approval_Request__c> appRequestList{get;set;}
    Public String recipientIdString{get; set;}
    Public String recipientName{get; set;}
    Public String AgreementId{get; set;}
    Public Apttus__APTS_Agreement__c agreementSo{get;set;}
    public string approvalSysPropertiesInstanceUrl{get;set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;}
    public Document lstDocument{get;set;}
    
    public APTSMD_CustomAgreementApprovalCls(){
         
        currencySymbol='-';
       /*   approvalRequestRecord=new Apttus_Approval__Approval_Request__c();
          approvalRequestRecord=[Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c, APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where id=:appReqId];*/
        lstDocument = [Select Id,Name from Document where Name ='New Apttus logo' limit 1];
        approvalSysPropertiesInstanceUrl=String.valueof([SELECT Apttus_Approval__InstanceUrl__c FROM Apttus_Approval__ApprovalsSystemProperties__c WHERE Name='System Properties' LIMIT 1].Apttus_Approval__InstanceUrl__c);
    }
    
    public Apttus_Approval__Approval_Request__c getAppReqDetail(){
        appRequestList= [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c, APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c
                from Apttus_Approval__Approval_Request__c
                Where id=:appReqId];
                
        if(appRequestList.size()>0){
            return appRequestList[0];
        }
        else
        {
            return null;
        }
                
        
    }
    
    public Apttus__APTS_Agreement__c GetAgreement(){
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList=[select id,name,APTSMD_AccountName__c,Apttus__Description__c,Apttus__FF_Agreement_Number__c,Apttus__Status_Category__c,Apttus__Status__c,Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c from Apttus__APTS_Agreement__c where id=:AgreementId];
        
        agreementSo = new Apttus__APTS_Agreement__c();
        
        if(agreementList.size()>0){
            agreementSo=agreementList[0];
        }
        
        return agreementSo;
    }
    
    Public List<Apttus_Approval__Approval_Request__c> GetApprovalHistory(){
    
        ListOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems = [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Workflow_Trigger_Added_Comments__c,APTSMD_Assigned_To_Actual_Approver__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_Approval__Related_Agreement__c =: AgreementId AND APTSMD_Assigned_To_Actual_Approver__c!=null order by id];
                
                
        return ListOfApprovalLineItems;
    
    }

}