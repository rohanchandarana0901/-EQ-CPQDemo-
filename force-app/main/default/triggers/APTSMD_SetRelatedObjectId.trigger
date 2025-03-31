/**
 * @description       : 
 * @author            : Japan Bhavsar
 * @group             : 
 * @last modified on  : 04-12-2023
 * @last modified by  : Japan Bhavsar
**/
trigger APTSMD_SetRelatedObjectId on Apttus_Approval__Approval_Request__c (before update) {

    //added by vivek as on 30 Nov 2022 to hide system generated approval request records 
    if(Trigger.isUpdate && Trigger.isBefore){
        for(Apttus_Approval__Approval_Request__c approvalRequest : Trigger.new){
            if((approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus__APTS_Agreement__c' 
                    || approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus_Config2__ProductConfiguration__c'
                    || approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus__ClauseApproval__c') 
                && (approvalRequest.Apttus_Approval__Request_Comments__c != null
                && approvalRequest.Apttus_Approval__Request_Comments__c.equals('For system use only. No action needed'))){
                    approvalRequest.Apttus_Approval__Related_Agreement__c = null;
                    approvalRequest.Apttus_QPApprov__ProposalId__c = null;
                    approvalRequest.APTSMD_Clause_Approval__c = null;
            }
        }
    }

    Set<Id> configIds = new Set<Id>();
    for(Apttus_Approval__Approval_Request__c approvalRequest : Trigger.New){
        if(approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus_Config2__ProductConfiguration__c'
            || approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus__ClauseApproval__c'){
            configIds.add(approvalRequest.Apttus_Approval__Object_Id__c);
        }
    }
    if(configIds.isEmpty()){
        //return;
    }
    Map<Id, Apttus_Config2__ProductConfiguration__c> prodConfigMap = new Map<Id, Apttus_Config2__ProductConfiguration__c>([Select Id, Apttus_QPConfig__Proposald__c From Apttus_Config2__ProductConfiguration__c Where Id in :configIds]);
   
    for(Apttus_Approval__Approval_Request__c approvalRequest : Trigger.New){
        if(!(approvalRequest.Apttus_Approval__Request_Comments__c != null 
                && approvalRequest.Apttus_Approval__Request_Comments__c.equals('For system use only. No action needed'))){
            if(approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus_Config2__ProductConfiguration__c'){
                if(prodConfigMap.get(approvalRequest.Apttus_Approval__Object_Id__c) != null){
                    approvalRequest.Apttus_QPApprov__ProposalId__c = prodConfigMap.get(approvalRequest.Apttus_Approval__Object_Id__c).Apttus_QPConfig__Proposald__c;
                }
            }else if(approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus__ClauseApproval__c'){
                approvalRequest.APTSMD_Clause_Approval__c = approvalRequest.Apttus_Approval__Object_Id__c;
            }else if(approvalRequest.Apttus_Approval__Object_Type__c == 'Quote'){
                approvalRequest.APTSMD_Quote__c = approvalRequest.Apttus_Approval__Object_Id__c;
            }
        }
        
    }
}