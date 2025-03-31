global class APTSMD_AgreementSubmitV2Controller {
    
    // Variables
    global string agreementId {get;set;}
    global List<Apttus__APTS_Template__c> MSAandNDATemplates {get;set;}
    global APTSMD_Apttus_PreSales_Config_Settings2__c preSalesSetting {get;set;}
    global string MSAandNDATemplatesJSON {get;set;}
    global string preSalesSettingJSON {get;set;}
    
    private static final String PARAM_DOCUMENT_IDS_CSV = 'documentIdsCsv';
    private static final String SIGNATURE_TYPE_LABEL = 'Signature Type';
    private static final String SIGNATURE_TYPE_VALUE_ESIG = 'e-Signature';
    private static final String SIGNATURE_TYPE_VALUE_WRITTEN = 'Written Signature';
    
    // Constructor
    global APTSMD_AgreementSubmitV2Controller(ApexPages.StandardController stdCtrl){
        agreementId = ApexPages.currentPage().getParameters().get('id');
        MSAandNDATemplates = new List<Apttus__APTS_Template__c>();
        preSalesSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        if(preSalesSetting == null){
            preSalesSettingJSON = '';
        }else{
            preSalesSettingJSON = JSON.serialize(preSalesSetting);
        }
        MSAandNDATemplates = [SELECT Id, Name FROM Apttus__APTS_Template__c 
                                WHERE Name = :preSalesSetting.APTSMD_Default_MSA_Template__c 
                                    OR Name = :preSalesSetting.APTSMD_Default_NDA_Template__c];
        if(MSAandNDATemplates.isEmpty()){
            MSAandNDATemplatesJSON = '';
        }else{
            MSAandNDATemplatesJSON = JSON.serialize(MSAandNDATemplates);
        }
    }
    
    // createNDAAgreement - Create NDA Agreement for Given MSA Agreement
    @remoteAction
    global static string createNDAAgreement(string agreementId){
        try{
            if(agreementId == null || agreementId == ''){
                return 'Error: Please provide valid Agreement Id to create NDA Agreement';
            }
            
            // Get Parent Agreement Record
            Apttus__APTS_Agreement__c parentMSAagreement = [select Id,Apttus__Primary_Contact__c,
                                                        Apttus__Account__c,Apttus__Status_Category__c,Apttus__Status__c,
                                                        RecordTypeId,Name,Apttus__Parent_Agreement__c,RecordType.Name 
                                                        from Apttus__APTS_Agreement__c where Id = :agreementId LIMIT 1];
            
            // Check for the Parent Agreement                                            
            if(parentMSAagreement == null){
                return 'Error: No Agreement found for given Agreement Id';
            }
            
            // Get NDA record type ID
            Id ndaRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
            
            // Clone Parent Agreement and Create NDA
            Apttus__APTS_Agreement__c clonedNDAAgreement = parentMSAagreement.clone(false, true, false, false);
            clonedNDAAgreement.Name = 'NDA' + parentMSAagreement.Name.right(parentMSAagreement.Name.length()-3);
            clonedNDAAgreement.Apttus__Primary_Contact__c = parentMSAagreement.Apttus__Primary_Contact__c;
            clonedNDAAgreement.Apttus__Account__c = parentMSAagreement.Apttus__Account__c;
            clonedNDAAgreement.RecordTypeId = ndaRecordTypeId;
            insert clonedNDAAgreement;
            
            // Create Relation between Parent and NDA Agreement
            Apttus__APTS_Related_Agreement__c relatedAgreementEntry = new Apttus__APTS_Related_Agreement__c();
            relatedAgreementEntry.Name  = 'Related NDA';
            relatedAgreementEntry.Apttus__APTS_Contract_From__c = parentMSAagreement.Id;
            relatedAgreementEntry.Apttus__Relationship_From_Type__c = 'Related NDA Is';
            relatedAgreementEntry.Apttus__APTS_Contract_To__c = clonedNDAAgreement.Id;
            relatedAgreementEntry.Apttus__Relationship_To_Type__c = 'IS NDA for';
            insert relatedAgreementEntry;
            
            return 'Success: NDA Agreement Created Successfully! NDA AgreementID:' + clonedNDAAgreement.Id;
            
        }catch(Exception ex){
            return 'Error: ' + ex.getMessage() + ' @ Line#' + ex.getLineNumber();
        }
    }
    
    @remoteAction
    global static string generateDocument(string agreementId, string templateId, string eSignType){
        try{
            
            Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name, Apttus__VersionAware__c, Apttus__Primary_Contact__c 
                                                    from Apttus__APTS_Agreement__c where Id= :agreementId];
                                                    
            if(agreement == null){
                return 'Error: No Agreement found for given Agreement Id';
            }
            
            if(agreement.RecordType.Name=='MSA'){
                if(agreement.Apttus__VersionAware__c){
                    APTSMD_generateDocumentHandler.generateDocumentVersion(templateId, agreementId);
                    generateDocumentWithVersion(agreementId);
                    return 'Success: Document Version Created successfully!';
                }else{
                    APTSMD_generateDocumentHandler.generateDocument(templateId, agreementId, UserInfo.getSessionId().SubString(15), false);
                }
            }else{
                APTSMD_generateDocumentHandler.generateDocument(templateId, agreementId, UserInfo.getSessionId().SubString(15), true);
                
                if(eSignType == 'Docusign'){
                    Apttus_DocuApi__DocuSignDefaultRecipient2__c defaultRecipientObj = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                    defaultRecipientObj.Apttus_CMDSign__AgreementId__c = agreementId;
                    defaultRecipientObj.RecordTypeId = Apttus_DocuApi__DocuSignDefaultRecipient2__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
                    defaultRecipientObj.Apttus_DocuApi__ContactId__c = agreement.Apttus__Primary_Contact__c;
                    defaultRecipientObj.Apttus_DocuApi__SigningOrder__c = 1;
                    defaultRecipientObj.Apttus_DocuApi__IsTransient__c = false;
                    insert defaultRecipientObj;
                }
            }
            
            return 'Success: Document generated successfully!';
            
        }catch(Exception ex){
            return 'Error: ' + ex.getMessage() + ' @ Line#' + ex.getLineNumber();
        }
    }
    
    @remoteAction
    global static string sendForsignature(string agreementId, string eSignType){
        try{
            
            if(agreementId == null || agreementId == '' || eSignType == '' || eSignType == null){
                return 'Error: Please provide valid data to send document for signature.';
            }
            
            Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name, Apttus__VersionAware__c,Apttus__Primary_Contact__c
                                                    from Apttus__APTS_Agreement__c where Id= :agreementId];
            
            if(agreement == null){
                return 'Error: No Agreement found for given Agreement Id';
            }
            
            if(eSignType == 'Docusign'){
                // Send for Docusign now
                APTSMD_generateDocumentHandler.sendToDocuSign(agreementId);
            }else{
                APTSMD_generateDocumentHandler.sendToEchoSign(agreementId);
            }
            
            return 'Success: Document send for signature successfully!';
            
        }catch(Exception ex){
            return 'Error: ' + ex.getMessage() + ' @ Line#' + ex.getLineNumber();
        }
    }
    
    global static void generateDocumentWithVersion(string agreementId){
        if(agreementId != null && agreementId != ''){
            APTSMD_generateDocumentHandler.generateDocumentWithVersion(agreementId);
        }
    }
    
    public PageReference sendForEsignature(){
        Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name from Apttus__APTS_Agreement__c where Id=:agreementId];
        if(agreement!=null){
            if(agreement.RecordType.Name=='MSA'){
                List<Apttus__APTS_Related_Agreement__c> relatedList = new List<Apttus__APTS_Related_Agreement__c>();
                relatedList = [select id , Apttus__APTS_Contract_To__c  from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c =: agreement.Id];
                if(relatedList!=null && relatedList.size() > 0){
                    if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
                        APTSMD_generateDocumentHandler.sendToDocuSign(relatedList[0].Apttus__APTS_Contract_To__c);
                    }else{
                        sendToEchoSign(relatedList[0].Apttus__APTS_Contract_To__c);
                    }
                }
            } else {
                if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
                    APTSMD_generateDocumentHandler.sendToDocuSign(agreementId);
                }else{
                    sendToEchoSign(agreementId);
                }
            }
        }
        
        PageReference pr = new PageReference('/apex/APTSMD_AgreementSendToESNextV2?id=' + agreementId);
        pr.setRedirect(true);
        return pr;
    }
    
    private void sendToEchoSign(String agreementId){
        ContentDocumentLink contentDocLink;
        ContentVersion contentVer;
        Attachment att;
        
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
    }
    
    public void executeESAPI(){
         if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
            return;
         }
         
         String signAgreementId = agreementId;
         List<Apttus__APTS_Related_Agreement__c> relatedList = [select id , Apttus__APTS_Contract_To__c  from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c =: agreementId];
         if(!relatedList.isEmpty()){
             signAgreementId = relatedList[0].Apttus__APTS_Contract_To__c;
         }
         Apttus__APTS_Agreement__c agreement = [Select Id, Apttus__Status__c, Name, Apttus__Primary_Contact__c, Apttus__Account__c from Apttus__APTS_Agreement__c where id = :signAgreementId];
         echosign_dev1__SIGN_Agreement__c esAgmt = [Select Id from echosign_dev1__SIGN_Agreement__c Where Apttus_Echosign__Apttus_Agreement__c =:signAgreementId Order By CreatedDate Desc Limit 1];
         
         try {
            echosign_dev1.EchoSignApiService.SendDocumentResult result = echosign_dev1.EchoSignApiService.sendDocument(esAgmt.Id);
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
        Attachment esAttachment = new Attachment(Name = contentVersion.Title, ContentType = contentVersion.FileType, Body = contentVersion.VersionData, ParentId = parentId);
        insert esAttachment;
        return esAttachment;
    }
}