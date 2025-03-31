public class APTSMD_FinalizeCart implements APTSMD_HandlerInterface {
    
    public void executeMethod(string cartId, string param2, string param3, string param4, string param5){
        // Get Cart Record
        List<Apttus_Config2__ProductConfiguration__c> prodConfig = [SELECT Id, Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c 
                                                              			FROM Apttus_Config2__ProductConfiguration__c WHERE Id = :cartId];
        if(!prodConfig.isEmpty()){
            // Fetch oldProdConfig List
            List<Apttus_Config2__ProductConfiguration__c> oldProdConfigList = [SELECT Id, Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c 
                                                                               		FROM Apttus_Config2__ProductConfiguration__c 
                                                                               		WHERE Id != :cartId 
                                                                               			AND Apttus_QPConfig__Proposald__c = :prodConfig[0].Apttus_QPConfig__Proposald__c 
                                                                               			AND Apttus_Config2__Status__c = 'Finalized'];
            // Check for oldProdConfig List
            if(!oldProdConfigList.isEmpty()){
                for(Apttus_Config2__ProductConfiguration__c oldProdConfig : oldProdConfigList){
                    oldProdConfig.Apttus_Config2__Status__c = 'Superseded';
                }
                
                UPDATE oldProdConfigList;
            }
            
            Apttus_CPQApi.CPQ.FinalizeCartRequestDO request = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        	request.CartId = prodConfig[0].Id;
        	Apttus_CPQApi.CPQ.FinalizeCartResponseDO response = Apttus_CPQApi.CPQWebService.finalizeCart(request);
            
            
        }
    }

}