/*
    Apttus Contract Management
    Merge Documents Controller for Contract Management.
    It will select documents from notes and attachment and merge based on sequencing provided.
*/

public with sharing class APTSMD_MergeDocumentsAgreementCtrl{ 
    public list<AttachmentWrapper> lstWrapper {get;set;}
    Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(); 
    private list<Attachment> lstAttachment = new list<Attachment>(); 
    public string alertMessage {get;set;}
    private list<ContentDocumentLink> contentDocLink = new list<ContentDocumentLink>();
 
    public APTSMD_MergeDocumentsAgreementCtrl(){ 
        this.alertMessage = '';
        // this.showLoading = false;
        lstWrapper=new list<AttachmentWrapper>(); 
        Id IdPAgmt=Apexpages.currentPage().getParameters().get('Id'); 
        
        agreement=[select id,Name from Apttus__APTS_Agreement__c where Id=:IdPAgmt limit 1]; 
        //Getting Comply System Properties
        Apttus__ComplySystemProperties__c ComplySystemProperty = [select Apttus__EnableFile__c from Apttus__ComplySystemProperties__c];
        
        //If file enabled is true
        if(ComplySystemProperty.Apttus__EnableFile__c == true){
           contentDocLink = [select ContentDocumentId,ContentDocument.Title,ContentDocument.ContentModifiedDate, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Apttus__APTS_Agreement__c where Id =: IdPAgmt)];
            if(contentDocLink.size()>0){
                for(ContentDocumentLink attach:contentDocLink){ 
                    lstWrapper.add(new AttachmentWrapper(false,attach.ContentDocumentId,attach.ContentDocument.Title,attach.ContentDocument.ContentModifiedDate)); 
                } 
            }
        }
        else{
             lstAttachment=[select id,Name,LastModifiedDate from Attachment where ParentId=:IdPAgmt];
              if(lstAttachment.size()>0){ 
                  for(Attachment attach:lstAttachment){ 
                      lstWrapper.add(new AttachmentWrapper(false,attach.Id,attach.Name,attach.LastModifiedDate)); 
                  } 
              }
        }
        
        // fileAttachment=[select id,Title from ContentDocument where ParentId=:IdPAgmt];
    } 
 
    public PageReference Cancel(){ 
        Pagereference pageref=new pagereference('/'+agreement.Id); 
        pageref.setredirect(true); 
        return pageref; 
    } 
 
    public PageReference MergeDocument(){ 
        try{
                this.alertMessage = '';
                // this.showLoading = true;
                list<id> lstDocumentIds=new list<Id>(); 
                String SESSION_ID=userInfo.getSessionId();//SessionId 
                //String apiServerURL=URL.getOrgDomainUrl().toExternalForm()+'/services/Soap/u/42.0/'+UserInfo.getOrganizationId(); 
                String apiServerURL=System.Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/42.0/'+UserInfo.getOrganizationId();
                String fileName; 
                system.debug('URL='+apiServerURL); 
                lstWrapper.sort(); 
                for(AttachmentWrapper wrapper:lstWrapper){ 
                    fileName=wrapper.Name; 
                    if(wrapper.selected){ 
                        lstDocumentIds.add(wrapper.attachId); 
                    } 
                } 
                //show message if not any attachment selected
                if(lstDocumentIds.size() == 0 || lstDocumentIds.size() == 1){
                    // Pass error message (In error section but we need window alert ui)
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select atleast one attachment for merging.'));
                    //return null;
                    // this.showLoading = false;
                    this.alertMessage = 'Please select atleast 2 attachments to merge';
                    return null;
                }
         
                //Apttus.MergeWebService.mergeDocsToPDF(agreement.Id,lstDocumentIds,agreement.name+'_Merged_'+Datetime.now().format('yyyy-MM-dd')+'.pdf',SESSION_ID,apiServerURL);
                Apttus.CustomClass.ActionParams apiParameters = new Apttus.CustomClass.ActionParams();
  
                apiParameters.ParentId = agreement.Id;
                apiParameters.DocIds = lstDocumentIds;
                apiParameters.DocFileName = agreement.name+'_Merged_'+Datetime.now().format('yyyy-MM-dd')+'.pdf';
                apiParameters.PreserveRedlines = true;
                apiParameters.ProtectOutputDoc = false;
                apiParameters.SessionId = SESSION_ID;
                apiParameters.SessionUrl = apiServerURL;
                apiParameters.addAutoHeaderFooter = true;

                Apttus.MergeWebService.mergeDocsToPDF2(apiParameters);
                Pagereference pageref=new pagereference('/'+agreement.Id); 
                pageref.setredirect(true); 
                this.alertMessage = 'Oops! something went wrong. Please try again later';
                //this.showLoading = false;
                return pageref; 
            
            
        }catch(Exception ex){
            // this.showLoading = false;
            Pagereference pageref=new pagereference('/'+agreement.Id); 
            pageref.setredirect(true); 
            return pageref;
        }  
    } 
 
    //wrapperclassformasterendnotes 
    public class AttachmentWrapper implements Comparable{ 
     
        public integer sequence{get;set;} 
        public Boolean selected { get; set; }
        public ID attachId { get; set; }
        public string Name { get; set; }
        public Datetime LastModifiedDate { get; set; }
        
        public AttachmentWrapper(Boolean selected, ID attachId, string Name, Datetime LastModifiedDate) {
       // this.attachmentSO = attachment;
        this.selected = selected;
        this.attachId = attachId;
        this.Name = Name;
        this.LastModifiedDate = LastModifiedDate;
        }
        
        public Integer compareTo(Object compareTo){ 
        //Idon'tknowwhatcriteriayouwanttosorton 
            AttachmentWrapper other=(AttachmentWrapper)compareTo; 
            if(this.sequence>other.sequence) 
                return 1; 
            else if(this.sequence==other.sequence) 
                return 0; 
                return -1; 
        } 
    } 
}