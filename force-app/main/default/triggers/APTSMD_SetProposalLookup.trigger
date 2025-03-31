trigger APTSMD_SetProposalLookup on Apttus_QPConfig__ProposalUsagePriceTier__c (before insert) {
    List<Id> lineItemIdList = new List<Id>();
    Map<Apttus_QPConfig__ProposalUsagePriceTier__c,Id> usageTierLineItemMap = new Map<Apttus_QPConfig__ProposalUsagePriceTier__c,Id>();
    Map<Id,Id> lineItemProposalMap = new Map<Id,Id>();
    
    for(Apttus_QPConfig__ProposalUsagePriceTier__c usageTier : Trigger.new)
    {
        lineItemIdList.add(usageTier.Apttus_QPConfig__LineItemId__c);
        usageTierLineItemMap.put(usageTier, usageTier.Apttus_QPConfig__LineItemId__c);
    }
    
    for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : [select Id, Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id in :lineItemIdList])
    {
        lineItemProposalMap.put(proposalLineItem.Id, proposalLineItem.Apttus_Proposal__Proposal__c);
    }
    
    
    for(Apttus_QPConfig__ProposalUsagePriceTier__c usageTier : trigger.new)
    {
        usageTier.APTSMD_Quote_Proposal__c = lineItemProposalMap.get(usageTierLineItemMap.get(usageTier));
    }
    
}