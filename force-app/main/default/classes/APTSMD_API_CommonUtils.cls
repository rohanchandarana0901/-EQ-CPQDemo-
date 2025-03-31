public class APTSMD_API_CommonUtils {
     
    public static Blob getExceptionMessage(Exception ex){
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('error', ex.getMessage());        
        return APTSMD_API_CommonUtils.convertStringToBlob(JSON.serialize(responseMap));
    }
    
    public static Blob sendErrorMessage(String error){
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('error', error);        
        return APTSMD_API_CommonUtils.convertStringToBlob(JSON.serialize(responseMap));
    }
    
    public static Blob commonErrorMessage(){
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('error', 'Something went wrong, please contact your admin.');  
        return APTSMD_API_CommonUtils.convertStringToBlob(JSON.serialize(responseMap));
    }
    
    public static Blob convertStringToBlob(String stringToConvert){
        return Blob.valueOf(stringToConvert);
    }
    
    // Get E-Commerce URL (Added by Jigar Naik 06/07/2019)
    public static String getECommerceCommunityURL(){
        for(ConnectApi.Community community : ConnectApi.Communities.getCommunities().communities){
            if(community.siteURL.contains('/ecomm'))
            return community.siteURL;
        }
        
        return null;
    }
    
    // Get Partner Commerce URL (Added by Jigar Naik 01/23/2020)
    public static String getPartnerCommerceCommunityURL(){
        for(ConnectApi.Community community : ConnectApi.Communities.getCommunities().communities){
            if(community.siteURL.contains('/pcomm'))
            return community.siteURL;
        }
        
        return null;
    }
}