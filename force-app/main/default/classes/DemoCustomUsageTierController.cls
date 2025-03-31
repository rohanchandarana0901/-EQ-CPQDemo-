public with sharing class DemoCustomUsageTierController {

    private String configurationId;
    private String configRequestId;
    private String businessObjectId;
    private String flow;
    private String proposalId;
    public Boolean approvalRequired {get; set;}
    public String previousURL {get; set;}

    public DemoCustomUsageTierController() {
        configRequestId = ApexPages.currentPage().getParameters().get('configRequestId');
        configurationId = ApexPages.currentPage().getParameters().get('id');
        businessObjectId = ApexPages.currentPage().getParameters().get('businessObjectId');
        flow = ApexPages.currentPage().getParameters().get('flow');
        approvalRequired = false;
        previousURL = ApexPages.CurrentPage().getHeaders().get('Referer');
        System.debug('@@@ configurationId: ' + configurationId);
        previousURL = previousURL + 'apex/Apttus_Config2__Cart' + '?businessObjectId=' + businessObjectId + '&flow=' + flow + '&useDealOptimizer=true&useAdvancedApproval=true';
        System.debug('@@@ previousURL: ' + previousURL);
        System.debug('@@@ header: ' + ApexPages.CurrentPage().getHeaders());
    }

    public PageReference createUsageTiers() {
        System.debug('@@@ inside createUsageTiers');
        PageReference pageRef = Page.Apttus_Config2__Cart;
        // '?businessObjectId=' + businessObjectId + '&flow=' + flow + '&useDealOptimizer=true&useAdvancedApproval=true');
        pageRef.getParameters().put('businessObjectId', businessObjectId);
        //pageRef.getParameters().put('configRequestId', configRequestId);
        pageRef.getParameters().put('flow',flow);
        //pageRef.getParameters().put('autoFinalize', 'true');
        pageRef.getParameters().put('useAdvancedApproval', 'true');
        pageRef.getParameters().put('useDealOptimizer', 'true');

        
        //pageReferenceSO.getParameters().put('id', 'a1XHs00000Ud8gz');
        //pageReferenceSO.getParameters().put('flow', flow);
        

        createUsageTier(configurationId);

        return pageRef;
    }

    public void createUsageTier(Id configurationId) {
        try{

            Set<String> setInclusiveUptoAttributes = new Set<String>{'Inclusive Upto', 'All Exclusive'};
            List<String> attributeFields = new List<String>(Apttus_Config2__ProductAttributeValue__c.SObjectType.getDescribe().fields.getMap().keySet());
            String attributeSOQL = 'SELECT ' + String.join(attributeFields, ',') + ' FROM  Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c = :configurationId AND C2C_InclusionType__c IN: setInclusiveUptoAttributes';
            Map<Id, Apttus_Config2__ProductAttributeValue__c> mpAttributeValues = new Map<Id, Apttus_Config2__ProductAttributeValue__c>((List<Apttus_Config2__ProductAttributeValue__c>)Database.query(attributeSOQL));
            System.debug('@@@ mpAttributeValues ' + mpAttributeValues);

            Set<Id> attributeValueIds = new Set<Id>(mpAttributeValues.keySet());
            List<String> lineItemFields = new List<String>(Apttus_Config2__LineItem__c.SObjectType.getDescribe().fields.getMap().keySet());
            String lineItemSOQL = 'SELECT ' + String.join(lineItemFields, ',') + ', Apttus_Config2__OptionId__r.ProductCode FROM  Apttus_Config2__LineItem__c WHERE Apttus_Config2__AttributeValueId__c IN: attributeValueIds';
            Map<Id, Apttus_Config2__LineItem__c> mpLineItems = new Map<Id, Apttus_Config2__LineItem__c>((List<Apttus_Config2__LineItem__c>)Database.query(lineItemSOQL));
            
            for(Apttus_Config2__ProductAttributeValue__c attributeValue : mpAttributeValues.values()){
                Apttus_Config2__LineItem__c lineItem = mpLineItems.get(attributeValue.Apttus_Config2__LineItemId__c);
                if(lineItem.Apttus_Config2__OptionId__r.ProductCode == 'UKSS REG SR SR_REGISTRAR-TRANSFERS'){
                    if(attributeValue.C2C_InclusionType__c == 'Inclusive Upto'){
                        doCreateUsageTier(lineItem.Id, attributeValue.C2C_InclusionType__c, attributeValue.Excess_Transfer_Rate__c, attributeValue.Included_Transfers__c);
                    }else{ 
                        doCreateUsageTier(lineItem.Id, attributeValue.C2C_InclusionType__c, attributeValue.Transfer_Charge__c, 0);
                    }
                }
                else if(lineItem.Apttus_Config2__OptionId__r.ProductCode == 'UKSS REG SR SR_REGISTRAR-REG MAINT-Demo'){
                    if(attributeValue.C2C_InclusionType__c == 'Inclusive Upto'){
                        doCreateUsageTier(lineItem.Id, attributeValue.C2C_InclusionType__c, attributeValue.Excess_Account_Charges__c, attributeValue.Accounts_Included__c);
                    }else{
                        doCreateUsageTier(lineItem.Id, attributeValue.C2C_InclusionType__c, attributeValue.Account_Charge__c, 0);
                    }                  
                }
            }
        } catch(Exception ex){
           System.debug('@@@ exception: ' + ex);
        }
    }

    public void doCreateUsageTier(Id lineItemId, String inclusionType, Decimal perUnitCharge, Decimal includedQuantity){
        System.debug('@@@ inside doCreateUsageTier ' + lineItemId + ' ' + inclusionType + ' ' + perUnitCharge + ' ' + includedQuantity);
        includedQuantity = includedQuantity ?? 0;
        perUnitCharge = perUnitCharge ?? 0;
        
        if(inclusionType == 'Inclusive Upto'){

            List<String> fields = new List<String>(Apttus_Config2__UsagePriceTier__c.SObjectType.getDescribe().fields.getMap().keySet());
            String SOQL = 'SELECT ' + String.join(fields, ',') + ', Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c from Apttus_Config2__UsagePriceTier__c  where Apttus_Config2__LineItemId__c = :lineItemId';
            List<Apttus_Config2__UsagePriceTier__c> lstExistingUsageTiers = Database.query(SOQL);

            if(!lstExistingUsageTiers.isEmpty()){
                Id priceMatrixId = lstExistingUsageTiers[0].Apttus_Config2__PriceMatrixId__c;
                delete lstExistingUsageTiers;

                List<Apttus_Config2__UsagePriceTier__c> lstUsageTiersToInsert = new List<Apttus_Config2__UsagePriceTier__c>();

                Apttus_Config2__UsagePriceTier__c tier1 = new Apttus_Config2__UsagePriceTier__c();
                tier1.Apttus_Config2__AdjustmentType__c = 'List Price Override';
                tier1.Apttus_Config2__AdjustmentAmount__c = 0;
                tier1.Apttus_Config2__Dimension1Value__c = String.valueOf(includedQuantity);
                tier1.Apttus_Config2__LineItemId__c = lineItemId;
                tier1.Apttus_Config2__PriceMatrixId__c = priceMatrixId;
                tier1.Apttus_Config2__PriceOverride__c = 0;
                tier1.Apttus_Config2__Sequence__c = 1;
                tier1.Apttus_Config2__TierEndValue__c = includedQuantity;
                tier1.Apttus_Config2__TierStartValue__c = 0;
                tier1.Apttus_Config2__UsageRate__c = 0;
                lstUsageTiersToInsert.add(tier1);

                Apttus_Config2__UsagePriceTier__c tier2 = new Apttus_Config2__UsagePriceTier__c();
                tier2.Apttus_Config2__AdjustmentType__c = 'List Price Override';
                tier2.Apttus_Config2__AdjustmentAmount__c = perUnitCharge;
                tier2.Apttus_Config2__Dimension1Value__c = '999999';
                tier2.Apttus_Config2__LineItemId__c = lineItemId;
                tier2.Apttus_Config2__PriceMatrixId__c = priceMatrixId;
                tier2.Apttus_Config2__PriceOverride__c = perUnitCharge;
                tier2.Apttus_Config2__Sequence__c = 2;
                tier2.Apttus_Config2__TierEndValue__c = 999999;
                tier2.Apttus_Config2__TierStartValue__c = includedQuantity;
                tier2.Apttus_Config2__UsageRate__c = perUnitCharge;
                lstUsageTiersToInsert.add(tier2);

                insert lstUsageTiersToInsert;
            } 
        
        } else if(inclusionType == 'All Exclusive'){
            List<String> fields = new List<String>(Apttus_Config2__UsagePriceTier__c.SObjectType.getDescribe().fields.getMap().keySet());
            String SOQL = 'SELECT ' + String.join(fields, ',') + ', Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c from Apttus_Config2__UsagePriceTier__c  where Apttus_Config2__LineItemId__c = :lineItemId';
            List<Apttus_Config2__UsagePriceTier__c> lstExistingUsageTiers = Database.query(SOQL);

            Id priceMatrixId = lstExistingUsageTiers[0].Apttus_Config2__PriceMatrixId__c;
            delete lstExistingUsageTiers;

            List<Apttus_Config2__UsagePriceTier__c> lstUsageTiersToInsert = new List<Apttus_Config2__UsagePriceTier__c>();

            Apttus_Config2__UsagePriceTier__c tier2 = new Apttus_Config2__UsagePriceTier__c();
            tier2.Apttus_Config2__AdjustmentType__c = 'List Price Override';
            tier2.Apttus_Config2__AdjustmentAmount__c = perUnitCharge;
            tier2.Apttus_Config2__Dimension1Value__c = '0';
            tier2.Apttus_Config2__LineItemId__c = lineItemId;
            tier2.Apttus_Config2__PriceMatrixId__c = priceMatrixId;
            tier2.Apttus_Config2__PriceOverride__c = perUnitCharge;
            tier2.Apttus_Config2__Sequence__c = 1;
            tier2.Apttus_Config2__TierEndValue__c = 999999;
            tier2.Apttus_Config2__TierStartValue__c = includedQuantity;
            tier2.Apttus_Config2__UsageRate__c = perUnitCharge;
            lstUsageTiersToInsert.add(tier2);
            insert tier2;
        }
    }
}