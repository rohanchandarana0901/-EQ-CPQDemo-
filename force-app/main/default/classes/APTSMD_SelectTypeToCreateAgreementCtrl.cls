/**
*Name: APTSMD_SelectTypeToCreateAgreement 
*Description: Screen for select record type to create agreement
*Author: Japan Bhavsar
*Created Date: 2/1/2019
**/
public class APTSMD_SelectTypeToCreateAgreementCtrl {
    
    // Variable Initialization
    private Apttus_Proposal__Proposal__c proposal;
    public RecordTypeWrapper rtWrapper {get; set;}
    public List<RecordTypeWrapper> rtWrapperList {get; set;}
    public List<SelectOption> listOfFields{get;set;}
    public String selectedField{get;set;}
    public string isCopyLineItemAllowed;
    
    // Constructor APTSMD_SelectTypeToCreateAgreement() - Fetch Proposal Record + Setup Record Type Logics
    public APTSMD_SelectTypeToCreateAgreementCtrl(ApexPages.StandardController stdController){
        // Fetch current agreement record
        this.proposal = (Apttus_Proposal__Proposal__c)stdController.getRecord();
        // Fetch parameter
        this.isCopyLineItemAllowed = apexpages.currentpage().getparameters().get('copyLineItems');
        if(this.isCopyLineItemAllowed == '' || this.isCopyLineItemAllowed == null){
            this.isCopyLineItemAllowed = 'True';
        }
        // Fetch all the record types
        Schema.DescribeSObjectResult RecordDetail = Apttus__APTS_Agreement__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RecordTypes = RecordDetail.getRecordTypeInfos();
        // This query is for fetching info from database
        Map<id,RecordType> recTypeIDvsDesc = new Map<id,RecordType>([SELECT Id,  Name, DeveloperName, Description 
            FROM RecordType WHERE SobjectType = 'Apttus__APTS_Agreement__c']);
        rtWrapperList = new List<RecordTypeWrapper>();
        // Initialize select option
        listOfFields = new List<SelectOption>();
        // Iterate all record type for check activation of records
        System.debug('RecordTypes' + RecordTypes);
        for(Schema.RecordTypeInfo rt : RecordTypes){
            // Check if this is available for this user
            if(rt.isActive() && rt.isAvailable() && !rt.isMaster()){
                rtWrapper = new RecordTypeWrapper();
                rtWrapper.recordTypeName = rt.getName();
                rtWrapper.recordTypeID = rt.getRecordTypeId();
                rtWrapper.isDefault = rt.isDefaultRecordTypeMapping();
                rtWrapper.description = recTypeIDvsDesc.get(rt.getRecordTypeId()).Description;
                rtWrapperList.add(rtWrapper);
                // Add this name andid to selectoption
                listOfFields.add(new SelectOption(String.valueOf(rt.getRecordTypeId()),String.valueOf(rt.getName())));
            }
        }
        
        // Now check if there is only one record in list then please directly call the function
        if(rtWrapperList != null && rtWrapperList.size() == 1){
            selectedField = String.valueOf(rtWrapperList[0].recordTypeID);
            // Call function doContinue
            doContinue();
        }
    }
    
    
    // doContinue() - Do continue method for create an agreement
    public PageReference doContinue(){        
        if(selectedField != null  && selectedField != ''){            
            return new PageReference('/apex/apttus_qpcomply__ProposalAgreementNew?copyLineItems='+ isCopyLineItemAllowed +'&id=' + proposal.Id + '&recordTypeId=' + selectedField);
        }else{
            return null;
        }        
    }
    
    // doCancel() - Cancle operation and go back to proposal page
    public PageReference doCancel(){        
        return new PageReference('/' + proposal.Id);
    }
    
    // Create wrapper class for record type
    public class RecordTypeWrapper{
        public string recordTypeName {get; set;}
        public string recordTypeID {get; set;}
        public boolean isDefault {get; set;}
        public string description {get; set;}
        public RecordTypeWrapper(){
            this.recordTypeName = '';
            this.recordTypeID = '';
            this.isDefault = false;
            this.description = '';
        }
    }
}