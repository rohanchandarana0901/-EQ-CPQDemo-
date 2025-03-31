/*
This class used to Agreement Creation wizard to generate document and send for esignature.
*/
global class APTSMD_generateDocumentHandler {
    
    private static Apttus__APTS_Template__c docTemplate;
    private static String generatedDocId;
    private static Boolean isDraft;
    private static Attachment att;
    private static ContentDocumentLink contentDocLink;
    private static ContentVersion contentVer;
    private static String echoSignAgreementId;
    
    private static final String PARAM_DOCUMENT_IDS_CSV = 'documentIdsCsv';
    private static final String SIGNATURE_TYPE_LABEL = 'Signature Type';
    private static final String SIGNATURE_TYPE_VALUE_ESIG = 'e-Signature';
    private static final String SIGNATURE_TYPE_VALUE_WRITTEN = 'Written Signature';
    
    public APTSMD_generateDocumentHandler (){
    }
    
    static{
        docTemplate = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name = 'NDA' LIMIT 1];
        isDraft = false;
    }
    
   
    public static void generateDocument(String agreementId, String sessionId){
        Id templateId = docTemplate.Id;
        Id recordId = agreementId;
        sessionId = Userinfo.getsessionid();
        String accessLevel = 'Full Access';
        String docFormat = 'docx';
        String apiServerURL =  System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        generatedDocId = Apttus.MergeWebService.generateDoc(templateId, recordId, accessLevel, docFormat, sessionId, apiServerURL);
    }
    
    public static void generateDocument(String docId,String agreementId, String sessionId,boolean isPDF){
        Id templateId = docId;
        sessionId = Userinfo.getsessionid();
        Id recordId = agreementId;
        String accessLevel = 'Full Access';
        String docFormat = 'pdf';
        if(!isPDF){
            docFormat = 'docx';
        }
        String apiServerURL =  System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        generatedDocId = Apttus.MergeWebService.generateDoc(templateId, recordId, accessLevel, docFormat, sessionId, apiServerURL);
    }
    
     public static void generateDocument(String docId,String agreementId, String sessionId){
        Id templateId = docId;
        sessionId = Userinfo.getsessionid();
        Id recordId = agreementId;
        String accessLevel = 'Full Access';
        String docFormat = 'pdf';
        String apiServerURL =  System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        generatedDocId = Apttus.MergeWebService.generateDoc(templateId, recordId, accessLevel, docFormat, sessionId, apiServerURL);
    }
    
    public static void generateDocumentVersion(String docId,String agreementId){
        Id templateId = docId;
        String outputFormat = 'DOCX';
        String comments = '';
        
        // Create a Document Verison
        String docAction = Apttus.AgreementGenerateController.ACTION_GENERATE;
        apttus__DocumentVersionDetail__c  documentVersionDetail = Apttus.AgreementGenerateController.createDocVersionSO(agreementId,  templateId,  docAction,  outputFormat,  comments);
        system.debug('APITEST:documentVersionDetail.Id = '+documentVersionDetail.Id);
    }
    
    public static void generateDocumentWithVersion(String agreementId){
        APTSMD_Apttus_PreSales_Config_Settings2__c setting = [select id,APTSMD_Default_MSA_Template__c from APTSMD_Apttus_PreSales_Config_Settings2__c LIMIT 1];
        Id templateId = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name =:setting.APTSMD_Default_MSA_Template__c LIMIT 1][0].Id;
        Id documentVersionDetailId = [Select Id From Apttus__DocumentVersionDetail__c Where Apttus__DocumentVersionId__r.Apttus__AgreementId__c = :agreementId Order By CreatedDate Desc Limit 1][0].Id;
        String sessionId = Userinfo.getsessionid();
        Boolean isDraft = false;
        String pLevel = 'Full access';
        String outputFormat = 'DOCX';
        String comments = '';
        
        Apttus__APTS_Agreement__c agreementSO = [select Id,name from Apttus__APTS_Agreement__c where Id = :agreementId];
        String apiServerURL =  System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
        
        Apttus.AgreementGenerateController agc = new Apttus.AgreementGenerateController(new ApexPages.StandardController(agreementSO));   
        agc.submitGenerateDoc(templateId, pLevel, outputFormat, isDraft, documentVersionDetailId, sessionId, apiServerURL);
    }
    
    public static void sendToEchoSign(String agreementId){
        //String LOGIN_DOMAIN = 'www';
        
        //Getting Comply System Properties
        Apttus__ComplySystemProperties__c ComplySystemProperty = [select Apttus__EnableFile__c from Apttus__ComplySystemProperties__c];
        
        //If file enabled is true
        if(ComplySystemProperty.Apttus__EnableFile__c == true){
            
          // contentDoc = [select id,ParentId, FileType from ContentDocument where ParentId =: agreementId order by createddate desc limit 1];
            contentDocLink = [select ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Apttus__APTS_Agreement__c where Id =: agreementId)];
            contentVer = [select id,VersionData,Title,FileType from ContentVersion where ContentDocumentId =: contentDocLink.ContentDocumentId];
        }
        //If file enabled is false
        else{
            att = [select id,name,ParentId,Parent.name, body, ContentType from Attachment where ParentId =: agreementId order by createddate desc limit 1];
        }
        
        Apttus__APTS_Agreement__c agreement = [Select Id,Apttus__Status__c, Name, Apttus__Primary_Contact__c, Apttus__Account__c from Apttus__APTS_Agreement__c where id = :agreementId limit 1];
        //create echosign agreement and associate it to this apttus agreement
        echosign_dev1__SIGN_Agreement__c esAgmt = new echosign_dev1__SIGN_Agreement__c(
            Apttus_Echosign__Apttus_Agreement__c = agreementId, Name = agreement.Name, echosign_dev1__Account__c = agreement.Apttus__Account__c, echosign_dev1__SignatureType__c = SIGNATURE_TYPE_VALUE_ESIG, echosign_dev1__SignatureOrder__c = null, echosign_dev1__Recipient__c = agreement.Apttus__Primary_Contact__c);
        
        PageReference rtnPageRef = new PageReference('/' + agreementId);
        esAgmt.echosign_dev1__ReturnURL__c = rtnPageRef.getUrl();   
        
        insert esAgmt;
      
        // clone and associate selected attachments to echosign agreement.
        Attachment echoSignAttachment;
        if(ComplySystemProperty.Apttus__EnableFile__c == true){
            echoSignAttachment = cloneContentDocument(contentVer, esAgmt.Id);
        }
        else{
            echoSignAttachment = cloneAttachments(att, esAgmt.Id);
       }
        
        
        // update esAgmt with attachmentIds for ordering
        esAgmt.echosign_dev1__Attachment_ID_Order__c = echoSignAttachment.Id;       
        update esAgmt;
        echoSignAgreementId = esAgmt.Id;
         try {
            echosign_dev1.EchoSignApiService.SendDocumentResult result = echosign_dev1.EchoSignApiService.sendDocument(echoSignAgreementId);
            agreement.Apttus__Status__c='Other Party Signatures';
            update agreement;
         } catch (Exception e) {
             System.debug('Exception - ' + e );
         }
    }
    
    private static Attachment cloneAttachments(Attachment attachment, ID parentId) {
        Attachment aptsAttachBody = [SELECT Id, Body FROM Attachment WHERE Id = :attachment.Id];
        Attachment esAttachment = new Attachment(Name = attachment.Name, ContentType = attachment.ContentType, Body = aptsAttachBody.Body, ParentId = parentId);
        insert esAttachment;
        return esAttachment;
    }
    
    //For Files or ContentDocument
    private static Attachment cloneContentDocument(ContentVersion contentVersion, ID parentId) {
     //   ContentVersion aptsContentBody = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :contentVersion.Id];
        Attachment esAttachment = new Attachment(Name = contentVersion.Title, ContentType = contentVersion.FileType, Body = contentVersion.VersionData, ParentId = parentId);
        insert esAttachment;
        return esAttachment;
    }
    
    public static void sendToDocuSign(String agmtId){
        if(agmtId != Null){
             Map<Id,Id> mapOfAgmtIdVsContentDocId = new Map<Id,Id>();
             Map<Id,ContentDocumentLink> mapOfAgmtIdVsCDL = new Map<Id,ContentDocumentLink>();
             Attachment tempAtt;

             //Getting agreement                    
             Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Primary_Contact__c FROM Apttus__APTS_Agreement__c WHERE Id =: agmtId];
           
            //Checking Enable file setting   
            Apttus__ComplySystemProperties__c a = [SELECT Name,Apttus__EnableFile__c FROM Apttus__ComplySystemProperties__c WHERE Name='System Properties'];
            String AttachemntorFileId = '';             
            if(a.Apttus__EnableFile__c){
                List<ContentDocumentLink> generatedFiles = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: newAgreement.Id  and LinkedEntity.Type='Apttus__APTS_Agreement__c' and (not ContentDocument.Title Like '%signed%')];
                if(!generatedFiles.isEmpty()){
                    AttachemntorFileId = String.valueOf(generatedFiles[0].ContentDocumentId).substring(0, 15);
                }else{
                    return;
                }
            }else{
                List<Attachment> generatedAttachments = [SELECT id, name, ParentId, Parent.name, body, ContentType FROM Attachment WHERE ParentId =: newAgreement.Id ORDER BY CreatedDate Desc ];   
                if(!generatedAttachments.isEmpty()){
                    AttachemntorFileId = String.valueOf(generatedAttachments[0].id).substring(0, 15);
                }else{
                    return;
                }
            }
            
            if(AttachemntorFileId==''){
                  return;
            }else{
                 try {   
                   String agreementId = String.valueOf(newAgreement.Id).substring(0, 15);
                   String result = Apttus_CMDSign.CMDocuSignSendForESignatureAPI.submitDocuSignBatchCreateEnvelopeJob(agreementId,new List<Id>{AttachemntorFileId});    
                   System.debug('Docusign result:'+result);  
                   Apttus__APTS_Agreement__c existingAgreement = new Apttus__APTS_Agreement__c (id=agreementId);
                   existingAgreement.Apttus__Status__c = 'Other Party Signatures';
                   update existingAgreement;
                   return;
                } catch (Exception e) {
                   System.debug('Exception - ' + e );
                }
            }    
        }
    }

}