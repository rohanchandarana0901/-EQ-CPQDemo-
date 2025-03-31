/**
 * Company      : Apttus Inc.
 * Description  : Rest class to send the agreement for review
 * History      :
 * [11.Oct.2018]: CaaS Team - Sagar Pomal
 */ 

@RestResource(urlMapping='/agreement/sendforreview')
global class APTSMD_SendForReview {
    
   /*****************************************************************
        
        @param agreementId - String - required
        @param attachmentIds - List - required
        @param toAddresses - List - required if contactid not specified
        @param ccAddresses - List - optional
        @param bccAddresses - List - optional
        @param contactId - String - required if template name is specified as SF requires it for merge fields in templates
        @param emailTemplateName - String - optional if emailsubject & emailbody specified
        @param emailSubject - String - optional if valid email template name specified
        @param emailBody - String - optional if valid email template name specified
        @param enableFile - boolean - optional if use of files is enabled
        
        @comments: If email template is used, we need to specify the contact. If not provided, it will look into Agreement's Primary contact else it has to be specified

   ******************************************************************/ 
   
    @HttpPost
    global Static void sendforreview(String agreementId,List<string> attachmentIds,List<String> toAddresses,List<String> ccAddresses,List<String> bccAddresses, String contactId, String emailTemplateName, String emailSubject, String emailBody, Boolean enableFile){
        if (agreementId != null)
            agreementId = String.escapeSingleQuotes(agreementId);
        if (contactId != null)
            contactId = String.escapeSingleQuotes(contactId);
        if (emailTemplateName != null)
            emailTemplateName = String.escapeSingleQuotes(emailTemplateName);
        if (emailSubject != null)
            emailSubject = String.escapeSingleQuotes(emailSubject);
        if (emailBody != null)
            emailBody = String.escapeSingleQuotes(emailBody);
        //vars
        Map<id,Attachment> attachmentMap;
        List<Attachment> fileAttachmentList;
        List<Messaging.EmailFileAttachment> lefa = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        List<string> bccSender = new List<string>();
        List<EmailTemplate> eTemplate;
        Boolean iseTemplate = false;
        
        //check if mandatory params received
        if(agreementId == null || agreementId == ''){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide agreement id.'); 
            return;
        }
        if(attachmentIds.isEmpty()){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide agreement attachment list.'); 
            return;
        }
        
        if (enableFile == null)
            enableFile = false;
        if(!enableFile){
            //query attachments
            attachmentMap = getAttachemnts(attachmentIds);
            
            //prepare email with file attahments
            for(ID attId : attachmentMap.keyset()){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(attachmentMap.get(attId).name);
                efa.setBody(attachmentMap.get(attId).body);
                efa.setContentType(attachmentMap.get(attId).ContentType);
                lefa.add(efa);
            }
        }
        else{
            fileAttachmentList = getFiles(agreementId, attachmentIds);
            for(Attachment fileAttachment : fileAttachmentList){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(fileAttachment.Name);
                efa.setBody(fileAttachment.Body);
                String contentType;
                system.debug('####content type:' + fileAttachment.ContentType);
                if(fileAttachment.ContentType == 'PDF'){
                    contentType = 'application/pdf';
                }else if(fileAttachment.ContentType == 'DOCX' || fileAttachment.ContentType == 'DOC' ||
                fileAttachment.ContentType == 'WORD_X' || fileAttachment.ContentType == 'WORD'){
                    contentType = 'application/msword';
                }else{
                    contentType = fileAttachment.ContentType;
                }
                efa.setContentType(contentType);
                lefa.add(efa);
            }
        }       
        
        //set email template if provided else set the html body
        if(emailTemplateName != null && emailTemplateName != ''){
            /*Apttus__APTS_Admin__c admin = [Select Id, Apttus__Value__c From Apttus__APTS_Admin__c Where Name = 'APTS_EmailTemplateForReview'];
            eTemplate = [Select id from EmailTemplate where Name =: admin.Apttus__Value__c];*/
            system.debug('###template name:' + emailTemplateName);
            eTemplate = [Select id from EmailTemplate where Name =:emailTemplateName];
            if(eTemplate == NULL || eTemplate.isEmpty()){
                RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide valid email template.');     
                return;
            }

        } else {
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide valid email template.');     
            return;
        }
        
        //check if provided emmail template found else see if there is html and subject else throw error
        if(eTemplate != null && !eTemplate.isEmpty()){
            iseTemplate = true;
            email.setTemplateID(eTemplate[0].Id);
        }else if(emailBody != null & emailBody != '' && emailSubject != null && emailSubject != ''){
            email.setHtmlBody(emailBody);
            email.setSubject(emailSubject);
        }else{

        }
                
        //set values and send
        
        //check for to addresses
        if(toAddresses != NULL && !toAddresses.isEmpty()){
            email.toaddresses = toAddresses;                
        }
        
        //set bcc sender
        if(bccAddresses != NULL && !bccAddresses.isEmpty()){
            email.setBccSender(true);
            email.setBccAddresses(bccAddresses);
        }
        
        //set ccc sender
        if(ccAddresses != NULL && !ccAddresses.isEmpty()){
            email.setCcAddresses(ccAddresses);
        }
        
        //set contact id if received else look in agreement (Primary contact), only rquired if email template is specified
        if(iseTemplate == true){
            if(contactId != NULL && contactId != ''){
                email.setTargetObjectId(contactId);        
            }else{
                /*List<Apttus__APTS_Agreement__c> agreementObj = [select id, name, Apttus__Primary_Contact__c from Apttus__APTS_Agreement__c where id =: agreementId];
                String agreementContactId = agreementObj[0].Apttus__Primary_Contact__c;
                if(agreementContactId != NULL){
                    email.setTargetObjectId(agreementContactId);    
                }else{*/
                    //send message
                    RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide contact id as it is required if email template is used.'); 
                    return;
                //}
            }
        }
        
        //set the agreement id for merge fields
        email.setWhatId(agreementId);
        //email.setTreatTargetObjectAsRecipient(false);
        
        
        
        try{
            //send email
            email.setFileAttachments(lefa);
            Messaging.SendEmailResult [] emailresult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            system.debug(emailresult);
            
            RestContext.response.responseBody = APTSMD_API_CommonUtils.convertStringToBlob('true'); 
            
        }catch(Exception ex){
            System.debug('Exception: '+ ex);            
            RestContext.response.responseBody = APTSMD_API_CommonUtils.getExceptionMessage(ex);
        }
        
        
        
    }
    
    public static Map<id,Attachment> getAttachemnts(List<String> attachmentIds){
        return new Map<id,Attachment>([select id,body,name,ContentType,Description,lastmodifiedDate from Attachment where id  in :attachmentIds]);
    }
    
    public static List<Attachment> getFiles(String agreementId, List<String> attachmentIds){
        system.debug('###Attachment Id:' + attachmentIds);
        List<Attachment> attachmentList = new List<Attachment>();
        List<ContentDocumentLink> generatedFiles = [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId = :agreementId  and LinkedEntity.Type='Apttus__APTS_Agreement__c' and (not ContentDocument.Title Like '%signed%') And ContentDocumentId in : attachmentIds];
        
        for(ContentDocumentLink contentDocLink : generatedFiles){
            Attachment attachmentSO=new Attachment(
                                Name = contentDocLink.ContentDocument.Title
                                , ContentType = contentDocLink.ContentDocument.FileType
                                , Body = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocLink.ContentDocumentId][0].VersionData
                                , ParentId = agreementId);
            attachmentList.add(attachmentSO);
        }
        
        return attachmentList;
    }
}