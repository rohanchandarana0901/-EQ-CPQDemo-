global with sharing class CustomPricingCallbackNE implements Apttus_Config2.CustomClass.IPricingCallback3 {
 
   private Apttus_Config2.ProductConfiguration contextCart; //branch 1 first commit
   private Apttus_Config2.CustomClass.PricingMode currentMode; 
 
 /**
 * Callback at the beginning of the pricing call.
 * Use the start method to initialize state
 * @param cart the cart object
 */
 global void start(Apttus_Config2.ProductConfiguration cart) {
    this.contextCart = cart;
 }
 
 /**
 * Callback to indicate the pricing mode
 * @param mode the pricing mode
 */
 global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
    this.currentMode = mode;
 }
 /**
 * Callback after the price list item is set on the given line item
 * @param itemSO the price list item associated with the line item
 * @param lineItemMO the line item
 */
 global void onPriceItemSet(Apttus_Config2__PriceListItem__c itemSO, Apttus_Config2.LineItem lineItemMO){
 }
 
 /**
 * Callback before pricing the line item collection
 * Use this method to do all required pre-processing to prepare the line items for pricing.
 * @param itemColl the line item collection to pre-process
 */
 global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
 }
 
 /**
 * Callback before pricing the given line item in the line item collection
 * Use this method to do all required pre-processing to prepare the line item for pricing.
 * @param itemColl the line item collectionholding the line item
 * @param lineItemMO the line item to pre-process
 */
 global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
 }
 
 /**
 * Callback after pricing the given line item in the line item collection
 * Use this method to do all required post-processing after the line item is priced
 * @param itemColl the line item collection holding the line item
 * @param lineItemMO the line item to post-process
 */
 global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
 }
 
 /**
 * Callback after pricing the line item collection
 * Use this method to do all required post-processing after line items are priced.
 * @param itemColl the line item collection to post-process
 */
 global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
 }
 
 /**
 * Executes after all batches of line items are processed.
 * The finish method runs after the save operation.
 * Use this method to implement any logic that depends on saved data.
 * Perform updates in this method using a DML operation.
 */
 global void finish() {
            system.debug(this.currentMode + '<> finish()');
            Apttus_Config2__ProductConfiguration__c configSO = this.contextCart.getConfigSO();
            Set<Integer> pr = new Set<Integer>{1};
            Apttus_Config2.FieldExpressionWebService.attachApplicableExpressionsOnAdd(configSO.id, pr);
    }
}
