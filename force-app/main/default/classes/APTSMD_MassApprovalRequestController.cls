public class APTSMD_MassApprovalRequestController {
    
    public string appReqListJSON {get;set;}
    public List<Apttus_Approval__Approval_Request__c> appReqList {get;set;}
    public list<APTSMD_approvalRequestWrapper> appReqWrapperList {get;set;}
    public string dateFormat {get;set;}
    
    public APTSMD_MassApprovalRequestController() {
        appReqListJSON='[]';
        appReqWrapperList = new list<APTSMD_approvalRequestWrapper>(); 
        appReqList = new List<Apttus_Approval__Approval_Request__c>();
        appReqList = [SELECT id,name,Apttus_Approval__ProcessInstanceId__c,Apttus_Approval__ProcessInstanceId__r.Name,Apttus_Approval__Approval_Status__c,Apttus_Approval__Date__c,Apttus_Approval__Assigned_To_Name__c,Apttus_Approval__Actual_Approver__r.Name,Apttus_Approval__Actual_Approver__c,Apttus_Approval__Approver_Comments__c, Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Object_Name__c,Apttus_Approval__Object_Id__c,Apttus_Approval__Object_Type__c
            From Apttus_Approval__Approval_Request__c
            where Apttus_Approval__Assigned_To_Id__c = :UserInfo.getUserId() AND Apttus_Approval__Approval_Status__c = 'Assigned' order by Apttus_Approval__Date__c];
        if(!appReqList.isEmpty()){
            for(Apttus_Approval__Approval_Request__c approvalRequests : appReqList){
                appReqWrapperList.add(new APTSMD_approvalRequestWrapper(approvalRequests));
            }
            appReqListJSON = JSON.serialize(appReqWrapperList);
        }
        this.dateFormat =  APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(false,''); 
    }   
    
    public static list<APTSMD_approvalRequestWrapper> init(){
        list<APTSMD_approvalRequestWrapper> appReqWrapperList = new list<APTSMD_approvalRequestWrapper>();
        list<Apttus_Approval__Approval_Request__c> appReqList = new List<Apttus_Approval__Approval_Request__c>();
        appReqList = [SELECT id,name,Apttus_Approval__ProcessInstanceId__c,Apttus_Approval__ProcessInstanceId__r.Name,Apttus_Approval__Approval_Status__c,Apttus_Approval__Date__c,Apttus_Approval__Assigned_To_Name__c,Apttus_Approval__Actual_Approver__r.Name,Apttus_Approval__Actual_Approver__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__Object_Name__c,Apttus_Approval__Object_Id__c,Apttus_Approval__Object_Type__c From Apttus_Approval__Approval_Request__c where Apttus_Approval__Assigned_To_Id__c = :UserInfo.getUserId() and Apttus_Approval__Date__c!=null and Apttus_Approval__Approval_Status__c!='Not Submitted' order by Apttus_Approval__Date__c];
        if(!appReqList.isEmpty()){
            for(Apttus_Approval__Approval_Request__c approvalRequests : appReqList){
                appReqWrapperList.add(new APTSMD_approvalRequestWrapper(approvalRequests));
            }
        }
        return appReqWrapperList;
    }
    @TestVisible
    public class APTSMD_approvalRequestWrapper{
        public boolean check {get;set;}
        public Apttus_Approval__Approval_Request__c approvalRequest{get;set;}
        public string objectLabel {get;set;}
        public APTSMD_approvalRequestWrapper(Apttus_Approval__Approval_Request__c approvalReq){
            check=false;
            approvalRequest = approvalReq;
            string apiName = approvalReq.Apttus_Approval__Object_Type__c;
            if(apiName != ''){
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{apiName}); // this can accept list of strings, we describe only one object here    
                if(describeSobjectsResult.size() > 0){
                    objectLabel = describeSobjectsResult[0].getLabel();    
                }else{
                    objectLabel = '';
                }
            }
        }
    }
    
    @RemoteAction
    public static list<APTSMD_approvalRequestWrapper> approve(string approvalRequestApproved,string wrapper){
   
        Apttus_Approval__Approval_Request__c approvedApprovalReq = new Apttus_Approval__Approval_Request__c();
        
        approvedApprovalReq = (Apttus_Approval__Approval_Request__c) JSON.deserialize(approvalRequestApproved, Apttus_Approval__Approval_Request__c.class);
        if(approvedApprovalReq!=null){
            try{
            	boolean result = Apttus_Approval.ApprovalsWebService.approveRequest(approvedApprovalReq.Id,'Approved through Mass Approval');    
            
                update approvedApprovalReq;
            }
            catch(Exception e){
                
            }
            
        }
   
        list<APTSMD_approvalRequestWrapper> appRequestWrapperList = new list<APTSMD_approvalRequestWrapper>();
        list<APTSMD_approvalRequestWrapper> appRequestWrapperLists = new list<APTSMD_approvalRequestWrapper>();
        
        appRequestWrapperLists = (list<APTSMD_approvalRequestWrapper>) JSON.deserialize(wrapper, list<APTSMD_approvalRequestWrapper>.class);
   
      appRequestWrapperList = init();
        
        for(APTSMD_approvalRequestWrapper a : appRequestWrapperList){
            for(APTSMD_approvalRequestWrapper ar : appRequestWrapperLists){
                if(a.approvalRequest.Id == ar.approvalRequest.Id){
                    a.check = ar.check;
                }
            }
        }
        
        return appRequestWrapperList;
    }
    @RemoteAction
    public static list<APTSMD_approvalRequestWrapper> reject(string approvalRequestApproved,string wrapper){
        Apttus_Approval__Approval_Request__c approvedApprovalReq = new Apttus_Approval__Approval_Request__c();
        
        approvedApprovalReq = (Apttus_Approval__Approval_Request__c) JSON.deserialize(approvalRequestApproved, Apttus_Approval__Approval_Request__c.class);
        if(approvedApprovalReq!=null){
            try{
            	boolean result = Apttus_Approval.ApprovalsWebService.rejectRequest(approvedApprovalReq.Id,'Rejected through Mass Approval');
        	    update approvedApprovalReq;
                
            }
            catch(Exception e){
                
            }
        }
   
        list<APTSMD_approvalRequestWrapper> appRequestWrapperList = new list<APTSMD_approvalRequestWrapper>();
        list<APTSMD_approvalRequestWrapper> appRequestWrapperLists = new list<APTSMD_approvalRequestWrapper>();
        appRequestWrapperLists = (list<APTSMD_approvalRequestWrapper>) JSON.deserialize(wrapper, list<APTSMD_approvalRequestWrapper>.class);
        
        
        appRequestWrapperList = init();
        
        for(APTSMD_approvalRequestWrapper a : appRequestWrapperList){
            for(APTSMD_approvalRequestWrapper ar : appRequestWrapperLists){
                if(a.approvalRequest.Id == ar.approvalRequest.Id){
                    a.check = ar.check;
                }
            }
        }
        
        return appRequestWrapperList;
    }
}