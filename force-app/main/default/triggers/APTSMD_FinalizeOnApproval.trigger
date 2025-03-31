trigger APTSMD_FinalizeOnApproval on Apttus_Config2__ProductConfiguration__c (after update) {
    if(Trigger.New.size() > 1){
        return;
    }
    
    if(Trigger.New[0].Apttus_CQApprov__Approval_Status__c == 'Approved' && Trigger.Old[0].Apttus_CQApprov__Approval_Status__c != Trigger.New[0].Apttus_CQApprov__Approval_Status__c){
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO finalRequest = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        finalRequest.CartId = Trigger.New[0].Id;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO finalResponse = Apttus_CPQApi.CPQWebService.finalizeCart(finalRequest);
    }
}