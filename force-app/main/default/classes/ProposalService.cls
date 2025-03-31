global with sharing class ProposalService {
 
    @InvocableMethod
    public static List<Results> createProposal(List<Requests> requests) {
        System.debug('@@@ requests ' + requests);
        
        Requests req = requests[0];
        
        Id sourceProposalId = req.sourceProposalId;
        Id opportunityId = req.opportunityId;
        
        Integer proposalCount = getProposalCountForOpportunity(opportunityId);
        
        List<String> fields = new List<String>(Apttus_Proposal__Proposal__c.SObjectType.getDescribe().fields.getMap().keySet());
        String SOQL = 'SELECT ' + String.join(fields, ',') + ' from Apttus_Proposal__Proposal__c  where Id = :sourceProposalId';
        List<Apttus_Proposal__Proposal__c> lstProposals = Database.query(SOQL);
        Apttus_Proposal__Proposal__c sourceProposal = lstProposals[0];
        
        Apttus_Proposal__Proposal__c clonedProposal = sourceProposal.clone(false, true, false, false);
        clonedProposal.Apttus_Proposal__Opportunity__c = opportunityId;
        clonedProposal.Apttus_Proposal__Account__c = [select AccountId from opportunity where id = :opportunityId]?.AccountId;
        clonedProposal.Is_Proposal_Template__c = false;
        if(proposalCount == 0) {
            clonedProposal.Apttus_Proposal__Primary__c = true;
        }
        insert clonedProposal;
        
        Apttus_QPConfig.QPConfigWebService.copyProductConfiguration(sourceProposalId, clonedProposal.id);
     
        Results res = new Results();
        res.isSuccess = true;
        res.newProposalId = clonedProposal.id;
        
        List<Results> lstResults = new List<Results>();
        lstResults.add(res);
        
        return lstResults;
        
    }
    
    global class Requests {
        @InvocableVariable
        global String opportunityId;
        
        @InvocableVariable
        global String sourceProposalId;       
    }
    
    global class Results {
        @InvocableVariable
        global String newProposalId;
        @InvocableVariable
        global Boolean isSuccess;
    }
    
    public static Integer getProposalCountForOpportunity(Id opportunityId) {
        AggregateResult result = [
            SELECT COUNT(Id) proposalCount 
            FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_Proposal__Opportunity__c = :opportunityId
        ];

        // Return the count, ensuring it’s not null
        return (result != null) ? (Integer) result.get('proposalCount') : 0;
    }

}