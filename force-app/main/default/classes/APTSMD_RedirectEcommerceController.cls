public class APTSMD_RedirectEcommerceController {

    String retUrl;
    
    public PageReference redirect(){
        ConnectApi.CommunityPage comPage = ConnectApi.Communities.getCommunities();
        
        for(ConnectApi.Community com : comPage.communities){
            if(com.urlPathPrefix!=null && com.urlPathPrefix.equalsIgnoreCase('ecomm')){
                retUrl = com.siteUrl;
            }
        }
        
        retUrl +='/APTSMD_Webstore';
        return new PageReference(retUrl);
        
    }   
}