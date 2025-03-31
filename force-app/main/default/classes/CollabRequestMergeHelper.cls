public class CollabRequestMergeHelper {

    @InvocableMethod(label='MergeUsageTier')

    public static void mergeUsageTier(List<Id> lstCollabRequestId) {

        try{
            Id collabRequestId = lstCollabRequestId[0];
            Id collabConfigId = [select id from Apttus_Config2__ProductConfiguration__c where Apttus_Config2__BusinessObjectId__c = :collabRequestId]?.id;
            Id parentConfigId = [select Apttus_Config2__ParentConfigurationId__c from Apttus_Config2__CollaborationRequest__c where Id = :collabRequestId]?.Apttus_Config2__ParentConfigurationId__c;
            
            System.debug('@@@ collabConfigId ' + collabConfigId);
            System.debug('@@@ parentConfigId ' + parentConfigId);
            
            List<String> fields = new List<String>(Apttus_Config2__UsagePriceTier__c.SObjectType.getDescribe().fields.getMap().keySet());
            String SOQL = 'SELECT ' + String.join(fields, ',') + ', Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c from Apttus_Config2__UsagePriceTier__c  where Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c = :collabConfigId';
            List<Apttus_Config2__UsagePriceTier__c> lstCollabUsagePriceTier = Database.query(SOQL);
            /*List<Apttus_Config2__UsagePriceTier__c> lstCollabUsagePriceTier = [select id, Name , Apttus_Config2__UsageRate__c , Apttus_Config2__Sequence__c ,
              Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c from Apttus_Config2__UsagePriceTier__c 
              where Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c = :collabConfigId];*/
             
             System.debug('@@@ lstCollabUsagePriceTier ' + lstCollabUsagePriceTier);
             
           Map<Id, Id> productIdToLineItemId = new Map<Id, Id>();
           List<Apttus_Config2__UsagePriceTier__c> lstParentUsagePriceTier = [select id, Apttus_Config2__LineItemId__c, Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c from Apttus_Config2__UsagePriceTier__c 
              where Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c = :parentConfigId]; 
           for(Apttus_Config2__UsagePriceTier__c upt: lstParentUsagePriceTier){
               productIdToLineItemId.put(upt.Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c, upt.Apttus_Config2__LineItemId__c);
           }
           delete lstParentUsagePriceTier;
           System.debug('@@@ lstParentUsagePriceTier ' + lstParentUsagePriceTier);
           
           List<Apttus_Config2__UsagePriceTier__c> lstUsageTierToInsert = new List<Apttus_Config2__UsagePriceTier__c>();
           for(Apttus_Config2__UsagePriceTier__c usageTier: lstCollabUsagePriceTier){
               Id productId = usageTier.Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__c;
               if(productIdToLineItemId.containsKey(productId)){
                   Id targetLineItemId = productIdToLineItemId.get(productId);
                   Apttus_Config2__UsagePriceTier__c clonedTier = usageTier.clone(false, true, false, false);
                   clonedTier.Apttus_Config2__LineItemId__c = targetLineItemId;
                   lstUsageTierToInsert.add(clonedTier);
               }
           }
           System.debug('@@@ lstUsageTierToInsert ' + lstUsageTierToInsert);
           if(!lstUsageTierToInsert.isEmpty()) insert lstUsageTierToInsert;
        } catch(Exception ex){
           System.debug('@@@ exception ' + ex);
        }
    }
}