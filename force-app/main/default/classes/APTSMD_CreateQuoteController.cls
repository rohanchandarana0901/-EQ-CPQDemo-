/*
    APTSMD_CreateQuoteController : This controller is used for create quote from opportunity
    Last Edited By: Jigar Naik on 06/18/2019
*/
public class APTSMD_CreateQuoteController {
    private ID opptyId = null;
    private ID proposalId = null;
    private ID recordTypeId = null;
    private Boolean hasErrors = false;
    private String flow = null;
    
    /**
       * Class Constructor specifying initial values
       * @param stdController the standard controller
    **/
    public APTSMD_CreateQuoteController(ApexPages.StandardController stdController) {      
        //get the opportunity id
        this.opptyId = stdController.getId();
    }
    
    /**
       * Callback invoked when the page is loaded
       * @return the page reference 
    **/
    public PageReference createAndRedirect() {
      
        PageReference pageRef = null;
        Savepoint sp = null;
        String action = ApexPages.currentPage().getParameters().get('action');
      
        try {
            // get the opportunity sobject
            Opportunity opptySO = APTSMD_CPQHelper.getOpportunitySO(opptyId);
            
            if(opptySO.APTSMD_Flow__c == null){
                 flow = 'tier1angular';
             }else {
                 flow = opptySO.APTSMD_Flow__c;
             }
            
            //update the oppty
            opptySO.APTSMD_Flow__c = flow;
            update opptySO;
            
            // create the quote/proposal
            this.proposalId = APTSMD_CPQHelper.createQuoteOrProposal(opptySO);
            
            if(action == 'QuoteInExcel'){
                return openXAEApp(opptySO.Id, proposalId);
            }else if(action == 'RLP'){
                String redirectToRLPCart = '/apex/Conga_CCPQ__RLPCart?boid=' + this.proposalId + '&flow=system&idp=Salesforce&skipDealGuidance=false&skipApprovalCheck=false&useDealOptimizer=true';
            	return new PageReference(redirectToRLPCart);
            }else if(opptySO.APTSMD_Default_Product__c != null){
                String directConfigLaunch = '/apex/Apttus_Config2__Cart?useAdvancedApproval=true&useDealOptimizer=true#!/flows/' + opptySO.APTSMD_Flow__c;
                directConfigLaunch += '/businessObjects/' + this.proposalId;
                directConfigLaunch += '/products/' + opptySO.APTSMD_Default_Product__c + '/configure';
                
                return new PageReference(directConfigLaunch);
            }

            // Call the standard detail page
            //fail safe for bps parnter community generate doc button not working
            //modified pageRef By Ankush and Sharanya
            pageRef = Page.Apttus_Config2__Cart;
            
            pageRef.getParameters().put('businessObjectId', proposalId);
            pageRef.getParameters().put('method', 'csrFlow');
            //add the flow to direct to the correct layouts
            pageRef.getParameters().put('asyncFinalize','true');//added by vivek to implement async finalize Date: 16 dec 2021
            pageRef.getParameters().put('flow',flow);
            pageRef.getParameters().put('useAdvancedApproval', 'true');
            pageRef.getParameters().put('useDealOptimizer', 'true');
            pageRef.getParameters().put('useAdvancedCurrency', 'true');

            String retPage = ApexPages.currentPage().getParameters().get('retPage');
            if (retPage != null) {
                pageRef.getParameters().put('retPage', retPage);
            }
        } catch (Exception ex) {
            //report error
            ApexPages.addmessages(ex);  
            //indicate error
            hasErrors = true;
            //if a savepoint was set, rollback updates
            if (sp != null) {
              Database.rollback(sp);
            }
            return null;
        }
        return pageRef;
    }
    
    /**
    * Checks if there were errors in loading the page
    * @return <code>true</code> if there were errors, <code>false</code> otherwise
    */
    public Boolean getHasErrors() {
        return hasErrors;
    }
  
    /**
    * Performs the cancel action
    * @return the next page reference 
    */
    public PageReference doCancel() {
        //navigate to the opportunity 
        return new PageReference('/' + opptyId);
    }
    
    /**
    * Opens "Quote In Excel" XAE App
    * @returns the page reference 
    */
    public PageReference openXAEApp(String opportunityId, String proposalId) {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__c,Apttus_QPConfig__PriceListId__c
                        FROM Apttus_Proposal__Proposal__c WHERE Id = :proposalId];
            
        Apttus_Config2__BillingPreference__c billingPreference = [SELECT Id FROM Apttus_Config2__BillingPreference__c WHERE Name = 'Org Wide Default'];
            
