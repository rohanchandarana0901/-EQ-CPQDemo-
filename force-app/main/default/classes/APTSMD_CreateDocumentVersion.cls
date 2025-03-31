public class APTSMD_CreateDocumentVersion implements APTSMD_HandlerInterface{
    
    public void executeMethod(string recordId, string templateId, string documentType, string comments, string param5){
        
        System.debug ('-------Inside executeMethod-------');
        System.debug (recordId);
        System.debug (templateId);
        System.debug (documentType);
        System.debug (comments);
        System.debug (param5); // Can be null from SF Flow
        
        // Create a Document Verison
        string docAction = Apttus.AgreementGenerateController.ACTION_GENERATE;
        apttus__DocumentVersionDetail__c  documentVersionDetail = Apttus.AgreementGenerateController.createDocVersionSO(recordId,  templateId,  docAction,  documentType,  comments);
        system.debug('APITEST:documentVersionDetail.Id = '+documentVersionDetail.Id);
            
    }
    
}