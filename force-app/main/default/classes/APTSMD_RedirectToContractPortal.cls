public class APTSMD_RedirectToContractPortal {

    public PageReference redirect(){
        String retUrl;
      
        ConnectApi.CommunityPage comPage = ConnectApi.Communities.getCommunities();
        for(ConnectApi.Community com : comPage.communities){
            if(com.urlPathPrefix!=null && com.urlPathPrefix.equalsIgnoreCase('AgreementPortal')){
                retUrl = com.siteUrl;
            }
        }
        return new PageReference(retUrl);
        
    }   
}