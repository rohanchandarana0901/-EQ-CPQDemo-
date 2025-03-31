/*
    REST API For Generating Agreement Document
    Type: POST
    Author : Sagar Pomal
    Date : 8-12-2014

    //sample params
    { templateId: 'a2a41000000nJ7', agreementId: "a3V410000005XDf"};    
    //optional:
    pLevel: //The protection level to apply to the document.
            Full access
            Insert comments only
            Insert comments and tracked changes only
            Read only
            Fill in form fields only

            //Default: Full access.
    docFormat:
            DOC
            DOCX
            PDF
            RTF

            //Default: PDF
    isDraft://Indicates whether a draft watermark should be added to the document. 
            Boolean
            //Default: False. Generates a Draft where the sales rep can view before generating the actual doc, which added watermark.

    //sample return
    attachmentid
    
*/
 
@RestResource(urlMapping='/agreement/generatedocs/*')
global class APTSMD_API_CLM_GenerateDocumentAgreement {
    
    @HttpPost
    global Static void generateDocumentAgreement(String templateId, String agreementId, String pLevel, String docFormat, Boolean isDraft){
        
        String apiServerURL  = null;
        String sessionId = '';
        
        sessionId = userInfo.getSessionId();
        
        if(pLevel==null || pLevel == ''){
             pLevel = 'Full access';             
        } 
        if(docFormat==null || docFormat == ''){
            docFormat = 'PDF';
        }
        if(isDraft==null){
            isDraft = false;
        }
        
        try{
            //check if template exists            
            List<Apttus__APTS_Template__c> templateList = [select id from Apttus__APTS_Template__c where id =: templateId];
            if(!templateList.isEmpty()){
                
                //check if agreement exists
                List<Apttus__APTS_Agreement__c> agreementList = [select id from Apttus__APTS_Agreement__c where id =: agreementId];
                if(!agreementList.isEmpty()){
                    
                    //call generate doc 
                    apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/44.0/' + UserInfo.getOrganizationId();
        
                    Id docId = Apttus.MergeWebService.generateDoc2(templateId, agreementId, pLevel, docFormat, isDraft, sessionId, apiServerURL);
                    RestContext.response.responseBody = APTSMD_API_CommonUtils.convertStringToBlob(docId); 
                    
                }else{
                    RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Invalid agreement id');
                }
                
            }else{
                RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Invalid template id');
            }
            
            
        }
        catch(Exception ex){      
            System.debug('Exception: '+ ex);            
            RestContext.response.responseBody = APTSMD_API_CommonUtils.getExceptionMessage(ex);
        }                              
    }
}