/**
* 
*/
global class APTS_CalculateTaxDispatcher implements Apttus_WebStore.RemoteDispatcher.DispatchInterface{

    private Static final String ERROR_MESSAGE='Tax could not be calculated for given cart. Please contact your administrator and check tax configuration and try again.'; 
    /**
     * 
     */
    global Apttus_WebStore.RemoteDispatcher.DispatchResponse dispatch(String method, Object jsonData){
        Map<String, Object> data = (Map<String, Object>) jsonData;
        if(method == 'computeTaxForCart')
            return this.computeTaxForCart(data);
        else
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, 'Invalid Endpoint: ' + method);
    }
 
    /**
     * 
     */
    public Apttus_WebStore.RemoteDispatcher.DispatchResponse computeTaxForCart(Map<String, Object> data){
        try 
        {
            Apttus_CPQApi.CPQ.ComputeTaxRequestDO r = new Apttus_CPQApi.CPQ.ComputeTaxRequestDO();
            r.CartId = (String) data.get('cartId');
    
            // Run tax calculate service
            Apttus_CPQApi.CPQ.ComputeTaxResponseDO response= Apttus_CPQApi.CPQWebService.computeTaxForCart(r);
            
            // Run update price service
            Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
            objUpdatePriceRequestDO.CartId = (String) data.get('cartId');
            Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
            
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, response.TotalTaxItem);
        }
        catch(Exception e)
        {
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, ERROR_MESSAGE);
        }
        
        
    }
}