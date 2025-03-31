@isTest(seeAllData=False)
public class APTS_CalculateTaxDispatcherTest {
  private static final String JSON_CART =  '\'{\'"cartId" : "{0}"}\'';
          
    @isTest
    static void testComputeTax() {
    
        RestRequest req = new RestRequest();
        req.requestURI = '/dc/' + Datetime.now().getTime(); 
        req.httpMethod = 'POST';
        
        Apttus_Config2__ProductConfiguration__c cart = new Apttus_Config2__ProductConfiguration__c(Name = 'Test Cart');
        insert cart;
        String request = '\'{\'"class" : "APTS_CalculateTaxDispatcher", "method" : "{0}", "data" : {1}, "namespace" : "' + '"\'}\'';
        String input = String.format(request, new String[]{'computeTaxForCart', String.format(JSON_CART, new String[]{cart.id})});
        req.requestURI = '/dc/' + Datetime.now().getTime();
        Apttus_WebStore.RemoteDispatcher.DispatchResponse response = Apttus_WebStore.RemoteDispatcher.handlePost(encryptPayload(input));
    }
    
    public static string encryptPayload(string plainText) {       
        blob key =  EncodingUtil.base64Decode('u/Gu5posvwDsXUnV5Zaq4g==');
        blob iv =  EncodingUtil.base64Decode('5D9r9ZVzEYYgha93/aUK2w==');
        blob textBlob = blob.valueOf(plainText);
        blob encryptedData = Crypto.encrypt('AES128', key, iv, textBlob);
        
        return EncodingUtil.base64Encode(encryptedData);    
    }

}