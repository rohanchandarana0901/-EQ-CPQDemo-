global with sharing class APTSMD_CustomABOCallback implements System.callable {
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'sortAssets' {
                // get the cart managed object
                Apttus_Config2.ProductConfiguration cart = (Apttus_Config2.ProductConfiguration) args.get('cart');
                // get the asset item ids
                List<ID> assetItemIds = (List<ID>) args.get('assetItemIds');
                // sort the asset item ids and create the sorted collection
                List<ID> sortedAssetItemIds = new List<ID>();
                for ( Apttus_Config2__AssetLineItem__c asset : [SELECT Id from Apttus_Config2__AssetLineItem__c WHERE ID IN :assetItemIds ORDER BY CreatedDate DESC]) {
                    sortedAssetItemIds.add(asset.Id);
                }
                // return the sorted asset item ids
                return sortedAssetItemIds;
            }
            when else {
                return null;
            } 
        }  
    }
}