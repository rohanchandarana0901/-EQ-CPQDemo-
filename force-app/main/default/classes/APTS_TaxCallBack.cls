global class APTS_TaxCallBack implements Apttus_Config2.CustomClass.ITaxCallback,Apttus_Config2.CustomClass.ITaxCallback2{
    public static List<Apttus_Config2__TaxBreakup__c> taxBreakupList {get;set;}
    
    public Apttus_Config2.CustomClass.TaxResult computeTax (Apttus_Config2.CustomClass.TaxInput input) {
        List<Apttus_Config2.CustomClass.TaxInput> inputs = new List<Apttus_Config2.CustomClass.TaxInput>{input};
        List<Apttus_Config2.CustomClass.TaxResult> results = computeTaxMultiple(inputs);
        return (null == results || 1 > results.size()) ? null : results[0];
    }
    public List<Apttus_Config2.CustomClass.TaxResult> computeTaxMultiple (List<Apttus_Config2.CustomClass.TaxInput> inputs) {
        List<Apttus_Config2.CustomClass.TaxResult> results = new List<Apttus_Config2.CustomClass.TaxResult>();
        Schema.SobjectType sobjectType = inputs[0].Item.getSObjectType();
        System.debug('Hello11 '+String.valueOf(sobjectType));
        if (String.valueOf(sobjectType) == 'Apttus_Config2__LineItem__c') {
           results = APTS_TaxUtility.lineItemTaxEngine(inputs);
        }
        return results;
    }
    
    public void computeTaxForCart(){
        Id cartId = apexpages.currentpage().getparameters().get('id');
        system.debug(cartId +'car id ');
        
         if(String.isNotBlank(cartId)){
            Apttus_CPQApi.CPQ.ComputeTaxRequestDO request = new Apttus_CPQApi.CPQ.ComputeTaxRequestDO();
            request.CartId = cartId;
            Apttus_CPQApi.CPQ.ComputeTaxResponseDO result = Apttus_CPQApi.CPQWebService.computeTaxForCart(request);
            
            taxBreakupList = [select id,name,Apttus_Config2__BreakupType__c,Apttus_Config2__LineItemId__c,Apttus_Config2__Sequence__c,Apttus_Config2__TaxAmount__c,
            Apttus_Config2__TaxAppliesTo__c,Apttus_Config2__TaxRate__c,Apttus_Config2__TaxType__c from Apttus_Config2__TaxBreakup__c 
            where Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c =: cartId and Apttus_Config2__LineItemId__r.Apttus_Config2__LineType__c !='Misc'];
            }
         }
            
}