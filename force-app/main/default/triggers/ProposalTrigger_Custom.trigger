trigger ProposalTrigger_Custom on Apttus_Proposal__Proposal__c (after update) {
    
    Apttus_Proposal__Proposal__c proposal;
    
    for(Apttus_Proposal__Proposal__c pro: Trigger.new) {
        if(pro.Apttus_Proposal__Primary__c == true && pro.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && Trigger.oldMap.get(pro.id).Apttus_QPConfig__ConfigurationFinalizedDate__c != pro.Apttus_QPConfig__ConfigurationFinalizedDate__c){
            proposal = pro;
        }
    }
    
    if(proposal != null) {
       Id opportunityId = [SELECT Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.CurrencyIsoCode from Apttus_Proposal__Proposal__c where Id = :proposal.id]?.Apttus_Proposal__Opportunity__c;
       System.debug('@@@ opportunityId ' + opportunityId);

       if(opportunityId != null) {

           String currencyCode = [SELECT Apttus_Proposal__Opportunity__r.CurrencyIsoCode FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.id].Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
           List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLines = [SELECT id, Apttus_QPConfig__LineType__c, Apttus_Proposal__Product__c, Apttus_QPConfig__OptionId__c,
           Apttus_QPConfig__ListPrice__c, Apttus_QPConfig__NetUnitPrice__c, Apttus_QPConfig__NetPrice__c
           FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :proposal.id AND (Apttus_QPConfig__HasOptions__c = true OR (Apttus_Proposal__Product__r.Apttus_Config2__ConfigurationType__c = 'Standalone' AND Apttus_QPConfig__IsPrimaryLine__c = true AND Apttus_QPConfig__LineType__c = 'Product/Service'))];
           
           System.debug('@@@ Proposal Lines Count ' + lstProposalLines.size());

           if(!lstProposalLines.isEmpty()) {
                Map<id, List<Apttus_Proposal__Proposal_Line_Item__c>> mpProductIdToProposalLine = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
                for(Apttus_Proposal__Proposal_Line_Item__c proposalLine: lstProposalLines){
                    Id productId = proposalLine.Apttus_Proposal__Product__c;
                    if(proposalLine.Apttus_QPConfig__LineType__c == 'Option'){
                        productId = proposalLine.Apttus_QPConfig__OptionId__c;
                    }
                    if(mpProductIdToProposalLine.containsKey(productId)){
                        mpProductIdToProposalLine.get(productId).add(proposalLine);
                    } else {
                        mpProductIdToProposalLine.put(productId, new List<Apttus_Proposal__Proposal_Line_Item__c>{proposalLine});
                    }     
                }
            
                Map<id, PriceBookEntry> mpProductIdToPBE = new Map<Id, PriceBookEntry>();
                List<PriceBookEntry> pbeList = [SELECT Id, PriceBook2Id, Product2Id, CurrencyIsoCode, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2Id IN : mpProductIdToProposalLine.keySet() AND CurrencyIsoCode = :currencyCode];
                for(PriceBookEntry pbe: pbeList) {
                    mpProductIdToPBE.put(pbe.Product2.id, pbe);
                }
                
                System.debug('@@@ mpProductIdToPBE ' + mpProductIdToPBE);
                
                delete [SELECT Id from OpportunityLineItem where OpportunityId = :opportunityId];

                List<OpportunityLineItem> lstOpporunityLineItem = new List<OpportunityLineItem>();
                List<PriceBookEntry> lstPriceBookEntryToInsert = new List<PriceBookEntry>();
                for(Id productId: mpProductIdToProposalLine.keySet()){
                    for(Apttus_Proposal__Proposal_Line_Item__c proposalLine : mpProductIdToProposalLine.get(productId)){
                        PriceBookEntry pbe = mpProductIdToPBE.get(productId);
                        if(pbe == null) {
                            System.debug('@@ inside if PBE for proposal line ' + proposalLine.id + ', product ' + productId);
                            pbe = new PriceBookEntry();
                            pbe.PriceBook2Id = '01sHs000007ayLaIAI';
                            pbe.Product2Id = productId;
                            pbe.UnitPrice = 0;
                            pbe.IsActive = true;
                            pbe.CurrencyIsoCode = currencyCode;
                            lstPriceBookEntryToInsert.add(pbe);
                        }
                    }
                    
                    if(!lstPriceBookEntryToInsert.isEmpty()){
                       System.debug('@@@ insert PBE ' + lstPriceBookEntryToInsert);
                       insert lstPriceBookEntryToInsert;
                       lstPriceBookEntryToInsert = new List<PriceBookEntry>();
                    }

                    pbeList = [SELECT Id, PriceBook2Id, Product2Id, CurrencyIsoCode, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2Id IN : mpProductIdToProposalLine.keySet() AND CurrencyIsoCode = :currencyCode];
                    for(PriceBookEntry pbe: pbeList) {
                        mpProductIdToPBE.put(pbe.Product2.id, pbe);
                    }

                    for(Apttus_Proposal__Proposal_Line_Item__c proposalLine : mpProductIdToProposalLine.get(productId)){
                        PriceBookEntry pbe = mpProductIdToPBE.get(productId);
                        if(pbe == null) continue;

                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId = opportunityId;
                        oli.PricebookEntryId = pbe.Id;
                        oli.Quantity = 1;
                        //oli.UnitPrice = proposalLine.Apttus_QPConfig__NetUnitPrice__c;
                        oli.TotalPrice = proposalLine.Apttus_QPConfig__NetPrice__c;
                        oli.Product2Id = productId;
                        lstOpporunityLineItem.add(oli);
                    }        
                }
                insert lstOpporunityLineItem;
            }
       }
    }
}