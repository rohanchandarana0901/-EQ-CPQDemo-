public class APTSMD_CloneClausesHandler {
    
    public static void cloneAgreementClauses(String agreementId) {
        String soqlQuery = APTSMD_CloneUtils.getCreatableFieldsSOQL('Apttus__Agreement_Clause__c','Apttus__Agreement__c=\''+ agreementId + '\'');
        List<Apttus__Agreement_Clause__c> currentAgreementClauses = (List<Apttus__Agreement_Clause__c>)Database.query(soqlQuery);
        List<Apttus__Agreement_Clause__c> agreementClausesToInsert = new List<Apttus__Agreement_Clause__c>();
        Set<String> agreementClauseNameSet = new Set<String>();
        
        for(Apttus__Agreement_Clause__c currentAgreementClause : currentAgreementClauses){
            if(agreementClauseNameSet.contains(currentAgreementClause.Apttus__Clause__c)){
                continue;
            }else{
                agreementClauseNameSet.add(currentAgreementClause.Apttus__Clause__c);
            }
            
            Apttus__Agreement_Clause__c clonedAgreementClause = currentAgreementClause.clone(false,true,false,false);
            clonedAgreementClause.Apttus__Action__c = 'Final';
            clonedAgreementClause.Apttus__PreviousVersionId__c = currentAgreementClause.Id;
            clonedAgreementClause.Apttus__DiffText2__c = '';
            agreementClausesToInsert.add(clonedAgreementClause);
        }
        
        if(!agreementClausesToInsert.isEmpty()){
            insert agreementClausesToInsert;
        }
    }
    
}