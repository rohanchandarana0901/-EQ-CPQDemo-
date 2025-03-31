/**
 *  AptsComplyCustomAPI provides the entire API that can be used from a third party UI.  
 *  It assumes certain dependencies on Apttus Packages and DocuSign
 *  It also requires a custom settings that provides all the required information for these APIs to perform their tasks
 *
 */
global with sharing class APTSMD_ComplyCustomAPI {
    
   
    private static final string Agmt_StatusCategory_Request='Request';
    private static final string Agmt_StatusCategory_In_Signatures='In Signatures';
    private static final string Agmt_Status_Ready_for_Signatures='Ready for Signatures';
    private static final string Agmt_Status_Fully_Signed='Fully Signed';
    private static final string Agmt_Status_Other_Party_Signatures='Other Party Signatures';
    private static final string Custom_setting_name='Apttus Comply Custom API Settings';
    private static final string Document_Access_Level='Read Only';
    private static string document_Format='pdf';
    
    //send for Signature
    global static String doSend(Id agreementId, Id generatedAgreementDocId) {
        
        //validate agreement id
        if(agreementId == null){
            return 'agreement Id is Missing.';//Label.APTS011_INVALID_AGREEMENT_ID;
        }
        
        //validate agreement document id
        if(generatedAgreementDocId == null){
            return 'Generated agreement Document Id is Missing.';//Label.APTS012_INVALID_GENERATED_DOCUMENT_ID;
        }
        
        //validate agreement
        Apttus__APTS_Agreement__c contract;
        try{
            contract = [SELECT Id, 
                              name,
                              Apttus_CMDSign__DocuSignEnvelopeId__c, 
                              Apttus__Requestor__c, 
                              Apttus__Status_Category__c, 
                              Apttus__Status__c, 
                              Apttus__Contract_End_Date__c, 
                              Apttus__Term_Months__c,
                              Apttus__Primary_Contact__r.Email, 
                              Apttus__Primary_Contact__r.Name,
                              Apttus__Primary_Contact__c 
                        FROM Apttus__APTS_Agreement__c 
                        WHERE id = :agreementId];
            document_Format='doc';
            
        }catch(System.QueryException qe){
            return 'agreement Id is Missing.';//Label.APTS011_INVALID_AGREEMENT_ID;          
        }
        
        //validate recipient detail
        if(contract == null || contract.Apttus__Primary_Contact__c == null || contract.Apttus__Primary_Contact__r.Email == null || contract.Apttus__Primary_Contact__r.Name == null) {
            return 'agreement Recepient Detail is Missing.';//Label.APTS015_RECIPIENT_DETAIL_MISSING;
        }

        String accountId = '73f8278c-262c-49d5-b55a-b58972e1f2d5';
        String userId = 'nmccoy@apttus.com';
        String password = 'docusign2014';
        String integratorsKey = 'APTT-ec765388-5365-4651-b8cf-d5af23f3812e';
        String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
        String envelopeId;
        APTSMD_DocuSignAPI.APIServiceSoap dsApiSend = new APTSMD_DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;

        //Set Authentication
        String orgId = UserInfo.getOrganizationId();
       
        String requestorDSID = 'congademo@conga.com';// updated by vivek as on 8 dec 2021
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey>'
            + (requestorDSID != null ? ('<SendOnBehalfOf>'+requestorDSID+'</SendOnBehalfOf>'):'')
            +'</DocuSignCredentials>';
        //TEMP CODE END
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put(/*Label.Input_Http_Headers_X*/'X-DocuSign-Authentication', auth);
        APTSMD_DocuSignAPI.Envelope envelope = new APTSMD_DocuSignAPI.Envelope();
        envelope.Subject = 'Documents for your DocuSign Signature from Apttus CLM';//Label.Envelope_Subject_Send;
        envelope.EmailBlurb = 'Request for eSignatures.Please review and sign.';//Label.Envelope_Email_Blurb_Send;
        envelope.AccountId  = accountId;
        APTSMD_DocuSignAPI.CustomField cf = new APTSMD_DocuSignAPI.CustomField();
        cf.Name = 'ApttusAgreementID';
        cf.value = contract.Id; 
        cf.required = 'false';
        cf.show  = 'true';
        
        APTSMD_DocuSignAPI.CustomField cf1 = new APTSMD_DocuSignAPI.CustomField();
        cf1.Name = 'dsfs__Source_Object__c';
        cf1.value = contract.Id; 
         
        APTSMD_DocuSignAPI.CustomField cf2 = new APTSMD_DocuSignAPI.CustomField();
        cf2.Name = 'dsfs__Custom_Field_1_Name__c';
        cf2.value = 'ApttusAgreementID'; 
         
        APTSMD_DocuSignAPI.CustomField cf3 = new APTSMD_DocuSignAPI.CustomField();
        cf3.Name = 'dsfs__Custom_Field_1_Value__c';
        cf3.value = contract.Id; 
         
        APTSMD_DocuSignAPI.ArrayOfCustomField acf = new APTSMD_DocuSignAPI.ArrayOfCustomField();
        acf.CustomField = new APTSMD_DocuSignAPI.CustomField[]{cf}; 
        envelope.CustomFields = acf; 

        Attachment att;
        List<contentVersion> contentVer;
        try{
            //Query Comply system properties for checking the Enable Files flag
            Apttus__ComplySystemProperties__c ComplySystemProperty = Apttus__ComplySystemProperties__c.getValues('System Properties');
            //If true then use contentVersion object to get the generated document(Type will be file)
            if(ComplySystemProperty.Apttus__EnableFile__c){
                contentVer = [SELECT Id,VersionData,Title,IsLatest,ContentDocumentId
                              FROM contentVersion
                              WHERE ContentDocumentId =: generatedAgreementDocId];
            }else{
                att = [select id, name, body from Attachment where id = :generatedAgreementDocId];
            }
        }catch(System.QueryException qe1){
            return 'Invalid Generated Document Id';//Label.APTS012_INVALID_GENERATED_DOCUMENT_ID;
        }           

        // Document
        APTSMD_DocuSignAPI.Document document = new APTSMD_DocuSignAPI.Document();
        document.ID = 1;
        /*If the attachment type is not file then will take value from attachment 
        object else will look into ContentVersion Object*/
        if(att != Null){
            document.Name = att.Name;
            document.pdfBytes = EncodingUtil.base64Encode(att.body);
        }else{
            document.Name = contentVer[0].Title;
            document.pdfBytes = EncodingUtil.base64Encode(contentVer[0].VersionData);
        }
        document.FileExtension = document_Format;
        envelope.Documents = new APTSMD_DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new APTSMD_DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        
        APTSMD_DocuSignAPI.Recipient recipient = new APTSMD_DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = contract.Apttus__Primary_Contact__r.Email;
        recipient.UserName = contract.Apttus__Primary_Contact__r.Name;
        recipient.RequireIDLookup = false;
        
        envelope.Recipients = new APTSMD_DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new APTSMD_DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0] = recipient;

        //Set the Notification
        APTSMD_DocuSignAPI.Notification notification = new APTSMD_DocuSignAPI.Notification();
        APTSMD_DocuSignAPI.Reminders reminders = new APTSMD_DocuSignAPI.Reminders();
        APTSMD_DocuSignAPI.Expirations expirations = new APTSMD_DocuSignAPI.Expirations();
        
        reminders.ReminderEnabled = true;
        reminders.ReminderDelay = 0;
        reminders.ReminderFrequency = 0;
        
        expirations.ExpireEnabled = true;
        expirations.ExpireAfter = 0;
        expirations.ExpireWarn = 0;
        
        notification.Reminders = reminders;
        notification.Expirations = expirations;
        
        envelope.Notification = notification;
  
        try{
            if(!Test.isRunningTest()){
                APTSMD_DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                envelopeId = es.EnvelopeID;
                createAndUpdateEnvelope(envelope, es.EnvelopeId, contract, document.Name, contract.Apttus__Primary_Contact__r.Email,generatedAgreementDocId);
                contract.Apttus__Status__c = 'Other Party Signatures';
                update contract;
                return 'Success';//Label.SUCCESS;
            }
        }catch(CalloutException e) {
            envelopeId = 'Exception - ' + e;
            String rString = 'Error 123 '+ e.getMessage() +'  ***  '+e;
            return rString ;
        }
        return 'Success';//Label.SUCCESS;
    }
    
    public static void createAndUpdateEnvelope(APTSMD_DocuSignAPI.Envelope envelope, String envelopeId, Apttus__APTS_Agreement__c  agreement, String docName, String email,String docId) {
        
        Apttus_DocuApi__DocuSignEnvelope__c docSignEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docSignEnvelope.Apttus_DocuApi__EnvelopeId__c = envelopeId;
        docSignEnvelope.Apttus_CMDSign__Agreement__c = agreement.Id;
        docSignEnvelope.Name = envelopeId;
        docSignEnvelope.Apttus_DocuApi__DocumentName__c = '["' +docName + '"]';
        docSignEnvelope.Apttus_DocuApi__ParentId__c = agreement.Id;
        docSignEnvelope.Apttus_DocuApi__Status__c = 'sent';
        docSignEnvelope.Apttus_DocuApi__NumberOfDocuments__c = 1;
        docSignEnvelope.Apttus_DocuApi__StatusChangeDateTime__c = Date.today();
        String content = '{"success":true,"showTagAndSend":false,"showSendforESignature":true,"showSendAsAnotherUser":true,"showPreview":true,"senderViewURL":null,"sendAsUserEmail":"apttusdemo@apttus.com","parentId":"'+agreement.Id+'","oneClickSend":false,"objRecipientList":{"listRecipient":[{"tabs":null,"signerType":"signers","signerRole":"Signer","selected":true,"orderNumber":1,"objectType":null,"objectIndex":0,"name":"'+agreement.Apttus__Primary_Contact__r.Name+'","id":"'+agreement.Apttus__Primary_Contact__r.id+'","email":"'+agreement.Apttus__Primary_Contact__r.Email+'","canMoveUp":false,"canMoveDown":false}]},"objAttachmentWrapperList":{"parentStatus":null,"parentNumber":null,"parentName":null,"listAttachmentWrapper":[{"siblingsId":null,"selected":true,"relationship":"Primary","parentStatus":null,"parentNumber":null,"parentName":null,"parentId":"'+agreement.Id+'","objectIndex":0,"isSibling":false,"isParent":false,"isChild":false,"documentAssociationType":"Primary","canMoveUp":false,"canMoveDown":false,"attachment":{"attributes":{"type":"Attachment","url":"/services/data/v35.0/sobjects/Attachment/'+docId+'"},"Id":"'+docId+'","Name":"'+docName+'"}}],"hasSibling":false,"hasRelated":false,"hasParent":false,"hasChild":false,"hasAmendRenew":false},"isPreviewInDocusign":false,"Id":"'+envelopeId+'","errorMessage":null,"errorCode":null,"error":false,"envelopeStatus":"Sent","emailSubject":"Request for eSignatures","emailBody":"Request for eSignatures.Please review and sign.","documentUploadProcessId":null}';
        docSignEnvelope.Apttus_DocuApi__EnvelopeContent__c = content;
        
        insert docSignEnvelope;
        
        agreement.Apttus_CMDSign__DocuSignEnvelopeId__c = docSignEnvelope.id;
        update agreement;
        
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c dsRecipient = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        dsRecipient.Apttus_DocuApi__DocuSignEnvelopeId__c = docSignEnvelope.Id;
        dsRecipient.Apttus_DocuApi__Title__c = 'Customer 1';
        dsRecipient.Apttus_DocuApi__Status__c = 'sent';
        dsRecipient.Apttus_DocuApi__RoutingOrder__c = '1';
        dsRecipient.Apttus_DocuApi__RoleName__c = 'Signer1';
        dsRecipient.Apttus_DocuApi__Email__c = email;
        dsRecipient.Apttus_DocuApi__EnvelopeParentId__c = agreement.Id;
        dsRecipient.Apttus_DocuApi__RecipientName__c = agreement.Apttus__Primary_Contact__r.Name;
        insert dsRecipient;
    }
}