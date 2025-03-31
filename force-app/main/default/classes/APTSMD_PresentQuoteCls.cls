// APTSMD_PresentQuoteCls() - This class is used for handling opeartion like present quotes + send email with attachments.
// Last updated by Japan Bhavsar on 12/28/2018 - Code indentation + Code Clean
public class APTSMD_PresentQuoteCls {
    
    // Common Variable Initialization
    public string agreementAttachJSON {get;set;}
    public string contactTemplateJSON {get;set;}
    
    // Currancy Variable Initialization
    public boolean isMultiCurrancyOn {get;set;}
    public string defaultCurrancy {get;set;}
    public string dateFormat {get;set;}
    
    // Constructor Initialization
    public APTSMD_PresentQuoteCls(){
        
        // Set currancy information Start (By Japan Bhavsar on 12/28/2018)
        this.defaultCurrancy = APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(true,'');
        this.isMultiCurrancyOn = Schema.getGlobalDescribe().containsKey('CurrencyType');
        this.dateFormat = APTSMD_ConfigDataInfoUtility.getCurrAndDateFormat(false,'');
        // Set currancy information End (By Japan Bhavsar on 12/28/2018)
        
        id agreementId = ApexPages.currentPage().getParameters().get('id');
        list<AgrAttachmentWrapperCls> agrAttachWrapperList = new list<AgrAttachmentWrapperCls>();
        Apttus_Proposal__Proposal__c agreement = [SELECT id,Name,Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c WHERE id=:agreementId];
        list<Attachment> attachList = new list<Attachment>();
        attachList = [SELECT id,Name,BodyLength,lastModifiedDate FROM Attachment where parentid = :agreementId];
        list<contact> contactList = new list<contact>();
        contactList = [SELECT id,name,email FROM contact];
        list<user> userList = new list<user>();
        userList = [SELECT id,name,email FROM user where IsActive = true];
        list<EmailTemplate> templateList = new list<EmailTemplate>();
        Apttus_Proposal__ProposalSystemProperties__c proposalsetting = [select id,Apttus_Proposal__EmailTemplateForPresentingProposals__c	 from Apttus_Proposal__ProposalSystemProperties__c LIMIT 1];
        String templateName = 'Present Proposal';
        if(proposalsetting.Apttus_Proposal__EmailTemplateForPresentingProposals__c	==''){
            templateName = proposalsetting.Apttus_Proposal__EmailTemplateForPresentingProposals__c	;
        }
        templateList = [SELECT id,name FROM EmailTemplate where IsActive = true And Name = :templateName];
        for(Attachment attach:attachList){
            agrAttachWrapperList.add(new AgrAttachmentWrapperCls(attach,agreement));
        } 
        list<contactTemplateWrapperCls> contactTemplateWrapperList = new list<contactTemplateWrapperCls>();
        contactTemplateWrapperList.add(new contactTemplateWrapperCls(contactList,templateList,userList));
        contactTemplateJSON = JSON.serialize(contactTemplateWrapperList);
        agreementAttachJSON = JSON.serialize(agrAttachWrapperList);
    }
    
    // AgrAttachmentWrapperCls class initialization
    public class AgrAttachmentWrapperCls{
        public Attachment attachWrapper {get;set;}
        public Apttus_Proposal__Proposal__c agrWrapper {get;set;}
        public boolean selected {get;set;}
        public AgrAttachmentWrapperCls(Attachment att,Apttus_Proposal__Proposal__c agr){
            selected = false;
            attachWrapper = att;
            agrWrapper = agr;
        }
    }
    
    // contactTemplateWrapperCls class initialization
    public class contactTemplateWrapperCls{
        public list<contact> contactWrapper {get;set;}
        public list<emailtemplate> templateWrapper {get;set;}
        public list<user> userWrapper {get;set;}
        public contactTemplateWrapperCls(list<contact> con,list<emailtemplate> template,list<user> users){
            contactWrapper = con;
            templateWrapper = template;
            userWrapper = users;
        }
    }
    
    //sendEmail() - Send Email with selected attachments.
    @RemoteAction
    public static string sendEmail(string agrAtt,string userDetails,string userId,string templateId, string subject){
        list<AgrAttachmentWrapperCls> agrAttWrapList = (List<AgrAttachmentWrapperCls>) JSON.deserialize(agrAtt, List<AgrAttachmentWrapperCls>.class);
        list<Attachment> attIds = new list<Attachment>();
        // Create an instance of Mail
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId,userId,(string)agrAttWrapList[0].agrWrapper.Id);
        //send attachments
        list<id> attId = new list<id>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for(AgrAttachmentWrapperCls att:agrAttWrapList){
            if(att.selected){
                attId.add(att.attachWrapper.Id);
            }
        }
        for(Attachment a:[SELECT id,name,body from attachment where id IN:attId]){
          Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
          efa.setFileName(a.Name);
          efa.setBody(a.Body);
          fileAttachments.add(efa);
        }
        mail.setFileAttachments(fileAttachments);
        // Who you are sending the email to
        mail.setTargetObjectId(userId);
        // Update subject
        if(subject != '' && subject != null){
            mail.setSubject(subject);    
        }
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if(agrAttWrapList[0].agrWrapper.Apttus_Proposal__Approval_Stage__c != 'Presented'){
            updateAgreementStatus(agrAttWrapList[0].agrWrapper);
        }
        return agrAttWrapList[0].agrWrapper.Id;
    }
    
    // updateAgreementStatus() - Update Agreement Status.
    public static void updateAgreementStatus(Apttus_Proposal__Proposal__c proposal){
        proposal.Apttus_Proposal__Approval_Stage__c = 'Presented';
        update proposal;
    }
    
}