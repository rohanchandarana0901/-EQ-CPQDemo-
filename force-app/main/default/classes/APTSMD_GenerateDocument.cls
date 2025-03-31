public class APTSMD_GenerateDocument {

    private static final String PARAM_DOCUMENT_IDS_CSV = 'documentIdsCsv';
    private static final String SIGNATURE_TYPE_LABEL = 'Signature Type';
    private static final String SIGNATURE_TYPE_VALUE_ESIG = 'e-Signature';
    private static final String SIGNATURE_TYPE_VALUE_WRITTEN = 'Written Signature';
    
    public static String generateDocument(String docId,String agreementId, String sessionId){
        Id templateId = docId;
        Id recordId = agreementId;
        String accessLevel = 'Full Access';
        String docFormat = 'PDF';
        String apiServerURL = URL.getOrgDomainUrl().toExternalForm() +  '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        //String generatedDocId = Apttus.MergeWebService.generateDoc(templateId, recordId, accessLevel, docFormat, sessionId, apiServerURL);
        String generatedDocId = '';
        String i = userinfo.getsessionid();
        system.debug(i);
        system.debug(i.substring(0, i.length()-1));
        try {
            system.debug('Inside try Catch');
            generatedDocId = Apttus.MergeWebService.generateDoc(templateId, recordId, accessLevel, docFormat,sessionId,apiServerURL);
           }
        catch(Exception ex) {
           system.debug('Inside Exception');
           System.debug('Exception - ' + ex );
       }    
        return generatedDocId;
    }
    
    
    
    private static Attachment cloneAttachments(Attachment attachment, ID parentId) {
        List<Attachment> listOfAttachment = [SELECT Id, Body FROM Attachment WHERE Id = :attachment.Id];
        if(listOfAttachment!=null && listOfAttachment.size() > 0){
            Attachment esAttachment = new Attachment(Name = attachment.Name
                , ContentType = attachment.ContentType
                , Body = listOfAttachment[0].Body
                , ParentId = parentId);
                    
            insert esAttachment;
            return esAttachment;
        }
        return null;
    }

    public static boolean sendToEchoSign(Id docId,Id agreementId,String agreementName,String contactName){
       // String LOGIN_DOMAIN = 'www';
       // string userName = 'eferrisv11.3@apttusdemo.com'; 
       // string pwd = 'apttus2016';
       //system.debug('@@@@@---'+contactName);
        string SOAP_START = '<?xml version="1.0" encoding="utf-8"?>'; 
       /* HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
       
        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
          .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
          .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
          .getChildElement('result', 'urn:partner.soap.sforce.com');

      
        final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
        final String SESSION_ID = Userinfo.getsessionid();
         */
        //resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
        List<Attachment> listOfAttachment = [select id,name,ParentId,Parent.name, body, ContentType from Attachment where id =: docId];
        if(listOfAttachment!=null && listOfAttachment.size() > 0){
            Attachment att = listOfAttachment[0];
            echosign_dev1__SIGN_Agreement__c esAgmt = new echosign_dev1__SIGN_Agreement__c(
                Apttus_Echosign__Apttus_Agreement__c = agreementId
                , Name = agreementName
                , echosign_dev1__SignatureType__c = SIGNATURE_TYPE_VALUE_ESIG
                , echosign_dev1__SignatureOrder__c = null
                , echosign_dev1__Recipient__c = contactName
                , echosign_dev1__Message__c = 'Please sign attached document.'
            );
            
            PageReference rtnPageRef = new PageReference('/' + agreementId);
            esAgmt.echosign_dev1__ReturnURL__c = rtnPageRef.getUrl();   
            insert esAgmt;
            Attachment echoSignAttachment = cloneAttachments(att, esAgmt.Id);
            esAgmt.echosign_dev1__Attachment_ID_Order__c = att.Id;       
            update esAgmt;
    
            String echoSignAgreementId = esAgmt.Id;
    
            try {
                //system.debug('echoSignAgreementId=====>'+echoSignAgreementId);
                echosign_dev1.EchoSignApiService.SendDocumentResult result = echosign_dev1.EchoSignApiService.sendDocument(echoSignAgreementId);
                // system.debug('result=====>'+result);
                return true;
            } catch (Exception e) {
                // System.debug('Exception - ' + e );
                return false;
            }
        }
        return false;
    }
}