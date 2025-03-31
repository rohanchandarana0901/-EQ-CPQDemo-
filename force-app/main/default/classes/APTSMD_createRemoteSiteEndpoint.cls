public with sharing class APTSMD_createRemoteSiteEndpoint {

    public void createRemoteSiteSetting(String ServerUrl){
        MetadataService.MetadataPort service = createService();
        MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = 'CSOrgAccess' + Math.round(Math.random()*1000);
        remoteSiteSettings.url = ServerUrl;
        remoteSiteSettings.isActive = true;
        remoteSiteSettings.disableProtocolSecurity = false;
        MetadataService.SaveResult[] results = service.createMetadata(new List<MetadataService.Metadata> { remoteSiteSettings });
    }
    
    public void updateRemoteSiteSetting(Map<String, String> remoteSiteSettingsMap){
        MetadataService.MetadataPort service = createService();
        
        List<MetadataService.Metadata> remoteSiteSettingList = new List<MetadataService.Metadata>();
        for(String siteName : remoteSiteSettingsMap.keySet()){
            MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
            remoteSiteSettings.fullName = siteName;
            remoteSiteSettings.url = remoteSiteSettingsMap.get(siteName);
            remoteSiteSettings.isActive = true;
            remoteSiteSettings.disableProtocolSecurity = false;
            remoteSiteSettingList.add(remoteSiteSettings);
        }
        
        MetadataService.UpsertResult[] results = service.upsertMetadata(remoteSiteSettingList);
    }
    
    public MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
        service1.SessionHeader = new MetadataService.SessionHeader_element();
        service1.SessionHeader.sessionId = UserInfo.getSessionId();
        return service1;
    }

}