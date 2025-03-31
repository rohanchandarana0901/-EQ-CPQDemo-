public class APTSMD_AgreementInEffectViewController {
    public String agreementWrapperJSON {get; set;}
    public String errorMessage {get; set;}
    public String inputId {get; set;}
    private AgreementWrapper agreementWrapper;
    private String recordId;
    
    // Currancy Variable initialize
    public boolean isMultiCurrancyOn {get;set;}
    public string defaultCurrancy {get;set;}
    public string dateFormat {get;set;}
    
    public APTSMD_AgreementInEffectViewController(){
        inputId = ApexPages.currentPage().getParameters().get('id');
        agreementWrapper = new AgreementWrapper();
        
        // Set currency information
        this.defaultCurrancy = APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(true,'');
        this.isMultiCurrancyOn = Schema.getGlobalDescribe().containsKey('CurrencyType');
        this.dateFormat =  APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(false,''); 
        
        Apttus__APTS_Agreement__c mainAgreement = [Select Id, Apttus__Agreement_Number__c From Apttus__APTS_Agreement__c Where Id = :inputId];
        List<Apttus__APTS_Agreement__c> agreementList = [Select Id, Apttus__Status_Category__c  From Apttus__APTS_Agreement__c Where Apttus__Agreement_Number__c = :mainAgreement.Apttus__Agreement_Number__c Order By Apttus__Version_Number__c Desc];
        
        for(Apttus__APTS_Agreement__c agreement : agreementList){
            if(agreement.Apttus__Status_Category__c == 'In Effect'){
                recordId = agreement.Id;
                break;
            }
        }
        
        if(recordId == null){
            errorMessage = 'No \'In Effect\' version found for the current agreement.';
        }
    }
    
    public void queryInEffectAgreementInfo(){
        if(recordId == null){
            return;
        }
        
        agreementWrapper.agreement = getAgreement();
        agreementWrapper.agreementLineItems = getAgreementLineItems();
        agreementWrapper.agreementClauses = getAgreementClauses();
        agreementWrapper.agreementObligations = getAgreementObligations();
        agreementWrapperJSON = JSON.serialize(agreementWrapper);
          }
    
    private Apttus__APTS_Agreement__c getAgreement(){
        String soqlQuery = APTSMD_QueryUtils.getAllFieldsSOQL('Apttus__APTS_Agreement__c','id=\''+ recordId + '\'', null);
        return (Apttus__APTS_Agreement__c)Database.query(soqlQuery);
    }
    
    private List<Apttus__AgreementLineItem__c> getAgreementLineItems(){
        String soqlQuery = APTSMD_QueryUtils.getAllFieldsSOQL('Apttus__AgreementLineItem__c','Apttus__AgreementId__c=\''+ recordId + '\'', null);
        return (List<Apttus__AgreementLineItem__c>)Database.query(soqlQuery);
    }
    
    private List<Apttus__Agreement_Clause__c> getAgreementClauses(){
        String soqlQuery = APTSMD_QueryUtils.getAllFieldsSOQL('Apttus__Agreement_Clause__c','Apttus__Agreement__c=\''+ recordId + '\'' + ' And Apttus__Action__c = \'Final\' ORDER BY Id Desc', 'Apttus__PreviousVersionId__r.Apttus__Agreement__c,Apttus__PreviousVersionId__r.Apttus__Agreement__r.Apttus__FF_Agreement_Number__c');
        List<Apttus__Agreement_Clause__c> allClausesOfAgreement = (List<Apttus__Agreement_Clause__c>)Database.query(soqlQuery);
        List<Apttus__Agreement_Clause__c> clausesToDisplay = new List<Apttus__Agreement_Clause__c>();
        Set<String> clauseNameSet = new Set<String>();
        
        for(Apttus__Agreement_Clause__c clause : allClausesOfAgreement){
            if(!clauseNameSet.contains(clause.Apttus__Clause__c)){
                clausesToDisplay.add(clause);
                clauseNameSet.add(clause.Apttus__Clause__c);
            }
        }
        return clausesToDisplay;
    }
    
    private List<Apttus__Obligation__c> getAgreementObligations(){
        String soqlQuery = APTSMD_QueryUtils.getAllFieldsSOQL('Apttus__Obligation__c','APTSMD_Agreement__c=\''+ recordId + '\'', null);
        return (List<Apttus__Obligation__c>)Database.query(soqlQuery);
    }
    
    public class AgreementWrapper {
        Apttus__APTS_Agreement__c agreement {get; set;}
        List<Apttus__AgreementLineItem__c> agreementLineItems {get; set;}
        List<Apttus__Agreement_Clause__c> agreementClauses {get; set;}
        List<Apttus__Obligation__c> agreementObligations {get; set;}
    }
}