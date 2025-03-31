/**
 *  Apttus Config & Pricing
 *  APTSMD_CPQHelper - This class is providing some helper classes for CPQ opeartion.
 *  Created By: Japan Bhavsar on 12/26/2018
 *  @2018-2019 Apttus Inc. All rights reserved.
 */
public abstract class APTSMD_CPQHelper{
    // nil value indicator
    private static final String NILVALUE = 'xsi:nil';
    /**
    * Creates a quote/proposal using the given opportunity
    * @param opptySO the opportunity to create the quote for
    * @return the id of the created quote/proposal
    */
    public static ID createQuoteOrProposal(Opportunity opptySO){
        // STEP I - get the proposal record type id        
        ID recordTypeId = null;
        String RECORDTYPE_PROPOSAL;
        RECORDTYPE_PROPOSAL = 'Proposal';
        
        if(recordTypeId == null){
            recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), RECORDTYPE_PROPOSAL);
        }
        // STEP II - create a new quote/proposal object from the opportunity
        Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, recordTypeId);    
        // save the proposal 
        insert proposalSO;
        // get the quote/proposal id
        Id DealId = createDealFromProposal(proposalSO);
        
        return proposalSO.Id;
    }
      
    /**
    * Creates a new proposal from the given opportunity
    * @param opptySO the opportunity to create the proposal for 
    * @param recordTypeId the record type id for the proposal
    * @return the created proposal
    */
    private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId){
        // STEP I - create a new proposal sobject
        Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c();
        // initialize the proposal from the opportunity
        // STEP II - copy known opportunity fields
        // record type id
        if(recordTypeId != null){
            proposalSO.RecordTypeId = recordTypeId;
        }
        // proposal name (max length = 50)
        String opptyName = opptySO.Name;
        if(opptyName != null && opptyName.length() > 50){
            opptyName = opptyName.substring(0, 50);
        }
        Integer quoteCount = [select count() from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :opptySO.Id and Apttus_Proposal__Primary__c = true];
        Boolean isPrimaryQuote = (quoteCount == 0 ? true : false);
        // base fields
        Datetime currentDate = Datetime.now();
        String dateOutput = currentDate.format('MM-YY');
        // proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName;
        proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName + ' Proposal ' + dateOutput;
        // opportunity
        proposalSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
        // account
        proposalSO.Apttus_Proposal__Account__c = opptySO.AccountId;
        //Bill To -  this is needed for Forecast Billing button on cart to work
        proposalSO.Apttus_QPConfig__BillToAccountId__c = opptySO.AccountId;
        // primary contact
        proposalSO.Apttus_Proposal__Primary_Contact__c = getPrimaryContactIdForAccount(opptySO.AccountId);
        // description
        proposalSO.Apttus_Proposal__Description__c = opptySO.Description;
        // primary
        proposalSO.Apttus_Proposal__Primary__c = isPrimaryQuote;
        // price list id
        proposalSO.Apttus_QPConfig__PriceListId__c = opptySO.APTSMD_Price_List__c;
        // pricing date
        proposalSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
        // valid until date
        proposalSO.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30);
        // ready to generate
        proposalSO.Apttus_Proposal__ReadyToGenerate__c = true;
        // ready to present
        proposalSO.Apttus_Proposal__ReadyToPresent__c = true;
        // owner
        proposalSO.OwnerId = opptySO.OwnerId;
        // QTC profile
        proposalSO.Apttus_QPConfig__QTCProfile__c = opptySO.APTSMD_QTC_Profile__c;
        // return the created proposal
        return proposalSO;
    }

    /**
    * Gets the record type id associated with the given sobject name and record type name
    * @param sObjectName the sobject name
    * @param recordTypeName the record type name to get the record type for
    * @return the record type id
    */
    public static ID getRecordTypeIdForName(String sObjectName, String recordTypeName){
        // get the record type 
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = :sObjectName AND (Name = :recordTypeName OR DeveloperName = :recordTypeName) LIMIT 1];
        return (!recordTypes.isEmpty() ? recordTypes[0].Id : null);
    }
      
    /**
    * Gets the primary contact id for the given account id
    * @param acctId the account id to to retrieve the contact for
    * @return the contact sobject id
    */
    private static ID getPrimaryContactIdForAccount(ID acctId){
        //Changed By  : Archil Prajapati
        
        //fetch default primary contact from presales config settings
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting = [select APTSMD_Default_Primary_Contact__c from APTSMD_Apttus_PreSales_Config_Settings2__c];//Query
        
        //get contact which matches the name with the value in the custom setting
        Contact matchedContact = [select id,name from Contact where name =: presalesSetting.APTSMD_Default_Primary_Contact__c Limit 1];//Query
    
        // get the contacts for the account
        Map<Id,Account> allAccountcontacts = new Map<ID, Account>([Select id,Name,(select Name from Contacts ORDER by APTSMD_Is_Primary_Contact__c DESC) FROM Account]);// Query
        
        return (!allAccountcontacts.get(acctId).Contacts.isEmpty() ? allAccountcontacts.get(acctId).Contacts[0].id : matchedContact.id);        
    }
      
    /**
    * Checks if the given string value is null or empty.
    * @param strValue the string to check
    * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
    */
    public static Boolean nullOrEmpty(String strValue){
        // check if null or zero length string
        return (strValue == null || strValue.trim().length() == 0);
    }
      
    /**
    * Checks if the given string value holds a nil value.
    * @param strValue the string to check
    * @return <code>true</code> if the string holds a nil value, <code>false</code> otherwise
    */
    public static Boolean isNilValue(String strValue){
        return (NILVALUE == strValue);
    }
    
    /**
    * Returns ifNull value when the value is null or empty.
    * Otherwise returns actual value
    */
    public static String nullValue(String value, String ifNull){
        if(nullOrEmpty(value) || isNilValue(value)){
            return ifNull;
        }
        return value;
    }
        
    /**
    * Gets the opportunity sobject for the given opportunity id
    * @param opptyId the opportunity id to retrieve
    * @return the opportunity sobject 
    */
    public static Opportunity getOpportunitySO(ID opptyId){
        // get the opportunity
        List<Opportunity> opportunities = [SELECT Id,Name,Type,StageName,APTSMD_Price_List__r.Name,APTSMD_Price_List__c,OwnerId,LeadSource,Description,
                    CloseDate,Amount,AccountId,APTSMD_Flow__c,APTSMD_QTC_Profile__c,APTSMD_Default_Product__c FROM Opportunity WHERE Id = :opptyId LIMIT 1];
        return (!opportunities.isEmpty() ? opportunities[0] : null);
    }
    
    /**
    * Creates a deal using the given proposal
    * @param proposalSO the proposal to create the deal for
    * @return the id of the created deal
    */
  public static ID createDealFromProposal(Apttus_Proposal__Proposal__c proposalSO) {    
    
    // STEP I - create a new deal sobject
    Apttus_DealMgr__Deal__c dealSO = new Apttus_DealMgr__Deal__c();
    
    // initialize the deal from the proposal
    
    // base fields
    dealSO.Apttus_DealMgr__DealName__c = 'Deal for ' + proposalSO.Apttus_Proposal__Proposal_Name__c;
    // proposal
    dealSO.APTSMD_Quote_Proposal_ID__c = proposalSO.Id;
    // opportunity
    dealSO.Apttus_DealMgr__RelatedOpportunityId__c = proposalSO.Apttus_Proposal__Opportunity__c;
    // account
    dealSO.Apttus_DealMgr__AccountId__c = proposalSO.Apttus_Proposal__Account__c;
    // owner
    dealSO.OwnerId = UserInfo.getUserId();
    // requestor
    dealSO.Apttus_DealMgr__Requestor__c = UserInfo.getUserId();
    // description
    dealSO.Apttus_DealMgr__Description__c = proposalSO.Apttus_Proposal__Description__c;
    // relate object type
    dealSO.Apttus_DealMgr__BusinessObject__c = 'Apttus_Proposal__Proposal__c';
    // status
    //dealSO.Apttus_DLApprov__Approval_Status__c = 'Not Submitted';
    
    insert dealSO;
    
    // get the deal id
    return dealSO.Id;      
    
  }
    
}