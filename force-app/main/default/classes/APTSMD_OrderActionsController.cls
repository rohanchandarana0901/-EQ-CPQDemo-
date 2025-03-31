/**
 * Class: APTSMD_OrderActionsController
 *    Defines aura enabled methods for Apttus Orders  
 */
public class APTSMD_OrderActionsController {
/**
 * Returns Fields Required for the Component
 * 
 * 
 */
     @AuraEnabled
    public static Apttus_Config2__Order__c getOrder(Id orderId) {
        System.debug('inside controller');
        List<Apttus_Config2__Order__c> order 
            = [SELECT Id, Name,APTSMD_Flow__c,
                     Apttus_Config2__PriceListId__c, 
                      Apttus_Config2__Status__c
          FROM Apttus_Config2__Order__c 
        WHERE Id =: orderId
                LIMIT 1];
        
        System.debug('Query Executed:'+order);
        if(!order.isEmpty()) {
            return order[0];

        } else {
            return null;
        }
    }
}