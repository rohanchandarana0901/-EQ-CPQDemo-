/*
This class used to Agreement Creation wizard for MSA and NDA to generate document and agrement send to Esignature.
*/
public class APTSMD_AgreementSubmitController {
    string sessionID; 
    String LOGIN_DOMAIN = 'login';
    string userName = 'eferrisv11.3@apttusdemo.com'; 
    string pwd = 'apttus2016';
    private final string SOAP_START = '<?xml version="1.0" encoding="utf-8"?>'; 
    public string id {get;set;}
    
    public APTSMD_AgreementSubmitController(){
        id = ApexPages.currentPage().getParameters().get('id');
         sessionID = Userinfo.getSessionId();
    }
    
    public PageReference generateDoc(){
        
        Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name, Apttus__VersionAware__c from Apttus__APTS_Agreement__c where Id=:id];
        if(agreement!=null){
            Apttus__APTS_Template__c template;
            APTSMD_Apttus_PreSales_Config_Settings2__c setting;
            if(agreement.RecordType.Name=='MSA'){
                setting = [select id,APTSMD_Default_MSA_Template__c from APTSMD_Apttus_PreSales_Config_Settings2__c LIMIT 1];
                template = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name =:setting.APTSMD_Default_MSA_Template__c LIMIT 1];
                
                if(agreement.Apttus__VersionAware__c){
                    APTSMD_generateDocumentHandler.generateDocumentVersion(template.Id,agreement.Id);
                    PageReference pr = new PageReference('/apex/APTSMD_GenerateDocWithVersion?id=' + id);
                    pr.setRedirect(true);
                    return pr;
                }else{
                    APTSMD_generateDocumentHandler.generateDocument(template.Id,agreement.Id, sessionID,false);
                }
            }else{
                setting = [select id,APTSMD_Default_NDA_Template__c from APTSMD_Apttus_PreSales_Config_Settings2__c LIMIT 1];
                template = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name =:setting.APTSMD_Default_NDA_Template__c LIMIT 1];
                APTSMD_generateDocumentHandler.generateDocument(template.Id,agreement.Id, sessionID,true);
            }
            
        }
        PageReference pr = new PageReference('/apex/APTSMD_GenerateDocNext?id=' + id);
        pr.setRedirect(true);
        return pr;

    }
    
    public PageReference generateDocWithVersion(){
        APTSMD_generateDocumentHandler.generateDocumentWithVersion(id);
        
        PageReference pr = new PageReference('/apex/APTSMD_GenerateDocNext?id=' + id);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference generateDocNext(){
       
        Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name,Apttus__Primary_Contact__c from Apttus__APTS_Agreement__c where Id=:id];
        if(agreement!=null){
            if(agreement.RecordType.Name=='MSA'){
                APTSMD_Apttus_PreSales_Config_Settings2__c setting = [select id,APTSMD_Default_NDA_Template__c from APTSMD_Apttus_PreSales_Config_Settings2__c LIMIT 1];
                Apttus__APTS_Template__c ndaTemplate = getTemplateByName(setting.APTSMD_Default_NDA_Template__c);
                List<Apttus__APTS_Related_Agreement__c> relatedList = new List<Apttus__APTS_Related_Agreement__c>();
                relatedList = [select id , Apttus__APTS_Contract_To__c  from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c =: agreement.Id];
                if(relatedList!=null && relatedList.size() > 0){
                    APTSMD_generateDocumentHandler.generateDocument(ndaTemplate.Id,relatedList[0].Apttus__APTS_Contract_To__c, sessionID,true);
                    
                    if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
                        Contact contact = [Select Id, FirstName, LastName, Email From Contact Where Id = :agreement.Apttus__Primary_Contact__c];
                            
                        Apttus_DocuApi__DocuSignDefaultRecipient2__c defaultRecipientObj = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                        defaultRecipientObj.Apttus_CMDSign__AgreementId__c = relatedList[0].Apttus__APTS_Contract_To__c;
                        defaultRecipientObj.RecordTypeId = Apttus_DocuApi__DocuSignDefaultRecipient2__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
                        defaultRecipientObj.Apttus_DocuApi__ContactId__c = contact.Id;
                        defaultRecipientObj.Apttus_DocuApi__SigningOrder__c = 1;
                        defaultRecipientObj.Apttus_DocuApi__IsTransient__c = false;
                        insert defaultRecipientObj;
                    }
                }
            }
        }
        
        PageReference pr = new PageReference('/apex/APTSMD_AgreementSendToES?id=' + id);
        pr.setRedirect(true);
        return pr;

    }
    
    public PageReference createParentAgreementIfRecordTypeMSA(){
        Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Primary_Contact__c,Apttus__Account__c,Apttus__Status_Category__c,Apttus__Status__c,RecordTypeId,Name,Apttus__Parent_Agreement__c,RecordType.Name from Apttus__APTS_Agreement__c where Id=:id];
        if(agreement!=null && agreement.RecordType.Name=='MSA'){
            RecordType ndaRecordType =  [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Apttus__APTS_Agreement__c' and DeveloperName='APTSMD_NDA'][0];
            Apttus__APTS_Agreement__c clonedObj = agreement.clone(false, true, false, false);
            clonedObj.Name = agreement.Name+'_NDA';
            clonedObj.Apttus__Primary_Contact__c = agreement.Apttus__Primary_Contact__c;
            clonedObj.Apttus__Account__c = agreement.Apttus__Account__c;
            clonedObj.Apttus__Account__c = agreement.Apttus__Account__c;
            clonedObj.RecordTypeId = ndaRecordType.id;
            insert clonedObj;
            Apttus__APTS_Related_Agreement__c apts = new Apttus__APTS_Related_Agreement__c();
            apts.Name  = 'Related NDA';
            apts.Apttus__APTS_Contract_From__c = agreement.Id;
            apts.Apttus__Relationship_From_Type__c = 'Related NDA Is';
            apts.Apttus__APTS_Contract_To__c = clonedObj.Id;
            apts.Apttus__Relationship_To_Type__c = 'IS NDA for';
            insert apts;
        }
        PageReference pr = new PageReference('/apex/APTSMD_GenerateDoc?id=' + id);
        pr.setRedirect(true);
        return pr;

    }
    
    public Apttus__APTS_Template__c getTemplateByName(String templateName){
        return [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name =:templateName LIMIT 1];
    }
    
    
    public PageReference sendForEsignature(){
        Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name from Apttus__APTS_Agreement__c where Id=:id];
        if(agreement!=null){
            if(agreement.RecordType.Name=='MSA'){
                List<Apttus__APTS_Related_Agreement__c> relatedList = new List<Apttus__APTS_Related_Agreement__c>();
                relatedList = [select id , Apttus__APTS_Contract_To__c  from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c =: agreement.Id];
                if(relatedList!=null && relatedList.size() > 0){
                    if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
                        APTSMD_generateDocumentHandler.sendToDocuSign(relatedList[0].Apttus__APTS_Contract_To__c);
                    }else{
                        APTSMD_generateDocumentHandler.sendToEchoSign(relatedList[0].Apttus__APTS_Contract_To__c);
                    }
                }
            } else {
                if(APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Esignature_Type__c=='Docusign'){
                    APTSMD_generateDocumentHandler.sendToDocuSign(id);
                }else{
                    APTSMD_generateDocumentHandler.sendToEchoSign(id);
                }
            }
        }
        
        PageReference pr = new PageReference('/apex/APTSMD_AgreementSendToESNext?id=' + id);
        pr.setRedirect(true);
        return pr;
    }
    
       public void sendForEsignatureNext(){
        //  Apttus__APTS_Agreement__c agreement = [select Id,Apttus__Parent_Agreement__c,RecordType.Name from Apttus__APTS_Agreement__c where Id=:id];
        //  if(agreement!=null){
        //     if(agreement.RecordType.Name=='MSA'){
        //         List<Apttus__APTS_Related_Agreement__c> relatedList = new List<Apttus__APTS_Related_Agreement__c>();
        //         relatedList = [select id , Apttus__APTS_Contract_To__c  from Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c =: agreement.Id];
        //         if(relatedList!=null && relatedList.size() > 0){
        //             APTSMD_generateDocumentHandler.sendToEchoSign(relatedList[0].Apttus__APTS_Contract_To__c);
        //         } 
        //     }
        // }
    }
    
   
}