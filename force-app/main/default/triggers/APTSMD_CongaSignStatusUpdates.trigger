trigger APTSMD_CongaSignStatusUpdates on APXT_CongaSign__Transaction__c (after update) {
    if(Trigger.New.size() > 1){
        return;
    }
    
    APXT_CongaSign__Transaction__c congaSignTransaction = Trigger.New[0];
    APXT_CongaSign__Transaction__c congaSignTransactionOld = Trigger.Old[0];
     /* agreement conga sign part commented as product introduced integration package Date:14 Dec 2021
    if(congaSignTransaction.Parent_a0C__c != null) {
        if(congaSignTransaction.APXT_CongaSign__Status__c != congaSignTransactionOld.APXT_CongaSign__Status__c
            && congaSignTransaction.APXT_CongaSign__Status__c == 'SENT'){
            update new Apttus__APTS_Agreement__c(Id = congaSignTransaction.Parent_a0C__c, Apttus__Status__c = 'Other Party Signatures', Apttus__Status_Category__c = 'In Signatures');
        }
        
        if(congaSignTransaction.APXT_CongaSign__Status__c != congaSignTransactionOld.APXT_CongaSign__Status__c
            && congaSignTransaction.APXT_CongaSign__Status__c == 'COMPLETE'){
            update new Apttus__APTS_Agreement__c(Id = congaSignTransaction.Parent_a0C__c, Apttus__Status__c = 'Fully Signed', Apttus__Status_Category__c = 'In Signatures');
            //APTSMD_CloneClausesHandler.cloneAgreementClauses(congaSignTransaction.Parent_a0C__c);
            
            List<Apttus__DocumentVersion__c> documentVersionList = [Select Id From Apttus__DocumentVersion__c 
                                                            Where Apttus__AgreementId__c = :congaSignTransaction.Parent_a0C__c
                                                            And Apttus__DocumentType__c = 'Agreement Document'
                                                            Order By LastModifiedDate Desc];
            if(!documentVersionList.isEmpty()){
                Apttus.AgreementWebService.finalizeClausesForSendForSignature(congaSignTransaction.Parent_a0C__c, new List<Id>{documentVersionList[0].Id});
            }
    }
    }else*/ if(congaSignTransaction.Parent_a1X__c != null) {
        if(congaSignTransaction.APXT_CongaSign__Status__c != congaSignTransactionOld.APXT_CongaSign__Status__c
            && congaSignTransaction.APXT_CongaSign__Status__c == 'COMPLETE'){
            update new Apttus_Proposal__Proposal__c(Id = congaSignTransaction.Parent_a1X__c, Apttus_Proposal__Approval_Stage__c = 'Presented');
        }
    }else if(congaSignTransaction.Parent_006__c != null) {
        if(congaSignTransaction.APXT_CongaSign__Status__c != congaSignTransactionOld.APXT_CongaSign__Status__c
            && congaSignTransaction.APXT_CongaSign__Status__c == 'COMPLETE'){
            update new Opportunity(Id = congaSignTransaction.Parent_006__c, StageName = 'Closed Won');
        }
    }else if(congaSignTransaction.Parent_0Q0__c != null) {
        if(congaSignTransaction.APXT_CongaSign__Status__c != congaSignTransactionOld.APXT_CongaSign__Status__c
            && congaSignTransaction.APXT_CongaSign__Status__c == 'COMPLETE'){
            update new Quote(Id = congaSignTransaction.Parent_0Q0__c, Status= 'Accepted');
        }
    } 
}