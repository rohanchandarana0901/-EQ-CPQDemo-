trigger APTSMD_QuoteLineTrigger on QuoteLineItem (after insert, after update) {

    if(Trigger.isAfter && !APTSMD_ConstantVariables.isQuoteLineApprovalLogicDone){       
        APTSMD_ConstantVariables.isQuoteLineApprovalLogicDone = true; 
        Set<Id> QuoteIdsToUpdateApprovalStatus = new Set<Id>();
        List<QuoteLineItem> QLIToUpdate = new List<QuoteLineItem>();
        for(QuoteLineItem QLI : Trigger.New){
            if(QLI.APTSMD_Approval_Status__c == '' || QLI.APTSMD_Approval_Status__c == null || QLI.APTSMD_Approval_Status__c == 'Not Submitted'){
                Boolean isApprovalRequired = Apttus_Approval.ApprovalsWebService.isApprovalRequired('QuoteLineItem',QLI.Id);
                if(isApprovalRequired){
                    QLIToUpdate.add(new QuoteLineItem(Id = QLI.Id, APTSMD_Approval_Status__c = 'Approval Required'));
                    QuoteIdsToUpdateApprovalStatus.add(QLI.QuoteId);
                }
            }
        }
        if(!QuoteIdsToUpdateApprovalStatus.isEmpty()){
            // Update Quote Lines
            Update QLIToUpdate;
            // Update Quote Records
            List<Quote> quotesToUpdate = new List<Quote>();
            for(Id quoteId : QuoteIdsToUpdateApprovalStatus){
                quotesToUpdate.add(new Quote(Id = quoteId, APTSMD_Approval_Status__c = 'Approval Required'));
            }
            Update quotesToUpdate;
        }
    }

}