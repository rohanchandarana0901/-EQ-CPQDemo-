public with sharing class APTSMD_GenerateCompareQuoteController {

    // access-level and doc-format pdf
    private static final String accessLevel = 'Read Only';
    private static final String docFormat = 'pdf';
    
    // proposal id
    public ID proposalId {get; private set;}
    
    // quote template name
    private static String templateName = null;
    
    // message
    private String templateNotFoundMsg = 'Could not locate default quote template specified in Admin property.';
    
    // values set by vf page
    public String apiSessionId {get; set;}
    public String apiServerURL {get; set;}
    private Boolean initLoad = true;
    
    // generated quote info
    public QuoteDocument quoteInfo {get; private set;}
    public Boolean quoteGenerated {get; private set;}
    public String quoteURL {get; private set;}
    
    private Apttus_Proposal__Proposal__c proposal = null;
    public Boolean hasErrors {get; private set;}
    
    /**
     * Class Constructor specifying initial values
     * @param stdController the standard controller
     */
    public APTSMD_GenerateCompareQuoteController(ApexPages.StandardController stdController) {
                
        // get proposal object
        proposal = (Apttus_Proposal__Proposal__c)stdController.getRecord();
        proposalId = proposal.Id;
        //quoteURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=';commented by vp 29/03/2022
		quoteURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/';

    }
    
    public Boolean getInitialLoad() {
        return initLoad;
    }
    
    
    /**
     * Cancel and return to proposal detail view
     */
    public PageReference doCancel() {
        PageReference pageRef = new PageReference('/' + proposal.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * Create Quote pdf document
     */
    public PageReference doGenerateQuote() {
        
        ID templateId = getQuoteTemplateId();
        
        ID quoteDocId = null;
        hasErrors = false;
        initLoad = false;
        apiServerURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/42.0/'+UserInfo.getOrganizationId();

        try {
            if (templateId != null) {
                quoteDocId = Apttus_Proposal.MergeWebService.generateDoc(templateId
                                                            , proposalId
                                                            , accessLevel
                                                            , docFormat
                                                            , apiSessionId
                                                            , apiServerURL);       
              
                if (quoteDocId != null) {
                    /*
                    Attachment att = [select Id, Name, contentType, BodyLength
                                        from Attachment
                                        where Id = :quoteDocId];
                
                    quoteGenerated = true;
                    quoteURL = quoteURL + quoteDocId;
                    
                    quoteInfo = new QuoteDocument(att.Name, att.BodyLength, att.contentType);
					*/
                    //Original Query was for Attachment now it is for content document. VP 29/03/2022
                    ContentDocument att = [select id,FileType,Title,ContentSize,LatestPublishedVersionId from ContentDocument where id = :quoteDocId];
                    quoteGenerated = true;
					//Please use LatestPublishedVersionId insted of Id
                    quoteURL = quoteURL + att.LatestPublishedVersionId;
                    quoteInfo = new QuoteDocument(att.Title, att.ContentSize, att.FileType);
                }
            } else {
                hasErrors = true;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, templateNotFoundMsg);
                ApexPages.addMessage(msg);
                System.debug(templateNotFoundMsg);
            }
        } catch (Exception e) {
                System.debug('Quote Generation Failed for ' + templateName + ' <br>' + e.getMessage());
                hasErrors = true;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
                ApexPages.addMessage(msg);
        }
        return null;
    }
    
    /**
     * Get quote template name admin property
     */
    private String getQuoteTemplateId() {
        templateName = APTSMD_Apttus_PreSales_Config_Settings2__c.getInstance().APTSMD_Compare_Quote_Template_Name__c;
        
        if (templateName != null) {
            List<Apttus__APTS_Template__c> templateList =[select Id, Name from Apttus__APTS_Template__c
                                                    where Name = :templateName order by lastModifiedDate desc];
            if ((templateList != null) && (!templateList.isEmpty())) {
                return templateList[0].Id;
            }
        }
        return null;
    }
    
    // Wrapper class to hold document info
    public class QuoteDocument {
        public String quoteName {get; private set;}
        public String bodyLength {get; private set;}
        public String contentType {get; private set;}
        
        public QuoteDocument(String quoteName, Integer bodyLength, String contentType) {
            this.quoteName = quoteName;
            this.bodyLength = String.valueOf(bodyLength);
            this.contentType = contentType;
        } 
    }
}