/*** Company      : Apttus Inc.
 * Description  : Webservice class for sending Agreement for Docusign/Echosign FROM MAX bot
 * History      :
 * [29.Aug.2018] Devangi Mehta    : Created Class 
 * [14.May.2019] Jiger Niak : Updated the class, added file logic also
 */ 

@RestResource(urlMapping='/agreement/echosign')
global class APTSMD_SendAgmtForEchoSign {
    /**
   * Calls the Docusign/Echosign apis based on User input
   * @param agmtId is the agreement ID
   * @param provider is the User's choice for Docusign/Echosign
   * @param contactId ,userId and email are the recipient types
   * @return Boolean value of success/failure
   */ 
    @HttpPost
    webservice static Boolean executeTriggerLogic(String agmtId,String provider,String contactId,String userId,String email){
        if (agmtId != null)
            agmtId = String.escapeSingleQuotes(agmtId);
        if (provider != null)
            provider = String.escapeSingleQuotes(provider);
        if (contactId != null)
            contactId = String.escapeSingleQuotes(contactId);
        if (userId != null)
            userId = String.escapeSingleQuotes(userId);
        if (email != null)
            email = String.escapeSingleQuotes(email);
        if(contactId != null && contactId != ''){
            List<Contact> contactList = [Select Id From Contact Where Id=:contactId Or Name=:contactId Limit 1];
            if(!contactList.isEmpty()){
                contactId = contactList[0].Id;
            }
            else{
                contactId = '';
            }
        }
        
        if(agmtId != Null){
           Attachment attachmentSO;
           Apttus__APTS_Agreement__c newAgreement = [SELECT Id,
                                                             Name,
                                                             Apttus__Primary_Contact__c
                                                     FROM Apttus__APTS_Agreement__c 
                                                     WHERE Id =: agmtId];
            
            List<Attachment> generatedDocuments = [SELECT id,
                                                    name,
                                                    ParentId,
                                                    Parent.name, 
                                                    body, 
                                                    ContentType
                                                   FROM Attachment 
                                                   WHERE ParentId =: newAgreement.Id 
                                                   ORDER BY CreatedDate Desc];
            if(generatedDocuments.isEmpty()){ 
                List<ContentDocumentLink> generatedFiles = [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: newAgreement.Id  and LinkedEntity.Type='Apttus__APTS_Agreement__c' and (not ContentDocument.Title Like '%signed%')];

                if(!generatedFiles.isEmpty()){
                    AttachmentSO=new Attachment(
                                Name = generatedFiles[0].ContentDocument.Title
                                , ContentType = generatedFiles[0].ContentDocument.FileType
                                , Body = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId = :generatedFiles[0].ContentDocumentId][0].VersionData
                                , ParentId = newAgreement.Id);
                                
                }else{
                    return false;
                }
              }
            else{
                String gdId = generatedDocuments[0].Id;
                if (gdId != null)
                    gdId = String.escapeSingleQuotes(gdId);
                String gdName = generatedDocuments[0].Name;
                if (gdName != null)
                    gdName = String.escapeSingleQuotes(gdName);
                String gdContentType = generatedDocuments[0].ContentType;
                if (gdContentType != null)
                    gdContentType = String.escapeSingleQuotes(gdContentType);
                String gdParentId = generatedDocuments[0].parentId;
                if (gdParentId != null)
                    gdParentId = String.escapeSingleQuotes(gdParentId);
                AttachmentSO=new Attachment(Id=gdId
                                ,Name = gdName
                                , ContentType = gdContentType
                                , Body = generatedDocuments[0].Body
                                , ParentId = gdParentId);
                }
                 
                echosign_dev1__SIGN_Agreement__c esAgmt;
                
                String [] echosignFields = new String [] {'Apttus_Echosign__Apttus_Agreement__c','Name','echosign_dev1__SignatureType__c','echosign_dev1__SignatureOrder__c','echosign_dev1__Recipient__c','echosign_dev1__Message__c'};
       
                // Obtaining the field name/token map for the echosign_dev1__SIGN_Agreement__c object
                Map<String,Schema.SObjectField> m = Schema.SObjectType.echosign_dev1__SIGN_Agreement__c.fields.getMap();
                for (String fieldToCheck : echosignFields) {
                  // Check if the user has create access on the each field
                  if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                    return false;
                  }
                }
                
                //These loops create echosign agreement and associate it to this apttus agreement based on the recipient provided by the User FROM MAX
                if(contactId != ''){
                    esAgmt = new echosign_dev1__SIGN_Agreement__c(
                        Apttus_Echosign__Apttus_Agreement__c = newAgreement.Id
                        , Name = newAgreement.Name
                        , echosign_dev1__SignatureType__c = 'e-Signature'
                        , echosign_dev1__SignatureOrder__c = null
                        , echosign_dev1__Recipient__c = contactId
                        , echosign_dev1__Message__c = 'Please sign attached document.'
                    );
                }else if(userId != ''){
                    system.debug('Inside userId');
                    esAgmt = new echosign_dev1__SIGN_Agreement__c(
                        Apttus_Echosign__Apttus_Agreement__c = newAgreement.Id
                        , Name = newAgreement.Name
                        , echosign_dev1__SignatureType__c = 'e-Signature'
                        , echosign_dev1__SignatureOrder__c = null
                        ,echosign_dev1__Recipient_User__c = userId
                        , echosign_dev1__Message__c = 'Please sign attached document.'
                    );
                }else if(email != ''){
                    system.debug('Inside email');
                    esAgmt = new echosign_dev1__SIGN_Agreement__c(
                        Apttus_Echosign__Apttus_Agreement__c = newAgreement.Id
                        , Name = newAgreement.Name
                        , echosign_dev1__SignatureType__c = 'e-Signature'
                        , echosign_dev1__SignatureOrder__c = null
                        ,echosign_dev1__More_Recipients__c = email
                        , echosign_dev1__Message__c = 'Please sign attached document.'
                    );
                }else{
                    esAgmt = new echosign_dev1__SIGN_Agreement__c(
                        Apttus_Echosign__Apttus_Agreement__c = newAgreement.Id
                        , Name = newAgreement.Name
                        , echosign_dev1__SignatureType__c = 'e-Signature'
                        , echosign_dev1__SignatureOrder__c = null
                        , echosign_dev1__Recipient__c = newAgreement.Apttus__Primary_Contact__c
                        , echosign_dev1__Message__c = 'Please sign attached document.'
                    );
                }
                
                PageReference rtnPageRef = new PageReference('/' + newAgreement.Id);
                if (m.get('echosign_dev1__ReturnURL__c').getDescribe().isUpdateable()) {
                  esAgmt.echosign_dev1__ReturnURL__c = rtnPageRef.getUrl();   
                }
        
                try {
                    if(echosign_dev1__SIGN_Agreement__c.SObjectType.getDescribe().isCreateable()) {
                        insert esAgmt;
                    }
                    else {
                        throw new IllegalArgumentException('Cannot create echo sign object. insufficient privileges');
                    }
                    Attachment echoSignAttachment = cloneAttachments(attachmentSO, esAgmt.Id);

                    String esaId = echoSignAttachment.Id;
                    if (m.get('echosign_dev1__Attachment_ID_Order__c').getDescribe().isUpdateable()) {
                        esAgmt.echosign_dev1__Attachment_ID_Order__c = esaId;
                    }
                    if(echosign_dev1__SIGN_Agreement__c.SObjectType.getDescribe().isUpdateable()) {
                        update esAgmt;
                    }
                    else {
                        throw new IllegalArgumentException('Cannot update echo sign object. insufficient privileges');
                    }
                
                    echosign_dev1.EchoSignApiService.SendDocumentResult result = echosign_dev1.EchoSignApiService.sendDocument(esAgmt.Id);
                    system.debug('result - ' + result );
                } catch (Exception e) {
                    system.debug('Exception - ' + e );
                }
            }
            return true;
        }
    
    private static Attachment cloneAttachments(Attachment attachment, ID parentId) {
        String sname = attachment.Name;
        if (sname != null)
            sname = String.escapeSingleQuotes(sname);
        if(Schema.describeSObjects(new String[]{'Attachment'})[0].isCreateable()) {
            String [] attachmentFields = new String [] {'Name','ContentType','Body','ParentId'};
       
            // Obtaining the field name/token map for the echosign_dev1__SIGN_Agreement__c object
            Map<String,Schema.SObjectField> m = Schema.SObjectType.Attachment.fields.getMap();
            for (String fieldToCheck : attachmentFields) {
              // Check if the user has create access on the each field
              if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                throw new IllegalArgumentException('Cannot create Attachment object. insufficient privileges');
              }
            }
            
            Attachment esAttachment = new Attachment(Name = sname
                , ContentType = attachment.ContentType
                , Body = attachment.Body
                , ParentId = parentId);
                    
            insert esAttachment;
            return esAttachment;
        }
        else {
            throw new IllegalArgumentException('Cannot create Attachment object. insufficient privileges');
        }
    }
}