/**
    Apttus EchoSign Integration for Quote/Proposal
    SelectAttachmentController - Provides UI for selecting attachments.
     
    @2012 Apttus Inc. All rights reserved.
*/
public without sharing class APTSMD_SelectAttachmentController {          
    
    public static final String PARAM_DOCUMENT_IDS_CSV = 'documentIdsCsv';
    
    private static final String SIGNATURE_TYPE_LABEL = 'Signature Type';
    private static final String SIGNATURE_TYPE_VALUE_ESIG = 'e-Signature';
    private static final String SIGNATURE_TYPE_VALUE_WRITTEN = 'Written Signature';
    
    private static final String PROP_INSTANCE_URL = 'APTS_InstanceURL';
    
    // show only requested list of attachments
    private String documentIdsCsv = null;
    
    private List<APTSMD_AttachmentWrapper> attachments = null;
    
    private Apttus_Proposal__Proposal__c proposalSO;
        
    // currently selected attachment id list
    private Set<ID> curSelection;
    private List<ID> selectedList;
        
    // ui flag
    public Boolean showOrderPage {get; private set;}
        
    // user selected attachment that will be combined into a single document and sent for eSignature
    public List<Attachment> selectedAtts {get; set;}
    
    // to avoid showing up arrow
    public ID firstAttachmentId {get; private set;}
    // to avoid showing down arrow
    public ID lastAttachmentId {get; private set;}
    // action param for move up action
    public ID moveUpId {get; set;}
    // action param for move down action
    public ID moveDownId {get; set;}
    // helper map for moving up/down
    private Map<ID, Integer> idIndexMap = new Map<ID, Integer>();
    
    private ApexPages.StandardController controller;
    
    public APTSMD_SelectAttachmentController(ApexPages.StandardController stdController) {
        controller = stdController;
        proposalSO = (Apttus_Proposal__Proposal__c) controller.getRecord();  

        String documentIdsCsvStr = ApexPages.currentPage().getParameters().get(PARAM_DOCUMENT_IDS_CSV);
        if (hasValue(documentIdsCsvStr)) {
            documentIdsCsv = String.escapeSingleQuotes(documentIdsCsvStr);
        }
        
        curSelection = new Set<ID>();
        selectedList = new List<ID>();
        
        showOrderPage = false;
    }
    
    /**
     * Load attachments from database
     * Auto select if only one attachment and proceed to echosign send page
     */
    public PageReference loadAttachments() {
        
        attachments = new List<APTSMD_AttachmentWrapper>();
        
        if (hasValue(documentIdsCsv)) {
            loadRequestedAttachments();
            
        } else {
            loadProposalAttachments();
        }
        
        // auto select if only one attachment
        if (attachments.size() == 1) {
            attachments[0].selected = true;
            return doSelect();
        }
        return null;
    }
    
    /**
     * Load requested attachments from list of identifiers provided through input parameter
     */
    private void loadRequestedAttachments() {
        
        //get requested list of atatchments
        List<Attachment> attList = APTSMD_QueryHelper.getAttachments(documentIdsCsv);
        if (hasValue(attList)) {
            
            for (Attachment attSO : attList) {
                // create and add the attachment wrapper
                attachments.add(new APTSMD_AttachmentWrapper(attSO, false));
            }
        }
    }
    
    /**
     * Load proposal related attachments from database
     */
    private void loadProposalAttachments() {
        
        List<Attachment> attachList = APTSMD_QueryHelper.getChildAttachments(proposalSO.Id);
        if (hasValue(attachList)) {
            for (Attachment attSO : attachList) {
                attachments.add(new APTSMD_AttachmentWrapper(attSO, false));
            }
        }
    }
    
    /**
     * Get attachment wrapper objects
     * @return collection of attachment wrapper objects
     */
    public List<APTSMD_AttachmentWrapper> getAttachments() {
        return attachments;
    }
    
    /**
    * Launch EchoSignSend page if selected one attachment, else show order page.
    */
    public PageReference doSelect() {
        
        selectedList = new List<ID>();
        for (APTSMD_AttachmentWrapper wrapper : attachments) {
            if (wrapper.selected) {
                selectedList.add(wrapper.attachmentSO.Id);    
            }   
        }
        if (selectedList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Select atleast one attachment.'));
            return null;
        }   
        
        String attachIds = toCommaSepString(selectedList);
        // get attachments
        selectedAtts = APTSMD_QueryHelper.getAttachments(attachIds);
        
        if (selectedList.size() > 1) {
            return showOrderPage();
        } else {
            return doContinue();
        }
    }   
    
    /**
    * Return to attachment selection page
    */
    public PageReference doPrevious() {
        showOrderPage = false;
        return null;
    }
    
    /**
     * Show order page
     */
    private PageReference showOrderPage() {

        // setup to control rendering up/down arrows
        setupFirstLastIds();
        
        // save current attachment order
        saveIdIndexMap();
        
        // enable ui flag
        showOrderPage = true;
        
        return null;
    }
    
    /**
    * Launch EchoSign's visualforce page
    */
   public PageReference doContinue() {
    
        //create echosign agreement and associate it to this apttus agreement
        echosign_dev1__SIGN_Agreement__c esAgmt = new echosign_dev1__SIGN_Agreement__c(
            Apttus_Proposal__c = proposalSO.Id
            , Name = proposalSO.Apttus_Proposal__Proposal_Name__c
            , echosign_dev1__SignatureType__c = SIGNATURE_TYPE_VALUE_ESIG
            , echosign_dev1__SignatureOrder__c = null
            , echosign_dev1__Recipient__c = proposalSO.Apttus_Proposal__Primary_Contact__c
            , echosign_dev1__Message__c = 'Sign attached document.'
        );
        
        PageReference rtnPageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + proposalSO.Id);
        esAgmt.echosign_dev1__ReturnURL__c = rtnPageRef.getUrl();   
        
        insert esAgmt;
        System.debug(LoggingLevel.INFO, 'esAgmt='+esAgmt);
        
        // save order
        List<String> attNames = new List<String>();
        for (Attachment att : selectedAtts) {
            attNames.add(att.Name);
        }
        // clone and associate selected attachments to echosign agreement.
        List<Attachment> esAttList = APTSMD_QueryHelper.cloneAttachments(selectedAtts, esAgmt.Id);
        // prepare new es-attachments ordered list
        selectedList.clear();
        Map<String, ID> nameIdMap = new Map<String, ID>();
        for (Attachment esAtt : esAttList) {
            nameIdMap.put(esAtt.Name, esAtt.Id);
        }
        for (String attName : attNames) {
            selectedList.add(nameIdMap.get(attName));
        }
        //get list of es-attachment ids
        String attachmentIds = toCommaSepString(selectedList);
        // update esAgmt with attachmentIds for ordering
        esAgmt.echosign_dev1__Attachment_ID_Order__c = attachmentIds;       
        update esAgmt;
        
        // redirect to EchoSign page
        PageReference pageRef = new PageReference('/' + esAgmt.Id);
        pageRef.setRedirect(true); 

        return pageRef;
    }
    
    /**
     * Return to proposal detail view
     */
    public PageReference doCancel() {
        return new PageReference('/' + proposalSO.Id);    
    }
    
    /**
     * Move the corresponding attachment up in the list
     * @param moveUpId set by assignTo param
     */
    public PageReference doMoveUp() {
        Integer curIndex = idIndexMap.get(moveUpId);
        Attachment att = (Attachment)selectedAtts.remove(curIndex);
        selectedAtts.add(curIndex-1, att);
        setupFirstLastIds();
        saveIdIndexMap();

        return null;
    }
    
    /**
     * Move the corresponding attachment down in the list
     * @param moveDownId set by assignTo param
     */
    public PageReference doMoveDown() {
        Integer curIndex = idIndexMap.get(moveDownId);
        Attachment att = (Attachment)selectedAtts.remove(curIndex);
        if (selectedAtts.size() == curIndex + 1) {
            selectedAtts.add(att);
        } else {
            selectedAtts.add(curIndex + 1, att);
        }
        setupFirstLastIds();
        saveIdIndexMap();
        return null;
    }
    
    // setup first/last id to control move up/down arrow rendering
    private void setupFirstLastIds() {
        // setup first/last id for move up/down arrow rendering  
        firstAttachmentId = selectedAtts[0].Id;
        Integer lastIndex = selectedAtts.size() - 1;
        lastAttachmentId = selectedAtts[lastIndex].Id;      
    }
    
    // build attachmentId <> list-index map
    private void saveIdIndexMap() {
        idIndexMap.clear();
        for (Integer i=0; i < selectedAtts.size(); i++) {
            idIndexMap.put(selectedAtts[i].Id, i);
        }
    }
    /**
     * Convert the List of ID to comma seperated ID string
     * @param objList to be converted
     * @return string
     */
        private static String toCommaSepString(List<ID> idList) {
        String str = '';
        Boolean firstItem = true;
        if (idList != null) {
            for (ID id : idList) {
                if (id != null) {
                    if (! firstItem) {
                        str += ',';  
                    } else {
                        firstItem = false;
                    }
                    str += id;  
                }
            }
        }
        return str;
    }
    
    // has value?
    private static Boolean hasValue(String strValue) {
        if ((strValue == null) || (strValue.trim().length() == 0)) {
            return false;
        } else {
            return true;    
        }   
    }
    
    // has value?
    private static Boolean hasValue(List<SObject> objList) {
        if ((objList == null) || (objList.isEmpty())) {
            return false;
        } else {
            return true;    
        }   
    }
}