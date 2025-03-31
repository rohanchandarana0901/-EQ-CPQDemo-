public class APTSMD_CustomQuoteApprovalCls {
	Public String appReqId{get; set;}
    public string currencySymbol{get;set;}
    public List<Apttus_Approval__Approval_Request__c> appRequestList{get;set;}
    Public String recipientIdString{get; set;}
    Public String recipientName{get; set;}
    Public String contractId{get; set;}
    Public Quote contractSo {get;set;}
    public string approvalSysPropertiesInstanceUrl{get;set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;}
    public Document lstDocument{get;set;}
    
    public APTSMD_CustomQuoteApprovalCls(){
         
        currencySymbol='-';
       
        //lstDocument = [Select Id,Name from Document where Name ='New Apttus logo' limit 1];
        approvalSysPropertiesInstanceUrl=String.valueof([SELECT Apttus_Approval__InstanceUrl__c FROM Apttus_Approval__ApprovalsSystemProperties__c WHERE Name='System Properties' LIMIT 1].Apttus_Approval__InstanceUrl__c);
    }
    
    public Apttus_Approval__Approval_Request__c getAppReqDetail(){
        appRequestList= [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment1__c,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c, 
                Apttus_Approval__Date__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
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
    
    public quote getContract(){
        List<quote> conList = new List<quote>();
        conList =[select id,name,status,AccountId,Account.Name   from quote where id=:contractId];
        
        contractSo = new quote();
        
        if(conList.size()>0){
            contractSo =conList[0];
        }
        
        return contractSo ;
    }
    
    Public List<Apttus_Approval__Approval_Request__c> GetApprovalHistory(){
    
        ListOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        ListOfApprovalLineItems = [Select Apttus_Approval__Internal_Comments__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__SubmissionComment2__c,Apttus_Approval__SubmissionComment3__c,
                                  Apttus_Approval__StepLabel__c, Apttus_Approval__Date__c, Apttus_Approval__Workflow_Trigger_Added_Comments__c,Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c, Apttus_Approval__Object_Id__c
                                   from Apttus_Approval__Approval_Request__c Where Apttus_Approval__Object_Id__c  =: contractId order by id];
                
                
        return ListOfApprovalLineItems;
    
    }
}