public class APTSMD_UpdateStoreFrontBannerLinksCtrl{
    
    public void updateBannerLinks(){
        updateSingleStorefront('Tier1 Store');
        updateSingleStorefront('Tier1 Store (Blue Theme)');
        updateSingleStorefront('Tier1 Partner Store');
        setInvoiceDocumentsVisibility();
        updateECommerceRemoteSite();
    }
    
    private void updateSingleStorefront(String storeName){
        //Fatching all attchments
        List<Attachment> attchments = [SELECT Id, Name FROM Attachment where Parent.Name= :storeName];  
        
        //Get guest user details
        List<User> userList = [Select Id, Username from User Where FirstName = 'Guest' and LastName = 'User'];
        
        //Storefront Logo Id Update
        Apttus_WebStore__Storefront__c storefront = [Select Id, Name, Apttus_WebStore__Logo__c,  Apttus_WebStore__Guest_Username__c From Apttus_WebStore__Storefront__c Where Name = :storeName];
        for(Attachment a : attchments){
            if(a.Name.substringBefore('.') == 'Tier1 Logo'){
                storefront.Apttus_WebStore__Logo__c = a.id;
                storefront.Apttus_WebStore__Guest_Username__c = userList[0].Username;
                update storefront;
                break;
            }else if(a.Name.substringBefore('.') == 'Tier1 Partner Store'){
                storefront.Apttus_WebStore__Logo__c = a.id;
                update storefront;
                break;
            }
        }
    
        //Getting all banners
        List<Apttus_WebStore__StorefrontBanner__c> banners = [select id, Apttus_WebStore__Title__c, Apttus_WebStore__Image__c from Apttus_WebStore__StorefrontBanner__c where Apttus_WebStore__StorefrontId__r.Name = :storeName];
        
        //Setting all banner image links
        if(attchments.size()> 0 && banners != null){
            for(Apttus_WebStore__StorefrontBanner__c b : banners){
                for(Attachment a : attchments){
                    if(a.Name.substringBefore('.').toUpperCase() == b.Apttus_WebStore__Title__c.toUpperCase()){
                        b.Apttus_WebStore__Image__c = a.id;
                    }
                }  
            }
        }
        if(banners.size() > 0){
            update banners;
            System.debug(Limits.getDmlRows());
        }
        
        //Updated Banners List
        //Getting all sub banners
        List<APTSMD_Storefront_Sub_Banner__c> subBanners = [select id, APTSMD_Banner_Label__c, APTSMD_Banner_Image__c from APTSMD_Storefront_Sub_Banner__c where APTSMD_Storefront__r.Name = :storeName];
        
        //Setting all banner image links
        if(attchments.size()> 0 && subBanners != null){
            for(APTSMD_Storefront_Sub_Banner__c b : subBanners){
                for(Attachment a : attchments){
                    if(a.Name.substringBefore('.').toUpperCase() == b.APTSMD_Banner_Label__c.toUpperCase()){
                       b.APTSMD_Banner_Image__c = a.id;
                    }
                }  
            }
        }
        if(subBanners.size() > 0){
            update subBanners;
        }
        
        //Updated Side Banners List
        //Getting all side banners
        List<APTSMD_Storefront_Side_Banner__c> sideBanners = [select id, APTSMD_Side_Banner_Label__c, APTSMD_Side_Banner_Image__c from APTSMD_Storefront_Side_Banner__c where APTSMD_Storefront__r.Name = :storeName];
        
        //Setting all banner image links
        if(attchments.size()> 0 && sideBanners != null){
            for(APTSMD_Storefront_Side_Banner__c b : sideBanners){
                for(Attachment a : attchments){
                     if(a.Name.substringBefore('.').toUpperCase() == b.APTSMD_Side_Banner_Label__c.toUpperCase()){
                         b.APTSMD_Side_Banner_Image__c = a.id;
                     }
                }  
            }
        }
        if(sideBanners.size() > 0){
            update sideBanners;
        }
    }
    
    public void setInvoiceDocumentsVisibility(){
        list<string> biList = new List<string>();

        for(Apttus_Billing__Invoice__c i : [select id from Apttus_Billing__Invoice__c]){
            biList.add(i.id);
        }
        
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl : [select id,visibility,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :biList]){
            cdl.visibility = 'AllUsers';
            cdList.add(cdl);
        }
        
        update(cdList);
    }
    
    @future(callout=true)
    public static void updateECommerceRemoteSite(){
        for(ConnectApi.Community community : ConnectApi.Communities.getCommunities().communities){
            if(community.siteURL.contains('/ecomm')){
                updateRemoteSiteSetting(community.siteURL);
            }
        }
    }
    
    public static void updateRemoteSiteSetting(String ServerUrl){
        MetadataService.MetadataPort service = createService();
        MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = 'APTSMD_ECOMM_URL';
        remoteSiteSettings.url = ServerUrl;
        remoteSiteSettings.isActive = true;
        remoteSiteSettings.disableProtocolSecurity = false;
        MetadataService.UpsertResult[] results = service.upsertMetadata(new List<MetadataService.Metadata> { remoteSiteSettings });
    }
    
    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
        service1.SessionHeader = new MetadataService.SessionHeader_element();
        service1.SessionHeader.sessionId = UserInfo.getSessionId();
        return service1;
    }
}