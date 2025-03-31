// Class Name: APTSMD_AddFinalClausesController 
// Description: This class is use for amend clauses.
public class APTSMD_AddFinalClausesController {
    
    // Initialize variables
    public String agreementClausesJSON {get; set;}
    public String errorMessage {get; set;}
    public String inputId {get; set;}
    public Apttus__APTS_Agreement__c mainAgreement {get; set;}
    
    // APTSMD_AddFinalClausesController - Initialize Constructor
    public APTSMD_AddFinalClausesController(){
        inputId = ApexPages.currentPage().getParameters().get('id');
        mainAgreement = [Select Id, Apttus__Agreement_Number__c, Apttus__FF_Agreement_Number__c 
            From Apttus__APTS_Agreement__c Where Id = :inputId];
    }
    
    // getAgreementClauses() - Get All Agreement Clause List for Agreement.
    public void getAgreementClauses(){
        String soqlQuery = APTSMD_QueryUtils.getAllFieldsSOQL('Apttus__Agreement_Clause__c','Apttus__Agreement__c=\''+ inputId + '\'' + ' And Apttus__Action__c = \'Final\' ORDER BY Id Desc',null);
        List<Apttus__Agreement_Clause__c> allClausesOfAgreement = (List<Apttus__Agreement_Clause__c>)Database.query(soqlQuery);
        List<Apttus__Agreement_Clause__c> clausesToDisplay = new List<Apttus__Agreement_Clause__c>();
        Set<String> clauseNameSet = new Set<String>();
        if(allClausesOfAgreement.isEmpty()){
            errorMessage = 'No \'Final\' clauses found for the current agreement.';
        }
        for(Apttus__Agreement_Clause__c clause : allClausesOfAgreement){
            if(!clauseNameSet.contains(clause.Apttus__Clause__c)){
                clausesToDisplay.add(clause);
                clauseNameSet.add(clause.Apttus__Clause__c);
            }
        }
        agreementClausesJSON = JSON.serialize(clausesToDisplay);
    }
    
    // updateClauses() - Update clauses records
    @RemoteAction
    public static String updateClauses(String agreementClausesJSON){
        List<Apttus__Agreement_Clause__c> clauses = (List<Apttus__Agreement_Clause__c>)JSON.deserialize(agreementClausesJSON, List<Apttus__Agreement_Clause__c>.class);
        List<Apttus__Agreement_Clause__c> clausesToUpdate = new List<Apttus__Agreement_Clause__c>();
        for(Apttus__Agreement_Clause__c clause : clauses){
            clausesToUpdate.add(new Apttus__Agreement_Clause__c(Id = clause.Id, APTSMD_Include_in_Document__c = clause.APTSMD_Include_in_Document__c));
        }
        update clausesToUpdate;
        return 'Success';
    }
}