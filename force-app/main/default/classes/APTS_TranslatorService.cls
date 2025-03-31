global class APTS_TranslatorService implements Apttus_WebStore.RemoteDispatcher.DispatchInterface {
   
    global Apttus_WebStore.RemoteDispatcher.DispatchResponse dispatch(String method, Object jsonData){
        Map<String, Object> data =(Map<String, Object>) jsonData;
        
        if(method == 'GetTranslateLabels')
        {
            return this.GetTranslateLabels(data);        
        }
        
       return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, ''); 
    }
        
    
     private Apttus_WebStore.RemoteDispatcher.DispatchResponse GetTranslateLabels(Map<String, Object> data) {
         try
         {
         RestRequest req = RestContext.request;
         PageReference translationPageRef;
         string sfTranslateURL = (String)data.get('sfTranslateURL');
         if(String.isNotBlank(sfTranslateURL))
         {
         	translationPageRef = new PageReference(sfTranslateURL);
         }
         else
         {
             return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, '');
             //translationPageRef = Page.APTS_EcommerceTranslator;
         }
		 translationPageRef.getParameters().put('language', (String)data.get('language'));
         //System.debug(LoggingLevel.INFO, translationPageRef.getUrl());
         string response = EncodingUtil.base64Decode(EncodingUtil.base64Encode(translationPageRef.getContent())).toString().replaceAll('\n', '');
         //System.debug(LoggingLevel.INFO, 'dave lables-- ' + response);
         return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, response);
         }
         catch(Exception e)
         {
         	return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, '');
         }
         
    }
}