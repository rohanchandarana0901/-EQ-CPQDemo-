public class APTSMD_AgreementPortalConstant {   
    public static String ATTACHMENT_URL;
    public static String COMMUNITY_URL;
    public static String CONTACT_NAME;
    public static String MSA_TEMPLATE_NAME;
    public static String NDA_TEMPLATE_NAME;
    public static String NDA_VERIFICATION_TEMPLATE;
    public static String REVIEW_EMAIL_TEMPLATE;
    public static String PERMISSION_SET;
    public static String PORTAL_OWNER;
    public static String PROFILE_NAME;
    public static String SOW_TEMPLATE_NAME;
    public static String NDA_RECORD_TYPE_NAME;
    public static String MSA_RECORD_TYPE_NAME;
    public static String ACCOUNT_NAME;
    public static RecordType ndaRecordType;
    public Static RecordType msaRecordType;
    public static Group portalOwner;
    public static Account account;
    public static Contact contact;
    public static EmailTemplate emailTemplate;
    public static EmailTemplate reviewEmailTemplate;
    public static Profile portalProfile;
    public static String CONFIGNAME = 'Portal Config';
    public static String AgreementObjectNAME = 'Apttus__APTS_Agreement__c';
    public static String GroupTypeNAME = 'Queue';
    public static String SUCCESS = 'Success';
    public static String FAIL = 'Fail';
    public static String AgreementStatus = 'Submitted Request';
    public static String AgreementStatusCategory = 'Request';
    public static String PortalHomePage = 'APTSMD_AgreementPortalHomePage';
    static {
        APTSMD_AgreementPortal__c portalSetting = APTSMD_AgreementPortal__c.getValues(CONFIGNAME);
        if(portalSetting!=null){
            ATTACHMENT_URL = portalSetting.APTSMD_Attachment_Url__c;
            COMMUNITY_URL = portalSetting.APTSMD_Community_URL__c;
            CONTACT_NAME = portalSetting.APTSMD_Contact_Name__c;
            MSA_TEMPLATE_NAME = portalSetting.APTSMD_MSA_Template_Name__c;
            NDA_TEMPLATE_NAME = portalSetting.APTSMD_NDA_Template_Name__c;
            NDA_VERIFICATION_TEMPLATE = portalSetting.APTSMD_NDA_Verification_Template__c;
            PORTAL_OWNER = portalSetting.APTSMD_Portal_Owner__c;
            PERMISSION_SET = portalSetting.APTSMD_Permission_Set__c;
            SOW_TEMPLATE_NAME = portalSetting.APTSMD_SOW_Template_Name__c;
            NDA_RECORD_TYPE_NAME = portalSetting.APTSMD_NDA_RECORD_TYPE_NAME__c;
            MSA_RECORD_TYPE_NAME = portalSetting.APTSMD_MSA_Record_Type_Name__c;
            ACCOUNT_NAME = portalSetting.APTSMD_Portal_Account_Placeholder__c;
            PROFILE_NAME = portalSetting.APTSMD_Profile_Name__c;
            REVIEW_EMAIL_TEMPLATE = portalSetting.APTSMD_Review_Email_Template_Name__c;
            List<RecordType> listOfNDARecordType =  [SELECT Id, 
                                                            Name, 
                                                            DeveloperName 
                                                     FROM RecordType 
                                                     WHERE SObjectType =:AgreementObjectNAME 
                                                     and DeveloperName=:NDA_RECORD_TYPE_NAME];
            if(listOfNDARecordType!=null && listOfNDARecordType.size() > 0){
                ndaRecordType = listOfNDARecordType[0];
            }
            List<RecordType> listOfMSARecordType =  [SELECT Id, 
                                                            Name, 
                                                            DeveloperName 
                                                    FROM RecordType 
                                                    WHERE SObjectType =:AgreementObjectNAME 
                                                    and DeveloperName=:MSA_RECORD_TYPE_NAME];
            if(listOfMSARecordType!=null && listOfMSARecordType.size() > 0){
                msaRecordType = listOfMSARecordType[0];
            }
            List<Group> listOFGroup = [select Id from Group where DeveloperName =:PORTAL_OWNER and Type =:GroupTypeNAME ];
            if(listOFGroup!=null && listOFGroup.size() > 0){
                portalOwner = listOFGroup[0];
            }
            List<Account> listOfAccount = [SELECT ID, Name FROM Account where Name =:ACCOUNT_NAME ];
            if(listOfAccount!=null && listOfAccount.size() > 0){
                account = listOfAccount[0];
            }
            List<EmailTemplate> listOfTemplate = [select Id, Body  from EmailTemplate where DeveloperName =:NDA_VERIFICATION_TEMPLATE];
            if(listOfTemplate!=null && listOfTemplate.size() > 0){
                emailTemplate = listOfTemplate[0];
            }
            List<contact> listOfContact = [Select id from contact Where Name =:CONTACT_NAME];
            if(listOfContact!=null && listOfContact.size() > 0){
                contact = listOfContact[0];
            }
            List<Profile> listOfProfile = [SELECT Id FROM Profile WHERE Name=:PROFILE_NAME];
            if(listOfProfile!=null && listOfProfile.size() > 0){
                portalProfile = listOfProfile[0];
            }
            List<EmailTemplate> listOfReviewTemplate = [select Id, Body  from EmailTemplate where DeveloperName =:REVIEW_EMAIL_TEMPLATE];
            if(listOfReviewTemplate!=null && listOfReviewTemplate.size() > 0){
                reviewEmailTemplate = listOfReviewTemplate[0];
            }
        }
    }

}