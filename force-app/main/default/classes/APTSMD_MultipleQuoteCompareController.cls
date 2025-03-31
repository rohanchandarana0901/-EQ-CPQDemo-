global class APTSMD_MultipleQuoteCompareController{

    public ID opportunityId {get;set;}
    public Opportunity oppty{get;set;} 
    //private static Id opttyId;
    private ID returnId;
    public list<string> statusFilter{get; set;}
    Public static List<Apttus_Proposal__Proposal__c> proposalList;
    Public String QuotelistJson {get{return JSON.Serialize(proposalList);}}
    public String processStep {get{return processStepCont;}}
    public String processStepCont {get; set;}
    private static ID primaryContactId;
    public Set<String> propStatus{get; set;}
    public string propStatusJSON{get{return JSON.serialize(propStatus);}set;}
    public static Set<Id> addedQuotes;
    public static Set<String> addedQuoteNames{get;set;}
    public transient Component.Apex.StyleSheet customCSSStyle{get;set;}
    public Static List<fieldWrapper> listPLIPageFieldWrapper;
    public Static string PLIPageFieldsJSON{get;set;}
    public Static List<fieldWrapper> listPLILineFieldWrapper;
    public Static string PLILineFieldsJSON{get;set;}
    public Static List<fieldWrapper> listPropFieldWrapper;
    public Static string PropFieldsJSON{get;set;}
    public Integer MaxfieldsForPageLayout;
    public Integer MaxfieldsForLineLayout;
    public Integer MaxfieldsForPropLayout;
    public Integer counterPageFields;
    public Integer counterLineFields;
    public Integer counterPropFields;
    public Map<String,String> typeAPIMap = new Map<String,String>();
    Global string propDateFieldsJSON{get;set;}
    //String queryString;
    //constructor
    public APTSMD_MultipleQuoteCompareController(ApexPages.StandardController stdController) {
        //this.oppty = (Opportunity) ;
        this.oppty = [SELECT Name, AccountId,Account.Name FROM Opportunity WHERE Id =: stdController.getRecord().Id];
        this.opportunityId = oppty.Id;
        this.returnId = oppty.Id;
        proposalList = new List<Apttus_Proposal__Proposal__c>();
        propStatus= new set<string>();
        listPLIPageFieldWrapper = new List<fieldWrapper> ();
        listPLILineFieldWrapper = new List<fieldWrapper> ();
        listPropFieldWrapper = new List<fieldWrapper> ();
        
        Schema.DescribeFieldResult fieldResult = Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c.getDescribe();
     
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        propStatus.add('Status');
        for( Schema.PicklistEntry f : ple)
        {
           propStatus.add(f.getLabel());
        }
        
        init();
        setCustomCSSPath();
        //queryString = 'select id,';
        
        //Fields for Page Layout Line items
        MaxfieldsForPageLayout = 11;
        counterPageFields = 1;
        List<Schema.FieldSetMember> fieldSetMemberList =  APTSMD_MultipleQuoteCompareController.readFieldSet('APTSMD_QuoteCompare_Page_Fields','Apttus_Proposal__Proposal_Line_Item__c');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            //queryString += fieldSetMemberObj.getFieldPath() + ', ';
            if(counterPageFields > MaxfieldsForPageLayout)
            break;
            listPLIPageFieldWrapper.add(new fieldWrapper (String.valueOf(fieldSetMemberObj.getFieldPath()),String.valueOf(fieldSetMemberObj.getLabel()),String.valueOf(fieldSetMemberObj.getType())));
            counterPageFields ++;
            
        }
        PLIPageFieldsJSON=JSON.serialize(listPLIPageFieldWrapper);
        
        //Fields for Line Layout Line items
        MaxfieldsForLineLayout = 4;
        counterLineFields = 1;
        List<Schema.FieldSetMember> fieldSetMemberList1 =  APTSMD_MultipleQuoteCompareController.readFieldSet('APTSMD_QuoteCompare_Line_Fields','Apttus_Proposal__Proposal_Line_Item__c');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList1)
        {
            //queryString += fieldSetMemberObj.getFieldPath() + ', ';
            if(counterLineFields > MaxfieldsForLineLayout)
            break;
            listPLILineFieldWrapper.add(new fieldWrapper (String.valueOf(fieldSetMemberObj.getFieldPath()),String.valueOf(fieldSetMemberObj.getLabel()),String.valueOf(fieldSetMemberObj.getType())));
            counterLineFields ++;
        }
        PLILineFieldsJSON=JSON.serialize(listPLILineFieldWrapper);
        
        MaxfieldsForPropLayout = 8;
        counterPropFields = 1;
        List<Schema.FieldSetMember> fieldSetMemberList2 =  APTSMD_MultipleQuoteCompareController.readFieldSet('APTSMD_QuoteCompare_Fields','Apttus_Proposal__Proposal__c');
        listPropFieldWrapper.add(new fieldWrapper ('Name','Quote Id','STRING'));
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList2)
        {
            //queryString += fieldSetMemberObj.getFieldPath() + ', ';
            if(counterPropFields > MaxfieldsForPropLayout)
            break;
            listPropFieldWrapper.add(new fieldWrapper (String.valueOf(fieldSetMemberObj.getFieldPath()),String.valueOf(fieldSetMemberObj.getLabel()),String.valueOf(fieldSetMemberObj.getType())));
            
            if(String.valueOf(fieldSetMemberObj.getType()) == 'DATE'){
                typeAPIMap.put(String.valueOf(fieldSetMemberObj.getFieldPath()),String.valueOf(fieldSetMemberObj.getType()));
            }
            counterPropFields ++;
        }
        PropFieldsJSON=JSON.serialize(listPropFieldWrapper);
        propDateFieldsJSON = JSON.serialize(typeAPIMap);
    }
     public void setCustomCSSPath(){
             String path;
             Apttus_Config2__ConfigSystemProperties__c config = Apttus_Config2__ConfigSystemProperties__c.getValues('System Properties');
             if(config !=null && config.Apttus_Config2__CSSOverride__c !=null){
                 String resourceName = config.Apttus_Config2__CSSOverride__c;
                 List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
                                    
                //Checking if the result is returned or not
                if(resourceList.size() == 1)
                {
                   //Getting namespace
                   String namespace = resourceList[0].NamespacePrefix;
                   //Resource URL
                   path= '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
                   customCSSStyle= new Component.Apex.StyleSheet();
                   customCSSStyle.value=path;
                }
             } 
         } 
    /*
     * init method on page load
    */ 
    private void init() {
        processStepCont = 'prompt';

        //get the list of quotes for the passed optty id
        List<Apttus_Proposal__Proposal__c> quoteList = getOpportunityQuotes(opportunityId);
        
        //ensure the optty has more than one quote for comparing
        if(quoteList!=null){
        if (quoteList.size() <= 1) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Should have two or more Quotes.');
            ApexPages.addMessage(msg);
            return;
        }    }

    }
    

    /*
     * method called for page-direction
     */
    @RemoteAction 
    public static List<QuoteLIWrapper> doPageDirection(String quoteIds) {
    
        if(addedQuotes == null)
            addedQuotes = new Set<Id>();
        
        // Added by Japan Bhavsar - first check if any data is there in JSON String
        if(quoteIds == '[]'){
            return new List<QuoteLIWrapper>();
        }
        
        for(String quoteId: (List<String>) JSON.deserialize(quoteIds, List<String>.class))
            addedQuotes.add(quoteId);

        //get the line items for display
        return createQuoteLIDetails();
    }
    
    //method for lineDirection
    @RemoteAction 
    public static List<QuoteProductLIWrapper> doLineDirection(String quoteIds) {
        if(addedQuotes == null)
            addedQuotes = new Set<Id>();
           
         // Added by Japan Bhavsar - first check if any data is there in JSON String
        if(quoteIds == '[]'){
            return new List<QuoteProductLIWrapper>();
        } 
         
        for(String quoteId: (List<String>) JSON.deserialize(quoteIds, List<String>.class))
            addedQuotes.add(quoteId);
        
        //get the line items for display
        return createLineDirPLI();
    }
    
    //method called on save action
    @RemoteAction
    public static String doSave(String opportunityId, String quoteWrapper) {

        // get the opportunity sobject
        Opportunity opptySO = getOpportunitySO(opportunityId);
        // create the quote/proposal
        String quoteName = 'QuoteComparison - ' + System.now();
        ID proposalId = createQuote(opptySO, quoteName, primaryContactId);
        
        //copy the proposal line items onto the created quote
        List<Apttus_Proposal__Proposal_Line_Item__c> pliList;
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLIMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        
        //for each proposal create a new quote proposal record
        List<APTSMD_Quote_Comparator__c> quoteCompareRecList = new List<APTSMD_Quote_Comparator__c>();
        for(QuoteLIWrapper quoteLIWrapper : (List<QuoteLIWrapper>) JSON.deserialize(quoteWrapper, List<QuoteLIWrapper>.class)){
            
            Apttus_Proposal__Proposal__c quote = quoteLIWrapper.quote;
            
            APTSMD_Quote_Comparator__c quoteComparator = new APTSMD_Quote_Comparator__c();
            quoteComparator.APTSMD_Quote_Proposal__c = proposalId ;
            quoteComparator.APTSMD_Related_Quote_Id__c = quote.Id;
            quoteComparator.APTSMD_Related_Quote__c = quote.Name;
            quoteComparator.APTSMD_Related_Quote_Name__c = quote.Apttus_Proposal__Proposal_Name__c;
            quoteCompareRecList.add(quoteComparator);
            quoteLIMap.put(quoteLIWrapper.quote.Id, quoteLIWrapper.pliList );
        }
        
        insert quoteCompareRecList;
        
        List<APTSMD_Related_Proposal_Line_Item__c > updatePliList = new List<APTSMD_Related_Proposal_Line_Item__c >();
        for(APTSMD_Quote_Comparator__c quote: quoteCompareRecList){
            pliList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            pliList = quoteLIMap.get(quote.APTSMD_Related_Quote_Id__c);
            for(Apttus_Proposal__Proposal_Line_Item__c pli : pliList){
                APTSMD_Related_Proposal_Line_Item__c relatedPLI = new APTSMD_Related_Proposal_Line_Item__c();
                relatedPLI.APTSMD_Quote_Comparator__c = quote.Id;
                relatedPLI.APTSMD_Proposal_Line_Item__c = pli.Id;
                updatePliList.add(relatedPLI);
            }
        }
        insert updatePliList ;
        
        return proposalId;
    }
    
    /**
     * Return to caller
     */
    public PageReference doCancel() {
        
        return new PageReference('/' + returnId);
    }   
    
    private static List<QuoteLIWrapper> createQuoteLIDetails(){
        List<QuoteLIWrapper> quoteWrapperList  = new List<QuoteLIWrapper>();
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> tempPLIMap =  new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        List<Apttus_Proposal__Proposal_Line_Item__c> pliList;
        String opttyId ;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItemSOList = getProposalLineItems(addedQuotes);
        
        //create the quote-proposal line item map             
        for(Apttus_Proposal__Proposal_Line_Item__c quotePLI : quoteLineItemSOList ){
            pliList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            if(tempPLIMap.get(quotePLI.Apttus_Proposal__Proposal__c) != null){
                pliList = tempPLIMap.get(quotePLI.Apttus_Proposal__Proposal__c);
            }
            if(quotePLI.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c != null){
                opttyId = quotePLI.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ;
            }
            pliList.add(quotePLI);
            
            tempPLIMap.put(quotePLI.Apttus_Proposal__Proposal__c, pliList);
        }    
        
        //create the display map    
        List<Apttus_Proposal__Proposal__c> quoteList = getOpportunityQuotes(opttyId);
        //ensure the optty has more than one quote for comparing
        Map<ID, Apttus_Proposal__Proposal__c> quoteIdObjMap = getQuoteMap(quoteList);
         for(Id quoteId : tempPLIMap.keySet()){
            quoteWrapperList.add(new QuoteLIWrapper(quoteIdObjMap.get(quoteId), tempPLIMap.get(quoteId )));
        }
        
        return quoteWrapperList;
    }
    
    
    private static List<QuoteProductLIWrapper> createLineDirPLI(){
        Map<String, ProductDetailsWrapper> prodDetailsMap = new Map<String, ProductDetailsWrapper>();
        Map<Integer, String> quoteNames = new Map<Integer, String>();
        addedQuoteNames = new Set<String>();
        
        Map<String, List<LineItemWrapper>> quoteLineItemSOMap = new Map<String, List<LineItemWrapper>>();
        Map<String, List<LineItemWrapper>> tempQuoteLineItemSOMap  = new Map<String, List<LineItemWrapper>>();
        List<QuoteProductLIWrapper> quoteProductLIWrapper = new List<QuoteProductLIWrapper> ();
         
        createProductDetailsMap(prodDetailsMap,tempQuoteLineItemSOMap);
           
        Integer counter = addedQuoteNames.size()-1 ;
        for(String name : addedQuoteNames){
            quoteNames.put(counter, name);
            counter--;
        }
        
        List<LineItemWrapper> liWrapperTempList;
        //logic to create the display map 
        for(String key1: tempQuoteLineItemSOMap.keySet()){
            List<LineItemWrapper> liWrapperLst = tempQuoteLineItemSOMap.get(key1);
            liWrapperTempList = new List<LineItemWrapper>();
            
            //create the list by quote 
            for(integer count=0; count<quoteNames.size(); count++){
                for(LineItemWrapper liw : liWrapperLst ){
                    if(liw.quote == quoteNames.get(count)){
                        liWrapperTempList.add(liw);
                    }
                }
                
                //add an empty line wrapper if the linewrapper has more thn count
                if(liWrapperTempList.size() < count+1){
                    liWrapperTempList.add(new LineItemWrapper());
                }
            }
            quoteProductLIWrapper.add(new QuoteProductLIWrapper(key1, liWrapperTempList, prodDetailsMap.get(key1)));
            quoteLineItemSOMap.put(key1,liWrapperTempList);
        }
        
        return quoteProductLIWrapper;
    } 
    
    private static void createProductDetailsMap(Map<String, ProductDetailsWrapper> prodDetailsMap, Map<String, List<LineItemWrapper>> tempQuoteLineItemSOMap) {
        List<LineItemWrapper> liWrapperList;
        //get the proposal line items for the added quotes
        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItemSOList = getPliLineItems(addedQuotes);
        String key = '';
        for(Apttus_Proposal__Proposal_Line_Item__c quotePLI : quoteLineItemSOList ){
            
            key = quotePLI.Apttus_Proposal__Product__r.Name +'__'+ quotePLI.APTSMD_Option_Name__c;
            if(quotePLI!= NULL && quotePLI.Apttus_QPConfig__ChargeType__c != null || quotePLI.Apttus_QPConfig__ChargeType__c != ''){
               key = key +'__'+ quotePLI.Apttus_QPConfig__ChargeType__c;
            }
            
            //create a map with the quote and related proposal line items
            liWrapperList = new List<LineItemWrapper>();
            if(tempQuoteLineItemSOMap.get(key) != null){
                key = getKey(tempQuoteLineItemSOMap, key, quotePLI, 0);
            }
            
            //create a map with all the products and the details
            if(prodDetailsMap.get(key)== null){
                ProductDetailsWrapper prodDetails = new ProductDetailsWrapper();
                prodDetails.productName = quotePLI.Apttus_Proposal__Product__r.Name;
                prodDetails.productId = quotePLI.Apttus_Proposal__Product__c;
                prodDetails.optionId = quotePLI.Apttus_QPConfig__OptionId__c;
                prodDetails.optionName = quotePLI.APTSMD_Option_Name__c;
                prodDetails.chargeType = quotePLI.Apttus_QPConfig__ChargeType__c;
                prodDetails.priceType = quotePLI.Apttus_QPConfig__PriceType__c;
                prodDetails.priceMethod = quotePLI.Apttus_QPConfig__PriceMethod__c;
                prodDetails.frequency = quotePLI.Apttus_QPConfig__Frequency__c; 
                prodDetails.proposalId = quotePLI.Apttus_Proposal__Proposal__c; 
                prodDetails.itemSequence=Integer.valueOf(quotePLI.Apttus_QPConfig__ItemSequence__c);
                prodDetails.lineNumber=Integer.valueOf(quotePLI.Apttus_QPConfig__LineNumber__c);
                
                prodDetailsMap.put(key, prodDetails);    
            }
            
            if(tempQuoteLineItemSOMap.get(key) != null){    
                liWrapperList = tempQuoteLineItemSOMap.get(key);
            }
            liWrapperList.add(new LineItemWrapper(quotePLI.Apttus_Proposal__Proposal__r.APTSMD_Proposal_ID_Name__c, quotePLI));
            tempQuoteLineItemSOMap.put(key, liWrapperList);
            addedQuoteNames.add(quotePLI.Apttus_Proposal__Proposal__r.APTSMD_Proposal_ID_Name__c);
        }
        
        
    }
    
    private static String getKey(Map<String, List<LineItemWrapper>> tempQuoteLineItemSOMap, String key, Apttus_Proposal__Proposal_Line_Item__c quotePLI, Integer count){      
        
        String newKey = count == 0 ?  key : key+'__'+ count;
        
        if(tempQuoteLineItemSOMap.get(newKey) != null){
            for(LineItemWrapper liWrapper : tempQuoteLineItemSOMap.get(newKey)){
                if(liWrapper.quote == quotePLI.Apttus_Proposal__Proposal__r.APTSMD_Proposal_ID_Name__c){
                    count++;
                    newKey = getKey(tempQuoteLineItemSOMap, key, quotePLI, count);
                    
                }
            }
        }
        return newKey;
    }
    
    //method to create the quote - pli map
    private static Map<ID, Apttus_Proposal__Proposal__c> getQuoteMap(List<Apttus_Proposal__Proposal__c> quoteList ){
        Map<ID, Apttus_Proposal__Proposal__c> quoteIdObjMap = new Map<ID, Apttus_Proposal__Proposal__c>();
            for (Apttus_Proposal__Proposal__c quote : quoteList) {
                if(primaryContactId == null){
                    primaryContactId = quote.Apttus_Proposal__Primary_Contact__c;
                }
                quoteIdObjMap.put(quote.Id, quote);
            }
       return quoteIdObjMap;     
    }
    
    public class QuoteLIWrapper{
        public Apttus_Proposal__Proposal__c quote{get;set;}
        public List<Apttus_Proposal__Proposal_Line_Item__c> pliList {get;set;}
        
        public QuoteLIWrapper(Apttus_Proposal__Proposal__c quote, List<Apttus_Proposal__Proposal_Line_Item__c> pliList){
            this.quote = quote;
            this.pliList = pliList;
        }
    }
    
    public class QuoteProductLIWrapper{
        public String key{get;set;}
        public List<LineItemWrapper> LineItemList {get;set;}
        public ProductDetailsWrapper ProductDetails {get;set;}
        
        public QuoteProductLIWrapper(String key, List<LineItemWrapper> LineItemList, ProductDetailsWrapper ProductDetails){
            this.key = key;
            this.LineItemList = LineItemList ;
            this.ProductDetails = ProductDetails ;
        }

    }
    
    public class ProductDetailsWrapper{
        public String productName {get; set;}
        public String optionName {get;set;}
        public String chargeType {get; set;}
        public String priceType {get; set;}
        public String priceMethod {get; set;}
        public String frequency {get; set;}
        public String productId {get; set;}
        public String optionId {get; set;}
        public String proposalId { get; set;}
        public Integer lineNumber{get;set;}
        public Integer itemSequence{get;set;}
        
        public ProductDetailsWrapper() {
            productName = null;
            optionName = null;
            chargeType = null;
        }
    }
    
    public class LineItemWrapper{
        public String quote {get;set;}
        public Apttus_Proposal__Proposal_Line_Item__c proposalLI {get;set;}
        
        public LineItemWrapper(String quote, Apttus_Proposal__Proposal_Line_Item__c proposalLI){
             this.quote = quote;
             this.proposalLI = proposalLI;
        }
        
        public LineItemWrapper(){
             this.quote = null;
             this.proposalLI = null;
        }
    }
    
     /**
     * Get quotes for opportunity
     * @param opportunityId
     * @return collection of proposal objects
     */
    Public static List<Apttus_Proposal__Proposal__c> getOpportunityQuotes(ID oppId) {
        List<Apttus_Proposal__Proposal__c> tempProposalList = [select id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:oppId];
        List<id> tempProposalId = new List<id>();
           String q='(';
        if(tempProposalList.size()>0){
            for(Apttus_Proposal__Proposal__c temp:tempProposalList){
                tempProposalId.add(temp.id);
            }
            List<Apttus_Proposal__Proposal_Line_Item__c> pllList = [select id,Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :tempProposalId];
            
            
         
            
            if(pllList.size()>0){
                tempProposalId=new List<id>();
                Map<id,Integer> tempMap=new Map<id,Integer>();
                for(Apttus_Proposal__Proposal_Line_Item__c temp:pllList){
                    if(tempMap.get(temp.Apttus_Proposal__Proposal__c)==null){
                        tempMap.put(temp.Apttus_Proposal__Proposal__c, 1);
                        tempProposalId.add(temp.Apttus_Proposal__Proposal__c);
                        q=q+'\''+temp.Apttus_Proposal__Proposal__c+'\',';
                    }
                }
                if(q.substring(q.length()- 1) == ',')
                    q = q.substring(0,q.length()- 1);
                    q=q+')';
            }
            else
            {
                tempProposalId=new List<id>();
            }
        }
        
        if(tempProposalId.size()>0){
        proposalList = (list<Apttus_Proposal__Proposal__c>)getListWAllFields('Apttus_Proposal__Proposal__c','ID IN '+q,0,'Apttus_Proposal__Primary_Contact__r.Name,','Name');
        
        return proposalList;}else
        return proposalList;
    } 
    
    private static List<Apttus_Proposal__Proposal_Line_Item__c> getProposalLineItems(Set<Id> addedQuotesId){
        
        
        String addedQuotesIdString = '';
       
        
        
        if(!addedQuotesId.isEmpty())
        {
            for(Id eachQuoteId : addedQuotesId)
            {
                addedQuotesIdString = addedQuotesIdString +'\''+eachQuoteId + '\',';
            }
            
        }
        if(addedQuotesIdString.substring(addedQuotesIdString.length()- 1) == ',')
        addedQuotesIdString = addedQuotesIdString.substring(0,addedQuotesIdString.length()- 1);

         return (list<Apttus_Proposal__Proposal_Line_Item__c>)getListWAllFields('Apttus_Proposal__Proposal_Line_Item__c','Apttus_Proposal__Proposal__c IN ('+addedQuotesIdString +')',0,'Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c,Apttus_Proposal__Product__r.Name,','');

    } 
    
    private static List<Apttus_Proposal__Proposal_Line_Item__c> getPliLineItems(Set<Id> addedQuotesId){
        
        String addedQuotesIdString = '';
       
        
        
        if(!addedQuotesId.isEmpty())
        {
            for(Id eachQuoteId : addedQuotesId)
            {
                addedQuotesIdString = addedQuotesIdString +'\''+eachQuoteId + '\',';
            }
            
        }
        if(addedQuotesIdString.substring(addedQuotesIdString.length()- 1) == ',')
        addedQuotesIdString = addedQuotesIdString.substring(0,addedQuotesIdString.length()- 1);
        
         return (list<Apttus_Proposal__Proposal_Line_Item__c>)getListWAllFields('Apttus_Proposal__Proposal_Line_Item__c','Apttus_Proposal__Proposal__c IN ('+addedQuotesIdString +')',0,'Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal__r.Name, Apttus_Proposal__Proposal__r.APTSMD_Proposal_ID_Name__c, Apttus_Proposal__Product__r.Name,','Apttus_Proposal__Proposal__r.Name');
    } 
    
    /**
     * Gets the opportunity sobject for the given opportunity id
     * @param opptyId the opportunity id to retrieve
     * @return the opportunity sobject 
     */
    public static Opportunity getOpportunitySO(ID opptyId) {
        try {
            // get the opportunity
            List<Opportunity> opportunities = [select Id, Name, Type, StageName, OwnerId, LeadSource, Description,
                                                    CloseDate, Amount, AccountId
                                               from Opportunity
                                               where Id = :opptyId limit 1];
            return (!opportunities.isEmpty() ? opportunities[0] : null);
        }
        catch(Exception ex) {
            return null;
        }
    }
    
    /**
     * Create Quote/Proposal from given Opportunity with 'Quote Compare' record type.
     * @param opptySO
     * @param quoteCompareId
     * @param primaryContactId
     */ 
    public static ID createQuote(Opportunity opptySO, String quoteName, ID primaryContId) {
        
        // STEP I - create a new proposal sobject
        Apttus_Proposal__Proposal__c quoteSO = new Apttus_Proposal__Proposal__c();
        
        // record type id
        quoteSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
        quoteSO.Apttus_Proposal__Account__c = opptySO.AccountId;
        quoteSO.Apttus_Proposal__Description__c = opptySO.Description;
        quoteSO.Apttus_Proposal__Primary__c = false;
        quoteSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
        quoteSO.OwnerId = opptySO.OwnerId;
        quoteSO.Apttus_Proposal__Primary_Contact__c = primaryContId;
        quoteSO.Apttus_Proposal__Proposal_Name__c = quoteName;
        
        //save
        insert quoteSO;
                 
        return quoteSO.Id;
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        return fieldSetObj.getFields(); 
    }
    
    public Static List<sObject> getListWAllFields(string objectName, string whereClaus, integer limitNumber,string extraRelationalFields,string orderByField) {
        // Initialize setup variables
        //String objectName = 'Contact';  // modify as needed
        String query = ' SELECT ';
        Map<String, Schema.SObjectField> objectFields = getAllMetaDataFields(objectName);

        query+=extraRelationalFields;

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
    
        query = query.subString(0,query.Length()-2);
    
        // Add FROM statement
        query += ' FROM ' + objectName;
    
        // Add on a WHERE statement as needed
        if (String.isNotBlank(whereClaus)) {
          query += ' WHERE ' + whereClaus;
        }
        // Add on a Order by statement as needed
        if (String.isNotBlank(orderByField)) {
          query += ' order by ' + orderByField;
        }
        // Add on a LIMIT statement as needed
        if (limitNumber>0) {
          query += ' LIMIT ' + String.valueOf(limitNumber);
        }
        
        try {
          return database.query(query);
        } catch (QueryException qe) {
            return null;
        }
    }
    
    public Static Map<String, Schema.SObjectField> getAllMetaDataFields(string objName)
    {
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    }
    
    Global class fieldWrapper{
        public string fieldAPIName{get;set;}
        public string fieldLabel{get;set;}
        public string getType{get;set;}
        
        public fieldWrapper(string fieldAPIName,string fieldLabel,string getType){
            this.fieldLabel = fieldLabel;
            this.fieldAPIName = fieldAPIName;
            this.getType = getType;
        }
    }
}