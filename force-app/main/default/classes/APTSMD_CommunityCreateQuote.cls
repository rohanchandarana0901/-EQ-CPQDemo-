public class APTSMD_CommunityCreateQuote {
    private ID opptyId = null;
    private String flow = null;
    
    public APTSMD_CommunityCreateQuote(ApexPages.standardController controller){
        this.opptyId = controller.getId();
    }
   
    public PageReference createQuoteAndRedirect(){
        PageReference pageRef = null;
        // Savepoint sp = null;
      
        try {
            System.debug('##### Done');
            // get the opportunity sobject
            Opportunity opptySO = APTSMD_CPQHelper.getOpportunitySO(opptyId);
            APTSMD_Apttus_PreSales_Config_Settings2__c objPreSalesConfig = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
            if(objPreSalesConfig.APTSMD_Community_Flow__c == null){
                 flow = 'tier1community';
             }else {
                 flow = objPreSalesConfig.APTSMD_Community_Flow__c;
             }
            String proposalId = APTSMD_CPQHelper.createQuoteOrProposal(opptySO); 
            System.debug('##### Done1');
            system.debug('proposalId:' + proposalId);
            Apttus_Proposal__Proposal__c proposal = [SELECT Id, 
                                                            Apttus_QPConfig__PriceListId__r.Name,
                                                            Apttus_Proposal__Proposal_Name__c, 
                                                            Apttus_Proposal__Account__c,
                                                            Apttus_QPConfig__PriceListId__c 
                                                     FROM Apttus_Proposal__Proposal__c 
                                                     WHERE Id = :proposalId];
            
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteId = proposal.Id;
            Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
            ID cartId = response.CartId;
            
            System.debug('##### Done1 cartId: '+cartId); 
            String paramsToBeReplaced = '<Param><Name>initialStatus</Name><Value>New</Value></Param>';
            String paramsToReplace = '<Param><Name>flow</Name><Value>'+flow+'</Value></Param><Param><Name>id</Name><Value>'+proposal.Id+'</Value></Param><Param><Name>method</Name><Value>csrFlow</Value></Param>';
            paramsToReplace += '<Param><Name>useAdvancedApproval</Name><Value>true</Value></Param><Param><Name>useDealOptimizer</Name><Value>true</Value></Param>';
            
            Apttus_Config2__TempObject__c tempObject = [SELECT Id, 
                                                               Apttus_Config2__Data__c 
                                                        FROM Apttus_Config2__TempObject__c 
                                                        WHERE Apttus_Config2__ConfigurationId__c =: cartId];
            tempObject.Apttus_Config2__Data__c = tempObject.Apttus_Config2__Data__c.replace(paramsToBeReplaced,paramsToReplace);
             
            String param2ToBeReplaced = '<IsDynamicProductSearchFilter>true</IsDynamicProductSearchFilter>';
            String param2ToReplaced = '<IsDynamicProductSearchFilter>true</IsDynamicProductSearchFilter><IsDynamicAssetSearchFilter>true</IsDynamicAssetSearchFilter>';
            tempObject.Apttus_Config2__Data__c = tempObject.Apttus_Config2__Data__c.replace(param2ToBeReplaced,param2ToReplaced);
            update tempObject;
            
            String domainUrl = Network.getLoginUrl([SELECT Id FROM Network WHERE Name =: objPreSalesConfig.APTSMD_Community_Name__c].id);
            String pageUrl = '';
            if(domainUrl != null && domainUrl.contains('.com')){
                pageUrl = domainUrl.subString(0, domainUrl.indexOf('login'));
                system.debug('pageUrl:' + pageUrl);
                pageRef =  new PageReference(pageUrl+'s/sfdcpage/%2Fapex%2FApttus_Config2__Cart%3FcartStatus%3DNew%26configRequestId%3D'+tempObject.Id + '%26flow%3D'+ flow +'%26id%3D'+cartId+'%26p1?isdtp=p1');
            }   
            
            system.debug('----- Community Page Reference :'+pageRef);
            pageRef.setredirect(false);
                
        } catch (Exception ex) {
            
        }
       //PageReference pref = new PageReference('/');
       return pageRef;
   }
}