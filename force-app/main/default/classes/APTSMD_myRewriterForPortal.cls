global with sharing class APTSMD_myRewriterForPortal implements Site.UrlRewriter {

    //Variables to represent the user-friendly URLs for
    //account and contact pages
    String HOME_ENGLISH = '/US/en_US';
    String MY_PROFILE = '/US/MyInformation';
    String SUPPORT = '/US/Support';
    String HOME_FRENCH = '/FR/en_US';

    //Variables to represent my custom Visualforce pages
    //that display account and contact information
    String HOME_ENGLISH_VISUALFORCE_PAGE = '/APTSMD_AgreementPortalHomePage'; 
    String HOME_FRENCH_VISUALFORCE_PAGE = '/APTSMD_AgreementPortalHomePage';
    String MY_INFO_VISUALFORCE_PAGE = '/APTSMD_VFP19_MyInformation';
    String SUPPORT_VISUALFORCE_PAGE = '/APTSMD_VFP29_Support';

    global PageReference mapRequestUrl(PageReference myFriendlyUrl) {
        String url = myFriendlyUrl.getUrl();

        if (url.startsWith(HOME_FRENCH)) {
            
            return new PageReference(HOME_FRENCH_VISUALFORCE_PAGE);
        }
        
        if (url.startsWith(HOME_ENGLISH)) {
            
            return new PageReference(HOME_ENGLISH_VISUALFORCE_PAGE);
        }
        
        if (url.startsWith(MY_PROFILE)) {
            
            return new PageReference(MY_INFO_VISUALFORCE_PAGE);
        }
        
        if (url.startsWith(SUPPORT)) {
            
            return new PageReference(SUPPORT_VISUALFORCE_PAGE);
        }
        
        if(url=='/'){
            return new PageReference(HOME_ENGLISH_VISUALFORCE_PAGE);
        }
        //If the URL isn't in the form of a contact or
        //account page, continue with the request
        return null;
    }
    
    global List < PageReference > generateUrlFor(List < PageReference > mySalesforceUrls) {
        List<PageReference> myFriendlyUrls = new List<PageReference>();

        // make the new urls
        Integer counter = 0;

        // it is important to go through all the urls again, so that the order
        // of the urls in the list is maintained. 
        for (PageReference mySalesforceUrl: mySalesforceUrls) {

            //Get the URL of the page
            String url = mySalesforceUrl.getUrl();
            
            if (url.startsWith(HOME_ENGLISH_VISUALFORCE_PAGE)) {
                
                myFriendlyUrls.add(new PageReference(HOME_ENGLISH));
            } else if (url.startsWith(HOME_FRENCH_VISUALFORCE_PAGE)) {
                
                myFriendlyUrls.add(new PageReference(HOME_FRENCH ));
                
            }else if (url.startsWith(MY_PROFILE)) {
                
                myFriendlyUrls.add(new PageReference(MY_INFO_VISUALFORCE_PAGE));
                
            }else if (url.startsWith(SUPPORT)) {
                
                myFriendlyUrls.add(new PageReference(SUPPORT_VISUALFORCE_PAGE));
                
            }else{
                myFriendlyUrls.add(mySalesforceUrl);
            }
        }

        //Return the full list of pages
        return myFriendlyUrls;
    }

}