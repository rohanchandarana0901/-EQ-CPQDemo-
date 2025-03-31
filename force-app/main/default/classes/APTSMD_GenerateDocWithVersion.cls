public class APTSMD_GenerateDocWithVersion implements APTSMD_HandlerInterface {
    
    public void executeMethod(string recordId, string templateId, string documentType, string param4, string param5){
        
        System.debug ('-------Inside executeMethod-------');
        System.debug (recordId);
        System.debug (templateId);
        System.debug (documentType);
        System.debug (param4); // Can be null from SF Flow
        System.debug (param5); // Can be null from SF Flow
        
        // Fetch the latest Document Version Detail Record for an agreement
        Apttus__DocumentVersionDetail__c documentVersionDetail = [Select Id From Apttus__DocumentVersionDetail__c 
                                      	Where Apttus__DocumentVersionId__r.Apttus__AgreementId__c = :recordId 
                                      	Order By CreatedDate Desc Limit 1];
        
        if(documentVersionDetail != null){
            String sessionId = Userinfo.getsessionid();
            Boolean isDraft = false;
            String pLevel = 'Full access';
            String outputFormat = 'DOCX';
            
            // Creating Agreement sObject
            Apttus__APTS_Agreement__c agreementSO = new Apttus__APTS_Agreement__c(
            	Id = recordId
            ); // commented for now to save one DML : [select Id,name from Apttus__APTS_Agreement__c where Id = :recordId];
            
            String apiServerURL =  System.Url.getOrgDomainURL().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
            
            // Create AgreementGenerateController Instance to call generate method
            Apttus.AgreementGenerateController agc = new Apttus.AgreementGenerateController(new ApexPages.StandardController(agreementSO));   
            agc.submitGenerateDoc(templateId, pLevel, documentType, isDraft, documentVersionDetail.Id, sessionId, apiServerURL);
        }
            
    }

}