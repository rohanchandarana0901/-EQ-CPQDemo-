public class APTSMD_GenerateDocumentFile implements APTSMD_HandlerInterface{
    
    public void executeMethod(string recordId, string templateId, string documentType, string param4, string param5){
        System.debug ('-------Inside executeMethod-------');
        System.debug (recordId);
        System.debug (templateId);
        System.debug (documentType);
        System.debug (param4);
        System.debug (param5);
        Id templateRecordId = templateId;
        Id agreementId = recordId;
        string accessLevel = 'Full Access';
        string apiServerURL =  System.Url.getOrgDomainURL().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        string generatedDocId = Apttus.MergeWebService.generateDoc(templateId,recordId,accessLevel, documentType, Userinfo.getsessionid(), apiServerURL);
        System.debug('generatedDocId >> ' + generatedDocId);
    }
    
}