//added by vp on 23rd nov 2021 - set composer lightning collection
public with sharing class APTSMD_LightningComposerCollectionCtrl {
    public APTSMD_LightningComposerCollectionCtrl() {
    }
    //ADDED BY VIVEK TO UPDATE LIGHTNING COMPOSER COLLECTION AUTOMATICALLY; DT: 23 NOV 2021
    
    public PageReference updateComposerCollection(){
        try{
            List<APXTConga4__Conga_Collection_Solution__c> collectionList = [Select Id, Name, APXTConga4__Conga_Collection__c, 
                                                                        APXTConga4__Conga_Solution__r.APXTConga4__Master_Object_Type__c 
                                                                        from APXTConga4__Conga_Collection_Solution__c];
            System.debug('@@updateComposerCollection().collectionList='+collectionList);
            Map<String, String> collectionNamePageMap = new Map<String, String>();

            for(APXTConga4__Conga_Collection_Solution__c collection : collectionList){
                collectionNamePageMap.put(collection.APXTConga4__Conga_Solution__r.APXTConga4__Master_Object_Type__c, collection.APXTConga4__Conga_Collection__c);
            }

            List<String> fullNames = new List<String>{'Account_Record_Page', 'Opportunity_Record_Page', 'Quote_Proposal_Record_Page3'};
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();

            String metadataType = 'FlexiPage';
            MetadataService.IReadResult readResult = new MetadataService.ReadFlexiPageResult();
            readResult = service.readMetadata(metadataType,fullNames);
            List<MetadataService.Metadata> lightningPageList = readResult.getRecords();
            System.debug('@@updateComposerCollection().lightningPageList='+lightningPageList);
            Boolean flagForChange = false;
            for(MetadataService.Metadata lightningPage : lightningPageList){
                MetadataService.FlexiPage flexiPage = (MetadataService.FlexiPage) lightningPage;
                for(MetadataService.FlexiPageRegion pageRegion : flexiPage.flexiPageRegions){
                    for(MetadataService.ComponentInstance compInstance : pageRegion.componentInstances){
                        if(compInstance.componentInstanceProperties == null){
                            continue;
                        }
                        for(MetadataService.ComponentInstanceProperty compInstanceProperty : compInstance.componentInstanceProperties){
                            if(compInstanceProperty.value !=null && compInstanceProperty.value.startsWith('a9q')){
                                compInstanceProperty.value = collectionNamePageMap.get(flexiPage.sobjectType);
                            }
                        }
                    }
                }    
            }
            System.debug('@@updateComposerCollection().lightningPageList='+lightningPageList);
            MetadataService.UpsertResult[] results = service.upsertMetadata(lightningPageList);
            System.debug('@@updateComposerCollection().results='+results);
        }
        catch(Exception ex){
            System.debug('Error Occured while updating lightning composer collection script'+ex.getMessage());
        }
        return new PageReference('/apex/Apttus_Config2__HierarchyViewUpdate2');
    }
}