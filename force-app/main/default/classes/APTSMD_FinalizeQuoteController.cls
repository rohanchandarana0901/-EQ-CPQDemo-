//This class is used to finalize the Quote in Lightning Community
global class APTSMD_FinalizeQuoteController{
    
    public String configId {get;set;}
    public String finalizeBtn {get;set;}
    
    public APTSMD_FinalizeQuoteController(ApexPages.standardController controller){
        system.debug('Configuration ID'+controller.getId());
        configId = controller.getId();
        finalizeBtn = Apexpages.currentpage().getparameters().get('finalizeBtn');
        system.debug('finalizeBtn : '+finalizeBtn);
        
    }
    
    @RemoteAction
    global static String init(String configId, String finalizeClicked){
        //system.debug('INIT method is called... '+configId);
        //system.debug('Finalize Clicked is called... '+finalizeClicked);
        Apttus_Config2__ProductConfiguration__c objConfig = [SELECT Id, 
                                                                    Apttus_QPConfig__Proposald__c,
                                                                    Apttus_Config2__Status__c, 
                                                                    Apttus_Config2__VersionNumber__c, 
                                                                    Apttus_Config2__LocationId__c, 
                                                                    Apttus_Config2__BillToAccountId__c, 
                                                                    Apttus_Config2__AccountId__c, 
                                                                    Apttus_Config2__BillingPreferenceId__c 
                                                             FROM Apttus_Config2__ProductConfiguration__c 
                                                             WHERE id =: configId];
        Boolean isSuccess = false;
        Boolean finalBtn = (Boolean)JSON.deserialize(finalizeClicked, Boolean.class);
        //system.debug('finalBtnnnnnn : '+finalBtn);
        Apttus_Config2__BillingPreference__c billingPreference = [SELECT Id FROM Apttus_Config2__BillingPreference__c WHERE Name = 'Org Wide Default'];
        APTSMD_Apttus_PreSales_Config_Settings2__c objPreSalesConfig = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        if(finalBtn){
            Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
            // add request parameters
            request.CartId = configId;
    
            // finalize the cart
            Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
            isSuccess = response.isSuccess;
        }else{
            objConfig.Apttus_Config2__Status__c = 'Saved';
            objConfig.Apttus_Config2__EffectiveDate__c = System.now();
            objConfig.Apttus_Config2__BillToAccountId__c = objConfig.Apttus_Config2__AccountId__c;
            //objConfig.Apttus_Config2__LocationId__c = 'a0C0Y000000Qq5E';
            objConfig.Apttus_Config2__BillingPreferenceId__c = billingPreference.Id;
            if(objConfig.Apttus_Config2__VersionNumber__c != null){
                objConfig.Apttus_Config2__VersionNumber__c += 1;
            }else{
                objConfig.Apttus_Config2__VersionNumber__c = 1;
            }
            update objConfig;
            system.debug('Configuration Updated :'+objConfig);
            
            Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
            boolean IsPricePending = true;
            objUpdatePriceRequestDO.CartId = configId;
            while(IsPricePending) {
                Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
                IsPricePending = result.IsPricePending;      
            }
        }
        system.debug('Is Success :'+isSuccess);
        if(isSuccess || objConfig.Apttus_Config2__Status__c.equalsIgnoreCase('Saved')){
            // String communityUrl = Url.getSalesforceBaseUrl().toExternalForm();
            String domainUrl = Network.getLoginUrl([SELECT Id FROM Network WHERE Name =: objPreSalesConfig.APTSMD_Community_Name__c].id);
            String pageUrl = '';
            if(domainUrl != null && domainUrl.contains('.com')){
                pageUrl = domainUrl.subString(0, domainUrl.indexOf('login'));
                system.debug('pageUrl:' + pageUrl);
                //pageRef =  new PageReference(pageUrl+'/'+ objConfig.Apttus_QPConfig__Proposald__c);
                return pageUrl + objConfig.Apttus_QPConfig__Proposald__c;
            }
            return 'false';
             
        }else{
            return 'false';
        }
        
    }
    
}