        //create configuration
        Apttus_Config2__ProductConfiguration__c configuration = new Apttus_Config2__ProductConfiguration__c();
        configuration.Name = proposal.Apttus_Proposal__Proposal_Name__c;
        configuration.Apttus_QPConfig__Proposald__c = proposal.Id;
        configuration.Apttus_Config2__BusinessObjectId__c = proposal.Id;
        configuration.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        configuration.Apttus_Config2__AccountId__c = proposal.Apttus_Proposal__Account__c;
        configuration.Apttus_Config2__PriceListId__c = proposal.Apttus_QPConfig__PriceListId__c;
        configuration.Apttus_Config2__ExpectedStartDate__c = date.today().addDays(5);
        configuration.Apttus_Config2__ExpectedEndDate__c = date.today().addYears(1);
        configuration.Apttus_Config2__EffectivePriceListId__c = proposal.Apttus_QPConfig__PriceListId__c;
        configuration.Apttus_Config2__IsTransient__c = true;
        configuration.Apttus_Config2__BillingPreferenceId__c = billingPreference.Id;
        configuration.Apttus_Config2__Status__c = 'Saved';
        insert configuration;
        
        configuration = [SELECT Id, Name, Apttus_Config2__PriceListId__c, 
                        Apttus_Config2__ExpectedStartDate__c, Apttus_Config2__ExpectedEndDate__c  
                        FROM Apttus_Config2__ProductConfiguration__c 
                        WHERE Id = :configuration.Id];
        
        //create temp object
        Apttus_Config2__TempObject__c tempObject = new Apttus_Config2__TempObject__c();
        tempObject.Apttus_Config2__ConfigurationId__c = configuration.Id;
        
        //XML data 
        String strProposal = proposal.Apttus_Proposal__Proposal_Name__c;
        String strConfiguration = configuration.Name;
          
        if(strConfiguration != null && strConfiguration.contains('&')) {
            strConfiguration = strConfiguration.replace('&','&amp;');
        }
        
        if(strProposal != null && strProposal.contains('&')) {
            strProposal = strProposal.replace('&','&amp;');
        }
            
        //string to hold proper XML value
        String strData = '<?xml version="1.0" encoding="UTF-8"?><ConfigRequest><BusinessObjectId>'
                        + proposal.Id + '</BusinessObjectId><BusinessObjectType>Proposal</BusinessObjectType><BusinessObjectTitle>'
                        + strProposal + '</BusinessObjectTitle><PriceListId>' 
                        + configuration.Apttus_Config2__PriceListId__c+'</PriceListId><AccountId>'
                        + proposal.Apttus_Proposal__Account__c 
                        + '</AccountId><FinalizePage>Apttus_QPConfig__ProposalFinalize</FinalizePage><FinalizeClass>Apttus_QPConfig.ProposalActionCallback</FinalizeClass><CallerPackageNS>Apttus_QPConfig</CallerPackageNS>'
                        + '<UseAdvancedApproval>true</UseAdvancedApproval><UseDealOptimizer>true</UseDealOptimizer>'
                        + '<Fields><Field><Name>Name</Name><Value>'
                        + strConfiguration + '</Value></Field><Field><Name>Apttus_Config2__EffectiveDate__c</Name><Value>' 
                        + system.now() + '</Value></Field><Field><Name>Apttus_QPConfig__Proposald__c</Name><Value>'
                        + proposal.Id + '</Value></Field><Field><Name>Apttus_Config2__ExpectedStartDate__c</Name><Value>'
                        + configuration.Apttus_Config2__ExpectedStartDate__c 
                        + '</Value></Field><Field><Name>Apttus_Config2__ExpectedEndDate__c</Name><Value>'
                        + configuration.Apttus_Config2__ExpectedEndDate__c + '</Value></Field>'
                        + '<Field><Name>Apttus_Config2__EffectivePriceListId__c</Name><Value>'+configuration.Apttus_Config2__PriceListId__c+'</Value></Field>'
                        + '<Field><Name>Apttus_Config2__BillingPreferenceId__c</Name><Value>'+billingPreference.Id+'</Value></Field>'
                        + '</Fields>'
                        + '<Params><Param><Name>flow</Name><Value>'+flow +'</Value></Param><Param><Name>id</Name><Value>'+ proposal.Id +'</Value></Param>'
                        + '<Param><Name>method</Name><Value>csrFlow</Value></Param><Param><Name>useAdvancedApproval</Name><Value>true</Value></Param>'
                        + '<Param><Name>useDealOptimizer</Name><Value>true</Value></Param></Params><'
                        + 'IsDynamicProductSearchFilter>true</IsDynamicProductSearchFilter><IsDynamicAssetSearchFilter>true</IsDynamicAssetSearchFilter></ConfigRequest>'; 

        tempObject.Apttus_Config2__Data__c = strData;            
        insert tempObject;
                
        return new PageReference('/apex/APTSMD_OpenQuoteInExcelApp?id='+configuration.Id+'&oppId='+opportunityId);
    }
}