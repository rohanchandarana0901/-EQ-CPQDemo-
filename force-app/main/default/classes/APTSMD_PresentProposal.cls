/**
 * Company      : Apttus Inc.
 * Description  : Rest class to present proposal
 * History      :
 * [04.Jan.20198]: CaaS Team
 */ 

//@RestResource(urlMapping='/sendforreview')
@RestResource(urlMapping='/proposal/present')
global class APTSMD_PresentProposal {

   /*****************************************************************

       @param porposalId - String - required
       @param attachmentIds - List - required
       @param toAddresses - List - required if contactid not specified
       @param ccAddresses - List - optional
       @param bccAddresses - List - optional
       @param contactId - String - required if template name is specified as SF requires it for merge fields in templates
       @param emailTemplateName - String - optional if emailsubject & emailbody specified
       @param emailSubject - String - optional if valid email template name specified
       @param emailBody - String - optional if valid email template name specified

       @comments: If email template is used, we need to specify the contact. If not provided, it will look into Proposal's Primary contact else it has to be specified

   ******************************************************************/

    @HttpPost
    global Static void presentProposal(String proposalId,List<string> attachmentIds,List<String> toAddresses,List<String> ccAddresses,List<String> bccAddresses, String contactId, String emailTemplateName, String emailSubject, String emailBody){
        if (proposalId != null)
            proposalId = String.escapeSingleQuotes(proposalId);
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
        List<Messaging.EmailFileAttachment> lefa = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        List<string> bccSender = new List<string>();
        List<EmailTemplate> eTemplate;
        Boolean iseTemplate = false;

        //check if mandatory params received
        if(proposalId == null || proposalId == ''){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide proposal id.');
        }
        if(attachmentIds.isEmpty()){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide proposal attachment list.');
        }


        //query attachments
        attachmentMap = getAttachemnts(attachmentIds);

        //prepare email with file attachments
        for(ID attId : attachmentMap.keyset()){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attachmentMap.get(attId).name);
            efa.setBody(attachmentMap.get(attId).body);
            efa.setContentType(attachmentMap.get(attId).ContentType);
            lefa.add(efa);
        }


        //set email template if provided else set the html body
        if(emailTemplateName != null && emailTemplateName != ''){
            eTemplate = [Select id from EmailTemplate where DeveloperName =: emailTemplateName];

            if(eTemplate == NULL || eTemplate.isEmpty()){
                RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide valid email template.');
            }
        }

        //check if provided emmail template found else see if there is html and subject else throw error
        if(eTemplate != null && !eTemplate.isEmpty()){
            iseTemplate = true;
            email.setTemplateID(eTemplate[0].Id);
        }else if(emailBody != null & emailBody != '' && emailSubject != null && emailSubject != ''){
            email.setHtmlBody(emailBody);
            email.setSubject(emailSubject);
        }else{
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide email template name or Body with Subject.');
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

        //set contact id if received else look in proposal (Primary contact), only required if email template is specified
        if(iseTemplate == true){
            if(contactId != NULL && contactId != ''){
                email.setTargetObjectId(contactId);
            }else{
                /*List<Apttus_Proposal__Proposal__c> proposalObj = [select id, name, Apttus_Proposal__Primary_Contact__c from Apttus_Proposal__Proposal__c where id =: proposalId];
                String proposalContactId = proposalObj[0].Apttus_Proposal__Primary_Contact__c;
                if(proposalContactId != NULL){
                    email.setTargetObjectId(proposalContactId);
                }else{*/
                    //send message
                    RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide contact id as it is required if email template is used.');
                //}
            }
        }

        //set the proposal id for merge fields
        email.setWhatId(proposalId);

        try{
            //send email
            email.setFileAttachments(lefa);
            Messaging.SendEmailResult [] emailresult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

            if(emailresult[0].isSuccess()){
                system.debug(emailresult);
                RestContext.response.responseBody = APTSMD_API_CommonUtils.convertStringToBlob('true');
            }
            else {
                RestContext.response.responseBody = APTSMD_API_CommonUtils.convertStringToBlob('Email not successfully sent');
            }

        }catch(Exception ex){
            System.debug('Exception: '+ ex);
            RestContext.response.responseBody = APTSMD_API_CommonUtils.getExceptionMessage(ex);
        }

    }
    
    public static Map<id,Attachment> getAttachemnts(List<String> attachmentIds){
        return new Map<id,Attachment>([select id,body,name,ContentType,Description,lastmodifiedDate from Attachment where id  in :attachmentIds]);
    }
}