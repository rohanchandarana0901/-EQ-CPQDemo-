/*
    Apttus Echosign Integration for Quote/Proposal
    AttachmentWrapper - wrapper class for selecting attachments
     
    @2012 Apttus Inc. All rights reserved.
*/
public without sharing class APTSMD_AttachmentWrapper {
    
    public Attachment attachmentSO { get; set; }
    public Boolean selected { get; set; }
    
    // prevent empty instantiation
    private APTSMD_AttachmentWrapper() {
    }
    
    /**
    * Class Contructor with the following parameters
    * @param attachment NOT NULL attachment object
    * @param selected checked during display
    * @return AttachmentWrapper object
    */
    public APTSMD_AttachmentWrapper(Attachment attachment, Boolean selected) {
        this();
        this.attachmentSO = attachment;
        this.selected = selected;
    }
      
}