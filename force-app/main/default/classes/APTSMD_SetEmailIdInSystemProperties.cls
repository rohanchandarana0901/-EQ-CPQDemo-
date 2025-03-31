/*
 *
 * @ Name : APTSMD_SetEmailIdInSystemProperties.cls 
 * @ Author : Sagar Jogi
 * @ CreatedDate : 20th Jan 2016
 * @ Description : To Set Reply To email id in approval customsetting
 * @ UsedBy : APTSMD_MDOHOMECtrl.cls
 * @ ForDemo : MDO
 ****************************************************************************************************************************************************************
 * @ ModifiedBy :  
 * @ ModifiedDate : 
 * @ ChangeDescription : 
 * @ ForDemo : 
 *
*/ 

global class APTSMD_SetEmailIdInSystemProperties
{
    @future(callout=true)
    public static void setReplytoEmailId()
    {   
        List<EmailServicesFunction>  emailFunctionOfApprovalList = [SELECT  Id  FROM EmailServicesFunction Where FunctionName ='Email Approval Services'];
        if(emailFunctionOfApprovalList.size() > 0) {
            List<EmailServicesAddress>  emailServiceAddressOfApprovalList = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId = :emailFunctionOfApprovalList[0].Id];
            String emailService;
            if(emailServiceAddressOfApprovalList.size() > 0) {
                emailService = emailServiceAddressOfApprovalList[0].LocalPart + '@' + emailServiceAddressOfApprovalList[0].EmailDomainName;
                Apttus_Approval__ApprovalsSystemProperties__c approvalEmailSystemProperties = Apttus_Approval__ApprovalsSystemProperties__c.getValues('System Properties');
                approvalEmailSystemProperties.Apttus_Approval__EmailApprovalServiceAddress__c = emailService;    
                approvalEmailSystemProperties.Apttus_Approval__InstanceUrl__c = URL.getOrgDomainUrl().toExternalForm();//added by vp to set instance url Date:14 Dec 2021
                update approvalEmailSystemProperties; 
            }
        }
    }
}