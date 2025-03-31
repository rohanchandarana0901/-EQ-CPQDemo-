public class APTSMD_FinalizeConfigurationController {
    private String configurationId;
    private String configRequestId;
    private String flow;
    private String proposalId;
    public Boolean approvalRequired {get; set;}
    
    public APTSMD_FinalizeConfigurationController() {      
        configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        configurationId = ApexPages.currentPage().getParameters().get('id');
        flow = ApexPages.currentPage().getParameters().get('flow');
        approvalRequired = false;
    }
    
    public PageReference finalizeConfiguration() {
        Apttus_Config2__ProductConfiguration__c prodConfig = [Select Id, Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c From Apttus_Config2__ProductConfiguration__c Where Id = :configurationId];
        List<Apttus_Config2__ProductConfiguration__c> oldProdConfigList = [Select Id, Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c From Apttus_Config2__ProductConfiguration__c Where Id != :configurationId And Apttus_QPConfig__Proposald__c = :prodConfig.Apttus_QPConfig__Proposald__c And Apttus_Config2__Status__c = 'Finalized'];
        
        for(Apttus_Config2__ProductConfiguration__c oldProdConfig : oldProdConfigList){
            oldProdConfig.Apttus_Config2__Status__c = 'Superseded';
        }
        
        if(oldProdConfigList != null & !oldProdConfigList.isEmpty()){
            update oldProdConfigList;
        }
        
        if(prodConfig.Apttus_Config2__Status__c == 'Approval Required'){
            approvalRequired = true;
            proposalId = prodConfig.Apttus_QPConfig__Proposald__c;
            return null;
        }
      
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO request = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        request.CartId = prodConfig.Id;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO response = Apttus_CPQApi.CPQWebService.finalizeCart(request);

        PageReference pageRef = new PageReference('/apex/Apttus_QPConfig__ProposalAccept');
        pageRef.getParameters().put('id', prodConfig.Apttus_QPConfig__Proposald__c);
        
        return pageRef;
    }
    
    public PageReference closeWindow() {
        return new PageReference('/' + proposalId);
    }
  
}